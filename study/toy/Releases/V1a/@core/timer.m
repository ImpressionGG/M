function [t,dt] = timer(obj,dt,t0)
%
% TIMER    Setup timer for graphical animations. 
%
%    It implicitle sets 'shg' attribute of the object to value 1 (true).
%
%       cob = timer(core);             % Use default sample time   
%       cob = timer(core,0.1);         % Use sample time dt = 0.1s
%       cob = timer(core,0.1,t0);      % init initial time t0 also
%
%    Comment: To disable auto-shg functionality set 'shg' attribute
%    of timer to 0 (false), i.e.
%
%       cob = set(timer(smart,0.1),'shg',0);
%
%    Syntactic sugar
%
%       timer(core,0.1)               % uses gao object if nargout == 0
%       timer(core);                  % default 0.1 for dt, uses gao
%       [t,dt] = timer(core,0.1);     % initializes t and dt
%       [t,dt] = timer(core,dt,t0);   % initializes t=t0,dt
%
%    See also: CORE, WAIT, STOP, TERMINATE
%
   if (nargout == 0 || nargout >= 2)
      obj = gao;
   end
   
   if (nargin < 2) dt = 0.1; end
   if (nargin < 3) t0 = 0.0; end

   terminate(obj,0);    % clear stop flag (allow loop)

   start = tic;
   obj = set(obj,'timer.dt',dt,'timer.tnext',dt,'timer.start',start);
   obj = set(obj,'timer.t',t0, 'timer.shg',1);

   if (nargout == 0)
      gao(obj);
   elseif (nargout == 1)
      t = obj;                      
   else      % nargout >= 2
      gao(obj);
      t = t0;
   end
   
   return
end


