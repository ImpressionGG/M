function oo = mcu(o,varargin)   % Algorithms for C-Implementation @ MCU
%
% MCU  Algorithms for C-implementation on a MCU
%
%       oo = mcu(o,'Menu')      % setup study menu
%
%    See also: PLL, PLOT, STUDY
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                      @RunLqr,@RunTwin,@Run);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % MCU Main Menu                 
   setting(o,{'mcu.noise'},1);         % noise on
   setting(o,{'mcu.magnitude'},3);     % large values (*1000)
   setting(o,{'mcu.feedback'},2);      % state feedback type 2
   setting(o,{'mcu.setpoint'},4);      % setpoint level 4
   setting(o,{'mcu.scheme'},1);        % Kalman Filter Control Scheme
   setting(o,{'mcu.constrain'},0);     % constrain control signal

   setting(o,{'mcu.kmax'},20);         % simulation steps

   oo = Scenario(o);                   % add Scenario menu
   oo = mitem(o,'Simulation Steps',{},'mcu.kmax');
        choice(oo,[5 20 50 100 200 500 1000],{});
   oo = mitem(o,'Run',{@Run});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Noise',{},'mcu.noise');
        choice(oo,{{'Off',0},{'On (Fixed)',1},{'On (Random)',2}},{});
   oo = mitem(o,'Magnitude',{},'mcu.magnitude');
        choice(oo,{{'Small',1},{'Large',3}},{});
   oo = mitem(o,'State Feedback',{},'mcu.feedback');
        choice(oo,{{'Moderate',0},{'Medium',1},{'Strong',2}},{});
   oo = mitem(o,'Setpoint Level',{},'mcu.setpoint');
        choice(oo,[0:10],{});
   oo = mitem(o,'Control Scheme',{},'mcu.scheme');
        choice(oo,{{'LQR',0},{'Kalman',1}},{});
   oo = mitem(o,'Constrain',{},'mcu.constrain');
          choice(oo,{{'No Constraint',0},...
                       {'8000...12000',1}},{});
        
   oo = mitem(o,'-');
        
   oo = mitem(o,'-');
   oo = mitem(o,'LQR Control',{@Callback,'RunLqr'},[]);
   oo = mitem(o,'Twin Control',{@Callback,'RunTwin'},[]);
end
function oo = Callback(o)                                              
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   mcu(oo);
end

function oo = Scenario(o)              % Scenario Menu                 
   setting(o,{'mcu.scenario'},00031);      
   
   oo = mitem(o,'Scenario',{},'mcu.scenario');
        choice(oo,{{'LQR: Small Values - Noise Off',00010},...
                   {'LQR: Small Values - Noise On', 00011},...
                   {},...
                   {'LQR: Large Values - Noise Off',00030},...
                   {'LQR: Large Values - Noise On', 00031},...
                   {},...
                   {'Kalman: Small Values - Noise Off',10010},...
                   {'Kalman: Small Values - Noise On', 10011},...
                   {},...
                   {'Kalman: Large Setpoint - Noise Off',114230},...
                   {'Kalman: Large Setpoint- Noise On', 114231},...
                  },{@Process});   
end
function o = Process(o)                % Scenario Processing           
%
% SCENARIO  Scenario number is composed of the following digits
%
%            111001
%            |||||'-- noise off/on (0/1)
%            ||||'--- numbers small/large (0/1) 
%            |||'---- state feedback type (0,1,2)
%            ||'----- setpoint 0/1000/2000/... (0/1/2/...)
%            |'------ control Scheme LQR/LQG (0/1)
%            '------- constrain u 0/1
%
% Examples 1: LQR control with state feedback type 0
%    00010: setpoint 0 / small numbers / noise off
%    00011: setpoint 0 / small numbers / noise on
%    04030: setpoint 4000 / large numbers / noise off
%    04031: setpoint 4000 / large numbers / noise on
%
% Examples 2: LQG control with various state feedback types
%    14210: setpoint 0 / small numbers / noise off
%    14211: setpoint 4 / state feedback 2 / small numbers / noise off
%
   scenario = int32(opt(o,'mcu.scenario'));
   
      % convert digits of scenario to value array
      
   for (i=1:6)
      value(i) = rem(scenario,10);
      scenario = floor(scenario/10);
   end
   value = double(value);
   
      % update settings

   check(o,'mcu.noise',value(1));
   choice(o,'mcu.magnitude',value(2));
   choice(o,'mcu.feedback',value(3));
   choice(o,'mcu.setpoint',value(4));
   choice(o,'mcu.scheme',value(5));
   choice(o,'mcu.constrain',value(6));

   o = pull(o);            % refresh object with updated options
   mcu(o,'Run');
end

