function o = kalman(o,oo)                                              
%
% KALMAN Kalman filter block
%    Syntax:
%
%       o = kalman(o)                  % init
%       o = kalman(o,osys)             % loop
%
%    Log data:
%
%       k:  run index
%       xm: observer state (x(1): period, x(2): ZV time stamps)
%       ym: observer output (zero cross time stamps)
%       yd: observer deviation (yd = ym-y)
%         
%    Example:
%
%       oc = controller(o);                 % passive controller
%       os = system(o);
%       ok = kalman(type(o,'mcukalf'));     % init Kalman Filter
%      
%       for (k=1:Kmax(o))
%          os = system(os,oc);              % run system (timer) loop
%          ok = kalman(ok,var(os).tj);      % run Kalman filter loop
%       end
%
%    See also: PLL, SYSTEM, CONTROL
%
   if (nargin > 1)
      gamma = var(o,'gamma');
      o = gamma(o,oo);
      return
   end
   
       % otherwise we inigialize depending on type
   switch type(o)
      case {'mcukalf','mcucalf'}
         o = McuKalfInit(o);
      case 'order2'
         o = Kalf2Init(o);
      case 'order3'
         o = Kalf3Init(o);
      case 'order4'
         o = Kalf4Init(o);
      case 'casc'
         o = CascadeInit(o);
      case 'twin'
         o = TwinInit(o);
      case 'itwin'
         o = iTwinInit(o);
      case 'steady'
         o = SteadyInit(o);
      case 'simple'
         o = SimpleInit(o);
      otherwise
         error('bad type');
   end
end

%==========================================================================
% Helper
%==========================================================================

function [t0,period] = GridParameter(o)                                
   f = opt(o,{'grid.f',50});
   toff = opt(o,{'grid.offset',0});    % time offset

   period = 1/f;
   tmin = 0; tmax = period;
   t = [tmin-toff-period/2:period:tmax];
   
   idx = find(tmin <= t & t <= tmax);
   t0 = t(idx(1));
end
function [Tt0,Tt,Dt] = TimerParameter(o)                               
   f0 = opt(o,'clock.f0');
   kappa = opt(o,'clock.kappa');

   Kt = opt(o,'tim6.prescale');
   Dt = Kt/f0*kappa;
   
   period = opt(o,'tim6.period')+1;
   Tt = period*Dt;
   
   offset = opt(o,'tim6.offset');
   Tt0 = offset;
end
function [sigw,sigv] = Sigma(o)        % Get Noise Sigma Values        
   [Tt0,Tt,Dt] = TimerParameter(o);
%o = opt(o,'grid.sigw',[]);   
%o = opt(o,'grid.sigv',[]);   
   sigw = opt(o,{'grid.vario',5e-6}) / 3 / Dt;
   sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;
end

%==========================================================================
% Kalman Equations
%==========================================================================

function [P,K,x,q,d,e] = Kalman(A,B,C,P,R,Q,x,u,y)                     
   I = eye(size(A));

      % Iterate Ricati equation 

   M = A*P*A' + Q;
   K = M*C' * inv(C*M*C'+R);
   P = (I-K*C)*M;

      % observer state transition

   h = A*x + B*u;                      % half transition
   e = y - C*h;                        % error signal
   x = h + K*e;                        % full transition

      % output signals

   q = C*x;                            % Kalman filter output
   d = y - q;                          % output deviation
