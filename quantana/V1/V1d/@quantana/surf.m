function obj = surf(obj,x,y,psi)
%
% SURF      Surface plot. Destroys previous surface plot (handle
%           is stored in object.
%
%              obj = quantana;
%              obj = surf(obj,psi)
%              obj = surf(obj,x,y,psi)
%
%           See also: QUANTANA, CMAP
%
   hdls = get(obj,'surf.hdls');
   hdlp = get(obj,'surf.hdlp');

   if (nargin <= 2)
       psi = x;
   end
   
   C = cindex(obj,psi);

   delete(hdls);
   if (nargin >= 4)
      hdls = surf(x,y,abs(psi),C,'EdgeColor','none');
      set(gca,'xlim',[min(x) max(x)],'ylim',[min(y) max(y)]);
   else
      hdls = surf(abs(psi),C,'EdgeColor','none');
   end
   
   set(gca,'xgrid','off','ygrid','off','box','off');
   set(gca,'xtick',[],'ytick',[],'ztick',[]);

   xlim = get(gca,'xlim');  x1 = xlim(1);  x2 = xlim(2);
   ylim = get(gca,'ylim');  y1 = ylim(1);  y2 = ylim(2);
   
   hold on
   delete(hdlp);
   hdlp(1) = plot([x1 y1 0],[x2 y1 0],'k');
   hdlp(2) = plot([x2 y1 0],[x2 y2 0],'k');
   hdlp(3) = plot([x2 y2 0],[x1 y2 0],'k');
   hdlp(4) = plot([x1 y2 0],[x1 y1 0],'k');
   
   obj = set(obj,'surf.hdls',hdls);
   obj = set(obj,'surf.hdlp',hdlp);
   
   return   

% eof