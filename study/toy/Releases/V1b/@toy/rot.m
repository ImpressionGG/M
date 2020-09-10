function [Xo,Yo,Zo] = rot(obj,X,Y,Z,az,el)
%
% ROT   General 3D Rotation matrix according to azimulth & elongation
%       Set options azimuth and elongation to control 3D rotation
%
%          [Xo,Yo,Zo] = rot(obj,X,Y,Z,az,el);
%
%          obj = option(toy,'azimuth',pi/3);
%          obj = option(obj,'elongation',pi/4);
%          [Xo,Yo,Zo] = rot(obj,X,Y,Z);           % az,el passed by option
%  
%       Also an explicite rotation matrix can be provided (5 input args)
%
%          [Xo,Yo,Zo] = rot(obj,X,Y,Z,T);
%
%       In alternative a coordinate transformation according to the
%       required 3D rotation can be performed.
%
   if (nargin < 5)
      az = either(option(obj,'azimuth'),0);
      el = either(option(obj,'elongation'),0);
   end

   if (nargin == 5)
      T = az; 
   else
      Ty = roty(obj,el);    % elongation
      Tz = rotz(obj,az);    % azimuth
   
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
