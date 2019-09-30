function job_sensor_evoked_tfr(subj_id, data)

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
cfg.demean = 'yes';
cfg.baselinewindow = [-0.5 0];
data = ft_preprocessing(cfg, data);

cfg = [];
cfg.neighbours = neighbours;
cfg.planarmethod = 'sincos';
data = ft_megplanar(cfg, data);

% get trial indices for behaviour
[stim,~,responses] = load_behav(subj_id);
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
trialinds = data.trialinfo(:,2);
conds = conds(:,trialinds);

% equalize trial counts for planar ERF
balanced_conds = {};
[balanced_conds{1},balanced_conds{2}] = equalize_counts(find(conds(1,:)), find(conds(2,:)));

freqs = {};
for k = 1:size(conds,1)
  cfg = [];
  cfg.trials = balanced_conds{k};
  tl = ft_timelockanalysis(cfg, data);
  
  cfg = [];
  cfg.pad = 3;
  cfg.method = 'mtmconvol';
  cfg.toi = -0.5:0.05:1;
  cfg.taper = 'hanning';
  cfg.foi = 1:30;
  cfg.t_ftimwin = ones(size(cfg.foi)) * 0.5;

  freqs{k} = ft_freqanalysis(cfg, tl);
  freqs{k} = ft_combineplanar([], freqs{k});
  freqs{k} = rmfield(freqs{k}, 'cfg');
end

% save in temporary file first and then rename to make sure the master job
% is not trying to load data from an incomplete file
tmpfile = [tempname(subjects(subj_id).dir) '.mat'];
save(tmpfile, 'freqs', 'conds', 'condlabels', 'balanced_conds');
movefile(tmpfile, fullfile(subjects(subj_id).dir, [mfilename() '.mat']));

end

