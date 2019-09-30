[subjects,all_ids] = datainfo();

%% on cluster

myqsub('job_geom_segmentmri_and_leadfield', 'mem=12gb,walltime=00:30:00,nodes=1:intel', all_ids);

%% in process

for subj_id = all_ids
  job_geom_segmentmri_and_leadfield(subj_id);
end

%% visual checks

for subj_id = all_ids
  job_plot_geom_check(subj_id);
end