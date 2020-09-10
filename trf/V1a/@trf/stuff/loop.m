function [T,S] = loop(obj)
%
% LOOP     Calculate loop transfer function T and sensitivity function S
%          based on a open loop transfer function L
%
%             [T,S] = loop(L);       % T = L /(L+1)
%             T = loop(R*P);         % T = R*P / (R*P + 1)
%
%            [T,S] = tffloop(L)
% 
%         Calculates the closed loop transfer function T = L / (1 + L)
%         and the sensitivity function S = 1 / (1 + L).
% 
%         See also: TFF, TRIM, DSP, NUM, DEN
%
   L = data(obj);
   [T,S] = tffloop(L);
   
   T = tff(T);
   S = tff(S);
   
   return
%   