function gana(K,E,kind,specs,xlim,ylim)
%
% GANA      Graphical analysis of a drift vector set with optimal 
%           affine compensation.
%
%              gana(K,E,kind,specs,[xlow xhigh],[ylow yhigh])
%              gana(K,E,kind)     % specs = [-10,10]
%              gana(K,E)          % kind = 1: affine map
%              gana(K,E,kind,xy)  % xlow = ylow = -xy, xhigh = yhigh = xy
%
%              gana([],E,kind,specs,[xlow xhigh],[ylow yhigh])  % omit mapping analysis
%
%           where
%
%              K     ... vector set with calibration points (calibration coordinate System)
%              E     ... vector set of errors
%              kind  ... kind of approximation (see map, nlmap)
%              xlow  ... fixed value for xlow of axes
%              xhigh ... fixed value for xhigh of axes
%              ylow  ... fixed value for ylow of axes
%              yhigh ... fixed value for yhigh of axes
%              specs ... lower-upper bound specs
%
   if ( nargin < 3 ) kind = 1; end
   if ( nargin < 4 )
      specs = 10;
   end
   
   if isempty(specs) specs = 10; end
   
   if ( nargin >= 5 ) 
      if (nargin == 5)
         if ( length(xlim) == 1 )
            ylim = [-abs(xlim) abs(xlim)];
            xlim = ylim;
         else
            error('both x- and y-limits expected!'); 
         end
      end
   end
   
   
   hold off
   
   vplt(E,'bo');
   hold on;
   
   devs = devi(E);
   meane = devs(1);  meanx = devs(2);  meany = devs(3);
   stde = devs(5);   stdx = devs(6);   stdy = devs(7);
   minx = min(E(1,:));  maxx = max(E(1,:));
   miny = min(E(2,:));  maxy = max(E(2,:));
   
   maxr = devs(9);
   hdl = vplt(vmove(vcirc([stdx stdy]),meanx,meany),'b');
   set(hdl,'linewidth',3);
   
   hdl = vplt(vmove(vcirc(3*[stdx stdy]),meanx,meany),'b');
   %hdl = vplt(vcirc(maxr),'b');
   set(hdl,'linewidth',3);
   plot([minx maxx maxx minx minx],[miny miny maxy maxy miny],'b');
   
   if ~isempty(K)
      C = map(K,E,kind);          % calculate map
      Er = E-map(C,K);            % residual error
      vplt(Er,'ro');   % plot result of residual error
   end
   
   if length(specs) == 1
      sigma = specs / 3;
   elseif length(specs) == 2
      sigma = (specs(2) - specs(1)) / 6;
   else
      error('specs');
   end
   
   hdl = vplt(vcirc(sigma),'g');   % circle of reference (sigma)
   set(hdl,'linewidth',3);
   
   %hdl = vplt(vcirc(3*sigma),'g'); % circle of reference (3*sigma)
   hdl = plot(3*sigma*[-1 1 1 -1 -1],3*sigma*[-1 -1 1 1 -1],'g'); % rectangle of reference (3*sigma)
   set(hdl,'linewidth',3);

   if ~isempty(K)
      devs = devi(Er);  meane1 = devs(1); meanx1 = devs(2);  meany1 = devs(3);  stde1 = devs(5);
      stdx1 = devs(6);   stdy1 = devs(7);
      minx1 = min(Er(1,:));  maxx1 = max(Er(1,:));
      miny1 = min(Er(2,:));  maxy1 = max(Er(2,:));
      
      hdl = vplt(vmove(vcirc([stdx1 stdy1]),meanx1,meany1),'m');
      set(hdl,'linewidth',3);
      hdl = vplt(vmove(vcirc(3*[stdx1 stdy1]),meanx1,meany1),'m');
      set(hdl,'linewidth',3);
      plot([minx1 maxx1 maxx1 minx1 minx1],[miny1 miny1 maxy1 maxy1 miny1],'m');
   end
   
   D = 10;  % eine Dezimalstelle nach dem Komma anzeigen!
   
   if isempty(K)
%      xlabel(sprintf('mean = %g (%g/%g), sigma: %g',round(meane*D)/D,round(meanx*D)/D,round(meany*D)/D,round(stde*D)/D))
   else
%      xlabel(sprintf('mean = %g (%g/%g) -> %g (%g/%g), sigma: %g -> %g',round(meane*D)/D,round(meanx*D)/D,round(meany*D)/D,round(meane1*D)/D,round(meanx1*D)/D,round(meany1*D)/D,round(stde*D)/D,round(stde1*D)/D))
   end
   
   if ~isempty(K)
      CC = map(K,K-E,1);  % affine map
      [SS,KK,RR] = skr(CC(1:2,1:2));
      phi = angle(RR(1,1)+sqrt(-1)*RR(2,1));
      s = SS(1,2);
      kx = KK(1,1);
      ky = KK(2,2);
   
      kxp = (kx-1)*100000;   % prozentuale Aenderung der Skalierung x (mu/100mm)
      kyp = (ky-1)*100000;   % prozentuale Aenderung der Skalierung y  
   
      sp = s; ex = 1;
      while (abs(sp) < 1) sp = sp*10; ex = ex/10; end; sp = round(sp*100)/100*ex;
   
      pp = phi/deg; ex = 1;
      while (abs(pp) < 1) pp = pp*10; ex = ex/10; end; pp = round(pp*100)/100*ex;
   
