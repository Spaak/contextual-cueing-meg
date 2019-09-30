function slaves = sl_findslaves()

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