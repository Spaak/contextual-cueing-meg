function myqsub(funname, reqstring, varargin)
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

% check if we should distribute across as many nodes as possible
if strcmp(varargin{end}, '-spread')
  noquit = 0;
  dospread = 1;
  varargin = varargin(1:end-1);
elseif strcmp(varargin{end}, '-noquit')
  noquit = 1;
  dospread = 0;
  varargin = varargin(1:end-1);
else
  noquit = 0;
  dospread = 0;
end

nargs = numel(varargin);
njob = numel(varargin{1});

matlabcmd = '/opt/matlab/R2017b/bin/matlab -nodesktop -nosplash';
workingdir = '~/ctxcue/4archiving/matlab';

if dospread
  nodes = torque_getnodes();
  goodcpus = [nodes.cputype] > 10;
  goodload = [nodes.ncpu_free] <= median([nodes.ncpu_free]);
  goodnodes = nodes(goodcpus & goodload);
  goodnodeind = 1;
end

% generate a batch identifier, used in naming the log files
batchid = datestr(datetime(), 'yyyy-mm-ddTHH-MM-SS');
mkdir(sprintf('~/.matlabjobs/%s', batchid));

for k = 1:njob
  args = {};
  for l = 1:nargs
    args{l} = num2str(varargin{l}(k));
  end
  args = join(args, ',');
  
  if dospread
    fullreqstring = sprintf('%s,nodes=%s', reqstring, goodnodes(goodnodeind).hostname);
    goodnodeind = goodnodeind+1;
    if goodnodeind > numel(goodnodes)
      goodnodeind = 1;
    end
  else
    fullreqstring = reqstring;
  end
  
  if noquit
    matlabscript = sprintf('cd %s; set_path(); %s(%s);', workingdir, funname, args{1});
  else
    matlabscript = sprintf('cd %s; set_path(); %s(%s); quit', workingdir, funname, args{1});
  end
  
  % store the output in custom files
  logfile = sprintf('%s/j%s_%s', batchid, args{1}, funname);
  
  qsubcmd = sprintf('qsub -q matlab -l %s -N j%s_%s', fullreqstring, args{1}, funname);
  cmd = sprintf('echo ''stdbuf -oL -eL %s -r "%s" >~/.matlabjobs/%s.out 2>~/.matlabjobs/%s.err'' | %s',...
    matlabcmd, matlabscript, logfile, logfile, qsubcmd);
  
  %fprintf([cmd '\n']);
  [status, result] = system(cmd);
  if status
    error(result);
  end
end

end