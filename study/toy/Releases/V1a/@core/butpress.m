function butpress(obj,func)
%
% BUTPRESS  Setup button press function
%
%    Syntax
%
%       butpress(obj);             % standard redirection
%       butpress(obj,'refresh')    % setup figure refreshment
%       butpress(obj,'CbButPress') % call CbButPress callback
%
%    Example:
%
%       menu(obj,'butpress')       % setup default button press function.
%
%    See also: SHELL CBSETUP CBRESET REFRESH
%
   if (nargin < 2)
      cb = setting('shell.butpress');   % default butpress call
   elseif isempty(func)
      cb = '';
   else
      stack = dbstack;           % get calling stack 
      path = stack(2).file;      % get path of mfile name

      [p,mfile,ext] = fileparts(path);
   
      cb = [mfile,'(arg(gfo,[],''',func,'''));'];
   end
   
   set(gcf,'WindowButtonDownFcn',cb);
   return
