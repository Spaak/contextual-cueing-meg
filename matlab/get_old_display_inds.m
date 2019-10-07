function [disp_inds] = get_old_display_inds(stim)
% This function takes the coordinates of the stimuli and, for each Old or
% violation trial, determines the index of that trial into the set of 20
% repeated displays. This allows aggregation of performance across
% repetitions of those 20 displays.
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


% this takes a few seconds per iteration, so implement a caching scheme
persistent cache;

if isempty(cache)
  cache = struct();
end

hashkey = ['s' CalcMD5(mxSerialize(stim))];
if isfield(cache, hashkey)
  disp_inds = cache.(hashkey);
  return;
end

% old displays from block 1 (same throughout experiment, except some become
% violations later on)
olds = stim.coords(stim.is_old & stim.blocks==1,:,:);
nold = stim.num_repeat_displays;

disp_inds = nan(stim.num_tri_total, 1);
for k = 1:stim.num_tri_total
  if ~stim.is_old(k)
    continue;
  end
  % find out which old display this was
  thistri = squeeze(stim.coords(k,:,:));
  foundflag = 0;
  for olddisp = 1:nold
    oldcoords = squeeze(olds(olddisp,:,:));
    if stim.is_target_violation(k)
      % use expensive check because rows will not be in order here
      foundflag = isequal(size(intersect(thistri, squeeze(olds(olddisp,:,:)), 'rows')), [10 2]);
    else
      % use very quick check
      foundflag = isequal(thistri, oldcoords);
    end
    
    if foundflag
      disp_inds(k) = olddisp;
      break;
    end
  end
  if ~foundflag
    error('could not determine display index');
  end
end

cache.(hashkey) = disp_inds;

end