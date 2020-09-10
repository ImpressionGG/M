function basics(obj)
%
% BASICS   Callbacks for demo menu 'basics'
%
%             Topics
%             - phase color and complex color
%             - color map visualization
%
   func = args(obj,1);
   if isempty(func)
      mode = setting('basics.func');
   else
      setting('basics.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return

%==========================================================================   
% Camera
%==========================================================================   

function CbZoom(obj)
%
% CBZOOM   Demo demonstrating camera zoom
%
   camera('play','light');              % build up a demo sceene
   camera('home','target',[0 0 0]);     % define home position & cam target
   dark;
   
   [t,dt] = timer(gao,0.05);             % setup timer
   while (~stop(gao))                   % still continue 
      camera('zoom',1+sin(t)/2);
      [t,dt] = wait(gao);               % wait for timer tick
   end
   return
   
%==========================================================================

function CbSpin(obj)
%
% CBSPIN   Demo demonstrating camera spin
%
   camera('play','light');              % build up a demo sceene
   camera('home','target',[0 0 0]);     % define home position & cam target
   dark;
   camera('spinning',0.05);
   return
   
%==========================================================================   
   
function CbSpinZoom(obj)
%
% CBZOOM   Demo demonstrating camera zoom
%
   camera('play','light');              % build up a demo sceene
   camera('home','target',[0 0 0]);     % define home position & cam target
   dark;
   
   [t,dt] = timer(gao,0.05);            % setup timer
   while (~stop(gao))                   % still continue 
      camera('spin',2,'zoom',1+sin(t)/2);
      [t,dt] = wait(gao);               % wait for timer tick
   end
   
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
   
function CbAlphaCmap(obj)
%
   cmapdemo(obj,'alpha',1);
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

%==========================================================================
% 3D Animation Demos
%==========================================================================

function Cb3DTube(obj)
%
% CB3DTUBE   3D Animation of a Tube
%
%
   cls
   n = 50;
 
   a = .4;                         % the diameter of the small tube
   c = .6;                         % the diameter of the bulb
   z0 = 1;                         % z offset of the bottle
   t1 = pi/4 : pi/n : 5*pi/4;      % parameter along the tube
   t2 = 5*pi/4 : pi/n : 9*pi/4;    % angle around the tube
   u  = pi/2 : pi/n : 5*pi/2;
   [X,Z1] = meshgrid(t1,u);
   [Y,Z2] = meshgrid(t2,u);

      % draw the handle

   len = sqrt(sin(X).^2 + cos(2*X).^2);
   x1 = c*ones(size(X)).*(cos(X).*sin(X) ...
       - 0.5*ones(size(X))+a*sin(Z1).*sin(X)./len);
   y1 = a*c*cos(Z1).*ones(size(X));
   z1 = ones(size(X)).*cos(X) + a*c*sin(Z1).*cos(2*X)./len;
   handleHndl=surf(x1,y1,z0+z1,X);
   alpha(handleHndl,0.5);
   set(handleHndl,'EdgeColor','none');   % [.5 .5 .5];
   hold on;

      % draw the bulb
      
   r = sin(Y) .* cos(Y) - (a + 1/2) * ones(size(Y));
   x2 = c * sin(Z2) .* r;
   y2 = - c * cos(Z2) .* r;
   z2 = ones(size(Y)) .* cos(Y);
   bulbHndl=surf(x2,y2,z0+z2,Y);
   set(bulbHndl,'EdgeColor','none')
   alpha(bulbHndl,0.5);
   
      % draw a transparent tube
   
   t = -1:2/(n+1):1;               % coordinate along tube
   u  = pi/2 : pi/n : 5*pi/2;
   [T,U] = meshgrid(t,u);

   x0 = 0; y0 = 0;  r0 = 1;
   x = x0 + r0*cos(U);
   y = y0 + r0*sin(U);
   z = T;
   hold on;
   hdl = surf(x,y,z,T,'EdgeColor','none');
   alpha(hdl,0.5);
   
      % draw a solid cylinder using MATLAB's cylinder function
      
   [x,y,z] = cylinder(2*ones(1,1),200);   
   hdl = surf(x,y,z,'edgecolor','none');
   
      %draw two spheres at the light position
      % and set two lights
      
   [x,y,z] = sphere(40);
   r =0.5; x0 = 2;  y0 = -2; z0 = 1;
   surf(x0+r*x+x0,y0+r*y,z0+r*z,'edgecolor','none');
   %light('Position',[x0 y0 z0])

   r =0.5; x0 = 2;  y0 = +2; z0 = 2;
   surf(x0+r*x+x0,y0+r*y,z0+r*z,'edgecolor','none');
   %light('Position',[x0 y0 z0])
   
   cmap(obj,'fire');
   axis vis3d, axis off
   view(-37,30);

   camera('target',[0 0 0],'pin','zoom',1.5,'light');  % use default light
   
   shg;
   set(gca,'dataaspect',[1 1 1]);
   hold off
   
   [t,dt] =  timer(gao,0.05);
   while (~stop(gao))
      camera('spin',5);
      [t,dt] = wait(gao);
   end
   return

%==========================================================================

function Cb3DWing(obj)
%
% CB3DWing   3D Wing Animation of psi functions
%
%
   mp = option(obj,'pale.m');   % number of segments along pale (mp = 10)
   np = option(obj,'pale.n');   % number of segments around pale (np = 10)
   tp = option(obj,'pale.t');   % transparency (tp = 0.8)

   tp = 1;
   %mp = 10;  np = 4;   
   fac = 4;                     % virtual amplification for visualisation
   
      % Define coordinate space and psi functioon
      
   z = -5:0.2:5;                             % our coordinate space
   k = 0 * 2*pi / 10; om = 2*pi*0.05;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',1.6);
 
   [t,dt] = timer(smart,0.1);
   while (control(smart))
      psi1 = normalize(cos(z/max(z)*1*pi/2) .* exp(i*1*[k*z+om*t]),z);
      psi2 = normalize(sin(z/max(z)*2*pi/2) .* exp(i*4*[k*z+om*t]),z);
      psi = psi1 + psi2;
      P = prob(psi,z);
      
      wing(obj,z,fac*psi1,'r'); 
      wing(obj,z,fac*psi2,'y'); 
      wing(obj,z,fac*psi,'b'); 
      balley(obj,z,fac*P,'g'); 

      [t,dt] = wait(smart);
   end
   return
   
%==========================================================================

function Cb3DPale(obj)
%
% CB3DPale   3D pale animation of psi functions
%
%
   mp = option(obj,'pale.m');   % number of segments along pale (mp = 10)
   np = option(obj,'pale.n');   % number of segments around pale (np = 10)
   tp = option(obj,'pale.t');   % transparency (tp = 0.8)

   tp = 1;
   mp = 1;  np = 12;   
   fac = 3;                     % virtual amplification for visualisation
   
      % Define coordinate space and psi functioon
      
   z = -5:0.25:5;                             % our coordinate space
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',1.6);
 
   [t,dt] = timer(smart,0.1);
   while (control(smart))

      psi1 = normalize(cos(z/max(z)*1*pi/2) .* exp(i*1*[k*z+om*t]),z);
      psi2 = normalize(sin(z/max(z)*2*pi/2) .* exp(i*4*[k*z+om*t]),z);
      psi = psi1 + psi2;
      P = prob(psi,z);
      
      pale(obj,z,fac*psi1,'r',tp,mp,np); 
      pale(obj,z,fac*psi2,'y',tp,mp,np); 
      pale(obj,z,fac*psi,'b',tp,mp,np); 
      balley(obj,z,fac*P,'g',1.0); 

      [t,dt] = wait(smart);
   end
   return
   
   %eof   
   