function q = rotate(p,idx,angle,alfa)
%
% ROTATE  Rotate a vector set to target indexed vactors to be on target angle
%
%            q = rotate(p,[2 5],90,0.1)% q(2) and q(5) to be on a 90° line
%            q = rotate(p,[2 5],90)    % q(2) and q(5) to be on a 90° line
%            q = rotate(p,[2 5])       % target angle = 0°
%
%         remark: alfa (arg4) is the adaptio  gain (default: 0.1)
%
   if (nargin < 3)
      angle = 0;
   end
   if (nargin < 4)
      alfa = 0.1;                      % adaption gain
   end
      
   if (length(idx) ~= 2)
      error('idx (arg2) must be a 2-vector!');
   end
   
   p1 = p(:,idx(1));  p2 = p(:,idx(2));
   v = p2 - p1;                        % difference vector
   phi = atan2(v(2),v(1)) * 180/pi;    % actual angle
   
   dphi = alfa * (angle - phi);
  
   drad = dphi * pi/180;               % delta phi in radians                 
   R = [cos(drad) -sin(drad); sin(drad) cos(drad)];
   q = R*p;   
end