function oo = sub(o,x,y)               % Subtract Two Rational Objects 
%
% SUB   Subtract two rational objects
%
%       1) Subtracting Mantissa
%
%          o = base(rat,100);
%          z = sub(o,[26 19 25 94],[17 28 89])   % subtract mantissa
%
%       2) Subtracting Objects
%
%          oo = sub(o1,o2)
%
%       See also: CORINTH, SUB, MUL, DIV, COMP
%
   o = touch(o);                       % just in case of a copy somewhere

   if (nargin == 3)
      oo = Sub(o,x,y);
   else
      x = touch(x);
      switch o.type
         case 'number'
            oo = SubNumber(o,x);
         case 'poly'
            oo = SubPoly(o,x);
         case 'ratio'
            oo = SubRatio(o,x);
         case 'matrix'
            oo = SubMatrix(o,x);
         otherwise
            error('implermentation restriction!');
      end
      
      oo = can(oo);
      oo = trim(oo);
   end
end

%==========================================================================
% Subtract Two Mantissa
%==========================================================================

function z = Sub(o,x,y)                % Mantissa Subtraction          
   if (all(x>=0) && any(y<0))
      z = add(o,x,-y);
      return
   elseif (any(x<0) && all(y>=0))
      z = -add(o,-x,y);
      return
   elseif (any(x<0) && any(y<0))
      z = Sub(o,-y,-x);
      return
   elseif comp(o,x,y) < 0
      z = -Sub(o,y,x);
      return
   end
   
   [x,y] = form(o,x,y,1);
   if all(x==y)
      z = QuickTrim(o,0*x);
      return
   end
   
   base = o.data.base;
   borrow = 0;
   for (i=length(x):-1:1)
      xi = x(i);  yi = y(i);
      z(i) = xi - yi - borrow;
      
      borrow = 0;
      while z(i) < 0
         z(i) = z(i) + base;
         borrow = borrow + 1;
      end
   end
   
   assert(borrow==0);

   if (z(1) == 0)
      z = QuickTrim(o,z);
   end
end

%==========================================================================
% Subtract Two Objects
%==========================================================================

function oo = SubNumber(o1,o2)         % Subtract Rational Numbers     
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   o1 = form(o1);
   o2 = form(o2);
   oo = o1;

   num1 = o1.data.num;  den1 = o1.data.den;
   num2 = o2.data.num;  den2 = o2.data.den;
   
   p1 = mul(oo,num1,den2);
   p2 = mul(oo,num2,den1);
   num = sub(oo,p1,p2);
   den = mul(oo,den1,den2);

   [num,den] = can(oo,num,den);        % cancel by common factor cf
   
   oo.data.num = num;
   oo.data.den = den;
end

%==========================================================================
% Subtract Two Polynomials
%==========================================================================

function oo = SubPoly(o1,o2)           % Subtraction Of Polynomials    
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   assert(isequal(o1.type,'poly') && isequal(o2.type,'poly'));
   
   n1 = length(o1.data.expo)-1;  
   n2 = length(o2.data.expo)-1;
      
   oo = corinth(o1,'poly');
   for (i=0:max(n1,n2))
      %o1i = trim(o1,peek(o1,i));
      %o2i = trim(o2,peek(o2,i));
      o1i = trim(peek(o1,i));
      o2i = trim(peek(o2,i));
      ooi = SubNumber(o1i,o2i);
      oo = poke(oo,ooi,i);
   end
   
   oo.work.can = false;
   oo.work.trim = false;
end

%==========================================================================
% Subtract Two Ratios
%==========================================================================

function oo = SubRatio(o1,o2)          % Subtraction Of Ratios         
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   assert(isequal(o1.type,'ratio') && isequal(o2.type,'ratio'));
   
   [ox1,oy1,~] = peek(o1);
   [ox2,oy2,~] = peek(o2);
   
   oxy1 = mul(ox1,oy2);
   oxy2 = mul(oy1,ox2);
   
   ox = SubPoly(oxy1,oxy2);
   oy = mul(oy1,oy2);
   
   oo = poke(corinth(o1,'ratio'),NaN,ox,oy);
   oo = can(oo);
end

%==========================================================================
% Subtract Two Rational Matrices
%==========================================================================

function oo = SubMatrix(o1,o2)         % Subtract Two Matrices         
   if ~(isequal(o1.type,'matrix') && isequal(o2.type,'matrix'))
      error('two rational matrices expected');
   end
   
   M1 = o1.data.matrix;
   M2 = o2.data.matrix;
   
   [m1,n1] = size(M1);  [m2,n2] = size(M2);
   
   if (m1 ~= n2 || n1 ~= n2)
      error('incompatible sizes for matrix addition');
   end
   
   for (i=1:m1)
      for (j=1:n2)
          M{i,j} = SubRatio(M1{i,j},M2{i,j});
      end
   end
   
   oo = corinth(o1,'matrix');
   oo.data.matrix = M;
end

%==========================================================================
% Helpers
%==========================================================================

function y = QuickTrim(o,x)            % Trim Mantissa                 
%
% QUICKTRIM Trim mantissa: remove leading and trailing zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end
