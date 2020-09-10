function S = shear(sxy,sxz,syz)
%
% SHEAR     2D or 3D shear matrix
%
%              S = shear(s)               % 2D shear-x matrix
%              S = shear(s)'              % 2D shear-y matrix
%              S = shear(sxy,sxz,syz)     % 3D shaer-xy matrix
%              S = shear([sxy,sxz,syz])   % 3D shaer-xy matrix
%
%           Theory:
%                          [ 1    s ]
%              2D: Shaer = [        ]
%                          [ 0    1 ]
%
%                          [ 1  sxy sxz ]
%              3D: Shaer = [ 0   1  syz ]
%                          [ 0   0   1  ]
%
%           See also: ROBO, ROTX, ROTY, ROTZ, RPY, SCALE
%
   if (nargin == 1)
      
      if (length(sxy) == 1)
         S = [1 sxy; 0 1];
      elseif(length(sxy(:))==3)
         S = [1 sxy(1) sxy(2); 0 1 sxy(3); 0 0 1];
      else
         error('arg1 must be scalar or vector(3)!')
      end
               
   elseif (nargin == 3)
      
      S = [1 sxy sxz; 0 1 syz; 0 0 1];
      
   else
      error('One or three arguments expected!')
   end
    
% eof