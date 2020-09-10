function out = handle(obj,func,cbo)
%
% HANDLE   Get function name which handles menu callbacks. 
%
%    Syntax
%       mfile = handle(obj);
%
%       Without output argument the result of the function will be
%       applied to the object argument:
%
%          handle(obj);          % eval([handle(obj),'(obj);'])
%          handle(obj,func);     % eval([handle(obj),'(obj,func);'])
%          handle(obj,func,cbo); % eval([handle(obj),'(obj,func,cbo);'])
%
%       Handle() will look into the first entry of the get(obj,'menu')
%       Parameter. If this item is a cell array, then the first element
%       of the cell array is the menu handling function. Otherwise by
%       default it is the function menu.
%
%    Example 1:
%       obj = core('myshell');          % create core (type 'myshell')
%       obj = set(obj,'menu',{{'myshell'},'file','play'});
%
%       mfile = handle(obj);            % will return 'myshell'
%       eval([handle(obj),'(obj)']);    % launches: myshell(obj)
%
%    Example 2:
%       obj = core('myshell');          % create shell (format 'myshell')
%       obj = set(obj,'menu',{'file','play'});
%       mfile = handle(obj);            % will return 'menu'
%       eval([handle(obj),'(obj)']);    % launches: menu(obj)
%
%    Example 3:
%       handle(obj,'setup',[])          % callback to setup()
% 
%    Comment
%       The return value of this function will be used by the
%       clone function.
%
%    See also: CORE MENU CLONE
%
   list = get(obj,'menu');
   entry = eval('list{1}','{}');
   mfile = eval('entry{1}','''menu''');
   
   if (nargout > 0)
      if (nargin > 1)
         error('only 1 input arg expected, if out arg is assigned!')
      end
      out = mfile;
   else % nargout == 0
      if (nargin == 1)
         eval([mfile,'(obj);']);
      elseif (nargin == 2)
         eval([mfile,'(obj,func);']);
      elseif (nargin == 3)
         eval([mfile,'(obj,func,cbo);']);
      end
   end
   
   return
   
% eof   