function [t,dt] = wait(obj)
%
% WAIT   Wait for animation timer.
%
%    It also calls SHG function to show
%    current graphic figure
%
%    Example 1:
%       cob = timer(core,0.1);      % setup dt = 0.1 timer interval
%       cob = set(cob,'shg',1);     % show graphics
%
%       while(~stop(cob))
%          % do something
%          cob = wait(cob);
%       end
%
%    Example 2:
%       timer(gao,0.1);           % setup dt = 0.1 timer interval
%       while(~stop(cob))
%          % do something
%          wait(gao);
%       end
%
%    Example 3:
%       [t,dt] = timer(gao,0.1);  % setup dt = 0.1 timer interval
%       while(~stop(cob))
%          f = sin(t);            % do something
%          [t,dt] = wait(gao);
%       end
%
%
%    See also: CORE, TIMER, TERMINATE, STOP
%
   profiler('wait',1);
   if (nargout==0 || nargout >= 2)
      obj = gao;           % fetch from axis user data
   end
   
   show = get(obj,'timer.shg');
   if (show)
      shg;    % show graphics
   end
   
   dt = get(obj,'timer.dt');
   tstart = get(obj,'timer.start');
   tnext = get(obj,'timer.tnext');
   obj = set(obj,'timer.tnext',tnext + dt);
   
   t = get(obj,'timer.t') + dt;
   obj = set(obj,'timer.t',t);
   
   if (nargout == 0 || nargout >= 2)
      gao(obj);           % push back to axis user data
   end
   
   while (toc(tstart) < tnext)
      0;               % wait
   end
   
   if (nargout == 1)
      t = obj;
   end
   
   profiler('wait',0);
   return
end


