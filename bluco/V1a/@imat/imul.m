function c = imul(a,b,name)
%
% IMUL   IMAT multiplication
%
%           c = imul(a,b)              % c = a * b
%           c = imul(a,b,'A*B')        % c = a * b, provide result name
%
%        See also IMAT, CAST, IMUL, ISUB, IINV
%
   if (nargin < 3)
      name = '';
   end   
   if (a.n ~= b.m)
      error('dimension mismatch!');
   end
   base = 2^b.expo;

      % setup basic data of result matrix
   
   c = a;
   c.m = a.m;
   c.n = b.n;
   c.len = c.m * c.n;
   c.name = name;
   
   M = zeros(c.m,c.n);
   
      % down sizing of mantissa while upsizing of exponent
      % mantissa of b is down sized by an extra factor of 2 in order
      % to have room for overflow during "addition of products"
   
   expx = ceil(c.bits/2);              % need extra bits
   
   A = reshape(a.mant,a.m,a.n)/2^expx; % downsize mantissa of a
   B = reshape(b.mant,b.m,b.n)/2^expx; % downsize mantissa of b         
   
   expa = a.expo + expx;               % upsize exponent of A
   expb = b.expo + expx;               % upsize exponent of B

      % perform multiplication
      
   n = a.n;                            % equals b.m
   for (i=1:c.m)
      for (j=1:c.n)
         M(i,j) = 0;
         for (k=1:n)
            M(i,j) = M(i,j) + A(i,k)*B(k,j); % "addition of products"
         end
      end
   end
   
      % store result in object and check integrity
      
   if (c.bits == 30)
      c.mant = int32(M(:));
   else
      c.mant = int64(M(:));
   end
   c.expo = a.expo + b.expo + 2*expx - c.bits;
   
   c = itrim(c);
end
