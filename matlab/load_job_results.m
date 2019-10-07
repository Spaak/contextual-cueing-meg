function results = load_job_results(subjects, all_ids, filename, varname)
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

results = {};
for k = 1:numel(all_ids)
  subj_id = all_ids(k);
  fprintf('loading data for subject ID = %d...\n', subj_id);
  load(fullfile(subjects(subj_id).dir, filename), varname);
  eval(sprintf('results{k} = %s;', varname));
end

end