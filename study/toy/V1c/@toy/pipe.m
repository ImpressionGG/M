function [X,Y,Z] = pipe(obj,x,y,z,r,m)
%
% PIPE       Calculate X,Y,Z for a surface plot. The vectors x,y,z
%            represent the path of the pipe, r is the radius.
%
%               [X,Y,Z] = pipe(obj,x,y,z,r);       % calc X,Y,Z of a pipe
%               surf(obj,X,Y,Z,'r');
%
%            See also: TOY
%
   if (nargin < 6)
      m = 40;           % 40 points around the circumference of the pipe
   end
   
   if ~length(x) == length(y) || length(y) ~= length(z)
      error('x,y and z must have the same length');
   end
   
   n = length(x);
   
   if (n < 3)
      error('at least 3 points expected for the pipe')
   end
   
      % calculate 1st and second normal vectors
   
   for (i=2:n-1)
      s1 = [x(i+0)-x(i-1); y(i+0)-y(i-1); z(i+0)-z(i-1)];
      s2 = [x(i+1)-x(i+0); y(i+1)-y(i+0); z(i+1)-z(i+0)];
   
      d1 = s1 + s2;
      d2 = s1 - s2;
      
         % in case of a rank deficite we have to do a recovery
         % instead of the original d2 we overwrite d2 with some
         % vector from the null space
         
      if (rank([d1,d2]) < 2)
         D = null([d1,d2,d2]');
         d2 = D(:,1);
      end
      
         % calculate n1 as normalized ex-product (s1xs2)/|s1xs2|
      
      n1 = null([d1,d2,d2]');  n1 = n1(:,1);
      n2 = null([d1,n1,n1]');  n2 = n2(:,1);  

      assert(abs(d1'*n1) < 1000*eps);
      assert(abs(d2'*n1) < 1000*eps);
      assert(abs(d1'*n2) < 1000*eps);
      assert(abs(n1'*n2) < 1000*eps);
      
         % store normal vectors n1 and n2 in arrays N1, N2

      N1(:,i) = n1;  N2(:,i) = n2;
   end
   
   N1(:,1) = N1(:,2);  N1(:,n) = N1(:,n-1);      % make complete
   N2(:,1) = N2(:,2);  N2(:,n) = N2(:,n-1);      % make complete

      % now optimize the orientation
      
   for (i=2:n)
       p1 = N1(:,i-1);  p2 = N2(:,i-1);  q1 = N1(:,i);  q2 = N2(:,i);      
       assert(norm(q1)-1 < 1000*eps);
       assert(norm(q2)-1 < 1000*eps);
       assert(abs(q1'*q2) < 1000*eps);
       
       q3 = null([q1,q2,q2]');
       n1 = [q1,q2]*[q1,q2]'*p1;
       if norm(n1) == 0
          n1 = q1;
       end
       n2 = null([q3,n1,n1]');      
       
       
       n1 = n1/norm(n1);
       n2 = n2/norm(n2);
       
          % correction of sign of n2
          
       n2p = [q1,q2]*[q1,q2]'*p2;
          
       if (n2p'*n2 < 0)
          n2 = -n2;
       end
       
       assert(norm(n1)-1 < 100*eps);
       assert(norm(n2)-1 < 100*eps);
       assert(abs(n1'*n2) < 100*eps);
       
       N1(:,i) = n1;  N2(:,i) = n2;
   end

   R1 = r*N1;  R2 = r*N2;
   
      % calculate X,Y,Z
      
   p = 0:(2*pi)/m:2*pi;
   
   [P,X] = meshgrid(p,x);
   [P,Y] = meshgrid(p,y);
   [P,Z] = meshgrid(p,z);
   
   [P,R11] = meshgrid(p,R1(1,:));
   [P,R12] = meshgrid(p,R1(2,:));
   [P,R13] = meshgrid(p,R1(3,:));

   [P,R21] = meshgrid(p,R2(1,:));
   [P,R22] = meshgrid(p,R2(2,:));
   [P,R23] = meshgrid(p,R2(3,:));
   
   U = R11.*cos(P) + R21.*sin(P);
   V = R12.*cos(P) + R22.*sin(P);
   W = R13.*cos(P) + R23.*sin(P);
   
   R = sqrt(U.*U + V.*V + W.*W);
   
   X = X + U;
   Y = Y + V;
   Z = Z + W;
   return
end
