function T = roty(obj,phi)
%
% ROTY      Rotation matrix for 3D-y-axis rotation
%
%              T = roty(obj,phi)
%
%           Theory:
%                          [  cos(phi)   0    sin(phi)]
%              RotY(phi) = [     0       1       0    ]
%                          [ -sin(phi)   0    cos(phi)]
%
%           See also: ROBO, ROT, ROTX, ROTZ, RPY
%
   T = [  cos(phi)  0   sin(phi)
             0      1     0
         -sin(phi)  0   cos(phi)
       ];
   return
end