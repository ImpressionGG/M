function [AA,BB,CC,DD] = statemodel(obj,p,touch,Ts)
%
% STATEMODEL    Return continuous or discrete model system matrices
%               from parameter set
%
%                  p = statemodel(obj);          % get default parameters
%
%               % To get the open model (thermodes not touching)
%
%                  [A,B,C,D] = statemodel(obj,p,0)     % continuous state model
%                  [A,B,C,D] = statemodel(obj,p,0,Ts)  % discrete state model
%
%               % To get the open model (thermodes not touching)
%
%                  [A,B,C,D] = statemodel(obj,p,1)     % continuous state model
%                  [A,B,C,D] = statemodel(obj,p,1,Ts)  % discrete state model
%
%               The parameter vector p consists of the following
%               parameters:
%
%                  p(1) = RH
%                  p(2) = RC
%                  p(3) = RS
%                  p(4) = RR
%                  p(5) = CT
%                  p(6) = CL
%

%
% setup initial state and ambient state
%
   Ta = [20 20]';           % ambient temperature
   T0 = [150 20]';          % initial temperatures
   x0 = T0 - Ta;

   parameter.x0 = x0;
   
   if (nargin == 0)         % standard parameters
      RH = 9.4;     % [K/W]  (5,   0.52 )
      RC = 3.3;     % [K/W]  (0.1, 0.026)
      RS = 41.4;    % [K/W]  (0.043)
      RR = 1000;    % [K/W]  (20, 1.0)
      CT = 0.069;   % [Ws/K] (60, 7.5)
      CL = 6*0.11;  % [Ws/K] (18.75)
      
      table = [ 
             RH * [1 0.001 1000]    % p(1)
             RC * [1 0.001 1000]    % p(2)
             RS * [1 0.001 1000]    % p(3)
             RR * [1 0.001 1000]    % p(4)
             CT * [1 0.001 1000]    % p(5)
             CL * [1 0.001 1000]    % p(6)
           ];
        
      parameter.p = table(:,1);
      parameter.pmin = table(:,2);
      parameter.pmax = table(:,3);
      
      AA = parameter;
      return
   end

%
% otherwise process state model from parameter vector and perform
% parameter variation
%
   kRC = get(obj,'model.variation.kRC');
   kRR = get(obj,'model.variation.kRR');
   kCT = get(obj,'model.variation.kCT');
   
   par = p;
   
   RH = par(1);
   RC = par(2) / kRC;
   RS = par(3);
   RR = par(4) / kRR;
   CT = par(5) * kCT;  
   CL = par(6);
   
      % respect now the fact whether thermode is touching (closed model)
      % or not (open model), In the non-touching case we set both RC and
      % RS to a huge value
      
   if (~touch)
      RC = 1e12;   % very huge
      RS = 1e12;   % very huge
   end

      % continue with the calculation of the system matrices
      
   RCH = 1 / (1/RC + 1/RH);
   RCSR = 1 / (1/RC + 1/RS + 1/RR);

   AA = [-1/CT/RCH    1/CT/RC;  1/CL/RC     -1/CL/RCSR];
   BB = [ 1/CT  0     0;   0  1/CL/RS -1/CL/RS];
   CC = [1 0; 0 1];
   DD = [0 0 1; 0 0 1];
   
      % convert to discrete model if Ts is specified
      % With the use of the control system toolbox we would have to do:
      % 
      %    sys = ss(AA,BB,CC,DD);
      %    sys = c2d(sys,Ts);
      %    AA = sys.a;
      %    BB = sys.b;
      %    CC = sys.c;
      %    DD = sys.d;
      %
      % Since we want to avoid control toolbox function usage
      % we do the conversion explicitely by calculating
      %
      %    Phi = exp(AA*Ts), 
      %    H = integral(0:Ts){exp(A*tau)*B*dtau}
      %
      
   if (nargin >= 3)
     Phi = expm(AA*Ts);
     
     N = 100;  dtau = Ts/N;   % choose 100 integration steps
     H = BB*0;
     for(i=1:N)
         tau = i*dtau;
         H = H + expm(AA*tau)*BB*dtau;
     end
     AA = Phi;  BB = H;  CC = CC;  DD = DD;
   end
   
   return

