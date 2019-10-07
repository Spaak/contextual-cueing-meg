function DrawFeedback(stim, ptb, tex, trial_id, resp)
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

if resp == stim.RESP_RIGHT
    if stim.rotation(trial_id,1) == 90
        % right button, correct response
        color_center = [0 255 0];
    else
        % right button, incorrect response (so left was correct)
        color_center = [255 0 0];
    end
elseif resp == stim.RESP_LEFT
    if stim.rotation(trial_id,1) == -90
        % left button, correct response
        color_center = [0 255 0];
    else
        % left button, incorrect response (so right was correct)
        color_center = [255 0 0];
    end
elseif resp == 0
    % timeout
    color_center = [255 0 0];
end

DrawFixationDot(ptb, 0, color_center);

end