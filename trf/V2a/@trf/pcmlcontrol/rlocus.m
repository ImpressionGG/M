function r = rlocus(num,den,k)
%RLOCUS	Evans root locus.
%	R = RLOCUS(num,den,k) calculates the locus of the zeros of:
%
%			       num(s)
%		H(s) = 1 + k ----------  =  0
%			       den(s)
%
%	for the gains specified in vector K.  Vectors NUM and DEN must contain 
%	the numerator and denominator coefficents in descending powers of s.
%	RLOCUS returns a matrix R with LENGTH(K) rows and (LENGTH(DEN)-1)
%	columns containing the complex root locations.   Each row of the
%	matrix corresponds to a gain from vector K.  The root-locus may be
%	plotted	with  PLOT(R,'x').
%
[mn,nn] = size(num);
[md,nd] = size(den);
if (mn+md) ~= 2
	errmsg('Both numerator and denominator must be row vectors')
	return
end
if (nn > nd)
	den = [zeros(md,nn-nd) den];
elseif (nn < nd)
	num = [zeros(mn,nd-nn) num];
end
n  = length(den);
nk = length(k);
r  = sqrt(-1) * ones(n-1,nk);

% Here is what the algorithm is:
% for i=1:nk
%	r(:,i) = roots(den+num*k(i));
% end

% Here is an optimized way to do it:
a = 1;
if  n~=2
	a = diag(ones(1,n-2),-1);
end
for i=1:nk
	c = den + num * k(i);
	a(1,:) = -c(2:n) ./ c(1);
	r(:,i) = eig(a);
end
r = r.';
                                                                                                                                                                                                                                                                                                                                                                             