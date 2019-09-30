%% load and identify fiducials

% designed as a script to be run in several steps
% this allows checking of e.g. the ICP algorithm results

subj_id = 38;

subjects = datainfo();

fprintf('*** SUBJECT %02d : loading raw mri... ***\n', subj_id);
rawmri = ft_read_mri(subjects(subj_id).rawmri);

fprintf('*** SUBJECT %02d : identify fiducials ***\n', subj_id);
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
mri1 = ft_volumerealign(cfg, rawmri);

%% realign second pass: use headshape

fprintf('*** SUBJECT %02d : automatic realignment to headshape ***\n', subj_id);

headshape = ft_read_headshape(subjects(subj_id).polhemus);

cfg = [];
cfg.method = 'headshape';
cfg.coordsys = 'ctf';
cfg.headshape.headshape = headshape;

% first iterative closed point (automatic)
cfg.headshape.interactive = 'no';
cfg.headshape.icp = 'yes';
mri2 = ft_volumerealign(cfg, mri1);

fprintf('RMS error before icp: %.3f\n', sqrt(mean(mri2.cfg.icpinfo.distancein.^2)));
fprintf('RMS error after icp:  %.3f\n', sqrt(mean(mri2.cfg.icpinfo.distanceout.^2)));

%% realign third pass: interactive with headshape

fprintf('*** SUBJECT %02d : interactive realignment to headshape ***\n', subj_id);

% then interactive (also to visually check icp solution)
cfg.headshape.interactive = 'yes';
cfg.headshape.icp = 'no';
mri = ft_volumerealign(cfg, mri2);

%% save realigned mri

save(fullfile(subjects(subj_id).dir, 'geom-mri-realigned.mat'), 'mri');