function T = hroty(phi)
%
% HROTY     Homogeneous rotation matrix for 3D-y-axis rotation
%
%              Th = hroty(phi)
%
%           Theory:
%                           
%              HrotY(phi) = hom(RotY(phi),0]
%
%           See also: ROBO, HOM, IHOM, HROT, HROTX, HROTZ, HRPY
%

   T = hom(roty(phi),0);
   
% eof
