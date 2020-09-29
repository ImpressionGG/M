function z = qadd(o,x,y)
%
% QADD   Quick adding of two mantissa
%
%           z = qadd(o,x,y)            % same as z = add(o,x,y)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, ADD, QMUL, QTRIM
%
   sgnx = any(x>0) - any(x<0);
   sgny = any(y>0) - any(y<0);
   
   if (sgnx < 0 || sgny < 0)
      if (sgnx < 0 && sgny > 0)
         z = qsub(o,y,-x);
      elseif (sgnx > 0 && sgny < 0)
         z = qsub(o,x,-y);
      else
         z = -qadd(o,-x,-y);
      end
      return
   end
   
      % ok - all x and y values are positive now - let's go ...
      
   assert(all(x>=0) && all(y>=0))
   nx = length(x);  ny = length(y);  n = 1+max(nx,ny);
   
      % make same length mantissa ...
      
   x = [zeros(1,n-nx) x];
   y = [zeros(1,n-ny) y];
   
      % add mantissa
      
   sgn = +1;                           % positive result so far
   z = x + y;
   
      % investigate

   z = qtrim(o,z);                     % trim away convolution overflows
   
   if (sgn < 0)
      z = -z;
   end
end
