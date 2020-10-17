function z = qmul(o,x,y)
%
% QMUL   Quick multiplication of two mantissa
%
%           z = qmul(o,x,y)            % same as z = mul(o,x,y)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, MUL
%
   sgn = +1;
   if any(x < 0)
      x = -x;  sgn = -sgn;
   end      
   if any(y < 0)
      y = -y;  sgn = -sgn;
   end

   z = conv(x,y);                      % convolution of x and y
   z = qtrim(o,z);                     % trim away convolution overflows
   
   if (sgn < 0)
      z = -z;
   end
end
