function [subjects, all_ids, rootdir] = datainfo(rootdir)
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

persistent cache;

if ~isempty(cache)
  subjects = cache.subjects;
  all_ids = cache.all_ids;
  rootdir = cache.rootdir;
  return;
end

if nargin < 1 || isempty(rootdir)
  if ispc()
    rootdir = 'P:\3018029.07\';
  else
    rootdir = '/project/3018029.07/';
  end
end

% note: originally this file also contained references to individual
% participants' MRI and Polhemus (headshape) data; these are stripped for
% privacy reasons.

subjects = [];

subjects(1).id = 1;
subjects(1).rawmeg = fullfile(rootdir, 'raw', 'subj01_3018029.07_20180601_01.ds');
subjects(1).behav = fullfile(rootdir, 'behavioural', 'subj01_sess01_2018-06-01T08-52-24.mat');

subjects(2).id = 2;
subjects(2).rawmeg = fullfile(rootdir, 'raw', 'subj02_3018029.07_20180418_01.ds');
subjects(2).behav = fullfile(rootdir, 'behavioural', 'subj02_sess01_2018-04-18T13-06-05.mat');

subjects(3).id = 3;
subjects(3).rawmeg = fullfile(rootdir, 'raw', 'subj03_3018029.07_20180420_01.ds');
subjects(3).behav = fullfile(rootdir, 'behavioural', 'subj03_sess01_2018-04-20T13-14-28.mat');

subjects(4).id = 4;
subjects(4).rawmeg = fullfile(rootdir, 'raw', 'subj04_3018029.07_20180420_01.ds');
subjects(4).behav = fullfile(rootdir, 'behavioural', 'subj04_sess01_2018-04-20T15-06-55.mat');

subjects(5).id = 5;
subjects(5).rawmeg = fullfile(rootdir, 'raw', 'subj05_3018029.07_20180423_01.ds');
subjects(5).behav = fullfile(rootdir, 'behavioural', 'subj05_sess01_2018-04-23T09-56-47.mat');

subjects(6).id = 6;
subjects(6).rawmeg = fullfile(rootdir, 'raw', 'subj06_3018029.07_20180423_01.ds');
subjects(6).behav = fullfile(rootdir, 'behavioural', 'subj06_sess01_2018-04-23T11-56-48.mat');

subjects(7).id = 7;
subjects(7).rawmeg = fullfile(rootdir, 'raw', 'subj07_3018029.07_20180423_01.ds');
subjects(7).behav = fullfile(rootdir, 'behavioural', 'subj07_sess01_2018-04-23T13-05-27.mat');

subjects(8).id = 8;
subjects(8).rawmeg = fullfile(rootdir, 'raw', 'subj08_3010829.07_20180423_01.ds');
subjects(8).behav = fullfile(rootdir, 'behavioural', 'subj08_sess01_2018-04-23T14-50-42.mat');

subjects(9).id = 9;
subjects(9).rawmeg = fullfile(rootdir, 'raw', 'subj09_3018029.07_20180425_01.ds');
subjects(9).behav = fullfile(rootdir, 'behavioural', 'subj09_sess01_2018-04-25T11-50-02.mat');

subjects(10).id = 10;
subjects(10).rawmeg = fullfile(rootdir, 'raw', 'subj10_3018029.07_20180430_01.ds');
subjects(10).behav = fullfile(rootdir, 'behavioural', 'subj10_sess01_2018-04-30T11-31-50.mat');

subjects(11).id = 11;
subjects(11).rawmeg = fullfile(rootdir, 'raw', 'subj11_3018029.07_20180430_01.ds');
subjects(11).behav = fullfile(rootdir, 'behavioural', 'subj11_sess01_2018-04-30T12-59-38.mat');

subjects(12).id = 12;
subjects(12).rawmeg = fullfile(rootdir, 'raw', 'subj12_3018029.07_20180430_01.ds');
subjects(12).behav = fullfile(rootdir, 'behavioural', 'subj12_sess01_2018-04-30T14-34-55.mat');

subjects(13).id = 13;
subjects(13).rawmeg = fullfile(rootdir, 'raw', 'subj13_3018029.07_20180430_01.ds');
subjects(13).behav = fullfile(rootdir, 'behavioural', 'subj13_sess01_2018-04-30T15-59-22.mat');

