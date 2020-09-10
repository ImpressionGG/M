function o = mul(o,x,y)                % Multiply Two Rational Objects
%
% MUL   Multiply two rational objects
%
%          o = base(rat,100);
%          z = mul(o,[26 19 25 94],[17 28 89])    % multiply two mantissa
%
%       See also: RAT, TRIM, FORM, COMP, ADD, SUB, MUL, DIV
%
   if (nargin == 3)
      o = Mul(o,x,y);
   end
end

%==========================================================================
% Multiply Two Mantissa
%==========================================================================

function z = Mul(o,x,y)                % Mantissa Multiplication       
   x = trim(o,x);
   y = trim(o,y);

   sign = 1;
   if any(x< 0)
      x = -x;  sign = -sign;
   end
   if any(y<0)
      y = -y;  sign = -sign;
   end
   
   base = o.base;
   
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
         t = [carry t];         % assert(carry == 0);
      end
      z = add(o,z,t);
   end
   z = sign*z;
end
