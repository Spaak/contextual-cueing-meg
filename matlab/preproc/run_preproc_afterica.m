%% NOTE: this is supposed to be run as a script, not a function

subjects = datainfo();

subj_id = 38;

fprintf('*** SUBJECT %02d : loading data... ***\n', subj_id);

load(fullfile(subjects(subj_id).dir, 'preproc-data-artreject-400hz.mat'),...
  'data');
load(fullfile(subjects(subj_id).dir, 'preproc-ica-weights.mat'),...
  'unmixing', 'topolabel');

cfg = [];
cfg.method = 'predefined mixing matrix';
cfg.demean = 'no';
cfg.channel = {'MEG'};
cfg.topolabel = topolabel;
cfg.unmixing = unmixing;
comp = ft_componentanalysis(cfg, data);

cfg = [];
cfg.viewmode = 'component';
cfg.layout = 'CTF275_helmet.mat';
ft_databrowser(cfg, comp);

fprintf('*** SUBJECT %02d : save the identified components!!! ***\n', subj_id);

%% write down and save

badcomps = [];
badcomps_reasons = {};

assert(numel(badcomps) == numel(badcomps_reasons));

save(fullfile(subjects(subj_id).dir, 'preproc-ica-badcomps.mat'),...
  'badcomps', 'badcomps_reasons');

fprintf('saved.\n');