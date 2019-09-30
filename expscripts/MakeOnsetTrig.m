function trig = MakeOnsetTrig(stim, trial_id)

% NOTE: for pilot333 (first MEG pilot) the trigger values were incorrect;
% the first term 2^0 was omitted then (so rotation was encoded as 2^0,
% etc.)

trig = 2^0 + (stim.rotation(trial_id,1)==90)*2^1 + stim.is_old(trial_id)*2^2 + ...
    stim.is_target_violation(trial_id)*2^3 + ...
    stim.is_distractor_violation(trial_id)*2^4 + ...
    ismember(stim.blocks(trial_id), stim.recognition_blocks)*2^5;

end