function plot(o,mode)
%
% PLOT  Plot data of a CUT object
%
%          plot(o)
%          plot(o,"Vx")
%          plot(o,"UxUyVxVy")
%
%       See also: CUT, SODE, HEUN
%
   if (nargin < 2)
      mode = var(o,"plot");
   end

   if (isequal(mode,"Vx"))
      Vx(o);
   elseif (isequal(mode,"UxUyVxVy"))
      UxUyVxVy(o);
   end
end

%=============================================================================
% Plotting
%=============================================================================

function hdl = Title(str)
   hdl = title(str);
   set(hdl,'fontsize',12),
end

function hdl = Xlabel(str)
   hdl = xlabel(str);
   set(hdl,'fontsize',12),
end

function hdl = Ylabel(str)
   hdl = ylabel(str);
   set(hdl,'fontsize',12),
end

function Plot(t,x,colors,labels)
   if (nargin < 3)
      colors = {'r','b','g','c','m','y','k'}
   end
   
   if (nargin >= 4)
      clf
   end
   
   [m,n] = size(x);
   for (i=1:m)
      col = colors{1+rem(i-1,length(colors))};
      hdl = plot(t,x(i,:),col);
      hold on;
      set(hdl,'linewidth',1);
   end
   set(gca,'fontsize',12)
   
   if (nargin >= 4)
      hdl = legend(labels,'location','northeast');
      set(hdl,'fontsize',12);
   end
end
   
%=============================================================================
% micron display
%=============================================================================

function [x,unit] = Micron(x)  % discriminate whether micron display
   micron = all(all(abs(x([1,2],:))<=0.001));
   if (micron)
      fac = 1e6;  unit = '[um]';
   else 
      fac = 1e3;  unit = '[mm]';
   end 
   x(1,:) = fac*x(1,:);
   x(2,:) = fac*x(2,:);
end

%===============================================================================
% plot ux, uy, vx, vy 
%===============================================================================

function UxUyVxVy(o)
   p = get(o,"parameter");
   t  = data(o,"t"); 
   x = data(o,"x");

   [x,unit] = Micron(x);  % discriminate whether micron display

   subplot(221);
   Plot(t,x(1,:),{'r'});
   hdl = Ylabel(['Magnitude ux ',unit]);
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   set(gca,"xlim",[min(t),max(t)]);
   
   subplot(222);
   Plot(t,x(2,:),{'m'});
   hdl = Ylabel(['Magnitude uy',unit]);
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl = Title(sprintf('Fn = %g',p.Fn));
   set(hdl,'fontsize',12),
   set(gca,"xlim",[min(t),max(t)]);

   subplot(223);
   Plot(t,x(3,:),{'b'});
   hdl = Ylabel('Velocity vx [m/s]');
   hold on;
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl=Title(sprintf('v = %g m/s',p.v));
   set(hdl,'fontsize',12),
   plot(t,0*t+p.v,'r')
   set(gca,"xlim",[min(t),max(t)]);

   subplot(224);
   Plot(t,x(4,:),{'g'});
   hdl = Ylabel('Velocity vy [m/s]');
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl = Title(sprintf('mu = %g',p.mu));
   set(hdl,'fontsize',12),   
   set(gca,"xlim",[min(t),max(t)]);
end

%===============================================================================
% plot vx 
%===============================================================================

function Vx(o)
   p = get(o,"parameter");
   t  = data(o,"t");         % time vector
   s  = data(o,"s");         % system indicator 
   x = data(o,"x");          % state vector
   
   [x,unit] = Micron(x);  % discriminate whether micron display

   Plot(t,x(3,:),{'b'});
   hdl = Ylabel('Velocity vx [m/s]');
   hold on;
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl=Title(sprintf('v = %g m/s',p.v));
   set(hdl,'fontsize',12),
   plot(t,0*t+p.v,"r")
   if (isequal(type(o),"sode"))
      plot(t,o.dat.s,"k");
   end
   plot(0*t,0*t+p.v,"r");
   set(gca,"xlim",[min(t),max(t)]);
end

