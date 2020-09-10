function y = rd(x,n)
%
% RD   Round to n digits after comma
%
%         y = rd(x,n)   % round x to n digits after comma
%         y = rd(x)     % same as y = rd(x,2)
%
   if (nargin < 2), n = 2; end
   
   factor = 10^n;
   y = round(factor*x) / factor;
   return
   
%eof   