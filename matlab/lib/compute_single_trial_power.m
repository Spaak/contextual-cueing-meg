function source_pow = compute_single_trial_power(source, freq)

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