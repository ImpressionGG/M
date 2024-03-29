function [num,den] = zp2tf(z,p,k)
%ZP2TF	Zero-pole to transfer function conversion.
%	[NUM,DEN] = ZP2TF(Z,P,K)  forms the transfer function:
%
%			NUM(s)
%		H(s) = -------- 
%			DEN(s)
%
%	given a set of zero locations in vector Z, a set of pole locations
%	in vector P, and a gain in scalar K.  Vectors NUM and DEN are 
%	returned with numerator and denominator coefficients in descending
%	powers of s.  See TF2PZ to convert the other way.

% 	J.N. Little 7-17-85
%	Copyright (c) 1985, by the MathWorks, Inc.

%	Note: the following will not work if p or z have elements not
%	in complex pairs.

den = real(poly(p(:)));
[m,n] = size(z);
for j=1:n
	zj = z(:,j);
	pj = real(poly(zj)*k(j));
	num(j,:) = [zeros(1,m-length(pj)+1) pj];
end
                                                                                                                                                                                                                                                                      