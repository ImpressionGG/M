function o = invoke(o)
%
% INVOKE   Overloaded TOY method to invoke a callback function
%
%    Invoke a callback function via a package handler. Control needs to
%    be directed to the particular handler given by user data
%
%       invoke(o);
%
%    Speciality: invoke must set the 'task' parameter of an object
%    with setting('view.task');
%
%    See also: TOY, MENU, CALLBACK, ARG, ARGUMENTS
%

% % %    if isempty(get(o,'task'))                      % @@@ this is special!
% % %       top = setting('view.topic');                  % @@@ this is special!
% % %       task = setting('view.task');                  % @@@ this is special!
% % %       o = topic(o,top,task);                    % @@@ this is special!
% % %    end                                              % @@@ this is special!
   
   [cmd,oo,func] = arguments(o);

   if match(func,{'Refresh','Terminate','Ignore'})
      eval(cmd);
   else
      Execute(o);
   end
   return
end

%==========================================================================
% Execute
%==========================================================================

function Execute(o,handler)
%
% EXECUTE   Execute a callback
%
   if (nargin < 2)
      handler = caller(o,2);
   end
   
      % now setup refresh function call properly
   
   callback = [handler,'(o);'];
   callargs = cons(mfilename,arg(o,0));
   
   refresh(o,callback,callargs); 
   click(o,'Terminate');               % setup mouse click callback

   clc;                                  % clear command line
   profiler([]);                         % initialize profiler

   busy;
   cmd = [handler,'(o);'];
   eval(cmd);
   ready;

   click(o,'Refresh');                 % setup mouse click callback

   if (opt(o,'profiler'))
      profiler; 
   end
   return
end

%==========================================================================
% Terminate
%==========================================================================

function Terminate(o)
%
% TERMINATE   Set termination flag on keypress event
%
   terminate(core);
   click(o,'Refresh');       % next mouse button click with refresh
   return
end

%==========================================================================
% Ignore
%==========================================================================

function Ignore(o)
%
% IGNORE   Ignore keypress event
%
   %fprintf('Ignore: key pressed!\n');
   return
end

%==========================================================================
% Refresh
%==========================================================================

function Refresh(o)
%
% REFRESH   Refresh current callback task
%
   %fprintf('Refresh: key pressed!\n');
   refresh(o);
   return
end

