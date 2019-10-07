function tex = MakeStimTextures(ptb)
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

% we're making the textures using an all-white square and storing the shape
% in the alpha channel, which frees us from having to worry about
% background colour

target_img = zeros(128,128,2,'uint8');
target_img(:,:,1) = 255;
target_img(1:32,:,2) = 255;
target_img(:,48:79,2) = 255;
tex.target = Screen('MakeTexture', ptb.win, target_img);

distractor_img = zeros(128,128,2,'uint8');
distractor_img(:,:,1) = 255;
distractor_img(:,1:32,2) = 255;
distractor_img(96:128,:,2) = 255;
tex.distractor = Screen('MakeTexture', ptb.win, distractor_img);

end