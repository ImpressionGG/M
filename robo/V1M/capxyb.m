function capxyb(D,specs,limits,colors)
%
% CAPXYB    Capability analysis of a x/y-vector set (ball plot). 
%
%              capxyb(D,specs,limits,{'g','b'})
%              capxyb(D)                           % specs = [-10,10]
%
%           where:
%              specs,limits: [low,high] or [xlow,xhigh;ylow,yhigh]]
%
   
   if ( nargin < 2 )
      specs = 10;
   end
   if ( nargin < 3 ) 
      limits = max(max(abs(specs)));
   end
   
   if nargin < 4
      colors = {'g','b'};
   end
   
   if (length(specs) == 0) specs = 10; end
   if (length(specs) == 1) specs = [-abs(specs),abs(specs)]; end
   if (size(specs,2) == 2) specs = [specs ones(size(specs,1),1)]; end
   if (size(specs,1) == 1) specs = [specs;specs];  end

   Cpk = specs(:,3);
   
   
   if (size(limits,2) == 1) limits = [-abs(limits),abs(limits)]; end
   if (size(limits,1) == 1) limits = [limits;limits];  end
 
   sigma = (specs(:,2) - specs(:,1))/6;

   hold off
   
   vplt(D,[colors{2},'o']);
   hold on;
   
   d = specs(:,2)-specs(:,1);
   m = (specs(:,2)+specs(:,1))/2;
   v = (specs(:,2)+specs(:,1))/2 - d/2;
   
   devs = devi(D);
   mx = devs(2);
   my = devs(3);
   st = devs(5);
   sx = devs(6);
   sy = devs(7);
   rt = devs(13);
   rx = devs(14);
   ry = devs(15);
   
   x = D(1,:);  
   y = D(2,:); 
   dx = x - m(1);  
   dy = y - m(2); 
   dr = sqrt(dx.*dx+dy.*dy);
   bt = max(dr);
   
   lx = min(x);
   ly = min(y);
   ux = max(x);
   uy = max(y);
   
   dmx = mx-m(1);
   dmy = my-m(2);
   dminx = min(dx); 
   dmaxx = max(dx); 
   dminy = min(dy); 
   dmaxy = max(dy); 
   
   if (sx==0) 
      cpx = inf; cpkx = inf; 
   else  
      cpx = sigma(1)/sx;  cpkx = (3*sigma(1)-abs(dmx)) / (3*sx);
   end
   if (sy==0) 
      cpy = inf; cpky = inf; 
   else  
      cpy = sigma(2)/sy;  cpky = (3*sigma(2)-abs(dmy)) / (3*sy);
   end
   
   cap = (cpkx >= Cpk(1) & cpky >= Cpk(2));  % machine is capable
   
%
% begin graphics
%

% start with the blue ellipses

   hdl = vplt(vmove(vcirc([sx sy]),mx,my),colors{2});
   set(hdl,'linewidth',3);
   
   hdl = vplt(vmove(vcirc(3*[sx sy]),mx,my),colors{2});
   set(hdl,'linewidth',3);
   
   hdl = vplt(vmove(vcirc(3*[Cpk(1)*sx,Cpk(2)*sy]),mx,my),colors{2});
   set(hdl,'linewidth',3);
   
% continue with the green ellipses
   
   hdl = vplt(vmove(vcirc(sigma./Cpk),m(1),m(2)),colors{1});   % circle/ellipse of reference (sigma)
   set(hdl,'linewidth',3);
   
   %hdl = vplt(vmove(vcirc(bt),m(1),m(2)),colors{2});   % circle/ellipse of reference (sigma)
   hdl = vplt(vmove(vrect(rx,ry),lx,ly),colors{2});   % circle/ellipse of reference (sigma)
   set(hdl,'linewidth',1);
   
   hdl = vplt(vmove(vrect(d(1),d(2)),v(1),v(2)),colors{1}); % rectangle of reference (3*sigma)
   set(hdl,'linewidth',3);

   
   if ( nargin >= 3 )   % set x- and y-limits
      set(gca,'xlim',limits(1,:));
      set(gca,'ylim',limits(2,:));
   end
   
   aspect
   set(gca,'ydir','reverse')
   set(gca,'fontsize',8)
   shg
   
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   
   plot(xlim,[m(2) m(2)],colors{1});
   plot([m(1) m(1)],ylim,colors{1});
         
   plot(xlim,my*[1 1],colors{2});
   plot(mx*[1 1],ylim,colors{2});
   
   hdl = vplt(vmove(vrect(rx,ry),lx,ly),colors{2});   % circle/ellipse of reference (sigma)
   set(hdl,'linewidth',1);  % once again
   
   hax = gca;
   set(gca,'position',[0.05 0.1 0.8 0.8]);shg
   
   dmx = round(10*dmx)/10;
   dmy = round(10*dmy)/10;
   st = round(10*st)/10;
   sx = round(10*sx)/10;
   sy = round(10*sy)/10;
   bt = round(10*bt)/10;    % maximum radial distance
   dminx = round(10*dminx)/10;
   dminy = round(10*dminy)/10;
   dmaxx = round(10*dmaxx)/10;
   dmaxy = round(10*dmaxy)/10;
   rt = round(10*rt)/10;
   rx = round(10*rx)/10;
   ry = round(10*ry)/10;
   cpx  = round(100*cpx)/100;
   cpy  = round(100*cpy)/100;
   cpkx = round(100*cpkx)/100;
   cpky = round(100*cpky)/100;
   
   txt0 = 'Specs x/y:';
   txt1 = sprintf('MIN:  %g / %g',specs(1,1),specs(2,1));
   txt2 = sprintf('MAX:  %g / %g',specs(1,2),specs(2,2));
   txt3 = sprintf('Cpk:  %g / %g',round(100*specs(1,3))/100,round(100*specs(2,3))/100);
   
   txt4 = 'Deviations x/y:';
   txt5 = sprintf('MEAN: %g / %g',dmx,dmy);
   txt6 = sprintf('SDEV: %g / %g',sx,sy);
   txt7 = sprintf('MIN:  %g / %g',dminx,dminy);
   txt8 = sprintf('MAX:  %g / %g',dmaxx,dmaxy);
   txt9 = sprintf('RANG: %g / %g',rx,ry);
   
   txt10 = 'Capability x/y:';
   txt11 = sprintf('Cp:  %g / %g',cpx,cpy);
   txt12 = sprintf('Cpk: %g / %g',cpkx,cpky);
   
   if (cap) 
      txt13 = 'capable: YES!';
   else
      txt13 = 'capable: NO!';
   end
   
   axes('position',[0.8,0.1,0.2,0.8]);
   h = plot(0,0,'o');             % plot single ball to avoid warning
   set(h,'visible','off');
   set(gca,'fontsize',8)
   textbox(txt0,'',txt1,txt2,txt3,'',txt4,'',txt5,txt6,txt7,txt8,txt9,'',txt10,'',txt11,txt12,'',txt13,1);
   set(gca,'visible','off');

   axes(hax);
   title('X/Y Capability Analysis');
   
% eof
   