end
function [P,K,x,q,d,e] = iKalman(A,B,C,P,R,Q,x,u,y)                    
   I = imat(2,2,eye(2),'I');

   AP = imul(A,P,'AP=A*P');
   AT = itrn(A,'AT=A''');
   APAT = imul(AP,AT,'APAT=A*P*A''');
   M = iadd(APAT,Q,'M=A*P*A''+Q');

      % calculate: K = M*C' * inv(C*M*C'+R);

   CT = itrn(C,'CT=C''');
   MCT = imul(M,CT,'MCT=M*C''');
   
   CM = imul(C,M,'CM=C*M');
   CMCT = imul(CM,CT,'CMCT=C*M*C''');
   CMCTR = iadd(CMCT,R,'CMCTR=C*M*C''+R');
   INV = iinv(CMCTR,'INV=inv(C*M*C''+R)');
   K = imul(MCT,INV,'K=M*C''*INV');

      % calculate: P = (I-K*C)*M;

   KC = imul(K,C,'KC=K*C');
   IKC = isub(I,KC,'IKC=I-K*C');
   P = imul(IKC,M,'P=(I-K*C)*M');
   
      % observer state transition
      % start with: h = A*x + B*u (half transition)

   Ax = imul(A,x,'Ax=A*x');
   Bu = imul(B,u,'Bu=B*u');
   h = iadd(Ax,Bu,'h=A*x+B*u');
   
      % next: e = y - C*h (error signal)
      
   Ch = imul(C,h,'Ch=C*h');
   e = isub(y,Ch,'e=y-C*h');
   
      % finally: x = h + K*e (full transition) 
      
   Ke = imul(K,e,'Ke=K*e');
   x = iadd(h,Ke,'x=h+K*e');

      % output signals
      % q = C*x
      % d = y - q
      
   q = imul(C,x,'q=C*x');              % Kalman filter output
   d = isub(y,q,'d=y-q');              % output deviation
end

function [o,x,t0] = ModuloJump(o,y,x)  % Handle Timer Modulo Jumps     
   t0 = var(o,{'t0',0});
   yo = var(o,{'yo',0});
   period = opt(o,'tim6.period') + 1;

   if (y < yo - 10000)                 % did y jump back?
      x = x - period;            % state correction
      t0 = t0 + period;                % record jump
   end
   yo = y;                             % remember old measurement

   o = var(o,'t0',t0, 'yo',yo);
end
function [o,x,t0] = iModuloJump(o,y,x) % Handle Timer Modulo Jumps     
   t0 = var(o,{'t0',0});
   yo = var(o,{'yo',0});
   period = opt(o,'tim6.period') + 1;

   y = icast(y);                       % cast to double
   if (y < yo - 10000)                 % did y jump back?
      x = isub(x,imat([0;period]));    % state correction
      t0 = t0 + period;                % record jump
   end
   yo = y;                             % remember old measurement

   o = var(o,'t0',t0, 'yo',yo);
end

function [o,x,t0] = PwmJump(o,h,x)     % Handle PWM Modulo Jumps       
   ho = var(o,{'ho',0});
   period = opt(o,'tim2.period') + 1;

   if (h < ho - 5000)                  % did y jump back?
      x = x - period;                  % state correction
   end
   ho = h;                             % remember old measurement

   o = var(o,'ho',ho);
end

%==========================================================================
% MCU Kalman Filter
%==========================================================================

function o = McuKalfInit(o)            % Init                          
   o = var(o,'gamma',@McuKalfLoop);
   k = 0;                              % init run index

   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);
   
   [sigw,sigv] = Sigma(o);

   A = [1 0; 1 1];                     % system matrix
   C2 = 1;

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x1 = 0; %0.018;                       % model state(1)
   x2 = 0;                           % model state(2)

      % setup Kalman parameter matrices
      % P = 1e6*I
      % Q = [sigw^2 0; 0 0]
      % R = sigv^2

   P11 = 1e6; P12 = 0; 
   P21 = 0;   P22 = 1e6;
   
   Q11 = sigw^2;
   R   = sigv^2;

      % variable storage
      
   o = var(o,'k',k, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'C2',C2, 'x1',x1, 'x2',x2);
   o = var(o,'P11',P11, 'P12',P12, 'P21',P21, 'P22',P22, 'Q11',Q11, 'R',R);

      % log init      
   
   o = log(o,'k,x,y,z,d');
