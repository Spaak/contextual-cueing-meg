function ptb = InitPsychtoolbox(is_live)
% InitPsychtoolbox performs some basic setup calls for PsychToolbox, as
% well gets the indices of the screen's white colour, screen dimensions,
% etc.
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

% initialize a structure in which to store useful information
ptb = [];

ptb.is_live = is_live;

% skip the ptb synchronization tests when not running actual experiment
if ~is_live
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% some default setup
AssertOpenGL();

% ensure consistent mapping of keyboard buttons to character labels
KbName('UnifyKeyNames');

% get available screens and draw onto the one with highest ID (usually an
% extra screen on which Matlab is not running)
screens = Screen('Screens');

if is_live
    ptb.screen_id = max(screens);
else
    ptb.screen_id = 1;
end

% get pointer to window on which to draw
[ptb.win, ptb.win_rect] = Screen('OpenWindow', ptb.screen_id,...
    128, [], [], [], [], 4); % gray background, 4x multisample anti-aliasing

% clear the screen
Screen('Flip', ptb.win);

% query the frame duration
ptb.ifi = Screen('GetFlipInterval', ptb.win);

% set the text font and size
Screen('TextFont', ptb.win, 'Calibri');
Screen('TextSize', ptb.win, 18);
Screen('TextStyle', ptb.win, 0);

% get the size of the on screen window
[ptb.win_w, ptb.win_h] = Screen('WindowSize', ptb.win);

% set the blend funciton for the screen
Screen('BlendFunction', ptb.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% initialize GetSecs and WaitSecs (to ensure the mexfiles are loaded)
GetSecs();
WaitSecs(0);

end