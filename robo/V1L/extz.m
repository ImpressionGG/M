function V3 = extz(V2)
%
% EXTZ      Extend 2D-vector to 3D-vector by z-coordinate
%
%              v3 = extz(v2)     % single vector
%              V3 = extz(V2)     % vector set
%
%           See also: ROBO, PRXY, PRYZ, PRZX
%

   V3 = [V2; 0*sum(V2)];

% eof   