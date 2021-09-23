function oo = sunclock(o,varargin)        % Sun Clock Studies          
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Study1')   % raw signal
%       oo = study(o,'Study2')   % raw & filtered signal
%       oo = study(o,'Study3')   % filtered
%       oo = study(o,'Study4')   % signal noise
%
%    See also: PLL, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                  @SunClock1,@SunClock2,@SunClock3,@SunClock4,...
                  @SunClock5,@SunClock6,@SunClock7,@SunClock8,...
                  @SunClock9,@SunClock10);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                                                  
   oo = SunClockMenu(o);
end
function oo = SimuMenu(o)                                              
   setting(o,{'simu.periods'},50);
   setting(o,{'simu.random'},1);         % no random seed reset
   setting(o,{'simu.noise'},1);          % noise on/off
   setting(o,{'simu.trace'},0);          % tracing on/off

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Periods',{},'simu.periods');
         choice(ooo,[1 2 5 10 20 50 100 200 500 1000 2000 5000 10000,...
                     20000,50000],{});
   ooo = mitem(oo,'Random',{},'simu.random');
         choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Noise',{},'simu.noise');
         choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Trace',{},'simu.trace');
         choice(ooo,{{'Off',0},{'On',1}},{});
end
function oo = SunClockMenu(o)                                          
   oo = SimuMenu(o);
   oo = mitem(o,'-');
   oo = mitem(o,'Intuitive Method',      {@Callback,'SunClock1'},[]);
   oo = mitem(o,'Intuitive Improvement', {@Callback,'SunClock2'},[]);
   oo = mitem(o,'Further Improvement: 0*K + 0.5',   {@Callback,'SunClock3'},[0,0.5]);
   oo = mitem(o,'Further Improvement: 0*K + 0.2',   {@Callback,'SunClock3'},[0,0.2]);
   oo = mitem(o,'Further Improvement: 0*K + 0.1',   {@Callback,'SunClock3'},[0,0.1]);
   oo = mitem(o,'Further Improvement: 0*K + 0.05',   {@Callback,'SunClock3'},[0,0.05]);
   oo = mitem(o,'Further Improvement: 0.5*K + 0',   {@Callback,'SunClock3'},[0.5,0]);
   oo = mitem(o,'-');
   oo = mitem(o,'Order 1 Kalman',        {@Callback,'SunClock4'},[]);
   oo = mitem(o,'Simplified Order 1',    {@Callback,'SunClock5'},[]);
   oo = mitem(o,'Constant Kalman Gain',  {@Callback,'SunClock6'},[]);
   oo = mitem(o,'Model error',           {@Callback,'SunClock7'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Order 2 Kalman',        {@Callback,'SunClock8'},[]);
   oo = mitem(o,'Sun Clock 8',           {@Callback,'SunClock9'},[]);
   oo = mitem(o,'Sun Clock 9',           {@Callback,'SunClock10'},[]);
end
function oo = Callback(o)                                              
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   sunclock(oo);
end

%==========================================================================
% Helpers
%==========================================================================

function kmax = Kmax(o)                % Maximum Simulation Index      
   kmax = opt(o,{'simu.periods',50});
end
function [sigw,sigv,sigx] = Sigma(o)   % Get Noise Sigma Values        
    sigw = 0.01; sigv = 0.1; sigx = 100;
end

%==========================================================================
% Riccati
%==========================================================================

function [P,K] = Riccati(A,C,P,Q,R)    % Riccati Equation              
   I = eye(size(A));

      % Iterate Ricati equation 

   K = P*C' * inv(C*P*C'+R);
   S = (I-K*C)*P;
   P = A*S*A' + Q;
end
function Plot(o)                       % Plot Sunclock data            
   [x] = data(o,'x');
   
   if (size(x,1) == 1)
      Plot1(o);
   elseif (size(x,1) == 2)
      Plot2(o);
   end
   
   function Plot1(o)                   % Plot Order 1 Sunclock data
      [t,x,y,e,v,K] = data(o,'t','x','y','e','v','K');
      [~,Sigv] = Sigma(o);

      [avge,sige] = steady(o,e);
      [avgv,sigv] = steady(o,v);

      while (11)
         subplot(221);
         plot(t,x,'b',  t,x,'b.');
         hold on;
         plot(t,y,'r',  t,y,'r.');
         title('True and Observed state');
         grid on;
         break
      end
      while (12)
         subplot(222);
         plot(t,v,'m',  t,v,'k.');
         hold on;
         plot(t,0*t+3*Sigv,'b-.');
         plot(t,0*t-3*Sigv,'b-.');
         set(gca,'ylim',4*Sigv*[-1 1]);
         title(sprintf('Noise v: %g @3s',o.rd(3*sigv,2)));
         grid on;
         break
      end
      while (21)
         subplot(223);
         plot(t,e,'g',  t,e,'k.');
         hold on;
         plot(t,0*t+3*Sigv,'b-.');
         plot(t,0*t-3*Sigv,'b-.');
         set(gca,'ylim',4*Sigv*[-1 1]);
         title(sprintf('Observation error e: %g +- %g @3s',...
                       o.rd(3*avge,2),o.rd(3*sige,2)));
         grid on;
         break
      end
      while (22)
         subplot(224);
         plot(t,K,'k',  t,K,'k.');
         title(sprintf('Kalman gain K -> %g',K(end)));
         grid on;
         break
      end
   end
   function Plot2(o)                   % Plot Order 2 Sunclock data
      [t,x,y,e,v,K] = data(o,'t','x','y','e','v','K');
      [~,Sigv] = Sigma(o);

      [avge1,sige1] = steady(o,e(1,:));
      [avge2,sige2] = steady(o,e(2,:));
      [avgv,sigv] = steady(o,v);

      while (11)
         subplot(321);
         plot(t,x,'b',  t,x,'b.');
         hold on;
         plot(t,y,'r',  t,y,'r.');
         title('True and Observed state');
         grid on;
         break
      end
      while (12)
         subplot(322);
         plot(t,v,'m',  t,v,'k.');
         hold on;
         plot(t,0*t+3*Sigv,'b-.');
         plot(t,0*t-3*Sigv,'b-.');
         set(gca,'ylim',4*Sigv*[-1 1]);
         title(sprintf('Noise v: %g @3s',o.rd(3*sigv,2)));
         grid on;
         break
      end
      while (21)
         subplot(323);
         plot(t,e(1,:),'g',  t,e(1,:),'k.');
         hold on;
         plot(t,0*t+3*Sigv,'b-.');
         plot(t,0*t-3*Sigv,'b-.');
         set(gca,'ylim',4*Sigv*[-1 1]);
         title(sprintf('Observation error e1: %g @3s',o.rd(3*sige1,2)));
         grid on;
         break
      end
      while (22)
         subplot(324);
         plot(t,K(1,:),'k',  t,K(1,:),'k.');
         title(sprintf('Kalman gain K1 -> %g',K(1,end)));
         grid on;
         break
      end
      while (31)
         subplot(325);
         plot(t,e(2,:),'g',  t,e(2,:),'k.');
         hold on;
         plot(t,0*t+3*Sigv,'b-.');
         plot(t,0*t-3*Sigv,'b-.');
         set(gca,'ylim',4*Sigv*[-1 1]);
         title(sprintf('Observation error e2: %g @3s',o.rd(3*sige2,2)));
         grid on;
         break
      end
      while (32)
         subplot(326);
         plot(t,K(2,:),'k',  t,K(2,:),'k.');
         title(sprintf('Kalman gain K2 -> %g',K(2,end)));
         grid on;
         break
      end
   end
end

%==========================================================================
% Sun Clock - Part 1
%==========================================================================

function o = SunClock1(o)              % Intuitive Method              
%
% SUNCLOCK1 Kalman gain = 1 (intuitive method)
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      K = 1;
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock2(o)              % Intuitive Improvement         
%
% SUNCLOCK2 Intuitive improvement
%
%           K(0) = 1
%           K(k+1) = K(k)/2
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   K = 2;
   
   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      K = 0.8*K;                       % decrease Kalman gain
      z = p + K*i;                     % correction
      
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock3(o)              % Further Improvement           
%
% SUNCLOCK3 Further improvement
%
%           K(0) = 1
%           K(k+1) = a*K(k) + b
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   K = 2;
   
   ab = arg(o,1); a = ab(1); b = ab(2);

   K = 1;
   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      K = a*K + b;                     % decrease Kalman gain
      z = p + K*i;                     % correction
      
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end

%==========================================================================
% Sun Clock - Part 2
%==========================================================================

function o = SunClock4(o)              % Order 1 Kalman Filter
%
% SUNCLOCK4 Standard Kalman algorithm
%
   [sigw,sigv,sigx] = Sigma(o);
   sigw = 0;
   
   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      [P,K] = Riccati(A,C,P,Q,R);      % Riccati iteration
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock5(o)              % Simplified (Order 1) Riccati  
%
% SUNCLOCK5 Simplified (Order 1) Riccati
%
   [sigw,sigv,sigx] = Sigma(o);
   sigw = 0;

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      K = P / (P+R);
      P = (1-K)*P + Q;
     
      x = x + 24;                      % system
      p = z + 24;                      % prediction

      y = x + v;                       % measurement
      i = y-p;                         % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock6(o)              % Constant Kalman Gain          
%
% SUNCLOCK6 constant Kalman gain
%
% Solve:       K = P / (P+R);
%              P = (1-K)*P + Q;
%
%              P = P*(1 - P/(P+R)) + Q;
%              P*(P+R) = P*(P+R - P) + Q(P+R);
%              P*P + P*R = P*R + Q*P + Q*R;
%              P*P -Q*P - Q*R = 0;
%
%              P12 = Q/2 +- sqrt(Q^2/4+QR)s
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   for (k=0:Kmax(o))
      K = P / (P+R);
      P = (1-K)*P + Q;
   end
   
   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock7(o)              % Imperfect Model               
%
% SUNCLOCK7 Imperfect Model
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      [P,K] = Riccati(A,C,P,Q,R);      % Riccati iteration
      
      x = A*x + B*u;                   % system
      p = A*z + B*0.99*u;              % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   
   Plot(oo);
   subplot(223);
   set(gca,'ylim',[-3 3]);
end

%==========================================================================
% Sun Clock - Part 3
%==========================================================================

function o = SunClock8(o)              % Order 2 Kalman Filter         
%
% SUNCLOCK6 Order 2 Standard Kalman algorithm
%
   [sigw,sigv,sigx] = Sigma(o);
   sigw = 0;

   x = [24;0];
   z = [23.5;1];
   
   A = [1 0; 1 1];  C = [0 1];
   P = diag(sigx^2*[1 1]);  Q = diag([sigw^2 0]);  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      [P,K] = Riccati(A,C,P,Q,R);      % Riccati iteration
      
      x = A*x;                         % system
      p = A*z;                         % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock9(o)              % Order 1 Kalman Filter         
%
% SUNCLOCK2 Standard Kalman algorithm
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      [P,K] = Riccati(A,C,P,Q,R);      % Riccati iteration
      
      x = A*x + B*u;                   % system
      p = A*z + B*u;                   % prediction

      y = C*x + v; 
      i = y-C*p;                       % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
function o = SunClock10(o)             % Simplified (Order 1) Riccati  
%
% SUNCLOCK3 Simplified Riccati
%
   [sigw,sigv,sigx] = Sigma(o);

   x = [0];
   z = [1];
   
   A = [1];  C = [1];  B = [1];  u = 24;
   P = sigx^2;  Q = sigw^2;  R = sigv^2;

   oo = log(o,'t,x,y,i,e,v,K');
   for (k=0:Kmax(o))
      v = sigv*randn;
      t = 1*k;
      
      K = P / (P+R);
      P = (1-K)*P + Q;
     
      x = x + 24;                      % system
      p = z + 24;                      % prediction

      y = x + v;                       % measurement
      i = y-p;                         % innovation
      
      z = p + K*i;                     % correction
      e = x-z;                         % estimation error
            
      oo = log(oo,t,x,y,i,e,v,K);
   end
   Plot(oo);
end
