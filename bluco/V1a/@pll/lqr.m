function [k,s]=lqr(o,a,b,q,r)
%LQR	Linear quadratic regulator design for continuous-time systems.
%	[K,P] = LQR(o,A,B,Q,R)  calculates the optimal feedback gain matrix K
%	such that the feedback law:
%
%		u = -Kx
%
%	minimizes the cost function:
%
%		J = Integral {x'Qx + u'Ru} dt
%
%	subject to the constraint equation: 
%		.
%		x = Ax + Bu 
%                
%	Also returned is S, the steady-state solution to the associated 
%	algebraic Riccati equation:
%				  -1
%		0 = PA + A'P - SBR  B'P + Q

   if o.argcheck(4,4,nargin)
      return
   end
   if abcdcheck(a,b)
      return
   end
   [m,n] = size(a);
   [mb,nb] = size(b);
   [mq,nq] = size(q);
   if (m ~= mq) | (n ~= nq) 
      errmsg('A and Q must be the same size')
      return
   end
   [mr,nr] = size(r);
   if (mr ~= nr) | (nb ~= mr)
      errmsg('B and R must be consistent')
      return
   end

   % Check if q and r are positive definite
   chol(q); 
   chol(r);

   [v,d] = eig([a b/r*b';q, -a']);  % eigenvectors of Hamiltonian
   d = diag(d);
   [d,index] = sort(real(d));	 % sort on real part of eigenvalue
   if (~( (d(n)<0) & (d(n+1)>0) ))
      errmsg('Can''t order eigenvalues')
      return
   end
   chi = v(1:n,index(1:n));	 % select vectors with negative eigenvalues
   lambda = v((n+1):(2*n),index(1:n));
   s = -real(lambda/chi);
   k = r\b'*s;
end
