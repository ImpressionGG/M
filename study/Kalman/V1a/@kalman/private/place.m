function k = place(a,b,r)
%PLACE	Pole placement gain selection.
%	K = PLACE(A,B,R)  calculates the feedback gain matrix K	such that
%	the single input system
%		.
%		x = Ax + Bu 
%
%	with a feedback law of  u = -Kx  has closed loop poles at the 
%	values specified in vector R, i.e.,  R = eig(A-B*K).
%
%	Note: This algorithm uses Ackermann's formula.  This method
%	is NOT numerically reliable and starts to break down rapidly
%	for problems of order greater than 10, or for weakly controllable
%	systems.  A warning message is printed if the nonzero closed loop
%	poles are greater than 10% from the desired locations specified in R.

if nargcheck(3,3,nargin)
	return
end
if abcdcheck(a,b)
	return
end
[m,n] = size(b);
if n ~= 1
	errmsg('System must be single input')
	return
end
r = r(:);		% Make sure roots are in a column vector
[mr,nr] = size(r);
[m,n] = size(a);
if (m ~= mr)
	errmsg('The vector R must have ORDER(A) elements')
	return
end

% Algorithm is from page 201 of Kailath's LINEAR SYSTEMS

% Form controllability matrix
ctrb = b;
for i=1:n-1
	ctrb = [b a*ctrb];
end

% Form caleyham = alpha(A) using Horner's method of polynomial evaluation
alpha = real(poly(r));
caleyham = zeros(n);
for i=1:n+1
	caleyham = a * caleyham + alpha(i) * eye(m);
end

% Form gains using Ackerman's formula
ctrb = inv(ctrb);
k = ctrb(n,:) * caleyham;

% Remove zero pole locations
r = sort(r);
i = find(r ~= 0);
r = r(i);
rc = sort(eig(a-b*k));
rc = rc(i);
if max(abs(r-rc)./abs(r)) > .1
	Warning='Pole locations are more than 10% in error'
end
