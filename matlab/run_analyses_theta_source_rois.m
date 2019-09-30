function run_analyses_theta_source_rois(run_mode, results_dir, subjects, all_ids, rootdir)

%% trial-resolved source-level post-stimulus theta power in ROIs

allsources = run_individual_jobs('job_source_theta_rois', 'source_pow', subjects, all_ids, run_mode);

% the frontal ROI is grid points 2-4 combined, the hippocampal ROI is the
% first grid point
roilabels = {'R Hipp', 'L Front Sup', '(small) R Front Mid', '(small) L Precentral'};


%% relate single-trial values to experimental variables

smoothblocks = -1:1;
use_blocks = 9:22;
for k = 1:numel(all_ids)
  for l = 1:numel(roilabels)
    scores(k,l) = relate_to_task(all_ids(k), allsources{k}.pow(l,:),...
      allsources{k}.trialinfo(:,2), smoothblocks, 9:22);
  end
end


%% plot theta power in the two ROIs and Old/New over experiment time

alpha = 0.05;
blk = 1:22;

all_timecond = structcat(scores, 'timecondvar');

% subj X block X cond
pow_hipp = permute(all_timecond(:,:,:,1), [3 2 1]);
pow_frontal = permute(mean(all_timecond(:,:,:,2:4), 4), [3 2 1]);

plotdat = cat(4, pow_hipp, pow_frontal);

f = figure();

for axnum = 1:2
  mu = squeeze(mean(plotdat(:,:,:,axnum), 1));
  % within-participant corrected standard error of the mean, per block
  % correction only across the two conditions
  ci = zeros(numel(blk), 1, 2);
  for k = 1:22
    ci(k,1,:,:) = withinstde(squeeze(plotdat(:,k,:,axnum)));
  end
  
  ax = subplot(2,1,axnum);

  set(ax, 'color', 'none', 'xtick', [1 5 10 15 20 22]);
  xlim([0 22]);
  hold on;
  [hl,~] = boundedline(blk, mu, ci, 's-', 'alpha');
  set(hl, {'markerfacecolor'}, get(hl, 'color'), 'markersize', 3);

  % add tests
  for k = 1:22
    [~,p,~,~] = ttest(plotdat(:,k,1,axnum), plotdat(:,k,2,axnum));
    if p < alpha
      plot(k, 0.05, '*', 'color', 'k');
    end
  end

  legend(hl, 'Old', 'New', 'location', 'eastoutside');
  xlabel('Block');
  
  if axnum == 1
    set(ax, 'ytick', 0.03:0.03:0.15);
    ylim([0.03 0.15]);
    ylabel('Normalized power');
    title('Hippocampus');
  else
    set(ax, 'ytick', -0.03:0.03:0.06);
    ylim([-0.03 0.06]);
    ylabel('Normalized power');
    title('Frontal');
  end

end

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '013-source-theta-rois-oldnew-fig3c.pdf'), '-dpdf');
close(f);


%% load behavioural results

detrend_and_log = 1;

% load all data
for k = 1:numel(all_ids)
  behav(k) = behav_single_subj(all_ids(k), smoothblocks, use_blocks, detrend_and_log);
  
  % use this one for the RT effect over the whole experiment, as otherwise
  % only blocks 9-22 will be log-transformed and detrended
  behav_overtime(k) = behav_single_subj(all_ids(k), smoothblocks, 1:22, detrend_and_log);
  
  % these are used in the per-item analysis of contextual cueing effect
  % (median RT in first 5 versus median RT in last 5 blocks of experiment)
  behav_first(k) = behav_single_subj(all_ids(k), smoothblocks, 1:5, detrend_and_log);
  behav_last(k) = behav_single_subj(all_ids(k), smoothblocks, 18:22, detrend_and_log);
end


%% plot Old vs New effect for power and reaction time on same axis

% for power time courses: Old - New
plotdat = cat(4, pow_hipp, pow_frontal);
plotdat = squeeze(plotdat(:,:,1,:) - plotdat(:,:,2,:));

% for reaction time effect: New - Old (so both effects are in same
% direction)
plotdat(:,:,3) = cat(1, behav_overtime.medblockrt_new) - cat(1, behav_overtime.medblockrt_old);

mu = squeeze(mean(plotdat, 1));

