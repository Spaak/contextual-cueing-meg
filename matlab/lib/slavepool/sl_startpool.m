function sl_startpool(dowait, all_ids)

if nargin < 1 || isempty(dowait)
  dowait = 0;
end

if nargin < 2 || isempty(all_ids)
  [subjects,all_ids,rootdir] = datainfo();
end

% first delete all the marker files in ~/.matlabslaves
system('cd ~/.matlabslaves; rm *');

% now submit to Torque
myqsub('sl_startslave',...
  'mem=16gb,walltime=8:00:00,nodes=1:intel:network10GigE:ppn=1', all_ids,...
  '-noquit');

if dowait
  % and wait until all are running
  slaves = [];
  fprintf('waiting for slave pool to start...\n');
  while numel(slaves) < numel(all_ids)
    slaves_new = sl_findslaves();
    if numel(slaves_new) > numel(slaves)
      fprintf('%d slaves found\n', numel(slaves_new));
      slaves = slaves_new;
    end
    pause(0.1);
  end

  fprintf('all slaves ready and at your command\n');
else
  fprintf('slave jobs submitted to Torque queue, not waiting for them to start\n');
end

end