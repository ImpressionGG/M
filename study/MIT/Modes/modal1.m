% modal1 - Modalanalyse 1
%          nominal parameters according to MIT lecture

   m1 = 0.3193;  % kg
   m2 = 0.6309;  % kg
   
   m1 = 10; m2 = 0.1;
   
   
   k1 = 55.87;   % n/m
   k2 = 36.05;   % N/m

   
   k1 = 500.87; k2=100;
   
   M = [m1 0; 0 m2];
   K = [k1+k2 -k2; -k2 k2];
   
% calculate modes and transformation matrices
   
   A = M\K;
   [U,D] = eig(A);
%   T = [0 1; 1 0];
%   U = T*U*T;  D = T*D*T;
   
   Om = sqrt(D);
   
   om1 = Om(1,1);  om2 = Om(2,2);
   
% calculate modes

   t = 0:0.01:5;
   q = [sin(om1*t); sin(om2*t)];
   
   x1 = U(:,1)*q(1,:);
   x2 = U(:,2)*q(2,:);
   
   v1 = om1*max(x1')'; 
   v2 = om2*max(x2')'; 
   W = 1/2 * [m1 m1; m2 m2].*[v1.*v1 v2.*v2];
      
% plot modes

   clf;
   
   subplot(1,2,1);
   plot(t,3+x1(1,:),'r');
   hold on;
   plot(t,1+x1(2,:),'r');
   xlabel(sprintf('m1 = %g kg, m2 = %g kg',m1,m2));
   ylabel(sprintf('Mode #1: om1 = %g',om1));
   title(sprintf('W1 = %g J, W2 = %g J',W(1,1),W(2,1)));

   subplot(1,2,2);
   plot(t,3+x2(1,:),'g');
   hold on;
   plot(t,1+x2(2,:),'g');
   xlabel(sprintf('m1 = %g kg, m2 = %g kg',m1,m2));
   ylabel(sprintf('Mode #2: om2 = %g',om2));
   title(sprintf('W1 = %g J, W2 = %g J',W(1,2),W(2,2)));
