function z = qsub(o,x,y)
%
% QSUB   Quick subtraction of two mantissa
%
%           z = qsub(o,x,y)            % same as z = sub(o,x,y)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, ADD, QMUL, QTRIM
%
   sgnx = any(x>0) - any(x<0);
   sgny = any(y>0) - any(y<0);
   
   if (sgnx < 0 || sgny < 0)
      if (sgnx < 0 && sgny > 0)
         z = -qadd(o,-x,y);
      elseif (sgnx > 0 && sgny < 0)
         z = qadd(o,x,-y);
      else
         z = -qsub(o,-x,-y);
      end
      return
   end
   
      % ok - all x and y values are positive now - let's go ...
      
   assert(all(x>=0) && all(y>=0))
   nx = length(x);  ny = length(y);  n = 1+max(nx,ny);
   
      % make same length mantissa ...
      
   x = [zeros(1,n-nx) x];
   y = [zeros(1,n-ny) y];
   
      % find the bigger one: build the difference vectors (x-y) and apply
      % the signum function
      
   sgn = sign(x-y);
   idx = find(sgn);
   
      % if idx is empty ten all digits are the same, thus the difference
      % is zero and we are done
      
   if isempty(idx)
      z = 0;                           % difference is zero
      return                           % done - bye!
   end
   
      % otherwise there is a first non-zero signum value. This value
      % determines whether result is positive or negative
      
   if sgn(idx(1)) < 0
      sgn = -1;
      tmp = x;  x = y;  y = tmp;       % swap x and y
   else
      sgn = +1;                        % otherwise we can just continue
   end
   
      % subtract mantissa and use borrow trimming afterwards
      
   z = x - y;
   z = Btrim(o,z);                     % trim away convolution overflows
   
      % final correction of sign
      
   if (sgn < 0)
      z = -z;
   end
end

function x = Btrim(o,x)                % Borrow Trimming                
%
% BTRIM  Borror trimming of mantissa (resolves underflows)
%
%           x = Btrim(o,x)             % borrow trimming of mantissa
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, QADD, QMUL, QTRIM
%   
      % fetch base and calc borrow
   
   b = o.data.base;                 % fetch base
   c = (x < 0);                     % borrow

      % as long as we have non zero borrow we have to process borrow
      
   while any(c)                     % while any non processed borrow
      x = [0 x+c*b];                % selective add borrow*base
      c = [c 0];                    % left shift borrow 
      x = x - c;                    % subtract shifted borrow to result
      c = (x < 0);                  % calculate new borrow
   end

   idx = find(x~=0);
   if ~isempty(idx)
      x(1:idx(1)-1) = [];
   end
end
