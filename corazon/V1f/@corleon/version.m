function out = version(obj,arg)
%
% VERSION   CORLEON toolbox version / release notes
%
%    Print CORLEON release notes / bug list or get CORLEON version
%
%       vs = version(corleon);        % get CORLEON version string
%       version(corleon);             % type release notes / known bugs
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORLEON
%
%--------------------------------------------------------------------------
%
%
   path = upper(which('corleon/version'));
   idx = max(findstr(path,'\@CORLEON\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0 || nargin > 1)
      clc;  help corleon/version
      s = '----------------------------------------';
      fprintf('%s%s\nCORLEON Toolbox - Version: %s\n%s%s\n',s,s,vers,s,s);
   else
      out = vers;
   end
end   
