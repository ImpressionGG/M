function Vp = przx(V)
%
% PRYZ      z-x projection
%
%              vp = przx(v)    % projection of a single vector
%              Vp = przx(V)    % projection of a set of vectors
%
%           The function deals both with normal and homogeneous coordinates
%
%           See also: ROBO, PRXY, PRYZ, PRZX, HPROJ
%

   Vp = V;
   Vp(2,:) = [];
   Vp(1:2,:) = Vp([2 1],:);
   
% eof