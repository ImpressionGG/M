function oo = mul(o,x,y)               % Multiply Two Rational Objects 
%
% MUL   Multiply two rational objects
%
%       1) Multiplying Mantissa
%
%          o = base(rat,100);
%          z = mul(o,[26 19 25 94],[17 28 89])    % multiply two mantissa
%
%       2) Multiplying Objects
%
%          oo = mul(o1,o2)
%
%       Example: polynomial multiplication
%
%          a = corinth([1 5 6])
%          b = corinth([1 2 1])
%          c = corinth([1 7 17 17 6])
%
%          ab = mul(a,b)
%          zero = sub(ab,c)
%
%       See also: CORINTH, SUB, MUL, DIV, COMP
%
   o.profiler('mul',1);
   
   if (nargin == 3)
      oo = Mul(o,x,y);
   else
      x = touch(x);
      switch o.type
         case 'trf'
            oo = MulTrf(o,x);
         case 'number'
            oo = MulNumber(o,x);
         case 'poly'
            oo = MulPoly(o,x);
         case 'ratio'
            oo = MulRatio(o,x);
         case 'matrix'
            oo = MulMatrix(o,x);
         otherwise
            error('implermentation restriction!');
      end
      
      oo = touch(oo);                  % force cancel & trim
      oo = can(oo);
      oo = trim(oo);
   end
   
   o.profiler('mul',0);
end

%==========================================================================
% Multiply Two Mantissa
%==========================================================================

function z = Mul(o,x,y)                % Multiply Mantissa             
   if (x(1) == 0)
      x = trim(o,x);
   end
   if (y(1) == 0)
      y = trim(o,y);
   end

   sign = 1;
   if any(x< 0)
      x = -x;  sign = -sign;
   end
   if any(y<0)
      y = -y;  sign = -sign;
   end
   
   base = o.data.base;
   
   n = length(x);
   z = 0*x;                              % init z
   for (i=1:length(y))
      z = [z 0];                         % shift intermediate result
      t = 0*z;                           % temporary result
      k = length(z);
      
      yi = y(i);  
      carry = 0;
      for (j=1:length(x))
         xj = x(n+1-j); 
         prod = xj * yi + carry;
         
         carry = floor(prod/base);
         remain = prod - carry*base;
         
         t(k) = t(k) + remain;
         k = k-1;
      end
      
      if (k > 0)
         t(k) = carry;
      elseif (carry ~= 0)
         t = [carry t];                % assert(carry == 0);
      end
      z = add(o,z,t);
   end
   z = sign*z;
end

%==========================================================================
% Multiplication Two Transfer Functions
%==========================================================================

function oo = MulTrf(o1,o2)            % Product Of Transfer Functions 
%   
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   oo = o1;

   [num1,den1] = peek(o1);
   [num2,den2] = peek(o2);
   
   num = conv(num1,num2);
   den = conv(den1,den2);
      
   oo = poke(oo,0,num,den);
   
   oo = can(oo);
   oo = trim(oo);
end

%==========================================================================
% Multiply Two Objects
%==========================================================================

function oo = MulNumber(o1,o2)         % Multiply Rational Numbers     
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   oo = o1;
   xpo = o1.data.expo + o2.data.expo;
   
   num = mul(o1,o1.data.num,o2.data.num);
   den = mul(o1,o1.data.den,o2.data.den);
   
   [num,den] = can(oo,num,den);        % cancel by common factor cf
   [num,den,xpo] = trim(oo,num,den,xpo);

   oo = poke(oo,xpo,num,den);

   oo.work.can = true;                 % result already canceled
   oo.work.trim = true;                % result already canceled
end

%==========================================================================
% Multiply Two Polynomials
%==========================================================================

function oo = MulPoly(o1,o2)           % Multiply Two Polynomials      
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   assert(isequal(o1.type,'poly') && isequal(o2.type,'poly'));

   oo = corinth(o1,'number');
   
   n1 = length(o1.data.expo)-1;  
   n2 = length(o2.data.expo)-1;
      
      % coeff is a cell array which holds the resulting coefficients
      % we init with all zeros and add up the partial sums of products

   for (k=0:n1+n2)
      coeff{k+1} = oo;                 % note: oo is a zero raional number
   end
   
   oo = corinth(o1,'poly');
   for (i=0:n1)                        % i indexes coeff's of 1st factor
      %oi = trim(o1,peek(o1,i));
      oi = peek(o1,i);
      for (j=0:n2)                     % j indexes coeff's of 2nd factor
         %oj = trim(o2,peek(o2,j));
         oj = peek(o2,j);
         
         k = i+j;
         ok = mul(oi,oj);

            % add up products
            
         c_k = coeff{k+1};
         ck = add(c_k,ok);
         coeff{k+1} = ck;
      end
   end
   
   for (k=0:n1+n2)
      ok = coeff{k+1};     
      oo = poke(oo,ok,k);
   end
   
   oo = can(oo);
end

%==========================================================================
% Multiply Two Rational Functions
%==========================================================================

function oo = MulRatio(o1,o2)          % Multiply Two Ratios           
   if ~(isequal(o1.type,'ratio') && isequal(o2.type,'ratio'))
      error('two rational objects expected');
   end
   
   [num1,den1,~] = peek(o1);
   [num2,den2,~] = peek(o2);
   
   num = mul(num1,num2);
   den = mul(den1,den2);
   
   oo = poke(corinth(o1,'ratio'),NaN,num,den);
   %oo = can(oo);
end

%==========================================================================
% Multiply Two Rational Matrices
%==========================================================================

function oo = MulMatrix(o1,o2)         % Multiply Two Matrices         
   if ~(isequal(o1.type,'matrix') && isequal(o2.type,'matrix'))
      error('two rational matrices expected');
   end
   
   global CorinthVerbose
   if isempty(CorinthVerbose)
      CorinthVerbose = 0;
   end
   
   M1 = o1.data.matrix;
   M2 = o2.data.matrix;
   
   [m1,n1] = size(M1);  [m2,n2] = size(M2);
   
   if (n1 ~= m2)
      error('incompatible sizes for matrix multiplication');
   end
   
   for (i=1:m1)
      for (j=1:n2)
         if (CorinthVerbose >= 2)
            fprintf('matrix product [%g,%g] of %gx%g ...\n',i,j,m1,n2);
         end
         
         Mij = number(o1,0,1);
         for (k=1:n1)
            if (CorinthVerbose >= 2)
               fprintf('-> multiply term %g ...\n',k);
            end
            M1M2 = M1{i,k} * M2{k,j};

            if (CorinthVerbose >= 2)
               fprintf('-> add term %g ...\n',k);
            end
            Mij = Mij + M1M2;
         end
         M{i,j} = Mij;
      end
   end
   
   oo = corinth(o1,'matrix');
   oo.data.matrix = M;
end
