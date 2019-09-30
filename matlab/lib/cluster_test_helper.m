function [datobs, datrnd] = cluster_test_helper(dat, nperm)
% CLUSTER_TEST_HELPER is a helper function for doing cluster-corrected
% permutation tests in arbitrary dimensions. The randomizations are
% generated under the assumption that input dat was computed using a paired
% statistic T for which T(a,b) = -T(b,a) holds, where a and b are the data
% under the two paired conditions. (E.g. raw difference would work.)
%
% dat - an NxMx...xZxObs data matrix. The trailing dimension must correspond
% to the unit of observation (e.g., subjects or trials).
%
% nperm - the number of permutations to generate
%
% Returns:
% datobs - NxMx...xZ statistic for observed data, averaged across observations
% datrnd - NxMx...xZxPerm statistic under the null hypothesis
%
% Written by Eelke Spaak, Oxford University, June 2015.

fprintf('generating randomization distribution, assuming dat was generated\n');
fprintf('using a paired test statistic T for which T(a,b) = -T(b,a) holds...\n');

% get data characeristics
siz = size(dat);
sampdim = numel(siz);
nSamp = siz(sampdim);

% the observed statistic: mean across the observed samples
datobs = mean(dat, sampdim);

% initialize space for randomization distribution
siz = size(datobs);
if numel(siz) == 2 && siz(2) == 1
    siz(2) = nperm;
else
    siz(end+1) = nperm;
end
datrnd = zeros(siz);
rnddim = numel(siz);

% create indexing vector, this is necessary to support arbitrary dimensions
% e.g. if indvec = {':', ':', 3} then we can do x(indvec{:}) which results
% in the same as x(:,:,3)
indvec = {};
indvec(1:rnddim) = {':'};
for k = 1:nperm
    if mod(k, round(nperm/10)) == 0
        fprintf('generating permutation %d of %d...\n', k, nperm);
    end
    % copy the data
    tmp = dat;
    
    % randomly flip the sign of ~half the observations
    flipinds = randperm(nSamp, round(nSamp/2));
    indvec{end} = flipinds;
    tmp(indvec{:}) = -tmp(indvec{:});
    
    % store the mean across the surrogate data in the null distribution
    indvec{end} = k;
    datrnd(indvec{:}) = mean(tmp, rnddim); 
end

fprintf('done.\n');

end