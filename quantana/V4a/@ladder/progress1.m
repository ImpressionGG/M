function [nt,col,u,mode] = progress(obj,n,t)
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
   T = (nmax-nmin)*(trans+dwell);
   epsi = 1e-12;
   
      % calculate periode
      
      
   deltan = n - nmin;                 % delta n
   nint = floor(deltan);
   nfrac = deltan - floor(deltan);
   t0 = nint * (trans+dwell) + nfrac*trans;

   for (k=1:length(t))
      tk = t(k) + t0;           % relative time
      ntk = floor(tk/(trans+dwell));

      dt = tk - ntk*(trans+dwell);
      u(k) = 2*dt/(trans+dwell) - 1;
      dn = max(0,min(1,(dt-dwell/2)/trans));
      ntk = ntk + dn;

      if (mode == 1)
         nt(k) = nmin + ntk;
         if (nt(k) > nmax)
            u(k) = -1;
         end
      elseif (mode == -1)
         nt(k) = nmax - ntk;
         if (nt(k) < nmin)
            u(k) = -1;
         end
      elseif (mode == 0)
         tk = t(k) + t0 + 2*T - dwell/2;           % relative time
         ntk = floor(tk/(trans+dwell));
         
         dt = tk - ntk*(trans+dwell);
         dn = min(1,dt/trans);
         ntk = ntk + dn;
         
         ntk = rem(ntk-epsi,(nmax-nmin)) + epsi;
         phase = floor((tk-epsi)/T);
         if (rem(phase,2) == 0)
            nt(k) = nmin + ntk;
            mode = 1;
         else
            nt(k) = nmax - ntk;
            mode = 0;
         end
      else
         error('bad mode!');
      end
      nt(k) = max(nmin,min(nt(k),nmax));  % saturate
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
   