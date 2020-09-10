function [out1,out2] = refi(arg1,arg2,arg3)
%
% REFI      Regression filter. The function operates on a structure 'F'
%           containing all necessary parameters
%
%           a) One input argument: setup filter
%
%              F = refi(F);           % customized setup of refi filter
%              F = refi(n);           % predefined setup of filter
%
%           b) Two input arguments: reset filter
%
%              F = refi(F,[]);        % reset refi filter
%
%           c) Three input arguments: filter operation
%
%              [y,F] = refi(F,u,t);   % normal filter operation
%
%           Meaning of arguments:
%
%              F: parameter structure including filter state variables
%              u: filter input
%              y: filter output
%              t: current time stamp
%
%           In addition there are some predefined ways of setting up the
%           refi filter:
%
%              F = refi(0);  % order 1 filter: time constants T1 = 3;
%              F = refi(1);  % standard refi filter: time constants T1 = T2 = 3;
%
%           refi filter operates on a structure F whith the following
%           elements:
%
%              F.kind     % filter kind
%              F.type     % filter type
%              F.T1       % filter time constant T1
%              F.T2       % filter time constant T2
%              F.x1       % filter state variable x1
%              F.x2       % filter state variable x2
%              F.u        % filter input u
%              F.y        % filter output y
%              F.told     % last time stamp
%              F.Kp       % Kalman decay
%
%
%           Setup Examples:
%
%           a)  regression filter
%
%               F = setup(0);         % default setup of ordinary filter
%
%               F.type = 1;  F.T = 0.5;
%               F = setup(F)          % customized setup, time const 0.5
%               F = setup([0 0.5])    % short hand setup, time const 0.5
   
% a) One input argument: setup filter
%
%   (i) F = refi(F)           % F: structure
%  (ii) F = refi(n)           % n: integer (type)
% (iii) F = refi([n Tf])      % n: integer, T: filter time const
%  (iv) F = refi([n Tf Kp])   % n: integer, T: time const, Kp: Kalman decay
%
   if (nargin == 1) % filter setup
       if (strcmp(class(arg1),'struct'))
          if (isnan(eval('arg1.type','NaN')))
              error('Filter type must be provided for customized setup!');
          end
          out1 = setup(arg1);          % customized setup of refi filter
          return
       else
          F.kind = 'refi';             % refi filter
          F.type = arg1(1);            % filter type
          eval('F.Tf = arg1(2);','');   % filter time constant
          eval('F.Kp = arg1(3);','');  % Kalman decay
          eval('F.N = arg1(4);','');   % number of simultaneous tests
          out1 = setup(F);             % predefined or shorthand setup
          return
       end
   end
  
% b) Two input arguments: reset filter
%
%    F = refi(F,[])   % reset filter
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% states 'x1' and 'x2' to the well defined values zero!

   if (nargin == 2) % reset filter
      if (~strcmp(class(arg1),'struct') | ~isempty(arg2))
          error('filter reset syntax: expected struct for arg1 and empty matrix for arg2!')
      end
      out1 = reset(arg1);
      return
   end

% c) Three input arguments: normal filter operation
%
%    [y,F] = refi(F,u,t);   % normal filter operation
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% sates 'x1' and 'x2' to the well defined values zero!
   
   if (nargin == 3) % reset filter
      F = arg1;
      switch F.type
          case 0
             [out1,out2] = operate0(arg1,arg2,arg3);
          case 1
             if (F.Kp < 0)  % this is for easier simulation
                [out1,out2] = operate0(arg1,arg2,arg3);
             else
                [out1,out2] = operate1(arg1,arg2,arg3);
             end
          otherwise
              error(sprintf('filter operation for type = %g not implemented!',F.type));
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
% SETUP   Customized setup of refi filter
%
   F.N = eval('F.N','1');      % number of simultaneous tests
   F.M = eval('F.M','100');    % general filter time constant default
   F.Tcrit = eval('F.T','2');  % critical time for reset
   
   F.Ts = eval('F.Ts','0.2');  % nominal sampling time
   F.Tf = eval('F.Tf','3');    % general filter time constant default
   F.Kp = eval('F.Kp','0.3');  % Kalman decay default
   
   F.u = 0;   F.y = 0;
   F.q = exp(-F.Ts/F.Tf);
   
   switch F.type
      case 0   % F = refi(0);  % ordinary order 1 filter
      case 1   % F = refi(1);  % standard refi filter
         epsilon = 0.01;       % 1% deviation
         F.P0 = -F.Tf * log(epsilon);
      otherwise
         error(sprintf('bad mode: %g',mode));
   end

   F = reset(F);        % reset refi filter
   return
   
