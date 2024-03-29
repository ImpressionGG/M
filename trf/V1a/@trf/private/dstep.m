function [y,x] = dstep(a,b,c,d,iu,n)
%DSTEP	Step response of discrete-time linear systems.
%	Y = DSTEP(A,B,C,D,iu,n)  calculates the response of the system:
%
%		x[n+1] = Ax[n] + Bu[n]
%		y[n]   = Cx[n] + Du[n]
%
%	to a step applied to the iu'th input.  Integer n specifies how
%	many points of the step response are to be found.  DSTEP returns a
%	matrix Y with as many columns as there are outputs y, and with
%	n rows. [Y,X] = DSTEP(A,B,C,D,iu,n) also returns the state
%	time history.
%
%	Y = DSTEP(NUM,DEN,n) calculates the step response from the transfer
%	function description  G(z) = NUM(z)/DEN(z)  where NUM and DEN contain
%	the polynomial coefficients in descending powers.


if (nargin == 3)		% transfer function description 
	[y,x] = dlsim(a,b,ones(c,1));
else
	[y,x] = dlsim(a,b(:,iu),c,d(:,iu),ones(n,1));
end

                                                                                                                                                                               