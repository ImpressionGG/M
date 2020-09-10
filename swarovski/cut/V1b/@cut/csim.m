function oo = csim(o,varargin)
%
% CSIM  constrained simulation
%
%          oo = csim(o,mode)
%          oo = csim(o,mode,tmax)
%          oo = csim(o,mode,tmax,dt)
%          oo = csim(o,mode,tmax,[dtmax,dtmin])
%
%       Examples for mode:
%
%          oo = csim(o,'Free')
%
%       Algorithm:
%
%          1) assume dx/dt = A*x + B*Fn
%
%          2) calculate equilibrium q:
%                 dx/dt = 0 = A*q + B*Fn  =>  q = -inv(A)*B*Fn
%
%          3) Linearize by setting: x(t) = q + z(t)
%                 z(0) = x(0) - q
%                 dz/dt = A*z, which is solved as z(t) = expm(A*t)*z(0)
%
%          4) calculate back:
%                 x(t) = q + z(t) ...
%
%       See also: CUT, HOGA, HEUN, SODE
%
   [gamma,o] = manage(o,varargin,@Free,@Constant,@Ramp);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Free System Simulation
%==========================================================================

function oo = Free(o)
   p = get(o,'parameter');
   vc = p.vc;                          % cutting speed
   vs = p.vs;                          % seek speed
   Fn = p.Fn;
   
   tmax = o.either(arg(o,1),get(o,'simu.tmax'));
   dt = o.either(arg(o,2),get(o,'simu.dt'));
   
      % get system matrices
 
   model = get(o,'model'); 
   [A,~,B,C] = model(o);               % get linear system matrices
   x0 = 0*A(:,1);

      % calculate equilibrium states
      
   q = -inv(A)*B(:,3)*Fn;              % equilibrium
 
      % prepare timing
      
   dtmin = dt(min(2,length(dt)));
   dtmax = dt(1);
   delta = dtmax;                      % default time increment

   t = 0:dt:tmax;
   z0 = x0 - q;                        % mind: x(t) = q + z(t)
   
   for (i=1:length(t))
      tau = t(i);
      z = expm(A*tau)*z0;
      x(:,i) = q + z;
      y(:,i) = C*x(:,i);
   end

   oo = o;
   oo.type = 'csim';
   oo.data.t = t;
   oo.data.x = x;
   oo.data.y = y;
end

%==========================================================================
% Simulation of Constant y3(t)
%==========================================================================

function oo = Constant(o)
   p = get(o,'parameter');
   vc = p.vc;                          % cutting speed
   vs = p.vs;                          % seek speed
   Fn = p.Fn;
   
   if (nargin < 2)
      tmax = get(o,'simu.tmax');
   end
   if (nargin < 3)
      dt = get(o,'simu.dt');
   end
   
      % get system matrices
 
   model = get(o,'model'); 
   [A,~,B,C] = model(o);               % get linear system matrices
   x0 = -inv(A)*B(:,3)*Fn;

      % calculate equilibrium states
      
   q = -inv(A)*B(:,3)*Fn;              % equilibrium
 
      % prepare timing
      
   dtmin = dt(min(2,length(dt)));
   dtmax = dt(1);
   delta = dtmax;                      % default time increment

   t = 0:dt:tmax;
   z0 = x0 - q;                        % mind: x(t) = q + z(t)
   
   for (i=1:length(t))
      tau = t(i);
      z = expm(A*tau)*z0;
      x(:,i) = q + z;
      y(:,i) = C*x(:,i);
   end

   oo = o;
   oo.type = 'csim';
   oo.data.t = t;
   oo.data.x = x;
   oo.data.y = y;
end

%==========================================================================
% Simulation of Ramping y3(t)
%==========================================================================

function oo = Ramp(o)
   p = get(o,'parameter');
   vc = p.vc;                          % cutting speed
   vs = p.vs;                          % seek speed
   Fn = p.Fn;
   
   if (nargin < 2)
      tmax = get(o,'simu.tmax');
   end
   if (nargin < 3)
      dt = get(o,'simu.dt');
   end
   
      % get system matrices
 
   model = get(o,'model'); 
   [A,~,B,C] = model(o);               % get linear system matrices
   
   b3 = B(:,3);
   c3 = C(3,:)';
   
   if (c3'*b3 == 0)
      C(3,25) = 1;
      C(3,end-1) = 0;    % fake
      C(3,end) = 0;      % fake
      c3 = C(3,:)';       % refresh c3
   end
   
   AA = A - b3*c3'/(c3'*b3)*A;
   
   x0 = 0*AA(:,1);

      % prepare timing
      
   dtmin = dt(min(2,length(dt)));
   dtmax = dt(1);
   delta = dtmax;                      % default time increment
   
   t = 0:dt:tmax;
   
   xi = x0;  t0 = t(1);
   y(:,1) = C*x0;
   
   for (i=2:length(t))
      ti = t(i-1);
      tm = ti+dt/2;
      
      F = (vs - c3'*A*xi) / (c3'*b3);
      f = A*xi + b3*F;
      
      xm = xi + f*dt/2;
      Fm = (vs - c3'*A*xm) / (c3'*b3);
      fm = A*xm + b3*Fm;
      
      xi = xi + fm*dt;
      x(:,i) = xi;
      y(:,i) = C*xi;
   end

   oo = o;
   oo.type = 'csim';
   oo.data.t = t;
   oo.data.x = x;
   oo.data.y = y;
end
