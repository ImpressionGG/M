function x = dlyap(a,c)
%DLYAP	Discrete Lyapunov equation solution.
%	X = DLYAP(A,C) solves the discrete Lyapunov equation:
%
%		A*X*A' + C = X
%
%	See also LYAP.

% Author: J.N. Little 2-1-86

a = (a+eye(a))\(a-eye(a));
c = (eye(a)-a)*c*(eye(a)-a')/2;
x = lyap(a,c);
                                                                                                                                                                                                                                      