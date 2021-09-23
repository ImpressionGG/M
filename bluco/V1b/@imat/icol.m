function c = icol(a,b,name)
%
% ICOL  Concatenate matrices to a column
%
%           c = icol(a,b)         
%           c = icol(a,b,'[a;b]')   % concatenated column matrix         
%
%        See also IMAT, ICAST, IMUL, ISUB, IINV, IROW
%
   if (nargin < 3)
      name = '';
   end
   
   if (a.n ~= b.n)
      error('column number mismatch');
   end
   
   A = icast(a);
   B = icast(b);
   c = imat(a.m+b.m,a.n,[A;B],name);
end