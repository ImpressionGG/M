function nichols(o,L,sub)
%
% NICHOLS  Nichols plot for principal and critical spectrum
%
%           nichols(o,gamma0,sub);       % critical forward spectrum
%           nichols(o,gamma180,sub);     % critical backward spectrum
%
%           nichols(o,lambda0,sub);      % principal forward spectrum
%           nichols(o,lambda0,sub);      % principal backward spectrum
%
%        Copyright(c): Bluenetics 2021
%
%        See also: SPM, BODE, GAMMA, SPECTRUM, BODE, NYQUIST
%
   if (nargin < 3 || length(sub) < 1)
      sub = opt(o,{'subplot',111});
   end
   
      % now sub is proper!
      
   Nichols(o,L,sub);   
end

%==========================================================================
% Bode Plot
%==========================================================================

function Nichols(o,L,sub)
   frequency = opt(o,{'bode.frequency',0});
   bullets = opt(o,{'style.bullets',0});
   fac = o.iif(frequency,2*pi,1);

      % get spectral data
      
   [jdx,olim] = Olim(o,L);          % index of eventually closeup
   om = L.data.omega(jdx);
   name = get(L,'name');
   [Ljw,phi,i0,j0,K,f,tag] = var(L,'fqr,phi,i0,j0,K,f,tag');
%  l0 = lambda(o,L);   
   
      % setup colors and löinewidth
   
   [colors,colwk,col0] = Colors(o,L);
   linewidth = 1;
   
      % let's go      
      
   [o,hax] = subplot(o,sub);
   set(hax,'visible','on');

      % magnitude plots 1:m  

   for (i=1:size(Ljw,1))
      col = colors{1+rem(i-1,length(colors))};
      col = o.iif(bullets,o.iif(dark(o),'w','k'),col);
      
      hdl = plot(hax,phi(i,jdx)*180/pi,20*log10(abs(Ljw(i,jdx))),colwk);
      set(hdl,'color',o.color(col),'linewidth',linewidth);
      
      if (bullets) % bullets
         col = colors{1+rem(i-1,length(colors))};
         hdl = plot(hax,phi(i,jdx)*180/pi,20*log10(abs(Ljw(i,jdx))),'c.');
         set(hdl,'color',o.color(col),'linewidth',linewidth);
      end
   end

      % critical magnitude

   [Ld,Lc] = lambda(o,L);
   [Lcjw,phic] = var(Lc,'fqr,phi');

   hdl = plot(hax,phic(jdx)*180/pi,20*log10(abs(Lcjw(jdx))),colwk);
   set(hdl,'color',o.color(col0), 'linewidth',2);

   if (bullets)
      hdl = plot(hax,phic(jdx)*180/pi,20*log10(abs(Lcjw(jdx))),'c.');
      set(hdl,'color',o.color([col0,'ww']));
   end
   
      % limit calculation seems complicated, but xlim has 
      % irelevant values when graphics is zoomed in

   plim = [min(phi(:)),max(phi(:))]*180/pi;
   xlim = get(gca,'xlim');
   xlim = [min(xlim(1),plim(1)), max(xlim(2),plim(2))];

      % limits

   Klim = o.iif(var(L,'critical'),K,1);
   limits(o,'Magni',Klim);

         % draw critical points

   phi0 = -180;
   while (phi0 >= xlim(1))
      phi0 = phi0 - 360;
   end
   for (phi = phi0+360:360:100*180)
      hdl = plot(phi,0,'p');
      if (phi==-180)
         set(hdl,'color','r', 'linewidth',1);
         plot(phi,0,'y.');
      else
         set(hdl,'color',o.iif(dark(o),'w','k'), 'linewidth',1);
      end
      if (phi+360>xlim(2))
         break;
      end
   end

      % Eigenvalue & Nyquist error

   L0 = cache(o,'critical.L0');
   everr = var(L0,['EVerr',tag]);
   nyqerr = var(L,'nyqerr');

      % labels

   title(sprintf('%s: Magnitude Plots - K%s: %g @ %g Hz (EV/Nyq error: %g/%g)',...
                 name,tag,K,f,everr,nyqerr));
   xlabel('Phase [deg]');
   ylabel(sprintf('|%s[k](jw)| [dB]',name));
   subplot(o);
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
