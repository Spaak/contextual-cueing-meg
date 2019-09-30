function data = load_clean_data(subj_id)

[subjects,all_ids,rootdir] = datainfo();

tstart = tic();

% load initial-cleaned data
load(fullfile(subjects(subj_id).dir, 'preproc-data-artreject-400hz.mat'), 'data');

% load ica decomposition weights and bad components
load(fullfile(subjects(subj_id).dir, 'preproc-ica-weights.mat'), 'unmixing', 'topolabel');
load(fullfile(subjects(subj_id).dir, 'preproc-ica-badcomps.mat'), 'badcomps');

% apply ica demixing
cfg = [];
cfg.demean = 'no';
cfg.method = 'predefined unmixing matrix';
cfg.unmixing = unmixing;
cfg.topolabel = topolabel;
data = ft_componentanalysis(cfg, data);

% reject bad components
cfg = [];
cfg.demean = 'no';
cfg.component = badcomps;
data = ft_rejectcomponent(cfg, data);

fprintf('Loading and cleaning data took %.1f seconds.\n', toc(tstart));

end