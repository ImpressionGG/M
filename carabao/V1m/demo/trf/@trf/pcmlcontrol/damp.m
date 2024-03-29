function [wn,z] = damp(a)
% DAMP	Natural frequency and damping factor.
%	[Wn,Z] = DAMP(A) returns vectors Wn and Z containing the
%	natural frequencies and damping factors of A.   The variable A
%	can be in one of several formats:
%
%		1) If A is square, it is assumed to be the state-space
%		   "A" matrix.
%		2) If A is a row vector, it is assumed to be a vector of
%		   the polynomial coefficients from a transfer function.
%		3) If A is a column vector, it is assumed to contain
%		   root locations.
%
%	In all cases, DAMP returns the natural frequencies and damping
%	factors of the system.
[m,n] = size(a);
if (m == n)
	r = eig(a);
elseif (m == 1)
	r = roots(a);
end
wn = abs(r);
z = -cos(imag(log(r)));

                                                                                                                                                                                                                                                                                             