%==========================================================================
% Helper
%==========================================================================

function [sigw,sigv] = Sigma(o)        % Get Noise Sigma Values        
   sigw = 10/3;
   sigv = 60/3;
end
function m = Magnitude(o)              % Get Magnitude                 
   m = opt(o,{'mcu.magnitude',3});
   m = 10^m;
end
function s = Setpoint(o)               % Get Setpoint                  
   s = opt(o,{'mcu.setpoint',4});
   s = s*Magnitude(o);
end
function y = Quantize(x)               % Quantizing Measurements       
   y = round(x);
end

%==========================================================================
% Control Simu for C-Translation
%==========================================================================

function q = AuxInit(o)                % Init Auxillary Data           
   if (opt(o,{'mcu.noise',0}) == 1)
      rng(0);                          % set random seed to zero
   end
   
   q.L = [0;0;0;0];                    % temporary 4x1 vector L
   q.I = [1 0; 0 1];                   % unit 2x2 matrix
   q.M = [0 0; 0 0];                   % temporary 2x2 matrix
   q.N = [0 0; 0 0];                   % temporary 2x2 matrix
   q.H = [0;0];                        % temporary 2x1 vector
   q.S = [1];                          % scalar
end
function p = Measurement(o,p)          % Measurement & Set Noise       
   if opt(o,{'mcu.noise',0})
      p.w = round(10 * randn/3);       % 3*sigma(w) = 10 us     
      p.v = round(60 * randn/3);       % 3*sigma(v) = 60 us     
   end
   
   p.W(1,1) = p.w;    % W = [w;0;0;0]  % pack dynamic noise
   p.V(1) = p.v;
   p.V(2) = p.v;      % V = [v;v]      % pack measurement noise
   
   p.t = p.C(1,:) * p.X;               % noise free objective
   p.q = p.C(2,:) * p.X;               % noise free objective
   p.Y = Quantize(p.C * p.X + p.V);
   
   p.z = p.Y(1,1);
   p.y = p.Y(2,1);
end

%==========================================================================
% PWM System
%==========================================================================

function p = SystemInit(o)             % Init System                   

      % system matrices
      
   p.A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   p.B = [0; 0; 1; -1];
   p.C = [0 1 0 0; 0 0 0 1];

      % input vector 

   p.U = [0];
   
      % initial state vector
      
   p.X = [20; 0; 10; 4]*Magnitude(o);
   
      % initial output vector
      
   p.Y = p.C*p.X;

      % system noise
      
   p.W = [1; 0; 0; 0];                 % dynamic noise matrix
   p.V = [1; 1];                       % measurement noise matrix
   
      % scalar quantities

   p.u = p.U(1,1);
  
   p.g = p.X(1,1);
   p.t = p.X(2,1);
   p.h = p.X(3,1);
   p.q = p.X(4,1);

   p.w = 0;                            % dynamic noise
   p.v = 0;                            % measurement noise

   p.z = p.Y(1,1);
   p.y = p.Y(2,1);   
   
   p.t0 = 0;
