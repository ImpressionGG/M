%
% TERMINATE  Set stop flag in order to terminate a loop.
%
%    Stop flag is cleared by TIMER function. In orrder to re-set stop
%    flag the terminate function needs to be called in a keypress
%    handler function
%
%       terminate(o,1);                % force termination
%       terminate(o,0);                % clear stop flag
%       terminate(o);                  % like terminate(o,1);
%
%    Example
%
%       timer(o,0.1);                  % set timer, clear stop flag
%       while (~stop(o))
%          % do something
%          wait(o);                    % wait for timer
%       end
%
%    To stop above loop you have to call terminate in a keypress
%    function, e.g.
%
%       function Stop(o)               % handler called by kexpress event
%          terminate(o);
%       end
%
%    or
%       set(gcf,'WindowButtonDownFcn','terminate(sho)')
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, TIMER, TERMINATE, WAIT
%
