function o = sub(o,x,y)                % Subtract Two Rational Objects 
%
% SUB   Subtract two rational objects
%
%          o = base(rat,100);
%          z = sub(o,[26 19 25 94],[17 28 89])   % subtract mantissa
%
%       See also: RAT, TRIM, MATCH, COMP, ADD, SUB, MUL, DIV
%
   if (nargin == 3)
      o = Sub(o,x,y);
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
      z = trim(o,0*x);
      return
   end
   
   base = o.base;
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
   z = trim(o,z);
end
