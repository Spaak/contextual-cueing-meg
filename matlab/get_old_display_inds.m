function [disp_inds] = get_old_display_inds(stim)

% This function takes the coordinates of the stimuli and, for each Old or
% violation trial, determines the index of that trial into the set of 20
% repeated displays. This allows aggregation of performance across
% repetitions of those 20 displays.

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