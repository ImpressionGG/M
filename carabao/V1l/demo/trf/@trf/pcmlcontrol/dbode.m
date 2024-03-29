function [mag,phase] = dbode(a,b,c,d,iu,w)
%DBODE	Bode response of discrete-time linear systems.
%	[MAG,PHASE] = DBODE(A,B,C,D,iu,W)  calculates the frequency response 
%	of the system:
%			x[n+1] = Ax[n] + Bu[n]		          -1
%			y[n]   = Cx[n] + Du[n]	     G(z) = C(zI-A) B + D
%
%		mag(w) = abs(G(exp(jw))),    phase(w) = angle(G(exp(jw)))
%
%	from the iu'th input.  Vector W must contain the frequencies, in
%	radians, at which the Bode response is to be evaluated. Normally,
%	the elements of W should not exceed Pi.  DBODE returns matrices MAG
%	and PHASE (in degrees) with as many columns as there are outputs y,
%	and with LENGTH(W) rows.  See LOGSPACE to generate frequency vectors
%	that are equally spaced logarithmically in frequency up to Pi. 
%
%	[MAG,PHASE] = DBODE(NUM,DEN,W) calculates the Bode response from the
%	transfer function description  G(z) = NUM(z)/DEN(z)  where NUM and DEN
%	contain the polynomial coefficients in descending powers.  NUM is 
%	padded with trailing zeros, if necessary, to make it the same length
%	as DEN.   
nargs = nargin;
if (nargs == 3) 	% Convert to state space
	[m,n] = size(a);
	a = [a zeros(m,length(b)-n)]
	w = c;
	[a,b,c,d] = tf2ss(a,b);
	nargs = 6;
	iu = 1;
end
if nargcheck(6,6,nargs)
	return
end
if abcdcheck(a,b,c,d)
	return
end
[no,ns] = size(c);
nw = max(size(w));

% [t,a] = balance(a);	    % Balance A (uncomment these three lines if you
% b = diag(ones(t)./t) * b; % want BODE to automatically balance your A matrix
% c = c * diag(t);	    % (They have been commented out for speed.)

[p,a] = hess(a);		% Reduce A to Hessenberg form:

%	 Apply similarity transformations from Hessenberg
%	 reduction to B and C:
b = p' * b(:,iu);
c = c * p;
d = d(:,iu);
w = exp(w * sqrt(-1));
g = ltifr(a,b,w);
g = c * g + diag(d) * ones(no,nw);
mag = abs(g)';
phase = (180./pi)*imag(log(g))';

% Comment out the following statement if you don't want the phase to  
% be "fixed".  Note that phase fixing will not always work; it is only a
% "guess" as to whether +-360 should be added to the phase to make it
% more asthetically pleasing.  (See FIXPHASE.M)

phase = fixphase(phase);

% Uncomment the following line for decibels, but be warned that the
% MARGIN function will not work with decibel data.
% mag = 20*log10(mag);
                                                                                                                                                                                                                          