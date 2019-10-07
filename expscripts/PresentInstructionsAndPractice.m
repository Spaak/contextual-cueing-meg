function PresentInstructionsAndPractice(stim_practice, ptb, tex, btsi)
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

btsi.clearResponses();

txt = 'Thank you for participating in this experiment! Your will see displays consisting of several L-shaped stimuli and one T-shaped target. Your task is to indicate whether the T is rotated to the left or right. Press a button to see an example of a search display as you will see during the experiment, and press a button again to continue.';
PresentTextAndWait(ptb, btsi, txt);

DrawSearchArray(stim_practice, ptb, tex, 1);
DrawFixationDot(ptb, 1);
WaitSecs(0.5);
btsi.getResponse(inf, true);

txt = 'You will now perform a short practice block. Press the LEFT button to indicate a LEFTWARD ROTATED T, and the RIGHT button to indicate a RIGHTWARD ROTATED T. Feel free to ask any questions if you have them! Press a button to continue.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Throughout the experiment, please keep looking at the little dot in the center of the screen (so don''t move your eyes), and try to blink as little as possible. When you''re ready, press a button to start the practice block.';
PresentTextAndWait(ptb, btsi, txt);

stim_practice.resp_upright_right(:) = 0;

for k = 1:30
    RunSingleTrial(stim_practice, ptb, tex, btsi, k);
end

txt = 'Very good! Please contact the experimenter.';
PresentTextAndWait(ptb, btsi, txt);

end