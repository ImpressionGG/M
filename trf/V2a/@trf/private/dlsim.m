function  [y,x] = dlsim(a, b, c, d, u, x0)
%DLSIM	Simulation of discrete-time linear systems.
%	Y = DLSIM(A,B,C,D,U)  calculates the time response of the system:
%		
%		x[n+1] = Ax[n] + Bu[n]
%		y[n]   = Cx[n] + Du[n]
%
%	to input sequence U.  Matrix U must have as many columns as there are
%	inputs, u.  Each row of U corresponds to a new time point. DLSIM
%	returns a matrix Y with as many columns as there are outputs y, and
%	with LENGTH(U) rows.
%	[Y,X] = DLSIM(A,B,C,D,U) also returns the state time history.
%	DLSIM(A,B,C,D,U,X0) can be used if initial conditions exist.
%
%	Y = DLSIM(NUM,DEN,U) calculates the time response from the transfer
%	function description  G(z) = NUM(z)/DEN(z)  where NUM and DEN
%	contain the polynomial coefficients in descending powers.
%	DLSIM(NUM,DEN,U) is equivalent to FILTER(NUM,DEN,U).
nargs = nargin;
if (nargs == 3)		% transfer function description 
	u = c;
	[m,n] = size(a);
	if ((m == 1)|(nargout == 1))	% Use filter, it's more efficient
		y = filter(a,b,u);
      x = [];   % hux
		return
	else  			% Convert to state space
		a = [a zeros(m,length(b)-n)]
		[a,b,c,d] = tf2ss(a,b);
		nargs = 5;
	end
end
[ns,nx] = size(a);
if (nargs == 5)
	x0 = zeros(1,ns);
end
if nargcheck(5,6,nargs)
	return
end
if abcdcheck(a,b,c,d)
	return
end
x = ltitr(a,b,u,x0);
y = x * c.' + u * d.';
