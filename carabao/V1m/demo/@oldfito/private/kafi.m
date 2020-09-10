function [out1,out2] = kafi(arg1,arg2,arg3)
%
% KAFI      Kalman filter. The function operates on a structure 'F'
%           containing all necessary parameters
%
%           a) One input argument: setup filter
%
%              F = kafi(F);         % customized setup of Kalman filter
%              F = kafi(n);         % predefined setup of Kalman filter
%
%           b) Two input arguments: reset filter
%
%              F = kafi(F,[]);      % reset kalman filter
%
%           c) Three input arguments: filter operation
%
%              [y,F] = kafi(F,u,t); % normal filter operation
%
%           Meaning of arguments:
%
%              F: parameter structure including filter state variables
%              u: filter input
%              y: filter output
%              t: current time stamp
%
%           In addition there are some predefined ways of setting up the
%           kalman filter:
%
%              F = kafi(1);   % PT1 model, time constant T = 3;
%              F = kafi(2);   % double integrator model
%              F = kafi(3);   % scalar Kalman filter (SKAFI)
%
%           The Kalman filter operates on a structure F whith the following
%           elements:
%
%              F.kind     % filter kind
%              F.type     % filter type
%              F.T        % system model time constant T
%              F.Ts       % sampling time
%              F.Tf       % filter time constant
%              F.Kp       % factor for initial state covariance
%              F.m        % initial state
%              F.P0       % covariance matrix of initial state
%              F.Q        % covariance matrix of state noise
%              F.R        % covariance matrix of output noise
%              F.A        % system matrix A
%              F.C        % system matrix C
%              F.x        % filter state vectror
%              F.u        % filter input u
%              F.y        % filter output y
%              F.told     % last time stamp
%              F.P        % actual covariance of state error
%              F.K        % Kalman state gain
%              F.H        % Kalman output gain
%
%
%           Setup Examples:
%
%           a)  setup Kalman filter on base of PT1-model
%
%               F = kafi(1);         % default setup for double integrator
%
%               F.type = 2;  F.T = 3;  F.Kp = 0.1;
%               F = kafi(F)          % customized KAFI setup
%
%               F = kafi([1 Tf Kp]); % short hand KAFI setup
%               F = kafi([2 3 0.1])  % short hand KAFI setup
%
   
% a) One input argument: setup filter
%
%   (i) F = kafi(F)           % F: structure
%  (ii) F = kafi(n)           % n: integer
% (iii) F = kafi([n Tf])      % n: integer, T: filter time const
%  (iv) F = kafi([n Tf Kp])   % n: integer, T: time const, Kp: Kalman decay
%
   if (nargin == 1) % filter setup
       if (strcmp(class(arg1),'struct'))
          if (isnan(eval('arg1.type','NaN')))
              error('Filter type must be provided for customized setup!');
          end
          out1 = setup(arg1);          % customized setup of Kalman filter
          return
       else
          F.kind = 'kafi';             % Kalman filter
          F.type = arg1(1);            % filter type
          eval('F.Tf = arg1(2);','');  % filter time constant
          eval('F.Kp = arg1(3);','');  % initial state weighting
          eval('F.N = arg1(4);','');   % number of simultaneous tests
          out1 = setup(F);             % predefined or shorthand setup
          return
       end
   end
  
% b) Two input arguments: reset filter
%
%    F = kafi(F,[])   % reset filter
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% vector state 'x' to the expected value 'm'
%
   if (nargin == 2) % reset filter
      if (~strcmp(class(arg1),'struct') | ~isempty(arg2))
          error('filter reset syntax: expected struct for arg1 and empty matrix for arg2!')
      end
      out1 = reset(arg1);
      return
   end

% c) Three input arguments: normal filter operation
%
%    [y,F] = kafi(F,u,t);   % normal filter operation
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% sates 'x1' and 'x2' to the well defined values zero!
   
   if (nargin == 3) % reset filter
      F = arg1;
      if (F.Kp < 0)  % this is for easier simulation
         [out1,out2] = operate0(arg1,arg2,arg3);
      else
         switch F.type
         case 0
            [out1,out2] = operate0(arg1,arg2,arg3);
         case 1
            [out1,out2] = operate1(arg1,arg2,arg3);
         case 2
            [out1,out2] = operate1(arg1,arg2,arg3);
         case 3
            [out1,out2] = operate3(arg1,arg2,arg3);
         case 4
            [out1,out2] = operate4(arg1,arg2,arg3);
         otherwise
            error(sprintf('filter operation for type = %g not implemented!',F.type));
         end
      end
      return 
   end
