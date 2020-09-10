T = hrpy(phi,theta,psi)
%
% HRPY      Calculate homogeneous Roll-Pitch-Yaw rotation matrix.
%
%              Th = hrpy(phi,theta,psi)  % angels in radians
%
%              Th = hrpy(phi,theta)      % psi = 0
%              Th = hrpy(phi)            % theta = psi = 0
%              Th = hrpy                 % phi = theta = psi = 0
%
%           Basic rotations:
%
%              Roll(phi) = RotZ(phi)
%              Pitch(theta) = RotY(theta)
%              Yaw(psi) = RotX(psi)
%
%           RPY(phi,theta,psi) = RotZ(phi) * RotY(theta) * RotX(psi)
%
%           See also: ROBO, HOM, IHOM, HROT, HROTX, HROTY, HROTZ
%
   if (nargin < 1) phi = 0; end
   if (nargin < 2) theta = 0; end
   if (nargin < 1) phi = 0; end

   T = hom(rpy(phi,theta,psi),);
   
% eof   