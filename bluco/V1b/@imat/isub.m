function c = isub(a,b,name)
%
% ISUB   IMAT addition
%
%           c = isub(a,b)              % c = a - b
%           c = isub(a,b,'A-B')        % c = a - b, provide result name
%
%        See also IMAT, IMUL, IADD, IINV
%
   if (nargin < 3)
      name = '';
   end
   if (a.m ~= b.m || a.n ~= b.n)
      error('dimension mismatch!');
   end
   
      % copy a matrix to result matrix c to have the basic structure

   c = a;
   c.name = name;

      % equalize exponents
      
   if (a.expo < b.expo)
      shift = b.expo - a.expo;
      c.expo = b.expo;
      a.mant = a.mant / 2^shift;
   elseif (b.expo < a.expo)
      shift = a.expo - b.expo;
      c.expo = a.expo;
      b.mant = b.mant / 2^shift;
   end
   
      % subtract mantissas
   
   for (i=1:c.len)
      c.mant(i) = a.mant(i) - b.mant(i);
   end
   
   c = itrim(c);
end