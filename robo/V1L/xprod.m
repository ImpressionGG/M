function V = vset(Vx,Vy,Vz)
%
% VSET      Create a 2D or 3D vector set
%
%              V = vset(Vx,Vy)
%              V = vset(Vx,Vy,Vz)
%
%           Note:
%
%              vset(Vx,Vy,Vz) = vset(Vx(:),Vy(:),Vz(:))
%
%           See also: ROBO, VPLT
%
   if (nargin == 2)
      V = [Vx(:),Vy(:)]';
   elseif (nargin == 3)
      V = [Vx(:),Vy(:),Vz(:)]';
   else
      error('2 or 3 inut args expected!');
   end
   
% eof