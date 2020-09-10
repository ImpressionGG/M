function filtercpk(N)
%
% FILTERCPK   Demonstration of filter Cpk definition
%
%                filtercpk(n)    % n runs
%                filtercpk       % n = 1
%
   if (nargin == 0) N = 1; end
   
   clrscr
   t=0:0.5:100;
   w = randn(size(t));
   w = w/std(w);      % normalize to std = 1
   
   plot(t,0*t,'k');  hold on;
   for (k=1:length(t))
      plot(t(k)*[1 1],[0 w(k)],'g');
   end      
   plot(t,w,'go');
   
   set(gca,'ylim',[-4,4]);
   hdl = plot(t,0*t+3,'r',  t,0*t-3,'r');
   set(hdl,'linewidth',3);
   

   x = -4:0.05:4;
   sig = 1;  my = 0;  
   idx = find(my-3*sig <= x & x <= my+3*sig);
   g = 1/(2*pi*sig)*exp(-(x-my).^2/2/sig^2);

   X = my + [-3 0 3]*sig;
   G = 1/(2*pi*sig)*exp(-(X-my).^2/2/sig^2);
   
   ti = 70; K = 70;
   plot([ti ti],[-4 4],'k',  ti+K*g,x,'g');
   hdl = plot(ti+K*g(idx),x(idx),'g');
   set(hdl,'linewidth',3);
   hdl = plot([ti ti+max(K*g)],my*[1 1],'r',  ti+K*G,X,'ro');
   set(hdl,'linewidth',2);

   Cpk = [];  ticpk = [];
   for (k=1:N)
      sig = 0.3 + 0.03*randn;
      my = 0.5 + 0.1*randn;
      x0 = 1 + 0.1*randn;
      T1 = abs(10+randn);
      T2 = abs(10+randn);

      e0 = x0*exp(-t/T1);       % settling part of error
      e1 = -sig*1-exp(-t/T2);   % amplitude of noise
     
      e = my + e0 + e1.*randn(size(t));
      if (k <= 1)
         plot(t,e,'b',  t,e,'k.');
      end
      stde = std(e);  avg = mean(e);
      

      X = avg + [-3 0 3]*stde;
      idx = find(avg-3*stde <= x & x <= avg + 3*stde);

      g = 1/(2*pi*stde)*exp(-(x-avg).^2/2/stde^2);
      G = 1/(2*pi*stde)*exp(-(X-avg).^2/2/stde^2);
   
      ti = 45-k*30/(N+1); 
      K = 70;
      if (N <= 3)
         plot([ti ti],[-4 4],'k',  ti+K*g,x,'b');
      end
      hdl = plot(ti+K*g(idx),x(idx),'b');
      set(hdl,'linewidth',iif(N<=3,3,2));
      if (N <= 3)
         hdl = plot([ti ti+max(K*g)],avg*[1 1],'r');
         set(hdl,'linewidth',2);
      end
      hdl = plot(ti+K*G,X,'ro');
      set(hdl,'linewidth',2);
      
      cpk = (3 - abs(avg)) / (3*stde); 
      Cpk = [Cpk cpk];   ticpk = [ticpk ti];
   end   

   Avg = mean(Cpk);
   Sig = std(Cpk);
   Sigma = (Avg - 3*Sig)*3;

      % draw distribution of Cpk
      
   stde = Sig;  avg = Avg;

   X = avg + [-3 0 3]*stde;
   idx = find(avg-3*stde <= x & x <= avg + 3*stde);

   g = 1/(2*pi*stde)*exp(-(x-avg).^2/2/stde^2);
   G = 1/(2*pi*stde)*exp(-(X-avg).^2/2/stde^2);
   
   ti = 5; 
   K = 70;
   plot([ti ti],[-4 4],'k',  ti+K*g,x,'r');
   hdl = plot(ti+K*g(idx),x(idx),'r');
   set(hdl,'linewidth',3);
   hdl = plot([ti ti+max(K*g)],avg*[1 1],'r',  ti+K*G,X,'ro');
   set(hdl,'linewidth',2);
   
   hdl = plot(ticpk,Cpk,'r');
   set(hdl,'linewidth',4);
   hdl = plot(ticpk,Cpk,'r', ticpk,Cpk,'k');
   set(hdl,'linewidth',2);
   
   title('Demonstration of filter Cpk');
   ylabel('green: noise,   blue: error after filtering');
   if (N <= 1)
      xlabel(sprintf('Filter Cpk: %g',rd(cpk)));
   else
      xlabel(sprintf('Filter Cpk: Avg Cpk = %g, Least Cpk = %g,  Sigma = %g',rd(Avg),rd(Avg-3*Sig),rd(Sigma)));
   end
   shg
   
   return
   
%eof   