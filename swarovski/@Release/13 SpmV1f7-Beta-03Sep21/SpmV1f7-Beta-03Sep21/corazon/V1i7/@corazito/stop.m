%
% STOP   Retrieve stop flag, or enable/disable stop callback.
%
%           flag = stop(o)             % retrieve stop flag
%           flag = stop(o,o)           % retrieve stop flag ANDed with
%                                      % opt(o,{stop,0})
%
%           stop(o,value)              % set stop flag to value
%
%           stop(o,'Enable')           % enable stop callback for but.press
%           stop(o,'Disable')          % disable stop callback for but.press
%           stop(o,'Callback')         % handle stop callback
%
%           stop(o,'on')               % same as stop(o,'Enable')
%           stop(o,'off')              % same as stop(o,'Disable')
%
%    Stop flag is cleared by TIMER function
%    and set by butpress, if butpress properly set to Stop()
%
%    Example 1
%
%       timer(o,0.1);                  % set timer, clear stop flag
%       while (~stop(o))
%          % do something
%          wait(o);                    % wait for timer
%       end
%
%    Example 2
%
%       stop(o,'Enable');              % enable stop functionality
%       for (i=1:1000)
%          % ...                       % do something
%          if stop(o)                  % stop requested by mouse click?
%             break;
%          end
%       end
%       stop(o,'Disable');             % disable stop functionality
%   
%    Options
%       stop                           % option to be anded with stop flag
%                                      % for stop(o,o) calls (default 0)
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, TIMER, TERMINATE, WAIT, PROGRESS
%
