function [y,x] = dimpulse(a,b,c,d,iu,n)
%DIMPULSE Impulse response of discrete-time linear systems.
%	 Y = DIMPULSE(A,B,C,D,iu,n)  calculates the response of the system:
%
%		x[n+1] = Ax[n] + Bu[n]
%		y[n]   = Cx[n] + Du[n]
%
%	to an unit sample applied to the iu'th input.  Integer n specifies
%	how many points of the impulse response to find. DIMPULSE 
%	returns a matrix Y with as many columns	as there are outputs y, 
%	and with n rows. 
%	[Y,X] = DIMPULSE(A,B,C,D,iu,n) also returns the state time history.
%
%	Y = DIMPULSE(NUM,DEN,n) calculates the impulse response from the 
%	transfer function description  G(z) = NUM(z)/DEN(z)  where NUM and
%	DEN contain the polynomial coefficients in descending powers.

if (nargin == 3)		% transfer function description 
	[y,x] = dlsim(a,b,[1;zeros(c-1,1)]);
else
	[y,x] = dlsim(a,b(:,iu),c,d(:,iu),[1;zeros(n-1,1)]);
end

                                                                                                                                  