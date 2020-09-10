function oo = uni(o,tag)
%
% UNI  University parameter setup for CUT object
%
%         o = uni(cut,"demo")   % generic demo setup
%         o = uni(cut,"60mm")   % 60mm crystal ball
%
%      See also: CUT, SIMU
%
   switch tag
   case "demo"
      oo = Demo(o);
   case "60mm"
      oo = Sixty(o);
   otherwise
      error("bad parameter setup selection (arg2)");
   end
end

%===============================================================================
% Compose a <cut: hoga> object with UNI setup
%===============================================================================

function oo = Compose1(title,model,simu,init,parameter)
   oo = cut("demo");
   oo = set(oo,"title",title);
   oo = set(oo,"model",model);   % Hoffmann/Gaul model, Vs.1
   oo = set(oo,"simu",simu);
   oo = set(oo,"init",init);
   oo = set(oo,"parameter",parameter);
end

function oo = Compose2(title,model,simu,init,rotation,modes,parameter)
   oo = cut("60mm");
   oo = set(oo,"title",title);
   oo = set(oo,"model",model);   % Hoffmann/Gaul model, Vs.2
   oo = set(oo,"simu",simu);
   oo = set(oo,"init",init);
   oo = set(oo,"rotation",rotation);
   oo = set(oo,"modes",modes);
   oo = set(oo,"parameter",parameter);
   oo = rotate(oo,rotation.beta);
end

%===============================================================================
% Demo Setup
%===============================================================================

function oo = Demo(o)
%
% DEMO  Nominal demo setup (according to UNI Innsbruck example)
%
   title = "UNI demo parameter set (see Table 3.1)";
   model = @hoga1;
   
      % simulation
      
   s.tmax = 1;               % max simulation time
   s.dt = [2e-3,1e-5,2e-3];  % simulation time interval
   s.plot = 'UxUyVxVy';      % plot mode

      % initial values
      
   i.ux0 = 0;                % [m]    initial elongation
   i.uy0 = 0.01;             % [m]    initial elongation
   i.vx0 = 0;                % [m/s]  initial velocity
   i.vy0 = 0;                % [m/s]  initial velocity
      
      % parameters
      
   p.kx = 100;               % [N/m]  stiffness kx
   p.ky = 100;               % [N/m]  stiffness ky
   p.k  = 100;               % [N/m]  coupling stiffness k
   p.c1 = 1;                 % [kg/s] damping c1 (1-1.2)
   p.c2 = 1;                 % [kg/s] damping c2 (1-1.2)
   p.m  = 0.1;               % [kg]   mass

   p.Fn = 10;                % [N]    normal force
   p.Sn =  0;                % [N]    variation of normal force
   p.fn =  5;                % [N]    frequency of force variation

   p.mu = 1;                 % [1]    friction coefficient (0-2)
   p.v  = 5;                 % [m/s]  tape velocity (1-5)

      % compose CUT object
      
   oo = Compose1(title,model,s,i,p); % compose a <cut: hoga1> object     
end

%===============================================================================
% 60mm Crystal Ball Setup
%===============================================================================

