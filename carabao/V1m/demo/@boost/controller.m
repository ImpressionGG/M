function o = controller(o,varargin)    % Triac And Boost Controller    
%
% CONTROLLER   Implement a controller on different test stages
%
%              1) Triac & Boost Controller
%              ===========================
%
%                 TriacBoost(o)        % triac & boost controller
%
%              The Triac & Boost Controller can be operated in several
%              modes:
%
%                 a) Kinds of grid voltage measurement
%                    - state model based grid voltage simulation
%                    - core generated grid voltage generation
%                 b) Observer type 
%                    - Luenberger observer
%                    - Kalman observer
%                 c) Noise Sources
%                    - no noise at all
%                    - process noise / frequency mismatch
%                    - measurement noise
%                    - time jitter noise
%
%              to simulate noise free, or to add measurement noise, process
%              noise and time jitter noise.
%
%
%              2) Rectangle Wave
%              =================
%
%                 RectangleWave(o)     % rectangle wave generatin
%
%              A rectangle wave is generated as a very simplified demo of
%              a setup for a Tick-Tock-Engine
%
%              See also: BOOST, ENGINE, CORE
%
   [gamma,oo] = manage(o,varargin,@Setup,@TriacBoost,@Rectangle,@Special);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   oo = mhead(o,'Controller');
   ooo = mitem(oo,'Triac & Booster',{@invoke,mfilename,@TriacBoost});
   ooo = mitem(oo,'Rectangle Wave',{@invoke,mfilename,@Rectangle});
   ooo = mitem(o,'-');
   ooo = mitem(oo,'Simulation',{@invoke,mfilename,@TriacBoost});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Luenberger');
   oooo = mitem(ooo,'Nominal Parameters',{@Special,'L-Nominal'});
   oooo = mitem(ooo,'No Initial Phase',{@Special,'L-NoInit'});
   oooo = mitem(ooo,'High Sampling Rate',{@Special,'L-HighRate'});
   oooo = mitem(ooo,'Noisy',{@Special,'L-Noisy'});
   oooo = mitem(ooo,'Noisy / High Sampling',{@Special,'L-NoisyHigh'});
   ooo = mitem(oo,'Kalman');
   oooo = mitem(ooo,'Nominal Parameters',{@Special,'K-Nominal'});
   oooo = mitem(ooo,'No Initial Phase',{@Special,'K-NoInit'});
   oooo = mitem(ooo,'High Sampling Rate',{@Special,'K-HighRate'});
   oooo = mitem(ooo,'Noisy',{@Special,'K-Noisy'});
   oooo = mitem(ooo,'Noisy / High Sampling',{@Special,'K-NoisyHigh'});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);

end

%==========================================================================
% Some Helper Functions
%==========================================================================

function [A,B,C] = System(T,f)         % create system matrices A,B,C  
   om = 2*pi*f;
   s = sin(om*T);  c = cos(om*T);
   A = [c -s; s c];                    % system matrix
   B = [0; 0];  C = [0.01 0];          % input/output matrix
end
function phi = Phase(x)                % Calculate Phase from State    
   phi = atan2(x(2),x(1))*180/pi;      % estimated phase
   phi = phi + 90;                     % 90° crrection                 
   phi = rem(phi+360,360);             % mapped to interval [0,360)
end

   % auxillary functions to set triac and boost control angles

function Triac(on,off)                 % Setup Triac control angles    
%
% TRIAC   Triac control
%
%         triac(60,64)              % set Triac on/off angles [°]
%
   global X                            % our global variables
   X.triac.angle(1) = on;              % triac control leading angle [°]
   X.triac.angle(2) = off;             % triac control trailing angle [°]
   X.triac.angle(3) = on + 180;        % triac control leading angle [°]
   X.triac.angle(4) = off + 180;       % triac control trailing angle [°]
   
   X.triac.enable = (on ~= 0 || off ~= 0);
end
function Boost(on,off)                 % Setup Booster On-Off Angles   
   global X                            % our global variables
   X.boost.angle(1) = on;              % store booster on angle [°]
   X.boost.angle(2) = off;             % store booster off angle [°]
   X.boost.angle(3) = on + 180;        % store booster on angle [°]
   X.boost.angle(4) = off + 180;       % store booster off angle [°]

   X.boost.enable = (on ~= 0 || off ~= 0);
end

