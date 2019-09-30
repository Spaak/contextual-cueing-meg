function results = run_individual_jobs(jobname, varname, subjects, all_ids, runmode, reqstring)
% This is a helper function that runs the specified function either
% in-process for all subjects, or submits Torque jobs, or uses an already
% running slave pool on Torque. In all cases, the function waits until all
% results are ready before returning.
% Job functions must take a subject ID as the only required, first, input
% argument. For execution inside a slave pool, they can also take a second
% input argument, which will be in-memory data (so they don't need to be
% read from disk every time).

if nargin < 6 || isempty(reqstring)
  % only used for runmode == 'qsub'
  reqstring = 'mem=16gb,walltime=01:00:00,nodes=1:intel';
end

if strcmp(runmode, 'in-process')
  for k = 1:numel(all_ids)
    fprintf('executing %s for subject ID %d...\n', jobname, all_ids(k));
    eval(sprintf('%s(%d)', jobname, all_ids(k)));
  end
elseif strcmp(runmode, 'qsub')
  fprintf('executing %s for all participants using Torque cluster...\n', jobname);
  myqsub(jobname, reqstring, all_ids);
elseif strcmp(runmode, 'slavepool')
  fprintf('executing %s for all participants using existing slave pool in Torque cluster...\n', jobname);
  sl_sendbatch(jobname, all_ids);
end

% now wait for the results to appear
hasresults = false(size(all_ids));
prevsum = 0;
fprintf('waiting for results...\n');
while sum(hasresults) < numel(all_ids)
  for k = find(~hasresults)
   hasresults(k) = exist(fullfile(subjects(all_ids(k)).dir, [jobname '.mat']), 'file') == 2;
  end
  if sum(hasresults) > prevsum
    fprintf('%d out of %d jobs done\n', sum(hasresults), numel(all_ids));
    prevsum = sum(hasresults);
  end
  pause(0.1);
end

results = load_job_results(subjects, all_ids, jobname, varname);

end