function data = load_clean_data(subj_id)
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

[subjects,all_ids,rootdir] = datainfo();

tstart = tic();

% load initial-cleaned data
load(fullfile(subjects(subj_id).dir, 'preproc-data-artreject-400hz.mat'), 'data');

% load ica decomposition weights and bad components
load(fullfile(subjects(subj_id).dir, 'preproc-ica-weights.mat'), 'unmixing', 'topolabel');
load(fullfile(subjects(subj_id).dir, 'preproc-ica-badcomps.mat'), 'badcomps');

% apply ica demixing
cfg = [];
cfg.demean = 'no';
cfg.method = 'predefined unmixing matrix';
cfg.unmixing = unmixing;
cfg.topolabel = topolabel;
data = ft_componentanalysis(cfg, data);

% reject bad components
cfg = [];
cfg.demean = 'no';
cfg.component = badcomps;
data = ft_rejectcomponent(cfg, data);

fprintf('Loading and cleaning data took %.1f seconds.\n', toc(tstart));

end