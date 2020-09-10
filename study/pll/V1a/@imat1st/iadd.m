function c = iadd(a,b,name)
%
% IADD   IMAT addition
%
%           c = iadd(a,b)              % c = a + b
%           c = iadd(a,b,'A+B')        % c = a + b, provide result name
%
%        See also IMAT, IMUL, ISUB, IINV
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
      c.data(i) = a.data(i) + b.data(i);
   end
   
   icheck(c,c.data,'iadd');
   c.margin = c.maxi / max(abs(c.data));
end