function sl_sendcommand(host, port, cmd)

% load the keypair
import javax.crypto.Cipher;
load('slavekeypair', 'keyPair');
cipher = Cipher.getInstance('RSA');
cipher.init(Cipher.ENCRYPT_MODE, keyPair.getPrivate());

% encrypt the message
plaintextUnicodeVals = uint16(cmd);
plaintextBytes = typecast(plaintextUnicodeVals, 'int8');
cmd = cipher.doFinal(plaintextBytes)';

% connect to slave and send encrypted command
sock = msconnect(host, port);
mssend(sock, cmd);
msclose(sock);

end