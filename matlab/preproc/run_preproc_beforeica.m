function run_preproc_beforeica(subj_id)

subjects = datainfo();

fprintf('*** SUBJECT %02d : epoching ***\n', subj_id);

cfg = [];
cfg.dataset = subjects(subj_id).rawmeg;
cfg.trl = make_trl(subj_id);
cfg.channel = {'MEG', 'MEGREF'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

%% 1: 3rd order gradient correction

fprintf('*** SUBJECT %02d : G3BR correction ***\n', subj_id);

cfg = [];
cfg.gradient = 'G3BR';
data = ft_denoise_synthetic(cfg, data);

%% 2: demean

fprintf('*** SUBJECT %02d : demean ***\n', subj_id);

cfg = [];
cfg.demean = 'yes';
data = ft_preprocessing(cfg, data);

%% 3: ft_rejectvisual summary with MEG variance

fprintf('*** SUBJECT %02d : ft_rejectvisual, summary, variance ***\n', subj_id);

cfg = [];
cfg.channel = {'MEG'};
cfg.method = 'summary';
cfg.layout = 'CTF275.lay';
data_clean = ft_rejectvisual(cfg, data);

% store which trials and channels to keep
tri_keep = data_clean.trialinfo(:, 2);
megchan_keep = data_clean.label;
save(fullfile(subjects(subj_id).dir, 'preproc-artifacts-rejectvisual-variance.mat'),...
  'tri_keep', 'megchan_keep');

%% 4: filter for muscle activity and ft_rejecvisual summary again

fprintf('*** SUBJECT %02d : ft_rejectvisual, summary, muscle ***\n', subj_id);

cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [110 140];
cfg.bpfilttype = 'but';
cfg.bpfiltord = 4;
cfg.hilbert = 'yes';
data_muscle = ft_preprocessing(cfg, data_clean);

cfg = [];
cfg.channel = {'MEG'};
cfg.method = 'summary';
cfg.layout = 'CTF275.lay';
data_clean = ft_rejectvisual(cfg, data_muscle);

% store which trials to keep (no channel rejected here)
tri_keep = data_clean.trialinfo(:, 2);
save(fullfile(subjects(subj_id).dir, 'preproc-artifacts-rejectvisual-muscle.mat'),...
  'tri_keep');

%% 5: now apply the selection of trials/channels

% We could have used cfg.keepchan in the calls to ft_rejectvisual instead
% of now selecting again on the G3BR-demean data, should result in the
% same. This is nice and explicit though.

fprintf('*** SUBJECT %02d : removing bad channels/trials ***\n', subj_id);

cfg = [];
cfg.channel = {'MEGREF', megchan_keep{:}};
cfg.trials = tri_keep;
data = ft_selectdata(cfg, data);

%% 6: resample the data and save

fprintf('*** SUBJECT %02d : ft_resampledata ***\n', subj_id);

cfg = [];
cfg.resamplefs = 400;
cfg.demean = 'no';
cfg.detrend = 'no';
data = ft_resampledata(cfg, data);

fprintf('*** SUBJECT %02d : saving data... ***\n', subj_id);

save(fullfile(subjects(subj_id).dir, 'preproc-data-artreject-400hz.mat'),...
  'data', '-v7.3');

end