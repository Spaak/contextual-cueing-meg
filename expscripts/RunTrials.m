function RunTrials(stim, ptb, tex, btsi, filename)
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

% record start times, responses, and reaction times
start_times = nan(stim.num_tri_total, 1);
responses = nan(stim.num_tri_total, 1);
rts = nan(stim.num_tri_total, 1);

for k = 1:stim.num_tri_total
    block_ind_true = floor((k-1) / stim.num_tri_per_block) + 1;
    block_ind_subj = floor((k-1) / (stim.num_tri_per_block*2)) + 1;
    newsubjblock = mod(k-1, (stim.num_tri_per_block*2)) == 0;
    
    if newsubjblock
        % alert experimenter
        sound(stim.beep);
    end
    
    if newsubjblock && block_ind_true == stim.recognition_blocks(1)
        stim = PresentRecognitionInstructions(stim, ptb, btsi);
    elseif newsubjblock
        if k == 1
            txt = '';
        else
            txt = 'Block finished! Feel free to take a short break if you like. ';
        end

        txt = [txt 'Next up is block ' num2str(block_ind_subj) ' of ' num2str(floor(stim.num_blocks/2)) '. When you''re ready, press a button to continue.'];
        PresentTextAndWait(ptb, btsi, txt);
    end
    
    [start_times(k), responses(k), rts(k)] = RunSingleTrial(...
        stim, ptb, tex, btsi, k, ismember(block_ind_true, stim.recognition_blocks));
    
    % save results every trial
    timestamp = clock();
    save(filename, 'stim', 'start_times', 'responses', 'rts', 'timestamp');
end

end