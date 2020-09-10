function c = isub(a,b,name)
%
% ISUB   IMAT subtraction
%
%           c = isub(a,b)              % c = a - b   
%           c = isub(a,b,'A-B')        % c = a - b, provide result name
%
%        See also IMAT, IMUL, ISUB, IINV, ITRN, ICAST
%
   if (nargin < 3)
      name = '';
   end
   if (a.m ~= b.m || a.n ~= b.n)
      error('dimension mismatch!');
   end
   
   if (a.expo ~= b.expo)
      error('exponent mismatch!');
   end

   c = a;
   c.name = name;
   
   for (i=1:c.len)
      c.data(i) = a.data(i) - b.data(i);
   end
   
   icheck(c,c.data,'isub');
   c.margin = c.maxi / max(abs(c.data));
end