%==========================================================================
% Eight Engine Standard Functions & Initializing Function
%==========================================================================
  
   % Eight engine functios. Pointers to these functions
   % are stored in X.engine,so the engine knows what to call

function Clear(o)                      % Clear System Clock            
   global X                            % our global variables
   core(o,'ClockClear');               % clear clock in core layer
end
function Start(o)                      % Start Measurements            
   global X                            % our global variables
   t = X.timing.t;                     % global store back system time
   Tm = 0.0003;                        % 300µs measurement time
   sigt = X.timing.sigt;               % sigma for time jitter
   Tm = Tm * (1+sigt*abs(randn));      % time for measurement

   X.timing.clock = Tm;                % update clock time
   X.timing.t = t + Tm;                % update system time
   core(o,'MeasureStart',t);           % clear clock in core layer
end
function Process(o)                    % Process Transition            
   function [x,f,T,sv,sw] = Unpack     % Unpack Process Stuff          
      x = X.process.x;              % unpack old state
      f = X.process.f;              % unpack frequency
      T = X.timing.Tk;              % sampling time
      sv = opt(o,'controller.sigv');     % measurement noise
      sw = opt(o,'controller.sigw');     % process noise
   end
   function Pack(x,y,phi)              % Pack Process State            
      X.process.x = x;              % save state after transition 
      X.process.y = y;              % save output after transition
      X.process.phi = phi;          % save process phase
   end
   function Simulation(o)              % Process Simulation            
      [xo,f,T,sv,sw] = Unpack;      % unpack process state

      [A,B,C] = System(T,f);        % model mismatch 50Hz <-> 60Hz
      x = A*xo + sw*randn(2,1);     % process state transition
      y = C*x + sv*randn;           % system output (measuring)
      y = max(y,-0.2);              % saturation of measurement

      phi = Phase(x);               % phase of grid voltage
      Pack(x,y,phi);                % pack process state
   end

   global X                            % our global variables
   switch X.process.mode               % dispatch process simulation mode
      case 0                           % simulation 
         Simulation(o);                % simulation of process
      case 1                           % use core functions
         Measurement(o);               % measurement of process
   end
end
function Observer(o)                   % Observer Transition           
   function Luenberger(o)              % Luenberger Observer Transition
      function [z,y,f,K,h,T] = Unpack % Unpack Observer Part of State 
         y = X.process.y; 
         z = X.observer.z;
         f = X.observer.f;  
         K = X.observer.K;
         h = X.observer.h;          % threshold to enable correction
         T = X.timing.Tk;           % threshold to enable correction
      end
      function Pack(z,q,d,phi)      % Pack Observer Part of State   
         X.observer.z = z;
         X.observer.q = q;             % save state after transition 
         X.observer.phi = phi;         % save phase angle
         X.observer.d = d;             % output deviation 
      end

      [zo,y,f,K,h,T] = Unpack;      % unpack observer part of state

      [A,B,C] = System(T,f);        % calculate system matrices A,B,C

      zp = A*zo;                    % predicted z
      qp = C*zp;                    % predicted observer output
      c = K * (y - qp);             % observer state correction 
      if (y < h)                    % if y is less than threshold h
         c = c*0;                   % no correction for negative y
      end
      z = zp + c;                   % observer state transition
      q = C*z;                      % observer output
      d = y - q;                    % output deviation

      phi = Phase(z);               % estimated phase of grid voltage
      Pack(z,q,d,phi);              % pack observer part of state
   end
   function Kalman(o)                  % Kalman Observer Transition    
      function [z,y,f,P,Q,R,h,T] = Unpack % Unpack Observer Part    
         h = X.observer.h;             % threshold to enable correction
         z = X.observer.z;
         y = X.process.y;
         P = X.kalman.P;
         f = X.observer.f;
         Q = X.kalman.Q;
         R = X.kalman.R;
         T = X.timing.Tk;
      end
      function Pack(z,q,d,P,phi)    % Pack Observer Part            
         X.observer.z = z;             % save observer state
         X.observer.q = q;
         X.kalman.P = P;               % save covariance after transition 
         X.observer.d = d;             % save deviation for logging 
         X.observer.phi = phi;         % save phase angle
      end
      function [P,K] = Ricc(P,A,C,Q,R) % Riccati Equation           
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
      end

      [zo,y,f,P,Q,R,h,T] = Unpack;  % unpack Kalman observer part
      [A,B,C] = System(T,f);        % calculate system matrices A,B,C
      [P,K] = Ricc(P,A,C,Q,R);      % calculate Kalman gain

      zp = A*zo;                    % predicted state
      qp = C*zp;                    % predicted observer output
      c = K * (y - qp);             % observer state correction
      if (y < h)
         c = c*0;                   % no correction for negative y
      end
      z = zp + c;                   % observer state update
      q = C*z;                      % reconstructed process output
      d = y - q;                    % output deviation

      phi = Phase(z);               % estimated phase of grid voltage
      Pack(z,q,d,P,phi);            % pack observer part of state
   end

      % let's go - dispatch on observer.mode

   global X                            % our global variables
   switch X.observer.mode
      case 0
         Luenberger(o);                % Luenberger observer transition
      case 1
         Kalman(o);                    % Kalman observer transition
   end
