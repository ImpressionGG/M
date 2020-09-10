function oo = study(o,varargin)         % Study Menu                   
%
% STUDY  Manage simulation menu
%
%           study(o,'Setup');           %  Setup Study menu
%
%           study(o,'Study1');          %  System Behavior
%           study(o,'Study2');          %  Time variant predictor
%           study(o,'Study3');          %  Time variant observer
%           study(o,'Study4');          %  Kalman filter
%
%           study(o,'Signal');          %  Setup STUDY specific Signal menu
%
%        See also: PREDICT, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Signal,...
                       @Study1,@Study2,@Study3,@Study4,@Study5,@Study6,...
                       @Study7,@Study8,@Analysis,@IdentResidual,@Uncertainty);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Simulation Menu         
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'System Behavior',{@Study1});
   ooo = mitem(oo,'Time Variant Predictor',{@Study2});
   ooo = mitem(oo,'Time Variant Observer',{@Study3});
   ooo = mitem(oo,'Kalman Filter 1',{@Study4});
   ooo = mitem(oo,'Kalman Filter 2',{@Study5});
   ooo = mitem(oo,'Kalman Filter @ PT2',{@Study6});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Positioning');
   oooo = mitem(ooo,'Positioning',{@Study7});
   oooo = mitem(ooo,'Fast Positioning',{@Study8});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Positioning Defaults',{@PositioningDefaultParameters});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'system'));           % register 'system' configuration
   Config(type(o,'predict'));          % register 'predict' configuration
   Config(type(o,'observe'));          % register 'observe' configuration
   Config(type(o,'kalman'));           % register 'kalman' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
   plugin(o,['caramel/shell/Analysis'],{mfilename,'Analysis'});
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Simu Specific Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   switch active(o);                   % depending on active type
      case {'predict','observe','kalman'}
         oo = mitem(o,'X/Y/S/Q,E/P',{@Config},'XYSQ_EP');
         oo = mitem(o,'Y/Q',{@Config},'YQ');
         oo = mitem(o,'-');
         oo = mitem(o,'X',{@Config},'X');
         oo = mitem(o,'Y',{@Config},'Y');
         oo = mitem(o,'S',{@Config},'S');
         oo = mitem(o,'E',{@Config},'E');
         oo = mitem(o,'Y,E',{@Config},'Y_E');
         oo = mitem(o,'Y/Q,E',{@Config},'YQ_E');
         oo = mitem(o,'X/Y',{@Config},'XY');
         oo = mitem(o,'X,Y,S',{@Config},'X_Y_S');
         oo = mitem(o,'X/Y/S',{@Config},'XYS');
         oo = mitem(o,'Y,Q,S,E',{@Config},'Y_Q_S_E');
      case {'system'}
         oo = mitem(o,'X/Y',{@Config},'XY');
         oo = mitem(o,'X_Y',{@Config},'X_Y');
         oo = mitem(o,'-');
         oo = mitem(o,'X',{@Config},'X');
         oo = mitem(o,'Y',{@Config},'Y');
   end
