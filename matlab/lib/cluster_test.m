function [h, p, clusterinfo] = cluster_test(datobs, datrnd, tail, alpha,...
    clusteralpha, clusterstat)
% CLUSTER_TEST performs a cluster-corrected test that datobs is higher/lower
% than the distribution as expected under the null hypothesis. The 'null'
% distribution should be pre-computed (manually or using CLUSTER_TEST_HELPER)
% and entered as an argument into this function.
%
% datobs - observed data MxNx...xZ
% datrnd - null distribution, MxNx...xZxPerm
% tail - whether to test datobs < null (tail==-1), datobs > null (tail==1)
% or datobs <> null (tail==0, default).
% alpha - critical level (default 0.05)
% clusteralpha - nonparametric threshold for cluster candidates (default
% 0.05)
% clusterstat - how to combine statistics in cluster candidates (can be
% 'sum' (default) or 'size')
%
% Returns:
% h - MxNx...xZ logical matrix indicating where significant clusters were
% found (though note that formally speaking the test concerns the data as a
% whole, so the interpretation of the location of clusters within h should
% be done with caution).
% p - MxNx...xZ matrix of p-values associated with clusters.
% clusterinfo - struct with extra cluster info, e.g. indices
%
% Written by Eelke Spaak, Oxford University, June 2015.
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

%% defaults handling

if nargin < 3 || isempty(tail)
    tail = 0;
end

if nargin < 4 || isempty(alpha)
    alpha = 0.05;
end

if nargin < 5 || isempty(clusteralpha)
    clusteralpha = 0.05;
end

if nargin < 6 || isempty(clusterstat)
    clusterstat = 'sum';
end

%% some bookkeeping

% which dimension contains the randomizations
rndsiz = size(datrnd);
rnddim = numel(rndsiz);
numrnd = rndsiz(rnddim);

if ~( all(size(datobs) == rndsiz(1:end-1)) ||...
        isvector(datobs) && numel(datobs) == rndsiz(1) )
    error('datobs and datrnd are not of compatible dimensionality');
end

% handle the different options for computing cluster characteristics
cluster_stat_sum = strcmp(clusterstat, 'sum');
cluster_stat_size = strcmp(clusterstat, 'size');
if ~cluster_stat_sum && ~cluster_stat_size
    error('unsupported clusterstat');
end

%% actual cluster test

% determine thresholds for cluster candidates
cluster_threshold_neg = quantile(datrnd, clusteralpha, rnddim);
cluster_threshold_pos = quantile(datrnd, 1-clusteralpha, rnddim);

% cluster candidates for observed data
[clus_observed_pos, clus_observed_neg, pos_inds, neg_inds] =...
    find_and_characterize_clusters(datobs);

% maximum and minimum cluster statistics for random data
null_pos = nan(numrnd, 1);
null_neg = nan(numrnd, 1);
% create indexing vector, this is necessary to support arbitrary dimensions
% e.g. if indvec = {':', ':', 3} then we can do x(indvec{:}) which results
% in the same as x(:,:,3)
indvec(1:rnddim) = {':'};
for k = 1:numrnd
    if mod(k, round(numrnd/10)) == 0
        fprintf('processing permutation %d of %d...\n', k, numrnd);
    end
    
    indvec{rnddim} = k;
    [clus_rnd_pos, clus_rnd_neg] = find_and_characterize_clusters(...
        datrnd(indvec{:}));
    if ~isempty(clus_rnd_pos)
        null_pos(k) = max(clus_rnd_pos);
    end
    if ~isempty(clus_rnd_neg)
        null_neg(k) = min(clus_rnd_neg);
    end
end

null_pos = null_pos(~isnan(null_pos));
null_neg = null_neg(~isnan(null_neg));

% sort the two null distributions, pos in descending, neg in ascending
% order; then we can just find the first value exceeding the critical alpha
% level and convert to p-value
null_pos = sort(null_pos, 'descend');
null_neg = sort(null_neg, 'ascend');

% compare observed clusters to max/min random clusters to obtain p-value
clus_p_pos = ones(size(clus_observed_pos));
for k = 1:numel(clus_observed_pos)
    ind = find(clus_observed_pos(k) > null_pos, 1);
    if ~isempty(ind)
        clus_p_pos(k) = ind/numel(null_pos);
    end
end
clus_p_neg = ones(size(clus_observed_neg));
for k = 1:numel(clus_observed_neg)
    ind = find(clus_observed_neg(k) < null_neg, 1);
    if ~isempty(ind)
        clus_p_neg(k) = ind/numel(null_neg);
    end
end

%% post-processing of output

% return some additional info about the clusters, if requested
if nargout > 2
    clusterinfo = [];
end

% convenient matrix of p-values
p = ones(size(datobs));
if tail >= 0
    for k = 1:numel(clus_p_pos)
        p(pos_inds{k}) = clus_p_pos(k);
        
        if nargout > 2
            clusterinfo.pos_clusters(k).clusterstat = clus_observed_pos(k);
            clusterinfo.pos_clusters(k).p = clus_p_pos(k);
            clusterinfo.pos_clusters(k).inds = false(size(datobs));
            clusterinfo.pos_clusters(k).inds(pos_inds{k}) = 1;
        end
    end
end
if tail <= 0
    for k = 1:numel(clus_p_neg)
        if clus_p_neg(k) < p(neg_inds{k}(1))
            p(neg_inds{k}) = clus_p_neg(k);
        end
        
        if nargout > 2
            clusterinfo.pos_clusters(k).clusterstat = clus_observed_neg(k);
            clusterinfo.neg_clusters(k).p = clus_p_neg(k);
            clusterinfo.neg_clusters(k).inds = false(size(datobs));
            clusterinfo.neg_clusters(k).inds(neg_inds{k}) = 1;
        end
    end
end
if tail == 0
    % for two-tailed, multiply p-values by 2
    % but since p must be <= 1, truncate at 1 if this takes it above 1
    p = min(1, p .* 2);
end

% result of the hypothesis test
h = p < alpha;

%% nested helper functions

% helper function that takes data (either random or observed), determines
% cluster candidates, and returns the aggregate cluster statistic for each
% cluster candidate
function [clus_stats_pos, clus_stats_neg, pos_inds, neg_inds] = ...
    find_and_characterize_clusters(dat)
    if tail >= 0
        [clus_stats_pos, pos_inds] = compute_cluster_stats(dat,...
            dat > cluster_threshold_pos);
    end
    if tail <= 0
        [clus_stats_neg, neg_inds] = compute_cluster_stats(dat,...
            dat < cluster_threshold_neg);
    end

    if tail == -1
        clus_stats_pos = [];
        pos_inds = [];
    elseif tail == 1
        clus_stats_neg = [];
        neg_inds = [];
    end
end

function [clus_stats, inds] = compute_cluster_stats(dat, clus_cand)
    % label the binary masks using image processing toolbox and compute the
    % cluster statistics for each cluster candidate
    connected = bwconncomp(clus_cand);
    inds = connected.PixelIdxList;
    if cluster_stat_sum
        % ignore 'clusters' consisting of just one pixel, these result
        % in a massive performance overhead and can safely be ignored
        % (since we apply the same processing to the observed and
        % random data sets)
        lens = cellfun(@numel, inds);
        inds = inds(lens > 1);
        clus_stats = zeros(numel(inds),1);
        for l = 1:numel(inds)
            clus_stats(l) = sum(dat(inds{l}));
        end
    elseif cluster_stat_size
        clus_stats = zeros(numel(inds),1);
        for l = 1:connected.NumObjects
            clus_stats(l) = numel(connected.PixelIdxList{l});
        end
    end
end

end