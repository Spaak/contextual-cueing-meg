# Spaak & De Lange (2019) Analysis code

This is the analysis code related to Spaak & De Lange (2019) paper "Hippocampal and prefrontal theta-band mechanisms underpin implicit spatial context learning".

## Getting started

### Dependencies

You'll need Matlab or Octave (tested with Matlab version R2017a) and [FieldTrip](https://github.com/fieldtrip/fieldtrip) installed. I think any recent version of FieldTrip should work; but see below for which specific versions were used/tested for the paper.

If you want to run the switchpoint analyses, you'll need to have a scientific Python stack available, with [PyMC3](https://github.com/pymc-devs/pymc3) and its dependencies (notably, [Theano](https://github.com/Theano/Theano)) installed.

The analysis for the paper was performed using FieldTrip commit [6414ea0](https://github.com/fieldtrip/fieldtrip/tree/6414ea000dcf5bba0ec43ce6487e3425e480b161), which you'll be able to obtain using

```
git clone git@github.com:fieldtrip/fieldtrip.git
cd fieldtrip
git checkout 6414ea000dcf5bba0ec43ce6487e3425e480b161
```

PyMC3 version used for the paper for is [24730cc](https://github.com/Spaak/pymc3/tree/24730cc360852e27020f5b7c5ca07d3791ccb167), for Theano it's [93e8180](https://github.com/Theano/Theano/tree/93e8180bf08b6fbe587b6f0ecc877ec90e6e1681).)

### Installing and basic setup

* Install dependencies (see above).
* Clone or download this repo like normal (see green "Clone or download" button in the top right corner of this page).
* Get a copy of the (raw and processed) [data from the repository](https://hdl.handle.net/11633/aacstiks).
* Configure some paths in the code:
    * `matlab/run_all_analyses.m` - set `data_dir` to where you put the data from the repository.
    * `matlab/run_all_analyses.m` - set `results_dir` to where the results (figures and outputs of statistical tests) should appear. Will be created if it does not exist.
    * `matlab/set_path.m` - set the line referring to FieldTrip to point to where you installed FieldTrip.
    * `matlab/lib/myqsub.m` - set `matlabcmd` to your Matlab executable (I recommend leaving the `nodesktop -nosplash` flags intact).
    * `matlab/lib/myqsub.m` - set `workingdir` to the Matlab working directory (usually the folder in which you cloned this repo + `/matlab`).
    * `python/analysis.py` - set `rootdir` to the same as Matlab's `data_dir` above.
    * `python/run_switchpoint_analyses.py` - set `working_dir` to the working directory of the Python script (usually the folder in which you cloned this repo + `/python`).

That's it! You should be able to [run the code](#running-it) now.

### Further setup options

You can change the variable `run_mode` in `matlab/run_all_analyses.m` to specify whether and how you want the actual analyses starting from raw data to be executed. Quoting from the comments in that file:

```
% Analyses can be run in one of three modes: in-process (each subject
% sequentially, very slow); individual qsub jobs (can also be relatively
% slow, since every job will need to read in the full original data); or in
% a slave pool running on the cluster (one long-running daemon job per
% subject, keeping that subject's data in memory; execute jobs as instructed 
% by the master script; fastest option).
% Alternatively, you can specify run_mode = 'load-only' to not execute the
% individual jobs starting from raw data at all, and instead load the
% intermediate results that should already be on disk.
% Behavioural analyses (with the exception of the Bayesian modelling) are
% all very fast and will always be done in-process.
```

The easiest is to leave it at `load-only` of course (use existing intermediate results). Also rather fool-proof is `in-process`, although that will take a long time. The other options `qsub` and `slavepool` require a Torque cluster backend (like the one running at the Donders Centre for Cognitive Neuroimaging) and a Linux environment. The other run modes should (I think) also run under Windows, but I haven't tested this.

Additionally, the variable `call_python` in the same file allows you to specify whether or not you want the MCMC Python code to be run at all. This might save you the hassle of setting up a Python environment with all the packages etc. installed. The relevant last bit of this analysis pipeline will then simply use the intermediate results that were provided in the data repository.

The Python code has an analogous `run_mode` variable that can be `qsub` or `in_process`.

## Running it

Start matlab, change directory to `<repo_dir>/matlab`, and execute `run_all_analyses`.

## Preprocessing

The analysis code starts either from the intermediate results (when `run_mode` equals `load-only`), or from the raw, yet artifact-cleaned and down-sampled, data (the `preproc-data-artreject-400hz.mat` files from the repository; other run modes). If you want to start from the _raw_ raw data, i.e. the `.ds` datasets as they were recorded by the CTF MEG machine, you can do so by using the code in the `matlab/preproc` folder. This code is not as streamlined as the analysis code, and requires manual interaction. Steps are, per subject:

* `run_preproc_beforeica`
* `run_preproc_ica`
* `run_preproc_after_ica`

You will probably need to change the default `rootdir` inside `datainfo` to point to the data from the repository.

Note that there are also a few files included in `preproc` related to the preprocessing of anatomical (MRI) data for the source analysis steps. You will not be able to run this code without the individual MRI images and headshape (Polhemus) files, which are not provided in the data repository due to privacy reasons. The resulting volume conduction and source models _are_ included as intermediate files.
