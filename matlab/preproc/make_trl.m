function trl = make_trl(subj_id)

subjects = datainfo();

cfg = [];
cfg.dataset = subjects(subj_id).rawmeg;
cfg.trialdef.eventtype = 'UPPT001';
cfg.trialdef.eventvalue = 1:32;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 1.5;
cfg = ft_definetrial(cfg);

[stim,~,~] = load_behav(subj_id);

addpath ../../expscripts;

% The MEG recording will contain the practice trials as well, which we
% don't want. There might be different numbers of practice trials among
% recordings, so do a check here to make sure we read in the right trials,
% as defined by the behavioural log file. This is also a nice sanity check
% in general.

% compute the triggers that should have been sent based on the behavioural
% log file
trigs_behav = arrayfun(@(x) MakeOnsetTrig(stim, x), 1:stim.num_tri_total);

% exclude recognition task
trigs_behav = trigs_behav(trigs_behav <= 32);

% subj29 had a DSQ error (see Castor EDC), so ignore the later part of the
% behavioural log file
if subj_id == 29
  trigs_behav = trigs_behav(1:804);
end

ntri_meg = size(cfg.trl, 1);
ntri_behav = numel(trigs_behav);
assert(ntri_meg >= ntri_behav);

% find indices for which triggers overlap
for offset = 0:1000
    trigs_meg = cfg.trl((1+offset):(ntri_behav+offset),4);
    if isequal(trigs_meg', trigs_behav)
        fprintf('ignoring first %d trials in MEG\n', offset);
        break;
    end
end
if offset == 1000
    error('could not determine best offset from MEG to behavioural triggers');
end

trl = cfg.trl((1+offset):(ntri_behav+offset),:);

% add trial indices to the end of the trl matrix, for easy indexing into
% the behavioural log later on (after rejecting trials etc.)
trl(:,5) = 1:ntri_behav;

end