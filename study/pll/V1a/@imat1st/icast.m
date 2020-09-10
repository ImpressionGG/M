function A = icast(a)
%
% ICAST  Cast IMAT to real matrix
%
%           A = icast(a)         
%
%        See also IMAT, ITRN, IMUL, ISUB, IINV
%
   A = reshape(a.data,a.m,a.n);
   
   A = A/(2^a.expo);
end