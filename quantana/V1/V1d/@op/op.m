function o = op(kind,dim)
%
% OP    Create an operator on Hilbert space
%
%       Geneneral
%  
%          o = op(kind,dim);
%          o = op(kind);        % dim = 20
%
%       Specific
%
%          x = op('x')          % position operator  x
%          p = op('p')          % momentum operator  p = -i*hbar*d/dx
%
%       Methods:
%  
%          eig           eigenvalues of an operator
%          display       display method
%          matrix        get numerical matrix of operator
%          op            constructor of an operator
%          state         get n-th eigen state of an operator
%
%       See also: OP
%
   if (nargin < 2)
      dim = 20;
   end
   
   o.dim = dim;
   o.kind = kind;
   
   switch kind
      case 'x'
         o.name = 'position operator';
         o.M = diag(1:dim);
      case 'p'
         o.name = 'momentum operator';
         dx = 1;
         M = zeros(dim,dim);
         for (j=1:dim-1)
            M(j+1,j) = -1/2/dx;
            M(j,j+1) = +1/2/dx;
         end
         hbar = 1;
         i = sqrt(-1);
         o.M = -i*hbar*M;
      otherwise
         kind
         error('unknown kind');
   end
   
   o = class(o,'op');
   return
   
%eof   