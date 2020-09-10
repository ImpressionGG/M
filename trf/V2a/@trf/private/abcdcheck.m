function Error = abcdcheck(a,b,c,d)
% Check that dimensions of A,B,C,D are consistent.
% Give error message if not and return 1. Otherwise return 0.
Error = 0;
[ma,na] = size(a);
if (ma ~= na)
	errmsg('The A matrix must be square')
	Error = 1;
end
if (nargin > 1)
	[mb,nb] = size(b);
	if (ma ~= mb)
errmsg('The A and B matrices must have the same number of rows')
	Error = 1;
	end
	if (nargin > 2)
		[mc,nc] = size(c);
		if (nc ~= ma)
errmsg('The A and C matrices must have the same number of columns')
			Error = 1;
		end
		if (nargin > 3)
			[md,nd] = size(d);
			if (md ~= mc)
errmsg('The C and D matrices must have the same number of rows')
				Error = 1;
			end
			if (nd ~= nb)
errmsg('The B and D matrices must have the same number of columns')
				Error = 1;
			end
		end
	end
end
