function v = vfid(r,pos)
%
% VFID        Create vector set representing a fiducial
%             Standard shape: caro inside square
%
%                v = vfid         % radius 1
%                v = vfid(r)      % radius r
%                v = vfid(r,pos)  % n fiducials at pos
%
%             Example:
%                pos = [[2 2]' [8 8]'];
%                v = vfid(1,pos);
%             See also: VSET VCHIP

% Change history
%    2009-11-29 created (Robo/V1k)

   if (nargin < 1)
       r = 1;
   end
   if (nargin < 2)
       pos = [0;0];
   end
   
   [m,n] = size(pos);
   if (m ~= 2) 
       error('2 rows expected for arg 2!');
   end
   
   v = [];    % init
   for (i = 1:n)
      v1 = vmove(vrect(2,2),-1,-1)*r;
      v2 = [[-1 0]' [0 1]' [1 0]' [0 -1]' [-1 0]']*r;
      vi = vmove(vcat(v1,v2),pos(1,i),pos(2,i));
      v = vcat(v,vi);
   end
   
% eof   