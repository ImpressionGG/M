function [out1,out2,out3] = hoga1(o,x,t)
%
% HOGA1  Hoffmann/Gaul system model, version 1
%
%        1) Nonliear system  description: dx/dt = f(x,t)
%
%            x0 = hoga1(o,[])       % initial state
%            f = hoga1(o,x,t)       % dx/dt = f(x,t)
%
%        2) Linear system description: dx/dt = A1*x+b, dx/dt = A2*x+b 
%
%            [A1,A2,b] = hoga1(o)   % linear systems: dx/dt = Ai*x+b
%
%        See also: CUT, HOGA2, HEUN, SODE
%
   p = o.par.parameter;      % access to parameters

   kx = p.kx;                % [N/m]  stiffness kx
   ky = p.ky;                % [N/m]  stiffness ky
   k  = p.k;                 % [N/m]  coupling stiffness k
   c1 = p.c1;                % [kg/s] damping c1 (1-1.2)
   c2 = p.c2;                % [kg/s] damping c2 (1-1.2)
   m  = p.m;                 % [kg]   mass
   Fn = p.Fn;                % [N]    normal force
   Sn = p.Sn;                % [N]    variation of normal force
   fn = p.fn;                % [N]    frequency of force variation
   mu = p.mu;                % [1]    friction coefficient(0-2)
   v  = p.v;                 % [m/s]  tae speed (1-5)

   if (nargin == 3)
      Fn = (Fn-Sn/2) + Sn/2*cos(2*pi*fn*t);

      kx = p.kx;             % [N/m]  stiffness kx
      ky = p.ky;             % [N/m]  stiffness ky
      k  = p.k;              % [N/m]  coupling stiffness k
      c1 = p.c1;             % [kg/s] damping c1 (1-1.2)
      c2 = p.c2;             % [kg/s] damping c2 (1-1.2)
      m  = p.m;              % [kg]   mass
      Fn = p.Fn;             % [N]    normal forceo.
      Sn = p.Sn;             % [N]    variation of normal force
      fn = p.fn;             % [N]    frequency of force variation
      mu = p.mu;             % [1]    friction coefficient(0-2)
      v  = p.v;              % [m/s]  tae speed (1-5)

      Fn = (Fn-Sn/2) + Sn/2*cos(2*pi*fn*t);
      
      f = [
             x(3)
             x(4)
             [-c1*x(3) - (kx+k/2)*x(1) + k/2*x(2) - mu*ky*x(2)*sign(1-x(3)/v)]/m
             [-c2*x(4) + k/2*x(1) - (ky+k/2)*x(2)  - Fn]/m
          ];
          
      out1 = f;   % copy to output arg
   elseif (nargin == 2)
      i = get(o,"init");
      x0 = [i.ux0; i.uy0; i.vx0; i.vy0];
      out1 = x0;    % copy to outarg
   else
      A1 = [      0        0        1      0
                  0        0        0      1
              [-(kx+k/2) k/2-mu*ky -c1     0 ]/m
              [k/2     -(ky+k/2)    0     -c2]/m
           ];

      A2 = [      0        0        1      0
                  0        0        0      1
              [-(kx+k/2) k/2+mu*ky -c1     0 ]/m
              [   k/2   -(ky+k/2)    0    -c2]/m 
           ];

      B = [0 0 0 -p.Fn/m]';
      
      if (nargout == 0)
         Show(o,A1,A2,B);
      else
         out1 = A1;  out2 = A2;  out3 = B;   % copy to out args
      end
   end
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
   fprintf("\nbT vector\n\n");
   disp(B');
end
