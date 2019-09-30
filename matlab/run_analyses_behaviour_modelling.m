function run_analyses_behaviour_modelling(results_dir, rootdir)

models = {'No effect', 'No switchpoint', 'Switchpoint', 'Linear', 'Blockwise linear', 'Quadratic'};

% load WAIC values
npwaic = importdata(fullfile(rootdir, 'processed', 'combined', 'npwaic-blockwisedetrend=False.txt'));

% normalize by z-scoring across models per participant
normwaic = (npwaic - mean(npwaic, 1)) ./ std(npwaic, [], 1);

% also report relative waic to best model
relwaic = (npwaic - max(npwaic, [], 1));


%% different models illustration

f = figure();

trialinds = 1:880;
blockinds = ceil(trialinds ./ 160);

subplot(6,2,1);
plot(trialinds, zeros(size(trialinds)), 'k');

subplot(6,2,3);
plot(trialinds, ones(size(trialinds))*0.5, 'k');

subplot(6,2,5);
dat = zeros(size(trialinds));
dat(321:end) = 0.5;
plot(trialinds, dat, 'k');

subplot(6,2,7);
dat = trialinds ./ max(trialinds) * 0.5;
plot(trialinds, dat, 'k');

subplot(6,2,9);
dat = blockinds ./ max(blockinds) * 0.5;
plot(trialinds, dat, 'k');

subplot(6,2,11);
dat = (trialinds ./ max(trialinds) * 0.8).^2;
dat = fliplr(max(dat) - dat);
plot(trialinds, dat, 'k');

plotinds = 1:2:12;
for k = 1:6
  ax = subplot(6,2,plotinds(k));
  box off;
  ylim([-1 1]);
  xlim([0 880]);
  hold on;
  plot(trialinds, zeros(size(trialinds)), ':k', 'color', [0.3 0.3 0.3 0.5]);
  set(ax, 'ytick', [0], 'yticklabel', models{k}, 'yticklabelrotation', 0);
  set(ax, 'xtick', []);
end


%% violin plots

bw = (max(normwaic(:))-min(normwaic(:))) * 0.07;

subplot(6,2,2:2:12);

violinplot(fliplr(normwaic'), fliplr(models), 'bandwidth', bw, 'violincolor', [0.5 0.5 0.5]);
ax = gca();
view([270 90]); % this rotates the plot
ax.YDir = 'reverse';

ylabel('WAIC (z-score)');
set(ax, 'ytick', [-2 0 2]);
ylim([-2.5 2.5]);

set(ax, 'xticklabel', {});

% save figure
print('-r150', '-fillpage', f, fullfile(results_dir, '006-behav-modelling-waic-fig2.pdf'), '-dpdf');
close(f);


%% pairwise comparisons

f = figure();
f.PaperUnits = 'centimeters';
f.PaperPosition = [0 0 40 40];
f.PaperSize = [40 40];
paired_scatters(normwaic, models);

print('-r150', '-fillpage', f, fullfile(results_dir, '007-behav-modelling-waic-pairwise.pdf'), '-dpdf');
close(f);


%% output relative waic values

ModelName = models';
RelWaic = sum(relwaic, 2);

T = table(ModelName, RelWaic);
f = fopen(fullfile(results_dir, '008-behav-modelling-waicvalues.txt'), 'wt');
% disp(T) gives nice textual summary, which we want to put in a file, but
% wihtout the <html> tags, and with NaN replaced by ''
fprintf(f, strrep(regexprep(evalc('disp(T)'), '<strong>|</strong>', ''), 'NaN', '   '));
fclose(f);


end
