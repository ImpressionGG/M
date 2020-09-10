function K = scale(k1,k2,k3)
%
% SCALE     2D or 3D scale matrix
%
%              K = scale(k1,k2)           % 2D scale matrix
%              K = scale([k1,k2])         % 2D scale matrix
%              K = scale(k1,k2,k3)        % 3D scale matrix
%              K = scale([k1,k2,k2])      % 3D scale matrix
%
%           Theory:
%                          [ k1   0 ]
%              2D: Scale = [        ]
%                          [ 0   k2 ]
%
%                          [ k1  0   0 ]
%              3D: Shaer = [ 0   k2  0 ]
%                          [ 0   0   k3]
%
%           See also: ROBO, ROTX, ROTY, ROTZ, RPY, SHEAR
%
   if (nargin == 1)
      
      K = diag(k1(:));
      
   elseif (nargin == 2)
      
      K = diag([k1 k2]);
      
   elseif (nargin == 3)
      
      K = diag([k1 k2 k3]);
      
   else
      error('One, two or three arguments expected!')
   end
    
% eof