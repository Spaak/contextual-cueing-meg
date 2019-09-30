function [start_time, resp, rt] = RunSingleTrial(stim, ptb, tex, btsi, trial_id, is_recog)

if nargin < 6
    is_recog = false;
end

start_time = GetSecs();

% present fixation dot only and wait
DrawFixationDot(ptb, 1);
btsi.sendTrigger(2^7);
PausableWait(ptb, stim.tim_iti - ptb.ifi);

% clear responses potentially in Bitsi box buffer
btsi.clearResponses();

DrawFixationDot(ptb, 0);

% present search array
DrawSearchArray(stim, ptb, tex, trial_id);
Screen('Flip', ptb.win);

btsi.sendTrigger(MakeOnsetTrig(stim, trial_id));

if is_recog
    % wait for self-timed response
    [resp, rt] = btsi.getResponse(inf, 1);
else
    % wait for response with timeout and present feedback
    [resp, rt] = btsi.getResponse(stim.tim_respwindow, 1);
    DrawFeedback(stim, ptb, tex, trial_id, resp);
    Screen('Flip', ptb.win);
    WaitSecs(stim.tim_feedback);
end

end