function oo = study(o,varargin)        % Do Some Studies               
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
                  @SunClock1,@SunClock2,@SunClock3,@SunClock4,@SunClock5,...
                  @SunClock6,@SunClock7,@SunClock8);
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
   oo = mitem(o,'Sun Clock 1', {@Callback,'SunClock1'},[]);
   oo = mitem(o,'Sun Clock 2', {@Callback,'SunClock2'},[]);
   oo = mitem(o,'Sun Clock 3', {@Callback,'SunClock3'},[]);
   oo = mitem(o,'Sun Clock 4', {@Callback,'SunClock4'},[]);
   oo = mitem(o,'Sun Clock 5 - Model error', {@Callback,'SunClock5'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Sun Clock 6', {@Callback,'SunClock6'},[]);
   oo = mitem(o,'Sun Clock 7', {@Callback,'SunClock7'},[]);
   oo = mitem(o,'Sun Clock 8', {@Callback,'SunClock8'},[]);
end
function oo = Callback(o)                                              
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   study(oo);
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
      break
   end
   while (21)
      subplot(223);
      plot(t,e,'g',  t,e,'k.');
      hold on;
      plot(t,0*t+3*Sigv,'b-.');
      plot(t,0*t-3*Sigv,'b-.');
      set(gca,'ylim',4*Sigv*[-1 1]);
      title(sprintf('Observation error e: %g @3s',o.rd(3*sige,2)));
      break
   end
   while (22)
      subplot(224);
      plot(t,K,'k',  t,K,'k.');
      title(sprintf('Kalman gain K -> %g',K(end)));
      break
   end
end

%==========================================================================
% Sun Clock
%==========================================================================

function o = SunClock1(o)              % Sun Clock Example 1           
%
% SUNCLOCK1 Kalman gain = 1 (intuitive trial)
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
function o = SunClock2(o)              % Sun Clock Example 2           
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
function o = SunClock3(o)              % Sun Clock Example 3           
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
function o = SunClock4(o)              % Sun Clock Example 4           
%
% SUNCLOCK4 constant Kalman gain
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
function o = SunClock5(o)              % Sun Clock Example 2           
%
% SUNCLOCK5 Modeling error
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
