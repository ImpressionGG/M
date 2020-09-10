function q = translate(p,idx,origin,alfa)
%
% TRANSLATE  Translate vector set to target indexed vector to be on target origin
%
%            q = rotate(p,[2 5],90,0.1)% q(2) and q(5) to be on a 90° line
%            q = rotate(p,[2 5],90)    % q(2) and q(5) to be on a 90° line
%            q = rotate(p,[2 5])       % target angle = 0°
%
%         remark: alfa (arg4) is the adaptio  gain (default: 0.1)
%
   if (nargin < 3)
      origin = 0*p(:,1);
   end
   if (nargin < 4)
      alfa = 0.1;                      % adaption gain
   end
      
   if (length(idx) == 0)
      p0 = mean(p')';
   else   
      p0 = p(:,idx);
   end

   dq = (origin-p0);
      
   [m,n] = size(p);
   q = p + alfa*dq*ones(1,n);
end