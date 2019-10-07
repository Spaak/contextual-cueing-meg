function PauseScreen(ptb)
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

while true
    [keydown, ~, keycode] = KbCheck();
    if keydown && keycode(82) % button r - resume
        return;
    elseif keydown && keycode(27) % button ESC - escape, quit experiment
        Screen('CloseAll');
        error('experiment aborted by pressing ESC key');
    elseif keydown && keycode(69) % button e - eyelink
        EyelinkDoTrackerSetup(ptb.eye);
    
        WaitSecs(0.1);
        Eyelink('StartRecording');
    end
    DrawFormattedText(ptb.win, 'One moment please...', ptb.win_w/2-250,...
        ptb.win_h/2-250, 255);
    DrawFixationDot(ptb, 1);
    WaitSecs(0.01);
end

end