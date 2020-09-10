function [phi,x,y,sig,T] = ellipse(o,x,y)
%
% ELLIPSE  Estimate ellipse fit and return rotation angle [°] as well as
%          x and y vector to plot an ellipse
%
%             [phi,x,y] = ellipse(o,X,Y)    % get ellipse angle and x,y
%             plot(x,y)                     % plot ellipse
%             title(sprintf('phi:%g°',phi)) % display angle
%
%          More output args: sig(1) and sig(2) are sigma values, meaning
%          3*sig(1) is the length of the principal axis and 3*sig(2) is the
%          length of the non-principal axis, while T is the rotation matrix
%
%             [phi,x,y,sig,T] = ellipse(o,x,y)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CUTE
%
   threshold = 1 - opt(o,{'cpk.pareto',0.99});
   
   r = sqrt(x.*x + y.*y);
   idx = find(r > threshold*max(r));

   C = cov(x(idx),y(idx));
   [V,S] = eig(C);
   s = diag(S);
   
   phi = atan2(V(2,1),V(1,1)) + pi/2;
   while (phi > pi/2)
      phi = phi-pi;
   end
   while (phi < -pi/2)
      phi = phi+pi;
   end
   phi = phi*180/pi;
   
   T = [0 1;1 0] * V';
   Y = T*[x(:)  y(:)]';
      
   sig(1) = std(Y(1,idx));
   sig(2) = std(Y(2,idx));
   
   p = 0:pi/100:2*pi;
   X = T' * 3*[sig(1)*cos(p); sig(2)*sin(p)];
   
   x = X(1,:);  y = X(2,:);
end

