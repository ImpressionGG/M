function [A,B,C,D] = ssr(obj)
%
% SSR    State space representation - calculated from a transfer function
%
%           [A,B,C,D] = ssr(Gs)        % same as [A,B,C,D] = ssr(num(Gs),den(Gs))
%
%        Example: Calculate state space model for transfer function
%
%                          5 s^2 + 14 s + 8                  
%                  G(s) = -------------------
%                           1 s^2 + 2 s + 1                  
%
%           [A,B,C,D] = ssr(tff([5 14 8],[1 2 1]));
%
   G = data(obj);
   [A,B,C,D] = tffssr(G);
   return;
   
% eof   