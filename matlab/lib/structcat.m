function x = structcat(y, param)
% STRUCTCAT takes a structure y of arbitrary dimensionality Mx...xN, each
% element of which contains a field named <param> of dimensionality
% Px...xK, and returns the data in those fields concatenated into a
% Px...XKxMx...N array.
%
% Author: Eelke Spaak, 2018.
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

siz1 = size(y);
siz2 = size(y(1).(param));

x = cat(numel(siz2)+1, y.(param));
x = reshape(x, [siz2 siz1]);

end