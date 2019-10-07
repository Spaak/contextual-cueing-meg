function sl_sendbatch(cmd, all_ids)
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

if nargin < 2 || isempty(all_ids)
  [~,all_ids,~] = datainfo();
end

slaves = sl_findslaves();
assert(numel(slaves) == numel(all_ids));

% check there is a slave running for every subject ID, just to be sure
found = false(numel(slaves), 1);
for k = 1:numel(all_ids)
  for l = 1:numel(slaves)
    if all_ids(k) == slaves(l).subj_id
      found(k) = 1;
      break;
    end
  end
end
assert(numel(all_ids) == numel(slaves) && all(found));

% execute the command given by cmd with (subj_id, data) as arguments on the
% slaves
% precede that with a 'clear [cmd]' to disable caching
for k = 1:numel(slaves)
  sl_sendcommand(slaves(k).host, slaves(k).port,...
    sprintf('clear %s;', cmd));
  sl_sendcommand(slaves(k).host, slaves(k).port,...
    sprintf('%s(subj_id, data);', cmd));
end

end