function flag = stop(o)
%
% STOP   Retrieve stop flag.
%
%    Stop flag is cleared by TIMER function
%    and set by butpress, if butpress properly set to Stop()
%
%    Example
%
%       timer(o,0.1);                  % set timer, clear stop flag
%       while (~stop(o))
%          % do something
%          wait(o);                    % wait for timer
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, TIMER, TERMINATE, WAIT
%
   flag = setting(o,{'control.stop',0});
   if (isempty(flag))
      stop = 0;
   end
end
