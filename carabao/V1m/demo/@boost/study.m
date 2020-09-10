function oo = study(o,varargin)        % Study Menu                    
%
% STUDY   Manage Study menu
%
%           study(o,'Setup');          %  Setup STUDY menu
%
%           study(o,'Study1');         %  Study 1
%           study(o,'Study2');         %  Study 2
%           study(o,'Study3');         %  Study 3
%           study(o,'Study4');         %  Study 4
%
%           study(o,'Signal');         %  Setup STUDY specific Signal menu
%
%        See also: BOOST, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,...
                   @Study1,@Study2,@Study3,@Study4,@Study5,@Study6,...
                   @Study7,@Special,@RandomGenerator);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'Triac & Boost');
   oooo = mitem(ooo,'Simulation',{@invoke,mfilename,@Study7});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Luenberger');
   ooooo = mitem(oooo,'Nominal Parameters',{@Special,'L-Nominal'});
   ooooo = mitem(oooo,'No Initial Phase',{@Special,'L-NoInit'});
   ooooo = mitem(oooo,'High Sampling Rate',{@Special,'L-HighRate'});
   ooooo = mitem(oooo,'Noisy',{@Special,'L-Noisy'});
   ooooo = mitem(oooo,'Noisy / High Sampling',{@Special,'L-NoisyHigh'});
   oooo = mitem(ooo,'Kalman');
   ooooo = mitem(oooo,'Nominal Parameters',{@Special,'K-Nominal'});
   ooooo = mitem(oooo,'No Initial Phase',{@Special,'K-NoInit'});
   ooooo = mitem(oooo,'High Sampling Rate',{@Special,'K-HighRate'});
   ooooo = mitem(oooo,'Noisy',{@Special,'K-Noisy'});
   ooooo = mitem(oooo,'Noisy / High Sampling',{@Special,'K-NoisyHigh'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Oscillation');
   oooo = mitem(ooo,'Constant Sampling',{@invoke,mfilename,@Study1});
   oooo = mitem(ooo,'Varying Sampling',{@invoke,mfilename,@Study2});
   ooo = mitem(oo,'Luenberger Observer');
   oooo = mitem(ooo,'Good Modeling',{@invoke,mfilename,@Study3});
   oooo = mitem(ooo,'Bad Modeling',{@invoke,mfilename,@Study4});
   ooo = mitem(oo,'Kalman Observer');
   oooo = mitem(ooo,'Again Luenberger',{@invoke,mfilename,@Study5});
   oooo = mitem(ooo,'Kalman Filter',{@invoke,mfilename,@Study6});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Random Generator',{@RandomGenerator});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'system'));           % register 'system' configuration
   Config(type(o,'observer'));         % register 'observer' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Signal(o)                 % Study Specific Signal Menu    
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   switch active(o);                   % depending on active type
      case {'system'}
         oo = mitem(o,'Y',{@Config},'Y');
         mitem(o,'-');
         oo = mitem(o,'X1 and X2',{@Config},'X');
      case {'observer'}
         oo = mitem(o,'Overview',{@Config},'OV');
         oo = mitem(o,'Control',{@Config},'Control');
         mitem(o,'-');
         oo = mitem(o,'Booster',{@Config},'Booster');
         oo = mitem(o,'Triac',{@Config},'Triac');
         oo = mitem(o,'Phi',{@Config},'Phi');
         mitem(o,'-');
         oo = mitem(o,'Y/Q',{@Config},'YQ');
         oo = mitem(o,'Y and Q',{@Config},'YandQ');
         mitem(o,'-');
         oo = mitem(o,'Y',{@Config},'Y');
         oo = mitem(o,'Q',{@Config},'Q');
         mitem(o,'-');
         oo = mitem(o,'X1/Z1 and X2/Z2',{@Config},'States');
         oo = mitem(o,'X1 and X2',{@Config},'X');
         oo = mitem(o,'Z1 and Z2',{@Config},'Z');
         mitem(o,'-');
         oo = mitem(o,'D',{@Config},'D');
         mitem(o,'-');
         oo = mitem(o,'B',{@Config},'B');
   end
end
function o = Config(o)                 % Install a Configuration       
%
% CONFIG Setup a configuration
%
%           Config(type(o,'mytype'))   % register a type specific config
%           oo = Config(arg(o,{'XY'})  % change configuration
%
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = category(o,1,[],[],'V');        % setup category 1
   o = category(o,2,[],[],'V');        % setup category 2
   o = category(o,3,[],[],'°');        % setup category 3 (angle)
   o = category(o,4,[],[-4 4],'°');    % setup category 4 (angle deviation)
   
   switch type(o)                      % depending on active type
      case 'system'
         mode = o.either(arg(o,1),'Y');% get mode or provide default
         coly = 'b';  colq = 'm';
      case 'observer'
         mode = o.either(arg(o,1),'OV');% get mode or provide default
         coly = 'b';  colq = 'm';
         colb = 'mk';  colg = 'yr'; 
      otherwise
         mode = o.either(arg(o,1),'Y');% get mode or provide default
         coly = 'b';  colg = 'yr';  colq = 'm';
   end
      
   o = subplot(o,'Signal',mode);       % set signal mode   
   switch mode
      case {'OV'}                      % Overview
         o = subplot(o,'Layout',2);    % layout with 2 subplot column   
         o = config(o,'y',{1,coly,2});
         o = config(o,'q',{1,colq,2});
         o = config(o,'xa',{2,coly,2});
         o = config(o,'b',{2,colb,2});
         o = config(o,'phi',{3,'g',3});
         o = config(o,'z1',{3,'rk',1});
         o = config(o,'x1',{3,'r',1});
         o = config(o,'z2',{3,'bk',1});
         o = config(o,'x2',{3,'b',1});
         o = config(o,'xb',{4,coly,2});
         o = config(o,'g',{4,colg,2});
      case {'Control'}                 % All Control Signals
         o = config(o,'y',{1,coly,2});
         o = config(o,'q',{1,colq,2});
         o = config(o,'b',{2,colb,2});
         o = config(o,'g',{3,colg,2});
      case {'Booster'}                 % Booster Signals
         o = config(o,'y',{1,coly,2});
         o = config(o,'q',{1,colq,2});
         o = config(o,'b',{1,colb,2});
         o = config(o,'df',{1,'gk',4});
      case {'Triac'}                   % Triac Signals
         o = config(o,'y',{1,coly,2});
         o = config(o,'q',{1,colq,2});
         o = config(o,'g',{1,colg,2});
         o = config(o,'df',{1,'gk',4});
      case {'Phi'}                     % Estimated Phase
         o = config(o,'phi',{1,'g',3});
         o = config(o,'x1',{1,'r',1});
         o = config(o,'z1',{1,'rk',1});
         o = config(o,'x2',{1,'b',1});
         o = config(o,'z2',{1,'bk',1});
         o = config(o,'df',{2,'gk',4});
      case {'Y'}
         o = config(o,'y',{1,coly,2});
      case {'Q'}
         o = config(o,'q',{1,colq,2});
      case {'YQ'}
         o = config(o,'y',{1,coly,2});
         o = config(o,'q',{1,colq,1});
      case {'States'}
         o = config(o,'x1',{1,'r',1});
         o = config(o,'z1',{1,'rk',1});
         o = config(o,'x2',{2,'g',1});
         o = config(o,'z2',{2,'gk',1});
      case {'X'}
         o = config(o,'x1',{1,'r',1});
         o = config(o,'x2',{2,'g',1});
      case {'Z'}
         o = config(o,'z1',{1,'rk',1});
         o = config(o,'z2',{2,'gk',1});
      case {'D'}
         o = config(o,'d',{1,'r',1});
      case {'B'}
         o = config(o,'b',{1,colb,2});
      otherwise
         o = config(o,'y',{1,coly,1});
         o = config(o,'q',{2,colq,1});
   end
   change(o,'Config');
end

%==========================================================================
% Study 1-6
%==========================================================================

function o = Study1(o)                 % Constant Sampling Time        
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [1 0];
   end

      % start by setting up a log object for data logging
      
   oo = boost('system');               % create a 'system' typed object
   oo = log(oo,'t','x1','x2','y');     % setup a data log object

      % setup system matrices
      
   T = 0.5e-3;  U = 230;  f = 50;      % some parameters
   [A,B,C] = System(T,f);              % calculate system matrices A,B,C
   
   x = [0 U*sqrt(2)]';  t = 0;         % init system state  
   for k = 0:40;
      y = C*x;                         % system output
      
      oo = log(oo,t,x(1),x(2),y);      % record log data
      x = A*x;  t = t+T;               % state % time transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title','Oscillation');
   plot(oo);                           % plot graphics
end
function o = Study2(o)                 % Varying Sampling Time         
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [1 0];
   end

      % start by setting up a log object for data logging
      
   oo = boost('system');               % create a 'system' typed object
   oo = log(oo,'t','x1','x2','y');     % setup a data log object

      % run the system

   T = 0.5e-3;  U = 230;  f = 50;      % some parameters
   x = [0 U*sqrt(2)]';  t = 0;         % init system state  

   for k = 0:40;
      Tk = T * (1+abs(2*randn));     % jittered sampling time  
      [A,B,C] = System(Tk,f);          % calculate system matrices A,B,C

      y = C*x;                         % system output
      
      oo = log(oo,t,x(1),x(2),y);      % record log data
      x = A*x;  t = t+Tk;              % state % time transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title','Oscillation');
   plot(oo);                           % plot graphics
end
function o = Study3(o)                 % Luenberger Observer           
%
%  STUDY3   Luenberger Observer
%
%     System to observe     Observer Model
%        x'= A*x               z'= A*z + c   (c: observer state correction)
%        y = C*x               q = C*z
%   
%     Notes:     
%        - the approach is to use a cloned dynamic system model for the 
%          observer with the goal to final match the observer state z with
%          the (unaccessible) system state x by applying a proper observer
%          state correction c during each state transition
%        - all we are able to measure is the system output y, which should
%          be matched by the observer output q, if we reach our goal z->x.
%        - We construct the output deviation d := y - q, which will
%          approach zero (d = y-q -> 0) if we are successful to let the
%          observer state z approach x: (z -> x) => (d -> 0)
%        - The idea is to construct the observer state correction c as a
%          linear function of the output deviation d
%
%             c = K*d = K*(y-q)    K: parameters of linear correction function
%
%        - K must be selected properly in order to achieve: z -> x
%
%     Formal Analysis of the Error System
%
%        Let
%           e := x-z, further c = K*(y-q) = K*(C*x-C*z) = K*C*(x-z) = K*C*e
%
%        Study the state error transition: e --> e'
%
%           e' = x' - z' = A*x - A*x - c = A*(x-z) - c = A*e - c
%           e' = A*e - c   with  c = K*C*e  => e' = A*e + K*C*e = (A-K*C)*e
%
%        Error System:
%           e' = (A-K*C)*e             % an autonomous system
%
%     How to find proper values for K for a proper correction function 
%
%        Answer: any values of K are good which lead to a stable error 
%        system, means, the eigenvalues of Matrix S := A - K*C must lie
%        between the unit circle!
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [0.01 0];
   end

      % start by setting up a log object for data logging
      
   oo = boost('observer');             % create a 'system' typed object
   oo = log(oo,'t','x1','x2','y','z1','z2','q','d'); % setup a data log object

      % run the system

   G = opt(o,'study.G');               % observer gain
   T = 0.5e-3;  U = 230;  f = 50;      % some parameters
   x = [0 U*sqrt(2)]';  t = 0;         % init system state  
   z = [0 0]'; K = G*[1 1]';           % observer model state (unknown)
   
   for k = 0:40;
      Tk = T * (1+abs(0.3*randn));     % jittered sampling time  
      [A,B,C] = System(Tk,f);          % calculate system matrices A,B,C

         % process
         
      y = C*x;                         % system output (measuring)
      x = A*x;

         % observer
      
      q = C*z;                         % observer output
      c = K * (y-q);                   % observer state correction 
      z = A*z + c;                     % observer state transition
         
      d = y - q;
      oo = log(oo,t,x(1),x(2),y,z(1),z(2),q,d);  % record log data
      t = t+Tk;              % system state % time transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title','Oscillation');
   plot(var(oo,'G',G));                % plot graphics
end
function o = Study4(o)                 % Luenberger Observer (60Hz)    
%
%  STUDY4   Luenberger Observer
%
%     Strong observer gain (K = [-2 -2]) can compensate model mismatch
%     (60Hz system model versus 50Hz observer model)
%
%     System to observe     Observer Model
%        x'= A*x               z'= A*z + c   (c: observer state correction)
%        y = C*x               q = C*z
%   
%     Notes:     
%        - the approach is to use a cloned dynamic system model for the 
%          observer with the goal to final match the observer state z with
%          the (unaccessible) system state x by applying a proper observer
%          state correction c during each state transition
%        - all we are able to measure is the system output y, which should
%          be matched by the observer output q, if we reach our goal z->x.
%        - We construct the output deviation d := y - q, which will
%          approach zero (d = y-q -> 0) if we are successful to let the
%          observer state z approach x: (z -> x) => (d -> 0)
%        - The idea is to construct the observer state correction c as a
%          linear function of the output deviation d
%
%             c = K*d = K*(y-q)    K: parameters of linear correction function
%
%        - K must be selected properly in order to achieve: z -> x
%
%     Formal Analysis of the Error System
%
%        Let
%           e := x-z, further c = K*(y-q) = K*(C*x-C*z) = K*C*(x-z) = K*C*e
%
%        Study the state error transition: e --> e'
%
%           e' = x' - z' = A*x - A*x - c = A*(x-z) - c = A*e - c
%           e' = A*e - c   with  c = K*C*e  => e' = A*e + K*C*e = (A-K*C)*e
%
%        Error System:
%           e' = (A-K*C)*e             % an autonomous system
%
%     How to find proper values for K for a proper correction function 
%
%        Answer: any values of K are good which lead to a stable error 
%        system, means, the eigenvalues of Matrix S := A - K*C must lie
%        between the unit circle!
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [1 0];
   end

      % start by setting up a log object for data logging
      
   oo = boost('observer');             % create a 'system' typed object
   oo = log(oo,'t','x1','x2','y','z1','z2','q'); % setup a data log object
   
      % run the system

   G = opt(o,'study.G');               % observer gain
   T = 0.5e-3;  U = 230;  f = 50;      % some parameters
   x = [0 U*sqrt(2)]';  t = 0;         % init system state  
   z = [0 0]'; K = G*[1 1]';           % observer model state (unknown)
   
   for k = 0:200;
      Tk = T * (1+abs(0.3*randn));     % jittered sampling time  

         % process
         
      [A,B,C] = System(Tk,f*6/5);      % model mismatch 50Hz <-> 60Hz
      y = C*x;                         % system output (measuring)
      x = A*x;

         % observer
      
      [A,B,C] = System(Tk,f);          % calculate system matrices A,B,C
      q = C*z;                         % observer output
      c = K * (y-q);                   % observer state correction 
      z = A*z + c;                     % observer state transition
         
      oo = log(oo,t,x(1),x(2),y,z(1),z(2),q);   % record log data
      t = t+Tk;              % system state % time transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title','Oscillation');
   plot(var(oo,'G',G));                % plot graphics
end
function o = Study5(o)                 % Luenberger Observer (60Hz)    
%
%  STUDY5   Again Luenberger Observer
%
%     Strong observer gain (K = [-2 -2]) can compensate model mismatch
%     (60Hz system model versus 50Hz observer model)
%
%     System to observe     Observer Model
%        x'= A*x               z'= A*z + c   (c: observer state correction)
%        y = C*x               q = C*z
%   
%     Notes:     
%        - the approach is to use a cloned dynamic system model for the 
%          observer with the goal to final match the observer state z with
%          the (unaccessible) system state x by applying a proper observer
%          state correction c during each state transition
%        - all we are able to measure is the system output y, which should
%          be matched by the observer output q, if we reach our goal z->x.
%        - We construct the output deviation d := q - y, which will
%          approach zero (d = q-y -> 0) if we are successful to let the
%          observer state z approach x: (z -> x) => (d -> 0)
%        - The idea is to construct the observer state correction c as a
%          linear function of the output deviation d
%
%             c = K*d = K*(q-y)    K: parameters of linear correction function
%
%        - K must be selected properly in order to achieve: z -> x
%
%     Formal Analysis of the Error System
%
%        Let
%           e := z-x, further c = K*(q-Y) = K*(C*z-C*x) = K*C*(z-x) = K*C*e
%
%        Study the state error transition: e --> e'
%
%           e' = z' - x' = A*z + c - A*x = A*(z-x) + c = A*e + c
%           e' = A*e + c   with  c = K*C*e  => e' = A*e + K*C*e = (A+K*C)*e
%
%        Error System:
%           e' = (A+K*C)*e             % an autonomous system
%
%     How to find proper values for K for a proper correction function 
%
%        Answer: any values of K are good which lead to a stable error 
%        system, means, the eigenvalues of Matrix S := A + K*C must lie
%        between the unit circle!
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [1 0];
   end
   function X = InitX(o)               % Init system and observer state
      G = opt(o,'study.G');            % observer gain
      U = 230;                         % RMS grid voltage
      
         % initialize system
         
      X.x = [0 U*sqrt(2)]';            % init system state
      X.f = 50;                        % 50 Hz sine
      
         % initialize observer
         
      X.z = [0 0]';                    % init observer model state (unknown)
      X.K = G*[-1 -1]';                % observer gain
   end
   function Z = InitZ(o,X)             % Init simulation state         
      
         % start by setting up a log object for data logging
      
      Z.oo = boost('observer');        % create a 'system' typed object
      Z.oo = log(Z.oo,'t','x1','x2','y','z1','z2','q');  % setup data log obj
   
         % run the system

      Z.T = 0.5e-3;                    % sampling interval
      Z.t = 0;                         % init simulation time      
   end
   function [x,f] = UnpackP(X)         % Unpack Process State          
      x = X.x;  f = X.f;
   end
   function X = PackP(X,x,y)           % Pack Process State            
      X.x1 = X.x(1);  X.x2 = X.x(2);   % save for logging
      X.x = x;  X.y = y;               % save state after transition 
   end
   function [z,y,f,K] = UnpackO(X)     % Unpack Observer Part of State 
      z = X.z;  y = X.y;  f = X.f;  K = X.K;
   end
   function X = PackO(X,z,q)           % Pack Observer Part of State   
      X.z1 = X.z(1);  X.z2 = X.z(2);   % save for logging
      X.z = z;  X.q = q;               % save state after transition 
   end
   function X = Process(X,T)           % Process Transition            
      [x,f] = UnpackP(X);              % unpack process state
      
      [A,B,C] = System(T,f);           % model mismatch 50Hz <-> 60Hz
      y = C*x;                         % system output (measuring)
      x = A*x;                         % process state transition

      X = PackP(X,x,y);                % pack process state
   end
   function X = Observer(X,T)          % Observer Transition           
      [z,y,f,K] = UnpackO(X);          % unpack observer part of state

      [A,B,C] = System(T,f);           % calculate system matrices A,B,C
      q = C*z;                         % observer output
      c = K * (q-y);                   % observer state correction 
      z = A*z + c;                     % observer state transition
   
      X = PackO(X,z,q);                % pack observer part of state
   end
   function Z = Log(Z,X,T)             % Log state                     
      Z.oo = log(Z.oo,Z.t,X.x1,X.x2,X.y,X.z1,X.z2,X.q);   % record log data
      Z.t = Z.t + Z.T;                 % time transition
   end

   X = InitX(o);   Z = InitZ(o,X);
   for k = 0:200;
      Tk = Z.T * (1+abs(0.3*randn));   % jittered sampling time
      X = Process(X,Tk);               % process transition
      X = Observer(X,Tk);              % observer transition
      Z = Log(Z,X,Tk);                 % data logging
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(Z.oo,'title','Oscillation');
   plot(var(Z.oo,'G',G));              % plot graphics
end
function o = Study6(o)                 % Kalman Observer (60Hz)        
%
%  STUDY6   Kalman Observer
%
%        Time invariant observer for the system
%
%           x = A*x° + w               % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + c
%           c = K * [y - C*(A*z°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;  
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
      B = [0; 0];  C = [1 0];
   end
   function [P,K] = Riccati(P,A,C,Q,R) % Riccati Equation
      I = eye(size(A));                % identity matrix
      M = A*P*A' + Q;                  % (1) short hand
      K = M*C' / (C*M*C' + R);         % (2) Kalman gain
      P = (I - K*C) * M;               % (3) recursive update of P
   end

      % start by setting up a log object for data logging
      
   oo = boost('observer');             % create a 'system' typed object
   oo = log(oo,'t','x1','x2','y','z1','z2','q','d'); % setup a data log object
   
      % run the system

   G = opt(o,'study.G');               % observer gain
   T = 0.5e-3;  U = 230;  f = 50;      % some parameters
   x = [0 U*sqrt(2)]';  t = 0;         % init system state  
   z = [0 0]'; K = G*[-1 -1]';         % observer model state (unknown)
   
   sigx = 100;  P = sigx^2*eye(2);     % initial noise
   sigw = 10;   Q = sigw^2*eye(2);     % process noise
   sigv = 10;   R = sigv^2*eye(1);     % measurement noise
   
   for k = 0:40;
      Tk = T * (1+abs(0.3*randn));     % jittered sampling time  

         % process
         
      [A,B,C] = System(Tk,f*6/5);      % model mismatch 50Hz <-> 60Hz
      w = sigw*[randn; randn];         % process noise
w=0;      
      v = sigv*[randn];                % measurement noise

      y = C*x + v;                     % system output (measuring)
      x1 = x(1);  x2 = x(2);
      x = A*x + w;                     % process state transition

         % Kalman observer
      
      [A,B,C] = System(Tk,f);          % calculate system matrices A,B,C
      [P,K] = Riccati(P,A,C,Q,R);      % calculate Kalman gain
      
      qp = C*(A*z);                    % predicted observer output
      c = K * (y - qp);                % observer state correction
      z = A*z + c;                     % observer state update
      q = C*z;                         % reconstructed process output

      d = y - q;
      oo = log(oo,t,x1,x2,y,z(1),z(2),q,d);   % record log data
      t = t+Tk;              % system state % time transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title','Oscillation');
   plot(var(oo,'G',G));                % plot graphics
end

%==========================================================================
% Study7 - Tick-Tock Engine Based Boost & Triac Control
%==========================================================================

function o = Study7(o)                 % Boost & Triac Control         
%
%  STUDY7   Standard engine based implementation
%
   function [A,B,C] = System(T,f)      % create system matrices A,B,C  
      om = 2*pi*f;
      s = sin(om*T);  c = cos(om*T);
      A = [c -s; s c];                 % system matrix
      B = [0; 0];  C = [0.01 0];       % input/output matrix
   end
   function phi = Phase(x)             % Calculate Phase from State    
      phi = atan2(x(2),x(1))*180/pi;   % estimated phase
      phi = phi + 90;                  % 90° crrection                 
      phi = rem(phi+360,360);          % mapped to interval [0,360)
   end

      % auxillary functions to set triac and boost control angles

   function Triac(on,off)              % Setup Triac control angles    
   %
   % TRIAC   Triac control
   %
   %         triac(60,64)              % set Triac on/off angles [°]
   %
      X.triac.angle(1) = on;           % triac control leading angle [°]
      X.triac.angle(2) = off;          % triac control trailing angle [°]
      X.triac.angle(3) = on + 180;     % triac control leading angle [°]
      X.triac.angle(4) = off + 180;    % triac control trailing angle [°]
   end
   function Boost(on,off)              % Setup Booster On-Off Angles   
      X.boost.angle(1) = on;           % store booster on angle [°]
      X.boost.angle(2) = off;          % store booster off angle [°]
      X.boost.angle(3) = on + 180;     % store booster on angle [°]
      X.boost.angle(4) = off + 180;    % store booster off angle [°]
   end

      % initializing of global variables

   function o = Init7(o)               % Init Global Variables         
      Log7([]);                        % initialize logging

      o = with(o,'study');             % set 'study' context for options
      rng('default');                  % initialize random generator seed
      G = opt(o,'G');                  % observer gain
      U = 230;                         % RMS grid voltage
      
         % initialize noise parameters
         
      X.noise.sigv = opt(o,'sigv');    % sigma of process noise
      X.noise.sigw = opt(o,'sigw');    % sigma of measurement noise
      X.noise.angle = 45;              % 45° noise angle
      
         % initialize process
         
      X.process.mode = opt(o,'simu');  % process simulation 
      X.process.x = [0 -U*sqrt(2)]';   % init system state
      X.process.y = 0;                 % init system output
      X.process.f = opt(o,'f');        % actual frequency (process model)
      X.process.phi = 0;               % process phase
      
         % initialize observer
         
      X.observer.mode = opt(o,'mode'); % 0: Luenberger, 1: Kalman
      X.observer.h = 0.5;              % threshold to enable correction
      X.observer.f = 50;               % 50 Hz sine (observer model)
      X.observer.z = [0 0]';           % init observer model state (unknown)
      X.observer.q = 0;                % init observer output
      X.observer.d = 0;                % init observer output deviation
      X.observer.K = G*[100 -100]';    % observer gain
      X.observer.phi = 0;              % init estimated phase
      
         % initialize Kalman stuff
         
      I = eye(2);                      % 2x2 identity matrix
      X.kalman.P = 300^2 * eye(2);     % error covariance matrix
      X.kalman.Q = opt(o,'q')^2 * I;   % Kalman Q-matrix
      X.kalman.R = opt(o,'r')^2;       % Kalman R-matrix
      
         % initialize Triac control
         
      X.triac.enable = opt(o,'triac'); % enable/disable triac
      X.triac.angle = [0 0 0 0];       % triac switch angle table
      X.triac.signal = [1 0 1 0];      % triac switch signal table
      X.triac.control = 0;             % triac control signal (gate)
      X.triac.index = 1;               % init triac table index
      X.triac.state = 0;               % state to call for triac action
      
         % initialize boost control
         
      X.boost.enable = opt(o,'boost'); % enable/disable booster
      X.boost.angle = [0 0 0 0];       % booster switch angle table
      X.boost.signal = [1 0 1 0];      % booster switch signal table
      X.boost.control = 0;             % booster control signal (b)
      X.boost.index = 1;               % init booster table index
      X.boost.state = 0;               % state to call for booster action
      
         % setup timing parameters

      X.timing.T = opt(o,'T');         % nominal sampling interval
      X.timing.N = opt(o,'N');         % number of periodes
      X.timing.t = 0;                  % init simulation time      
      X.timing.sigt = opt(o,'sigt');   % sigma of time jitter
      X.timing.Tini = opt(o,'Tini');   % init time befor boost & triac
      X.timing.ready = 0;              % ready for boost & triac
      X.timing.Tk = 0;                 % actual sampling interval
      X.timing.Tmin = 0.0001;          % min time for timer (100µs)
      X.timing.clock = 0;              % clock time
      
      X.engine.clear = @Clear7;        % clear clock function
      X.engine.start = @Start7;        % start measurement function
      X.engine.process = @Process7;    % process transition
      X.engine.observer = @Observer7;  % observer transition
      X.engine.log = @Log7;            % data logging
      X.engine.control = @Control7;    % control booster & triac
      X.engine.interval = @Interval7;  % calculate new sampling interval
      X.engine.schedule = @Schedule7;  % schedule next timer callback
      X.engine.stop = false;           % stop request cleared initially
      X.engine.enable = true;          % tick-tock engine ready to run
      
         % setup boost and triac angles
         
      Triac(60,64);                    % setup Triac angle 60°, 4° duration 
      Boost(45,135);                   % setup boost signal: 45° to 135°
   end

      % Eight engine functios. Pointers to these functions
      % are stored in X.engine,so the engine knows what to call
      
   function Clear7(o)                  % Clear System Clock            
      core(o,'ClockClear');            % clear clock in core layer
   end
   function Start7(o)                  % Start Measurements            
      t = X.timing.t;                  % global store back system time
      Tm = 0.0003;                     % 300µs measurement time
      sigt = X.timing.sigt;            % sigma for time jitter
      Tm = Tm * (1+sigt*abs(randn));   % time for measurement
      
      X.timing.clock = Tm;             % update clock time
      X.timing.t = t + Tm;             % update system time
      core(o,'MeasureStart',t);        % clear clock in core layer
   end
   function Process7(o)                % Process Transition            
      function [x,f,T,sv,sw] = Unpack  % Unpack Process Stuff          
         x = X.process.x;              % unpack old state
         f = X.process.f;              % unpack frequency
         T = X.timing.Tk;              % sampling time
         sv = opt(o,'study.sigv');     % measurement noise
         sw = opt(o,'study.sigw');     % process noise
      end
      function Pack(x,y,phi)           % Pack Process State            
         X.process.x = x;              % save state after transition 
         X.process.y = y;              % save output after transition
         X.process.phi = phi;          % save process phase
      end
      function Simulation(o)
         [xo,f,T,sv,sw] = Unpack;      % unpack process state

         [A,B,C] = System(T,f);        % model mismatch 50Hz <-> 60Hz
         x = A*xo + sw*randn(2,1);     % process state transition
         y = C*x + sv*randn;           % system output (measuring)
         y = max(y,-0.2);              % saturation of measurement

         phi = Phase(x);               % phase of grid voltage
         Pack(x,y,phi);                % pack process state
      end
      
      switch X.process.mode            % dispatch process simulation mode
         case 0                        % simulation 
            Simulation(o);             % simulation of process
         case 1                        % use core functions
            Measurement(o);            % measurement of process
      end
   end
   function Observer7(o)               % Observer Transition           
      function Luenberger(o)           % Luenberger Observer Transition
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
      function Kalman(o)               % Kalman Observer Transition    
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
         
      switch X.observer.mode
         case 0
            Luenberger(o);             % Luenberger observer transition
         case 1
            Kalman(o);                 % Kalman observer transition
      end
   end
   function Log7(o)                    % Data Logging                  
   %
   % LOG  Initialize a log object or add log data to log object
   %
   %         Log([])                   % initialize log object
   %         Log(o)                    % add log data to log object
   %
      if isempty(o)                    % initialize log object
         oo = boost('observer');       % create an 'observer' typed object
         oo = log(oo,'t','x1','x2','y','z1','z2','q','d','xa','xb',...
                     'b','g','phi','df'); 
      else                             % add log data to log object
         b = X.boost.control;          % boost output
         g = X.triac.control;          % triac gate
         x = X.process.x;  
         y = X.process.y;
         r = x(1)/100;                 % boost signal, voltage reference
         z = X.observer.z;
         q = X.observer.q;
         d = X.observer.d;
         phi = X.observer.phi;
         df = (X.process.phi-phi);     % phase error in mdeg
         if (df<-180) df = df+360; end;% map to interval [-180°,180°)
         if (df>+180) df = df-360; end;% map to interval [-180°,180°)
         t = X.timing.t;
         oo = X.log.oo;                % access to log object
         oo = log(oo,t,x(1),x(2),y,z(1),z(2),q,d,r,r,b,g,phi,df); 
      end
      X.log.oo = oo;                   % save log object
   end
   function Control7(o)                % Triac & Boost Control         
      function S = Action(S)           % Perform Triac/Booster Action  
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
         
      X.boost = Action(X.boost);       % booster control action
      X.triac = Action(X.triac);       % triac control action
   end
   function Interval7(o)               % Calculate Next Sample Interval
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
         
      if (X.timing.t >= X.timing.Tini)
         X.timing.ready = 1;           % now ready for booster & triac
      end
      
         % determine booster & triac schedule
         
      Tk = X.timing.T;                 % nominal sampling time      
      if (X.timing.ready)
         om = 360*X.observer.f;        % circular frequency
         phi = rem(X.observer.phi,360);% map phi to interval [0°,360°)

         [X.boost,Tb] = Determine(X.boost,Tk,phi,om);
         [X.triac,Tt] = Determine(X.triac,Tk,phi,om);

            % schedule booster action if proper

         Tk = min([Tk,Tb,Tt]);
         X.timing.Tk = Tk;             % store Tk in global variables
         if (Tb == Tk || Tt == Tk)
            'break';
         end
         X.boost.state = (Tb == Tk);
         X.triac.state = (Tt == Tk);
      end
      X.timing.Tk = Tk;                % pass over planned sample interval
   end
   function Schedule7(o)               % Schedule a Timer Callback     
      Tp = X.timing.Tk;                % planned sampling time
      Tnow = X.timing.clock;           % current clock time since clear
      
         % make sure that Tk is not smaller than minimum timer requirement

      Tmin = X.timing.Tmin;            % unpack minimum time for timer
      
      Tr = Tp - Tnow;                  % remaining time until Tick interrupt
      if (Tr < Tmin)                   % Tr compatible with timer?
         delta = Tmin - Tr;            % need to increase by delta
         Tr = Tr + delta;              % increase Tr -> Tmin
         Tk = Tp + delta               % increase Tk -> Tp + (Tmin - Tr)
      else
         Tk = Tp;                      % otherwise actual Tk = planned Tp
      end
      X.timing.Tk = Tk;                % global store
      
         % simulate a jitter for timing and update simulation time
         % note that only time t is influenced by jitter, not Tk
         
      sigt = X.timing.sigt;            % timing jittering sigma
      Tj = Tr * (1+abs(sigt*randn));   % jittered remaining time
      X.timing.t = X.timing.t + Tj;    % jittered time transition
      
      core(o,'TimerStart',Tr);         % start timer with remaining time
   end

      % Let's go: run the simulation engine

   global X                            % our global variables
   o = Init7(o);                       % Initialize global variables (X)
   engine(o);                          % run the tick/tock engine

      % finally plot logged data
      
   Plot(arg(o,{X,'Study7: Boost & Triac Control',G})); 
end
function o = Plot(o,oo)                % Plot Log Data                 
   X = arg(o,1);
   title = arg(o,2);
   G = arg(o,3);
   
   if (opt(o,'study.mode') == 0)
      title = [title,' (Luenberger)'];
   else
      title = [title,' (Kalman)'];
   end
   
   oo = X.log.oo;
   oo = set(oo,'title',title);
   plot(var(oo,'G',G));                % plot graphics
end
function o = Special(o)                % Boost & Triac - Special Call  
   charm(o,'study.mode',0);            % Luenberger observer
   charm(o,'study.boost',1);           % boost enabled
   charm(o,'study.triac',1);           % triac enabled
   charm(o,'study.T',0.002);           % sampling time
   charm(o,'study.Tini',0.02);         % initial time before boost & triac
   charm(o,'study.N',3);               % number of periodes
   charm(o,'study.f',50);              % mains grid frequency
   charm(o,'study.U',230);             % mains grid RMS voltage
   charm(o,'study.G',1);               % observer gain
   charm(o,'study.sigw',0.0);          % no stochastic process noise (0.0)
   charm(o,'study.sigv',0.0);          % stochastic measurement noise (0.1)
   charm(o,'study.sigt',0.0);          % stochastic time jitter (0.3)
   charm(o,'study.sigv',0.0);          % stochastic measurement noise (0.1)
   charm(o,'study.sigt',0.0);          % stochastic time jitter (0.3)
  
   charm(o,'study.q',5);               % Kalman q-parameter
   charm(o,'study.r',0.1);             % Kalman r-parameter

   mode = arg(o,1);
   switch mode
      case 'L-Nominal'
         % nothing to do
      case 'K-Nominal'
         charm(o,'study.mode',1);      % Kalman observer
         charm(o,'study.N',2);         % number of periodes
      case 'L-NoInit'
         charm(o,'study.Tini',0);      % initial time before boost & triac
         charm(o,'study.N',2);         % number of periodes
      case 'K-NoInit'
         charm(o,'study.mode',1);      % Kalman observer
         charm(o,'study.Tini',0);      % initial time before boost & triac
      case 'L-HighRate'
         charm(o,'study.T',0.0005);    % 0.5 ms sampling rate
      case 'K_HighRate'
         charm(o,'study.mode',1);      % Kalman observer
         charm(o,'study.T',0.0005);    % 0.5 ms sampling rate
      case 'L-Noisy'
         charm(o,'study.N',10);        % number of periodes
         charm(o,'study.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'study.sigt',0.3);    % stochastic time jitter (0.3)
      case 'K-Noisy'
         charm(o,'study.mode',1);      % Kalman observer
         charm(o,'study.N',10);        % number of periodes
         charm(o,'study.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'study.sigt',0.3);    % stochastic time jitter (0.3)
      case 'L-NoisyHigh'
         charm(o,'study.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'study.sigt',0.3);    % stochastic time jitter (0.3)
         charm(o,'study.T',0.0005);    % 0.5 ms sampling rate
         charm(o,'study.Tini',0);      % initial time before boost & triac
      case 'K-NoisyHigh'
         charm(o,'study.mode',1);      % Kalman observer
         charm(o,'study.sigv',0.1);    % stochastic measurement noise (0.1)
         charm(o,'study.sigt',0.3);    % stochastic time jitter (0.3)
         charm(o,'study.T',0.0005);    % 0.5 ms sampling rate
         charm(o,'study.Tini',0);      % initial time before boost & triac
   end
   o = pull(o);                        % refresh options
   o = Study7(o);
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'study.engine'},0);      % Loop engine by default observer
   setting(o,{'study.timer'},0);       % Luenberger observer
   setting(o,{'study.mode'},0);        % Luenberger observer
   setting(o,{'study.simu'},0);        % Process simulation
   setting(o,{'study.boost'},1);       % boost enabled
   setting(o,{'study.triac'},1);       % triac enabled
   setting(o,{'study.T'},0.002);       % sampling time
   setting(o,{'study.Tini'},0.02);     % initial time before boost & triac
   setting(o,{'study.N'},2);           % number of periodes
   setting(o,{'study.f'},50);          % mains grid frequency
   setting(o,{'study.U'},230);         % mains grid RMS voltage
   setting(o,{'study.G'},1);           % observer gain
   setting(o,{'study.sigw'},0.0);      % no stochastic process noise (0.0)
   setting(o,{'study.sigv'},0.0);      % stochastic measurement noise (0.1)
   setting(o,{'study.sigt'},0.0);      % stochastic time jitter (0.3)
   setting(o,{'study.q'},5);           % Kalman q-parameter
   setting(o,{'study.r'},0.1);         % Kalman r-parameter
   
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Engine Mode','','study.engine'); 
         choice(ooo,{{'0: Loop Engine',0},{'1: Event Engine',1}},{});
   ooo = mitem(oo,'Timer Mode','','study.timer'); 
         choice(ooo,{{'0: Simulation',0},{'1: Timer',1}},{});
   ooo = mitem(oo,'Observer Mode','','study.mode'); 
         choice(ooo,{{'0: Luenberger',0},{'1: Kalman',1}},{});
   ooo = mitem(oo,'Process Mode','','study.simu'); 
         choice(ooo,{{'0: Simulation',0},{'1: Sine Wave',1}},{});
   ooo = mitem(oo,'Booster','','study.boost'); 
         choice(ooo,{{'off',0},{'on',1}},{});
   ooo = mitem(oo,'Triac','','study.triac'); 
         choice(ooo,{{'off',0},{'on',1}},{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'T: Sampling Time [s]','','study.T'); 
         charm(ooo,{});
   ooo = mitem(oo,'N: Number of Periodes','','study.N'); 
         charm(ooo,{});
   ooo = mitem(oo,'Tini: Initializing Time [s]','','study.Tini'); 
         charm(ooo,{});
   ooo = mitem(oo,'f: Frequency [Hz]','','study.f'); 
         charm(ooo,{});
   ooo = mitem(oo,'U: RMS Voltage [V]','','study.U'); 
         charm(ooo,{});
   ooo = mitem(oo,'G: Observer Gain [1]','','study.G'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'sigv: Measurement Noise [V]','','study.sigv'); 
         charm(ooo,{});
   ooo = mitem(oo,'sigw: Process Noise [V]','','study.sigw'); 
         charm(ooo,{});
   ooo = mitem(oo,'sigt: Time Jitter [1]','','study.sigt'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'r: Measurement Noise Parameter [V]','','study.r'); 
         charm(ooo,{});
   ooo = mitem(oo,'q: Process Noise Parameter [V]','','study.q'); 
         charm(ooo,{});
end

