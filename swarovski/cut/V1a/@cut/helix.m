function out = helix(o,varargin);
%
% HELIX   3D Helix plot
%
%            helix(o,'Plot',t,a,x);
%
%         See also: CUT
%
   [gamma,oo] = manage(o,varargin,@Plot,@Magnitude,@Demo);
   oo = gamma(oo);
end

%==========================================================================
% helix plot
%==========================================================================

function o = Plot(o)                   % Helix Plot                    
   t = arg(o,1);
   ax = arg(o,2);
   ay = arg(o,3);

   scale = 0.5;
   ax = scale*ax;
   ay = scale*ay;
   
   
   Tube(o,t,0*t,0*t);
   Helix(o,t,ax,ay);
   Ambient(o);
end

function o = Magnitude(o)             % Helix Magnitude                    
   t = arg(o,1);
   ax = arg(o,2);
   ay = arg(o,3);

   scale = 0.5;
   ax = scale*ax;
   ay = scale*ay;
   
   Tube(o,t,ax,0*ax);
   hold on;
end

%==========================================================================
% Helix Demo
%==========================================================================

function o = Demo(o)                   % Helix Demo                    
   m = 500000;                
   tmax = 40;
   omega = 2*pi * 2000/tmax;
   omA = 2*pi * 25/tmax;

   dt = tmax/m;
   ax = 20;
   ay = 20;

   t = [0:dt:tmax];                     % coordinate along pale
   a = 0.3*ax+0.7*ax*abs(sin(omA*t));   % amplitude
   ax = 1*a.*cos(omega*t);
   ay = 2*a.*sin(omega*t);

   cls(o);
   Helix(o,t,ax,ay);
end

%==========================================================================
% Defaults
%==========================================================================

function oo = Default(o)              % Provide Defaults               
   oo = o;
   oo = opt(oo,{'radius.wire'},5);      % wire radius
   oo = opt(oo,{'radius.spring'},400);  % spring radius
   oo = opt(oo,{'points.wire'},20);     % number of wire circumference points
   oo = opt(oo,{'windings'},5);         % number of helix windings
   oo = opt(oo,{'pitch'},25);           % helix pitch
   oo = opt(oo,{'tube'},5);             % tube spec radius
   oo = opt(oo,{'offset'},[0 0 0]);     % offset of helix origin
end

%==========================================================================
% Helix
%==========================================================================

function o = Helix(o,t,ax,ay)         % Actual Helix Plot              
   oo = Default(o);
   r0 = opt(oo,{'radius.wire',5});    % wire radius
   R0 = opt(oo,{'radius.spring',400});% spring radius
   n  = opt(oo,{'points.wire',20});   % number points on wire circumference
   w  = opt(oo,{'windings',5});       % number of helix windings
   g  = opt(oo,{'pitch',25});         % helix pitch
   off = opt(oo,{'offset',[0 0 0]});  % offset of helix origin

   m = length(t);
   tmax = max(t)-min(t);
   beta = 0.001;

   Omega = 2*pi * (w/tmax);
   
   
   Rspec = 5;
   tt = 0:tmax/1000:tmax;
   v  = 0 : 2*pi/(4*n) : 2*pi;       % cordinate around tube          
   
      % calculate mesh of actual helix
   
   v  = 0 : 2*pi/n : 2*pi;           % cordinate around wire          
   p = atan2(ay,ax);
   a = sqrt(ax.*ax + ay.*ay);        % amplitude
   
   [T,V] = meshgrid(t-t(1),v);       % get TV-meshgrid
   [A,V] = meshgrid(a,v);            % get AV-meshgrid
   [P,V] = meshgrid(p,v);            % get PV-meshgrid

      % map meshgrid to helix

   Yp = (A+r0*sin(V)) .* cos(P);
   Zp = (A+r0*sin(V)) .* sin(P);

   Tp = T + 2*pi*R0/R0*100/200000/Omega * r0*cos(V); 

   H = g*r0*Omega/(2*pi)*T;
   Rp = R0.*(1-beta*H) + Yp;
   
   X = Rp.*cos(Omega*Tp);
   Y = Rp.*sin(Omega*Tp);
   Z = Zp + H;
   C = 150 * ones(size(Z));            % 2: color index red

      % surf plot of helix

   shdl = surf(X+off(1),Y+off(2),Z+off(3),'EdgeColor','none'); 
   alpha(shdl,1.0);
   set(gca,'DataAspectRatio',[1 1 1]);
end
function o = Tube(o,t,ax,ay)          % Helix Tube                     
   oo = Default(o);
   r0 = opt(oo,{'radius.wire',5});    % wire radius
   R0 = opt(oo,{'radius.spring',400});% spring radius
   n  = opt(oo,{'points.wire',20});   % number points on wire circumference
   w  = opt(oo,{'windings',5});       % number of helix windings
   g  = opt(oo,{'pitch',25});         % helix pitch
   tube  = opt(oo,{'tube',5});        % tube spec radius
   off = opt(oo,{'offset',[0 0 0]});  % offset of helix origin

   m = length(t);
   tmax = max(t)-min(t);
   beta = 0.001;

   Omega = 2*pi * (w/tmax);
   Rspec = tube;

   tt = 0:tmax/1000:tmax;
   v  = 0 : 2*pi/(4*n) : 2*pi;       % cordinate around tube          
   
      % calculate mesh of spec tube
   
   [T,V] = meshgrid(t,v);           % get TV-meshgrid
   [A,V] = meshgrid(ax,v);           % get TV-meshgrid
   H = g*r0*Omega/(2*pi)*T;
   
   Rp = (Rspec + A) .* cos(V);
%   Rp = Rspec * cos(V);
   Zp = Rspec * sin(V);
 
   X = (R0.*(1-beta*H) + Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + Rp) .* sin(Omega*T);
   Z = Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
   shdl = surf(X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none'); 
   alpha(shdl,0.8);
   hold on

   X = (R0.*(1-beta*H) + 4*Rp) .* cos(Omega*T);
   Y = (R0.*(1-beta*H) + 4*Rp) .* sin(Omega*T);
   Z = 4*Zp + H;
   C = 1*ones(size(Z));              % 1: color index gray
   
   shdl = surf(X+off(1),Y+off(2),Z+off(3),C,'EdgeColor','none');
   material(shdl,'shiny'); 
   alpha(shdl,0.4);
   hold on
end
function o = Ambient(o)               % Ambient Settings               
   set(gca,'Position',[0 0 1 1]);
   set(gca,'DataAspectRatio',[1 1 1]);
   
   set(gca,'color',[0 0 0]);
   set(figure(o),'color',[0 0 0]);
   light('Position',[+1 0 0],'Style','local')
   lightangle(-45,30)
end

