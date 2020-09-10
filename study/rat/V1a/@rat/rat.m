classdef rat
%
%  RAT   Rational function objects
%
%           o = rat(3.14)              % 314/100
%           o = rat(23,35)             % 23/35
%
%  Copyright(c): Bluenetics 2020 
%
   properties
      base                             % digit base
      num                              % numerator
      den                              % denominator
      real                             % real value
   end
   methods
      function o = rat(arg1,arg2)      % Corazita Class Constructor      
         o.base = 1e6;
         if (nargin < 1)
            arg1 = 1;  arg2 = 1;
         end
         
         if (nargin <= 1)
            base = o.base;
            den(1) = 1;
            num = [];
                        
               % calculate expo
               
            o.real = arg1; 
 
            sign = 2*(arg1>=0) - 1;
            mantissa = arg1*sign;
            logb = log10(mantissa) / log10(base);

            expo = floor(logb);
            x = mantissa / base^expo;

               % calculate mantissa
               
            if (x >= 1)
               num = floor(x);
               x = x - num;
            elseif (x == 0)
               num = 0;
            end
            
            while (x ~= 0)
               x = x * base;
               dig = floor(x);
               x = x - dig;
               
               num(1,end+1) = dig;
               den(1,end+1) = 0;
            end
            
               % adjust num or den according to expo
               
            if (expo > 0)
               num = [num,zeros(1,expo)];
            elseif (expo < 0)
               den = [den,zeros(1,expo)];
            end
 
            num = num * sign;
         else 
            o.real = arg1;
            num = int64(real);
            den = int64(real);
         end
         o.num = num;  o.den = den;
      end
   end
end
