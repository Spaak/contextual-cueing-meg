function sl_startpool(dowait, all_ids)
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