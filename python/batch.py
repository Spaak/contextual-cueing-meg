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

import multiprocessing
import numpy as np
import time
import os
import psutil
import traceback
import sys
import warnings
import itertools as it

# number of processes to spawn when doing multiprocessing
num_gpu_workers = 0
numMultiProc = 8

max_jobs_per_pool = 3000

progressVal = None
notCopiedArg = None
NOT_COPIED_ARG_FLAG = 'NOT_COPIED_ARG'

_pass_kwargs = None

_worker_pool = None

# approx. chunksize to pass to pool (note: different from chunks as defined below!)
_pool_chunksize = 1

worker_num = -1

# hack to have some GPU and some CPU workers

env_args = [dict(THEANO_FLAGS='device=gpu{}'.format(k)) for k in range(num_gpu_workers)]
env_args += [dict(THEANO_FLAGS='device=cpu')] * (numMultiProc-num_gpu_workers)

def _init_pool_worker(progVal, env_queue, num_queue):
    global progressVal, worker_num
    np.random.seed(os.getpid())
    print('pool worker random generator seeded to {}'.format(os.getpid()))
    if os.name == 'nt':
        sys.stdout.flush()
    progressVal = progVal

    d = env_queue.get()
    print('updating with {}'.format(d))
    os.environ.update(d)

    worker_num = num_queue.get()


def _init_multiprocessing_pool():
    # environment variables for the workers
    env_queue = multiprocessing.Queue(numMultiProc)
    num_queue = multiprocessing.Queue(numMultiProc)
    for arg in env_args:
        env_queue.put(arg)
    for k in range(numMultiProc):
        num_queue.put(k)

    pool = multiprocessing.Pool(numMultiProc, initializer=_init_pool_worker,
        initargs=(progressVal, env_queue, num_queue))
    # lower child process priority to keep machine responsive
    for child in psutil.Process().children():
        # this is different for windows/Linux
        if os.name == 'nt':
            child.nice(psutil.BELOW_NORMAL_PRIORITY_CLASS)
        else:
            child.nice(5)
    return pool
    
def _job_progress(func, index, *args):
    global progressVal, _pass_kwargs

    # see if we need to put the non-copied arg back in
    try:
        # this will throw a numpy warning if numpy arguments are present in the
        # list, due to a bug in numpy
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', category=FutureWarning)
            ind = args.index(NOT_COPIED_ARG_FLAG)

        theArgs = list(args)
        theArgs[ind] = notCopiedArg
    except ValueError:
        # NOT_COPIED_ARG_FLAG was not present
        theArgs = args
    
    try:
        retVal = func(*theArgs, **_pass_kwargs)
    except Exception as e:
        # catch here, so we can print the stack trace
        print('exception in worker processing element {}'.format(index))
        traceback.print_exc()
        if os.name == 'nt':
            sys.stdout.flush()
            sys.stderr.flush()
        raise e
        
    with progressVal.get_lock():
        progressVal.value += 1
    return retVal

def _process_chunk(func, chunk, total_length, startTime,
    print_progress=True, job_label='job'):
    resObj = _worker_pool.starmap_async(func, chunk, chunksize=_pool_chunksize)
    prevVal = 0
    while not resObj.ready():
        with progressVal.get_lock():
            newVal = progressVal.value
        if newVal > prevVal:
            elapsed = time.time()-startTime
            remaining = elapsed/newVal * (total_length-newVal)
            if print_progress:
                print('{}: {} of {} done, elapsed {:.0f}s, remaining {:.0f}s'
                    .format(job_label, newVal, total_length, elapsed, remaining))
            prevVal = newVal
        resObj.wait(1)

    return resObj.get(1)
    
def starmap(func, iterable, kwargs=None, job_label='job', in_process=False,
    no_copy_arg=None, print_progress=True):
    global _worker_pool, _pass_kwargs

    if kwargs is None:
        kwargs = dict()
    _pass_kwargs = kwargs

    startTime = time.time()
    if in_process:
        iterable = list(iterable) # make it a list to determine its length
        numArgs = len(iterable)
        retVal = []
        for ind, elem in enumerate(iterable):
            retVal.append(func(*elem, **kwargs))
            elapsed = time.time()-startTime
            remaining = elapsed/(ind+1) * (numArgs-ind-1)
            if print_progress:
                print('{}: {} of {} done, elapsed {:.0f}s, remaining {:.0f}s'
                    .format(job_label, ind+1, numArgs, elapsed, remaining))
        return retVal
    else:
        global progressVal
        global notCopiedArg
        
        # new iterable adding in the function doing the work
        # facilitate applying the function multiple times on the same data
        # this tweak prevents the data from having to be copied multiple times
        if no_copy_arg is not None:
            iterArgs = []
            for k, x in enumerate(iterable):
                x = list(x) # to make it mutable
                notCopiedArg = x[no_copy_arg]
                x[no_copy_arg] = NOT_COPIED_ARG_FLAG
                iterArgs.append( (func, k) + tuple(x) )
        else:
            iterArgs = [(func,k) + tuple(x) for k, x in enumerate(iterable)]
            
        if progressVal is None:
            progressVal = multiprocessing.Value('I', 0)
        if _worker_pool is None:
            _worker_pool = _init_multiprocessing_pool()
            
        with progressVal.get_lock():
            progressVal.value = 0
             
        # process the list in multiple chunks, because if we do not refresh our
        # multiprocessing.Pool then we will run out of memory. Due to a bug in
        # Python??
        
        total_length = len(iterArgs)
        
        if total_length <= max_jobs_per_pool:
            retval = _process_chunk(_job_progress, iterArgs, total_length,
                startTime, print_progress=print_progress, job_label=job_label)
            _worker_pool.close()
            _worker_pool = None
            progressVal = None
            return retval
        else:
            chunks = [iterArgs[i:i+max_jobs_per_pool]
                for i in range(0, total_length, max_jobs_per_pool)]
            retval = []
            for k, chunk in enumerate(chunks):
                retval.extend(_process_chunk(_job_progress, chunk, total_length,
                    startTime, print_progress=print_progress, job_label=job_label))
                    
                if k < len(chunks)-1:
                    print('refreshing worker pool...')
                    with progressVal.get_lock():
                        cur_progress = progressVal.value
                        
                    _worker_pool.close()
                    _worker_pool = None
                    progressVal = None
                    # not sure we need to reinitialize progressVal, but do it just in case
                    progressVal = multiprocessing.Value('I', cur_progress)
                    _worker_pool = _init_multiprocessing_pool()

            _worker_pool.close()
            _worker_pool = None
            progressVal = None
            return retval
