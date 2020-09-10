function [out1,out2,out3,out4] = shyp(o,x,t)
%
% SHYP  Schleifsaal Hypothesen  Modell
%
%        1) Nonliear system  description: dx/dt = f(x,t)
%
%            x0 = shyp(o,[])        % initial state
%            f = shyp(o,x,t)        % dx/dt = f(x,t)
%
%        2) Linear system description: 
%
%             dx/dt = A1*x+b        % mu = +mu0
%             dx/dt = A2*x+b        % mu = -mu0
%             dx/dt = A3*x+b        % mu = 0
%
%            [A1,A2,A3,b] = shyp(o) % linear systems: dx/dt = Ai*x+b
%
%        3) Parameter expansion
%
%            o = shyp(o)            % calculate params (from basic params)
%       
%        4) Sample setup
%
%            o = shyp(cut("demo")) 
%
%            o.par.basic.m = 0.5         % [kg]  oscillating mass
%            o.par.basic.k = 500e6       % [N/m] related (axial) stiffness
%            o.par.basic.kappa = 0.032   % [/]   coupling factor
%            o.par.basic.xi = 11.2       % [/]   related article x-stiffness
%            o.par.basic.eta = 15        % [/]   related article y-stiffness
%
%        See also: CUT, HOGA1, HOGA2, HEUN, SODE
%
   if (nargin == 1 &&  nargout <= 1)
      out1 = Expand(o);      % basic parameter expansion
      return
   end
   
   p = o.par.parameter;      % access to parameters

   k11 = p.k11;              % [N/m]  stiffness kx
   k12 = p.k12;              % [N/m]  coupling stiffness k/2
   k21 = p.k21;              % [N/m]  coupling stiffness k/2
   k22 = p.k22;              % [N/m]  stiffness ky
   
   c11 = p.c11;              % [kg/s] damping c11
   c12 = p.c12;              % [kg/s] damping c12
   c21 = p.c21;              % [kg/s] damping c21
   c22 = p.c22;              % [kg/s] damping c22
   
   m  = p.m;                 % [kg]   mass
   Fn = p.Fn;                % [N]    normal force
   Sn = p.Sn;                % [N]    variation of normal force
   fn = p.fn;                % [N]    frequency of force variation
   mu = p.mu;                % [1]    friction coefficient(0-2)
   v  = p.v;                 % [m/s]  tae speed (1-5)

   if (nargin == 3)
      Fn = (Fn-Sn/2) + Sn/2*cos(2*pi*fn*t);

      ux = x(1);  uy = x(2);  vx = x(3);  vy = x(4);
      
      sigma = sign(1+sign(uy));   % sigma(y)
      mu = p.mu*sign(v+vx)*(1-sigma);
      
      C = [p.c11 p.c12; p.c21 p.c22]/m;
      K = [p.k11 p.k12; p.k21 p.k22]/m;
      F = [0  mu*p.k22; 0     0    ]/m;
      I = eye(2);
      
      xu = x(1:2);
      xv = x(3:4);
      f = [ 0*I I; -(K-F) -C]*x;
          
      out1 = f;   % copy to output arg
   elseif (nargin == 2)
      i = get(o,"init");
      x0 = [i.ux0; i.uy0; i.vx0; i.vy0];
      out1 = x0;    % copy to outarg
   else
      A1 = [ 
              0*I,  I
             -K-F, -C
           ];

      A2 = [ 
              0*I,  I
             -K+F, -C
           ];

      A3 = [ 
              0*I,  I
              -K,  -C
           ];

      B = [0 0 0 -p.Fn/m]';
      
      if (nargout == 0)
         Show(o,A1,A2,A3,B);
      else
         out1 = A1;  out2 = A2;  out3 = A3; out4 = B;   % copy to out args
      end
   end
end

%===============================================================================
% Parameter Expansion
%===============================================================================

