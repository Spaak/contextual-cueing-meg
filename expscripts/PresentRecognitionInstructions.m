function stim = PresentRecognitionInstructions(stim, ptb, btsi)
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

txt = 'Done with the main task! Take a short break if you want, then press a button to continue to answering a few questions.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Did you have the feeling that some of the search displays occurred multiple times over the course of the experiment? Press the LEFT BUTTON for YES and the RIGHT BUTTON for NO.';
[stim.resp_recogyesno, ~] = PresentTextAndWait(ptb, btsi, txt);

txt = 'How sure are you about your answer to the previous question? Press the LEFT BUTTON for VERY SURE and the RIGHT BUTTON for NOT VERY SURE.';
[stim.resp_recogconfidence, ~] = PresentTextAndWait(ptb, btsi, txt);

txt = 'Now please perform one final (extra short) block, but the task is now different! Some of the search displays occurred multiple times in the experiment. We now want to test your memory for these. Press a button to continue and read the new instructions carefully.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Instead of searching for a T, please indicate whether you think you saw the search display during the main task. Press the LEFT BUTTON for YES and the RIGHT BOTTON for NO. You can take your time with each display, there is no timeout anymore. Feel free to ask questions now if you have them. Press a button to start the final block.';
PresentTextAndWait(ptb, btsi, txt);

end