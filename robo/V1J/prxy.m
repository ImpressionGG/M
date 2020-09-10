function Vp = prxy(V)
%
% PRXY      x-y projection
%
%              vp = prxy(v)    % projection of a single vector
%              Vp = prxy(V)    % projection of a set of vectors
%
%           The function deals both with normal and homogeneous coordinates
%
%           See also: ROBO, PRXY, PRYZ, PRZX, HPROJ
%

   Vp = V;
   Vp(3,:) = [];
   
% eof