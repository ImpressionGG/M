function out = play(o,t,ax,ay);
%
% PLAY   Play with 3D Helix plot
%
%        See also: CUT
%
   %if (nargin == 1)
   if (1)
      m = 500000;                
m = 50000;                
      tmax = 40;
      omega = 2*pi * 2000/tmax;
omega = 2*pi * 200/tmax;
      omA = 2*pi * 25/tmax;

      dt = tmax/m;
      ax = 20;
ax=50;      
%     ay = 20;

      t = [0:dt:tmax];                  % coordinate along pale
      a = 0.3*ax+0.7*ax*abs(sin(omA*t));   % amplitude
      ax = a.*cos(omega*t);
      ay = a.*sin(omega*t);
   else
      scale = 0.5;
      ax = scale*ax;
      ay = scale*ay;
   end
   
   Helix2(o,t,ax,ay);
end

%==========================================================================
% Helix 1,2
%==========================================================================

function o = Helix1(o,t,ax,ay)
   map = zeros(256,1)*o.color('r');
   map(1,:) = o.color('kww');
   %map(2,:) = o.color('r');
%   colormap(map);

   d0 = 10;                          % wire diameter
d0=10;   
   r0 = 10;                          % inner spring radius
   R0 = 400;                         % outer spring radius
   n = 20;                           % points of wire circumferene
   m = length(t);
   
   tmax = max(t)-min(t);
   w = 5;                            % windings
w = 1;   
   Omega = 2*pi * (w/tmax);
%   omega = 2*pi * 2000/tmax;
   
   g = 12;                            % ganghoehe (per radius)
   beta = 0.001;
   zj = 0;
   off = [0 0 0];
   
   Rspec = 5;
   tt = 0:tmax/1000:tmax;
   v  = 0 : 2*pi/(4*n) : 2*pi;       % cordinate around tube          
v  = 0 : 2*pi/20 : 2*pi;       % cordinate around tube          
   
      % calculate mesh of spec tube
%tt=0:0.2:1;   

   [T,V] = meshgrid(tt,v);           % get TV-meshgrid
   H = g*r0*Omega/(2*pi)*T;
   
   %                               z
   %                               ^
   %                               |
   %   o-------------------------->o----->r
   
   Rp = Rspec * cos(V);
   Zp = Rspec * sin(V);
   
      % waagrecht verlaufender Draht
      
   cls(o);   % clear screen
   surf(T,Rp,Zp,'EdgeColor','none'); 
   set(gca,'DataAspectRatio',[1 1 1]);
   
      % ansteigender Draht
   
   cls(o);   % clear screen
   surf(T,Rp,Zp+H,'EdgeColor','none'); 
   set(gca,'DataAspectRatio',[1 1 1]);
   
      % spiralisierter Draht

   X = (R0.*(1-beta*H) + Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + Rp) .* sin(Omega*T);
   surf(X,Y,Zp+H,'EdgeColor','none'); 
   set(gca,'DataAspectRatio',[1 1 1]);
   
   
   
   
   
   Z = Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
      % surf plot
      
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none'); 
   alpha(shdl,0.8);
   hold on
   
   set(gca,'DataAspectRatio',[1 1 1]);

   set(gca,'color',[0 0 0]);
   set(figure(o),'color',[0 0 0]);
   light('Position',[+1 0 0],'Style','local')
   lightangle(-45,30)
end
function o = Helix2(o,t,ax,ay)
   map = zeros(256,1)*o.color('r');
   map(1,:) = o.color('kww');
   %map(2,:) = o.color('r');
%   colormap(map);

   d0 = 10;                          % wire diameter
 
   r0 = 10;                          % inner spring radius
   R0 = 400;                         % outer spring radius
   n = 20;                           % points of wire circumferene
   m = length(t);
   
   tmax = max(t)-min(t);
   w = 5;                            % windings
   Omega = 2*pi * (w/tmax);