end
function o = McuKalfLoop(o,oo)         % Loop Function                 
   [k,sigw,sigv] = var(o,'k','sigw','sigv');
   [A,C2,x1,x2] = var(o,'A','C2','x1','x2');
   [P11,P12,P21,P22,Q11,R] = var(o,'P11','P12','P21','P22','Q11','R');

      % progress run index and measure z
      
   k = k+1;
   z = var(oo,'z');                    % zero cross time stamps
   
      % Ricati equation part1: M = A*p*A' + Q
      
   M11 = P11 + Q11;
   M12 = P11 + P12;
   M21 = P11 + P21;
   M22 = M12 + P21 + P22;

      % Ricati equation part 2: K = M*Cm'*inv(Cm*M*Cm'+R)

   q = C2 / (C2 * M22 * C2 + R);
   K1 = M12 * q;
   K2 = M22 * q;

      % Ricati equation part 3: P = (I-K*Cm)*M

   K1C2 = K1 * C2;  
   K2C2 = K2 * C2;
   P11 = M11 - K1C2 * M12;
   P12 = M12 - K1C2 * M22;
   P21 = M21 * (1-K2C2);
   P22 = M22 * (1-K2C2);
   
      % part 1 of observer transition
      %    hk = Am*xm;           % half transition
      %    ek = yt(k) - Cm*hk;   % error signal

   h1 = x1;
   h2 = x1 + x2;
   e = z - C2 * h2;

      % part 2 of observer transition
      %    xm = hk + K*ek              % full transition
      %    ym(k) = Cm*xm               % model counter reading

   x1 = h1 + K1 * e;
   x2 = h2 + K2 * e;
   y = C2 * x2;                       % model counter reading

   d = y - z;                         % output deviation

      % variable storage
      
   o = var(o,'k',k, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'C2',C2, 'x1',x1, 'x2',x2, 'y',y, 'd',d);
   o = var(o,'P11',P11, 'P12',P12, 'P21',P21, 'P22',P22, 'Q11',Q11, 'R',R);

      % logging
      
   o = log(o,k,[x1;x2],y,z,d);
end

%==========================================================================
% Order 2 Kalman Filter
%==========================================================================

function o = Kalf2Init(o)              % Init                          
   o = var(o,'gamma',@Kalf2Loop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0; 1 1];                     % system matrix
   B = [0 0]';                         % input matrix
   C = [0 1];                          % output matrix

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [0.018;0];                      % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(2);
   Q = [sigw^2 0; 0 0];
   R = sigv^2;

      % variable storage
      
   o = var(o,'k',k, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'B',B, 'C',C, 'x',x, 'P',P, 'Q',Q, 'R',R);

      % log init      
   
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = Kalf2Loop(o,oo)           % Loop Function                 
   [k,x,A,B,C,P,Q,R] = var(o,'k','x','A','B','C','P','Q','R');

      % progress run index and measure z
      
   k = k+1;
   u = 0;                              % input irelevant
   y = var(oo,'z');                    % zero cross time stamps
   
      % handle modulo jumps of timer counter based time
 
   [o,x(2),t0] = ModuloJump(o,y,x(2)); % handle modulo jumps
   
      % Iterate Kalman equations 

   [P,K,x,q,d,e] = Kalman(A,B,C,P,R,Q,x,u,y);
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'P',P, 'K',K);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Order 3 Kalman Filter
%==========================================================================

function o = Kalf3Init(o)              % Init                          
   o = var(o,'gamma',@Kalf3Loop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0; 0 1 0; 1 -2 1];         % dynamic matrix
   B = [0 1 -1]';                      % input matrix
   C = [0 0 1];                        % output matrix

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0];                  % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(3);
   Q = diag([sigw^2 0 0]);
   R = sigv^2;

      % variable storage
      
   o = var(o,'k',k, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'B',B, 'C',C, 'x',x, 'P',P, 'Q',Q, 'R',R);

      % log init      
   
   o = log(o,'k,x,y,z,d,K,t0');
end
function o = Kalf3Loop(o,oo)           % Loop Function                 
   [k,x,A,B,C,P,Q,R] = var(o,'k','x','A','B','C','P','Q','R');

      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y = var(oo,'y');                    % PWM phase
   
      % handle modulo jumps of timer counter based time
 
   [o,~,t0] = ModuloJump(o,y,0);       % handle modulo jumps

      % Iterate Kalman equations 

   [P,K,x,q,d,e] = Kalman(A,B,C,P,R,Q,x,u,y);

      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'P',P, 'K',K);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Order 4 Kalman Filter
%==========================================================================

