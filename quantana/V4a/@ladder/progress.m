function [nt,col,u] = progress(obj,n,t)
%
% PROGRESS    Return actual values of ladder operator with progressing time
%
%                eob = envi(quantana,'harmonic','omega',1);
%                hob = quon(eob);
%
%                cre = ladder(eob,+1);   % creation operator
%                ani = ladder(eob,-1);   % anihilation operator
%
%                [t,dt] = timer(gao,0.1); 
%                while (control(gao))
%                   [nt,col] = progress(lob,n,t);
%                   [psi,E] = eig(hob,nt,t);
%                   wing(hob,zspace(hob),psi,col);
%                   [t,dt] = wait(gao);
%                end
%
%             See also: QUANTANA LADDER
%
   dat = data(obj);
   mode = dat.mode;
   dwell = dat.dwell;
   trans = dat.trans;
   nmin = dat.nmin;
   nmax = dat.nmax;
   colors = dat.colors;
   epsi = 1e-12;
   
      % calculate periode
      
   T = dwell + trans;  % total time for progress      

   for (k=1:length(t))
      tk = t(k); 
      if (tk < dwell/2)
         u(k) = tk * epsi/(dwell/2);
      elseif (tk < T-dwell/2)
         u(k) = 0.5 + (tk - T/2) * (1-2*epsi)/(trans);
      else
         u(k) = 1 - (T-tk) * epsi/(dwell/2);
      end
      
      u(k) = max(0,min(u(k),1));
      nt(k) = n + mode*u(k);
      nt(k) = max(nmin,min(nt(k),nmax));
   end
   
   cidx = nt(1) - nmin;
   cidx1 = floor(cidx);  cidx2 = ceil(cidx);  lambda = cidx - cidx1;
   
   nc = length(colors);
   cidx1 = 1 + rem(nc+cidx1,nc); 
   cidx2 = 1 + rem(nc+cidx2,nc); 
   
   col1 = color(colors(cidx1));
   col2 = color(colors(cidx2));
   col = (1-lambda)*col1 + lambda*col2;
   return
   