function job_source_theta_rois(subj_id, data)
% This script does something very similar to job_source_theta_beamformer,
% except it (1) limits analysis to only four points of interest, and (2)
% retains the trial dimension, to allow subsequent analyses to relate
% trial-wise source-level power to other task variables.

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

load(fullfile(subjects(subj_id).dir, 'geom-leadfield-mni-8mm-megchans.mat'),...
  'headmodel', 'leadfield');

% index of the region of interest (relative to 8mm grid)
% for old vs new 0-0.5s, 1-7Hz power:
% 4216 is peak in right hippocampal cluster
% 8849 is peak in left frontal superior cluster
% 7856 is peak in (small) right frontal mid cluster
% 7285 is peak in (small) left precentral cluster

roi = [4216; 8849; 7865; 7285];
leadfield.pos = leadfield.pos(roi,:);
leadfield.leadfield = leadfield.leadfield(roi);
leadfield.inside = true(numel(roi),1);

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

% compute single-trial power estimates
source_pow = compute_single_trial_power(source, freq);

% regress out confounds from power data
[stim,~,responses] = load_behav(subj_id);
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

cfg = [];
cfg.latency = [0 0.5];
cfg.avgovertime = 'yes';
source_pow = ft_selectdata(cfg, source_pow);

source_pow.trialinfo = freq.trialinfo;

% save in temporary file first and then rename to make sure the master job
% is not trying to load data from an incomplete file
tmpfile = [tempname(subjects(subj_id).dir) '.mat'];
save(tmpfile, 'source_pow');
movefile(tmpfile, fullfile(subjects(subj_id).dir, [mfilename() '.mat']));

end