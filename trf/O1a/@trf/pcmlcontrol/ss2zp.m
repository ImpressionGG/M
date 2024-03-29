function [z,p,k] = ss2zp(a,b,c,d,iu)
%SS2ZP	State-space to zero-pole conversion.
%	[Z,P,K] = SS2ZP(A,B,C,D,iu)  calculates the transfer function in
%	factored form:
%
%			     -1           (s-z1)(s-z2)...(s-zn)
%		H(s) = C(sI-A) B + D =  k ---------------------
%			                  (s-p1)(s-p2)...(s-pn)
%	of the system:
%		.
%		x = Ax + Bu
%		y = Cx + Du
%
%	from the iu'th input.  Vector P contains the pole locations of the
%	denominator of the transfer function.  The numerator zeros are
%	returned in the columns of matrix Z with as many columns as there are
%	outputs y.  The gains for each numerator transfer function are 
%	returned in column vector K.

% 	J.N. Little 7-17-85
%	Copyright (c) 1985, by the MathWorks, Inc.

if nargcheck(5,5,nargin)
	return
end
if abcdcheck(a,b,c,d)
	return
end

% Remove relevant input:
b = b(:,iu);
d = d(:,iu);

% Do poles first, they're easy:
p = eig(a);

% Now try zeros, they're harder:
[no,ns] = size(c);
z = zeros(ns,no) + inf;		% Set whole Z matrix to infinities
% Loop through outputs, finding zeros
for i=1:no
	s1 = [a b;c(i,:) d(i)];
	s2 = diag([ones(1,ns) 0]);
	zv = eig(s1,s2);
	% Now put NS valid zeros into Z. There will always be at least one
	% NaN or infinity.
	zv = zv((zv ~= nan)&(zv ~= inf));
	if length(zv) ~= 0
		z(1:length(zv),i) = zv;
	end
end

% Now finish up by finding gains using Markov parameters
k = d;  CAn = c;
while any(k==0)	% do until all k's are finished
	markov = CAn*b;
	i = find(k==0);
	k(i) = markov(i);
	CAn = CAn*a;
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 