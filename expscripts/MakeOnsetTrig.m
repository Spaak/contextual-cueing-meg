function trig = MakeOnsetTrig(stim, trial_id)
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

% NOTE: for pilot333 (first MEG pilot) the trigger values were incorrect;
% the first term 2^0 was omitted then (so rotation was encoded as 2^0,
% etc.)

trig = 2^0 + (stim.rotation(trial_id,1)==90)*2^1 + stim.is_old(trial_id)*2^2 + ...
    stim.is_target_violation(trial_id)*2^3 + ...
    stim.is_distractor_violation(trial_id)*2^4 + ...
    ismember(stim.blocks(trial_id), stim.recognition_blocks)*2^5;

end