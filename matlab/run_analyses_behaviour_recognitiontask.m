function run_analyses_behaviour_recognitiontask(results_dir, all_ids)

%% load behavioural data

% use only blocks 9-22 for condition-wise aggregates
use_blocks = 9:22;
smoothblocks = 0;

% log-transform and detrend the reaction time data
detrend_and_log = 1;

% load all data
for k = 1:numel(all_ids)
  behav(k) = behav_single_subj(all_ids(k), smoothblocks, use_blocks, detrend_and_log);
  behav_nolog(k) = behav_single_subj(all_ids(k), smoothblocks, use_blocks, 0);
  
  % these are used in the per-item analysis of contextual cueing effect
  % (median RT in first 5 versus median RT in last 5 blocks of experiment)
  behav_first(k) = behav_single_subj(all_ids(k), smoothblocks, 1:5, detrend_and_log);
  behav_last(k) = behav_single_subj(all_ids(k), smoothblocks, 18:22, detrend_and_log);
end


%% explicit recognition performance violin plots

nsub = numel(behav);

% subjective recognition rating
allresp = [behav.recogyesno];

% objective recognition accuracy
allacc = [behav.recogacc] * 100;

% contextual cueing effect in (normalized) reaction time difference
rtdiff = [behav.medrt_new] - [behav.medrt_old];

% contextual cueing effect in IES (inverse efficiency score)
ies_diff = zeros(nsub, 1);
for k = 1:nsub
  ies_diff(k) = (mean(behav_nolog(k).allrt_new) / behav_nolog(k).acc_new) - ...
    (mean(behav_nolog(k).allrt_old) / behav_nolog(k).acc_old);
end

% combine into matrix for easy plotting
plotdat = [allacc' rtdiff' ies_diff];

f = figure();
colors = get(gca,'ColorOrder');
close(f);

f = figure();

plotinds = [1 3 4];

for axnum = 1:3
  ax = subplot(3,2,plotinds(axnum));
  hold on;

  violdat = struct();
  violdat.Overall = plotdat(:, axnum);
  violdat.No = plotdat(~allresp, axnum);
  violdat.Yes = plotdat(allresp, axnum);

  bw = (max(plotdat(:,axnum))-min(plotdat(:,axnum))) * 0.07;
  violins = violinplot(violdat, {}, 'bandwidth', bw);

  for k = 1:3
    if k == 1
      violins(k).ViolinColor = [0.5 0.5 0.5];
    else
      violins(k).ViolinColor = colors(k+3,:);
    end
  end

  if axnum == 1
    ylabel('Recognition accuracy (%)');
    ylim([30 70]);
    set(gca, 'ytick', [30 50 70]);
    plot([-10 10], [50 50], ':k');
  elseif axnum == 2
    ylabel('Contextual cueing (log(RT/s))');
    ylim([-0.04 0.12]);
    set(ax, 'ytick', [-0.04 0 0.06 0.12]);
    plot([-10 10], [0 0], ':k');
  elseif axnum == 3
    ylabel('Contextual cueing IES (s)');
    ylim([-0.1 0.3]);
    set(ax, 'ytick', [-0.1:0.1:0.3]);
    plot([-10 10], [0 0], ':k');
  end

  xlim([0.5 3.5]);
  
end


%% scatter/regresssion plots of contextual cueing vs objective recognition accuracy

