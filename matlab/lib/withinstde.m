function stde = withinstde(X,unbiased)
% computes the within-subjects normalized standard error (Cousineau,
% 2005)
% X: columns are factors, rows are observations.
% unbiased (default = 1) will apply the Morey (2008) correction to obtain
% unbiased estimates.
% Copyright 2013 Eelke Spaak

if nargin < 2
  unbiased = 1;
end

subjMeans = nanmean(X,2);
grandMean = nanmean(subjMeans);

Y = bsxfun(@minus, X, subjMeans) + grandMean;

yvar = nanvar(Y);
if unbiased
  yvar = yvar .* (size(X,2)/(size(X,2)-1));
end

stde = sqrt(yvar)./sqrt(size(X,1));