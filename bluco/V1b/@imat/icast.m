function A = icast(o)
%
% ICAST  Cast IMAT to real matrix
%
%           A = icast(a)         
%
%        See also IMAT, ITRN, IMUL, ISUB, IINV
%
   A = reshape(double(o.mant),o.m,o.n);
   A = A * 2^(o.expo-o.bits);
end