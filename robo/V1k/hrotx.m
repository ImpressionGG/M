function T = hrotx(phi)
%
% HROTX     Homogeneous rotation matrix for 3D-x-axis rotation
%
%              Th = hrotx(phi)
%
%           Theory:
%                           
%              HrotX(phi) = hom(RotX(phi),0]
%
%           See also: ROBO, HOM, IHOM, HROT, HROTY, HROTZ, HRPY
%

   T = hom(rotx(phi),0);
   
% eof