ydats = [rtdiff' ies_diff];
plotinds = [5 6];

for axnum = 1:2
  ax = subplot(3,2,plotinds(axnum));

  % color the dots according to yes/no
  c = zeros(numel(allacc), 3);
  c(~allresp,:) = repmat(colors(5,:), sum(~allresp), 1);
  c(allresp,:) = repmat(colors(6,:), sum(allresp), 1);

  scatter(allacc', ydats(:,axnum), [], c, 'filled');
  
  if axnum == 1
    ylim([-0.05 0.12]);
    set(ax, 'ytick', [-0.05 0 0.05 0.1]);
    ylabel('Contextual cueing (log(RT/s))');
  else
    ylim([-0.1 0.3]);
    set(ax, 'ytick', [-0.1:0.1:0.3]);
    ylabel('Contextual cueing IES (s)');
  end
  
  xlim([38 70]);
  set(gca, 'xtick', 40:10:70);
  
  xlabel('Recognition accuracy (%)');

  % add regression line with CI
  mdl = fitlm(allacc', ydats(:,axnum));
  xpred = linspace(min(allacc), max(allacc), 200)';
  [ypred, yci] = predict(mdl, xpred);

  hold on;
  h = fill_between(xpred, yci(:,1), yci(:,2));
  h.EdgeColor = 'none';
  h.FaceColor = [0 0 0];
  h.FaceAlpha = 0.2;
  plot(xpred, ypred, 'k');

end

% save figure
print('-r150', '-fillpage', f, fullfile(results_dir, '020-behav-recogtask.pdf'), '-dpdf');
close(f);


%% mean values and statistical tests reported

% store values and labels for tests in these vectors; will be combined into
% table later on
Test = {};
MeanVal = [];
StdVal = [];
Tstat = [];
Df = [];
Pval = [];
BF10 = [];


% tests of recognition accuracy

Test{end+1} = 'Whole sample recog acc <> chance';
MeanVal(end+1) = mean(allacc);
StdVal(end+1) = std(allacc);
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(allacc-50);

Test{end+1} = 'Recognizers recog acc <> chance';
MeanVal(end+1) = mean(allacc(allresp));
StdVal(end+1) = std(allacc(allresp));
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(allacc(allresp)-50);

Test{end+1} = 'Non-recognizers recog acc <> chance';
MeanVal(end+1) = mean(allacc(~allresp));
StdVal(end+1) = std(allacc(~allresp));
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(allacc(~allresp)-50);

Test{end+1} = 'Recognizers <> Non-recognizers recog acc';
MeanVal(end+1) = nan; StdVal(end+1) = nan; % nan values are not reported in paper
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(allacc(allresp), allacc(~allresp));


% contextual cueing effect in subgroups

Test{end+1} = 'Recognizers log(RT) New <> Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(rtdiff(allresp));

Test{end+1} = 'Non-recognizers log(RT) New <> Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(rtdiff(~allresp));

Test{end+1} = 'Recognizers > Non-recognizers log(RT) New-Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[~,Pval(end+1),~,stat] = ttest2(rtdiff(allresp), rtdiff(~allresp), 'tail', 'right');
Df(end+1) = stat.df; Tstat(end+1) = stat.tstat; BF10(end+1) = nan;
% note: one-tailed Bayes factors were computed using JASP

Test{end+1} = 'Recognizers <> Non-recognizers log(RT) New-Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(rtdiff(allresp), rtdiff(~allresp));


% correlation between objective explicit memory and contextual cueing

Test{end+1} = 'Corr recog acc X log(RT) New-Old';
[r,p] = corr(allacc', rtdiff');
MeanVal(end+1) = r; Pval(end+1) = p;
StdVal(end+1) = nan;
Df(end+1) = numel(allacc)-2;
Tstat(end+1) = r.*sqrt((numel(allacc)-2)./(1-r.^2));
BF10(end+1) = t1smpbf(Tstat(end), numel(allacc));


% contextual cueing in search task accuracy

searchaccdiff = [behav.acc_old] - [behav.acc_new];

Test{end+1} = 'Recognizers searchacc New <> Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(searchaccdiff(allresp));

Test{end+1} = 'Non-recognizers searchacc New <> Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(searchaccdiff(~allresp));

Test{end+1} = 'Recognizers > Non-recognizers searchacc New-Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[~,Pval(end+1),~,stat] = ttest2(searchaccdiff(allresp), searchaccdiff(~allresp), 'tail', 'right');
Df(end+1) = stat.df; Tstat(end+1) = stat.tstat; BF10(end+1) = nan;
% note: one-tailed Bayes factors were computed using JASP

Test{end+1} = 'Recognizers <> Non-recognizers searchacc New-Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(searchaccdiff(allresp), searchaccdiff(~allresp));

Test{end+1} = 'Corr recog acc X searchacc New-Old';
[r,p] = corr(allacc', searchaccdiff');
MeanVal(end+1) = r; Pval(end+1) = p;
StdVal(end+1) = nan;
Df(end+1) = numel(allacc)-2;
Tstat(end+1) = r.*sqrt((numel(allacc)-2)./(1-r.^2));
BF10(end+1) = t1smpbf(Tstat(end), numel(allacc));


% contextual cueing as Inverse Efficiency Score (IES)

Test{end+1} = 'Recognizers <> Non-recognizers IES New-Old';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(ies_diff(allresp), ies_diff(~allresp));

Test{end+1} = 'Corr recog acc X IES New-Old';
[r,p] = corr(allacc', ies_diff);
MeanVal(end+1) = r; Pval(end+1) = p;
StdVal(end+1) = nan;
Df(end+1) = numel(allacc)-2;
Tstat(end+1) = r.*sqrt((numel(allacc)-2)./(1-r.^2));
BF10(end+1) = t1smpbf(Tstat(end), numel(allacc));


%% item-level analysis: does RT benefit predict recog performance?

% regression coefficients per participant
allb = zeros(nsub, 1);

for k = 1:nsub
  % ctxcue effect as RT difference per item first 5 vs last 5 blocks
  ctxcue = behav_first(k).medrt_display_old - behav_last(k).medrt_display_old;
  
  b = glmfit(ctxcue, behav(k).recogacc_display_old, 'binomial');
  allb(k) = b(2);
end

Test{end+1} = 'Item-level recog acc ~ RT benefit';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t1samp_with_bf(allb);


%% are there overall RT or search task acc differences between (non-)recognizers?

allrt = [behav.medrt];
Test{end+1} = 'Recognizers <> Non-recognizers overall log(RT)';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(allrt(allresp), allrt(~allresp));

searchacc = [behav.acc];
Test{end+1} = 'Recognizers <> Non-recognizers overall searchacc';
MeanVal(end+1) = nan; StdVal(end+1) = nan;
[Tstat(end+1),Df(end+1),Pval(end+1),BF10(end+1)] = t2samp_with_bf(searchacc(allresp), searchacc(~allresp));


%% output

Test = Test';
MeanVal = MeanVal';
StdVal = StdVal';
Tstat = Tstat';
Df = Df';
Pval = Pval';
BF10 = BF10';

T = table(Test, Tstat, Df, Pval, BF10, MeanVal, StdVal);
f = fopen(fullfile(results_dir, '021-behav-recogtask-tests.txt'), 'wt');
% disp(T) gives nice textual summary, which we want to put in a file, but
% wihtout the <html> tags, and with NaN replaced by ''
fprintf(f, strrep(regexprep(evalc('disp(T)'), '<strong>|</strong>', ''), 'NaN', '   '));
fclose(f);


end