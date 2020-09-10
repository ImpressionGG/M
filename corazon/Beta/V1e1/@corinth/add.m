function o = add(o,x,y)                % Add Two Rational Objects
%
% ADD   Add two rational objects
%
%       1) Adding Mantissa
%
%          o = base(corinth,100);
%          z = add(o,[26 19 25 94],[17 28 89])
%
%       2) Adding Objects
%
%          oo = add(o1,o2)
%
%       See also: CORINTH, SUB, MUL, DIV, COMP
%
   if (nargin == 3)
      o = Add(o,x,y);
   else
      switch o.type
         case 'number'
            o = AddNumber(o,x);
         case 'poly'
            o = AddPoly(o,x);
         case 'ratio'
            o = AddRatio(o,x);
         case 'matrix'
            o = AddMatrix(o,x);
         otherwise
            error('implermentation restriction!');
      end
   end
end

%==========================================================================
% Add Two Mantissa
%==========================================================================

function z = Add(o,x,y)                % Mantissa Addition             
   if (all(y>=0) && any(x<0))
      z = sub(o,y,-x);
      return
   elseif (all(x>=0) && any(y<0))
      z = sub(o,x,-y);
      return
   elseif (any(x<0) && any(y<0))
      z = -Add(o,-x,-y);
      return
   end
   
   [x,y] = form(o,x,y,1);

   base = o.data.base;
   z = x + y;
   for (i=length(x):-1:1)
      if (z(i) >= base)
         z(i) = z(i) - base;
         z(i-1) = z(i-1) + 1;
      end
   end
   
   z = trim(o,z);
end

%==========================================================================
% Add Two Numbers
%==========================================================================

function oo = AddNumber(o1,o2)         % Addition Of Numbers           
%   
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   o1 = form(o1);
   o2 = form(o2);
   oo = o1;

   [num1,den1,~] = peek(o1);
   [num2,den2,~] = peek(o2);
   
   p1 = mul(oo,num1,den2);
   p2 = mul(oo,num2,den1);
   num = add(oo,p1,p2);
   den = mul(oo,den1,den2);
   
   [num,den] = can(oo,num,den);        % cancel by common factor cf
   
   oo.data.num = num;
   oo.data.den = den;
end

%==========================================================================
% Add Two Polynomials
%==========================================================================

function oo = AddPoly(o1,o2)           % Addition Of Polynomials       
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   assert(isequal(o1.type,'poly') && isequal(o2.type,'poly'));
   
   n1 = length(o1.data.expo)-1;  
   n2 = length(o2.data.expo)-1;
      
   oo = corinth(o1,'poly');
   for (i=0:max(n1,n2))
      o1i = trim(o1,peek(o1,i));
      o2i = trim(o2,peek(o2,i));
      ooi = AddNumber(o1i,o2i);
      oo = poke(oo,ooi,i);
   end
   
   oo = can(oo);
end

%==========================================================================
% Add Two Ratios
%==========================================================================

function oo = AddRatio(o1,o2)           % Addition Of Ratios           
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   assert(isequal(o1.type,'ratio') && isequal(o2.type,'ratio'));
   
   [ox1,oy1,~] = peek(o1);
   [ox2,oy2,~] = peek(o2);
   
   oxy1 = mul(ox1,oy2);
   oxy2 = mul(oy1,ox2);
   
   ox = AddPoly(oxy1,oxy2);
   oy = mul(oy1,oy2);
   
   oo = poke(corinth(o1,'ratio'),NaN,ox,oy);
   oo = can(oo);
end

%==========================================================================
% Add Two Rational Matrices
%==========================================================================

function oo = AddMatrix(o1,o2)         % Add Two Matrices              
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
          M{i,j} = AddRatio(M1{i,j},M2{i,j});
      end
   end
   
   oo = corinth(o1,'matrix');
   oo.data.matrix = M;
end