subjects(14).id = 14;
subjects(14).rawmeg = fullfile(rootdir, 'raw', 'subj14_3018029.07_20180501_01.ds');
subjects(14).behav = fullfile(rootdir, 'behavioural', 'subj14_sess01_2018-05-01T08-30-56.mat');

subjects(15).id = 15;
subjects(15).rawmeg = fullfile(rootdir, 'raw', 'subj15_3018029.07_20180507_01.ds');
subjects(15).behav = fullfile(rootdir, 'behavioural', 'subj15_sess01_2018-05-07T09-51-18.mat');

subjects(16).id = 16;
subjects(16).rawmeg = fullfile(rootdir, 'raw', 'subj16_3018029.07_20180507_01.ds');
subjects(16).behav = fullfile(rootdir, 'behavioural', 'subj16_sess01_2018-05-07T12-08-48.mat');

subjects(17).id = 17;
subjects(17).rawmeg = fullfile(rootdir, 'raw', 'subj17_3018029.07_20180507_01.ds');
subjects(17).behav = fullfile(rootdir, 'behavioural', 'subj17_sess01_2018-05-07T13-27-06.mat');

subjects(18).id = 18;
subjects(18).rawmeg = fullfile(rootdir, 'raw', 'subj18_3018029.07_20180507_01.ds');
subjects(18).behav = fullfile(rootdir, 'behavioural', 'subj18_sess01_2018-05-07T14-36-21.mat');

subjects(19).id = 19;
subjects(19).rawmeg = fullfile(rootdir, 'raw', 'subj19_3018029.07_20180518_01.ds');
subjects(19).behav = fullfile(rootdir, 'behavioural', 'subj19_sess01_2018-05-18T14-31-07.mat');

subjects(20).id = 20;
subjects(20).rawmeg = fullfile(rootdir, 'raw', 'subj20_3018029.07_20180514_01.ds');
subjects(20).behav = fullfile(rootdir, 'behavioural', 'subj20_sess01_2018-05-14T09-55-27.mat');

subjects(21).id = 21;
subjects(21).rawmeg = fullfile(rootdir, 'raw', 'subj21_3018029.07_20180514_01.ds');
subjects(21).behav = fullfile(rootdir, 'behavioural', 'subj21_sess01_2018-05-14T12-57-07.mat');

subjects(22).id = 22;
subjects(22).rawmeg = fullfile(rootdir, 'raw', 'subj22_3018029.07_20180514_01.ds');
subjects(22).behav = fullfile(rootdir, 'behavioural', 'subj22_sess01_2018-05-14T14-08-01.mat');

subjects(23).id = 23;
subjects(23).rawmeg = fullfile(rootdir, 'raw', 'subj23_3018029.07_20180518_01.ds');
subjects(23).behav = fullfile(rootdir, 'behavioural', 'subj23_sess01_2018-05-18T09-00-34.mat');

subjects(24).id = 24;
subjects(24).rawmeg = fullfile(rootdir, 'raw', 'subj24_3018029.07_20180523_01.ds');
subjects(24).behav = fullfile(rootdir, 'behavioural', 'subj24_sess01_2018-05-23T08-26-33.mat');

% note: no subject 25

subjects(26).id = 26;
subjects(26).rawmeg = fullfile(rootdir, 'raw', 'subj26_3018029.07_20180524_01.ds');
subjects(26).behav = fullfile(rootdir, 'behavioural', 'subj26_sess01_2018-05-24T17-22-50.mat');

subjects(27).id = 27;
subjects(27).rawmeg = fullfile(rootdir, 'raw', 'subj27_3018029.07_20180525_01.ds');
subjects(27).behav = fullfile(rootdir, 'behavioural', 'subj27_sess01_2018-05-25T09-29-17.mat');

subjects(28).id = 28;
subjects(28).rawmeg = fullfile(rootdir, 'raw', 'subj28_3018029.07_20180525_01.ds');
subjects(28).behav = fullfile(rootdir, 'behavioural', 'subj28_sess01_2018-05-25T12-20-48.mat');

subjects(29).id = 29;
subjects(29).rawmeg = fullfile(rootdir, 'raw', 'subj29_3018029.07_20180528_01.ds');
subjects(29).behav = fullfile(rootdir, 'behavioural', 'subj29_sess01_2018-05-28T10-52-06.mat');

