function job_sensor_tfr(subj_id, data)
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

[subjects, all_ids, rootdir] = datainfo();

if nargin < 2 || isempty(data)
  data = load_clean_data(subj_id);
end

cfg = [];
cfg.method = 'template';
cfg.template = 'ctf275_neighb.mat';
neighbours = ft_prepare_neighbours(cfg);

% channel repair if needed
load(fullfile(rootdir, 'processed', 'combined', 'allchans.mat'), 'chanunion');
if numel(data.label) < numel(chanunion)
  cfg = [];
  cfg.method = 'average';
  cfg.missingchannel = setdiff(chanunion, data.label);
  cfg.neighbours = neighbours;
  data = ft_channelrepair(cfg, data);
end

cfg = [];
cfg.neighbours = neighbours;
cfg.planarmethod = 'sincos';
data = ft_megplanar(cfg, data);

cfg = [];
cfg.pad = 3;
cfg.method = 'mtmconvol';
cfg.toi = -0.5:0.05:1;
cfg.keeptrials = 'yes';
cfg.taper = 'hanning';
cfg.foi = 1:30;
cfg.t_ftimwin = ones(size(cfg.foi)) * 0.5;

freq = ft_freqanalysis(cfg, data);

trialinds = freq.trialinfo(:,2);

% get trial indices for behaviour
[stim,~,responses] = load_behav(subj_id);
use_blocks = 2:22; % first block all displays are essentially new
maintri = ismember(stim.blocks, use_blocks);
correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
    (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
viol = stim.is_distractor_violation | stim.is_target_violation;

% combine planar
freq = ft_combineplanar([], freq);

% regress out linear trend from power data
grad = freq.grad;
cfg = [];
cfg.confound = [(1:920)' mod(1:920, 80)' stim.blocks];
cfg.confound = cfg.confound(trialinds,:);
freq = ft_regressconfound(cfg, freq);
freq.grad = grad;

% baseline-correct individual trials
% use z-score across entire epoch as 'baseline'
% see Grandchamp & Delorme (2011) Front Psychol for why this is optimal
mu = mean(freq.powspctrm, 4);
sd = std(freq.powspctrm, [], 4);
freq.powspctrm = (freq.powspctrm - mu) ./ sd;

% define conditions
conds = [
  (maintri & correct & ~viol & stim.is_old)'
  (maintri & correct & ~viol & ~stim.is_old)'
];
condlabels = {'old', 'new'};

% conds is defined for the full experiment, limit to only those trials
% present in the meg data
conds = conds(:,trialinds);

freqs = {};
cfg = [];
for k = 1:size(conds,1)
  cfg.trials = conds(k,:);
  freqs{k} = ft_freqdescriptives(cfg, freq);
  freqs{k} = rmfield(freqs{k}, 'cfg');
end

% save in temporary file first and then rename to make sure the master job
% is not trying to load data from an incomplete file
tmpfile = [tempname(subjects(subj_id).dir) '.mat'];
save(tmpfile, 'freqs', 'conds', 'condlabels');
movefile(tmpfile, fullfile(subjects(subj_id).dir, [mfilename() '.mat']));

end
