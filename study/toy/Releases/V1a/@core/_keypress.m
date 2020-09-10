function keypress(obj,func)
%
% KEYPRESS  Setup keypress function
%           This function will be OBSOLETED! Use butpress instead!
%
%              keypress(obj);             % standard redirection
%              keypress(obj,'refresh')    % setup figure refreshment
%              keypress(obj,'CbKeyPress') % call CbKeyPress callback
%
%           Example:
%
%              menu(obj,'keypress')
%
%           to setup default key press function.
%
%           See also: SHELL CBSETUP CBRESET REFRESH
%
   fprintf(['*** warning: function KEYPRESS will be obsoleted in future!',...
            ' Use BUTPRESS instead!\n']);
         
   if (nargin < 2)
      cb = setting('shell.keypress');   % default keypress call
   else
      stack = dbstack;           % get calling stack 
      path = stack(2).file;      % get path of mfile name

      [p,mfile,ext] = fileparts(path);
   
      %cb = [mfile,'(gcfo,''',func,''',gcbo);'];
      %cb = [mfile,'(gfo,''',func,''');'];
      cb = [mfile,'(arg(gfo,''',func,'''));'];
   end
   
   set(gcf,'WindowButtonDownFcn',cb);
   return
