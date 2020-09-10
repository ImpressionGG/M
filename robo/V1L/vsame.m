function S = vsame(V,index)
%
% VSAME     Create a vector set consisting of same vectors.
%           Use dimension of a given vector set and index of "same vector"
%
%              S = vsame(V,index)
%              S = vsame(V)          % index = 1
%
%           Note:
%
%              vset(Vx,Vy,Vz) = vset(Vx(:),Vy(:),Vz(:))
%
%           See also: ROBO, VPLT
%
   if (nargin < 2)
      index = 1;
   end
   
   S = V(:,index)*ones(1,size(V,2));
   
% eof