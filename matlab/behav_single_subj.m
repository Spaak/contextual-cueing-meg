function [behav,correct,viol] = behav_single_subj(subj_id, ...
  combine_blocks, use_blocks, do_detrend_and_log)

[stim,rts,responses] = load_behav(subj_id);

if nargin < 2 || isempty(combine_blocks)
  combine_blocks = 0;
end

if nargin < 3 || isempty(use_blocks)
  % ignore first two blocks
  use_blocks = [stim.no_violation_blocks(3:end) stim.violation_blocks];
end

if nargin < 4 || isempty(do_detrend_and_log)
  do_detrend_and_log = 0;
end

maintri = ismember(stim.blocks, use_blocks);

if do_detrend_and_log
  rts(maintri) = log10(rts(maintri));
  xvals = (1:numel(rts(maintri)))';
  p = polyfit(xvals, rts(maintri), 1);
  rts(maintri) = rts(maintri) - p(2) - p(1).*xvals;
end

correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
    (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
viol = stim.is_distractor_violation | stim.is_target_violation;

behav = [];

% condition-wise RTs
behav.allrt_old = rts(maintri & correct & ~viol & stim.is_old);
behav.allrt_new = rts(maintri & correct & ~viol & ~stim.is_old);
behav.allrt_disviol = rts(maintri & correct & stim.is_distractor_violation);
behav.allrt_tarviol = rts(maintri & correct & stim.is_target_violation);

% also store the condition masks
behav.conds_old = maintri & correct & ~viol & stim.is_old;
behav.conds_new = maintri & correct & ~viol & ~stim.is_old;
behav.conds_disviol = maintri & correct & stim.is_distractor_violation;
behav.conds_tarviol = maintri & correct & stim.is_target_violation;

% condition median RTs
behav.medrt_old = median(behav.allrt_old);
behav.medrt_new = median(behav.allrt_new);
behav.medrt_disviol = median(behav.allrt_disviol);
behav.medrt_tarviol = median(behav.allrt_tarviol);

% RT and search task accuracy across all conditions
behav.medrt = median(rts(maintri & correct));
behav.acc = sum(maintri & correct) / sum(maintri);

% also compute median RT per old display (item-wise analysis)
behav.old_display_inds = get_old_display_inds(stim);
behav.medrt_display_old = zeros(stim.num_repeat_displays, 1);
for k = 1:stim.num_repeat_displays
  inds = maintri & stim.is_old & ~viol & behav.old_display_inds==k;
  behav.medrt_display_old(k) = median(rts(inds & correct));
end

% search task accuracy per condition
tri = maintri & ~viol & stim.is_old;
behav.acc_old = sum(tri & correct) / sum(tri);
tri = maintri & ~viol & ~stim.is_old;
behav.acc_new = sum(tri & correct) / sum(tri);
tri = maintri & stim.is_distractor_violation;
behav.acc_disviol = sum(tri & correct) / sum(tri);
tri = maintri & stim.is_target_violation;
behav.acc_tarviol = sum(tri & correct) / sum(tri);

% RT and accuracy for Old and New, across experiment blocks
useblocks = [stim.no_violation_blocks stim.violation_blocks];
for block = useblocks
  blk = ismember(stim.blocks, block+combine_blocks) & ...
    ismember(stim.blocks, useblocks);

  behav.medblockrt_old(block) = median(rts(blk & correct & ~viol & stim.is_old));
  behav.medblockrt_new(block) = median(rts(blk & correct & ~viol & ~stim.is_old));
  
  behav.accblock_old(block) = sum(blk & correct & ~viol & stim.is_old) / sum(blk & ~viol & stim.is_old);
  behav.accblock_new(block) = sum(blk & correct & ~viol & ~stim.is_old) / sum(blk & ~viol & ~stim.is_old);
end

% subjective recognition awareness (yes = left)
behav.recogyesno = stim.resp_recogyesno==stim.RESP_LEFT;
behav.recogconf = stim.resp_recogconfidence==stim.RESP_LEFT;

% objective recognition accuracy (yes = old)
blk = stim.blocks==stim.recognition_blocks;
behav.recogacc = mean((stim.is_old(blk) & responses(blk)==stim.RESP_LEFT) | ...
  (~stim.is_old(blk) & responses(blk)==stim.RESP_RIGHT));

% recognition accuracy across items
behav.recogacc_display_old = zeros(stim.num_repeat_displays, 1);
for k = 1:stim.num_repeat_displays
  ind = blk & behav.old_display_inds==k;
  assert(sum(ind) == 1); % each display should occur exactly once in the recognition task
  behav.recogacc_display_old(k) = responses(ind)==stim.RESP_LEFT;
end

end