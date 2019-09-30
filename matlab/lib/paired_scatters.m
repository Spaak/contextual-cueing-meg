function paired_scatters(dat, labels)

% dat: cond X participant

[ncond,nobs] = size(dat);

if nargin < 2 || isempty(labels)
  assert(ncond == 4);
  labels = {'Old', 'New', 'Distractor violation', 'Target violation'};
end

lims = [min(dat(:)) max(dat(:))];%[-0.2 0.5];

gcf();
for k = 1:ncond
  for l = (k+1):ncond
    subplot(ncond-1,ncond-1,(k-1)*(ncond-1)+l-1);
    scatter(dat(l,:), dat(k,:));
    hold on;
    xlabel(labels{l});
    ylabel(labels{k});
    plot(lims, lims, 'k');
    xlim(lims);
    ylim(lims);
    axis square;

    [h,p,ci,stat] = ttest(dat(l,:), dat(k,:));
    bf10 = t1smpbf(stat.tstat, numel(dat(l,:)));
    title(sprintf('t=%.3g, p=%.4g, bf10=%.3g', stat.tstat, p, bf10));
    if p < 0.05
      set(gca, 'Color', [0.8 1.0 0.8]);
    end
  end
end

end