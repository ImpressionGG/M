% kafidemo3 - Zeitinvariantes Erweitertes Kalman Filter / Doppelintegrierer

% system parameters  & sampling time

   Ts = 0.2;                     % sample time: 0.2 min = 12 sec
   T = 30;                       % system time constant
   V = 50;                       % system gain factor
   r0 = 10;                      % initial step

% time stamp and reference signal definition   

   tk = 0;  t = [];
   for (k = 1:250)
      t(k) = tk;
      tk = tk + Ts;
      %if (abs(tk-20) < 1e-10) tk = 40; end
      t = [t, tk];
   end
   r = r0 + (V-r0)*(1-exp(-t/T));   % reference signal, to be estimated
   
% noise definition   

   stdw = 1;                     % standard deviation of signal noise
   w = stdw * randn(size(t));    % signal noise
   y = r + w;                    % noisy signal
   
% Kalman filter definition   
   
   m = [0 0]';                   % <x0> expectation of initial state
   P0 = diag([25000/900, 100]);  % covariance of initial state
   R = stdw^2;                   % <<wk>> covariance of output noise
   Q = diag([100, 2500/900]);

Q = diag([1, 0]);
Q = Q/1000;

Q = diag([1, 1])/1000;


   xdk = m;                      % initialize observer state 
   Pk = P0;
   yd = [];  P = []; f = [];

   told = -Ts;
   for (k=1:length(t))
       tk = t(k);
       dtk = tk - told;
       told = tk;

       yk = y(k);              % noisy signal to be filtered
       
       Ak = [1 0; dtk 1];
       Bk = [0 0]';
       Ck = [0 1];
       Ey = eye(size(Ck*Ck'));     % m x m identity matrix
       uk = 0;
       vk = [0 0]';
       
          % time variant Kalman filter

       % ak = exp(-Ts/T);        % Hack !!!!!!!!!!
       % Ak = [1 0; (1-ak) ak];  % Hack !!!!!!!!!!
          
       Gk = R + Ck*Pk*Ck';
       Fk = Ak*Pk*Ck';
       Kk = Fk/Gk;
       Hk = (R + Ck*Pk*Ck')\Ck*Pk*Ck';
       
       ydk = (Ey - Hk)*Ck*xdk + Hk*yk;             % Kalman filter output
       yd = [yd,ydk];                              % log system output

       xdk = Ak*xdk + Bk*uk + Kk*(yk - Ck*xdk);    % state transion observer
       Pk = Ak*Pk*Ak' + Q - Kk*Fk';                % transition error covariance 
       P = [P,Pk(:)];
       
          % Sch‰tzfehler
          
       fk = (yk - w(k)) - ydk;
       f = [f fk];
   end
   
   stdw = round(100*std(w))/100;
   stdf = round(100*std(f))/100;
   stdf0 = round(100*std(f(5:length(f))))/100;
   
   suppression = round(100*stdw/stdf)/100;
   suppression0 = round(100*stdw/stdf0)/100;
   
   clrscr;
   plot(t,0*t,'k--',  t,r,'k',  t,y,'g',  t,yd,'r',  t,f,'b');
   title(sprintf('Zeitinvariantes Erweitertes Kalman Filter - Meﬂsignal: std(w) = %g, Suppresion: %g (%g)',stdw,suppression,suppression0));
   xlabel(sprintf('Dynamic Kalman Filter, Sch‰tzfehler: std(f) = %g (%g))',stdf,stdf0));
   ylabel('Modell basierend auf Doppelintegrierer');
   shg
   
   
%eof   
   