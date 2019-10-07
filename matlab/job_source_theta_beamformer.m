function job_source_theta_beamformer(subj_id, data)
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

% single-trial time-resolved power in 1-7 Hz band
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'fourier';
cfg.taper = 'dpss';
cfg.foi = 4;
cfg.toi = -0.5:0.05:1;
cfg.t_ftimwin = 0.5;
cfg.tapsmofrq = 3;
freq = ft_freqanalysis(cfg, data);

trialinds = freq.trialinfo(:,2);

% load pre-computed leadfield
load(fullfile(subjects(subj_id).dir, 'geom-leadfield-mni-8mm-megchans.mat'),...
  'headmodel', 'leadfield');

% source analysis to compute DICS spatial filters (this uses the
% cross-spectral density averaged across time)
cfg = [];
cfg.method = 'dics';
cfg.grid = leadfield;
cfg.headmodel = headmodel;
cfg.keeptrials = 'yes';
cfg.dics.lambda = '10%';
cfg.dics.projectnoise = 'no';
cfg.dics.keepfilter = 'yes';
cfg.dics.fixedori = 'yes';
cfg.dics.realfilter = 'yes';
source = ft_sourceanalysis(cfg, freq);

% apply the filters to the single-trial Fourier spectra and compute
% time-resolved power
source_pow = compute_single_trial_power(source, freq);
source_pow.dimord = 'pos_rpt_time';

[stim,~,responses] = load_behav(subj_id);

% regress out linear trend from power data
cfg = [];
cfg.confound = [(1:920)' mod(1:920, 80)' stim.blocks];
cfg.confound = cfg.confound(trialinds,:);
source_pow = ft_regressconfound(cfg, source_pow);

% baseline-correct individual trials
% use z-score across entire epoch as 'baseline'
% see Grandchamp & Delorme (2011) Front Psychol for why this is optimal
mu = mean(source_pow.pow, 3);
sd = std(source_pow.pow, [], 3);
source_pow.pow = (source_pow.pow - mu) ./ sd;

% get trial indices for behaviour
use_blocks = 2:22;
maintri = ismember(stim.blocks, use_blocks);
correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
    (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
viol = stim.is_distractor_violation | stim.is_target_violation;

% define conditions
conds = [
  (maintri & correct & ~viol & stim.is_old)'
  (maintri & correct & ~viol & ~stim.is_old)'
];
condlabels = {'old', 'new'};

% conds is defined for the full experiment, limit to only those trials
% present in the meg data
conds = conds(:,trialinds);

sources = {};
for k = 1:size(conds,1)
  % compute condition-wise average in time window of interest
  cfg = [];
  cfg.trials = conds(k,:);
  cfg.avgoverrpt = 'yes';
  cfg.latency = [0 0.5];
  cfg.avgovertime = 'yes';

  sources{k} = ft_selectdata(cfg, source_pow);
  sources{k} = rmfield(sources{k}, 'cfg');
end

% save in temporary file first and then rename to make sure the master job
% is not trying to load data from an incomplete file
tmpfile = [tempname(subjects(subj_id).dir) '.mat'];
save(tmpfile, 'sources', 'conds', 'condlabels');
movefile(tmpfile, fullfile(subjects(subj_id).dir, [mfilename() '.mat']));

end
