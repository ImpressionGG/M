function flag = stop(o,value)
%
% STOP   Retrieve stop flag.
%
%           flag = stop(o)             % retrieve stop flag
%           stop(o,value)              % set stop flag to value
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
   if (nargin == 1)
      flag = setting(o,{'control.stop',0});
   else
      setting(o,'control.stop',value);
   end
end
