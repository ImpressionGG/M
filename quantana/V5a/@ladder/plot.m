function plot(obj,n,t,vis)
%
% PLOT     Return actual values of ladder operator with progressing time
%
%                eob = envi(quantana,'harmonic','omega',1);
%                hob = quon(eob);
%
%                cre = ladder(eob,+1);   % creation operator
%                ani = ladder(eob,-1);   % anihilation operator
%                lob = ladder(eob,0);    % creation & anihilation operator
%
%                [t,dt] = timer(gao,0.1); 
%                while (control(gao))
%                   [nt,col,u] = progress(lob,n,t);
%                   [psi,E] = eig(hob,nt,t);
%                   wing(hob,zspace(hob),psi,col);
%                   plot(lob,n,t);
%                   [t,dt] = wait(gao);
%                end
%
%             See also: QUANTANA LADDER
%
   if (nargin < 4)
      vis = 1;
   end
   
   r = either(option(obj,'r'),1.2);

   dat = data(obj);
   z = dat.zspace;
   mode = dat.mode;
   
   X0 = dat.sphx;  Y0 = dat.sphy;  Z0 = dat.sphz;
   
   [nt,col,u] = progress(obj,n,t);
   x0 = 2*[min(z) + (max(z)-min(z)) * u];
   phi = u*3*pi;
   
   if (u < 0.01 || u > 0.99)
      r = 0;
   end
   
   x = cos(phi)*X0 - sin(phi)*Y0;
   y = sin(phi)*X0 + cos(phi)*Y0;
   hdl = surf(x0+r*x,r*y,r*Z0,'edgecolor','none');
   alpha(hdl,vis);
   update(gao,hdl);
   
   if (mode == 1)
      texture(dat.opcre,hdl);
   else
      texture(dat.opani,hdl);
   end
   
   return
   
% eof   