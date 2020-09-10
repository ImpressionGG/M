function K = place(o,A,B,poles)
%
% PLACE  State feedback calculation by pole placement
%
%           K = place(o,A,B,[p1,...,pn])
%
%        calculates a state feedback matrix K such that the closed loop
%        discrete system
%
%           x' = A*x + B*u
%           u  = -K*x
%
%        has its eigenvalues at given locations [p1,...,pn]
%
%        Example: dead beat control for PWM system
%
%           A = [1 0:-2 1];  B = [1;-1];
%           K = place(pll,A,B,[0 0]);       % => K = [1.5 -0.5]
%
%        Test: M = (A-B*K)^2 = 0
%           
%           M = (A-B*K)^2
%
%        See also: PLL, LQR
%
   K = place(A,B,poles);
end


% x1 = A*x0 + B*u0
% x2 = A*x1 + B*u1 = A*(A*x0 + B*u0) + B*u1 = A2*x1 + A*B*u0 + B*u0 = 0
% => A2*x1 = -A*B*u0 - 
