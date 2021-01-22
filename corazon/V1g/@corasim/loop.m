function [T,S] = loop(F,B)
%
% LOOP   Closed Loop transfer function T(s) and sensitivity function S(s)
%        based on open loop transfer function L(s) or forward transfer
%        function F(s) and backward transfer function B(s).
%
%           [T,S] = loop(F,B)
%
%                               +----------+
%                           e   |          |
%                r  ---->o----->|   F(s)   |------*----> y
%                        ^ -    |          |      |
%                        |      +----------+      |
%                        |                        |
%                        |      +----------+      |
%                        |      |          |      |
%                        +------|   B(s)   |<-----+
%                               |          |
%                               +----------+
%
%        Total transfer function: T(s) = F(s)/(I + B(s)*F(s)) = F(s)*S(s)
%        Sensitivity function:    S(s) = I/(I + B(s)*F(s))
%
%                            +---------------+
%                            |     F(s)      |
%                r  -------->| ------------- |--------->  y
%                            | 1 + F(s)*B(s) |
%                            +---------------+
%        Theory:
%           
%           y = F*e,  
%           e = r - B*y = r - B*F*e  =>  (I + B*F)*e = r
%           
%           e = 1/(1 + F*B)*r  =>  e = S*r   with  S := 1/(1 + F*B)
%           y = F/(1 + F*B)*r  =>  y = T*r   with  T := F/(1 + F*B)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, STEP, BODE, RLOC
%
   if (nargin < 2)
      B = 1;
   end
   
   if type(F,{'matrix'})
      [m,n] = size(F);
      I = eye(n);
   else
      I = 1;
   end
   
   S = inv(I+B*F);
   T = F*S;
end
