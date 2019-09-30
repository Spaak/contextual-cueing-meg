function run_preproc_ica(subj_id)

subjects = datainfo();

fprintf('*** SUBJECT %02d : ica ***\n', subj_id);

% load data
load(fullfile(subjects(subj_id).dir, 'preproc-data-artreject-400hz.mat'),...
  'data');

cfg = [];
cfg.method = 'runica';
cfg.demean = 'no';
cfg.channel = {'MEG'}; % only do ICA on MEG channels, not the refchans

comp = ft_componentanalysis(cfg, data);

unmixing = comp.unmixing;
topolabel = comp.topolabel;

save(fullfile(subjects(subj_id).dir, 'preproc-ica-weights.mat'),...
  'unmixing', 'topolabel');

end