end
function Log(o)                        % Data Logging                  
%
% LOG  Initialize a log object or add log data to log object
%
%         Log([])                   % initialize log object
%         Log(o)                    % add log data to log object
%
   global X                            % our global variables
   if isempty(o)                       % initialize log object
      oo = boost('observer');          % create an 'observer' typed object
      oo = log(oo,'t','x1','x2','y','z1','z2','q','d','xa','xb',...
                  'b','g','phi','df'); 
   else                                % add log data to log object
      b = X.boost.control;             % boost output
      g = X.triac.control;             % triac gate
      x = X.process.x;  
      y = X.process.y;
      r = x(1)/100;                    % boost signal, voltage reference
      z = X.observer.z;
      q = X.observer.q;
      d = X.observer.d;
      phi = X.observer.phi;
      df = (X.process.phi-phi);        % phase error in mdeg
      if (df<-180) df = df+360; end;   % map to interval [-180°,180°)
      if (df>+180) df = df-360; end;   % map to interval [-180°,180°)
      t = X.timing.t;
      oo = X.log.oo;                   % access to log object
      oo = log(oo,t,x(1),x(2),y,z(1),z(2),q,d,r,r,b,g,phi,df); 
   end
   X.log.oo = oo;                      % save log object
end
function Control(o)                    % Triac & Boost Control         
   function S = Action(S)              % Perform Triac/Booster Action  
      if (S.enable && S.state)
         index = S.index;
         signal = S.signal;
         S.control = signal(index); % change control signal

         n = length(signal);        % for modulo operation
         index = 1 + rem(index,n);  % increment index "modulo2"
         S.index = index;           % update index
      end
   end

      % let's go ...

   global X                            % our global variables
   X.boost = Action(X.boost);          % booster control action
   X.triac = Action(X.triac);          % triac control action
end
function Interval(o)                   % Calculate Next Sample Interval
   function [S,T] = Determine(S,Tk,phi,om)                          
      T = inf;                      % a huge number by default
      if (S.enable)                 % if booster/triac is enabled
         nang = X.noise.angle;
         dphi = om * Tk;            % phase angle equivalent to Tk 
         delta = S.angle(S.index) - phi;
         if (delta < -nang)         % only if delta sufficient negative!
            delta = delta + 360;    % delta = rem(delta+360,360);
            assert(delta>=0 && delta < 360);
         end
         if (delta <= dphi)
            T = max(0,delta / om);
         end
      end
   end

      % enable booster and triac

   global X                            % our global variables
   if (X.timing.t >= X.timing.Tini)
      X.timing.ready = 1;              % now ready for booster & triac
   end

      % determine booster & triac schedule

   Tk = X.timing.T;                    % nominal sampling time      
   if (X.timing.ready)
      om = 360*X.observer.f;           % circular frequency
      phi = rem(X.observer.phi,360);   % map phi to interval [0°,360°)

      [X.boost,Tb] = Determine(X.boost,Tk,phi,om);
      [X.triac,Tt] = Determine(X.triac,Tk,phi,om);

         % schedule booster action if proper

      Tk = min([Tk,Tb,Tt]);
      X.timing.Tk = Tk;                % store Tk in global variables
      if (Tb == Tk || Tt == Tk)
         'break';
      end
      X.boost.state = (Tb == Tk);
      X.triac.state = (Tt == Tk);
   end
   X.timing.Tk = Tk;                   % pass over planned sample interval