function o = Kalf4Init(o)              % Init                          
   o = var(o,'gamma',@Kalf4Loop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];   % dynamic matrix
   B = [0 0  1 -1]';                            % input matrix
   C = [0 1 0 0; 0 0 0 1];                      % output matrix

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];                        % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(4);
   Q = diag([sigw^2 0 0 sigw^2]);
   R = eye(2)*sigv^2;

      % variable storage & data logging
      
   o = var(o,'k',k, 'A',A, 'B',B, 'C',C, 'x',x, 'P',P, 'Q',Q, 'R',R);
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = Kalf4Loop(o,oo)           % Loop Function                 
   [k,x,A,B,C,P,Q,R] = var(o,'k','x','A','B','C','P','Q','R');

      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y = [
          var(oo,'z');                 % zero cross time stamps
          var(oo,'y');                 % PWM phase
       ]; 
   
      % handle modulo jumps of timer counter based time
 
   [o,x(2),t0] = ModuloJump(o,y(1),x(2));    % handle modulo jumps

      % Iterate Kalman equations 

   [P,K,x,q,d,e] = Kalman(A,B,C,P,R,Q,x,u,y);
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'P',P, 'K',K);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Cascade Kalman Filter
%==========================================================================

function o = CascadeInit(o)            % Init                          
   o = var(o,'gamma',@CascadeLoop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1]; 
   B = [0 0  1 -1]';                   % input matrix
   C = [0 1 0 0; 0 0 0 1];             % output matrix
   
      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];               % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(4);
   Q1 = diag([sigw^2 0]);
   Q2 = diag([0 sigw^2]);
   R = sigv^2;

      % variable storage & data logging
      
   o = var(o,'k',k, 'A',A,'B',B,'C',C, 'x',x, 'P',P,'Q1',Q1,'Q2',Q2,'R',R);
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = CascadeLoop(o,oo)         % Loop Function                 
   [k,x,A,B,C,P,Q1,Q2,R] = var(o,'k','x','A','B','C','P','Q1','Q2','R');

      % get subsystem matrices

   i1 = [1 2];  i2 = [3 4];            % indices for sub states
   A1 = A(i1,i1);  A2 = A(i2,i2);  F2 = A(i2,i1);
   B1 = B(i1);  B2 = B(i2);  C1 = C(1,i1);  C2 = C(2,i2); 
   x1 = x(i1);  x2 = x(i2);  P1 = P(i1,i1);  P2 = P(i2,i2);
   
      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y1 = var(oo,'z');                   % zero cross time stamps
   y2 = var(oo,'y');                   % PWM phase
   
      % handle modulo jumps of timer counter based time
 
   [o,x1(2),t0] = ModuloJump(o,y1,x1(2));   % handle modulo jumps
   %[o,x2(2)] = PwmJump(o,y2,x2(2));    % handle PWM modulo jumps
   
      % Iterate first Kalman subsystem 

   [P1,K1,x1,q1,d1,e1] = Kalman(A1,B1,C1,P1,R,Q1,x1,0,y1);
   
      % Iterate second Kalman subsystem 

   [P2,K2,x2,q2,d2,e2] = Kalman(A2,[B2,F2],C2,P2,R,Q2,x2,[u;x1],y2);

      % repack partial data
      
   P(i1,i1) = P1;  P(i2,i2) = P2;  K = [K1;K2];
   x(i1) = x1;  x(i2) = x2;  y = [y1;y2];  q = [q1;q2];  d = [d1;d2];
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'P',P, 'K',K);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Twin Kalman Filter
%==========================================================================

function o = TwinInit(o)               % Init                          
   o = var(o,'gamma',@TwinLoop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0 0  1 -1]';                   % input matrix
   C = [0 1 0 0; 0 0 0 1];             % output matrix
   
      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];               % model state
   
      % setup Kalman parameter matrices
   
   P = 1e6*eye(4);                     % instead of 1e6 * ...
   Q1 = diag([sigw^2 0]);
   Q2 = diag([0 sigw^2]);
   R = sigv^2;

      % get subsystem matrices

   i1 = [1 2];  i2 = [3 4];            % indices for sub states
   A1 = A(i1,i1);  A2 = A(i2,i2);
   B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  C1 = C(1,i1);  C2 = C(2,i2); 
   x1 = x(i1);  x2 = x(i2);  P1 = P(i1,i1);  P2 = P(i2,i2);

      % variable storage & data logging
      
   o = var(o,'A1',A1,'A2',A2, 'B1',B1,'B2',B2, 'C1',C1, 'C2',C2);
   o = var(o,'k',k, 'P1',P1, 'P2',P2, 'x1',x1, 'x2',x2, 'x',x);
   o = var(o,'Q1',Q1, 'Q2',Q2, 'R',R);
   
   o = log(o,'k,x,u,y,q,d,K,t0');
