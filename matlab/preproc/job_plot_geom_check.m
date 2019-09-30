function job_plot_geom_check(subj_id)

subjects = datainfo();

load(fullfile(subjects(subj_id).dir, 'geom-leadfield-mni-8mm-megchans.mat'),...
  'headmodel', 'leadfield');

grad = ft_read_sens(subjects(subj_id).rawmeg, 'senstype', 'meg');
grad = ft_convert_units(grad, 'mm');


h = figure('name', sprintf('subj%02d', subj_id));
ft_plot_sens(grad,  'chantype', 'meggrad', 'coilsize', 5,...
  'facecolor', 'white', 'edgecolor', 'white', 'facealpha', 0.8,...
  'edgealpha', 0.8);

hold on;
ft_plot_vol(headmodel, 'edgecolor', 'none', 'facealpha', 0.7, 'facecolor', 'cortex');
ft_plot_mesh(leadfield.pos(leadfield.inside,:));

waitfor(h);

end