function oo = Sixty(o)
   title = "UNI parameter for 60mm crystal ball";
   model = @hoga2;

      % simulation
     
   s.tmax = 0.005;           % max simulation time 
   s.dt = [2e-6,1e-7,2e-6];  % simulation time increment
   s.plot = 'Vx';            % plot mode
   
      % initial state
      
   i.ux0 = 0;                % [m]    initial elongation
   i.uy0 = 0;                % [m]    initial elongation
   i.vx0 = 0;                % [m/s]  initial velocity
   i.vy0 = 0;                % [m/s]  initial velocity
   
      % rotation
      
   r.kt = 3.475e7;           % [N/m]  transversal stiffness
   r.ka = 2.164e9;           % [N/m]  axial stiffness
   r.beta = 75;              % [?]    rotation angle (Lage)
   
      % modes
      
   m.ft = 1063;              % [Hz]   transversal eigenfrequeny
   m.fa = 6485;              % [Hz]   axial eigenfrequeny
   m.f = sqrt(m.fa*m.ft);    % [Hz]   effective eigenfrequency
   m.om0 = 2*pi*m.f;         % [1/s]  effective circular eigenfrequency
   m.D = 0.05;               % Lehr©sches D?mpfungsmass
   m.m  = 1;                 % [kg]   mass
   m.c = 2*m.m*m.D*m.om0;    % [kg/s] D?mpfungsparameter
   
      % parameters
      
   p.k11 = nan;              % [N/m]  stiffness kx
   p.k12 = nan;              % [N/m]  coupling stiffness
   p.k21 = nan;              % [N/m]  coupling stiffness
   p.k22 = nan;              % [N/m]  stiffness ky
   p.c1 = m.c;               % [kg/s] damping c1 (1-1.2)
   p.c2 = m.c;               % [kg/s] damping c2 (1-1.2)
   p.m  = m.m;               % [kg]   mass

   p.Fn = 1000;              % [N]    normal force
   p.Sn =  0;                % [N]    variation of normal force
   p.fn =  5;                % [N]    frequency of force variation

   p.mu = 0.8;               % [1]    friction coefficient (0-2)
   p.v  = 5;                 % [m/s]  tape velocity (1-5)
   
      % compose CUT object
      
   oo = Compose2(title,model,s,i,r,m,p); % compose a <cut: hoga2> object     
end

%===============================================================================
% Shyp 60mm Crystal Ball Setup
%===============================================================================

function oo = Shyp(o)
   title = "Schleifsaal Hypothese for 60mm crystal ball";
   model = @shyp;

      % simulation
     
   s.tmax = 0.005;           % max simulation time 
   s.dt = [2e-6,1e-7,2e-6];  % simulation time increment
   s.plot = 'Vx';            % plot mode
   
      % initial state
      
   i.ux0 = 0;                % [m]    initial elongation
   i.uy0 = 0;                % [m]    initial elongation
   i.vx0 = 0;                % [m/s]  initial velocity
   i.vy0 = 0;                % [m/s]  initial velocity
   
      % basic parameters

   b.k = 500e6;              % [N/m]  axial stiffness
   b.kappa = 16e6/b.k;       % [/]    coupling factor
   b.xi = 5600/b.k;          % [/]    relative x-stiffness
   b.eta = 7500/b.k;         % [/]    relative y-stiffness
   m.D = 0.05;               % [/]    Lehr©sches D?mpfungsmass
   
      % rotation
      
   r.ka = 2.164e9;           % [N/m]  axial stiffness
   r.kt = 3.475e7;           % [N/m]  transversal stiffness
   r.beta = 75;              % [?]    rotation angle (Lage)
   
      % modes
      
   m.fa = NaN;               % [Hz]   axial eigenfrequeny
   m.ft = NaN;               % [Hz]   transversal eigenfrequeny
   m.f = sqrt(m.fa*m.ft);    % [Hz]   effective eigenfrequency
   m.om0 = 2*pi*m.f;         % [1/s]  effective circular eigenfrequency
   m.c = 2*b.m*b.D*m.om0;    % [kg/s] damping parameter
   
      % parameters
      
   p.C = nan*eye(2);         % [N/m]  damping coefficients
   p.K = nan*eye(2);         % [N/m]  stiffness coefficients
   p.m  = b.m;               % [kg]   mass

   p.Fn = 1000;              % [N]    normal force
   p.Sn =  0;                % [N]    variation of normal force
   p.fn =  5;                % [N]    frequency of force variation

   p.mu = 0.8;               % [1]    friction coefficient (0-2)
   p.v  = 5;                 % [m/s]  tape velocity (1-5)
   
      % compose CUT object
      
   oo = Compose3(title,model,s,i,r,m,p); % compose a <cut: shyp> object     
end

