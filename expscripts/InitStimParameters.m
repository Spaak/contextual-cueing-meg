function stim = InitStimParameters(ptb)
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

stim = [];

stim.exp_start_time = clock();

% parameters for converting back and forth between pixels and degrees of
% visual angle
stim.screen_w = 48;%53;%38;     % cm (38 2nd screen at desk; 53 in cubicle; 48 in meg)
stim.view_dist = 85;%61;%70;    % cm (70 2nd screen at desk; 61 in cubicle; 85 in meg)
stim.pixel_size = stim.screen_w / ptb.win_w;
stim.pix2deg = @(px) (360./pi .* atan(px.*stim.pixel_size./(2.*stim.view_dist)));
stim.deg2pix = @(deg) (2.*stim.view_dist.*tan(pi./360.*deg)./stim.pixel_size);

% one block in the code is one repetition of all old displays + equal amount of
% new displays. the first eight blocks there are
% no violations, blocks 9-22 will each contain two target violation old displays
% and two distractor violation old displays.
stim.num_blocks = 23;
stim.no_violation_blocks = 1:8;
stim.violation_blocks = 9:22;
stim.recognition_blocks = 23;
stim.num_violation_per_block = 5;
stim.num_tri_per_block = 40;
stim.num_repeat_displays = 20;
stim.num_tri_total = stim.num_blocks * stim.num_tri_per_block;

% present 10 stimuli in 8x6 grid (see Chun & Jiang (1998) p. 35)
% with some jitter
stim.grid_x = linspace(-9, 9, 8);     % deg
stim.grid_y = linspace(-6, 6, 6);     % deg
stim.grid = fliplr(allcomb(stim.grid_y, stim.grid_x)); % all combinations of x/y to create grid
% note the fliplr is there to preserve compatibility with calls to
% combvec() which are now removed due to licensing
stim.max_jitter = 0.4; % deg
stim.num_stimuli = 10;

% size of stimuli on screen
stim.stim_w = 1.5; % deg
stim.stim_h = 1.5; % deg

% duration of stimuli etc (s)
stim.tim_iti = 1;
stim.tim_respwindow = 1.5; % on recog blocks will always be inf
stim.tim_feedback = 0.5;

end