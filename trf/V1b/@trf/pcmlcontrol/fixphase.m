function pfix = fixphase(praw)
%FIXPHASE Unwrap phase plots so that instead of going from -180 to 180
%	  they will have a smooth transition across these branch cuts
%	  into phases greater than 180 or less than -180.
%	  Y = FIXPHASE(X) fixes the phases in X.   If X is an array
%	  of phases from several variables, the phase for each variable
%	  must lie in a separate column.  The phase must be in degrees.

% 	J.N. Little 7-17-85
%	Copyright (c) 1985, by the MathWorks, Inc.

[m,n] = size(praw);
if m == 1
	praw = praw.';
	[m,n] = size(praw);
end
pfix = praw;
for j = 1:n
	p = praw(:,j);
	pd = diff(p);
	ijump = find(abs(pd) > 170);
	for i=1:max(size(ijump))
		k = ijump(i);
		p(k+1:m) = p(k+1:m) - 360 * sign(pd(k));
	end
	pfix(:,j) = p;
end
                                                                                                                                                                                                                                                       