end
function Schedule(o)                   % Schedule a Timer Callback     
   global X                            % our global variables
   Tp = X.timing.Tk;                   % planned sampling time
   Tnow = X.timing.clock;              % current clock time since clear

      % make sure that Tk is not smaller than minimum timer requirement

   Tmin = X.timing.Tmin;               % unpack minimum time for timer

   Tr = Tp - Tnow;                     % remaining time until Tick interrupt
   if (Tr < Tmin)                      % Tr compatible with timer?
      delta = Tmin - Tr;               % need to increase by delta
      Tr = Tr + delta;                 % increase Tr -> Tmin
      Tk = Tp + delta                  % increase Tk -> Tp + (Tmin - Tr)
   else
      Tk = Tp;                         % otherwise actual Tk = planned Tp
   end
   X.timing.Tk = Tk;                   % global store

      % simulate a jitter for timing and update simulation time
      % note that only time t is influenced by jitter, not Tk

   sigt = X.timing.sigt;               % timing jittering sigma
   Tj = Tr * (1+abs(sigt*randn));      % jittered remaining time
   X.timing.t = X.timing.t + Tj;       % jittered time transition

   core(o,'TimerStart',Tr);            % start timer with remaining time
end

   % initializing of global variables

function o = Init(o)                   % Init Global Variables         
   global X                            % our global variable X
   Log([]);                            % initialize logging

   o = with(o,'controller');           % set 'controller' context for opts
   rng('default');                     % initialize random generator seed
   G = opt(o,'G');                     % observer gain
   U = 230;                            % RMS grid voltage

      % initialize noise parameters

   X.noise.sigv = opt(o,'sigv');       % sigma of process noise
   X.noise.sigw = opt(o,'sigw');       % sigma of measurement noise
   X.noise.angle = 45;                 % 45° noise angle

      % initialize process

   X.process.mode = opt(o,'simu');     % process simulation 
   X.process.x = [0 -U*sqrt(2)]';      % init system state
   X.process.y = 0;                    % init system output
   X.process.f = opt(o,'f');           % actual frequency (process model)
   X.process.phi = 0;                  % process phase

      % initialize observer

   X.observer.mode = opt(o,'mode');    % 0: Luenberger, 1: Kalman
   X.observer.h = 0.5;                 % threshold to enable correction
   X.observer.f = 50;                  % 50 Hz sine (observer model)
   X.observer.z = [0 0]';              % init observer model state (unknown)
   X.observer.q = 0;                   % init observer output
   X.observer.d = 0;                   % init observer output deviation
   X.observer.K = G*[100 -100]';       % observer gain
   X.observer.phi = 0;                 % init estimated phase
   X.observer.G = G;                   % Luenberger tuning gain

      % initialize Kalman stuff

   I = eye(2);                         % 2x2 identity matrix
   X.kalman.P = 300^2 * eye(2);        % error covariance matrix
   X.kalman.Q = opt(o,'q')^2 * I;      % Kalman Q-matrix
   X.kalman.R = opt(o,'r')^2;          % Kalman R-matrix

      % initialize Triac control

   X.triac.enable = opt(o,'triac');    % enable/disable triac
   X.triac.angle = [0 0 0 0];          % triac switch angle table
   X.triac.signal = [1 0 1 0];         % triac switch signal table
   X.triac.control = 0;                % triac control signal (gate)
   X.triac.index = 1;                  % init triac table index
   X.triac.state = 0;                  % state to call for triac action

      % initialize boost control

   X.boost.enable = opt(o,'boost');    % enable/disable booster
   X.boost.angle = [0 0 0 0];          % booster switch angle table
   X.boost.signal = [1 0 1 0];         % booster switch signal table
   X.boost.control = 0;                % booster control signal (b)
   X.boost.index = 1;                  % init booster table index
   X.boost.state = 0;                  % state to call for booster action

      % setup timing parameters

   X.timing.T = opt(o,'T');            % nominal sampling interval
   X.timing.N = opt(o,'N');            % number of periodes
   X.timing.t = 0;                     % init simulation time      
   X.timing.sigt = opt(o,'sigt');      % sigma of time jitter
   X.timing.Tini = opt(o,'Tini');      % init time befor boost & triac
   X.timing.ready = 0;                 % ready for boost & triac
   X.timing.Tk = 0;                    % actual sampling interval
   X.timing.Tmin = 0.0001;             % min time for timer (100µs)
   X.timing.clock = 0;                 % clock time

   X.engine.clear = @Clear;            % clear clock function
   X.engine.start = @Start;            % start measurement function
   X.engine.process = @Process;        % process transition
   X.engine.observer = @Observer;      % observer transition
   X.engine.log = @Log;                % data logging
   X.engine.control = @Control;        % control booster & triac
   X.engine.interval = @Interval;      % calculate new sampling interval
   X.engine.schedule = @Schedule;      % schedule next timer callback
   X.engine.stop = false;              % stop request cleared initially
   X.engine.enable = true;             % tick-tock engine ready to run

      % setup boost and triac angles

   Triac(60,64);                       % setup Triac angle 60°, 4° duration 
   Boost(45,135);                      % setup boost signal: 45° to 135°
