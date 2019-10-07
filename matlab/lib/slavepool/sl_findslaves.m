function slaves = sl_findslaves()
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

% look for all the little marker files in ~/.matlabslaves
listing = dir('~/.matlabslaves');

slaves = [];
for k = 1:numel(listing)
  if ~strcmp(listing(k).name, '.') && ~strcmp(listing(k).name, '..')
    split = strsplit(listing(k).name, '_');
    if strcmp(split{1}, 'ready')
      slaves(end+1).host = split{2};
      slaves(end).subj_id = str2num(split{3});
      slaves(end).port = 30300 + slaves(end).subj_id;
    end
  end
end

end