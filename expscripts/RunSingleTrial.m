function [start_time, resp, rt] = RunSingleTrial(stim, ptb, tex, btsi, trial_id, is_recog)
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