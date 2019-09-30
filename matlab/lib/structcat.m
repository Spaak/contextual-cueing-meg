function x = structcat(y, param)
% STRUCTCAT takes a structure y of arbitrary dimensionality Mx...xN, each
% element of which contains a field named <param> of dimensionality
% Px...xK, and returns the data in those fields concatenated into a
% Px...XKxMx...N array.
%
% Author: Eelke Spaak, 2018.

siz1 = size(y);
siz2 = size(y(1).(param));

x = cat(numel(siz2)+1, y.(param));
x = reshape(x, [siz2 siz1]);

end