function oo = Expand(o)
%
% EXPAND   Expand basic parameters
%
   oo = Default(o);                    % occasionally provide default parameters
   
   b = get(oo,"basic");                % get basic parameters
   
   beta = b.beta*pi/180;               % cutting angle in radians
   
   T = [ cos(beta) -sin(beta); 
         sin(beta)  cos(beta)];

   p.ka = b.k;                         % axial stiffness
   p.kt = b.k*b.kappa;                 % transversal stiffness
   p.kx = b.k*b.xi;                    % article©s x-stiffness
   p.ky = b.k*b.eta;                   % article©s y-stiffness

   p.K = T*diag([p.ka,p.kt])*T' + diag([p.kx,p.ky]);
   
         % modes
      
   m.ft = sqrt(p.kt/b.m)/2/pi;         % [Hz]   transversal eigenfrequeny
   m.fa = sqrt(p.ka/b.m)/2/pi;         % [Hz]   axial eigenfrequeny
   m.f = sqrt(m.fa*m.ft);              % [Hz]   effective eigenfrequency
   m.om0 = 2*pi*m.f;                   % [1/s]  effective circular eigenfrequency
   m.D = 0.05;                         % [/]    Lehr©s damping measure
   m.c = 2*b.m*b.D*m.om0;              % [kg/s] damping parameter

   p.C = diag([m.c,m.c]);
   
   oo = set(oo,"modes",m); 
   oo = set(oo,"parameter",p); 
end

%===============================================================================
% Default Parameter Setup
%===============================================================================

function o = Default(o)
%
% DEFAULT   Occasionally expand default parameters
%
   if (~isempty(get(o,"basic")))       % basic parameters available?
      return
   end
   
   switch type(o)
      case "demo"
         o = DemoSetup(o);             % setup for SHYP demo
      otherwise
         o = DemoSetup(o);             % setup for 60mm crystal ball
   end
end

%===============================================================================
% Setup Object 
%===============================================================================

function oo = Setup(o,title,simu,basic,init)
   oo = type(o,"shyp");
   oo = set(oo,"title",title);
   oo = set(oo,"model",@shyp);         % Schleif-Hypothesen-Modell
   oo = set(oo,"simu",simu);
   oo = set(oo,"basic",basic);
   
   if (nargin >= 5)
      oo = set(oo,"init",init);
   else
      oo.par.init.ux0 = 0;             % [m]    initial elongation
      oo.par.init.uy0 = 0.01;          % [m]    initial elongation
      oo.par.init.vx0 = 0;             % [m/s]  initial velocity
      oo.par.init.vy0 = 0;             % [m/s]  initial velocity
   end
end

%===============================================================================
% Setup basic parameters for 
%===============================================================================

function o = DemoSetup(o)
%
% DEMOSETUP   Setup demo parameters
%
   title = "Schleifsaal-Hypothesen Demo";
   
      % simulation
     
   s.tmax = 0.005;           % max simulation time 
   s.dt = [2e-6,1e-7,2e-6];  % simulation time increment
   s.plot = 'Vx';            % plot mode

      % basic parameters
      
   b.k = 500e6;              % [N/m]  axial stiffness
   b.kappa = 0.032;          % [/]    coupling factor
   b.xi = 11.2;              % [/]    relative x-stiffness
   b.eta = 15;               % [/]    relative y-stiffness

   b.m = 0.5;                % [kg]   oscillating mass
   b.D = 0.05;               % [/]    Lehr©s damping measure

   b.beta = 90;              % [?]    cutting angle (Lagewinkel)
   
      % incorporate into object©s parameters
   
   o = Setup(o,title,s,b);   
end

%===============================================================================
% Auxillary Functions
%===============================================================================

function Show(o,A1,A2,B)
%
% SHOW   Show system matrices for linear system
%
   fprintf("A1 matrix (low velocity: vx < v)\n\n");
   disp(A1);
   fprintf("\nA2 matrix (high velocity: vx > v)\n\n");
   disp(A2);
   fprintf("\nA3 matrix (velocity: vx > v)\n\n");
   disp(A3);
   fprintf("\nbT vector\n\n");
   disp(B');
end

