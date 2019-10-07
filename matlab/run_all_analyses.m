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
%
% Copyright (C) Eelke Spaak, Donders Institute, Nijmegen, The Netherlands, 2019.
% 
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this code. If not, see <https://www.gnu.org/licenses/>.

run_mode = 'load-only';
data_dir = '/project/3018029.07/';
results_dir = '/home/predatt/eelspa/ctxcue/4archiving/results/';

call_python = false;

mkdir(results_dir);

set_path();

if strcmp(run_mode, 'slavepool')
  sl_startpool(1); % 1 - wait for slaves to start
end

[subjects, all_ids, rootdir] = datainfo(data_dir);

run_analyses_behaviour_main(results_dir, all_ids);

export_behaviour_data_for_modelling(all_ids, rootdir);

if call_python
  % actual MCMC sampling is done in Python
  system('cd ../python; python run_switchpoint_analyses.py');
end

run_analyses_behaviour_modelling(results_dir, rootdir);

run_analyses_sensor_tfr(run_mode, results_dir, subjects, all_ids);

run_analyses_theta_beamformer(run_mode, results_dir, subjects, all_ids, rootdir);

run_analyses_theta_source_rois(run_mode, results_dir, subjects, all_ids, rootdir);

run_analyses_behaviour_recognitiontask(results_dir, all_ids);
