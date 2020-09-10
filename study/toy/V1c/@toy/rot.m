function [Xo,Yo,Zo] = rot(o,X,Y,Z,az,el)
%
% ROT   General 3D Rotation matrix according to azimulth & elongation
%       Set options azimuth and elongation to control 3D rotation
%
%          [Xo,Yo,Zo] = rot(o,X,Y,Z,az,el);
%
%          o = opt(toy,'azimuth',pi/3);
%          o = opt(o,'elongation',pi/4);
%          [Xo,Yo,Zo] = rot(o,X,Y,Z);           % az,el passed by option
%  
%       Also an explicite rotation matrix can be provided (5 input args)
%
%          [Xo,Yo,Zo] = rot(o,X,Y,Z,T);
%
%       In alternative a coordinate transformation according to the
%       required 3D rotation can be performed.
%
   if (nargin < 5)
      az = either(opt(o,'azimuth'),0);
      el = either(opt(o,'elongation'),0);
   end

   if (nargin == 5)
      T = az; 
   else
      Ty = roty(o,el);    % elongation
      Tz = rotz(o,az);    % azimuth
   
      T = Tz * Ty;
   end
   
   if (nargout == 1)
      Xo = T;
      return
   end
   
   Xo = T(1,1)*X + T(1,2)*Y + T(1,3)*Z; 
   Yo = T(2,1)*X + T(2,2)*Y + T(2,3)*Z; 
   Zo = T(3,1)*X + T(3,2)*Y + T(3,3)*Z;

   return
end
