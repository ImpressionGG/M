function oo = heun(o,tmax,dt)
%
% HEUN  Solve ordinary differential equation, using HEUN algorithm
%
%          oo = heun(o)
%          oo = heun(o,tmax)
%          oo = heun(o,tmax,dt)
%          oo = heun(o,tmax,[dt,dplot])
%
%       See also: CUT, HOGA1, HOGA2, SODE
%
   p = get(o,'parameter');
  
   if (nargin < 2)
      tmax = get(o,'simu.tmax');
   end
   if (nargin < 3)
      dt = get(o,'simu.dt');
   end

   f = get(o,'model');         % model function
   x = f(o,0);                 % initial state   
   
   t = 0;
   dplot = dt(gluon.iif(length(dt)>=3,3,1));
   dt = dt(min(2,length(dt)));
      
   X = x; T = t;               % init result vectors
   
   i = 0
   tplot = min(t+dplot,tmax);
   while (1)
      tn = min(t+dt,tplot);    % next discrete time
      delta = (tn - t);        % integration time interval

      dx_dt = f(o,x,t);        % initial state derivative
      tm = t + delta/2;        % intermediate time
      xm = x + dx_dt*delta/2;  % intermediate state
      
      dxm_dt = f(o,xm,tm);     % intermediate state derivative
      t = tn;                  % progressed time 
      x = x + dxm_dt*delta;    % progressed state
      
      i = i+1;                 % verbose index
      if (rem(i,1000) == 0)
         fprintf('t = %g\n',t) % verbose talking
      end
      
      if (t == tplot)
         X(:,end+1) = x;       % data recording
         T(end+1) = t;         % time recording
         if (t >= tmax)
            break
         else
            tplot = min(t+dplot,tmax);
         end
      end
   end
   
   oo = o;
   oo.dat.t = T;
   oo.dat.x = X;
   oo.dat.s = 0*T;             % system indicator
   
   oo = var(oo,'plot',get(oo,'simu.plot'));
   oo = var(oo,'kind','x');
end
