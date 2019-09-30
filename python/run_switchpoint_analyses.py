import itertools as it

import numpy as np
import pymc3 as pm

import os
import analysis
import batch


run_mode = 'qsub'
working_dir = '~/ctxcue/analysis-python-4archiving'


model_types = ('noctxcue', 'nosp', 'sp', 'linear', 'blocklinear', 'quadratic')

# helper function to submit jobs to Torque cluster
def qsub(reqstring, module, fun, *args, **kwargs):
    nargs = len(args)
    njob = len(args[0])
    
    pythoncmd = 'python'
    for k, thisargs in enumerate(zip(*args)):
        argslist = ','.join([str(x) for x in thisargs])
        pythonscript = 'from {} import {}; kwargs={}; {}({}, **kwargs)'.format(module,
            fun, kwargs, fun, argslist)
        
        # escape the python script so that ' is output correctly by echo
        pythonscript = pythonscript.replace("'", "'\\''")
        
        # Note that this python call explicitly sets the python path by loading
        # the ~/condapath4jobs file. This should not normally be necessary,
        # since Torque should take care of path inheritance. Unfortunately, it
        # turns out that sometimes this fails so set the path explicitly in the
        # slave jobs.
        pythoncmd = 'source ~/condapath4jobs; cd {}; python -c "{}"'.format(
            working_dir, pythonscript)
        #pythoncmd = 'cd {}; python -c "{}"'.format(working_dir, pythonscript)
        
        qsubcmd = 'qsub -l {} -N j{}_{}'.format(reqstring, thisargs[0], fun)
        fullcmd = 'echo \'{}\' | {}'.format(pythoncmd, qsubcmd)
        
        os.system(fullcmd)
    
    
def run_samplers():
    subject_ids = list(range(36))
    detrend_blockwise = (False, True)
    
    if run_mode == 'qsub':
        for mt, db in it.product(model_types, detrend_blockwise)
            myqsub.qsub('mem=6gb,walltime=00:45:00,nodes=1:intel:ppn=4',
                'analysis', 'sample_and_save_subj', list(range(36)),
                model_type=mt, detrend_blockwise=db)
    else:
        for mt, db, sub_id in it.product(model_types, detrend_blockwise,
            subject_ids):
        analysis.sample_and_save_subj(sub_id, model_type=mt,
            detrend_blockwise=db)
    
    
def do_model_comparison_and_export():
    detrend_blockwise = (False, True)
    
    for db in detrend_blockwise:
        # load traces
        alltrace, allmodel = list(zip(*[analysis.load_traces(mt,
            detrend_blockwise=db, do_wait=True) for mt in model_types]))
        allwaic = [batch.starmap(pm.waic, zip(tr, mod))
            for tr, mod in zip(alltrace, allmodel)]
        
        npwaic = np.asarray([[x.WAIC for x in y] for y in allwaic])
        np.savetxt(analysis.rootdir +
            '/processed/combined/npwaic-blockwisedetrend={}.txt'.format(db),
            npwaic)
        
        if ~detrend_blockwise:
            # also export raw switchpoint samples
            sp_ind = model_types.index('sp')
            allsp = np.asarray([x['switchpoint'] for x in alltrace[sp_ind]])
            np.savetxt(analysis.rootdir +
                '/processed/combined/subject-switchpoints.txt', allsp)


if __name__ == '__main__':
    run_samplers()
    do_model_comparison_and_export()