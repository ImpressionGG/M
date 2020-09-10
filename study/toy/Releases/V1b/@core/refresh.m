function [out1,out2] = refresh(obj,callback,callargs)
%
% REFRESH    Refresh figure
%
%    Invoke refreshment callback which has been prepared for figure
%    refreshment. This function can also be used for handling key-press
%    events.
%
%    Refresh can be called with 1,2 or 3 args
%
%       refresh(obj)                          % invoke refreshing callback
%       [callback,callargs] = refresh(obj)    % return settings (no invoke)
%
%       refresh(obj,{'menu','Home'});         % setup refreshing callback 
%       refresh(obj,'menu(obj)',{'Home'});    % same as above
%
%       refresh(obj,callback,callargs)        % setup refreshing callback
%       obj = refresh(obj,cback,cargs)        % set options
%
%    Setup current function as refresh function
%
%       refresh(obj,inf);         % setup current function for refresh
%       refresh(obj,{});          % disable refresh callback
%
%    Typical examples for callback setup:
%
%       refresh(gfo,{});                      % clear refresh function
%       refresh(gfo,{'datainfo'});            % setup: datainfo(obj)
%       refresh(gfo,{'analyse','Execute','Overview'});
%
%    Exotic examples for callback setup:
%
%       refresh(gfo,'datainfo(obj)',{});
%       refresh(gfo,'compinfo(obj)',{});
%       refresh(gfo,'analyse(obj,''CbExecute'');','CbOverview');
%       refresh(gfo,'analyse(obj)',{'CbExcecute','CbOverview'});
%
%    See also: CORE MENU CLICK
%

     % if the calling syntax has two output args we just retrieve the
     % shell settings
     
   if (nargout == 2)
      out1 = setting('shell.callback');
      out2 = setting('shell.callargs');
      return
   end
   
     % previously we got cmd and callarg from the settings. This does not 
     % work if we launch an object from M-file. Thus we changed the code
     % to get this information from the options

   if (nargin == 1)
      callback = option(obj,'shell.callback');
      callargs = option(obj,'shell.callargs');

      %obj = arg(obj,[],callargs);
      obj = set(obj,'arg',callargs);
      if isstr(callback)
         if option(obj,'shell.debug')
            eval(callback);
         else
            try
               eval(callback);
            catch
               fprintf(['*** Could not execute callback: ',callback,'\n']);
               callargs
            end
         end
      end
      return
   end
   
% Handle the obsolete case with 2 callargs

   if (nargin == 2)
      arg2 = callback;
      if isempty(arg2)                   % deactivate refresh callback
         SetupRefresh(obj,'','');        % deactivate refresh callback
      elseif iscell(arg2)                % set up refreshing callback
         if length(arg2) == 0
            SetupRefresh(obj,'','');     % deactivate refresh callback
         end
         func = arg2{1};
         callargs = either(arg2(2:end),{});
         if ~isa(func,'char')
            func
            error('string expected for callback function (1st element of arg2)!');
         end
         callback = [func,'(obj);'];
         SetupRefresh(obj,callback,callargs);
      elseif isinf(arg2)            % set current callback for refresh
         %SetupRefresh(obj,inf);
         [func,manager] = caller(obj,1);
         callback = [manager,'(obj);'];
         callargs = cons(func,arg(obj,0));    % callback argument
         SetupRefresh(obj,callback,callargs);
      else
         error('Bad calling syntax with two input args!');
      end
   end

% A call with 3 args will setup the refresh callback and args

   if (nargin == 3)
      if (nargout == 0)
         SetupRefresh(obj,callback,callargs);
      else
         out1 = SetupRefresh(obj,callback,callargs);
      end
      return
   end
   
   return
end

%==========================================================================
% Setup Refresh Settings
%==========================================================================

function obj = SetupRefresh(obj,callback,callargs)
%
% SETUP-REFRESH   Setup a callback for figure refreshment. 
%
%    There are two possibilities to call SetupRefresh():
%
%    1) Define current function as figure refreshment callback.
%    In this mode arg2 is a non-character string, and SetupRefresh()
%    will determine the calling function in order to use it as
%    the figure refreshment callback
%
%       SetupRefresh(obj)      % setup figure refreshment callback
%       SetupRefresh(obj,inf)  % setup figure refreshment callback
%
%    2) Define a comand character string as the figure refreshment 
%    callback. In this mode arg2 is a character string. An optional
%    3rd argument will serve as the calling args. If the third arg
%    is not provided the call args will be implicitely fetched from
%    arg(obj).
%
%       SetupRefresh(obj,callback,callargs)  % setup calling args
%       SetupRefresh(obj,callback,arg(obj))  % setup callback & call args
%       SetupRefresh(obj,callback)           % same as above 
%
%    Example 1 (current function)
%
%       function myhandler(obj) % just a callback handler
%             :
%          SetupRefresh(obj);        % use myhandler() as refreshment cb.
%          return
%
%    Example 2 (command character string)
%
%       core play               % open a CORE shell for playing arround
%       command = 'plot(0:0.1:10,sin(0:0.1::10),''r'');';
%       SetupRefresh(gfo,command);   % use command as refreshment cb
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
