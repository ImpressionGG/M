function [C,Erot] = cmap(K,E,kind,idx)
%
% CMAP      Compensation map
%
%              C = cmap(K,E,kind,idx)
%              C = cmap(K,E)          % kind = 1, idx = corners
%              C = cmap(K,E,-1)       % kind = -1: translation und Rotation
%
   if ( nargin < 3 ) kind = 1; end         % affine map
   if ( nargin < 4 ) 
      eval('idx = corners;');              % indices of corners
   end                                     % suppress syntax check by using eval!
   
   Kidx = K(:,idx);  Eidx = E(:,idx);
   
   if ( kind > 0 )
      C = map(K,E,kind);
   else
      xk = K(1,:);  yk = K(2,:);
      ill = find(xk == min(xk) & yk == min(yk));  ill = ill(1);
      iur = find(xk == max(xk) & yk == max(yk));  iur = iur(1);
      
      phiK = atan((yk(iur)-yk(ill))/(xk(iur)-xk(ill)));
      
      Q = K-E;
      xq = Q(1,:);  yq = Q(2,:);
      
      phiQ = atan((yq(iur)-yq(ill))/(xq(iur)-xq(ill)));
      
      phi = phiK-phiQ;
      Erot = rot(phi)*K-K;
      
      C = map(K,Erot,1);    % noch einmal Abildung zum Fehler hin!
   end
   
% eof
   