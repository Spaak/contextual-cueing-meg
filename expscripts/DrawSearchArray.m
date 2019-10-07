function DrawSearchArray(stim, ptb, tex, trial_id)
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

centerx = stim.pix2deg(ptb.win_w/2);
centery = stim.pix2deg(ptb.win_h/2);

for k = 1:stim.num_stimuli
    if k == 1
        drawtex = tex.target;
    else
        drawtex = tex.distractor;
    end
    
    dest_rect = stim.deg2pix([
            centerx + stim.coords(trial_id,k,1) - stim.stim_w/2;
            centery + stim.coords(trial_id,k,2) - stim.stim_h/2;
            centerx + stim.coords(trial_id,k,1) + stim.stim_w/2;
            centery + stim.coords(trial_id,k,2) + stim.stim_h/2]);
    
    Screen('DrawTexture', ptb.win, drawtex, [], dest_rect,...
        stim.rotation(trial_id, k));

end

end