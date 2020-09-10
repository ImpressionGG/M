function y = rd(x,n)
%
% RD    Round real to n digits after comma
%
%          y = rd(x,n)   % round to n digits after comma
%          y = rd(x)     % round to 2 digits after comma
%
   n = eval('n','2');  % provide default
   
   base = 10^n;
   y = round(x*base)/base;
   
% eof   