end
function p = SystemLoop(o,p,q)         % Loop System                   
%
%    Mathematical Description of Basic PWM System:
%
%        [ g' ]   [ 1   0   0   0 ]   [ g ]   [ 0 ]       [ 1 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ]
%        [ t' ]   [ 1   1   0   0 ]   [ t ]   [ 0 ]       [ 0 ]
%    x = [    ] = [               ] * [   ] + [   ] * u + [   ] * w 
%        [ h' ]   [ 0   0   1   0 ]   [ h ]   [ 1 ]       [ 0 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ] 
%        [ q' ]   [ 1   0  -2   1 ]   [ q ]   [-1 ]       [ 0 ]  
%
%                                     [ g ]   
%                                     [   ]
%        [ z  ]   [ 0   1   0   0 ]   [ t ]   [ 1 ]
%    Y = [    ] = [               ] * [   ] + [   ] * v 
%        [ y  ]   [ 0   0   0   1 ]   [ h ]   [ 1 ]
%                                     [   ]
%                                     [ q ]   
%
%    In matrix notation we have:
%
%       x := [g t h q]',  Y = [ z y]'
%
%       x' = A*x + B*u + W*w
%       Y  = C*x + V*v
%       Z  = C*x  =>  Y = Y + V*v
%
      % constrain u      
   p.W(1,1) = p.w;    % W = [w;0;0;0]  % pack dynamic noise
   p.V(1,1) = p.v;    
   p.V(2,1) = p.v;    % V = [v;v]      % pack measurement noise
      
      % Y = C*X + V

   p.Y = Quantize(p.C * p.X + p.V);    % output equation

      % z = Y(1);  y = Y(2)            % pick out signals from out vector

   p.z = p.Y(1,1);                     % out 1: zero cross time stamps
   p.y = p.Y(2,1);                     % out 2: PWM phase

      %  current state: g = X(1);  t = X(2);  h = X(3);  q = X(4);

   p.g = p.X(1,1);      % g = X(1)     % grid period
   p.t = p.X(2,1);      % t = X(2)     % zero cross time stamp
   p.h = p.X(3,1);      % h = X(3)     % PWM period ("height")
   p.q = p.X(4,1);      % q = X(4)     % PWM phase (captured PWM counter)

      % constrain u and pack into input vector U
      
   p.u = Constrain(o,p.u,p.h);         % Constrain PWM Height 
   p.U(1,1) = p.u;    % U = [u]        % pack control input vector
   
      % state transition: X' = A*X + B*U + W*w

   q.L = p.B * p.U;                    % L = B*U
   p.X = p.A * p.X;                    % X' = A*X ... 
   p.X = p.X + q.L;                    % X' = A*X + B*U ...     
   p.X = p.X + p.W;                    % X' = A*X + B*U + W    

   while (p.X(2) >= 40000)
      p.X(2) = p.X(2) - 40000;         % handle modulo character of time
      p.t0 = p.t0 + 40000;
   end
end

%==========================================================================
% State Controller
%==========================================================================

function u = Constrain(o,u,h)          % Constrain PWM Height          
   if opt(o,{'mcu.constrain',0})
      hmin = 8000;  hmax = 12000;
   
      if (h+u > hmax)
         u = hmax - h;                 % to cause h(k+1) = hmax
      elseif (h+u < hmin)
         u = hmin-h;                   % to cause h(k+1) = hmin
      end
   end
end

function p = ControlInit(o)            % Init Controller               
   switch opt(o,{'mcu.feedback',0})
      case 1      % medium
         p.K = [0.0  +1.4721  -0.7639  -0.2361];
      case 2      % strong
         p.K = [0.0  +1.6077  -0.9503  -0.3315];
      otherwise   % moderate
         p.K = [0 -1.2 0.5 0.2];
   end

   p.X = [0.0; 0.0; 0.0; 0.0];
   p.U = [0.0];

   p.U = p.K * p.X;
   
   p.u = p.U(1,1);                     % control signal

      % input state variables

   p.g = 0;  p.h = 0;  p.q = 0;
   p.f = p.X(4,1);                     % auxillary state variable
   p.f_= p.X(4,1);                     % auxillary state after transition

      % reference signal r and reference gain s

   p.s = -1.0;                         % reference gain
   p.r = 4000;                         % some stupid setpoint value
end
function p = ControlLoop(o,p,q)        % Loop Controller               
   p.f = p.f_;                         % take over prepared transition

      % compose state feedback vector: X = [g;h;q;f]
      
   p.X(1,1) = p.g;      % X(1) = g  -  grid period
   p.X(2,1) = p.h;      % X(2) = h  -  zero cross time stamp
   p.X(3,1) = p.q;      % X(3) = q  -  PWM period ("height")
   p.X(4,1) = p.f;      % X(4) = f  -  PWM phase (captured PWM counter)

      % calculate control signal (vector)

   p.U = p.K*p.X;       % U = ... K*X
   p.U = -p.U;          % U = -K*X
   p.u = p.U(1,1);      % u = U(1)
      
      % control error
      
   p.e = p.r - p.y;

      % auxillary state transition: f -> f_

   p.f_ = p.f + p.q + p.s * p.r;        % f' = f + y + s*r    
end

function p = QndControlInit(o)         % Init QnD Controller           
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   A = [1 0;-2 1];  B = [1;-1];

   switch opt(o,{'qnd.feedback',0})
      case 0                                % moderate - LQR [1 1] @ 1
         K = dlqr(o,A,B,diag([1 1]),1);     % K = [1.2263 -0.3460]
         poles = eig(A-B*K)';               % poles: 0.2138 +- i*0.272
         
      case 1                                % medium - LQR [1 1] @ 0 => dead beat
         K = dlqr(o,A,B,diag([1 10]),1);     % K = [1.5 -0.5] (dead beat)
         poles = eig(A-B*K)';               % poles: 0.1626 +- i*0.785
         
      case 2   % strong, approx LQR [0 1] @ 0
         K = dlqr(o,A,B,diag([0 1]),0);     % K = [2 -1]
         poles = eig(A-B*K)';               % poles: 0.1626 +- i*0.785
         K = [2 -1];
         
      case 3   % poles @ 0.0)
         K = place(A,B, 0.0*[1 1]);         % K = [1.5 -0.5]
         poles = eig(A-B*K)';               % poles: 0.0
         
      case 4   % poles @ 0.2
         K = place(A,B, 0.2*[1 1]);         % K = [1.28 -0.32]
         poles = eig(A-B*K)';               % poles: 0.2

      case 5   % poles @ 0.4
         K = place(A,B, 0.4*[1 1]);         % K = [1.02 -0.18]
         poles = eig(A-B*K)';               % poles: 0.4

      case 6   % poles @ 0.6
         K = place(A,B, 0.6*[1 1]);         % K = [0.72 -0.08]
         poles = eig(A-B*K)';               % poles: 0.6

      case 7   % poles @ 0.8
         K = place(A,B, 0.8*[1 1]);         % K = [0.38 -0.02]
         poles = eig(A-B*K)';               % poles: 0.8

      otherwise   % moderate (poles @ 0.8)
         K = dlqr(o,A,B,diag([1 1000]),1);
   end

   p.K = [-K(1)/2, K(1), K(2), -K(2)];
   p.X = [0.0; 0.0; 0.0; 0.0];
   p.U = [0.0];

   p.U = p.K * p.X;
   
   p.u = p.U(1,1);                     % control signal

      % input state variables

   p.g = 0;  p.h = 0;  p.q = 0;
   p.f = 0;                            % auxillary state variable

      % reference signal r and reference gain s

   p.r = 4000;                         % some stupid setpoint value
end
function p = QndControlLoop(o,p,q)     % Loop QnD Controller           

      % compose state feedback vector: X = [g;h;q;f]
      
   p.X(1,1) = p.g;      % X(1) = g  -  grid period
   p.X(2,1) = p.h;      % X(2) = h  -  zero cross time stamp
   p.X(3,1) = p.q;      % X(3) = q  -  PWM period ("height")
   p.X(4,1) = p.r;      % X(4) = r  -  PWM phase reference

      % calculate control signal (vector)

   p.U = p.K*p.X;       % U = ... K*X
   p.U = -p.U;          % U = -K*X
   p.u = p.U(1,1);      % u = U(1)
      
      % control error
      
   p.e = p.r - p.y;    
end

%==========================================================================
% Twin Kalman Filter
%==========================================================================

function p  = Kalman(p,q)              % Kalman Iteration              
% 
% KALMAN   Iterate Kalman equations 
%
%          1) Ricati equation:
%
%             M = A*P*A' + Q;
%             K = M*C' * inv(C*M*C'+R);
%             P = (I-K*C)*M;
%
%          2) Observer state transition
%
%             h = A*x + B*u;           % half transition
%             e = y - C*h;             % error signal
%             x = h + K*e;             % full transition
%
%          3) Output signals
%
%             q = C*x;                 % Kalman filter output
%             d = y - q;               % output deviation
%

      % start with M = A*P*A' + Q;
      
   q.N = p.A * p.P;                    % N = A*P ...
   p.P = p.A';                         % P = ... A' ...
   q.M = q.N * p.P;                    % M = (A*P)*A' ...
   q.M = q.M + p.Q;                    % M = A*P*A' + Q
      
      % calculate:  K = M*C' * inv(C*M*C'+R);
   
   q.S = inv(p.C * q.M * p.C' + p.R);  % S = inv(C*M*C'+R)
   p.K = p.C';                         % K = ... C' ...
   p.K = q.M * p.K;                    % K = M*C' ...
   p.K = p.K * q.S;                    % K = M*C' * inv(C*M*C'+R)
   
      % update: P = (I-K*C)*M;

   q.N = p.K * p.C;                    % N = (... K*C)...
   q.N = q.I - q.N;                    % N = (I-K*C)...
   p.P = q.N * q.M;                    % P = (I-K*C)*M...

      % observer state transition
      % begin with half transition: h = A*x + B*u
      
   q.H = p.A * p.X;                    % H = A*X ...
   p.X = p.B * p.U;                    % X = ... B*U
   q.H = q.H + p.X;                    % H = A*X + B*U
   
      % error signal: e = y - C*h

   p.E = p.C * q.H;                    % E = ... C*H
   p.E = p.Y - p.E;                    % E = Y - C*H
      
      % full transition: x = h + K*e
      
   p.X = p.K * p.E;                    % X = ... K*E
   p.X = q.H + p.X;                    % X = H + K*E
