function out = launch(obj,func)
%
% LAUNCH   Launch shell of a CORE object or get launch function name
%
%    Syntax
%       launch(obj);             % launch menu shell of an object
%       func = launch(obj);      % get menu launch function name
%       obj = launch(obj,func)   % set launch function
%
%       Without output argument the result of the function will be
%       applied to the object argument:
%
%          launch(obj);          % eval([launch(obj),'(obj);'])
%
%       LAUNCH will look to option(obj,'shell.launch') for a proper launch
%       function. If this item is empty the menu handling function will be
%       used by default.. Otherwise by
%
%    Example 1:
%       obj = core('myshell');          % create core (type 'myshell')
%       obj = option(obj,'shell.launch','myshell');
%
%       func = launch(obj);             % will return 'myshell'
%       eval([launch(obj),'(obj)']);    % launches: myshell(obj)
%
%    Example 3:                         % launch menu shell
%       launch(obj);                    % => eval([launch(obj),'(obj)']);
% 
%    Comment
%       The return value of this function will be used by both the OPEN 
%       and CLONE function.
%
%    See also: CORE MENU OPEN CLONE
%
   if (nargin == 1)
      func = either(option(obj,'shell.launch'),'menu');

      if (nargout == 0)
         cmd = [func,'(obj,'''');'];
         eval(cmd);
      else % nargout > 0
         out = func;
      end
   elseif (nargin == 2)   % set launch function
      if ~ischar(func)
         func
         error('launch function (arg2) must be character string!');
      end
      out = option(obj,'shell.launch',func); 
   else
      error('1 or 2 input args expected!');
   end
   
   return
end   
