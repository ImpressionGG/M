function T = rotx(obj,phi)
%
% ROTX      Rotation matrix for 3D-x-axis rotation
%
%              T = rotx(obj,phi)
%
%           Theory:
%                          [  1    0        0      ]
%              RotX(phi) = [  0  cos(phi) -sin(phi)]
%                          [  0  sin(phi)  cos(phi)]
%
%           See also: ROBO, ROT, ROTY, ROTZ, RPY
%
   T = [  1    0        0
          0  cos(phi) -sin(phi)
          0  sin(phi)  cos(phi)
       ];
   return
end
