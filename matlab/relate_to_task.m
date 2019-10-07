function vars = relate_to_task(subj_id, rawvar, trial_ids, combine_blocks, use_blocks)
% This function relates some variable (e.g. power) to the experiment
% structure; e.g. condition- and block-wise means etc.
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

if nargin < 4
  combine_blocks = 0;
end

if size(rawvar, 2) > size(rawvar, 1)
  rawvar = rawvar';
end

[stim,~,responses] = load_behav(subj_id);

if nargin < 5 || isempty(use_blocks)
  % ignore first two blocks
  use_blocks = [stim.no_violation_blocks(3:end) stim.violation_blocks];
end

maintri = ismember(stim.blocks, use_blocks);
correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
    (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
viol = stim.is_distractor_violation | stim.is_target_violation;

% define conditions
conds = [
  (maintri & correct & ~viol & stim.is_old)'
  (maintri & correct & ~viol & ~stim.is_old)'
  (maintri & correct & stim.is_target_violation)'
  (maintri & correct & stim.is_distractor_violation)'
];
conds = conds(:,trial_ids);

vars = [];
vars.conds = conds;
vars.condlabels = {'old', 'new', 'tarviol', 'disviol'};
vars.condvar = zeros(size(conds,1),1);
vars.allcondvar = {};
for k = 1:size(conds, 1)
  vars.allcondvar{k} = rawvar(conds(k,:));
  vars.condvar(k) = mean(rawvar(conds(k,:)));
end

% also compute mean rawvar per old display
stim_inds = get_old_display_inds(stim);
vars.var_display_old = zeros(stim.num_repeat_displays, 1);
for k = 1:stim.num_repeat_displays
  inds = maintri & correct & ~viol & stim_inds==k;
  inds = inds(trial_ids);
  vars.var_display_old(k) = mean(rawvar(inds));
end

% define conditions for timecourse over experiment
timeconds = [
  (correct & ~viol & stim.is_old)'
  (correct & ~viol & ~stim.is_old)'
];
timeconds = timeconds(:,trial_ids);

blk = stim.blocks(trial_ids);
nblock = 22;

vars.timeconds = timeconds;
vars.timecondvar = zeros(size(timeconds,1), nblock);
vars.timecondtri = {};
for k = 1:size(timeconds, 1)
  for l = 1:nblock
    blkinds = ismember(blk, l+combine_blocks);
    vars.timecondtri{k,l} = rawvar(timeconds(k,:)' & blkinds);
    vars.timecondvar(k,l) = mean(vars.timecondtri{k,l});
  end
end

end
