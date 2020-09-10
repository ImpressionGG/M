function out = version(obj)
%
% VERSION   Get version of a CORE object class
%
%              vs = version(core);     % get version string
%              version(core);         % type also release notes
%                                        / known bugs
%
%           Note: 
%              shell/version will directly redirect to chameleon/version
%
%           See also: CORE
%
   if (nargout == 0)
      version(core)
   else
      out = version(core);
   end
   return
   
% eof   