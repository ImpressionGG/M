function o = add(o,x,y)                % add two rational numbers
%
% ADD   Add two rational numbers or functions
%
%          o = base(rat,100);
%          z = add(o,[26 19 25 94],[17 28 89])
%
%       See also: RAT
%
   if (nargin == 3)
      o = Add(o,x,y);
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

   base = o.base;
   z = x + y;
   for (i=length(x):-1:1)
      if (z(i) >= base)
         z(i) = z(i) - base;
         z(i-1) = z(i-1) + 1;
      end
   end
   
   z = trim(o,z);
end