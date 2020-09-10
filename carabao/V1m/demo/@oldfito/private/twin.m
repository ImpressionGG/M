function [out1,out2] = twin(arg1,arg2,arg3)
%
% TWIN      Twin Filter. The function operates on a structure 'F'
%           containing all necessary parameters
%
%           a) One input argument: setup filter
%
%              F = twin(F);           % customized setup of twin filter
%              F = twin(n);           % predefined setup of filter
%
%           b) Two input arguments: reset filter
%
%              F = twin(F,[]);        % reset twin filter
%
%           c) Three input arguments: filter operation
%
%              [y,F] = twin(F,u,t);   % normal filter operation
%
%           Meaning of arguments:
%
%              F: parameter structure including filter state variables
%              u: filter input
%              y: filter output
%              t: current time stamp
%
%           In addition there are some predefined ways of setting up the
%           twin filter:
%
%              F = twin(0);  % order 1 filter: time constants T1 = 3;
%              F = twin(1);  % standard twin filter: time constants T1 = T2 = 3;
%              F = twin(2);  % enhanced twin filter with Kalman decay
%
%           Twin filter operates on a structure F whith the following
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
%              F.N        % number of simultaneous simulations
%
%
%           Setup Examples:
%
%           a)  setup ordinary filter (order 1)
%
%               F = setup(0);         % default setup of ordinary filter
%
%               F.type = 1;  F.T = 0.5;
%               F = setup(F)          % customized setup, time const 0.5
%               F = setup([0 0.5])    % short hand setup, time const 0.5
%
%           b)  setup TWIN filter
%
%               F = setup(1);   % default setup of TWIN filter
%
%               F.type = 1;  F.T = 3;
%               F = setup(F)          % customized TWIN setup, time const 3
%               F = setup([1 3])      % short hand TWIN setup, time const 3
%
%           c)  setup XTWIN filter
%
%               F = setup(2);         % default setup of XTWIN filter
%
%               F.type = 2;  F.T = 3;  F.Kp = 0.1;
%               F = twin(F)           % customized XTWIN setup
%               F = twin([2 3 0.1])   % short hand XTWIN setup
%
   
% a) One input argument: setup filter
%
%   (i) F = twin(F)           % F: structure
%  (ii) F = twin(n)           % n: integer (type)
% (iii) F = twin([n Tf])      % n: integer, T: filter time const
%  (iv) F = twin([n Tf Kp])   % n: integer, T: time const, Kp: Kalman decay
%
   if (nargin == 1) % filter setup
       if (strcmp(class(arg1),'struct'))
          if (isnan(eval('arg1.type','NaN')))
              error('Filter type must be provided for customized setup!');
          end
          out1 = setup(arg1);          % customized setup of twin filter
          return
       else
          F.kind = 'twin';             % twin filter
          F.type = arg1(1);            % filter type
          eval('F.T = arg1(2);','');   % filter time constant
          eval('F.Kp = arg1(3);','');  % Kalman decay
          eval('F.N = arg1(4);','');   % number of simultaneous tests
          out1 = setup(F);             % predefined or shorthand setup
          return
       end
   end
  
% b) Two input arguments: reset filter
%
%    F = twin(F,[])   % reset filter
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
%    [y,F] = twin(F,u,t);   % normal filter operation
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% sates 'x1' and 'x2' to the well defined values zero!
   
   if (nargin == 3) % reset filter
      F = arg1;
      switch F.type
          case 0
             [out1,out2] = operate0(arg1,arg2,arg3);
          case 1
             [out1,out2] = operate1(arg1,arg2,arg3);
          case 2
             if (F.Kp < 0)  % this is for easier simulation
                [out1,out2] = operate0(arg1,arg2,arg3);
             else
                [out1,out2] = operate2(arg1,arg2,arg3);
             end
          case 3
             [out1,out2] = operate1(arg1,arg2,arg3);
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
% SETUP   Customized setup of twin filter
%
   F.T = eval('F.T','3');      % general filter time constant default
   F.T1 = eval('F.T1','F.T');  % 1st filter time constant default
   F.T2 = eval('F.T2','F.T');  % 2nd filter time constant default
   F.Kp = eval('F.Kp','0.3');  % Kalman decay default
   F.N = eval('F.N','1');      % number of simultaneous tests
   
   F.T = sqrt(F.T1*F.T2);
   F.u = 0;   F.y = 0;
   
   switch F.type
      case 0   % F = twin(0);  % ordinary order 1 filter
      case 1   % F = twin(1);  % standard twin filter
      case 2   % F = twin(2);  % enhanced twin filter
         F.kind = 'xtwin';
         epsilon = 0.01;       % 1% deviation
         F.P0 = -F.T * log(epsilon);
      case 3   % F = twin(3);  % enhanced twin filter
         F.kind = 'atwin';
         F.T2 = F.T1 * (F.Kp+0.5)^4;  % 2nd filter time constant default
      otherwise
         error(sprintf('bad mode: %g',mode));
   end

   F = reset(F);        % reset twin filter
   return
   
%==========================================================================
% twin filter reset
%
function F = reset(F)
%
% RESET   Reset twin filter
%
   F.x1 = zeros(1,F.N);       % initialize filter states
   F.x2 = zeros(1,F.N);       % initialize filter states
   F.told = -1e10;            % constant for very ancient time stamp
   F.p = 0;                   % initialize Kalman state
   return
   
%   
%==========================================================================
% twin filter operation, type = 0
%
function [y,F] = operate0(F,u,t)
%
% OPERATE0  Ordinary PT1 filter operation, type = 0
%
   F.u = u;
   F.p = t-F.told;
   A1 = exp(-F.p/F.T1);
             
   F.x1 = A1*F.x1 + (1-A1)*F.u;
   F.y = F.x1;
   F.told = t;

   y = F.y;
   return

   
function [y,F] = operate1(F,u,t)
%
% OPERATE1  Twin filter operation, type = 1: This is a twin filter with
%           equal time constants T1 = T2 = T
%
   F.u = u;
   F.p = t-F.told;
   A1 = exp(-F.p/F.T1);   A2 = exp(-F.p/F.T2);
             
   F.x1 = A1*F.x1 + (1-A1)*F.u;
   e = F.u - F.x1;
   F.x2 = A2*F.x2 + (1-A2)*e;
   F.y = F.x1 + F.x2;
   F.told = t;

   y = F.y;
   return

   
function [y,F] = operate2(F,u,t)
%
% OPERATE2  Twin filter operation, type = 2: This is an enhanced 
%           twin filter with equal time constants T1 = T2 = T
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
   