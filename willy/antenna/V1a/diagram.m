function diagram(o,phi,db)                                             
%
% DIAGRAM   Plot antenna diagram
%
%              phi = 0:10:360;
%              db = 30*sin(4*phi/180+pi);
%
%              diagram(o,phi,db);      % antenna diagramm
%              diagram(o);             % draw polar grid only
%    
%           Options:
%              min:     minimum dB value (center dB value)
%              max:     maximum dB value (outermost dB value)
%              step:    radial grid step (in dB)
%              sectors: number of grid sectors
%
%           See also: ANTENNA, PLOT
%
   step = opt(o,{'step',10});
   
   dbmin = floor((min(db)-step)/step)*step;
   dbmax =  ceil((max(db)+step)/step)*step;
   
   dbmin = opt(o,{'min',dbmin});
   dbmax = opt(o,{'max',dbmax});
   
   sectors = opt(o,{'sectors',12});
   
      % draw polar grid
      
   PolarGrid(o,dbmin,dbmax,step,sectors);
   
      % if only one arg is provided we are done with polar grid and return 
      
   if (nargin < 2)
      return
   end
      
      % plot antenna characteristics
      
   col = opt(o,{'gain','r'});
   lw = opt(o,{'linewidth',3});
   
   r = db - dbmin;
   hdl = plot(r.*cos(phi),r.*sin(phi));
   set(hdl,'color',o.color(col),'LineWidth',lw);
   
   heading(o);
end

%==========================================================================
% Draw Polar Grid
%==========================================================================

function o = PolarGrid(o,dbmin,dbmax,dbstep,sectors)                           
   p = 0:pi/100:2*pi;
   col = 0.5*[1 1 1];
   lw = 0.5;
   fsz = 12;                           % font size

   hor = 'HorizontalAlignment';
   ver = 'VerticalAlignment';
   zcol = opt(o,{'zero',''});          % zero dB color
   
   for (r = 0:dbstep:dbmax-dbmin)  
      hdl = plot(r*cos(p),r*sin(p));
      if (r==-dbmin && ~isempty(zcol))
         set(hdl,'Color',o.color(zcol),'Linewidth',lw+1);
      elseif (r == dbmax-dbmin)
         fcol = o.iif(dark(o),'wwk','kkw');
         set(hdl,'Color',o.color(fcol),'Linewidth',lw+2);
      else
         set(hdl,'Color',col, 'Linewidth',lw);
      end
      hold on
      
      hdl = text(r,0,sprintf('%g',r+dbmin));
      if (r == -dbmin && ~isempty(zcol))
         set(hdl,'Color',o.color(zcol),'FontSize',fsz);
      else
         set(hdl,'Color',col,'FontSize',fsz);
      end
      set(hdl, hor,'left', ver,'top');
   end
   
   set(gca,'DataAspect',[1 1 1]);
    
   r = dbmax-dbmin;
   inc = 360/sectors;
   
   for (p = 0:inc:360-inc)
      x = r*cos(p*pi/180);
      y = r*sin(p*pi/180);
      hdl = plot([0 x],[0 y]);
      set(hdl,'Color',col, 'Linewidth',lw);
      
      if (p == 0)
         continue;                     % 0° label is not provided
      end
      
      x = x*1.02;  y = y*1.02;
      txt = sprintf('%g°',p);
      hdl = text(x,y,txt);
      set(hdl,'Color',col,'FontSize',fsz);
      
      if (p == 0)
         set(hdl,hor,'left', ver,'mid');
      elseif (p > 0 && p < 90)
         set(hdl,hor,'left', ver,'bottom');
      elseif (p == 90)
         set(hdl,hor,'center', ver,'bottom');
      elseif (p > 90 && p < 180)
         set(hdl,hor,'right', ver,'bottom');
      elseif (p == 180)
         set(hdl,hor,'right', ver,'mid');
      elseif (p > 180 && p < 270)
         set(hdl,hor,'right', ver,'top');
      elseif (p == 270)
         set(hdl,hor,'center', ver,'top');
      elseif (p > 270 && p < 360)
         set(hdl,hor,'left', ver,'top');
      end  
   end
   
   axis off;
   col = o.iif(dark(o),'k','w');
   set(gcf,'Color',col);
end
