function o = gcd(o,x,y)                % Greatest Common Divisor       
%
% GCD   Greatest common divisor (GCD) of two rational objects
%
%       1) GCD of two Mantissa
%
%          o = base(rat,100);
%          [cf,x,y] = gcd(o,[10 71],[4 62])   % GCD of two mantissa
%
%       2) GCD of two Objects: oo receives GCD, o1 and o2 are both
%          canceled by GCD
%
%          oo = gcd(o1,o2)             % calc GCD of o1 and o2
%
%       Example:
%
%          o = base(rat,10);
%          cf = gcd(o,[10 71],[4 62])   % divide two mantissa
%
%          => cf = [21] (gcd)
%
%       See also: CORINTH, TRIM, FORM, CAN
%
   if (nargin == 3)
      o = Gcd(o,x,y);
   else
      o1 = o;  o2 = x;                 % rename args
      o = GcdObj(o1,o2);
      if (nargout == 0)
         o.data.blue = real(o);
      end
   end
end

%==========================================================================
% Divide Two Mantissa
%==========================================================================

function cf = Gcd(o,x,y)               % GCD of two Mantissa           
   if any(x< 0)
      x = -x;
   end
   if any(y<0)
      y = -y;
   end
  
      % x and y must be trimmed!
      
   x = trim(o,x);
   y = trim(o,y);
   
   if (comp(o,x,y) >= 0)
      a = x;  b = y;
   else
      a = y;  b = x;
   end
   
      % GCD loop
      
   while (1)
      if all(b==0)
         break;
      end
      
      [q,r] = div(o,a,b);
      a = b;  b = r;
   end
   cf = a;                             % resulting common factor
end

%==========================================================================
% Divide Two Objects
%==========================================================================

function oo = GcdObj(o1,o2)            % GCD of Objects Num/Den        
   if (o1.data.base ~= o2.data.base)
      error('incompatible bases!');
   end
   
   oo = o1;
   oo.data.expo = o1.data.expo - o2.data.expo;
   
   oo.data.num = mul(o1,o1.data.num,o2.data.den);
   oo.data.den = mul(o1,o1.data.den,o2.data.num);
   oo.data.blue = [];
end