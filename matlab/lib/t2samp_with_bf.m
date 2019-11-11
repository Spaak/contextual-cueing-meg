function [t,df,p,bf10] = t2samp_with_bf(dat1, dat2)

[~,p,~,stat] = ttest2(dat1, dat2);
t = stat.tstat;
df = numel(dat1) + numel(dat2) - 2;
bf10 = t2smpbf(t, numel(dat1), numel(dat2));

end