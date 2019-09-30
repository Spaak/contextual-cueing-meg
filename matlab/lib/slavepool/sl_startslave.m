function sl_startslave(subj_id)

% load the data
 data = load_clean_data(subj_id);
% [subjects,all_ids,rootdir] = datainfo();
% load(fullfile(subjects(subj_id).dir, 'source-parcellated-raw-v4.mat'),...
%   'data');

% open the server socket
srvsock = mslisten(30300 + subj_id);

% load the keypair
import javax.crypto.Cipher;
load('slavekeypair', 'keyPair');
cipher = Cipher.getInstance('RSA');
cipher.init(Cipher.DECRYPT_MODE, keyPair.getPublic());

% write a little marker file indicating our hostname and that we're ready
% to accept instructions
system(sprintf('touch ~/.matlabslaves/ready_`hostname`_%02d', subj_id));

while true
  fprintf('waiting for client connection...\n');
  sock = msaccept(srvsock);
  fprintf('accepted client connection\n');
  command = msrecv(sock);
  
  % decrypt the command
  command = cipher.doFinal(command);
  command = char(typecast(command, 'uint16'))';
  try
    eval(command);
  catch err
    fprintf('an error occurred:\n');
    disp(err);
  end
  msclose(sock);
end

end