function stde = withinstde(X,unbiased)
% computes the within-subjects normalized standard error (Cousineau,
% 2005)
% X: columns are factors, rows are observations.
% unbiased (default = 1) will apply the Morey (2008) correction to obtain
% unbiased estimates.
% Copyright 2013 Eelke Spaak
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