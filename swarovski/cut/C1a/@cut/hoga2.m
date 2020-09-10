function [out1,out2,out3] = hoga2(o,x,t)
%
% HOGA2  Hoffmann/Gaul system model, version 2
%
%        1) Nonliear system  description: dx/dt = f(x,t)
%
%            x0 = hoga2(o,[])       % initial state
%            f = hoga2(o,x,t)       % dx/dt = f(x,t)
%
%        2) Linear system description: dx/dt = A1*x+b, dx/dt = A2*x+b 
%
%            [A1,A2,b] = hoga1(o)   % linear systems: dx/dt = Ai*x+b
%
%        See also: CUT, HOGA2, HEUN, SODE
%
   p = o.par.parameter;      % access to parameters

   k11 = p.k11;              % [N/m]  stiffness kx
   k12 = p.k12;              % [N/m]  coupling stiffness k/2
   k21 = p.k21;              % [N/m]  coupling stiffness k/2
   k22 = p.k22;              % [N/m]  stiffness ky
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
      s = sign(1+sign(-x(2)));     % sigma(-uy)
      
      f = [
            x(3)
            x(4)
            [-c1*x(3) - k11*x(1) - k12*x(2) - mu*k22*x(2)*sign(1-x(3)/v)*s]/m
            [-c2*x(4) - k21*x(1) - k22*x(2) - Fn]/m
          ];
          
      out1 = f;   % copy to output arg
   elseif (nargin == 2)
      i = get(o,"init");
      x0 = [i.ux0; i.uy0; i.vx0; i.vy0];
      out1 = x0;    % copy to outarg
   else
      A1 = [     0        0        1      0
                 0        0        0      1
               [-k11 -k12-mu*k22  -c1     0 ]/m
               [-k21    -k22       0     -c2]/m
           ];

      A2 = [      0        0        1      0
                  0        0        0      1
               [-k11 -k12+mu*k22  -c1     0 ]/m
               [-k21    -k22       0     -c2]/m
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