%       
% Every other number of input args will lead to an error!
%
   error('1,2 oder 3 input args expected!');
   return
%  
%==========================================================================
% auxillary functions
%
function F = setup(F)
% 
% SETUP   Customized setup of Kalman filter
%

   F.T = eval('F.T','2');          % general filter time constant default
   F.Tcrit = eval('F.T','2');      % critical time for reset
   F.N = eval('F.N','1');      % number of simultaneous tests
   F.Kp = eval('F.Kp','0.1');
   
   switch F.type
      case 1   % F = kafi(1);            % double integrator based Kalman filter
         F.kind = 'dkafi';
         F.Ts = eval('F.Ts','0.2');      % default filter time
         F.Tf = eval('F.Tf','200');      % default filter time
         F.P0 = diag([25000/900, 100]);  % covariance of initial state
         F.P0 = F.P0 * 1e6^(F.Kp-0.3);   % adopt covariance of initial state
         F.R = 1;                        % R = cov(u) = 1µ^2
         F.Q = diag(F.R*(1-exp(-F.Ts/(F.Tf*200/3)))*[1 1]);         
         F.m = [0;0];                    % expecation of initial state
         F.At = '[1 0; F.dt 1]';
         F.Bt = '[0;0]';
         F.Ct = '[0 1]';
         F.Ts = 0.2;
         
      case 2   % F = kafi(2);            % standard Kalman filter
         F.kind = 'pkafi';
         F.Tsys = eval('F.Tsys','30');   % system time constant 
         F.Ts = eval('F.Ts','0.2');      % default filter time
         F.Tf = eval('F.Tf','200');      % default filter time
         F.P0 = diag([900, 900]);        % covariance of initial state
         F.P0 = F.P0 * 1e6^(F.Kp-0.3);   % adopt covariance of initial state
         F.R = 1;                        % covariance of output noise
         %F.Q = 0*F.P0;                   % covariance matrix of state vector
         F.Q = diag(F.R*(1-exp(-F.Ts/(F.Tf*200/3)))*[1 1]);         
         F.m = [0;0];                    % expecation of initial state
         F.At = '[1 0; (1-exp(-F.dt/F.Tsys)) exp(-F.dt/F.Tsys)]';
         F.Bt = '[0;0]';
         F.Ct = '[0 1]';
         F.Ts = 0.2;

      case 3   % F = kafi(3);            % SKAFI (scalar Kalman filter)
         F.kind = 'skafi';
         
         F.Ts = eval('F.Ts','0.2');      % default filter time
         F.Tf = eval('F.Tf','200');      % default filter time

         F.tau = F.Ts / F.Tf;            % normalized filter time constant
         F.rho = F.Kp * 50;
         F.m = 0;                        % expecation of initial state

         F.P0 = F.rho * F.rho;           % covariance initial state
         F.Q = 4*sinh(F.tau/2)^2;        % covariance state disturbance 
         
         F.At = '1';  F.Bt = '0';  F.Ct = '1';

      case 4   % F = kafi(4);            % TKAFI (Twin Kalman filter)
         F.kind = 'tkafi';
         
         F.Ts = eval('F.Ts','0.2');      % default filter time
         F.Tf = eval('F.Tf','200');      % default filter time

         F.tau = F.Ts / F.Tf;            % normalized filter time constant
         F.rho = F.Kp * 50;
         F.m = [0;0];                    % expecation of initial state

         F.P0 = F.rho * F.rho;           % covariance initial state
         F.Q = 4*sinh(F.tau/2)^2;        % covariance state disturbance 
         
         F.At = '[1 0;0 1]';  F.Bt = '[0;0]';  F.Ct = '[1 0]';

      otherwise
         error(sprintf('bad mode: %g',mode));
   end

   F.told = -F.Ts;
   F.m = F.m * ones(1,F.N);  % simultaneous simulations
   F = reset(F);             % reset Kalman filter
   
      % after reset we can rely on valid data
      % for F.x, F.P and F.dt
      
   F.A = eval(F.At,'F.A');   % calculate A(F.dt)
   F.B = eval(F.Bt,'F.B');   % calculate B(F.dt)
   F.C = eval(F.Ct,'F.C');   % calculate C(F.dt)

      % now all system matrices have to be setup
   
   F.c = 0*F.B'*F.m;
   F.u = 0*F.C*F.m;
   F.y = F.u;
   
   return
   
%==========================================================================
% Kalman filter reset
%
function F = reset(F)
%
% RESET   Reset Kalman filter
%
   F.x = F.m;                     % initialize filter states
   F.P = F.P0;                    % initialize Kalman state
   F.dt = F.Ts;                   % time stamp difference
   return
   