subjects(30).id = 30;
subjects(30).rawmeg = fullfile(rootdir, 'raw', 'subj30_3018029.07_20180528_01.ds');
subjects(30).behav = fullfile(rootdir, 'behavioural', 'subj30_sess01_2018-05-28T12-46-09.mat');

subjects(31).id = 31;
subjects(31).rawmeg = fullfile(rootdir, 'raw', 'subj31_3018029.07_20180626_01.ds');
subjects(31).behav = fullfile(rootdir, 'behavioural', 'subj31_sess01_2018-06-26T10-46-22.mat');

% note: no subject 32

subjects(33).id = 33;
subjects(33).rawmeg = fullfile(rootdir, 'raw', 'subj33_3018029.07_20180626_01.ds');
subjects(33).behav = fullfile(rootdir, 'behavioural', 'subj33_sess01_2018-06-26T11-52-09.mat');

subjects(34).id = 34;
subjects(34).rawmeg = fullfile(rootdir, 'raw', 'subj34_3018029.07_20180604_01.ds');
subjects(34).behav = fullfile(rootdir, 'behavioural', 'subj34_sess01_2018-06-04T12-25-31.mat');

subjects(35).id = 35;
subjects(35).rawmeg = fullfile(rootdir, 'raw', 'subj35_3018029.07_20180604_01.ds');
subjects(35).behav = fullfile(rootdir, 'behavioural', 'subj35_sess01_2018-06-04T13-52-60.mat');

subjects(36).id = 36;
subjects(36).rawmeg = fullfile(rootdir, 'raw', 'subj36_3018029.07_20180519_01.ds');
subjects(36).behav = fullfile(rootdir, 'behavioural', 'subj36_sess01_2018-05-19T11-02-34.mat');

subjects(37).id = 37;
subjects(37).rawmeg = fullfile(rootdir, 'raw', 'subj37_3018029.07_20180519_01.ds');
subjects(37).behav = fullfile(rootdir, 'behavioural', 'subj37_sess01_2018-05-19T12-53-52.mat');

subjects(38).id = 38;
subjects(38).rawmeg = fullfile(rootdir, 'raw', 'subj38_3018029.07_20180519_01.ds');
subjects(38).behav = fullfile(rootdir, 'behavioural', 'subj38_sess01_2018-05-19T13-52-07.mat');

for subj_id = 1:numel(subjects)
  subjects(subj_id).dir = fullfile(rootdir, 'processed', sprintf('subj%02d', subj_id));
end

for subj_id = 1:numel(subjects)
  % ensure consistency in subject IDs
  assert(isempty(subjects(subj_id).id) || subjects(subj_id).id == subj_id);
  assert(isempty(subjects(subj_id).id) || contains(subjects(subj_id).rawmeg, sprintf('subj%02d', subj_id)));
  assert(isempty(subjects(subj_id).id) || contains(subjects(subj_id).behav, sprintf('subj%02d', subj_id)));
%   assert(isempty(subjects(subj_id).id) || contains(subjects(subj_id).polhemus, sprintf('subj%02d', subj_id)));
%   assert(isempty(subjects(subj_id).id) || contains(subjects(subj_id).rawmri, sprintf('subj%02d', subj_id)));

  % make sure files exist
  assert(isempty(subjects(subj_id).id) || exist(subjects(subj_id).rawmeg, 'file'));
  assert(isempty(subjects(subj_id).id) || exist(subjects(subj_id).behav, 'file'));
%   assert(isempty(subjects(subj_id).id) || exist(subjects(subj_id).polhemus, 'file'));
%   assert(isempty(subjects(subj_id).id) || exist(subjects(subj_id).rawmri, 'file'));

  % make subject dir if needed
  warning('off', 'MATLAB:MKDIR:DirectoryExists');
  mkdir(subjects(subj_id).dir);
  warning('on', 'MATLAB:MKDIR:DirectoryExists');
end

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(fullfile(rootdir, 'processed', 'combined'));
warning('on', 'MATLAB:MKDIR:DirectoryExists');

% also return subject IDs that have data
all_ids = 1:numel(subjects);
all_ids(arrayfun(@(x) isempty(x.id), subjects)) = [];

cache = [];
cache.subjects = subjects;
cache.all_ids = all_ids;
cache.rootdir = rootdir;

end
