function [om,U] = modal(n,show,m)
%
% MODAL - calculate and plot modes of a multi mass system
%
%            [Om,U] = modal(n)    & frequencies & mode shapes
%
%            modal(n,0)   % show all mode shapes
%            modal(n,1,m)   % evolvment of mode 1 over n
%
%          m*x1: = -k1*x1 + k2*(x2-x1) = -(k1+k2)*x1 + k2*x2
%          m*x2: = -k2*x2 + k3*(x3-x2) = -(k2+k3)*x2 + k3*x3
%           :                  :             :
%          m*xn: = -kn*xn + kn
%
%              [ (k1+k2)  -k2                       ]
%              [    -k2  (k2+k3)  -k3               ]
%          K = [          -k3    (k3+k4)  -k4       ]
%              [    :       :       :      :    -kn ]
%              [                          -kn    kn ]
%
   if (nargin < 1)
      n = 2;
   end
   if (nargin < 2)
      show = 0;
   end
   if (nargin < 3)
      m = 1;
   end
   
   switch show
      case 0
         % go ahead
      case 1
         Evolvement(n,m);
         return
      otherwise
         error('not supported!');
   end
   
   k = n*ones(1,n);       % (N/m) stiffness
   m = 1;                 % (kg)  toatal mass

   M = m/n * eye(n,n);    % mass matrix
   
   if (n == 1)
      K = k(1);
   else
      K = zeros(n,n);
      K(1,1) = k(1)+k(2);
      K(1,2) = -k(2);
      for (i=2:n-1)
         K(i,i-1) = -k(i);
         K(i,i) = k(i)+k(i+1);
         K(i,i+1) = -k(i+1);
      end
      K(n,n-1) = -k(n);
      K(n,n) = k(n);
   end
   
% calculate modes and transformation matrices
   
   A = M\K;
   [U,D] = eig(A);
   Om = sqrt(D);
   om = diag(Om);
      
% plot if no out args

   t = 0:0.01:10;
   colors = {'r','g','b','m','c','k'};
   if (nargout == 0)
      clf
      for (k=1:n)        % run through modes
         qk = sin(om(k)*t);
         u = U(:,k);
         u = u*sign(u(1));
         xk = u*qk;
         col = colors{rem(k-1,length(colors))+1}; 
         for (i=1:n)        % run through masses
            subplot(n,1,i);
            plot(t,xk(i,:),col);
            hold on;
         end
      end
   end
end

%==========================================================================
% evolvement
%==========================================================================

function Evolvement(N,m)
   clf
   t = 0:0.01:10/m;
   for (n=m:N)
      [om,U] = modal(n);
      qm = sin(om(m)*t);
      u = U(:,m);
      u = u*sign(u(m));
      xm = u*qm;
      x = xm(m,:)/max(xm(m,:));
      
      subplot(221);
      plot(t,x,'r');
      hold on
     
      subplot(222);
      y = (0:n)/n;
      plot(y,[0 u'/max(u)],'b');
      hold on;
      plot(y,[0 u'/max(u)],'bo');
      title('Elongation x over coordinate');
      
      omega(n) = om(m);
   end
   
   subplot(223);
   plot(1:length(omega),omega,'g');
   title(sprintf('Mode #%g',m))
end
