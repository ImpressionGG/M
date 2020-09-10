function scatter(obj,varargin)
%
% SCATTER   Callbacks for demo menu 'scatter'
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'setup');
   
   if ~propagate(obj,func,which(func)) 
      eval(cmd);
   end
   return

   
%==========================================================================   
% Classical Particle Movement
%==========================================================================   
   
function CbClassicPass1D(obj)
%
   classic(obj,'1D',1);
   return

%==========================================================================   
   
function CbClassicPass3D(obj)
%
   classic(obj,'3D',1);
   return
   
%==========================================================================   
   
function CbClassicBump1D(obj)
%
   classic(obj,'1D',-1);
   return

%==========================================================================   
   
function CbClassicBump3D(obj)
%
   classic(obj,'3D',-1);
   return
   
%==========================================================================

function classic(obj,dim,mode)
%
% CLASSIC  Two classical particles pass without collision
%
   uselight = option(obj,'scatter.light');

   nz = iif(strcmp(dim,'3D'),200,200);
   tmax = option(obj,'scatter.tmax');
   dt = 0.1;

   lambda = 0.7;
   k = 2*pi/lambda;
   om = 0;

   obj = option(obj,'global.nz',nz,'global.dt',dt,'global.tmax',tmax);
   [t,z] = cspace(obj);
   

   sigma = 0.2;  sigmaa = sigma; sigmab = sigma;
   zl = min(z)-8*sigma;  zr = max(z)+8*sigma;  
   
      % setup diagram basics
     
   cls(obj);
   plot(0,0,'w'); hold on;
   hdl = [];  thdl = []; 

   if (match(dim,'3D'))
      cmap(obj,'fire');
      xlabel('z-Position of Particle 1');      
      ylabel('z-Position of Particle 2');      
      pmax = 0.02;
   else
      xlabel('Wave Function of Particle 1 (red) and Particle 2 (blue)');
   end
   

   obj = set(obj,'color',{'r','b'},'width',3);  % setup line properties
   timer(smart,dt);                             % setup timer for animation
   
   while (~stop(smart))
      for (t = 0:dt:tmax)
         if(~control(smart))
            break;
         end
      
         v = (zr-zl) / tmax;
         pa = zl + v*t;        % position particle A
         if (mode < 0)
            pa = -abs(pa);
            pa = min(-0.2,pa);
         end
         pb = -pa;      
      
         psia = bell(z,sigmaa,pa);
         psib = bell(z,sigmab,pb);
      
         psi = psia*psib';
      
         switch dim
            case '1D'
               obj = plot1d(obj,z,psia,z,psib);
               set(gca,'ylim',0.15*[0 1]);
            case '1C'
               obj = plot1c(obj,z,psia,z,psib);
            case '3D'
               obj = plot2d(obj,z,z,psi);
               set(gca,'zlim',[0 pmax]);
               if (uselight)
                  obj = light(obj,[-10 0 pmax/2],[1 1 1],[0 -10 pmax/2],[1 1 1]); % add light
               end
         end
      
         if (match(dim,{'1D','1C'}))
            update(smart,text(-0.5,0.14,sprintf('t = %3.1f',t)));
         else
            if (mode == 1)
               title('Classical Particle Scattering (Pass)');
            else
               title('Classical Particle Scattering (Bump)');
            end
         end
         
         wait(smart);   % wait on timer tic
      end
   end
   return
   
%==========================================================================
% Boson & Fermion Scattering
%==========================================================================   
   
function CbBoson1D(obj)
%
   quantic(obj,'1D',+1);
   return
   
%==========================================================================   
   
function CbBoson1C(obj)
%
   quantic(obj,'1C',+1);
   return
   
%==========================================================================   
   
function CbBoson3D(obj)
%
   quantic(obj,'3D',+1);
   return
   
%==========================================================================   

function CbBoson3C(obj)
%
   quantic(obj,'3C',+1);
   return
   
%==========================================================================   
   
function CbFermion1D(obj)
%
   quantic(obj,'1D',-1);
   return
   
%==========================================================================   
   
function CbFermion1C(obj)
%
   quantic(obj,'1C',-1);
   return
   
%==========================================================================   
   
function CbFermion3D(obj)
%
   quantic(obj,'3D',-1);
   return
   
%==========================================================================   
   
function CbFermion3C(obj)
%
   quantic(obj,'3C',-1);
   return
   
%==========================================================================   

