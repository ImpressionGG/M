function [out1,out2,out3,out4] = cons2(o,x,t)
%
% CONS2  Constrained system model, version 2
%        y3 to be increased with a ramp dy3/dt = vs
%
%        1) Nonliear system  description: dx/dt = f(x,t)
%
%            x0 = cons1(o,[])       % initial state
%            f = cons1(o,x,t)       % dx/dt = f(x,t)
%
%        2) Linear system description: dx/dt = A1*x+b, dx/dt = A2*x+b 
%
%            [A1,A2,B,C] = cons1(o) % linear systems: dx/dt = Ai*x+b
%
%        See also: CUT, CONS1, CONS2, HOGA1, HOGA2, HEUN, SODE
%
   p = o.par.parameter;      % access to parameters

   Fn = p.Fn;                % [N]    normal force
   Sn = p.Sn;                % [N]    variation of normal force
   fn = p.fn;                % [1/s]  frequency of force variation
   mu = p.mu;                % [1]    friction coefficient(0-2)
   v  = p.v;                 % [m/s]  tape speed (1-5)
   vs = p.vs;                % [m/s]  seek velocity
   
   A = p.A;
   B = p.B;
   C = p.C;

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
      A = p.A;
      B = p.B;
      x0 = -inv(A)*B*p.Fn;
      out1 = x0;
   else
      A1 = p.A;
      A2 = p.A;
      B  = p.B;
      C  = p.C;
      
      if (nargout == 0)
         Show(o,A1,A2,B,C);
      else
         out1 = A1;  out2 = A2;  out3 = B;  out4 = C;  % copy to out args
      end
   end
end

%===============================================================================
% Auxillary Functions
%===============================================================================

function Show(o,A1,A2,B,C)
%
% SHOW   Show system matrices for linear system
%
   fprintf("A1 matrix (low velocity: vx < v)\n\n");
   disp(A1);
   fprintf("\nA2 matrix (high velocity: vx > v)\n\n");
   disp(A2);
   fprintf("\nB matrix\n\n");
   disp(B');
   fprintf("\nCX matrix\n\n");
   disp(B');
end
