function [a,b,c,d] = ord2(wn, z)
%ORD2	State-space representation of a second order system.
%	[A,B,C,D] = ORD2(Wn, z) returns the A,B,C,D representation of the
%	second order system with natural frequency Wn and damping factor z.

a = [0 1;-wn^2, -2*z*wn];
b = [0; wn^2];
c = [1 0];
d = 0;