end
function o = Config(o)                 % Install a Configuration       
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = category(o,1,[0 0],[0 0],'µ');  % setup category 1
   o = category(o,2,[-0.2 0.2],[],'µ'); % setup category 2
   
   mode = o.either(arg(o,1),o.type);
   switch mode
      case {'X'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
      case {'E'}
         o = config(o,'e',{1,'o',2});  % configure 'e' for 1st subplot
      case {'Y'}
         o = config(o,'y',{1,'b',1});  % configure 'y' for 2nd subplot
      case {'S'}
         o = config(o,'s',{1,'g',1});  % configure 'y' for 2nd subplot
      case {'P'}
         o = config(o,'p',{1,'n',1});  % configure 'p' for 1st subplot
      case {'XY'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{1,'b',1});  % configure 'y' for 2nd subplot
      case {'X_Y','system'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{2,'b',1});  % configure 'y' for 2nd subplot
         mode = 'X_Y';
      case {'Y_E'}
         o = config(o,'y',{1,'b',1});  % configure 'y' for 1st subplot
         o = config(o,'e',{2,'o',2});  % configure 'e' for 2nd subplot
      case {'YQ_E'}
         o = config(o,'y',{1,'b',1});  % configure 'y' for 1st subplot
         o = config(o,'q',{1,'m',1});
         o = config(o,'e',{2,'o',2});  % configure 'e' for 2nd subplot
      case {'Y_Q_S_E'}
         o = config(o,'y',{1,'b',1});  % configure 'y' for 1st subplot
         o = config(o,'q',{2,'m',1});  % configure 'q' for 2nd subplot
         o = config(o,'s',{3,'g',1});  % configure 'p' for 3rd subplot
         o = config(o,'e',{4,'o',2});  % configure 'e' for 4th subplot
      case {'YQ'}
         o = config(o,'y',{1,'b',1});  % configure 'y' for 1st subplot
         o = config(o,'q',{1,'m',1});  % configure 'q' for 2nd subplot
      case {'XYS'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{1,'b',1});  % configure 'y' for 2nd subplot
         o = config(o,'s',{1,'g',1});  % configure 'p' for 3rd subplot
      case {'XYS_E','predict','observe'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{1,'b',1});  % configure 'y' for 2nd subplot
         o = config(o,'s',{1,'g',1});  % configure 'p' for 3rd subplot
         o = config(o,'e',{2,'o',2});  % configure 'e' for 4th subplot
         o = subplot(o,'Layout',2);
         mode = 'X_Y';
      case {'XYSQ_EP','kalman'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{1,'b',1});  % configure 'y' for 1st subplot
         o = config(o,'s',{1,'g',1});  % configure 'p' for 1st subplot
         o = config(o,'q',{1,'m',1});  % configure 'q' for 1st subplot
         o = config(o,'e',{2,'o',2});  % configure 'e' for 2nd subplot
         o = config(o,'p',{2,'n',2});  % configure 'e' for 2nd subplot
         o = subplot(o,'Layout',2);
         mode = 'X_Y';
      case {'X_Y_S'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{2,'b',1});  % configure 'y' for 2nd subplot
         o = config(o,'s',{3,'g',1});  % configure 'p' for 3rd subplot
      case {'X_Y_S_E'}
         o = config(o,'x',{1,'r',1});  % configure 'x' for 1st subplot
         o = config(o,'y',{2,'b',1});  % configure 'y' for 2nd subplot
         o = config(o,'s',{3,'g',1});  % configure 'p' for 3rd subplot
         o = config(o,'e',{4,'o',2});  % configure 'e' for 4th subplot
   end
   o = subplot(o,'Signal',mode);       % set signal mode   
   change(o,'Bias','absolute');
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'study.tmax'},0.1);
   setting(o,{'study.T'},1/1000);
   setting(o,{'study.repeats'},10);
   setting(o,{'study.omega'},100*2*pi);
   setting(o,{'study.damping'},-80);
   setting(o,{'study.zeta'},0.5);
   setting(o,{'study.sigma.x'},3.3);   % initial noise
   setting(o,{'study.sigma.v'},0.1);   % measurement noise
   setting(o,{'study.sigma.w'},0.0);   % process noise
   setting(o,{'study.a'},0.98);
   setting(o,{'study.g'},0.9);
   setting(o,{'study.speed'},1);       % Kalman speed factor
   
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Maximum Time',{},'study.tmax'); 
         charm(ooo,{});
   ooo = mitem(oo,'Sampling Interal',{},'study.T'); 
         charm(ooo,{});
   ooo = mitem(oo,'Repeats',{},'study.repeats'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Omega',{},'study.omega'); 
         charm(ooo,{});
   ooo = mitem(oo,'Damping',{},'study.damping'); 
         charm(ooo,{});
   ooo = mitem(oo,'Zeta',{},'study.zeta'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Noise');
   oooo = mitem(ooo,'Initial (sigma_x)',{},'study.sigma.x');
          charm(oooo,{});
   oooo = mitem(ooo,'Measurement (sigma_v)',{},'study.sigma.v');
          charm(oooo,{});
   oooo = mitem(ooo,'Process (sigma_w)',{},'study.sigma.w');
          charm(oooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Filter Eigen Value',{},'study.a');
         charm(ooo,{});
   ooo = mitem(oo,'Adaption Eigen Value',{},'study.g');
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Kalman Speed',{},'study.speed');
         charm(ooo,{});
end
function o = PositioningDefaultParameters(o)                           
   charm(o,'study.repeats',3);
   charm(o,'study.zeta',0.05);
   charm(o,'study.sigma.v',0.06);      % std. dev of measurement
end

%==========================================================================
% Simulations
%==========================================================================

function o = Study1(o)                 % System Behavior               
%
% STUDY1 Repeated simulation data is stored in a PREDICT object of type
%        'predict', stored into clipboard for potential paste and plotted.
%        If pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = caramel('system');             % create an 'osci' typed object
   oo = log(oo,'t,x,y');               % setup a data log object

         % setup parameters and system matrix
      
   o = with(o,'study');                % proceed with 'study' context
   [T,r,om,dmp] = opt(o,'T','repeats','omega','damping');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   Ad = S*exp(dmp*T);                  % system matrix for damped oscill's
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial noise
      x = [x0 1.5 -0.5]';              % init system state
      for k = 0:100;
         v = sigv * randn;             % measurement noise
         y = C*x + v;                  % noisy system output
         
         oo = log(oo,t,C*x,y);         % record log data
         x = A*x; t = t+T;             % state & time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Damped Oscillation @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study2(o)                 % Time Variant Predictor        
%
% STUDY2 The system dynamics of the oszillation is known, but not the
%        random offset (system noise).
%
   oo = caramel('predict');            % create a 'predict' typed object
   oo = log(oo,'t,x,y,s,q,e');         % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp] = opt(o,'T','repeats','omega','damping');
   [a,g] = opt(o,'a','g');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   A = S*exp(dmp*T); C = [0 1];        % system matrices
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x = [1.5 -0.5]';                 % init system state
      z = x;                           % we assume to know system state
      s = 0;                           % prediction of steady position
      x0 = sigx * randn;               % initial (positioning) noise
      ak = 0;
      for k = 0:100;
         v  = sigv*randn;              % measurement noise
         y = C*x + x0 + v;             % system output
         q = C*z;                      % observer output
         
         ak = g*ak + (1-g)*a;
         s = s*ak + (1-ak)*(y - q);    % prediction of steady position
         e = (C*x + x0) - q - s;       % prediction error
         
         oo = log(oo,t,y-v,y,s,q,e);   % record log data
         x = A*x;                      % system state transition
         z = A*z;                      % predictor state transition
         t = t + T;                    % time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study3(o)                 % Time Variant Observer         
%
% STUDY3 Time variant observer. The system dynamics of the oszillation is
%        known, but not the random offset (system noise).
%
   oo = caramel('observe');            % create an 'observe' typed object
   oo = log(oo,'t,x,y,s,q,e');         % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp] = opt(o,'T','repeats','omega','damping');
   [a,g] = opt(o,'a','g');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   Ad = S*exp(dmp*T);                  % system matrix for damped oscill's
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = [x0 1.5 -0.5]';              % init system state
      z = [0;  x(2:3)];                % we assume to know system state
      K = [1 0 0]';
      for k = 0:100;
         v  = sigv*randn;              % measurement noise
         y = C*x + v;                  % system output
         q = C*z;                      % observer output
         
         K = g*K + (1-g)*[(1-a) 0 0]';

         s = z(1);                     % ahead prediction of steady pos
         e = C*(z-x);                  % prediction error
         
         oo = log(oo,t,C*x,y,s,q,e);   % record log data
         x = A*x;                      % system state transition
         z = A*z - K*(C*z-y);          % observer state transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study4(o)                 % Kalman Filter 1               
%
% STUDY4 Kalman Filter: time variant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
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
%
   oo = caramel('kalman');             % create a 'kalman' typed object
   oo = log(oo,'t,x,y,s,q,e,p');       % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp] = opt(o,'T','repeats','omega','damping');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   Ad = S*exp(dmp*T);                  % system matrix for damped oscill's
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   B = [0 0 0]';
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = [x0 1.5 -0.5]';              % init system state
      u = 0;                           % zero control input
      z = [0;  x(2:3)];                % we assume to know system state
      P = diag([sigx^2 0 0]);          % initial error covariance matrix
      Q = diag([0 sigw^2 sigw^2]);     % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix
      I = eye(size(A));                % identity matrix
      
      for k = 0:100;
         v  = sigv * randn;            % measurement noise
         w  = sigw * [0 randn randn]'; % process noise
         y = C*x + v;                  % system output
         
         f = C*x;                      % noise free system output
         e = C*(z-x);                  % observation error
         p = 3*sqrt(norm(P));          % 3*sigma of P
         
           % Kalman filter

         q = C*z;                      % observer output

         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
           
         c = K * [y - C*(A*z + B*u)];  % observer state correction
         z = A*z + B*u + c;            % observer state update
         
         s = z(1);                     % ahead prediction of steady position
         
         oo = log(oo,t,f,y,s,q,e,p);   % record log data
         x = A*x + w;                  % system transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study5(o)                 % Kalman Filter 2               
