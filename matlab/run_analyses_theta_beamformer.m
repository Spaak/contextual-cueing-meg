function run_analyses_theta_beamformer(run_mode, results_dir, subjects, all_ids, rootdir)

%% beamformer in post-stimulus theta window for each individual participant

allsources = run_individual_jobs('job_source_theta_beamformer', 'sources', subjects, all_ids, run_mode);

% make it subject X condition (old/new)
allsources = cat(1, allsources{:});


%% replace individual-participant coordinates with the corresponding ones in MNI space

[~,ftpath] = ft_version();
load(fullfile(ftpath, 'template', 'sourcemodel', 'standard_sourcemodel3d8mm.mat'), 'sourcemodel');
template_grid = sourcemodel;
clear sourcemodel;

for k = 1:numel(allsources)
  allsources{k}.inside = template_grid.inside;
  allsources{k}.pos = template_grid.pos;
  allsources{k}.dim = template_grid.dim;
  
  % the source job has discarded all the voxels outside the brain, but FT
  % expects them present, so restore them here
  tmp = allsources{k}.pow;
  allsources{k}.pow = nan(size(template_grid.pos,1), size(tmp, 2), size(tmp, 3));
  allsources{k}.pow(template_grid.inside,:,:) = tmp;
end


%% compute t-map (uncorrected; stats done at sensor level)

cfg = [];
cfg.parameter = 'pow';
cfg.method = 'analytic';
cfg.correctm = 'no';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.tail = 0;

nobs = numel(all_ids);
cfg.design = [
  ones(1,nobs)*1 ones(1,nobs)*2
  1:nobs 1:nobs
];
cfg.ivar = 1;
cfg.uvar = 2;

stat = ft_sourcestatistics(cfg, allsources{:,:});


%% interpolate onto MNI average brain and plot

mri = ft_read_mri(fullfile(rootdir, 'processed', 'average305_t1_tal_lin.nii'));
mri.coordsys = 'mni';

cfg = [];
cfg.parameter = 'stat';
stat_interp = ft_sourceinterpolate(cfg, stat, mri);

% thresholded opacity map, anything <65% of maximum is fully transparent,
% anything >80% of maximum is fully opaque
stat_interp.nicemask = make_mask(stat_interp.stat, [0.65 0.8]);

cfg = [];
cfg.atlas = fullfile(ftpath, 'template', 'atlas', 'aal', 'ROI_MNI_V4.nii');
cfg.funparameter = 'stat';
cfg.maskparameter = 'nicemask';
cfg.method = 'ortho';
cfg.funcolorlim = [-4 4];
cfg.colorbar = 'yes';

% first maximum is in R Hippocampus
cfg.location = [42.9 -30.5 -9.3];
ft_sourceplot(cfg, stat_interp);

f = gcf();
print('-r150', '-fillpage', f, fullfile(results_dir, '012-source-theta-beamformer-hipp-fig3b.pdf'), '-dpdf');
close(f);

% second effect is in Superior Frontal
cfg.location = [-12.1 23.5 59.7];
ft_sourceplot(cfg, stat_interp);

f = gcf();
print('-r150', '-fillpage', f, fullfile(results_dir, '013-source-theta-beamformer-frontal-fig3b.pdf'), '-dpdf');
close(f);

end