end
function o = TwinLoop(o,oo)            % Loop Function                 
   [k,P1,P2,x1,x2,Q1,Q2,R] = var(o,'k','P1','P2','x1','x2','Q1','Q2','R');
   [A1,A2,B1,B2,C1,C2] = var(o,'A1','A2','B1','B2','C1','C2');
   
      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y1 = var(oo,'z');                   % zero cross time stamps
   y2 = var(oo,'y');                   % PWM phase

      % handle modulo jumps of timer counter based time
 
   [o,x1(2),t0] = ModuloJump(o,y1,x1(2));   % handle modulo jumps

      % Iterate first Kalman subsystem 

   [P1,K1,x1,q1,d1,e1] = Kalman(A1,B1,C1,P1,R,Q1,x1,0,y1);

      % Iterate second Kalman subsystem 

   [P2,K2,x2,q2,d2,e2] = Kalman(A2,B2,C2,P2,R,Q2,x2,[x1;u],y2);
   
      % repack partial data
      
   K = [K1;K2];  
   x = [x1; x2];  y = [y1;y2];  q = [q1;q2];  d = [d1;d2];
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'K',K);
   o = var(o,'P1',P1, 'P2',P2, 'x1',x1, 'x2',x2);
   o = log(o,k,x,u,y,q,d,K(:),t0);
end

%==========================================================================
% iTwin Kalman Filter
%==========================================================================

function o = iTwinInit(o)              % Init                          
   o = var(o,'gamma',@iTwinLoop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0 0  1 -1]';                   % input matrix
   C = [0 1 0 0; 0 0 0 1];             % output matrix
   
      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];               % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(4);
   Q1 = imat(2,2,diag([sigw^2 0]));
   Q2 = imat(2,2,diag([0 sigw^2]));
   R = imat(1,1,sigv^2);

      % get subsystem matrices

   i1 = [1 2];  i2 = [3 4];            % indices for sub states
   A1 = imat(2,2,A(i1,i1));
   A2 = imat(2,2,A(i2,i2));
   B1 = imat(2,1,B(i1),'B1');
   B2 = imat(2,3,[A(i2,i1),B(i2)],'B2');  
   C1 = imat(1,2,C(1,i1));
   C2 = imat(1,2,C(2,i2)); 
   x1 = imat(2,1,x(i1),'x1');  
   x2 = imat(2,1,x(i2),'x2');  
   
   P1 = imat(2,2,P(i1,i1));  
   P2 = imat(2,2,P(i2,i2));

      % variable storage & data logging
      
   o = var(o,'A1',A1,'A2',A2, 'B1',B1,'B2',B2, 'C1',C1, 'C2',C2);
   o = var(o,'k',k, 'P1',P1, 'P2',P2, 'x1',x1, 'x2',x2, 'x',x);
   o = var(o,'Q1',Q1, 'Q2',Q2, 'R',R');
   
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = iTwinLoop(o,oo)           % Loop Function                 
   [k,P1,P2,x1,x2,Q1,Q2,R] = var(o,'k','P1','P2','x1','x2','Q1','Q2','R');
   [A1,A2,B1,B2,C1,C2] = var(o,'A1','A2','B1','B2','C1','C2');
   
      % progress run index and measure z
      
   k  = k+1;
   u  = imat(1,1,var(oo,'u'),'u');     % control signal
   y1 = imat(1,1,var(oo,'z'),'z');     % zero cross time stamps
   y2 = imat(1,1,var(oo,'y'),'y');     % PWM phase
   
      % handle modulo jumps of timer counter based time
 
   [o,x1,t0] = iModuloJump(o,y1,x1);   % handle modulo jumps

      % Iterate first Kalman subsystem 

   u0 = imat(1,1,0,'u0=0');
   [P1,K1,x1,q1,d1,e1] = iKalman(A1,B1,C1,P1,R,Q1,x1,u0,y1);
   
      % Iterate second Kalman subsystem 

   ux1 = icol(x1,u);
   [P2,K2,x2,q2,d2,e2] = iKalman(A2,B2,C2,P2,R,Q2,x2,ux1,y2);
   
      % repack partial data
      
   K = [icast(K1);icast(K2)];   
   x = [icast(x1); icast(x2)];
   y = [icast(y1);icast(y2)];  
   q = [icast(q1);icast(q2)];
   d = [icast(d1);icast(d2)];
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'K',K);
   o = var(o,'P1',P1, 'P2',P2, 'x1',x1, 'x2',x2);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Order 4 Kalman Filter
