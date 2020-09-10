function [obj,stop] = run(obj,start)
% 
% RUN  Run a discret process object at time 'start'
%      
%             [obj,stop] = run(obj,start)     % create DPROC object
%
%      Arguments:
%         obj:    discrete process object
%         start:  start time
%         stop:   stop time
%
%      See also   DISCO, DPROC

   [x,y] = points(obj);
   delta = max(x(:))-min(x(:));
   
   stop = start + delta;
   obj = setp(obj,'start',start,'stop',stop);
   
% eof