%   omega = 2*pi * 2000/tmax;
   
   g = 12;                            % ganghoehe (per radius)
   beta = 0.001;
   zj = 0;
   off = [0 0 0];
   
   Rspec = 5;
   tt = 0:tmax/1000:tmax;
   v  = 0 : 2*pi/(4*n) : 2*pi;       % cordinate around tube          
   
      % calculate mesh of spec tube
   
   [T,V] = meshgrid(tt,v);           % get TV-meshgrid
   H = g*r0*Omega/(2*pi)*T;
   
   Rp = Rspec * cos(V);
   Zp = Rspec * sin(V);

%  beta = 0.0005;   % Verjüngung der Spirale

   X = (R0.*(1-beta*H) + Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + Rp) .* sin(Omega*T);
   Z = Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
      % hot wire
      
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none'); 
   set(gca,'DataAspectRatio',[1 1 1]);
   alpha(shdl,0.8);
   hold on

   X = (R0.*(1-beta*H) + 4*Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + 4*Rp) .* sin(Omega*T);
   Z = 4*Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
       % Coax Mantel
       
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none');
   set(gca,'DataAspectRatio',[1 1 1]);
   material(shdl,'shiny'); 
%   material(shdl,'metal'); 
   alpha(shdl,0.4);

      % calculate mesh of actual helix
   
   v  = 0 : 2*pi/n : 2*pi;           % cordinate around wire          
   p = atan2(ay,ax);
   a = sqrt(ax.*ax + ay.*ay);        % amplitude
   
   [T,V] = meshgrid(t-t(1),v);       % get TV-meshgrid
   [A,V] = meshgrid(a,v);            % get AV-meshgrid
   [P,V] = meshgrid(p,v);            % get PV-meshgrid

      % map meshgrid to helix
cls(o);
   Yp = (A+d0/2*sin(V)) .* cos(P);
   Zp = (A+d0/2*sin(V)) .* sin(P);
   shdl = surf(T*50,Yp,Zp,'EdgeColor','none'); 
   set(gca,'DataAspectRatio',[1 1 1]);

   Tp = T + 2*pi*R0/R0*100/200000/Omega * d0/2*cos(V); 

   H = g*r0*Omega/(2*pi)*T;
   RR = R0.*(1-beta*H) + Yp;
   
   X = RR.*cos(Omega*Tp);
   Y = RR.*sin(Omega*Tp);
   Z = Zp + H;
   C = 150 * ones(size(Z));            % 2: color index red

      % surf plot of helix

   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),'EdgeColor','none'); 
   alpha(shdl,1.0);
   set(gca,'Position',[0 0 1 1]);
   set(gca,'DataAspectRatio',[1 1 1]);
   
   set(gca,'color',[0 0 0]);
   set(figure(o),'color',[0 0 0]);
   light('Position',[+1 0 0],'Style','local')
   lightangle(-45,30)
end

%==========================================================================
% Helix
%==========================================================================

function o = Helix(o,t,ax,ay)
   map = zeros(256,1)*o.color('r');
   map(1,:) = o.color('kww');
   %map(2,:) = o.color('r');
%   colormap(map);

   d0 = 10;                          % wire diameter
d0=10;   
   r0 = 10;                          % inner spring radius
   R0 = 400;                         % outer spring radius
   n = 20;                           % points of wire circumferene
   m = length(t);
   
   tmax = max(t)-min(t);
   w = 5;                            % windings
w = 1;   
   Omega = 2*pi * (w/tmax);
%   omega = 2*pi * 2000/tmax;
   
   g = 12;                            % ganghoehe (per radius)
   beta = 0.001;
   zj = 0;
   off = [0 0 0];
   
   Rspec = 5;
   tt = 0:tmax/1000:tmax;
   v  = 0 : 2*pi/(4*n) : 2*pi;       % cordinate around tube          
   
      % calculate mesh of spec tube
   
   [T,V] = meshgrid(tt,v);           % get TV-meshgrid
   H = g*r0*Omega/(2*pi)*T;
   
   Rp = Rspec * cos(V);
   Zp = Rspec * sin(V);
 
   X = (R0.*(1-beta*H) + Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + Rp) .* sin(Omega*T);
   Z = Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none'); 
   alpha(shdl,0.8);
   hold on

   X = (R0.*(1-beta*H) + 4*Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + 4*Rp) .* sin(Omega*T);
   Z = 4*Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none');
   material(shdl,'shiny'); 