function quantic(obj,dim,mode)
%
% QUANTIC  Two quantum particles pass without collision
%
   uselight = option(obj,'scatter.light');
   
   nz = iif(strcmp(dim,'3D'),200,200);   % 200
   tmax = option(obj,'scatter.tmax');
   dt = 0.1;

   lambda = 3*0.7;
   k = 2*pi/lambda;
   om = k;

   obj = option(obj,'global.nz',nz,'global.dt',dt,'global.tmax',tmax);
   [t,z] = cspace(obj);
   

   sigma = 0.5;  sigmaa = 1; sigmab = 0.5;
   zl = min(z)-8*sigma;  zr = max(z)+8*sigma;  
   
      % setup diagram basics
     
   cls(obj);
   plot(0,0,'w'); hold on;
   hdl = [];  thdl = []; 

   if (match(dim,'3D'))
      obj = cmap(obj,'fire');
      xlabel('z-Position of Particle 1');      
      ylabel('z-Position of Particle 2');      
      title(iif(mode>0,'Boson Scattering','Fermion Scattering'));
   elseif (match(dim,'3C'))
      obj = cmap(obj,'complex');
      xlabel('z-Position of Particle 1');      
      ylabel('z-Position of Particle 2');      
      title(iif(mode>0,'Boson Scattering','Fermion Scattering'));
   else
      title('Quantum Mechanical Particle Scattering')
      xlabel('Wave Function of Particle 1 (red) and Particle 2 (blue)');
   end
   
   pmax = 0.001;

   obj = set(obj,'color',{'r','b'},'width',3);  % setup line properties
   [t,dt] = timer(smart,dt);                    % setup timer for animation
   
   while (~stop(smart))
      t = 0;
      while (control(smart) && t <= tmax)
      
         v = (zr-zl) / tmax;
         pa = zl + v*t;        % position particle A
         pb = -pa;      
      
         psia = bell(z,sigmaa,pa) .* exp(sqrt(-1)*(k*z - om*t));
         psib = [bell(z,sigmab,pb-sigmab) + bell(z,sigmab,pb+sigmab)]/2 .* exp(sqrt(-1)*(-k*z - om*t));
      
         psi = psia*psib' + mode*psib*psia';
      
         switch dim
            case '1D'
               obj = plot1d(obj,z,psia,z,psib);
               set(gca,'ylim',[-0.03 0.03]);
            case '1C'
               obj = plot1c(obj,z,psia,z,psib);
               set(gca,'ylim',[0 0.03]);
            case '3D'
               obj = plot2d(obj,z,z,psi);
               if (uselight)
                  camera('light');
                  %obj = light(obj,[-10 0 pmax/2],[1 1 1],[0 -10 pmax/2],[1 1 1]); % add light
               end
               set(gca,'zlim',[0 pmax]);
               view(-45,30);
            case '3C'
               obj = plot2c(obj,z,z,psi);
               if (uselight)
                  camera('light');
                  % obj = light(obj,[-10 0 pmax/2],[1 1 1],[0 -10 pmax/2],[1 1 1]); % add light
               end
               set(gca,'zlim',[0 pmax]);
               view(-45,30);
         end
      
         if (match(dim,{'1D','1C'}))
            delete(thdl);
            thdl = text(-0.5,0.027,sprintf('t = %3.1f',t));
         end
      
         t = t + iif(tmax>=10 && abs(t-tmax/2) < tmax/20,dt/5,dt);

         wait(smart);   % wait on timer tic
      end
   end
   return
   
%==========================================================================

function psi = bell(z,sigma,p)
%
% BELL   Bell shape function at position p
%
   z0 = (max(z)+min(z))/2;
   psi0 = exp(-((z-z0)/sigma).^2);
   A0 = 1/sum(psi0);               % just to calculate constant A0

   psi = A0*exp(-((z-p)/sigma).^2);
   return

%==========================================================================

function obj = plot1d(obj,z1,psi1,z2,psi2)
%
% PLOT1D    Plot psi function(s) in 1D graph
%
%              obj = plot1d(obj,z,psi);
%              obj = plot1d(obj,z1,psi1,z2,psi2);
%
   hdl = get(obj,'hdl');
   if (~isempty(hdl))
       delete(hdl);
   end

      % setup colors & width
      
   col1 = 'r';  col2 = 'b';  %  default settings
   col = get(obj,'color');
   if (length(col) >= 1)
       col1 = col{1};
   end
   if (length(col) >= 2)
       col2 = col{2};
   end

   wid1 = 3;  wid2 = 3;  %  default settings
   wid = get(obj,'width');
   if (length(wid) >= 1)
       wid1 = wid(1);  wid2 = wid1;
   end
   if (length(wid) >= 2)
       wid2 = wid(2);
   end
   
   hdl(1) = plot(z1,real(psi1));
   hold on;
   color(hdl(1),col1,wid1);
   
   if (nargin >= 4)
      hdl(2) = plot(z2,real(psi2));
      color(hdl(2),col2,wid2);
   end
   
   obj = set(obj,'hdl',hdl);
   return

