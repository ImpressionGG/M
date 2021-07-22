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
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, WAIT, STOP, TERMINATE
%