end

%==========================================================================
% Triac & Booster
%==========================================================================

function o = TriacBoost(o)             % Triac And Booster             
   global X                            % our global variables
   o = Init(o);                        % Initialize global variables (X)
   engine(o);                          % run the tick/tock engine

      % finally plot logged data
      
   Plot(arg(o,{X,'Triac & Boost Control',X.observer.G})); 
end

%==========================================================================
% Rectangle Wave
%==========================================================================

function o = Rectangle(o)              % Rectangle Wave                
   function Interval(o)
      X.timing.Tk = 0.01;              % half wave
   end
   function Process(o)
   end
   function Observer(o)
   end
   function Control(o)
      level = ~level;
      X.boost.control = level;
   end

   persistent level
   global X                            % our global variables
   o = Init(o);                        % Initialize global variables (X)
   X.engine.interval = @Interval;      % overwrite Interval function ptr. 
   X.engine.process  = @Process;       % overwrite Interval function ptr. 
   X.engine.observer = @Observer;      % overwrite Interval function ptr. 
   X.engine.control  = @Control;       % overwrite Interval function ptr. 
   
   Triac(0,0);
   Boost(0,0);
   
   level = 0;
   engine(o);                          % run the tick/tock engine

      % finally plot logged data
      
   Plot(arg(o,{X,'Rectangle Wave & Measurement',X.observer.G})); 
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Plot(o,oo)                % Plot Log Data                 
   X = arg(o,1);
   title = arg(o,2);
   G = arg(o,3);
   
   if (opt(o,'controller.mode') == 0)
      title = [title,' (Luenberger)'];
   else
      title = [title,' (Kalman)'];
   end
   
   oo = X.log.oo;
   oo = set(oo,'title',title);
   plot(var(oo,'G',G));                % plot graphics
