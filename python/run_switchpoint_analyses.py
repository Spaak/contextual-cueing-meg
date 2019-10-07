#
# Copyright (C) Eelke Spaak, Donders Institute, Nijmegen, The Netherlands, 2019.
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code. If not, see <https://www.gnu.org/licenses/>.

import itertools as it

import numpy as np
import pymc3 as pm

import os
import analysis
import batch


run_mode = 'qsub'
working_dir = '~/ctxcue/4archiving/python'


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
        
        pythoncmd = 'cd {}; python -c "{}"'.format(
            working_dir, pythonscript)
        #pythoncmd = 'cd {}; python -c "{}"'.format(working_dir, pythonscript)
        
        qsubcmd = 'qsub -V -l {} -N j{}_{}'.format(reqstring, thisargs[0], fun)
        fullcmd = 'echo \'{}\' | {}'.format(pythoncmd, qsubcmd)
        
        os.system(fullcmd)
    
    
def run_samplers(skip_existing=False):
    # Actually run the MCMC samplers, either on a Torque cluster
    # or in-process (depending on module variable 'run_mode'.
    # skip_existing allows you to run only those samplers that have not
    # been run successfully, e.g. due to Torque cluster instability/timeouts.
    subject_ids = list(range(36))
    detrend_blockwise = (False, True)
    filepattern = analysis.rootdir + '/processed/python-scratch/{}_trace_sub{:02d}_detrend_blockwise={}.pkl.gz'
    
    for mt, db in it.product(model_types, detrend_blockwise):
        if skip_existing:
            this_ids = []
            for sub_id in subject_ids:
                if not os.path.isfile(filepattern.format(mt, sub_id, db)):
                    this_ids.append(sub_id)
        else:
            this_ids = subject_ids
            
        if run_mode == 'qsub':
            if len(this_ids) > 0:
                qsub('mem=6gb,walltime=00:45:00,nodes=1:intel:ppn=4',
                    'analysis', 'sample_and_save_subj', this_ids,
                    model_type=mt, detrend_blockwise=db)
        else:
            for sub_id in this_ids:
                analysis.sample_and_save_subj(sub_id, model_type=mt,
                    detrend_blockwise=db)
    
    
def do_model_comparison_and_export():
    detrend_blockwise = (False, True)
    
    for db in detrend_blockwise:
        # load traces
        alltrace, allmodel = list(zip(*[analysis.load_traces(mt,
            detrend_blockwise=db, do_wait=False) for mt in model_types]))
        # can set in_process=False to use multiprocessing (8 processed by default)
        # this sometimes is not even faster due to Theano compiledir locks
        allwaic = [batch.starmap(pm.waic, zip(tr, mod), in_process=True)
            for tr, mod in zip(alltrace, allmodel)]
        
        npwaic = np.asarray([[x.WAIC for x in y] for y in allwaic])
        np.savetxt(analysis.rootdir +
            '/processed/combined/npwaic-blockwisedetrend={}.txt'.format(db),
            npwaic)
        
        if not detrend_blockwise:
            # also export raw switchpoint samples
            sp_ind = model_types.index('sp')
            allsp = np.asarray([x['switchpoint'] for x in alltrace[sp_ind]])
            np.savetxt(analysis.rootdir +
                '/processed/combined/subject-switchpoints.txt', allsp)


if __name__ == '__main__':
    run_samplers()
    do_model_comparison_and_export()