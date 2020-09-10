function Vm = vmove(V,x,y,z)
%
% VMOVE     Move a vector set relative by (x,y)
%
%              Vm = vmove(V,x,y)     % 2D vector set
%              Vm = vmove(V,[x;y])   % 2D vector set
%              Vm = vmove(V,x,y,z)   % 3D vector set
%              Vm = vmove(V,[x;y;z]) % 3D vector set
%
%           See also: ROBO, VPLT, VCAT, VTEXT, VCHIP

% Change history
%    2009-11-29 more convenient calls supported (Robo/V1k)

   [m,n] = size(V);
   
   if (nargin == 2) % 2009-11-29 more convenient calls supported (Robo/V1k)
      if (m == 2)
         if (length(x(:)) ~= 2) error('2D vector expected for arg2!'); end
         y = x(2);  x = x(1);
      elseif (m == 3)
         if (length(x(:)) ~= 3) error('3D vector expected for arg2!'); end
         z = x(3);  y = x(2);  x = x(1);
      else
         error('2D or 3D vector set expected for arg1!'); 
      end
   end
   
   if ( m == 2 )   % direct coordinates
      V(1,:) = V(1,:) + x;
      V(2,:) = V(2,:) + y;
   elseif (m == 3)
      V(1,:) = V(1,:) + x;
      V(2,:) = V(2,:) + y;
      V(3,:) = V(3,:) + z;
   else
      error('2D or 3D vector set expected for arg1!'); 
   end
   
   Vm = V;
   
% eof