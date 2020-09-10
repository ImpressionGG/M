function out = version(obj)
%
% VERSION   Get version of a SHELL obj
%
%              vs = version(shell);    % get version string
%              version(shell);         % type also release notes
%                                        / known bugs
%
%           Note: 
%              shell/version will directly redirect to chameleon/version
%
%           See also: CHAMELEON CHAMEO SHELL STREAMS DS DRAGON EVO TCB
%
   if (nargout == 0)
      version(chameleon)
   else
      out = version(chameleon);
   end
   return
   
% eof   