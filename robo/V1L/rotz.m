function T = rotz(phi)
%
% ROTZ     Rotation matrix for 3D-z-axis rotation
%
%              T = rotz(phi)
%
%           Theory:
%                          [  cos(phi) -sin(phi)  0  ]
%              RotZ(phi) = [  sin(phi)  cos(phi)  0  ]
%                          [     0         0      1  ]
%
%           See also: ROBO, ROT, ROTX, ROTY, RPY
%
   T = [  cos(phi) -sin(phi)   0
          sin(phi)  cos(phi)   0 
             0         0       1  
       ];
    
% eof