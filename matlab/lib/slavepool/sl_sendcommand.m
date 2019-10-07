function sl_sendcommand(host, port, cmd)
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