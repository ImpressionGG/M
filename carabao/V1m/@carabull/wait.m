function [t,dt] = wait(o)
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
%    See also: CARABULL, TIMER, TERMINATE, STOP
%
   o.profiler('wait',1);
   
   timer = control(pull(o),'timer');
   if isempty(timer)
      error('timer is not inititialized!');
   end
   
   show = timer.shg;
   if (show)
      shg;    % show graphics
   end
   
   dt = timer.dt;
   tstart = timer.start;
   tnext = timer.tnext;
   timer.tnext = tnext + dt;
   
   t = timer.t + dt;
   timer.t = t;
   
   control(o,'timer',timer);           % store back to shell settings
   
   o.profiler('waiting',1);
   tcurr = toc(tstart);
   if (tcurr < tnext)
      %fprintf('   waiting %g ms\n',rd((tnext-tcurr)*1000,0));
      while (tcurr < tnext)
         drawnow;
         pause(0.1);
         tcurr = toc(tstart);               % wait
      end
   end
   o.profiler('waiting',0);
   
   o.profiler('wait',0);
end


