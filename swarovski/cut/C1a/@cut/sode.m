function oo = sode(o,tmax,dt)
%
% SODE  Solve ordinary differential equation
%
%          oo = sode(o)
%          oo = sode(o,tmax)
%          oo = sode(o,tmax,dt)
%          oo = sode(o,tmax,[dtmax,dtmin])
%
%       Algorithm:
%
%          1) assume either dx/dt = A1*x + b (for cT*x < v)
%                        or dx(dt = A2*x + b (for cT*x > v)
%
%          2) Start with cT*x < v, and calculate equilibrium q1:
%                 dx/dt = 0 = A1*q1 + b  =>  q1 = -inv(A1)*b
%
%          3) Linearize by setting: x = q1 + z1
%                 z1(t0) = x(t0) - q1
%                 dz1/dt = A1*z1, which is solved as z1(t) = expm(A1*t)*z1(0)
%
%          4) On condition cT*x(t1) = cT*(q1+z1(t1)) > v calculate back:
%                 x(t1) = q1 + z1(t1) ...
%
%          5) continue with cT*x > v, and calculate equilibrium q2:
%                 dx/dt = 0 = A2*q2 + b  =>  q2 = -inv(A2)*b
%
%          6) and linearize by setting: x = q2 + z2
%                 z2(t1) = x(t1) - q2
%                 dz2/dt = A2*z2, which is solved as z2(t) = expm(A2*t)*z2(0)
%
%          7) On condition cT*x(t2) = cT*(q2+z2(t2)) < v calculate back:
%                 x(t2) = q2 + z2(t2) ...
%
%          8) continue at 2)
%
%       See also: CUT, HOGA, HEUN
%
   p = get(o,'parameter');
   v = p.v;                  % tape velocity

   if (nargin < 2)
      tmax = get(o,'simu.tmax');
   end
   if (nargin < 3)
      dt = get(o,'simu.dt');
   end
   
      % get system matrices
 
   model = get(o,'model'); 
   [A1,A2,b] = model(o);               % get linear system matrices
   cT = [0 0 1 0];                     % cT*x picks x-velocity (vx)
   
      % calculate equilibrium states
      
   q1 = -inv(A1)*b;                    % equilibrium 1
   q2 = -inv(A2)*b;                    % equilibrium 2
 
      % prepare timing
      
   k = 1;  i = 1;                      % indices
   t(1) = 0;
   s(1) = 0;                           % system indicator: +1 or -1
   
      % initial state
      
   xk = model(o,0);                    % initial state
   x(:,k) = xk;                        % record initial state
   s(1) = 0;                           % system indicatoer
   
      % integration loop
      
   dtmin = dt(min(2,length(dt)));
   dtmax = dt(1);
   delta = dtmax;                      % default time increment
   
   while(1)
      told = t(i);
      i = i+1;

      while (1)
         delta = max(delta,dtmin);
         t(i) = told + delta;
         tau = t(i) - t(k);

         if (cT*xk < v)                % in low velocity case
            s(i) = +1;
            z1k = xk - q1;             % mind: x(t) = q1 + z1(t)
            z1 = expm(A1*tau)*z1k;
            xi = q1 + z1;
            if(cT*xi <= v)             % stay in low velocity case?
               delta = min(2*delta,dtmax);
               break
            else % (cT*xi > v)         % we did not stay!
               if (delta <= dtmin)
                  k = i;  xk = xi;     % from now: cT*xk > v
                  break                % break in order to record xi
               else
                  delta = delta/2;     % decrease actual time increment
               end                     % repeat with smaller increment
            end
         else % (cT*xk >= v)           % inhigh velocity case
            s(i) = -1;
            z2k = xk - q2;             % mind: x(t) = q2 + z2(t)
            z2 = expm(A2*tau)*z2k;
            xi = q2 + z2;
            if(cT*xi >= v)             % stay in high velocity case?
               delta = min(2*delta,dtmax);
               break
            else % (cT*xi < v)         % we did not stay!
               if (delta <= dtmin)
                  k = i; xk = xi;      % from now: cT*xk < v
                  break                % break in order to record xi
               else
                  delta = delta/2;     % decrease actual time increment
               end                     % repeat with smaller increment
            end
         end
      end
      x(:,i) = xi;                     % record state
     
         % progress time
         
      if (t(i) >= tmax)
         break
      else                             % prepare for next iteration
         t(i) = min(t(i-1)+delta, tmax);
      end
   end

   oo = o;
   oo.typ = 'sode';
   oo.dat.t = t;
   oo.dat.x = x;
   oo.dat.s = s;
   
   oo = var(oo,'plot',get(oo,'simu.plot'));
   oo = var(oo,'kind','x');
end
