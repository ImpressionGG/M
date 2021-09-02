function bode(o,L,sub,dominant)
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
   if (nargin < 4)
      dominant = 0;
   end
   if (nargin < 3 || length(sub) < 1)
      sub = [111 0];
   end
   if (length(sub) < 2)
      sub = [sub 0];
   end
   
      % now sub is proper!
      
   BodePlot(o,L,sub(1),sub(2),dominant);   
end

%==========================================================================
% Bode Plot
%==========================================================================

function BodePlot(o,L,sub1,sub2,dominant)
   frequency = opt(o,{'bode.frequency',0});
   fac = o.iif(frequency,2*pi,1);

      % get spectral data
      
   [jdx,olim] = Olim(o,L);          % index of eventually closeup
   om = L.data.omega(jdx);
   name = get(L,'name');
   [Ljw,phi,i0,j0,K,f,tag] = var(L,'fqr,phi,i0,j0,K,f,tag');
   l0 = lambda(o,L);   
   
      % setup colors and löinewidth
   
   [colors,colwk,col0] = Colors(o,L);
   linewidth = 1;
   
   if (sub1)
      MagnitudePlot(o,sub1);
   end

      % phase plot

   if (sub2)
      PhasePlot(o,sub2);
   end
   
   function MagnitudePlot(o,sub)                                       
      o = subplot(o,sub,'semilogx');
      hax = axes(o);
      set(gca,'visible','on');

         % magnitude plots 1:m  

      for (i=1:size(Ljw,1))
         col = colors{1+rem(i-1,length(colors))};
         hdl = plot(hax,om/fac,20*log10(abs(Ljw(i,jdx))),colwk);
         set(hdl,'color',o.color(col),'linewidth',linewidth);
      end
      
         % max magnitude
         
%     hdl = plot(hax,om/fac,20*log10(Lmax),colwk);
      if (dominant)
         fqr = var(l0,'fqr');
         hdl = plot(hax,om/fac,20*log10(abs(fqr(jdx))),colwk);
      else
         hdl = plot(hax,om/fac,20*log10(abs(Ljw(i0,jdx))),colwk);
      end
      set(hdl,'color',o.color(col0), 'linewidth',2);

         % limits
         
      Klim = o.iif(var(L,'critical'),K,1);
      limits(o,'Magni',Klim);

         % critical point
         
      hdl = plot(2*pi*f/fac*[1 1],get(gca,'ylim'),[colwk,'-.']);
      set(hdl,'linewidth',1);
      hdl = plot(2*pi*f/fac,-20*log10(K/Klim),[colwk,'o']);
      set(hdl,'linewidth',1);
               
         % Eigenvalue error
         
      L0 = cache(o,'critical.L0');
      everr = var(L0,['EVerr',tag]);
      
         % labels
         
      title(sprintf('%s: Magnitude Plots - K%s: %g @ %g Hz (EV error: %g)',...
                    name,tag,K,f,everr));
      xlabel(o.iif(frequency,'Frequency [Hz]','Omega [1/s]'));
      ylabel(sprintf('|%s[k](jw)| [dB]',name));
      subplot(o);
   end
   function PhasePlot(o,sub)                                           
      o = subplot(o,sub,'semilogx');
      hax = axes(o);
      set(gca,'visible','on');
      
         % phase plots 1:m
         
      plot(hax,om/fac,0*om-180,colwk);
      for (i=1:size(Ljw,1))
         col = colors{1+rem(i-1,length(colors))};
         hdl = plot(hax,om/fac,phi(i,jdx)*180/pi,colwk);
         set(hdl,'color',o.color(col),'linewidth',1);
      end

         % phase plot 0
        
      if (dominant)   
         phi0 = var(l0,'phi');
         hdl = plot(hax,om/fac,phi0(jdx)*180/pi,colwk);
      else
         hdl = plot(hax,om/fac,phi(i0,jdx)*180/pi,colwk);
      end
      set(hdl,'linewidth',2, 'color',o.color(col0));
   
         % critical point
         
      hdl = plot(hax,2*pi*f/fac*[1 1],get(gca,'ylim'),[colwk,'-.']);
      set(hdl,'linewidth',1);
      hdl = plot(hax,2*pi*f/fac,-180,[colwk,'o']);
      set(hdl,'linewidth',1);
      
         % Nyquist error
         
      nyqerr = var(L,'nyqerr');

         % labels
         
      subplot(o);  idle(o);  % give time to refresh graphics
      title(sprintf('%s: Phase Plots - K%s: %g @ %g Hz (Nyquist error: %g)',...
                    name,tag,K,f,nyqerr));
      xlabel(o.iif(frequency,'Frequency [Hz]','Omega [1/s]'));
      ylabel(sprintf('%s[k](jw): Phase [deg]',name));
   end
end

%==========================================================================
% Helper
%==========================================================================

function [colors,colwk,col0] = Colors(o,L)  % Setup Colors             
   if dark(o)
      colors = {'rk','gk','b','ck','mk'};
      colwk = 'w';
   else
      colors = {'rwww','gwww','bwww','cwww','mwww'};
      colwk = 'k';
   end
   col0 = get(L,{'color','kw'});
end
function [odx,olim] = Olim(o,L)             % Get Omega Limits         
   fc = var(L,'f');                         % critical frequency
   o = Closeup(o,fc);
   olim = [opt(o,'omega.low'), opt(o,'omega.high')];

   om = L.data.omega;
   olim = [max(olim(1),min(om)), min(olim(2),max(om))];
   odx = find(om >= olim(1) & om <= olim(2));
end
function o = Closeup(o,f0)                  % Set Closeup if Activated 
   o = with(o,{'bode','stability'});
   o = with(o,{'critical'});

   points = opt(o,{'omega.points',10000});
   closeup = opt(o,{'bode.closeup',0});

   if (closeup)
       points = max(points,500);
       o = opt(o,'omega.low',2*pi*f0/(1+closeup));
       o = opt(o,'omega.high',2*pi*f0*(1+closeup));
       o = opt(o,'omega.points',points);
   end
end
