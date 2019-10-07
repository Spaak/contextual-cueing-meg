function run_analyses_behaviour_main(results_dir, all_ids)
%
% Copyright (C) Eelke Spaak, Donders Institute, Nijmegen, The Netherlands, 2019.
% 
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this code. If not, see <https://www.gnu.org/licenses/>.

%% load behavioural data

% use only blocks 9-22 for condition-wise aggregates
use_blocks = 9:22;

% smoothing factor for blockwise plots (not used for aggregates)
smoothblocks = -1:1;

% log-transform and detrend the reaction time data
detrend_and_log = 1;

% load all data
for k = 1:numel(all_ids)
  behav(k) = behav_single_subj(all_ids(k), smoothblocks, use_blocks, detrend_and_log);
  behav_nolog(k) = behav_single_subj(all_ids(k), smoothblocks, use_blocks, 0);
  behav_allblocks(k) = behav_single_subj(all_ids(k), smoothblocks, 1:22, detrend_and_log);
end


%% plot accuracy and RT in seconds over experiment time

alpha = 0.05;
blk = 1:22;

% subj X block X cond
rts = cat(3, cat(1, behav_nolog.medblockrt_old), cat(1, behav_nolog.medblockrt_new));
allacc = cat(3, cat(1, behav_nolog.accblock_old), cat(1, behav_nolog.accblock_new));

plotdat = cat(4, rts, allacc);

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
      plot(k, 0.92, '*', 'color', 'k');
    end
  end

  legend(hl, 'Old', 'New', 'location', 'eastoutside');
  xlabel('Block');
  
  if axnum == 1
    set(ax, 'ytick', [0.6 0.8]);
    ylim([0.6 0.92]);
    ylabel('Reaction time (s)');
  else
    set(ax, 'ytick', [0.7 0.8 0.9]);
    ylim([0.7 0.95]);
    ylabel('Accuracy');
  end

end

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '001-behav-fig1c.pdf'), '-dpdf');
close(f);


%% violin plots for blocks 9-22

rts = [behav.medrt_old; behav.medrt_new; behav.medrt_disviol; behav.medrt_tarviol];
allacc = [behav.acc_old; behav.acc_new; behav.acc_disviol; behav.acc_tarviol];

plotdat = cat(3, rts, allacc);

f = figure();
colors = get(gca,'ColorOrder');
close(f);

labels = {'Old', 'New', 'Distractor violation', 'Target violation'};

f = figure();

for axnum = 1:2
  ax = subplot(2,1,axnum);
  thisdat = plotdat(:,:,axnum);
  bw = (max(thisdat(:))-min(thisdat(:))) * 0.07;
  violins = violinplot(thisdat', labels, 'bandwidth', bw);

  for k = 1:4
    violins(k).ViolinColor = colors(k,:);
  end
  
  if axnum == 1
    set(ax, 'xticklabel', []);
    ylabel('Detrended log(RT)');
    ylim([-0.1 0.05]);
    set(ax, 'ytick', [-0.1 -0.05 0 0.05]);
  else
    set(ax, 'xticklabelrotation', 45);
    ylabel('Accuracy');
    ylim([0.6 1.0]);
    set(ax, 'ytick', [0.6 0.8 1.0]);
  end
end

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '002-behav-fig1d.pdf'), '-dpdf');
close(f);


%% pairwise comparisons in separate plot

% note: plots are not in the paper, but pairwise comparisons (stats from scatter plots) are
% represented as significance bars in Figure 1D and reported in the text

for num = 1:2
  f = figure();
  paired_scatters(plotdat(:,:,num));
  if num == 1
    suptitle('Detrended log(RT)');
    filename = '003-behav-pairwise-tests-rt';
  else
    suptitle('Accuracy');
    filename = '004-behav-pairwise-tests-acc';
  end
  print('-r150', '-fillpage', f, fullfile(results_dir, filename), '-dpdf');
  close(f);
end


%% mean values reported in text

% use non-log-transformed
rts = [behav_nolog.medrt_old; behav_nolog.medrt_new; behav_nolog.medrt_disviol; behav_nolog.medrt_tarviol];

MeanRT = mean(rts, 2) * 1000; % as milliseconds
StdRT = std(rts, [], 2) * 1000;
MeanAcc = mean(allacc, 2) * 100; % as percents
StdAcc = std(allacc, [], 2) * 100;
Condition = labels';

% save results as table
T = table(Condition, MeanRT, StdRT, MeanAcc, StdAcc);
f = fopen(fullfile(results_dir, '005-behav-mean-std-acc-rt.txt'), 'wt');
% disp(T) gives nice textual summary, which we want to put in a file, but
% wihtout the <html> tags
fprintf(f, regexprep(evalc('disp(T)'), '<.*?>', ''));
fclose(f);


%% individual learning curves of Old vs New reaction time

% subj X block X cond
rts = cat(3, cat(1, behav_allblocks.medblockrt_old), cat(1, behav_allblocks.medblockrt_new));
rts = rts(:,:,2) - rts(:,:,1);

mu = squeeze(mean(rts, 1));
ci = std(rts, [], 1) ./ sqrt(size(rts, 1));

f = figure();
ax = gca();

set(ax, 'color', 'none', 'xtick', [1 5 10 15 20 22]);
xlim([0 22]);
hold on;

% plot individual
plot(blk, rts', 'color', [0 0 0 0.1]);

[hl,~] = boundedline(blk, mu, ci, 'ks-', 'alpha');
set(hl, 'markerfacecolor', get(hl, 'color'), 'markersize', 3);

hold on;
plot(blk, zeros(size(blk)), 'k--');

xlabel('Block');
ylabel('Reaction time New - Old (log(RT/s))');

% save figure
print('-r150', '-bestfit', f, fullfile(results_dir, '006-behav-rteffect-individuals-fig2a.pdf'), '-dpdf');
close(f);

end
