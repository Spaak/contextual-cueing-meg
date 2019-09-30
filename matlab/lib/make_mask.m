function mask = make_mask(dat, thr)
% This function generates an opacity-ramping mask with a decent plateau and
% nice ramp-on/ramp-off. Useful for presenting e.g. t-maps thresholded at
% some % of maximum.

if nargin < 2
  thr = [0.5 0.8];
end

% if data contains negatives, ensure strongly negative values are given as
% much opacity as strongly positive ones
dat = abs(dat);

mask = zeros(size(dat));

thr = max(dat) .* thr;

% everything above thr(2) is fully opaque
mask(dat > thr(2)) = 1;

% in between thr(1) and thr(2): ramp up nicely
inds = dat > thr(1) & dat < thr(2);
x = dat(inds);

% scale between 0 and 1
x = (x-min(x)) ./ (max(x)-min(x));

% make sigmoidal
beta = 2;
x = 1 ./ (1 + (x./(1-x)).^-beta);

mask(inds) = x;

end