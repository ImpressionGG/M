function [t,dt] = timer(o,dt,t0,shg)
%
% TIMER    Setup timer for graphical animations. 
%
%    It implicitle sets 'shg' attribute of the object to value 1 (true).
%
%       timer(o);                      % use default sample time   
%       timer(o,0.1);                  % use sample time dt = 0.1s
%       timer(o,0.1,t0);               % init initial time t0 also
%       timer(o,0.1,t0,shg);           % init also shg flag
%
%    Comment: To disable auto-shg functionality set 'shg' attribute
%    of timer to 0 (false), i.e.
%
%       timer(o,0.1,t0,0);             % clear shg flag
%
%    Init a time variable (t) and a time increment variable (dt)
%
%       [t,dt] = timer(o,0.1);         % initializes t and dt
%       [t,dt] = timer(o,dt,t0);       % initializes t=t0,dt
%
%    See also: CARABULL, WAIT, STOP, TERMINATE
%
   if (nargin < 2) dt = 0.1; end
   if (nargin < 3) t0 = 0.0; end
   if (nargin < 4) shg = 1; end

   terminate(o,0);    % clear stop flag (allow loop)

   timer.start = tic;
   timer.dt = dt;
   timer.tnext = dt;
   timer.t = t0;
   timer.shg = shg;
   
   control(o,'timer',timer);

   if (nargout > 0)
      t = t0;
   end
end


