function export_behaviour_data_for_modelling(all_ids, rootdir)
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

allrts = {};
allcond = {};
allinds = {};

for k = 1:numel(all_ids)
  [stim,rts,responses] = load_behav(all_ids(k));
  
  use_blocks = 1:22;
  maintri = ismember(stim.blocks, use_blocks);
  correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
      (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
  viol = stim.is_distractor_violation | stim.is_target_violation;
  
  usetri = maintri & correct & ~viol;
  
  allrts{k} = rts(usetri);
  allcond{k} = stim.is_old(usetri);
  
  % trial indices
  allinds{k} = find(usetri);
end

save(fullfile(rootdir, 'processed', 'combined', 'all-rt-dat-for-modelling.mat'),...
  'allrts', 'allcond', 'allinds');

end