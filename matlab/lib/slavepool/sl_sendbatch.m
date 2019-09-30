function sl_sendbatch(cmd, all_ids)

if nargin < 2 || isempty(all_ids)
  [~,all_ids,~] = datainfo();
end

slaves = sl_findslaves();
assert(numel(slaves) == numel(all_ids));

% check there is a slave running for every subject ID, just to be sure
found = false(numel(slaves), 1);
for k = 1:numel(all_ids)
  for l = 1:numel(slaves)
    if all_ids(k) == slaves(l).subj_id
      found(k) = 1;
      break;
    end
  end
end
assert(numel(all_ids) == numel(slaves) && all(found));

% execute the command given by cmd with (subj_id, data) as arguments on the
% slaves
% precede that with a 'clear [cmd]' to disable caching
for k = 1:numel(slaves)
  sl_sendcommand(slaves(k).host, slaves(k).port,...
    sprintf('clear %s;', cmd));
  sl_sendcommand(slaves(k).host, slaves(k).port,...
    sprintf('%s(subj_id, data);', cmd));
end

end