end
function o = Special(o)                % Boost & Triac - Special Call  
   charm(o,'controller.mode',0);            % Luenberger observer
   charm(o,'controller.boost',1);           % boost enabled
   charm(o,'controller.triac',1);           % triac enabled
   charm(o,'controller.T',0.002);           % sampling time
   charm(o,'controller.Tini',0.02);         % initial time before boost & triac
   charm(o,'controller.N',3);               % number of periodes
   charm(o,'controller.f',50);              % mains grid frequency
   charm(o,'controller.U',230);             % mains grid RMS voltage
   charm(o,'controller.G',1);               % observer gain
   charm(o,'controller.sigw',0.0);          % no stochastic process noise (0.0)
   charm(o,'controller.sigv',0.0);          % stochastic measurement noise (0.1)
   charm(o,'controller.sigt',0.0);          % stochastic time jitter (0.3)
   charm(o,'controller.sigv',0.0);          % stochastic measurement noise (0.1)
   charm(o,'controller.sigt',0.0);          % stochastic time jitter (0.3)
  
   charm(o,'controller.q',5);               % Kalman q-parameter
   charm(o,'controller.r',0.1);             % Kalman r-parameter

   mode = arg(o,1);
   switch mode
      case 'L-Nominal'
         % nothing to do
      case 'K-Nominal'
         charm(o,'controller.mode',1);      % Kalman observer
         charm(o,'controller.N',2);         % number of periodes
      case 'L-NoInit'
         charm(o,'controller.Tini',0);      % initial time before boost & triac
         charm(o,'controller.N',2);         % number of periodes
      case 'K-NoInit'
         charm(o,'controller.mode',1);      % Kalman observer
         charm(o,'controller.Tini',0);      % initial time before boost & triac
      case 'L-HighRate'
         charm(o,'controller.T',0.0005);    % 0.5 ms sampling rate
      case 'K_HighRate'
         charm(o,'controller.mode',1);      % Kalman observer
         charm(o,'controller.T',0.0005);    % 0.5 ms sampling rate
      case 'L-Noisy'
         charm(o,'controller.N',10);        % number of periodes
         charm(o,'controller.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'controller.sigt',0.3);    % stochastic time jitter (0.3)
      case 'K-Noisy'
         charm(o,'controller.mode',1);      % Kalman observer
         charm(o,'controller.N',10);        % number of periodes
         charm(o,'controller.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'controller.sigt',0.3);    % stochastic time jitter (0.3)
      case 'L-NoisyHigh'
         charm(o,'controller.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'controller.sigt',0.3);    % stochastic time jitter (0.3)
         charm(o,'controller.T',0.0005);    % 0.5 ms sampling rate
         charm(o,'controller.Tini',0);      % initial time before boost & triac
      case 'K-NoisyHigh'
         charm(o,'controller.mode',1);      % Kalman observer
         charm(o,'controller.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'controller.sigt',0.3);    % stochastic time jitter (0.3)
         charm(o,'controller.T',0.0005);    % 0.5 ms sampling rate
         charm(o,'controller.Tini',0);      % initial time before boost & triac
   end
   o = pull(o);                        % refresh options
   o = TriacBoost(o);
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'controller.engine'},0);      % Loop engine by default observer
   setting(o,{'controller.timer'},0);       % Luenberger observer
   setting(o,{'controller.mode'},0);        % Luenberger observer
   setting(o,{'controller.simu'},0);        % Process simulation
   setting(o,{'controller.boost'},1);       % boost enabled
   setting(o,{'controller.triac'},1);       % triac enabled
   setting(o,{'controller.T'},0.002);       % sampling time
   setting(o,{'controller.Tini'},0.02);     % initial time before boost & triac
   setting(o,{'controller.N'},2);           % number of periodes
   setting(o,{'controller.f'},50);          % mains grid frequency
   setting(o,{'controller.U'},230);         % mains grid RMS voltage
   setting(o,{'controller.G'},1);           % observer gain
   setting(o,{'controller.sigw'},0.0);      % no stochastic process noise (0.0)
   setting(o,{'controller.sigv'},0.0);      % stochastic measurement noise (0.1)
   setting(o,{'controller.sigt'},0.0);      % stochastic time jitter (0.3)
   setting(o,{'controller.q'},5);           % Kalman q-parameter
   setting(o,{'controller.r'},0.1);         % Kalman r-parameter
   
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Engine Mode','','controller.engine'); 
         choice(ooo,{{'0: Loop Engine',0},{'1: Event Engine',1}},{});
   ooo = mitem(oo,'Timer Mode','','controller.timer'); 
         choice(ooo,{{'0: Simulation',0},{'1: Timer',1}},{});
   ooo = mitem(oo,'Observer Mode','','controller.mode'); 
         choice(ooo,{{'0: Luenberger',0},{'1: Kalman',1}},{});
   ooo = mitem(oo,'Process Mode','','controller.simu'); 
         choice(ooo,{{'0: Simulation',0},{'1: Sine Wave',1}},{});
   ooo = mitem(oo,'Booster','','controller.boost'); 
         choice(ooo,{{'off',0},{'on',1}},{});
   ooo = mitem(oo,'Triac','','controller.triac'); 
         choice(ooo,{{'off',0},{'on',1}},{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'T: Sampling Time [s]','','controller.T'); 
         charm(ooo,{});
   ooo = mitem(oo,'N: Number of Periodes','','controller.N'); 
         charm(ooo,{});
   ooo = mitem(oo,'Tini: Initializing Time [s]','','controller.Tini'); 
         charm(ooo,{});
   ooo = mitem(oo,'f: Frequency [Hz]','','controller.f'); 
         charm(ooo,{});
   ooo = mitem(oo,'U: RMS Voltage [V]','','controller.U'); 
         charm(ooo,{});
   ooo = mitem(oo,'G: Observer Gain [1]','','controller.G'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'sigv: Measurement Noise [V]','','controller.sigv'); 
         charm(ooo,{});
   ooo = mitem(oo,'sigw: Process Noise [V]','','controller.sigw'); 
         charm(ooo,{});
   ooo = mitem(oo,'sigt: Time Jitter [1]','','controller.sigt'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'r: Measurement Noise Parameter [V]','','controller.r'); 
         charm(ooo,{});
   ooo = mitem(oo,'q: Process Noise Parameter [V]','','controller.q'); 
         charm(ooo,{});
end


