function Vp = pryz(V)
%
% PRYZ      y-z projection
%
%              vp = pryz(v)    % projection of a single vector
%              Vp = pryz(V)    % projection of a set of vectors
%
%           The function deals both with normal and homogeneous coordinates
%
%           See also: ROBO, PRXY, PRYZ, PRZX, HPROJ
%

   Vp = V;
   Vp(1,:) = [];
   
% eof