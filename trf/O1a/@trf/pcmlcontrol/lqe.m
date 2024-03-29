function [k,s] = lqe(a,g,c,q,r)
%LQE	Linear quadratic estimator design. For the continuous-time system:
%		.
%		x = Ax + Bu + Gw	    {State equation}
%		z = Cx + Du + v		    {Measurements}
%
%	with process noise and measurement noise covariances:
%
%		E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R
%
%	the function LQE(A,G,C,Q,R) returns the gain matrix L
%	such that the stationary Kalman filter:
%		.
%		x = Ax + Bu + L(z - Hx - Du)
%
%	produces an LQG optimal estimate of x.
%	[L,P] = LQE(A,G,C,Q,R) returns the gain matrix L and the Riccati
%	equation solution P which is the estimate error covariance.

% Calculate estimator gains using LQR and duality:
% Note, cross term, if needed, is g*t
[k,s] = lqr(a',c',g*q*g',r);
k=k';
s=s';

                                                                                                                                                                                                                                                                       