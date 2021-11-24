function bode(o,L,sub)
%
% BODE   Bode plot for principal andcritical spectrum
%
%           bode(o,gamma0,[sub1 sub2]);   % magni & phase plot
%           bode(o,gamma180,[sub 0]);     % magnitude plot
%
%           bode(o,lambda0,[0 sub]);      % phase plot
%           bode(o,lambda0,sub);          % magnitude plot
%
%        Copyright(c): Bluenetics 2021
%
%        See also: SPM, GAMMA, SPECTRUM
%
   if (nargin < 3 || length(sub) < 1)
      sub = [111 0];
   end
   if (length(sub) < 2)
      sub = [sub 0];
   end
   
      % now sub is proper!
      
   BodePlot(o,L,sub(1),sub(2));   
end

%==========================================================================
% Bode Plot
%==========================================================================

function BodePlot(o,L,sub1,sub2,crit)
   frequency = opt(o,{'frequency',0});
   fac = o.iif(frequency,2*pi,1);

   om = L.data.omega;
   [Ljw,phi,i0,j0,K,f,tag] = var(L,'fqr,phi,i0,j0,K,f,tag');
   
   
   if dark(o)
      colors = {'rk','gk','b','ck','mk'};
      colwk = 'w';
   else
      colors = {'rwww','gwww','bwww','cwww','mwww'};
      colwk = 'k';
   end
   col0 = get(L,{'color','kw'});

   if (sub1)
      o = subplot(o,sub1,'semilogx');
      hax = axes(o);
      set(gca,'visible','on');

         % magnitude plots 1:m  

      for (i=1:size(Ljw,1))
         col = colors{1+rem(i-1,length(colors))};
         hdl = plot(hax,om/fac,20*log10(abs(Ljw(i,:))),colwk);
         set(hdl,'color',o.color(col));
      end
      
         % magnitude plot 0
         
      hdl = plot(hax,om/fac,20*log10(abs(Ljw(i0,:))),colwk);
      set(hdl,'color',o.color(col0), 'linewidth',2);
      
         % critical point
         
      hdl = plot(2*pi*f/fac*[1 1],get(gca,'ylim'),[colwk,'-.']);
      set(hdl,'linewidth',1);
      hdl = plot(2*pi*f/fac,-20*log10(1),[colwk,'o']);
      set(hdl,'linewidth',1);
      
         % labels
         
      name = get(L,'name');
      title(sprintf('%s: Magnitude Plots (K%s: %g @ %g Hz)',name,tag,K,f));
      xlabel(o.iif(frequency,'Frequency [Hz]','Omega [1/s]'));
      ylabel(sprintf('|%s[k](jw)| [dB]',name));
      subplot(o);
   end

      % phase plot

   if (sub2)
      o = subplot(o,sub2,'semilogx');
      hax = axes(o);
      set(gca,'visible','on');

         % phase plots 1:m
         
      plot(hax,om/fac,0*om-180,colwk);
      for (i=1:size(Ljw,1))
         col = colors{1+rem(i-1,length(colors))};
         hdl = plot(hax,om/fac,phi(i,:)*180/pi,colwk);
         set(hdl,'color',o.color(col));
      end

         % phase plot 0
         
      hdl = plot(hax,om/fac,phi(i0,:)*180/pi,colwk);
      set(hdl,'linewidth',2, 'color',o.color(col0));

         % critical point
         
      hdl = plot(hax,2*pi*f/fac*[1 1],get(gca,'ylim'),[colwk,'-.']);
      set(hdl,'linewidth',1);
      hdl = plot(hax,2*pi*f/fac,-180,[colwk,'o']);
      set(hdl,'linewidth',1);

         % labels
         
      subplot(o);  idle(o);  % give time to refresh graphics
      xlabel(o.iif(frequency,'Frequency [Hz]','Omega [1/s]'));
      ylabel(sprintf('%s[k](jw): Phase [deg]',name));
   end
end
