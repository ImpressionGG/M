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
   
   n = a.n;                            % equals b.m
   
   c = a;
   c.m = a.m;
   c.n = b.n;
   c.len = c.m * c.n;
   c.expo = a.expo;                    % inherit a's exponent
   c.name = name;
   
   M = zeros(c.m,c.n);
   A = reshape(a.data,a.m,a.n);
   B = reshape(b.data,b.m,b.n);
   
   maxa = max(abs(A(:)));  loga = ceil(log2(maxa));
   maxb = max(abs(B(:)));  logb = ceil(log2(maxb));
   logm = floor(log2(c.maxi));
   
   exp1 = loga + logb - floor(log2(c.maxi)); 
   if (exp1 > 0)
      exp2 = floor(b.expo-exp1);
exp=[exp1,exp2]
      'breakpoint';
   else
      exp1 = 0;
      exp2 = b.expo;
   end

      % some assertions
   
   assert(floor(exp1)==exp1);
   assert(floor(exp2)==exp2);
   assert(exp1+exp2==b.expo);
   
   base1 = 2^exp1;
   base2 = 2^exp2;
   
   B = B / base1;
   
      % perfporm multiplication
      
   for (i=1:c.m)
      for (j=1:c.n)
         M(i,j) = 0;
         for (k=1:n)
            M(i,j) = M(i,j) + A(i,k)*B(k,j);
         end
      end
   end
   
   icheck(c,M,'imul');
   
   c.data = M(:)/base2;
   c.margin = c.maxi / max(abs(c.data));
end