%   
%==========================================================================
% Kalman filter operation
    
function [y,F] = operate0(F,u,t)
%
% OPERATE0  Ordinary PT1 filter operation, type = 0
%
   F.u = u;
   if (F.told < 0) F.told = -1e10; end      % hack
   F.p = t-F.told;
   A1 = exp(-F.p/F.Tf);
             
   F.x(1,:) = A1*F.x(1,:) + (1-A1)*F.u;
   F.y = F.x(1,:);
   F.told = t;

   y = F.y;
   return

   
function [y,F] = operate1(F,u,t)
%
% OPERATE1  Kalman filter operation, type = 1
%
%              y = operate1(F,u,t)         % u: system output
%              y = operate1(F,{u,c},t)     % c: system (control) input

   if (iscell(u))
      c = u{2};  u = u{1};       % system output & system control input
   else
      c = zeros(1,F.N);          % no system control input
   end

   P = F.P;  x = F.x;  R = F.R;  Q = F.Q;  Ts = F.Ts;  Tcrit = F.Tcrit;
   
   F.dt = t-F.told;  F.told = t;
   
   if (F.dt > Tcrit)
       F = reset(F);             % if long time difference reset Kalman filter
       P = F.P;  x = F.x;        % actualize P & x after reset
   end
   
   A = eval(F.At,'F.A');     % system dynamics matrix   A(F.dt)
   B = eval(F.Bt,'F.B');     % system input matrix      B(F.dt)
   C = eval(F.Ct,'F.C');     % system output matrix     C(F.dt)
   
      % Calculate the Kalman gain
       
   N = inv(R + C*P*C');                        % auxillary expression
   K = A*P*C' * N;                             % Kalman state gain
   H = N * C*P*C';                             % Kalman output gain

      % next step is to calculate the Kalman filter output
       
   y = C*x + H*(u - C*x);                     % Kalman filter output
       
      % next step is the transition of the observer state
       
   x = A*x + B*c + K*(u - C*x);   

      % now we have to calculate the transition of the error covariance 
          
   P = A*P*A' + Q - K*C*P*A';   

   F.A = A;  F.B = B;  F.C = C;  F.P = P;  F.K = K;  F.H = H;
   F.x = x;  F.y = y;  F.u = u;  F.c = c;
   F.p = norm(P);
   return

   
function [y,F] = operate3(F,u,t)
%
% OPERATE3  Scalar Kalman filter operation, type = 2  (SKAFI)
%
%              y = operate3(F,u,t)         % u: system output
%              y = operate3(F,{u,c},t)     % c: system (control) input

   if (iscell(u))
      c = u{2};  u = u{1};       % system output & system control input
   else
      c = zeros(1,F.N);          % no system control input
   end

   F.dt = t-F.told;  F.told = t;
   
   if (F.dt > F.Tcrit)
       F = reset(F);             % if long time difference reset Kalman filter
       P = F.P;  x = F.x;        % actualize P & x after reset
   end
   
   F.a = inv(1 + F.P);           % 'eigen value' of system dynamics
   F.y = F.a*F.y + (1-F.a)*u;    % new filter output
   F.P = F.a*F.P + F.Q;

   F.p = F.P;                    % for monitoring
   y = F.y;
   return

   
function [y,F] = operate4(F,u,t)
%
% OPERATE4  Twin Kalman filter operation, type = 4  (TKAFI)
%
%              y = operate4(F,u,t)         % u: system output
%              y = operate4(F,{u,c},t)     % c: system (control) input

   if (iscell(u))
      c = u{2};  u = u{1};       % system output & system control input
   else
      c = zeros(1,F.N);          % no system control input
   end

   F.dt = t-F.told;  F.told = t;
   
   if (F.dt > F.Tcrit)
       F = reset(F);             % if long time difference reset Kalman filter
       P = F.P;  x = F.x;        % actualize P & x after reset
   end
   
   F.a = inv(1 + F.P);                     % 'eigen value' of system dynamics
   
   F.x(1,:) = F.a*F.x(1,:) + (1-F.a)*u;    % 1st filter output
   v = u - F.x(1,:);                       % Schleppfehler
   F.x(2,:) = F.a*F.x(2,:) + (1-F.a)*v;    % 2nd filter output
   F.y = F.x(1,:) + F.x(2,:);
   
   F.P = F.a*F.P + F.Q;

   F.p = F.P;                    % for monitoring
   y = F.y;
   return
  
%eof   
   