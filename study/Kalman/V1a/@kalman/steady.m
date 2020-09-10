function [avg,sig,idx] = steady(o,x,tail)
%
% STEADY  Get average and standard deviation of steady part of a signal
%
%            [avg,sig] = steady(o,x)
%            [avg,sig,idx] = steady(o,x,0.3)   % tail = 0.3 (30%)
%
%         See also: PLL
%
   if (nargin < 3)
      tail = 0.5;
   end
   
   [m,n] = size(x);
   
   from = ceil(n*(1-tail));
   idx = from:n;
   
   avg = mean(x(:,idx)')';
   sig = std(x(:,idx)')';
end