% now use normal standard error, because we're not directly comparing
% different lines in the same plot to one another
ci = squeeze(std(plotdat, [], 1) ./ sqrt(size(plotdat, 1)));

colors = brewermap(3, 'Dark2');

f = figure();
ax = gca();
hold on;
hl = zeros(3,1); % store handles to the lines added below
alpha = 0.05;
for k = 1:3
  hl(k) = boundedline(blk, mu(:,k), ci(:,k), 's-', 'cmap', colors(k,:), 'alpha');
  set(hl(k), 'markerfacecolor', get(hl(k), 'color'), 'markersize', 3);
  
  for l = 1:22
    [~,p] = ttest(plotdat(:,l,k));
    if p < alpha
      plot(l, (k-1)*0.01, '*', 'color', colors(k,:));
    end
  end
end

xlabel('Block');
ylabel('Old - New (normalized units)');

plot(0:25, zeros(26,1), 'k:');
legend(hl, 'Hippocampus R power', 'Prefrontal power', 'Reaction time');
set(ax, 'color', 'none', 'xtick', [1 5 10 15 20 22], 'ytick', -0.05:0.05:0.1);
ylim([-0.05 0.1]);
xlim([0 22]);

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '014-source-theta-rois-withrt-fig4a.pdf'), '-dpdf');
close(f);


%% align time courses to switchpoint

switchpoints = importdata(fullfile(rootdir, 'processed', 'combined', 'subject-switchpoints.txt'));
% note: keep switchpoints as zero-based index here, this is used in the
% code for plotting

% center analysis on 90% CI
inds = switchpoints >= prctile(switchpoints, 5, 2) & switchpoints < prctile(switchpoints, 95, 2);
samps = switchpoints;
samps(~inds) = nan;

blk_shift = -23:22;
nshifts = numel(blk_shift);
[nsub, nsamp] = size(samps);

% trailing dimension is Hipp/Front/RT
spdat = nan(nshifts, nsamp, nsub, 3);
for k = 1:nsamp
  for l = 1:nsub
    if ~isnan(samps(l,k))
      spdat(24-samps(l,k):nshifts-samps(l,k)-1,k,l,:) = plotdat(l,:,:);
    end
  end
end

% average over samples (get posterior mean)
post_mean = squeeze(nanmean(spdat, 2));
mu = squeeze(nanmean(post_mean, 2));
ci = squeeze(nanstd(post_mean, [], 2)) ./ sqrt(size(post_mean, 2));

f = figure();
ax = gca();
hold on;
hl = zeros(3,1); % store handles to the lines added below
alpha = 0.05;
for k = 1:3
  hl(k) = boundedline(blk_shift, mu(:,k), ci(:,k), 's-', 'cmap', colors(k,:), 'alpha');
  set(hl(k), 'markerfacecolor', get(hl(k), 'color'), 'markersize', 3);
  
  for l = 1:numel(blk_shift)
    tmpdat = post_mean(l,:,k)';
    tmpdat = tmpdat(~isnan(tmpdat));
    if numel(tmpdat) > 1
      [~,p] = ttest(tmpdat);
      if p < alpha
        plot(blk_shift(l), (k-1)*0.01, '*', 'color', colors(k,:));
      end
    end
  end
end

legend(hl, 'Hippocampus R power', 'Prefrontal power', 'Reaction time');

xlabel('Block from switchpoint');
ylabel('Old - New (normalized units)');
set(ax, 'color', 'none', 'xtick', -6:2:6, 'ytick', [-0.05:0.05:0.1]);
xlim([-7 7]);
ylim([-0.05 0.1]);

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '015-source-theta-rois-withrt-switchpoint-fig4b.pdf'), '-dpdf');
close(f);


%% cluster statistics on the switchpoint-aligned data

Test = {'Hipp Theta Pow Old vs New aligned to Switchpoint';
  'Frontal Theta Pow Old vs New aligned to Switchpoint';
  'log(RT) Old vs New aligned to Switchpoint'};

PVal = ones(3,1);

for k = 1:3
  [datobs,datrnd] = cluster_test_helper(post_mean(:,:,k), 1000);
  [~, p, ~] = cluster_test(datobs, datrnd);
  PVal(k) = min(p(:));
end


%% pairwise comparisons of frontal theta power between all four conditions

% note: plot is not in paper, but statistics for pairwise comparisons are
% reported in the text

