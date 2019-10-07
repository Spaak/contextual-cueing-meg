function PausableWait(ptb, secs)
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

untiltime = GetSecs() + secs;

while GetSecs() < untiltime
    [keydown, ~, keycode] = KbCheck();
    if keydown && keycode(80) % button p - pause
        PauseScreen(ptb);
        
        % re-start the waiting time if we've paused
        untiltime = GetSecs() + secs;
        Screen('Flip', ptb.win); % one blank frame to prompt the subject
        DrawFixationDot(ptb, 1);
    end
    WaitSecs(0.01);
end
    
end