function basics(obj)
%
% BASICS   Callbacks for demo menu 'basics'
%
%             Topics
%             - phase color and complex color
%             - color map visualization
%
   func = arg(obj);
   if isempty(func)
      mode = setting('basics.func');
   else
      setting('basics.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return
   
%==========================================================================   
% Phase Color and Complex Color Animation
%==========================================================================   

function CbPhaseColors(obj)
%
% PHASECOLORS   Demo displaying phase colors
%
   cls(obj);

   phi=0:pi/100:2*pi;
   hdl = patch(cos(phi),sin(phi),[1 1 1]);
   hold on;

   set(gca,'dataaspectratio',[1 1 1]);

   %hdl2 = plot([0 1],[0 0],'k');
   dt = 0.1;
   smo = timer(smart,dt);

   for (phi=0:20*dt:360*5)
      smo = update(smo);                  % sync!

      z = exp(sqrt(-1)*phi*pi/180);
      r = (2 + cos(5*pi*angle(z)))/3;
      z = r*z;

      set(hdl,'facecolor',pcolor(obj,z));

      smo = update(smo,plot([0 real(z)],[0 imag(z)],'k'));

      smo = wait(smo);
      if (stop(smo))
         break;
      end
   end

%==========================================================================

function CbMultiColors(obj)
%
% MULTICOLORS   Demo displaying phase colors
%
   cls(obj);

   r0 = 1.2*[1 1; -1 1; -1 -1; 1 -1];

   phi=0:pi/100:2*pi;

   for (k=1:4)
      hdl1(k) = patch(r0(k,1)+cos(phi),r0(k,2)+sin(phi),[1 1 1]);
      hold on;
      hdl2(k) = plot(r0(k,1)+[0 1],r0(k,2)+[0 0],'k');
   end

   set(gca,'dataaspectratio',[1 1 1]);

   dt = 0.1;
   smo = timer(smart,dt);


   for (phi=0:20*dt:360*5)
      z0 = exp(sqrt(-1)*phi*pi/180);

      delete(hdl2);
      for (k=1:4)
         switch k
            case 1
               r = cos(angle(z0));
               z = r;           % real part oszillation
            case 2
               z = z0;          % no change of magnitude
            case 3
               r = sin(angle(z0));
               z = sqrt(-1)*r;  % imag part oszillation
            case 4
               r = (2 + cos(5*pi*angle(z0)))/3;
               z = r*z0;        % change of magnitude
         end
         col = pcolor(obj,z);
         set(hdl1(k),'facecolor',col);
         hdl2(k) = plot(r0(k,1)+[0 real(z)],r0(k,2)+[0 imag(z)],'k');
      end

      smo = wait(smo);
      if (stop(smo))
         break;
      end
   end

%==========================================================================
% Color Map Demos
%==========================================================================

function CbFireCmap(obj)
%
   cmapdemo(obj,'fire',0);
   return

%==========================================================================
   
function CbPhaseCmap(obj)
%
   cmapdemo(obj,'phase',1);
   return

%==========================================================================

function CbComplexCmap(obj)
%
   cmapdemo(obj,'complex',1);
   return

%==========================================================================

function cmapdemo(obj,name,repeat)
%
% CMAPDEMO   Demo testing complex colormap
%
%                  cmapdemo(obj,'fire')
%                  cmapdemo(obj,'phase')
%                  cmapdemo(obj,'complex')
%
   cls(obj);
   N = 151;
   obj = cmap(obj,name);
   
   psi = ones(N,N);
   for (i=1:N)
      for (j=1:N)
         z = [(i-N/2) + sqrt(-1)*(j-N/2)] / (0.9*N/2);
         if (abs(z) > 1)
            z = z / abs(z);
         end
         psi(i,j) = z;
      end
   end
   
   Phi = exp(sqrt(-1)*angle(psi));
   Z = (1.01-abs(psi).^3) .* Phi;
   
   az = 37.5;  el = 20;  
   
   smo = timer(smart,0.1);
   while (~stop(smo))
      obj = surf(obj,1:N,1:N,Z);
      view(az,el);
      title(['Color Map: ',name]);
      
      dphi = exp(5*sqrt(-1)*(pi/180));   % 5 deg rotation
      Z = Z * dphi;
      smo = wait(smo);
      
      if (~repeat)
          break;
      end
   end
   return

%eof   
   