% kaldemo1

   Ts = 0.2;       % 0.2 min = 12 sec
   t = 0:Ts:50;    % max 50 min (=100 sampling intervalls)
   
   stdw = 1;                     % standard deviation output noise
   R = stdw^2;                   % <<wk>> covariance of output noise
   P0 = 0.5;                     % covariance of initial state
   m = 2;                        % <x0> expectation of initial state
   w = stdw * randn(size(t));    % output noise

   xk = 0;   % initialize system state 
   xdk = m;  % initialize observer state 
   Pk = P0;
   
   y1k = m;  K1 = 0.01;
   y2k = m;  K2 = 0.05;
   
   y = [];  yd = [];  P = [];  y1 = [];  y2 = [];

   for (k=1:length(t))
       yk = xk + w(k);           % system output
       y = [y,yk];               % log system output
       xk = xk;                  % state transion system
       
          % time variant Kalman filter
          
       ydk = xdk;                % system output
       yd = [yd,ydk];            % log system output

       Kk = Pk/(R+Pk);
       xdk = xdk + Kk*(yk - xdk);    % state transion observer
       Pk = Pk*R/(Pk + R);       % transition error covariance 
       P = [P,Pk];
       
          % stationary Kalman filter, K1 = 0.01
       
       y1k = (1-K1) * y1k + K1 * yk;
       y1 = [y1,y1k];            % log system output
          
          % stationary Kalman filter, K2 = 0.05

       y2k = (1-K2) * y2k + K2 * yk;
       y2 = [y2,y2k];            % log system output
          
   end
   
   stdw  = round(100*std(w))/100;
   stdyd = round(100*std(yd))/100;
   stdy1 = round(100*std(y1))/100;
   stdy2 = round(100*std(y2))/100;

   redd = round(100*stdw/stdyd)/100;
   red1 = round(100*stdw/stdy1)/100;
   red2 = round(100*stdw/stdy2)/100;
   
   clrscr;
   plot(t,0*t,'k',  t,w,'g',  t,yd,'r',  t,P,'m',  t,y1,'b',  t,y2,'k');
   title(sprintf('Kalman Filter Demo 1 - Noise: std(w) = %g - Noise Reduction Static y1: %g, y2: %g, Dynamic yd: %g, ',stdw,red1,red2,redd));
   xlabel(sprintf('Filterung: Stat KF, std(yd) = %g, std(y1) = %g, std(y2) = %g', stdyd,stdy1,stdy2));
   ylabel('Modell basierend auf PT1-Glied');
   shg
   
   
%eof   
   