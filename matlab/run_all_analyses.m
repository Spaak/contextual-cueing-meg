% Analyses can be run in one of three modes: in-process (each subject
% sequentially, very slow); individual qsub jobs (can also be relatively
% slow, since every job will need to read in the full original data); or in
% a slave pool running on the cluster (one long-running daemon job per
% subject, keeping that subject's data in memory; execute jobs as instructed 
% by the master script; fastest option).
% Behavioural analyses (with the exception of the Bayesian modelling) are
% all very fast and will always be done in-process.

run_mode = 'slavepool';
data_dir = '/project/3018029.07/';
results_dir = '/home/predatt/eelspa/ctxcue/4archiving/results/';

set_path();

if strcmp(run_mode, 'slavepool')
  sl_startpool(1); % 1 - wait for slaves to start
end

[subjects, all_ids, rootdir] = datainfo(data_dir);

run_analyses_behaviour_main(results_dir, all_ids);

export_behaviour_data_for_modelling(all_ids, rootdir);

% actual MCMC sampling is done in Python
system('cd ../python; python run_switchpoint_analyses.py');

run_analyses_behaviour_modelling(results_dir, rootdir);

run_analyses_sensor_tfr(run_mode, results_dir, subjects, all_ids);

run_analyses_theta_beamformer(run_mode, results_dir, subjects, all_ids, rootdir);

run_analyses_theta_source_rois(run_mode, results_dir, subjects, all_ids, rootdir);

run_analyses_behaviour_recognitiontask(results_dir, all_ids);
