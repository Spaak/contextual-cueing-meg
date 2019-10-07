function source_pow = compute_single_trial_power(source, freq)
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

% source has filters computed using average cross-spectral density over
% full epoch, now apply the filters to get time-resolved source power
npos = sum(source.inside);
ntim = numel(freq.time);
nfreq = numel(freq.freq);
nrpttap = size(freq.fourierspctrm, 1);
assert(nfreq==1);

fullfilt = cat(1, source.avg.filter{source.inside});
source_fourier = mtimesx(fullfilt, freq.fourierspctrm, 'T'); % note: non-conjugate transpose!
% source_fourier is now pos X rpttap X freq==1 X time

source_fourier = reshape(source_fourier, [npos nrpttap ntim]); % note: don't squeeze(); npos could be 1
ntap = freq.cumtapcnt(1);
nrpt = numel(freq.cumtapcnt);
assert(all(freq.cumtapcnt==ntap));
pow = zeros(npos, nrpt, ntim);
for k = 1:ntap
  pow = pow + abs(source_fourier(:,k:ntap:end,:)).^2;
end
pow = pow ./ ntap;

source_pow = [];
source_pow.pos = source.pos(source.inside,:);
source_pow.inside = true(npos,1);
source_pow.pow = pow;
source_pow.time = freq.time;
source_pow.dimord = 'pos_rpt_time';

end