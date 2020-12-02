function c = irow(a,b,name)
%
% IROW  Concatenate matrices to a row
%
%           c = irow(a,b)         
%           c = irow(a,b,'[a,b]')   % concatenated row matrix         
%
%        See also IMAT, ICAST, IMUL, ISUB, IINV, ICOL
%
   if (nargin < 3)
      name = '';
   end
   
   if (a.m ~= b.m)
      error('row number mismatch');
   end
   
   A = icast(a);
   B = icast(b);
   c = imat(a.m,a.n+b.n,[A,B],name);
end