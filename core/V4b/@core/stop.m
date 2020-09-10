function flag = stop(obj)
%
% STOP   Retrieve stop flag.
%
%    Stop flag is cleared by TIMER function
%    and set by butpress, if butpress properly set to Stop()
%
%    Example
%
%       cob = timer(core,0.1);       % set timer, clear stop flag
%       while (~stop(cob))
%          % do something
%          cob = wait(cob);          % wait for timer
%       end
%
%    See also: SMART, TIMER, TERMINATE, WAIT
%
   flag = setting('core.stop');
   if (isempty(flag))
      stop = 0;
   end
   return
end
