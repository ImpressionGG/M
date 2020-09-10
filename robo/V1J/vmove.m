function Vm = vmove(V,x,y,z)
%
% VMOVE     Move a vector set relative by (x,y)
%
%              Vm = vmove(V,x,y)
%
%           See also: ROBO, VPLT, VCAT, VTEXT, VCHIP
%
   [m,n] = size(V);
   
   if ( m <= 2 )   % direct coordinates
      V(1,:) = V(1,:) + x;
      V(2,:) = V(2,:) + y;
   else
      V(1,:) = V(1,:) + V(m,:)*x;
      V(2,:) = V(2,:) + V(m,:)*y;
   end
   
   Vm = V;
   
% eof