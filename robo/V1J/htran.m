function T = htran(r0)
%
% HTRAN     Homogeneous translation matrix for 2D or 3D translation
%
%              T = htran([x y])     % 4H matrix for 2D translation
%              T = htran([x y z])   % 4H matrix for 3D translation
%
%           See also: ROBO, HOM, IHOM, HROTX, HROTY, HROTZ, HRPY
%

   r0 = r0(:);
   if ( length(r0) == 2 ) r0 = [r0;0]; end
   
   T = hom(eye(3),r0);
   
% eof