%==========================================================================
% refi filter reset
%
function F = reset(F)
%
% RESET   Reset refi filter
%
   F.T = [];
   F.U = [];
   F.Y = [];
   F.Q = [];
   
   F.x = zeros(1,F.N);        % initialize filter state
   F.told = -1e10;            % constant for very ancient time stamp
   F.p = 0;                   % initialize Kalman state
   return
   
%   
%==========================================================================
% refi filter operation, type = 0
%
function [y,F] = operate0(F,u,t)
%
% OPERATE0  Ordinary PT1 filter operation, type = 0
%
   F.u = u;
   F.p = t-F.told;
   A = exp(-F.p/F.Tf);
             
   F.x = A*F.x + (1-A)*F.u;
   F.y = F.x;
   F.told = t;

   y = F.y;
   return

   
function [y,F] = operate1(F,u,t)
%
% OPERATE1  refi filter operation, type = 1: This is a refi filter with
%           equal time constants T1 = T2 = T
%
   if (t-F.told > F.Tcrit)
       F = reset(F);             % if long time difference reset Kalman filter
   end

   F.u = u;
   F.U = [u; F.U];
   F.T = [t; F.T];
   F.Q = [F.q;F.q*F.Q];
   
   if (size(F.U,1) > F.M)
       F.U = F.U(1:F.M,:);  F.T = F.T(1:F.M);  F.Q = F.Q(1:F.M);
   end

      % we have to calculate; y = inv(F'*Q*F)*F'*Q * u
      % Now define:           FT := F' and QF := Q*F
      % Then we get:          y = inv(FT*QF)*QF'
      
   one = ones(size(F.T));
   FT = [one, F.T]';  
   QF = [one.*F.Q, F.T.*F.Q];
   
   if (abs(det(FT*QF)) < 1e-12)
       a = u;  b = 0*u;
   else
      H = inv(FT*QF)*QF';
      lam = H*F.U;                   % calculate parameter vector
      a = lam(1,:);  b = lam(2,:);   % estimated parameters
   end
   F.Y = one*a + F.T*b;
   
   n = size(F.U,1);
   if (n >= 10*F.Kp)
      F.y = a + b*t;
   elseif (n == 1)
      F.y = F.u;
   else
      F.y = mean(F.U);   % comb filter
   end
   
   F.told = t;
   y = F.y;
   return

   
function [y,F] = operate2(F,u,t)
%
% OPERATE2  refi filter operation, type = 2: This is an enhanced 
%           refi filter with equal time constants T1 = T2 = T
%           and one Kalman parameter Tp
%
   F.u = u;
   
   dt = t-F.told;                % time difference current/last time stamp
   if (dt > F.p*1.001) 
       F.p = dt;                 % immeditately increase F.p to value of dt
   else
       F.p = min(F.p,F.P0);      % truncate to maximum value before decay
       F.p = F.Kp*F.p+(1-F.Kp)*dt; % decrease Kalman parameter (approach dt)
   end
   
   A1 = exp(-F.p/F.T1);          % filter coefficient, Filter 1
   A2 = exp(-F.p/F.T2);          % filter coefficient, Filter 1
             
   F.x1 = A1*F.x1 + (1-A1)*F.u;
   e = F.u - F.x1;
   F.x2 = A2*F.x2 + (1-A2)*e;
   F.y = F.x1 + F.x2;
   F.told = t;

   y = F.y;
   return
  
%eof   
   