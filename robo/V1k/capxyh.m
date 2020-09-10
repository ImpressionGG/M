function capxyh(D,specs,limits,colors)
%
% CAPXYH    Capability analysis of a x/y-vector set (histogram plot). 
%
%              capxyh(D,specs,limits,{'g','b'})
%              capxyh(D)                           % specs = [-10,10]
%
%           where:
%              specs:  [low,high,cpk] or [xlow,xhigh,cpk_x;ylow,yhigh,cpk_y]]
%              limits: [low,high] or [xlow,xhigh;ylow,yhigh]]
%
   
   if ( nargin < 2 )
      specs = 10;
   end
   if ( nargin < 3 ) 
      limits = max(max(abs(specs)));
   end
   
   if nargin < 4
      colors = {'r','b','k'};
   end
   
   if (length(specs) == 0) specs = 10; end
   if (length(specs) == 1) specs = [-abs(specs),abs(specs)]; end
   if (size(specs,2) == 2) specs = [specs ones(size(specs,1),1)]; end
   if (size(specs,1) == 1) specs = [specs;specs];  end

   Cpk = specs(:,3);
   
   if (length(limits) == 0) limits = max(max(abs(specs))); end
   if (size(limits,2) == 1) limits = [-abs(limits),abs(limits)]; end
   if (size(limits,1) == 1) limits = [limits;limits];  end
 
   sigma = (specs(:,2) - specs(:,1))/6;
   meanxy = (specs(:,2) + specs(:,1))/2;
   SX = sigma(1) / Cpk(1);
   SY = sigma(2) / Cpk(2);
   
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
% begin plot x
%
   limits(1,1) = min([limits(:,1)',min(x),min(y),mx-3*Cpk(1)*sx,my-3*Cpk(2)*sy]);
   limits(2,1) = limits(1,1);
   limits(1,2) = max([limits(:,2)',max(x),max(y),mx+3*Cpk(1)*sx,my+3*Cpk(2)*sy]);
   limits(2,2) = limits(1,2);
   
   subplot(211);
   set(gca,'position',[0.1 0.55 0.65 0.4]);shg
   hax = gca;
   
   set(gca,'xlim',limits(1,:));
   xlim = get(gca,'xlim');
   hold on;
   
   set(gca,'fontsize',8)
   ylabel('x-deviations')
   
   dx = (limits(1,2)-limits(1,1))/20;  %(X(length(X))-X(1))/length(X);
   x = limits(1,1):dx:limits(1,2);
   [N,X] = hist(D(1,:),x);
   N = N/sum(N)/dx;
   dx = dx*0.8;
   for (i=1:length(N))
      v = vmove(vrect(dx,N(i)),X(i)-dx/2,0);
      h = patch(v(1,:),v(2,:),colors{2});
      set(h,'edgecolor',colors{3})
   end
   x = xlim(1):(xlim(2)-xlim(1))/100:xlim(2);
   npdf = normpdf(x,mx,sx);
   h = plot(x,npdf,colors{1});
   set(h,'linewidth',3);
   
   h = plot([specs(1,1),mx-3*Cpk(1)*sx,mx+3*Cpk(1)*sx,specs(1,2)],max(npdf)*[0 1 1 0],colors{1});
   set(h,'linewidth',1);
   h = plot([mx-3*Cpk(1)*sx,mx-3*sx,mx-sx,mx,mx+sx,mx+3*sx,mx+3*Cpk(1)*sx],[max(npdf),normpdf(sx,0,sx)*[1 1],0,normpdf(sx,0,sx)*[1 1],max(npdf)],colors{1});
   set(h,'linewidth',1);
   %h = plot([0,mx],[0 max(npdf)],colors{1});
   shg
   
%
% begin plot y
%
   subplot(212);
   set(gca,'position',[0.1 0.1 0.65 0.4]);
   shg   
   set(gca,'xlim',limits(1,:));
   xlim = get(gca,'xlim');
   hold on;
   
   set(gca,'fontsize',8)
   ylabel('y-deviations')
   
   dx = (limits(2,2)-limits(2,1))/20;  %(X(length(X))-X(1))/length(X);
   x = limits(2,1):dx:limits(2,2);
   [N,X] = hist(D(2,:),x);
   dx = (X(length(X))-X(1))/length(X);
   N = N/sum(N)/dx;
   dx = dx*0.8;
   for (i=1:length(N))
      v = vmove(vrect(dx,N(i)),X(i)-dx/2,0);
      h = patch(v(1,:),v(2,:),colors{2});
      set(h,'edgecolor',colors{3})
   end
   x = xlim(1):(xlim(2)-xlim(1))/100:xlim(2);
   npdf = normpdf(x,my,sy);
   h = plot(x,npdf,colors{1});
   set(h,'linewidth',3);
   
   h = plot([specs(2,1),my-3*Cpk(2)*sy,my+3*Cpk(2)*sy,specs(2,2)],max(npdf)*[0 1 1 0],colors{1});
   set(h,'linewidth',1);
   h = plot([my-3*Cpk(2)*sy,my-3*sy,my-sy,my,my+sy,my+3*sy,my+3*Cpk(2)*sy],[max(npdf),normpdf(sy,0,sy)*[1 1],0,normpdf(sy,0,sy)*[1 1],max(npdf)],colors{1});
   set(h,'linewidth',1);
   %h = plot([0,my],[0 max(npdf)],colors{1});
   shg
   
%   set(gca,'position',[0.05 0.1 0.8 0.8]);shg
   
%
% add numerical results
%
   
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
   