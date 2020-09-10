function P = hproj(lambda)
%
% PROJ      Homogeneous perspective projection matrix
%
%              Ph = hproj(lambda)
%              Ph = hproj            % lambda = 1
%
%           Theory:
%                             [ eye(3) zeros(3,1)]
%              Proj(lambda) = [                  ]
%                             [ 0  0  -1/lambda 1]
%
%           See also: ROBO, ROTX, ROTY, ROTZ, RPY
%
   if (nargin < 1) lambda = 1; end

   P = [  1     0     0     0
          0     1     0     0
          0     0     1     0
          0     0 -1/lambda 1
       ];
    
% eof