%      ylabel(sprintf('scale: %g/%g, rot: %g, shear: %g',round(kxp*10)/10,round(kyp*10)/10,pp,sp))
   end
   
   if ( nargin >= 5 )   % set x- and y-limits
      set(gca,'xlim',xlim);
      set(gca,'ylim',ylim);
   end
   
   aspect
   set(gca,'ydir','reverse')
   set(gca,'fontsize',8)
   shg
   
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   
   plot(xlim,[0 0],'g');
   plot([0 0],ylim,'g');
         
   plot(xlim,meany*[1 1],'b');
   plot(meanx*[1 1],ylim,'b');
   
   if ~isempty(K)
      plot(xlim,meany1*[1 1],'r');
      plot(meanx1*[1 1],ylim,'r');
   end
   
   hax = gca;
   if (1)
      devs = devi(E);
      mt = devs(1);
      mx = devs(2);
      my = devs(3);
      st = devs(5);
      sx = devs(6);
      sy = devs(7);
      tt = devs(9);    % maximum radial distance
      rt = devs(13);
      rx = devs(14);
      ry = devs(15);
      if (sx==0) 
         cpx = inf; cpkx = inf; 
      else  
         cpx = sigma/sx;  cpkx = (3*sigma-abs(mx)) / (3*sx);
      end
      if (sy==0) 
         cpy = inf; cpky = inf; 
      else  
         cpy = sigma/sy;  cpky = (3*sigma-abs(my)) / (3*sy);
      end
      %cpx,cpkx,cpy,cpky
      if (st==0) 
         cp = inf; cpk = inf; 
      else  
         cp = sigma/st;  cpk = (3*sigma-mt) / (3*st);
      end
      cpk = round(100*cpk)/100;
      cp  = round(100*cp)/100;
      cpkx = round(100*cpkx)/100;
      cpx  = round(100*cpx)/100;
      cpky = round(100*cpky)/100;
      cpy  = round(100*cpy)/100;
      mt = round(10*mt)/10;
      mx = round(10*mx)/10;
      my = round(10*my)/10;
      st = round(10*st)/10;
      sx = round(10*sx)/10;
      sy = round(10*sy)/10;
      tt = round(10*tt)/10;    % maximum radial distance
      rt = round(10*rt)/10;
      rx = round(10*rx)/10;
      ry = round(10*ry)/10;
   
      txt0 = 'Deviations:';
      txt1 = sprintf('MX: %g µm',mx);
      txt2 = sprintf('MY: %g µm',my);
      txt3 = sprintf('SX: %g µm',sx);
      txt4 = sprintf('SY: %g µm',sy);
      txt5 = sprintf('RX: %g µm',rx);
      txt6 = sprintf('RY: %g µm',ry);
      
      txt7 = 'Capability';
      txt8 = sprintf('CpX:  %g',cpx);
      txt9 = sprintf('CpY:  %g',cpy);
      txt10 = sprintf('CpkX:  %g',cpkx);
      txt11 = sprintf('CpkY:  %g',cpky);

      axes('position',[0.01,0.1,0.15,0.75]);
      h = plot(0,0,'o');             % plot single ball to avoid warning
      set(h,'visible','off');
      set(gca,'fontsize',8)
      textbox(txt0,'',txt1,txt2,txt3,txt4,txt5,txt6,'',txt7,'',txt8,txt9,'',txt10,txt11,1);
      set(gca,'visible','off');

      if ~isempty(K)
         [R,T] = resi(K,K+E,kind);           % residual drift
         devs = devi(R);
         mt = devs(1);
         mx = devs(2);
         my = devs(3);
         st = devs(5);
         sx = devs(6);
         sy = devs(7);
         tt = devs(9);    % maximum radial distance
         rt = devs(13);
         rx = devs(14);
         ry = devs(15);
         if (sx==0) 
            cpx = inf; cpkx = inf; 
         else  
            cpx = sigma/sx;  cpkx = (3*sigma-abs(mx)) / (3*sx);
         end
         if (sy==0) 
            cpy = inf; cpky = inf; 
         else  
            cpy = sigma/sy;  cpky = (3*sigma-abs(my)) / (3*sy);
         end
         if (st==0) 
            cp = inf; cpk = inf; 
         else  
            cp = sigma/st;  cpk = (3*sigma-mt) / (3*st);
         end
         cpk = round(100*cpk)/100;
         cp  = round(100*cp)/100;
         cpkx = round(100*cpkx)/100;
         cpx  = round(100*cpx)/100;
         cpky = round(100*cpky)/100;
         cpy  = round(100*cpy)/100;
         mt = round(10*mt)/10;
         mx = round(10*mx)/10;
         my = round(10*my)/10;
         st = round(10*st)/10;
         sx = round(10*sx)/10;
         sy = round(10*sy)/10;
         tt = round(10*tt)/10;    % maximum radial distance
         rt = round(10*rt)/10;
         rx = round(10*rx)/10;
         ry = round(10*ry)/10;
         
         txt0 = 'Proposal:';
         txt1 = sprintf('MX: %g µm',mx);
         txt2 = sprintf('MY: %g µm',my);
         txt3 = sprintf('SX: %g µm',sx);
         txt4 = sprintf('SY: %g µm',sy);
         txt5 = sprintf('RX: %g µm',rx);
         txt6 = sprintf('RY: %g µm',ry);
         
         txt7 = 'Capability';
         txt8 = sprintf('CpX:  %g',cpx);
         txt9 = sprintf('CpY:  %g',cpy);
         txt10 = sprintf('CpkX:  %g',cpkx);
         txt11 = sprintf('CpkY:  %g',cpky);
         
         
         axes('position',[0.83,0.1,0.17,0.75]);
         h = plot(0,0,'o');             % plot single ball to avoid warning
         set(h,'visible','off');
         set(gca,'fontsize',8)
         textbox(txt0,'',txt1,txt2,txt3,txt4,txt5,txt6,'',txt7,'',txt8,txt9,'',txt10,txt11,1);
         set(gca,'visible','off');
      end
   end

   axes(hax);
   
% eof
   