%==========================================================================

function obj = plot1c(obj,z1,psi1,z2,psi2)
%
% PLOT1C    Plot psi function(s) in 1D graph with phase colors
%
%              obj = plot1c(obj,z,psi);
%              obj = plot1c(obj,z1,psi1,z2,psi2);
%
   hdl = get(obj,'hdl');
   if (~isempty(hdl))
       delete(hdl);
   end
   hdl = zeros(2,1+length(z1));

      % setup colors & width
      
   col1 = 'r';  col2 = 'b';  %  default settings
   col = get(obj,'color');
   if (length(col) >= 1)
       col1 = col{1};
   end
   if (length(col) >= 2)
       col2 = col{2};
   end

   wid1 = 3;  wid2 = 3;  %  default settings
   wid = get(obj,'width');
   if (length(wid) >= 1)
       wid1 = wid(1);  wid2 = wid1;
   end
   if (length(wid) >= 2)
       wid2 = wid(2);
   end

   plot(z1,0*z1,'k');  hold on;   % this is just to hold

      % draw phase colors

   psi = psi1 ./ abs(psi1);  % normalize
   col = pcolor(obj,psi);

   for (i=1:length(psi1))
      h = hdl(1,1+i);
      if (h)
         delete(h);
      end
      hdl(1,i+1) = plot(z1(i)*[1 1],[0 abs(psi1(i))]);
      set(hdl(1,i+1),'color',col(i,:),'linewidth',3);
   end

   psi = psi2 ./ abs(psi2);  % normalize
   col = pcolor(obj,psi);

   for (i=1:length(psi2))
      h = hdl(2,1+i);
      if (h)
         delete(h);
      end
      hdl(2,i+1) = plot(z1(i)*[1 1],[0 abs(psi2(i))]);
      set(hdl(2,i+1),'color',col(i,:),'linewidth',3);
   end

      % draw envelopes

   hdl(1,1) = plot(z1,abs(psi1));
   hold on;
   color(hdl(1),col1,wid1);

   if (nargin >= 4)
      hdl(2,1) = plot(z2,abs(psi2));
      color(hdl(2),col2,wid2);
   end
   
   obj = set(obj,'hdl',hdl);
   return

%==========================================================================

function obj = plot2d(obj,z1,z2,psi)
%
% PLOT2D    Plot psi function(s) in 2D graph
%
%              obj = plot2d(obj,z1,z2,psi);
%
   hdl = get(obj,'hdl');
   delete(hdl);
   
   psi = abs(psi);

   hdl = surf(z1,z2,psi,'EdgeColor','none','clipping','off');
   view(-37.5,30);

   hold on;
   set(gca,'box','off','ztick',[]);

   obj = set(obj,'hdl',hdl);
   return

%==========================================================================

function obj = plot2c(obj,z1,z2,psi)
%
% PLOT2C    Plot psi function(s) in 2C graph using phase color color maps
%
%              obj = plot2c(obj,z1,z2,psi);
%
   hdl = get(obj,'hdl');
   delete(hdl);

   obj = surf(obj,z1,z2,psi);
   return

%==========================================================================

function obj = plot2l(obj,z1,z2,psi)
%
% PLOT2C    Plot psi function(s) in 2D graph
%
%              obj = plot2d(obj,z1,z2,psi);
%
   hdl = get(obj,'hdl');
   if (~isempty(hdl))
       delete(hdl);
   end
   
   psi = abs(psi);

   hdl = surf(z1,z2,psi, ...
              'EdgeColor','none', ...
              'FaceColor',[1 0.2 0.2], ...   % [0.9 0.2 0.2]
              'FaceLighting','phong', ...
              'AmbientStrength',0.3, ...
              'DiffuseStrength',0.6, ... 
              'Clipping','off',...
              'BackFaceLighting','lit', ...
              'SpecularStrength',1, ...
              'SpecularColorReflectance',1, ...
              'SpecularExponent',7);
   
   if (~ishold)
      for (il=1:4)
         l1 = light('Position',[40 100 20], ...
              'Style','local', ...
              'Color',[1 0.2 0.2], ...  %'Color',[0 0.8 0.8],
              'parent',gca);

         l2 = light('Position',[.5 -1 .4], ...
              'Color',[0.8 0.8 0], ...
              'parent',gca);
      end
      hold on;
   end

   set(gca,'xgrid','off','ygrid','off','zgrid','off','ztick',[],'zticklabel',{});

   obj = set(obj,'hdl',hdl);
   return

%==========================================================================

   
%eof   
   