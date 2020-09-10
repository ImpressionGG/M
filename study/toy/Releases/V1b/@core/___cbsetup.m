function obj = cbsetup(obj,callback,callargs)
%
% CBSETUP   Setup a callback for figure refreshment. 
%
%    There are two possibilities to call cbsetup():
%
%    1) Define current function as figure refreshment callback.
%    In this mode arg2 is a non-character string, and cbsetup()
%    will determine the calling function in order to use it as
%    the figure refreshment callback
%
%       cbsetup(obj)      % setup figure refreshment callback
%       cbsetup(obj,inf)  % setup figure refreshment callback
%
%    2) Define a comand character string as the figure refreshment 
%    callback. In this mode arg2 is a character string. An optional
%    3rd argument will serve as the calling args. If the third arg
%    is not provided the call args will be implicitely fetched from
%    arg(obj).
%
%       cbsetup(obj,callback,callargs)  % setup calling args
%       cbsetup(obj,callback,arg(obj))  % setup callback & call args
%       cbsetup(obj,callback)           % same as above 
%
%    Example 1 (current function)
%
%       function myhandler(obj) % just a callback handler
%             :
%          cbsetup(obj);        % use myhandler() as refreshment cb.
%          return
%
%    Example 2 (command character string)
%
%       core play               % open a CORE shell for playing arround
%       command = 'plot(0:0.1:10,sin(0:0.1::10),''r'');';
%       cbsetup(gfo,command);   % use command as refreshment cb
%       refresh(gfo);           % execute previously defined calback
%
%    See also: CORE, CBRESET, REFRESH, PLOTINFO, TUTORIAL
%
   if (nargin == 2)
      if isinf(callback)
         [func,manager] = caller(obj,2);
         callback = [manager,'(obj);'];
         callargs = cons(func,arg(obj,0));    % callback argument
      else
         callargs = arg(obj,0);               % callback argument list
      end
   elseif (nargin == 3)
      %cb = callback;            % setup string callback (empty cbo)
   else
      [func,manager] = caller(obj,1);
      callback = [manager,'(obj);'];
      %callargs = cons(func,args(obj));   % callback argument
      callargs = cons(func,arg(obj,0));   % callback argument
   end
   
   setting('shell.callback',callback);
   setting('shell.callargs',callargs);    % added in V2g, modified in V3f
   
   obj = option(obj,'shell.callback',callback);
   obj = option(obj,'shell.callargs',callargs);
   
   plotinfo(obj,[]);          % reset plot info
   return
end