%   material(shdl,'metal'); 
   alpha(shdl,0.4);

      % calculate mesh of actual helix
   
   v  = 0 : 2*pi/n : 2*pi;           % cordinate around wire          
   p = atan2(ay,ax);
   a = sqrt(ax.*ax + ay.*ay);        % amplitude
   
   [T,V] = meshgrid(t-t(1),v);       % get TV-meshgrid
   [A,V] = meshgrid(a,v);            % get AV-meshgrid
   [P,V] = meshgrid(p,v);            % get PV-meshgrid

      % map meshgrid to helix

   Yp = (A+d0/2*sin(V)) .* cos(P);
   Zp = (A+d0/2*sin(V)) .* sin(P);

   Tp = T + 2*pi*R0/R0*100/200000/Omega * d0/2*cos(V); 

   H = g*r0*Omega/(2*pi)*T;
   RR = R0.*(1-beta*H) + Yp;
   
   X = RR.*cos(Omega*Tp);
   Y = RR.*sin(Omega*Tp);
   Z = Zp + H;
   C = 150 * ones(size(Z));            % 2: color index red

      % surf plot of helix

   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),'EdgeColor','none'); 
   alpha(shdl,1.0);
   set(gca,'Position',[0 0 1 1]);
   set(gca,'DataAspectRatio',[1 1 1]);
   
   set(gca,'color',[0 0 0]);
   set(figure(o),'color',[0 0 0]);
   light('Position',[+1 0 0],'Style','local')
   lightangle(-45,30)
end

%==========================================================================
% Tape
%==========================================================================

function o = Tape(o)
   r0 = 10;
   R0 = 200;                         % spring radius
   np = 25;
   m = 10000;                        % time steps
   L = 200;
   Lp = 2;
   ax = 20;
   ay = 20;
   
   g = 8;                            % 6xradius ganghoehe
   w = 5;                            % windings
   phij = pi/4;
   zj = 0;
   off = [0 0 0];
   
   t = [0:1/m:w]*L;                  % coordinate along pale
   a = 0.3*ax+0.7*ax*abs(sin(5*t*2*pi/L));          % amplitude
   p = 400*2*pi/L * t;               % phase
   r = [ones(size(t))]*r0;           % radial coordinate of pale
   v  = 0 : 2*pi/np : 2*pi;          % cordinate around pale          
   v = [0.8,1];
   
   [T,V] = meshgrid(t,v);            % get TV-meshgrid
   [A,V] = meshgrid(a,v);            % get AV-meshgrid
   [P,V] = meshgrid(p,v);            % get PV-meshgrid
   [R,V] = meshgrid(r,v);            % get RV-meshgrid

      % map meshgrid to pale

   %Zp = R.*cos(V);
   %Yp = R.*sin(V);
   
   Yp = V.*A.*cos(P);
   Zp = V.*A.*sin(P);
   
   Xp = T; 

   RR = R0 + Yp;
   PHI = 2*pi * Xp/200;
   
   XX = RR.*sin(PHI);
   YY = RR.*cos(PHI);
   ZZ = Zp + g*r0*T./L;
   
      % surf plot of pale

%  X = Xp;  Y = Yp;  Z = Zp;
   X = XX;  Y = YY;  Z = ZZ;
    
   shdl = surf(zj+X+off(1),Y+off(2),Z+off(3),'EdgeColor','none'); 
   alpha(shdl,1);
   set(gca,'DataAspectRatio',[1 1 1]);
end

