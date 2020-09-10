function dric(a,b,q,r,k,s)
%	discrete Riccati solution check.
%					  -1
%		0 = S - A'SA + A'SB(R+B'SB) BS'A - Q
serr = s - a'*s*a+a'*s*b*((r+b'*s*b)\b'*s'*a)-q
kerr = k - (r+b'*s*b)\b'*s*a

