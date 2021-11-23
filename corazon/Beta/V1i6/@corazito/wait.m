%
% WAIT   Wait for animation timer.
%
%    It also calls SHG function to show
%    current graphic figure
%
%    Example 1:
%       timer(o,0.1);                  % setup dt = 0.1, t0 = 0, shg = 1
%       while(~stop(o))
%          % do something
%          wait(o);
%       end
%
%    Example 2:
%       timer(o,0.1,0,0);              % setup dt = 0.1, t0 = 0, no shg
%       while(~stop(o))
%          % do something
%       end
%
%    Example 3:
%       [t,dt] = timer(o,0.1);         % setup dt = 0.1 timer interval
%       while(~stop(o))
%          f = sin(t);                 % do something
%          t = wait(o);
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, TIMER, TERMINATE, STOP
%
