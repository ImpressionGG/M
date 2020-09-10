function a = itrn(a,name)
%
% ITRN  transpose an IMAT
%
%           aT = itrn(a)         
%           aT = itrn(a,'aT')      % transpose, provide result name         
%
%        See also IMAT, ICAST, IMUL, ISUB, IINV
%
   if (nargin < 2)
      name = '';
   end
   a.name = name;
   
   A = reshape(a.data,a.m,a.n);
   A = A';
   a.data = A(:);
   tmp = a.m;  a.m = a.n;  a.n = tmp;
end