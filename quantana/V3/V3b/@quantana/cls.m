function drk = cls(obj,arg1,arg2)
%
% CLS    Clear Screen. Depending on the value setting of 'dark'
%        Either dark or bright background is chosen.
%
%           setting('dark',0);
%           dark = cls(quantana);      % clear screen with bright background
%
%           setting('dark',1);
%           dark = cls(quantana);      % clear screen with dark background
%
%        CLS can be called with more arguments
%
%           Default figure = gcf:
% 
%              cls(quantana)           % figure = gcf, axes off
%              cls(quantana,'on')      % axes visible
%              cls(quantana,'off')     % axes invisible
% 
%           Specified figure = fig:
% 
%              cls(quantana,fig)       % specify figure
%              cls(quantana,fig,'on')  % axes visible
%              cls(quantana,fig,'off') % axes invisible%
%
%       See also: QUANTANA, SMART/CLS, SMART/SETTING
%
   drk = option(obj,'dark');
   if (isempty(drk))
      drk = 0;
   end

   if (nargin >= 3)
      cls(arg1,arg2);    % clear screen
   elseif (nargin == 2)
      cls(arg1);         % clear screen
   else
      cls;               % clear screen
   end

   if (drk)
      dark;
   else
      bright
   end
   return

% eof