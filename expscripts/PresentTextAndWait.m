function [resp, rt] = PresentTextAndWait(ptb, btsi, txt)
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

DrawFormattedText(ptb.win, WrapString(txt, 50), ptb.win_w/2-250, 'center',...
    255, [], [], [], 1.5);
Screen('Flip', ptb.win);
WaitSecs(0.5);
[resp, rt] = btsi.getResponse(inf, true);

end