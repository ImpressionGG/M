function invoke(obj)
%
% INVOKE   Overloaded TOY method to invoke a callback function
%
%    Invoke a callback function via a package handler. Control needs to
%    be directed to the particular handler given by user data
%
%       invoke(obj);
%
%    Speciality: invoke must set the 'task' parameter of an object
%    with setting('view.task');
%
%    See also: TOY, MENU, CALLBACK, ARG, DISPATCH
%
   if isempty(get(obj,'task'))                      % @@@ this is special!
      top = setting('view.topic');                  % @@@ this is special!
      task = setting('view.task');                  % @@@ this is special!
      obj = topic(obj,top,task);                    % @@@ this is special!
   end                                              % @@@ this is special!
   
   [cmd,obs,list,func] = dispatch(obj);

   if match(func,{'Refresh','Terminate','Ignore'})
      eval(cmd);
   else
      Execute(obj);
   end
   return
end

%==========================================================================
% Execute
%==========================================================================

function Execute(obj,handler)
%
% EXECUTE   Execute a callback
%
   if (nargin < 2)
      handler = caller(obj,2);
   end
   
      % now setup refresh function call properly
   
   callback = [handler,'(obj);'];
   callargs = cons(mfilename,arg(obj,0));
   cbsetup(obj,callback,callargs); 
   butpress(obj,'Terminate');

   clc;
   profiler([]);

   busy;
   cmd = [handler,'(obj);'];
   eval(cmd);
   ready;

   butpress(obj,'Refresh')

   if (option(obj,'profiler'))
      profiler; 
   end
   return
end

%==========================================================================
% Terminate
%==========================================================================

function Terminate(obj)
%
% TERMINATE   Set termination flag on keypress event
%
   %fprintf('Terminate: key pressed!\n');
   terminate(core);
   butpress(obj,'Refresh');    % continue next keypress with refresh
   return
end

%==========================================================================
% Ignore
%==========================================================================

function Ignore(obj)
%
% IGNORE   Ignore keypress event
%
   %fprintf('Ignore: key pressed!\n');
   return
end

%==========================================================================
% Refresh
%==========================================================================

function Refresh(obj)
%
% REFRESH   Refresh current callback task
%
   %fprintf('Refresh: key pressed!\n');
   refresh(obj);
   return
end

