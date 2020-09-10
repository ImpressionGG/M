function lambda = eig(o,n)
%
% EIG    Get vector of eigenvalues or n-th eigenvalue of an operator
%
%          o = op('x');
%          psi = eig(o);        % get vector of (all) eigenvalues
%          psi = eig(o,n);      % get n-th eigenvalue
%
%       See also: OP
%
 
   M = o.M;
   lambda = eig(M);  % get vector of eigenvalues  

   if (nargin == 1)
      return    % done
   end
   
   if (n > o.dim || n < 1)
      error('index out of bounds');
   end
   
   lambda = lambda(n);
   
   return
   
%eof   