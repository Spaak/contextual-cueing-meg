function run_analyses_sensor_tfr(run_mode, results_dir, subjects, all_ids)
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

%% time-frequency analysis for each individual participant

allfreqs = run_individual_jobs('job_sensor_tfr', 'freqs', subjects, all_ids, run_mode);

% make it subject X condition (old/new)
allfreqs = cat(1, allfreqs{:});


%% cluster-based permutation test Old vs New

cfg = [];
cfg.method = 'template';
cfg.template = 'ctf275_neighb.mat';
neighbours = ft_prepare_neighbours(cfg);

cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.clusterthreshold = 'parametric';
cfg.clusterstatistic = 'maxsum';
cfg.numrandomization = 1000;
cfg.correctm = 'cluster';
cfg.neighbours = neighbours;
cfg.minnbchan = 2;
cfg.tail = 0;
cfg.clustertail = 0;

nobs = size(allfreqs,1);
cfg.design = [
  ones(1,nobs)*1 ones(1,nobs)*2
  1:nobs 1:nobs
];
cfg.ivar = 1;
cfg.uvar = 2;

stat = ft_freqstatistics(cfg, allfreqs{:,1}, allfreqs{:,2});

% The test is done across the entire time/frequency plane, which will also
% yield some response-related clusters. These are uninteresting, we want to
% plot the sensory-related (early) effect only. Since the cluster test is
% inherently stochastic, we need to figure out which cluster (usually #1 or
% #2) the sensory theta effect belongs to.
plot_negclus = [-1];
tmp = stat.posclusterslabelmat(:,stat.freq==3,stat.time==0.25);
plot_posclus = [mode(tmp(tmp>0))];
mytfrclusterplot(stat, 0.05, 1, plot_posclus, plot_negclus);

f = gcf();
% save figure
print('-r150', '-fillpage', f, fullfile(results_dir, '010-sensor-tfr-cluster-fig3a.pdf'), '-dpdf');
close(f);


%% also do evoked time-frequency analysis to test whether effect is evoked or not

allfreqs_evoked = run_individual_jobs('job_sensor_evoked_tfr', 'freqs', subjects, all_ids, run_mode);
allfreqs_evoked = cat(1, allfreqs_evoked{:});

cfg.latency = [0 0.5];
cfg.avgovertime = 'no';

cfg.frequency = [1 7];
cfg.avgoverfreq = 'no';

stat_evoked = ft_freqstatistics(cfg, allfreqs_evoked{:,1}, allfreqs_evoked{:,2});


%% save statistics results

Tests = {'Cluster-based permutation test Old vs New TFR', 'Control test with evoked TFR'}';
Pval = [min(stat.prob(:)); min(stat_evoked.prob(:))];

T = table(Tests, Pval);
f = fopen(fullfile(results_dir, '011-sensor-tfr-cluster-tests.txt'), 'wt');
% disp(T) gives nice textual summary, which we want to put in a file, but
% wihtout the <html> tags
fprintf(f, regexprep(evalc('disp(T)'), '<.*?>', ''));
fclose(f);


end