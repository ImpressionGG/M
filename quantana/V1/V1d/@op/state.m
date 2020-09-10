function psi = state(o,n)
%
% STATE    Get n-th eigenstate of an operator
%
%          o = op('x');
%          psi = state(o,n);
%
%       See also: OP
%
   if (n > o.dim || n < 1)
      error('index out of bounds');
   end
   
   M = o.M;
   [V,D] = eig(M);  % get eigen vectors
   psi = V(:,n)';
   
   return
   
%eof   