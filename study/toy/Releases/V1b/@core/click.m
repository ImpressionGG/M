function click(obj,func)
%
% CLICK  Setup button click callback function
%
%    Syntax
%
%       click(obj);                % standard redirection
%       click(obj,'refresh')       % setup figure refreshment
%       click(obj,'Click')         % call Click callback
%
%    Example:
%
%       menu(obj,'Click')          % run default button click callback
%
%    See also: CORE MENU REFRESH
%
   if (nargin < 2)
      cb = setting('shell.click'); % default butpress call
   elseif isempty(func)
      cb = '';
   else
      stack = dbstack;             % get calling stack 
      path = stack(2).file;        % get path of mfile name

      [p,mfile,ext] = fileparts(path);
      [~,manager] = caller(obj,1);
   
      cb = [manager,'(set(gfo,''arg'',''',func,'''));'];
   end
   
   set(gcf,'WindowButtonDownFcn',cb);
   return
