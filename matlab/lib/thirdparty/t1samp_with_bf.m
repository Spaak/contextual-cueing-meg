function [t,df,p,bf10] = t1samp_with_bf(dat, varargin)

if numel(varargin) == 1
  [t,df,p,bf10] = t1samp_with_bf(dat-varargin{1});
  return;
end

[~,p,~,stat] = ttest(dat);
t = stat.tstat;
df = numel(dat)-1;
bf10 = t1smpbf(t, numel(dat));

end