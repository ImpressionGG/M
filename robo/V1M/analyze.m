function [result,out2,out3] = analyze(V)
%
% ANALYZE   Analyze a given vector set
%
%              analyze(V)            % textual display of results
%              result = analyze(V)   % return resulting values by a row vector
%
%           Description: The result matrix consists of seveal rows, where
%           each column represents the standard deviations and max errors
%
%              result(:,1)   % standard deviation (distance)
%              result(:,2)   % x-standard deviation
%              result(:,3)   % y-standard deviation
%              result(:,4)   % z-standard deviation
%              result(:,5)   % max deviation (distance)
%              result(:,6)   % max x-deviation
%              result(:,7)   % max y-deviation
%              result(:,8)   % max z-deviation
%
%           The rows represent mapping errors with respect to different kind of 
%           transformations
%
%              result(1,:)   % translation and scaling
%              result(2,:)   % pure rotation
%              result(3,:)   % traslation and rotation
%              result(4,:)   % traslation, rotation, scale
%              result(5,:)   % affine mapping (traslation, rotation, scale, shear)
%              result(6,:)   % order 2 mapping
%          
%           See also: ROBO, VPLT, VCAT, VLETTER, VCHIP
%

   V = velim(V);     % eliminate NANs
   [m,n] = size(V);
   
   if ( m ~= 2 )
      error('2D vector set expected!')
   end

% locate corners

   x = V(1,:);  y = V(2,:);
   x0 = (min(x) + max(x))/2;
   y0 = (min(y) + max(y))/2;
   
   dx = x-0;  dy = y-y0;
   
% construct several objective functions to detect corners
   
   f = -dx-dy;  idx = find(f==max(f));  ill = idx(1);  % lower left corner
   f =  dx-dy;  idx = find(f==max(f));  ilr = idx(1);  % lower right corner
   f = -dx+dy;  idx = find(f==max(f));  iul = idx(1);  % upper left corner
   f =  dx+dy;  idx = find(f==max(f));  iur = idx(1);  % upper right corner
   
   vll = V(ill);  vlr = V(ilr);  vul = V(iul);  vur = V(iur);
   
% construct coordinate origin vector coordinate Base
   
   vS0 = vll;  sx = vlr - vll;  sy = vul - vll;  S0 = [sx,sy];   
   
% Translation und Skalierung 

   T = inv(hom(scale([norm(sx) norm(sy) 1]),vS0));
   F = photo(T,V);
   result = maperr(V,F);
   out2 = T;
   out3 = [vll vlr vul vur];

% eof
   