all_condvar = structcat(scores, 'condvar');
pow_frontal = squeeze(mean(all_condvar(:,:,:,2:4),4)); % note: avg over 3 frontal ROIs

f = figure();
paired_scatters(pow_frontal);
suptitle('Frontal theta power');

print('-r150', '-fillpage', f, fullfile(results_dir, '016-source-theta-rois-frontal-condwise.pdf'), '-dpdf');
close(f);


%% across-subject correlations between theta power and reaction time effect

pow_hipp = squeeze(all_condvar(1:2,:,:,1));
pow_frontal = squeeze(mean(all_condvar(1:2,:,:,2:4),4)); % note: avg over 3 frontal ROIs

% subj X hipp/frontal X old/new
pow_both = permute(cat(3, pow_hipp, pow_frontal), [2 3 1]);

cond_labels = {'Old', 'New'};
region_labels = {'Hipp', 'Frontal'};

rt_diff = [behav.medrt_new]' - [behav.medrt_old]';
nsub = numel(rt_diff);

f = figure();

ax = zeros(4,1);
for region = 1:2
  for cond = 1:2
    axnum = (cond-1)*2+region;
    ax(axnum) = subplot(2,2,axnum);
    hold on;
    
    scatter(pow_both(:,region,cond), rt_diff, 'k', 'filled');
    [r,p] = corr(pow_both(:,region,cond), rt_diff);
    t = r.*sqrt((nsub-2)./(1-r.^2));
    bf10 = t1smpbf(t, nsub);
    title(sprintf('r = %.3f, t = %.3f, p = %.3f, bf10 = %.3f', r, t, p, bf10));

    % add regression line with CI
    mdl = fitlm(pow_both(:,region,cond), rt_diff);
    xpred = linspace(min(pow_both(:,region,cond)), max(pow_both(:,region,cond)), 200)';
    [ypred, yci] = predict(mdl, xpred);
    h = fill_between(xpred, yci(:,1), yci(:,2));
    h.EdgeColor = 'none';
    h.FaceColor = [0 0 0];
    h.FaceAlpha = 0.2;
    plot(xpred, ypred, 'k');
    
    xlabel(sprintf('%s Power %s trials', region_labels{region}, cond_labels{cond}));
    ylabel('log(RT) benefit (New-Old)');
  end
end

linkaxes(ax, 'y');
linkaxes([ax(1) ax(3)], 'x');
linkaxes([ax(2) ax(4)], 'x');

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '017-source-theta-rois-scatters-fig4c.pdf'), '-dpdf');
close(f);


%% item-level analysis: is frontal theta power correlated with RT benefit across items?

allr_hipp = zeros(nsub, 1);
allr_frontal = zeros(nsub, 1);

all_display_old = structcat(scores, 'var_display_old');
pow_hipp = squeeze(all_display_old(:,:,:,1));
pow_frontal = squeeze(mean(all_display_old(:,:,:,2:4), 4));

for k = 1:nsub
  % ctxcue effect as RT difference per item first 5 vs last 5 blocks
  ctxcue = behav_first(k).medrt_display_old - behav_last(k).medrt_display_old;
  allr_hipp(k) = corr(ctxcue, pow_hipp(:,k));
  allr_frontal(k) = corr(ctxcue, pow_frontal(:,k));
end

Tstat = nan(3,1);
Df = nan(3,1);
BF10 = nan(3,1);

Test{end+1} = 'Across-item Corr Hipp Pow X log(RT)';
[Tstat(end+1),Df(end+1),PVal(end+1),BF10(end+1)] = t1samp_with_bf(allr_hipp);

Test{end+1} = 'Across-item Corr Frontal Pow X log(RT)';
[Tstat(end+1),Df(end+1),PVal(end+1),BF10(end+1)] = t1samp_with_bf(allr_frontal);


%% store test results in text file

T = table(Test, Tstat, Df, PVal, BF10);
f = fopen(fullfile(results_dir, '018-source-theta-rois-tests.txt'), 'wt');
% disp(T) gives nice textual summary, which we want to put in a file, but
% wihtout the <html> tags, and with NaN replaced by ''
fprintf(f, strrep(regexprep(evalc('disp(T)'), '<strong>|</strong>', ''), 'NaN', '   '));
fclose(f);


end