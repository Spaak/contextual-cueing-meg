function export_behaviour_data_for_modelling(all_ids, rootdir)

allrts = {};
allcond = {};
allinds = {};

for k = 1:numel(all_ids)
  [stim,rts,responses] = load_behav(all_ids(k));
  
  use_blocks = 1:22;
  maintri = ismember(stim.blocks, use_blocks);
  correct = (stim.rotation(:,1) == -90 & responses == stim.RESP_LEFT) | ...
      (stim.rotation(:,1) == 90 & responses == stim.RESP_RIGHT);
  viol = stim.is_distractor_violation | stim.is_target_violation;
  
  usetri = maintri & correct & ~viol;
  
  allrts{k} = rts(usetri);
  allcond{k} = stim.is_old(usetri);
  
  % trial indices
  allinds{k} = find(usetri);
end

save(fullfile(rootdir, 'processed', 'combined', 'all-rt-dat-for-modelling.mat'),...
  'allrts', 'allcond', 'allinds');

end