function [out1,out2] = twin(arg1,arg2,arg3)
%
% ORFI      Ordinary PT1 Filter on time variant basis. The function ope-
%           rates on a structure 'F' containing all necessary parameters
%
%           a) One input argument: setup filter
%
%              F = orfi(F);           % customized setup of ORFI filter
%              F = orfi(n);           % predefined setup of filter
%
%           b) Two input arguments: reset filter
%
%              F = orfi(F,[]);        % reset ORFI filter
%
%           c) Three input arguments: filter operation
%
%              [y,F] = orfi(F,u,t);   % normal filter operation
%
%           Meaning of arguments:
%
%              F: parameter structure including filter state variables
%              u: filter input
%              y: filter output
%              t: current time stamp
%
%           In addition there are some predefined ways of setting up the
%           ORFI filter:
%
%              F = orfi(0);  % order 1 filter: time constants T1 = 3;
%              F = orfi(1);  % No filter
%
%           ORFI filter operates on a structure F whith the following
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
%           a)  setup ordinary filter (order 1)
%
%               F = setup(0);         % default setup of ordinary filter
%
%               F.type = 1;  F.T = 0.5;
%               F = setup(F)          % customized setup, time const 0.5
%               F = setup([0 0.5])    % short hand setup, time const 0.5
%
   
% a) One input argument: setup filter
%
%   (i) F = orfi(F)           % F: structure
%  (ii) F = orfi(n)           % n: integer (type)
% (iii) F = orfi([n Tf])      % n: integer, T: filter time const
%  (iv) F = orfi([n Tf Kp])   % n: integer, T: time const, Kp: Kalman decay
%
   if (nargin == 1) % filter setup
       if (strcmp(class(arg1),'struct'))
          if (isnan(eval('arg1.type','NaN')))
              error('Filter type must be provided for customized setup!');
          end
          out1 = setup(arg1);          % customized setup of ORFI filter
          return
       else
          F.kind = 'orfi';             % ORFI filter
          F.type = arg1(1);            % filter type
          eval('F.T = arg1(2);','');   % filter time constant
          eval('F.Kp = arg1(3);','');  % Kalman decay
          out1 = setup(F);             % predefined or shorthand setup
          return
       end
   end
  
% b) Two input arguments: reset filter
%
%    F = orfi(F,[])   % reset filter
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
%    [y,F] = orfi(F,u,t);   % normal filter operation
%
% This will reset the state 'told' to a very long past time, and initialize the filter
% sates 'x1' and 'x2' to the well defined values zero!
   
   if (nargin == 3) % reset filter
      F = arg1;
      switch F.type
          case 0
             [out1,out2] = operate0(arg1,arg2,arg3);
          case 1
             [out1,out2] = operate1(arg1,arg2,arg3);  % no filter
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
% SETUP   Customized setup of ORFI filter
%
   F.T = eval('F.T','3');      % general filter time constant default
   F.Kp = eval('F.Kp','0.3');  % Kalman decay default (currently ignored)
   
   F.u = 0;   F.y = 0;
   
   switch F.type
      case 0   % F = orfi(0);  % ordinary order 1 filter
         epsilon = 0.01;       % 1% deviation
      case 1   % F = orfi(1);  % No filter
         F.kind = 'nofi';
      otherwise
         error(sprintf('bad mode: %g',mode));
   end

   F = reset(F);        % reset ORFI filter
   return
   
%==========================================================================
% ORFI filter reset
%
function F = reset(F)
%
% RESET   Reset ORFI filter
%
   F.x = 0;                   % initialize filter states
   F.told = -1e10;            % constant for very ancient time stamp
   F.p = 0;                   % initialize Kalman state
   return
   
%   
%==========================================================================
% ORFI filter operation, type = 0
%
function [y,F] = operate0(F,u,t)
%
% OPERATE0  Ordinary PT1 filter operation, type = 0
%
   F.u = u;
   
   F.p = t-F.told;
   A = exp(-F.p/F.T);
             
   F.x = A*F.x + (1-A)*F.u;
   F.y = F.x;
   F.told = t;

   y = F.y;
   return

   
% ORFI filter operation, type = 1  (no filter)
%
function [y,F] = operate1(F,u,t)
%
% OPERATE1  Ordinary PT1 filter operation, type = 0
%
   F.u = u;
   
   F.p = 1e10;
   
   F.y = F.u;
   y = F.y;
   return
  
%eof   
   