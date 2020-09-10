function cbreset(obj)
%
% CBRESET    Reset refreshment callback
%
%               cbreset    % reset refreshment callback
%
%            All further calls to refreshed() will be ignored
%            until reactivation by cbsetup()
%
%            See also: SHELL MENU REFRESH CBSETUP
%
   setting('shell.callback','');   % reset to non-action
   plotinfo(obj,[]);               % reset plot info
   return
   
%eof   
