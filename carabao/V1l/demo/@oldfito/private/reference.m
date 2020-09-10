function [rout,tout] = reference(mode,par,Ts,Tmax,Nx)
%
% REFERENCE    Setup a reference function
%
%              1) Exponential Curve
%
%                 [r,t] = reference(1,[V],Ts)  % exp. drift - T=35, several pauses
%                 [r,t] = reference(1,[V T],Ts)  % exp. drift - special T
%                 [r,t] = reference(1,[V T T1],Ts)  % exp. drift - special T, T1
%
%                 [r,t] = reference(mode,par,Ts,Tmax,Nx);
%
%                 Meaning of args:
%                    V:      stationary value for convergence
%                    T:      system time constant of drift
%                    T1:     time to first break 
%                    Ts:     sampling time
%                    Tmax:   maximum time
%                    Nx:     number of extra measurements after break 
%
%              2) Symmetric Ramp
%
%                 [r,t] = reference(2,T,Ts)  % symmetric ramp
%
%              3) Asymmetric Ramp
%
%                 [r,t] = reference(3,T,Ts)  % alternating asymmetric ramp
%
%              4) Square Wave
%
%                 [r,t] = reference(4,T,Ts)  % square wave
%
%              5) Time Varying System
%
%                 [r,t] = reference(5,T,Ts)  % square wave
%
%              Note: if no output args are provided then the reference
%              function will be plotted.
%
   mode = eval('mode','1');

   if (isstruct(mode))
      ref = mode;
      mode = ref.mode;
      V = ref.V;
      T = ref.T;
      T1 = ref.T1;
      Ts = ref.Ts;
      Tmax = ref.Tmax;
      Nx = ref.Nx;
      
      par = [V T T1];
   else    
      Tmax = eval('Tmax','100');      % maximum time [min] of test function
      Nx = eval('Nx','0');    % number of extra measurements to add
   end
   
   switch mode
   case 1
      V  = eval('par(1)','50');       % stationary value for convergence
      T  = eval('par(2)','35');       % system time constant of drift
      T1 = eval('par(3)','30');       % time to first break 
      Ts = eval('Ts','0.2');

      T2 = T1+20;  T3 = T1+30;  T4 = T1+35;  T5 = T1+40;  T6 = T1+42;  T7 = T1+50;
      T8 = T1+55;  T9 = T1+60;  T10 = T1+62;
      r0 = 0.2;
      symb = 'V';
   
      tk = 0;  t = [];
      for (k = 1:Tmax/Ts+1)
         tk = (k-1)*Ts;
         if (tk >= T1) tk = tk + T2-T1; end
         if (tk >= T3) tk = tk + T4-T3; end
         if (tk >= T5) tk = tk + T6-T5; end
         if (tk >= T7) tk = tk + T8-T7; end
         if (tk >= T9) tk = tk + T10-T9; end
         if (tk <= Tmax)
            t = [t, tk];
         end
      end
   
      V1 = V*(1 - r0);  
      V2 = V1*1.46;  V3 = V1*1.62;  V4 = V1*1.75;  V5 = V1*1.79;
      V6 = V1*1.72;  V7 = V1*1.72;  V8 = V1*1.72;  V9 = V1*1.9;
   
      r = V*r0 + V1*(1-exp(-t/T)) ...  % reference signal, to be estimated
        - V2*(1-exp(-(t-T1)/T)).*(t-T1>=0) ...
        + V3*(1-exp(-(t-T2)/T)).*(t-T2>=0) ...
        - V4*(1-exp(-(t-T3)/T)).*(t-T3>=0) ...
        + V5*(1-exp(-(t-T4)/T)).*(t-T4>=0) ...
        - V6*(1-exp(-(t-T5)/T)).*(t-T5>=0) ...
        + V7*(1-exp(-(t-T6)/T)).*(t-T6>=0) ...
        - V8*(1-exp(-(t-T7)/T)).*(t-T7>=0) ...
        + V9*(1-exp(-(t-T8)/T)).*(t-T8>=0) ...
        - V7*(1-exp(-(t-T9)/T)).*(t-T9>=0) ...
        + V3*(1-exp(-(t-T10)/T)).*(t-T10>=0) ...
        ;  

   case 2
      V = eval('par(1)','5');
      Ts = eval('Ts','0.2');
      T0 = 1;       % system time constant [min/µ] 
      Ton = V;  Toff = V;    % Toff = 5;
      T = Ton + Toff;
      r0 = V;
      % N = 10;
      symb = 'T';
  
      k = 1;  tk = 0; told = 0;  Tk = 0;
      t = [0];  T1 = [];  T2 = [];
      while (tk < 100)
         Tk = Tk + tk - told;
         told = tk;
         T1 = [T1 Tk];
         T2 = [T2 Tk+Ton];

         for (j = 1:Ton/Ts)
             tk = tk + Ts;
             t = [t,tk];
         end

         tk = tk + Toff;
         t = [t, tk];
         N = k;  k = k+1;
      end
      
         % truncate  time vector
         
      idx = find(t > Tmax + 1e4*eps);
      t(idx) = [];
      
         % reference signal, to be estimated
         
      r = 0*t+r0;  sgn = 1;  epsi = 1e-10;
      for (k = 1:N);
          r = r + sgn*((t-T1(k))/T0) .* (t-T1(k) >= epsi);
          r = r - sgn*((t-T1(k))/T0) .* (t-T2(k) > epsi);
          sgn = -sgn;
      end
      
   case 3
      V = eval('par(1)','2');
      Ts = eval('Ts','0.2');
      T0 = 1;       % system time constant [min/µ] 
      Ton = V;  Toff = 2*V;
      T = Ton + Toff;
      r0 = V;
      % N = 10;
      symb = 'T';
  
      k = 1;  tk = 0; told = 0;  Tk = 0;
      t = [0];  T1 = [];  T2 = [];
      while (tk < 100)
         Tk = Tk + tk - told;
         told = tk;
         T1 = [T1 Tk];
         T2 = [T2 Tk+Ton];

         for (j = 1:Ton/Ts)
             tk = tk + Ts;
             t = [t,tk];
         end

         tk = tk + Toff;
         t = [t, tk];
         N = k;  k = k+1;
      end
      
         % truncate  time vector
         
      idx = find(t > Tmax);
      t(idx) = [];
      
         % reference signal, to be estimated
         
      r = 0*t+r0;  sgn = 1;  epsi = 1e-10;
      for (k = 1:N);
          r = r + sgn*((t-T1(k))/T0) .* (t-T1(k) >= epsi);
          r = r - sgn*((t-T1(k))/T0) .* (t-T2(k) > epsi);
          sgn = -sgn;
      end

   case 4
      V = eval('par(1)','2');
      Ts = eval('Ts','0.2');
      T0 = 1;       % system time constant [min/µ] 
      Ton = V;  Toff = V;
      T = Ton + Toff;
      r0 = -V;
      % N = 10;
      symb = 'T';
  
      k = 1;  tk = 0; told = 0;  Tk = 0;
      t = [0];  T1 = [];  T2 = [];
      while (tk < 100)
         Tk = Tk + tk - told;
         told = tk;
         T1 = [T1 Tk];
         T2 = [T2 Tk+Ton];

         for (j = 1:Ton/Ts)
             tk = tk + Ts;
             t = [t,tk];
         end

         tk = tk + Toff;
         t = [t, tk];
         N = k;  k = k+1;
      end
      
         % truncate  time vector
         
      idx = find(t > Tmax);
      t(idx) = [];
      
         % reference signal, to be estimated
         
      r = 0*t+r0/2;  sgn = 1;  epsi = -1e-10;
      for (k = 1:N);
          r = r + sgn*V .* (t-T1(k) >= epsi);
          %r = r - sgn*V .* (t-T2(k) >= epsi);
          sgn = -sgn;
      end

   case 5  % Time Varying Sstem
      V  = eval('par(1)','50');    % stationary value for convergence
      T  = eval('par(2)','35');    % system time constant of drift
      T1 = eval('par(3)','25');    % time to first break 
      Ts = eval('Ts','0.2');

      T2 = T1+5;  T3 = T2+30;  T4 = T3+5;  T5 = T4+50;  T6 = T5+10; 
      r0 = 0.2;
      symb = 'V';
   
      tk = 0;  t = [];
      for (k = 1:Tmax/Ts+1)
         tk = (k-1)*Ts;
         if (tk >= T1) tk = tk + T2-T1; end
         if (tk >= T3) tk = tk + T4-T3; end
         if (tk >= T5) tk = tk + T6-T5; end
         if (tk <= Tmax)
            t = [t, tk];
         end
      end
   
      V1 = V*(1 - r0);  V2 = V1;  V3 = V1;
   
      r = V*r0 ...
        + V1*(1-exp(-t/(T/2))) .*(t <= T1) ...  % reference signal, to be estimated
        + V2*(1-exp(-(t-T2)/T)).*(t >= T2 & t <= T3) ...
        + V3*(1-exp(-(t-T4)/(2*T))).*(t >= T4 & t <= T5) ...
        ;  

    otherwise
      error(sprintf('Bad mode: %g',mode));
   end

   t = t(:);  r = r(:);

% Multiple Filtering

   if (Nx > 0)
      k = 1;
      kmax = length(t);
      while (k < kmax)
         k = k+1;
         if (t(k) - t(k-1) > 2*Ts) 
            t = [t(1:k-1); t(k)*ones(Nx,1); t(k:kmax)];
            r = [r(1:k-1); r(k)*ones(Nx,1); r(k:kmax)];
            k = k + Nx;  kmax = kmax + Nx;
         end
      end

         % also on the very beginning
         
      t = [t(1)*ones(Nx,1); t];
      r = [r(1)*ones(Nx,1); r];
   end

% Set output args or draw plot

   if (nargout == 0);
       cls;
       plot(t,0*r,'k',  t,r,'r', t,r,'k.');
       title(sprintf(['Test function r%g(t):  ',symb,' = %g,  T = %g,  T1 = %g,  Ts = %g'],mode,V,T,T1(1),Ts));
       xlabel('time t [min]');
       set(gca,'xlim',[0 Tmax]);
   else
       tout = t(:);  rout = r(:);
   end
   
   return
   
 % eof