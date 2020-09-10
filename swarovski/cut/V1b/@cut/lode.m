function oo = lode(o,tmax,dt)
%
% SODE  Linear ordinary differential equation solver
%
%          oo = lode(o)
%          oo = lode(o,tmax)
%          oo = lode(o,tmax,dt)
%
%       See also: CUT, HOGA, HEUN, SODE
%
   p = get(o);
   
   if (nargin < 2)
      tmax = get(o,"tmax");
   end
   if (nargin < 3)
      dt = tmax/1000;
   end
   
   [A1,A2,b] = hoga(o);   % get linear system matrices
   
   t = 0:dt:tmax;

   x0 = inv(A1)*b;
   for (i=1:length(t))
      x1(:,i) = expm(A1*t(i))*x0;
   end

   x0 = inv(A2)*b;
   for (i=1:length(t))
      x2(:,i) = expm(A2*t(i))*x0;
   end
   
   oo = o;
   oo.dat.t = t;
   oo.dat.x1 = x1;
   oo.dat.x2 = x2;
   
   oo = var(oo,"show",get(oo,"show"));
   oo = var(oo,"kind","x1x2");
end
