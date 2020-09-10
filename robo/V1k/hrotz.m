function T = hrotz(phi)
%
% HROTZ     Homogeneous rotation matrix for 3D-z-axis rotation
%
%              Th = hrotz(phi)
%
%           Theory:
%                           
%              HrotZ(phi) = hom(RotZ(phi),0]
%
%           See also: ROBO, HOM, IHOM, HROT, HROTX, HROTY, HRPY
%

   T = hom(rotz(phi),0);
   
% eof