%
% STUDY5 Kalman Filter: time variant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           h = A*z° + B*u°
%           z = h + K * [y - C*h]
%
%           q = C*z                    % observer output
%           s = [1 0 0]*z              % steady output prediction
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
%
   oo = caramel('kalman');             % create a 'kalman' typed object
   oo = log(oo,'t,x,y,s,q,e,p');       % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp] = opt(o,'T','repeats','omega','damping');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   Ad = S*exp(dmp*T);                  % system matrix for damped oscill's
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   B = [0 0 0]';
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = [x0 1.5 -0.5]';              % init system state
      u = 0;                           % zero control input
      z = [0;  x(2:3)];                % we assume to know system state
      P = diag([sigx^2 0 0]);          % initial error covariance matrix
      Q = diag([0 sigw^2 sigw^2]);     % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix
      I = eye(size(A));                % identity matrix
      
      for k = 0:100;
         v  = sigv * randn;            % measurement noise
         w  = sigw * [0 randn randn]'; % measurement noise
         y = C*x + v;                  % system output
         
         f = C*x;                      % noise free system output
         e = C*(z-x);                  % observation error
         p = 3*sqrt(norm(P));          % 3*sigma of P
         
           % Kalman filter

         q = C*z;                      % observer output

         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
           
         h = A*z + B*u;                % half way observer state transition
         z = h + K*(y-C*h);            % full way observer state transition
         
         s = z(1);                     % ahead prediction of steady position
         
         oo = log(oo,t,f,y,s,q,e,p);   % record log data
         x = A*x + w;                  % system transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study6(o)                 % Kalman Filter @ PT2           