end
function p  = KalmanAlgo(p,q)          % Kalman Filter Algorithm       
% 
% KALMAN   Iterate Kalman equations 
%
%          1) Ricati equation:
%
%             M = A*P*A' + Q;
%             K = M*C' * inv(C*M*C'+R);
%             P = (I-K*C)*M;
%
%          2) Observer state transition
%
%             h = A*x + B*u;           % half transition
%             e = y - C*h;             % error signal
%             x = h + K*e;             % full transition
%
%          3) Output signals
%
%             q = C*x;                 % Kalman filter output
%             d = y - q;               % output deviation
%

      % Ricati equation:

   q.M = p.A*p.P*p.A' + p.Q;
   p.K = q.M*p.C' * inv(p.C*q.M*p.C'+p.R);
   p.P = (eye(2)-p.K*p.C)*q.M;
   
      % observer state transition

   q.H = p.A*p.X + p.B*p.U;            % half transition
   p.E = p.Y - p.C*q.H;                % error signal
   p.X = q.H + p.K*p.E;                % full transition

      % output signals

   p.q = p.C*p.X;                      % Kalman filter output
   p.d = p.Y - p.q;                    % output deviation
end

function p1 = Kalman1Init(o)           % Init Kalman Filter 1          
%
%    Mathematical Description of Basic PWM System:
%
%        [ g' ]   [ 1   0   0   0 ]   [ g ]   [ 0 ]       [ 1 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ]
%        [ t' ]   [ 1   1   0   0 ]   [ t ]   [ 0 ]       [ 0 ]
%    x = [    ] = [               ] * [   ] + [   ] * u + [   ] * w 
%        [ h' ]   [ 0   0   1   0 ]   [ h ]   [ 1 ]       [ 0 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ] 
%        [ q' ]   [ 1   0  -2   1 ]   [ q ]   [-1 ]       [ 0 ]  
%
%                                     [ g ]   
%                                     [   ]
%        [ z  ]   [ 0   1   0   0 ]   [ t ]   [ 1 ]
%    Y = [    ] = [               ] * [   ] + [   ] * v 
%        [ y  ]   [ 0   0   0   1 ]   [ h ]   [ 1 ]
%                                     [   ]
%                                     [ q ]   
%
%    In matrix notation we have:
%
%       x := [g t h q]',  Y = [ z y]'
%
%       x' = A*x + B*u + W*w
%       Y  = C*x + V*v
%       Z  = C*x  =>  Y = Y + V*v
%
%    The Twin-Kalman observer is structured as follows
%
%    Kalman filter 1:
%                                                     [ h ]
%          [ g' ]   [ 1   0 ]   [ g ]   [ 0  0  0 ]   [   ]   [ 1 ]
%    x1' = [    ] = [       ] * [   ] + [         ] * [ q ] + [   ] * w
%          [ t' ]   [ 1   1 ]   [ t ]   [ 0  0  0 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ g ]
%    y1  = [ z  ] = [ 0   1 ] * [   ] + v     
%                               [ t ]
%
%    Kalman filter 2:
%                                                     [ g ]
%          [ h' ]   [ 1   0 ]   [ h ]   [ 0  0  1 ]   [   ]   [ 0 ]
%    x2' = [    ] = [       ] * [   ] + [         ] * [ t ] + [   ] * w
%          [ q' ]   [-2   1 ]   [ q ]   [ 1  0 -1 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ h ]
%    y2  = [ y  ] = [ 0   1 ] * [   ] + v     
%                               [ q ]   
%
   [sigw,sigv] = Sigma(o);

      % Kalman matrices

%  p1.P = [1e6 0; 0 1e6];              % state 1 covariance
   p1.P = [1e5 0; 0 1e7];              % state 1 covariance
   p1.Q = [sigw^2 0; 0 0];             % dynamic noise 1 covariance
   p1.R = [sigv^2];                    % measurement noise 1 covariance
   p1.K = [0;0];                       % Kalman gain 1
   
      % subsystem 1 system matrices
      
   p1.A = [1 0; 1 1];                  % dynamic matrix 1
   p1.B = [0 0 0; 0 0 0];              % input matrix 1
   p1.C = [0 1];                       % output matrix 1
   
      % input vectors

   p1.U = [0;0;0];                     % input vector 1 (remains zero)
   p1.Y = [0];                         % measurement vector 1
   
      % init state
      
   if (opt(o,{'mcu.scenario',0}) > 2)
      p1.X = [18000; 0];               % large values
   else
      p1.X = [180; 0];                 % small values
   end
   
      % scalar quantities

   p1.z = p1.Y(1,1);                   % zero cross time stamps
  
   p1.g = p1.X(1,1);                   % observed grid period
   p1.t = p1.X(2,1);                   % observed zero cross time stamps
   p1.yo = 0;                          % remember last measurement
end
function p2 = Kalman2Init(o)           % Init Kalman Filter 2          
%
%    Mathematical Description of Basic PWM System:
%
%        [ g' ]   [ 1   0   0   0 ]   [ g ]   [ 0 ]       [ 1 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ]
%        [ t' ]   [ 1   1   0   0 ]   [ t ]   [ 0 ]       [ 0 ]
%    x = [    ] = [               ] * [   ] + [   ] * u + [   ] * w 
%        [ h' ]   [ 0   0   1   0 ]   [ h ]   [ 1 ]       [ 0 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ] 
%        [ q' ]   [ 1   0  -2   1 ]   [ q ]   [-1 ]       [ 0 ]  
%
%                                     [ g ]   
%                                     [   ]
%        [ z  ]   [ 0   1   0   0 ]   [ t ]   [ 1 ]
%    Y = [    ] = [               ] * [   ] + [   ] * v 
%        [ y  ]   [ 0   0   0   1 ]   [ h ]   [ 1 ]
%                                     [   ]
%                                     [ q ]   
%
%    In matrix notation we have:
%
%       x := [g t h q]',  Y = [ z y]'
%
%       x' = A*x + B*u + W*w
%       Y  = C*x + V*v
%       Z  = C*x  =>  Y = Y + V*v
%
%    The Twin-Kalman observer is structured as follows
%
%    Kalman filter 1:
%                                                     [ h ]
%          [ g' ]   [ 1   0 ]   [ g ]   [ 0  0  0 ]   [   ]   [ 1 ]
%    x1' = [    ] = [       ] * [   ] + [         ] * [ q ] + [   ] * w
%          [ t' ]   [ 1   1 ]   [ t ]   [ 0  0  0 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ g ]
%    y1  = [ z  ] = [ 0   1 ] * [   ] + v     
%                               [ t ]
%
%    Kalman filter 2:
%                                                     [ g ]
%          [ h' ]   [ 1   0 ]   [ h ]   [ 0  0  1 ]   [   ]   [ 0 ]
%    x2' = [    ] = [       ] * [   ] + [         ] * [ t ] + [   ] * w
%          [ q' ]   [-2   1 ]   [ q ]   [ 1  0 -1 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ h ]
%    y2  = [ y  ] = [ 0   1 ] * [   ] + v     
%                               [ q ]   
%
   [sigw,sigv] = Sigma(o);

      % Kalman matrices

%  p2.P = [1e6 0; 0 1e6];              % state 2 covariance
   p2.P = [1e3 0; 0 1e6];              % state 2 covariance
   p2.Q = [0 0; 0 5*sigw^2];             % dynamic noise 2 covariance
   p2.R = [sigv^2];                    % measurement noise 2 covariance
   p2.K = [0;0];                       % Kalman gain 2
   
      % subsystem 2 system matrices

   p2.A = [1 0;-2 1];                  % dynamic matrix 2
   p2.B = [0 0,1; 1 0,-1];             % input matrix 2
   p2.C = [0 1];                       % output matrix 2
   
      % input vectors

   p2.U = [0;0;0];                     % input vector 2
   p2.Y = [0];                         % measurement vector 2
   
      % init state
      
   p2.X = [10000; 0];                  % small & large values
   
      % scalar quantities

   p2.g = p2.U(1,1);                   % g = p1.X(1)
   p2.t = p2.U(2,1);                   % t = p1.X(2)
   p2.u = p2.U(3,1);                   % control input
   
   p2.y = p2.Y(1,1);                   % PWM phase measurement
   
   p2.h = p2.X(1,1);                   % observed PWM period 
   p2.q = p2.X(2,1);                   % observed PWM phase
end
function p1 = Kalman1Loop(p1,q)        % Loop Kalman Filter 1          
%
%    The Twin-Kalman observer is structured as follows
%
%    Kalman filter 1:
%                                                     [ h ]
%          [ g' ]   [ 1   0 ]   [ g ]   [ 0  0  0 ]   [   ]   [ 1 ]
%    x1' = [    ] = [       ] * [   ] + [         ] * [ q ] + [   ] * w
%          [ t' ]   [ 1   1 ]   [ t ]   [ 0  0  0 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ g ]
%    y1  = [ z  ] = [ 0   1 ] * [   ] + v     
%                               [ t ]
%
%    Kalman filter 2:
%                                                     [ g ]
%          [ h' ]   [ 1   0 ]   [ h ]   [ 0  0  1 ]   [   ]   [ 0 ]
%    x2' = [    ] = [       ] * [   ] + [         ] * [ t ] + [   ] * w
%          [ q' ]   [-2   1 ]   [ q ]   [ 1  0 -1 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ h ]
%    y2  = [ y  ] = [ 0   1 ] * [   ] + v     
%                               [ q ]   
%
%    These are the first five Kalman gain vectors:
%
%       k = 0: K1 = [0.4999, 0.9998]',  K2 = [-0.4000, 0.9999]'
%       k = 1: K1 = [0.9980, 0.9992]',  K2 = [-0.4993, 0.9995]'
%       k = 2: K1 = [0.5019, 0.8338]',  K2 = [-0.2499, 0.8331]'
%       k = 3: K1 = [0.3073, 0.7034]',  K2 = [-0.1499, 0.6999]'
%       k = 4: K1 = [0.2151, 0.6096]',  K2 = [-0.1000, 0.5999]'
%
   period = 40000;                     % timer period
   
      % U1 = [0;0;0] - pack control signal into control input vector 

   p1.U(1,1) = 0;
   p1.U(2,1) = 0;     % U1 = [0;0;0]   % pack input vector
   p1.U(3,1) = 0;

      % Y1 = [z] - pack measured zero cross time stamps 

   p1.Y(1,1) = p1.z;   % Y1 = [z]      % pack input vector

      % handle modulo jump
      
   if (p1.Y(1,1) < p1.yo - period/4)   % did y jump back?
       p1.X(2,1) = p1.X(2,1) - period; % state correction
   end
   p1.yo = p1.Y(1,1);                  % remember last measurement

      % run Kalman iteration
      
   p1 = Kalman(p1,q);                  % Kalman iteration

      % scalar results
      
   p1.g = p1.X(1,1);                   % observed grid period
   p1.t = p1.X(2,1);                   % observed zero cross time stamps
end
function p2 = Kalman2Loop(p2,q)        % Loop Kalman Filter 2          
%
%    The Twin-Kalman observer is structured as follows
%
%    Kalman filter 1:
%                                                     [ h ]
%          [ g' ]   [ 1   0 ]   [ g ]   [ 0  0  0 ]   [   ]   [ 1 ]
%    x1' = [    ] = [       ] * [   ] + [         ] * [ q ] + [   ] * w
%          [ t' ]   [ 1   1 ]   [ t ]   [ 0  0  0 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ g ]
%    y1  = [ z  ] = [ 0   1 ] * [   ] + v     
%                               [ t ]
%
%    Kalman filter 2:
%                                                     [ g ]
%          [ h' ]   [ 1   0 ]   [ h ]   [ 0  0  1 ]   [   ]   [ 0 ]
%    x2' = [    ] = [       ] * [   ] + [         ] * [ t ] + [   ] * w
%          [ q' ]   [-2   1 ]   [ q ]   [ 1  0 -1 ]   [   ]   [ 0 ]
%                                                     [ u ]
%                               [ h ]
%    y2  = [ y  ] = [ 0   1 ] * [   ] + v     
%                               [ q ]   
%
%    These are the first five Kalman gain vectors:
%
%       k = 0: K1 = [0.4999, 0.9998]',  K2 = [-0.4000, 0.9999]'
%       k = 1: K1 = [0.9980, 0.9992]',  K2 = [-0.4993, 0.9995]'
%       k = 2: K1 = [0.5019, 0.8338]',  K2 = [-0.2499, 0.8331]'
%       k = 3: K1 = [0.3073, 0.7034]',  K2 = [-0.1499, 0.6999]'
%       k = 4: K1 = [0.2151, 0.6096]',  K2 = [-0.1000, 0.5999]'
%

      % U2 = [g;t;u] - pack control signal into control input vector 

   p2.U(1,1) = p2.g;
   p2.U(2,1) = p2.t;    % U2 = [g;t;u] % pack input vector
   p2.U(3,1) = p2.u;

      % Y2 = [y] - pack measured zero cross time stamps 

   p2.Y(1,1) = p2.y;   % Y2 = [y]      % pack input vector

      % run Kalman iteration
      
   p2 = Kalman(p2,q);                  % Kalman iteration

      % scalar results
      
   p2.h = p2.X(1,1);                   % observed PWM period
   p2.q = p2.X(2,1);                   % observed PWM phase
end

%==========================================================================
% Control Scheme
%==========================================================================

function SignalTrace(o)                % Trace Signal Values           
   d = data(o);
   i = length(d.k);
   
   k = d.k(i);  u = floor(d.u(i));  y = floor(d.y(i));
   g = floor(d.g(i));  h = floor(d.h(i));  q = floor(d.q(i)); 
   f = floor(d.f(i)); w = d.w(i);  v = d.v(i);
   
   sum = k+u+y+g+h+q+f+w+v;
   
   switch opt(o,{'mcu.scenario',0})
      case 00010                       % small values - noise off
         table = [280 599 1057 1283 1243 1056];
      case 00011                       % small values - noise on
         table = [356 627 1005 1280 1335 1148];
      case 00030                           % large values - noise off
         table = [28000 59801 105542 128165 124162 105434];
      case 00031                           % large values - noise on
         table = [28076 59829 105490 128162 124252 105525];
      case 10010                       % small values - noise off
         table = [-3901,11869,19106,11159,775,-5642];
      case 10011                       % small values - noise off
         table = [-3798,12183,18464,10539,1878,-2548];
      case 114230                       % small values - noise off
         table = [38585,23686,68289,90389,82021,76242];
      case 114231                       % small values - noise off
         table = [36076,40063,50000,67149,79901,84591,84308,77888,73824,73959];
    otherwise
         error('bad scenario');
   end
   
   if (k+1 > length(table))
      nonce = 99999;
   else
      nonce = sum - table(k+1);
   end
   ch = o.iif(nonce,'*** ','    ');
   
   fprintf(['%sk:%3g u:%6g, y:%6g |  w:%3g v:%3g | ',...
            'g:%6g, h:%6g, q:%6g, f:%6g\n'],ch,k,u,y,w,v,g,h,q,f);
         
   xf = data(o,'xf');
   if ~isempty(xf)
      gf = floor(xf(1,i));
      tf = floor(xf(2,i));
      hf = floor(xf(3,i));
      qf = floor(xf(4,i));
      fprintf(['                             |              | ',...
            'g^%6g, h^%6g, q^%6g, t^%6g\n'],gf,hf,qf,tf);
   end
end

function o = RunLqr(o)                 % Run LQR Control Loop          
   aux = AuxInit(o);
   sys = SystemInit(o);
   con = ControlInit(o);

   setpoint = Setpoint(o);
   
   oo = log(o,'k,t,r,e,u,y,w,v,x,g,h,q,f');

   kmax = opt(o,{'mcu.kmax',20});
   for (k=0:kmax)
      sys = Measurement(o,sys);        % add noise to system

         % call controller loop function

      con.r = setpoint;                % set reference equal setpoit value
      con.y = sys.y;                   % to calculate control error 
      
      con.g = sys.X(1);
      con.h = sys.X(3);
      con.q = sys.X(4);
      
      con = ControlLoop(o,con,aux);

         % call PWM system loop (system transition)

      sys.u = con.u;

         % call PWM system loop (system transition)

      sys = SystemLoop(o,sys,aux);

         % tracing

      oo = log(oo, k, k, con.r, con.e, sys.u, sys.y, sys.w, sys.v,...
                   sys.X, sys.g, sys.h, sys.q, con.f);
      SignalTrace(oo);
   end
   
   o = type(o,'con');  
   plot(o,oo,oo);
end
function o = RunTwin(o)                % Run Twin Control Loop         
   aux = AuxInit(o);
   sys = SystemInit(o);
   kf1 = Kalman1Init(o);               % init Kalman filter 1
   kf2 = Kalman2Init(o);               % init Kalman filter 2
   con = QndControlInit(o);

   setpoint = Setpoint(o);

   oo = log(o,'k,t,r,e,u,y,o,w,v,x,xf,g,h,q,f,t0');

   kmax = opt(o,{'mcu.kmax',20});
   for (k=0:kmax)
      sys = Measurement(o,sys);

         % run Kalman filter 1 loop
         
      kf1.z = sys.Y(1); % zero cross measurement
      kf2.y = sys.Y(2); % PWM phase measurement
      
      kf1 = Kalman1Loop(kf1,aux);

         % run Kalman filter 2 loop
         % take constrained u from system (not controller)
         
      kf2.g = kf1.X(1); % set Kalman filter 2 input U(1)
      kf2.t = kf1.X(2); % set Kalman filter 2 input U(2)
      kf2.u = sys.u;    % set Kalman filter 2 input U(3)
      
      kf2 = Kalman2Loop(kf2,aux);

         % run controller loop

      con.r = setpoint;                % set reference equal setpoint value
      
      con.g = kf1.X(1);
      con.h = kf2.X(1);
      con.q = kf2.X(2);
      
      con.y = kf2.q;                   % copy control objective

      con = QndControlLoop(o,con,aux);

         % run PWM system loop

      sys.u = con.u;                   % copy controlsignal into system

      sys = SystemLoop(o,sys,aux);

         % tracing

      oo = log(oo, k, k, con.r, con.e, sys.u, sys.y, con.y, sys.w, sys.v,...
                   sys.X,[kf1.X;kf2.X], sys.g, sys.h, sys.q, con.f, sys.t0);
      SignalTrace(oo);
   end

   plot(type(o,'con'),oo,oo);
   setting(o,'log',data(oo));          % save oo
   
   subplot(223);
   if (max(get(gca,'ylim')) > 20)
      set(gca,'ylim',[19.9 20.1]);
   end
end

function o = Run(o)                    % Run Control Scheme            
   refresh(o,o);
   cls(o);
   scheme = opt(o,'mcu.scheme');
   switch scheme
      case 0
         RunLqr(o);
      case 1
         RunTwin(o);
   end
end
