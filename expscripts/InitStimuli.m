function stim = InitStimuli(ptb, stim)
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

% determine stimuli locations for all trials
% note: target will always be the first stimulus
stim.coords = zeros(stim.num_tri_total, stim.num_stimuli, 2);
stim.rotation = zeros(stim.num_tri_total, stim.num_stimuli);

% some convenient vectors to keep track of which trial is what
stim.blocks = zeros(stim.num_tri_total, 1);
stim.is_old = false(stim.num_tri_total, 1);
stim.is_target_violation = false(stim.num_tri_total, 1);
stim.is_distractor_violation = false(stim.num_tri_total, 1);

% the periodicity for which the violations repeat
period_viol = stim.num_repeat_displays / stim.num_violation_per_block;

for k = 1:stim.num_tri_total
    block_ind = floor((k-1) / stim.num_tri_per_block) + 1;
    stim.blocks(k) = block_ind;
    tri_within_block = mod(k-1, stim.num_tri_per_block) + 1;
    
    if tri_within_block <= stim.num_repeat_displays
        stim.is_old(k) = true;
    end
    
    if block_ind > 1 && tri_within_block <= stim.num_repeat_displays
        stim.coords(k,:,:) = stim.coords(tri_within_block,:,:);
        stim.rotation(k,:) = stim.rotation(tri_within_block,:);
        
        if ismember(block_ind, stim.violation_blocks)
            viol_block_phase = mod((block_ind-numel(stim.no_violation_blocks)-1),...
                period_viol);
            
            distr_viol = viol_block_phase*stim.num_violation_per_block + (1:stim.num_violation_per_block);
            targ_viol = distr_viol + stim.num_violation_per_block;
            if any(targ_viol > stim.num_repeat_displays)
                targ_viol = 1:stim.num_violation_per_block;
            end
            if ismember(tri_within_block, targ_viol)
                % switch with random distractor
                ind = randi([2, stim.num_stimuli]);
                
                stim.coords(k,[1 ind],:) = stim.coords(k,[ind 1],:);
                stim.is_target_violation(k) = true;
            elseif ismember(tri_within_block, distr_viol)
                stim.rotation(k,2:end) = randsample(0:90:270, stim.num_stimuli-1, true);
                stim.is_distractor_violation(k) = true;
            end
        end

    else
        % either block 1 (any trial index), or later blocks second half of
        % trials
        stim.coords(k,:,:) = stim.grid(randperm(size(stim.grid, 1),...
            stim.num_stimuli),:) + (1-2*rand(stim.num_stimuli, 2))*stim.max_jitter;
        stim.rotation(k,:) = randsample(0:90:270, stim.num_stimuli, true);
        
        % make sure target excentricity is between 6 and 8 degrees
        exc = sqrt(sum(stim.coords(k,1,:).^2, 3));
        % and crowding (mean distance to all distractors) is between 9 and 11
        % degrees
        crwd = mean(sqrt(sum( (bsxfun(@minus, stim.coords(k,2:end,:), stim.coords(k,1,:))).^2, 3)), 2);
        while exc < 6 || exc > 8 || crwd < 9 || crwd > 11
            stim.coords(k,:,:) = stim.grid(randperm(size(stim.grid, 1),...
                stim.num_stimuli),:) + (1-2*rand(stim.num_stimuli, 2))*stim.max_jitter;
            exc = sqrt(sum(stim.coords(k,1,:).^2, 3));
            crwd = mean(sqrt(sum( (bsxfun(@minus, stim.coords(k,2:end,:), stim.coords(k,1,:))).^2, 3)), 2);
        end
    end
    
    % make target rotation random on each display
    stim.rotation(k,1) = randsample([-90 90], 1);
end

%
% randomize stimulus order within blocks
for k = 1:stim.num_blocks
    startind = (k-1)*stim.num_tri_per_block + 1;
    endind = k * stim.num_tri_per_block;
    realinds = startind:endind;
    shufinds = realinds(randperm(numel(realinds)));

    stim.coords(realinds,:,:) = stim.coords(shufinds,:,:);
    stim.rotation(realinds,:) = stim.rotation(shufinds,:);
    stim.blocks(realinds) = stim.blocks(shufinds);
    stim.is_old(realinds) = stim.is_old(shufinds);
    stim.is_target_violation(realinds) = stim.is_target_violation(shufinds);
    stim.is_distractor_violation(realinds) = stim.is_distractor_violation(shufinds);
end
%}

% sound to play to experimenter when block ends
t = 1/8192:1/8192:0.2;
stim.beep = sin(440*2*pi*t);
stim.beep(1:50) = linspace(0,1,50) .* stim.beep(1:50);
stim.beep(end-49:end) = linspace(1,0,50) .* stim.beep(end-49:end);

end