%
% STUDY5 Kalman Filter: time variant observer for the system
%
%        Our system is of PT2 type with transfer function
%
%                            1                      w^2
%           G(s) = ----------------------- = -------------------
%                  1 + 2*d*(z/w) + (z/w)^2   s^2 + 2*d*w*s + w^2 
%
%        By applying 2nd standard form we get the continuous type matrices
%
%           Ac = [0 -a0; 1 - a1]     =>   Ac = [0 -w^2 ; 1 -2*d*w]
%           Bc = [  b0 ;   b1  ]     =>   Bc = [  w^2  ;    0    ]
%           Cc = [   0     1   ]     =>   Cc = [   0   ;    1    ]
%
%        This system has to be converted to a discrete type system at 
%        sample time Ts.
%                                  /Ts
%           A = exp(Ac*Ts);   B = |exp(Ac*t)*Bc*dt = Ac \ exp(Ac*Ts)*Bc
%                                 /0
%
%        The discrete system dynamics can be described as:
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           h = A*z° + B*u°
%           z = h + K * [y - C*h]
%
%           q = C*z                    % observer output
%           s = [1 0 0]*z              % steady output prediction
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
%
   oo = caramel('kalman');             % create a 'kalman' typed object
   oo = log(oo,'t,x,y,s,q,e,p');       % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp,tmax] = opt(o,'T','repeats','omega','damping','tmax');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   d = exp(dmp*T)/4;  
   Ac = [0 -om^2 ; 1 -2*d*om];  Bc = [om^2; 0];  C = [0 1];
   Ad = expm(Ac*T);  Bd = Ac \ expm(Ac*T)*Bc;
   
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   B = [0 Bd']';
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = [x0 1.5 -0.5]';              % init system state
      x = [x0 0 -0.01]';               % init system state
      u = 0;                           % zero control input
      z = [0;  x(2:3)];                % we assume to know system state
      z = [0;  0; 0];                  % we assume to know system state
%     P = diag([sigx^2 0 0]);          % initial error covariance matrix
      P = diag([sigx^2 2^2 2^2]);      % initial error covariance matrix
      Q = diag([0 sigw^2 sigw^2]);     % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix
      I = eye(size(A));                % identity matrix
      
      for k = 0:tmax/T;
         v  = sigv * randn;            % measurement noise
         w  = sigw * [0 randn randn]'; % measurement noise
         y = C*x + v;                  % system output
         
         f = C*x;                      % noise free system output
         e = C*(z-x);                  % observation error
         p = 3*sqrt(norm(P));          % 3*sigma of P
         
           % Kalman filter

         q = C*z;                      % observer output

         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
%K=0*K;           
         h = A*z + B*u;                % half way observer state transition
         z = h + K*(y-C*h);            % full way observer state transition
         
         s = z(1);                     % ahead prediction of steady position
         
         oo = log(oo,t,f,y,s,q,e,p);   % record log data
         x = A*x + w;                  % system transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study7(o)                 % Kalman Filter @ PT2           
%
% POSITIONING
%
%        The discrete system dynamics can be described as:
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           h = A*z° + B*u°
%           z = h + K * [y - C*h]
%
%           q = C*z                    % observer output
%           s = [1 0 0]*z              % steady output prediction
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
%
   oo = caramel('kalman');             % create a 'kalman' typed object
   oo = log(oo,'t,x,y,s,q,e,p');       % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,dmp,tmax] = opt(o,'T','repeats','omega','damping','tmax');
   [sigx,sigv,sigw] = opt(o,'sigma.x','sigma.v','sigma.w');
   
   A = [1]; C = [1];  % system matrices
   B = [1];
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = x0;                          % init system state
      z = [0];                         % we assume to know system state
      P = sigx^2;                      % initial error covariance matrix
      Q = sigw^2;                      % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix
      I = eye(size(A));                % identity matrix
      
      V = 1;                           % positioning gain
      for k = 0:tmax/T;
         v  = sigv * randn;            % measurement noise
         w  = sigw * randn;            % measurement noise
         y = C*x + v;                  % system output
         
         f = C*x;                      % noise free system output
         e = C*(z-x);                  % observation error
         p = 3*sqrt(norm(P));          % 3*sigma of P
         
           % Kalman filter

         q = C*z;                      % observer output
         u = -V*q;                     % control signal

         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
