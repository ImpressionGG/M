function oo = number(o,num,den,xpo)
%
% NUMBER Construct a rational number, either from a real number or from
%        numerator/denominator integer arrays
%
%           o = corinth                % base 1e6
%           oo = number(o,8.88)        % 888/100 = 222/5 @ base 1e6
%           oo = number(o,5,6)         % 5/6 @ base 1e6
%           
%           o = base(corinth,100)      % corinthian object @ base 100
%           oo = number(o,pi)          % rational repr. of pi @ base 100
%
%           oo = number(o,num,den,xpo) % num/den * base^xpo
%           oo = number(o,num,den)     % num/den (xpo = 0)
%
%           o = base(corinth,100)      % corinthian object @ base 100
%           oo = number(o,[4 17],[7],3)%  417/7 * 100^3
%
%        Method NUMBER is also used for casting of proper polynomials or 
%        rational functions (matrices) to rational numbers
%
%           oo = poly(o,[7.5])
%           oo = number(oo)
%
%           oo = ratio(o,[3],[4])      % 1x1 rational 
%           oo = number(oo)            % cast rational function to number
%
%        Casting
%           oo = number(o)             % cast to a number
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, POLY, RATIO, MATRIX
%
   if (nargin == 1)                    % casting
      oo = Cast(o);
   elseif (nargin == 2)
      oo = Number(o,num);
   elseif (nargin == 3)
      oo = NumDen(o,num,den,0);
   elseif (nargin == 4)
      oo = NumDen(o,num,den,xpo);
   else
      error('bad arg list');
   end
   
   oo = can(oo);
   oo = trim(oo);
end

%==========================================================================
% Rational Number Construction
%==========================================================================

function [num,den,xpo] = Number(o,arg)    % Construct rational Number  
   den = 1;
   num = [];

      % for zero arg we have a special treatement
      
   if isequal(arg,0)
      num = 0;  xpo = 0;
      if (nargout <= 1)
         o.type = 'number';
         num = poke(o,xpo,num,den);
      end
      return;
   end
   
      % calculate expo

   sign = 2*(arg>=0) - 1;
   mantissa = arg*sign;
   logb = log10(mantissa) / log10(o.data.base);
   xpo = floor(logb);
      
      % integers and floats are differently processed!
      
   if (floor(mantissa) == mantissa)    % integer processing ...
      [num,den] = Integer(mantissa,o.data.base,xpo);
   else                                % float processing ...
      [num,den] = Float(mantissa,o.data.base,xpo);
   end
   
      % work in sign

   num = num * sign;
   
      % cancel numerator and denominator

   [num,den] = can(o,num,den);

      % poke num,den & xpo into data

   if (nargout == 1)
      oo = poke(corinth(o,'number'),xpo,num,den);
      num = oo;                        % return out arg
   end
   
   function [num,den] = Integer(mantissa,base,xpo)                     
   %
   % INTEGER  Calculate num/den for integer number
   %
      assert(xpo >= 0);                % for integers
      assert(mantissa>=0);             % need to be non-negative
      
      num(xpo+1) = rem(mantissa,base);
      den(xpo+1) = 0;                  % store '1' at the end
      
         % build up in reverse order (re-order after loop)
         
      for (i=xpo:-1:1)
         mantissa = floor(mantissa/base);
         num(i) = rem(mantissa,base); 
         den(i) = 0;                 
      end
      
      den(1) = 1;                      % always like that for integers
   end
   function [num,den] = Float(mantissa,base,xpo)                       
   %
   % FLOAT  Calculate num/den for floating point numbers
   %
      den = 1;
      x = mantissa / base^xpo;
      if (x >= 1)
         num = floor(x);
         x = x - num;
      elseif (x == 0)
         num = 0;
      end

      while (abs(x) > 10000*eps)       % calulate 'digits'  
         x = x * base;
         dig = floor(x);
         x = x - dig;

         num(1,end+1) = dig;
         den(1,end+1) = 0;
      end      
   end
end
function oo = OldNumber(o,arg)         % Construct a Rational Number   
   base = o.data.base;
   den = 1;
   
   if isequal(arg,0)
      oo = poke(o,0,0,1);              % number zero
      return;
   end
   num = [];

      % calculate expo

   sign = 2*(arg>=0) - 1;
   mantissa = arg*sign;
   logb = log10(mantissa) / log10(base);

   xpo = floor(logb);
   x = mantissa / base^xpo;

      % calculate mantissa

   if (x >= 1)
      num = floor(x);
      x = x - num;
   elseif (x == 0)
      num = 0;
   end

   while (abs(x) > 10000*eps)          % calulate 'digits'             
      x = x * base;
      dig = floor(x);
      x = x - dig;

      num(1,end+1) = dig;
      den(1,end+1) = 0;
   end

      % work in sign

   num = num * sign;
   
   oo = poke(corinth(o,'number'),xpo,num,den);
   oo = can(oo);
end
function oo = NumDen(o,num,den,xpo)    % Construct Number From Num/Den 
   base = o.data.base;

      % check if all num/den digits and exponent are integer
      
   if any(round(num) ~= num)
      error('all numerator dgits must be integer');
   end
   if any(round(den) ~= den)
      error('all denominator dgits must be integer');
   end
   if (round(xpo) ~= xpo)
      error('exponent must be integer');
   end

      % check consistency of num/den
      
   if any(abs(num) >= base)
      error('all numerator dgits must be (absolute) less than base');
   end
   if any(abs(den) >= base)
      error('all denominator dgits must be (absolute) less than base');
   end
   
      %  construct number
      
   oo = poke(corinth(o,'number'),xpo,num,den);
   oo = can(oo);
end

%==========================================================================
% Cast Corinthian Object To a Polynomial
%==========================================================================

function oo = Cast(o)                  % Cast CORINTH To Polynomial    
   switch o.type
      case 'number'
         oo = o;                       % easy :-)
      case 'poly'
         if (order(o) ~= 0)
            error('cannot convert non polynomial to poly');
         end
         oo = peek(o,0);               % peek 0-th coefficient
      case 'ratio'
         oo = poly(o);
         oo = Cast(o);
      case 'matrix'
         oo = ratio(o);                % cast matrix to ratio
         oo = poly(o);                 % cast ratio to polynomials
         oo = Cast(o);                 % cast ratio to polynomial
      otherwise
         error('internal')
   end
end
