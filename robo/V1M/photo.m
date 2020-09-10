function F = photo(C,V)
%
% PHOTO     Photo projection with respect to a camera
%
%              F = photo(C,V)   % photo projection with respect to camera C
%              F = photo(V)     % xy-projection, C = (camera[0 0 0],[1,1])
%
%           Meaning of the arguments
%
%              C: homogeneous coordinate frame matrix of camera
%              V: 2D, 3D or 4H vector set
%              F: 2D vector set of photo
%
%           Theory:
%
%              1) U = C * hom(V)
%              2) F = prxy(ihom(U))
%
%           Example:
%
%              C = camera([0 2 0],[80 40],[30 30 30]*deg);
%              V = vchip;
%              F = photo(C,V);
%              vplt(F);
%
%           See also: ROBO, HOM, IHOM, PRXY, CAMERA, VPLT
%
   if (nargin == 1)
      V = C;
      C = camera([0 0 0],[1 1]);  % camera for pure x-y-projection
   end

   [m,n] = size(C);
   if (size(V,1) < m-1)
      V(m-1,1) = 0;               % automatically add zeros
   end
   
   U = C*hom(V);
   F = prxy(ihom(U));
   
% eof