%K=0*K;           
         h = A*z + B*u;                % half way observer state transition
         z = h + K*(y-C*h);            % full way observer state transition
         
         s = z(1);                     % ahead prediction of steady position
         
         oo = log(oo,t,f,y,s,q,e,p);   % record log data
         x = A*x + w;                  % system transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Positioning @ ',o.now]);
   plot(oo);                           % plot graphics
end
function o = Study8(o)                 % Fast Positioning              
%
% STUDY8 Fast Positioning
%
%        Our system is of PT2 type with transfer function
%
%                            1                      w^2
%           G(s) = ----------------------- = -------------------
%                  1 + 2*d*(z/w) + (z/w)^2   s^2 + 2*d*w*s + w^2 
%
%        By applying 2nd standard form we get the continuous type matrices
%
%           Ac = [0 -a0; 1 -a1 ]     =>   Ac = [0 -w^2 ; 1 -2*d*w]
%           Bc = [  b0 ;    b1 ]     =>   Bc = [  w^2  ;    0    ]
%           Cc = [   0      1  ]     =>   Cc = [   0   ;    1    ]
%
%        This system has to be converted to a discrete type system at 
%        sample time Ts.
%                                  /Ts
%           A = exp(Ac*Ts);   B = |exp(Ac*t)*Bc*dt = Ac \ exp(Ac*Ts)*Bc
%                                 /0
%
%        The discrete system dynamics can be described as:
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           h = A*z° + B*u°
%           z = h + K * [y - C*h]
%
%           q = C*z                    % observer output
%           s = [1 0 0]*z              % steady output prediction
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
%
   refresh(o,o);
   oo = caramel('kalman');             % create a 'kalman' typed object
   oo = log(oo,'t,x,y,s,q,e,p');       % setup a data log object

         % setup parameters and system matrix

   o = with(o,'study');                % with 'study' context
   [T,r,om,zeta,tmax] = opt(o,'T','repeats','omega','zeta','tmax');
   [sigx,sigv,sigw,speed] = opt(o,'sigma.x','sigma.v','sigma.w','speed');

   Ac = [0 -om^2 ; 1 -2*zeta*om];  Bc = [om^2; 0];  C = [0 1];
   Ad = expm(Ac*T);  Bd = Ac \ expm(Ac*T)*Bc;
   
   A = [1 0 0;[0;0] Ad]; C = [1 1 0];  % system matrices
   B = [0 Bd']';
   
      % run the system
   
   t = 0;
   for i = 1:r                         % r = repeats
      oo = log(oo);                    % next repeat
      x0 = sigx * randn;               % initial (positioning) noise
      x = [x0 1.5 -0.5]';              % init system state
      x = [x0 0 -0.01]';               % init system state
      u = 0;                           % zero control input
      z = [0;  x(2:3)];                % we assume to know system state
      z = [0;  0; 0];                  % we assume to know system state
%     P = diag([sigx^2 0 0]);          % initial error covariance matrix
      P = diag([sigx^2 2^2 2^2]);      % initial error covariance matrix
      Q = diag([0 sigw^2 sigw^2]);     % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix
      I = eye(size(A));                % identity matrix
      
xold = x;  vold = 0;      
      for k = 0:tmax/T;
         v  = sigv * randn;            % measurement noise
         w  = sigw * [0 randn randn]'; % measurement noise
         y = C*x + v;                  % system output
         
         f = C*x;                      % noise free system output
         
            % this stuff is a hack (xold)
            
         %e = C*(z-x);                 % observation error
e = C*(z-xold);                        % observation error
yold = C*xold + vold;
xold = x;  vold = v;

         p = 3*sqrt(norm(P));          % 3*sigma of P
         
           % Kalman filter

         q = C*z;                      % observer output

         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         K = speed*K;                  % Kalman adaption speed
         P = (I - K*C) * M;            % (3) recursive update of P
         h = A*z + B*u;                % half way observer state transition
         z = h + K*(y-C*h);            % full way observer state transition
         
         s = z(1);                     % ahead prediction of steady position
         
%        oo = log(oo,t,f,y,s,q,e,p);   % record log data
oo = log(oo,t,f,yold,s,q,e,p);         % record log data
         x = A*x + w;                  % system transition
         t = t+T;                      % state/time transition
      end
   end

      % provide title and plot graphics
      
   oo = set(oo,'title',['Prediction @ ',o.now]);
   plot(oo);                           % plot graphics
end

%==========================================================================
% Analysis
%==========================================================================

function o = Analysis(o)               % Analysis Menu                 
   switch active(o)
      case 'system'
         oo = mitem(o,'-');
         oo = mitem(o,'Identification Residual',{@IdentResidual});
      case 'predict'
         oo = mitem(o,'-');
         oo = mitem(o,'Uncertainty',{@Uncertainty});
      case 'kalman'
         oo = mitem(o,'-');
         oo = mitem(o,'Kalman Analysis',{@KalmanAnalysis});
   end
end
function o = IdentResidual(o)          % Identification Residual       
   oo = current(o);                    % get current object
   X = cook(oo,'x','overlay');
   Y = cook(oo,'y','overlay');
   T = cook(oo,'t','overlay');
   t = T(1,:);
   
   xm = mean(X);  ym = mean(Y);
   e = ym - xm;
   
   oo = data(oo,[]);
   oo = log(oo,'t, x:r#1, y:b#1, e:o#2',t,xm,ym,e);
   plot(oo,'Stream');
   subplot(212);  hold off
   o.color(plot(t*1000,e),'o');
   xlabel('time [ms]');  set(gca,'xlim',[0 1000*max(t)]);
   ylabel('e [µ]');
   sigma = 1000*std(e);                % sigma [nm]
   title(sprintf('Identification Residual: %g nm @ 3s @ %g repeats',...
                 round(3*sigma),size(X,1)));
end
function o = Uncertainty(o)            % Display Uncertainty Progress  
   oo = current(o);                    % get current object
   E = cook(oo,'e','overlay');
   T = cook(oo,'t','overlay');
   t = T(1,:);
   s = std(E);                         % standard deviation
   
   oo = smart(oo,'t, e#1, y#2');
   plot(oo,'Overlay');
   subplot(212);  hold off
   plot(t*1000,3000*s);
   set(gca,'xlim',[0 1000*max(t)],'ylim',[0 250]);
   xlabel('time [ms]');
   ylabel('3*sigma [nm]');
   sigma = 1000*s(end);                % sigma [nm]
   title(sprintf('Progress of Uncertainty - Final: %gnm @ 3s',round(sigma)));
end
function o = KalmanAnalysis(o)         % Analysis of Kalman Filter     
   oo = current(o);                    % get current object
   E = cook(oo,'e','overlay');
   P = cook(oo,'p','overlay');
   T = cook(oo,'t','overlay');
   t = T(1,:);
   
   oo = smart(oo,'t, e#2, p#2, x#1, y#1, s#1');
   oo = subplot(oo,'Layout',2);
   oo = opt(oo,'xscale',1000);         % display in ms
   plot(oo,'Overlay');
   
   sig3 = 1000 * mean(P(:,end));       % 3*sigma [nm]
   subplot(122);
   title(sprintf('Progress of Uncertainty - Final: %gnm @ 3s',round(sig3)));
end