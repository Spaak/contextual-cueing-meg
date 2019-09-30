function results = load_job_results(subjects, all_ids, filename, varname)

results = {};
for k = 1:numel(all_ids)
  subj_id = all_ids(k);
  fprintf('loading data for subject ID = %d...\n', subj_id);
  load(fullfile(subjects(subj_id).dir, filename), varname);
  eval(sprintf('results{k} = %s;', varname));
end

end