%==========================================================================

function o = SteadyInit(o)             % Init                          
   o = var(o,'gamma',@SteadyLoop);
   k = 0;                              % init run index

   [sigw,sigv] = Sigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];   % dynamic matrix
   B = [0 0  1 -1]';                            % input matrix
   C = [0 1 0 0; 0 0 0 1];                      % output matrix

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];                        % model state

      % setup Kalman parameter matrices
   
   P = 1e6*eye(4);
   Q = diag([sigw^2 0 0 0]);
   R = eye(2)*sigv^2;

      % variable storage & data logging
      
   o = var(o,'k',k, 'A',A, 'B',B, 'C',C, 'x',x, 'P',P, 'Q',Q, 'R',R);
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = SteadyLoop(o,oo)          % Loop Function                 
   [k,x,A,B,C,P,Q,R,K] = var(o,'k','x','A','B','C','P','Q','R','K');

      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y = [
          var(oo,'z');                 % zero cross time stamps
          var(oo,'y');                 % PWM phase
       ]; 
   
      % handle modulo jumps of timer counter based time
 
   [o,x(2),t0] = ModuloJump(o,y(1),x(2));    % handle modulo jumps

      % Iterate Kalman equations 

   if isempty(K)
      [P,K,x,q,d,e] = Kalman(A,B,C,P,R,100*Q,x,u,y);
      for (i=1:100)
         [P,K,~,q,d,e] = Kalman(A,B,C,P,R,100*Q,x,u,y);
      end
   end
   
   x = A*x - K*(C*x-y);
   q = C*x;
   d = y - q;                          % output deviation
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d, 'P',P, 'K',K);
   o = log(o,k,x,y,q,d,K(:),t0);
end

%==========================================================================
% Simple Kalman Filter
%==========================================================================

function o = SimpleInit(o)             % Init                          
   o = var(o,'gamma',@SimpleLoop);
   k = 0;                              % init run index

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];   % dynamic matrix
   B = [0 0  1 -1]';                            % input matrix
   C = [0 1 0 0; 0 0 0 1];                      % output matrix

      % for model state 1 (period) we make a compromise between 
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms
      
   x = [18000; 0; 0; 0];                        % model state

      % variable storage & data logging
      
   o = var(o,'k',k, 'A',A, 'B',B, 'C',C, 'x',x);
   o = log(o,'k,x,y,q,d,K,t0');
end
function o = SimpleLoop(o,oo)          % Loop Function                 
   [k,x,A,B,C] = var(o,'k','x','A','B','C');

      % progress run index and measure z
      
   k = k+1;
   u = var(oo,'u');                    % control signal
   y = [
          var(oo,'z');                 % zero cross time stamps
          var(oo,'y');                 % PWM phase
       ]; 
   
      % handle modulo jumps of timer counter based time
 
%  [o,x(2),t0] = ModuloJump(o,y(1),x(2));    % handle modulo jumps
   [o,x(2),t0] = ModuloJump(o,y(1),x(2));    % handle modulo jumps

      % Iterate Kalman equations 

%  [P,K,x,q,d,e] = Kalman(A,B,C,P,R,Q,x,u,y);
   K = 0*x;                            % dummy
   q = y;                              % observer output (dummy)
   d = y - q;                          % output deviation
     
   a = 0.95;
   g = a*x(1) + (1-a)*(y(1)-x(1)); 
   
   x(1) = g;                           % reconstructed grid period
   x(2) = y(1);                        % zero cross time stamps
   x(3) = x(3) + u;                    % PWM period ("height")
   x(4) = y(2);

   
      % variable storage & data logging
      
   o = var(o,'k',k, 'x',x, 'y',y, 'q',q, 'd',d);
   o = log(o,k,x,y,q,d,[0 0 0 0]',t0);
end

