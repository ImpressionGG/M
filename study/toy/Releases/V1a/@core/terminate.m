function terminate(obj,flag)
%
% TERMINATE  Set stop flag in order to terminate a loop.
%
%    Stop flag is cleared by TIMER function. In orrder to re-set stop
%    flag the terminate function needs to be called in a keypress
%    handler function
%
%       terminate(smart,1);      % force termination
%       terminate(smart,0);      % clear stop flag
%       terminate(smart);        % like terminate(smart,1);
%
%    Example
%
%       smo = timer(core,0.1);   % set timer, clear stop flag
%       while (~stop(smo))
%          % do something
%          smo = wait(smo);      % wait for timer
%       end
%
%    To stop above loop you have to call terminate in a keypress
%    function, e.g.
%
%       function Stop(obj)       % handler is called by kexpress event
%          terminate(core);
%       return;
%
%    See also: CORE, TIMER, TERMINATE, WAIT
%
   if (nargin < 2)
      flag = 1;   % force termination
   end
   
   setting('core.stop',flag);
   return
end
