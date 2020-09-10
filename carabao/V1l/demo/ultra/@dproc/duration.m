function dt = duration(obj)
% 
% DURATION Duration of a process element
%      
%             dt = duration(obj);
%
%          See also   DISCO, DPROC

   [x,y] = points(obj);
   dt = max(x(:)) - min(x(:));
   
% eof