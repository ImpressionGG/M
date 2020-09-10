function clrscr(arg1,arg2)
%
% CLRSCR    Clear screen (without destroying menus)
%
%           Default figure = gcf:
%
%              clrscr            % figure = gcf, axes off
%              clrscr('on')      % axes visible
%              clrscr on         % axes visible
%              clrscr('off')     % axes invisible
%              clrscr off        % axes invisible
%
%           Specified figure = fig:
%
%              clrscr(fig)       % specify figure
%              clrscr(fig,'on')  % axes visible
%              clrscr(fig,'off') % axes invisible
%
%           See also: SMART CLS CLF
%
   fprintf('*** warning: clrscr() will be obsolete in future! use cls() instead!\n');
   
   if (nargin == 0)
      cls;
   elseif (nargin == 1)
      cls(arg1);
   else
      cls(arg1,arg2);
   end
   return

% eof