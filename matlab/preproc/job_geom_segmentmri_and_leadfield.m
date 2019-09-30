function job_geom_segmentmri_and_leadfield(subj_id)

subjects = datainfo();

% load realigned mri
load(fullfile(subjects(subj_id).dir, 'geom-mri-realigned.mat'), 'mri');

fprintf('*** SUBJECT %02d : segmenting mri ***\n', subj_id);

% segment mri and store brain mask
cfg = [];
cfg.output = 'brain';
segmentedmri = ft_volumesegment(cfg, mri);

save(fullfile(subjects(subj_id).dir, 'geom-mri-segmented.mat'), 'segmentedmri');

fprintf('*** SUBJECT %02d : preparing head model ***\n', subj_id);

cfg = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, segmentedmri);

% load template grid in mni space
load(fullfile('~/repos/fieldtrip/template/sourcemodel/standard_sourcemodel3d8mm.mat'),...
  'sourcemodel');
template_grid = sourcemodel;
clear sourcemodel;

fprintf('*** SUBJECT %02d : preparing source model ***\n', subj_id);

% make subject-specific grid by warping mni grid to subject's ctf space
cfg = [];
cfg.grid.warpmni = 'yes';
cfg.grid.template = template_grid;
cfg.grid.nonlinear = 'yes';
cfg.grid.unit ='mm';
cfg.mri = mri;
grid = ft_prepare_sourcemodel(cfg);

fprintf('*** SUBJECT %02d : loading meg data ***\n', subj_id);

% load cleaned meg data
data = load_clean_data(subj_id);

fprintf('*** SUBJECT %02d : preparing lead field ***\n', subj_id);

cfg = [];
cfg.headmodel = headmodel;
cfg.grid = grid;
cfg.channel = {'MEG'};
cfg.reducerank = 2;
leadfield = ft_prepare_leadfield(cfg, data);

fprintf('*** SUBJECT %02d : saving head model and lead field... ***\n', subj_id);

% save
save(fullfile(subjects(subj_id).dir, 'geom-leadfield-mni-8mm-megchans.mat'),...
  'headmodel', 'leadfield', '-v7.3');

end