function apparatus(obj,varargin)
%
% APPARATUS  Package handler for 3D spin measurement apparatus demo
%
%       apparatus(toy,'SpinMeasurement')     % spin measurement demo
%       apparatus(toy,'Draw');               % new drawing of apparatus
%       apparatus(obj,'KeyHit',key);         % handle key hit events
%       apparatus(obj,'Help');               % help for apparatus demo
%
%    See also: TOY, BALL, GEM, BRICK, SPINBALL
%
   [cmd,obj,list,func] = dispatch(obj,varargin);
   eval(cmd);
   return
end

%==========================================================================
% Spin Measurement
%==========================================================================

function SpinMeasurement(obj)
%
% SPIN-MEASUREMENT
%
   
   sceene(obj,'3D',-5:5); 
   camera('zoom',3,'target',[1.5 0 0]);     % zoom was 1.5
   
   NewSpin(obj);                      % store new spin in settings('spin')
   
   az = 0;  setting('apparatus.az',az);
   el = 0;  setting('apparatus.el',el);
   
   RadioButtonSetup(obj);             % setup radio buttons
   ResetApparatus(obj,1);             % initialize apparatus, clear history
   
   view(obj,'Owner','Apparatus');
   ready;

   profiler('SpinMeasurement',1);
   
   [t,dt] = timer(gao,0.2);  om = 1;  % omega for spinning

   while (control(gao))
      %ball(toy,[0 0 0],4,'k',0.1,100);% setup surroundings (dummy ball)  
      %NewSpin(obj);
      obj = gfo;                      % pull down obj from figure and pull
                                      % current settings into options
      spinball(obj,om*t,1,'y');
      [az,el] = Draw(obj,az,el);

      multi = option(obj,'apparatus.multi');
      if (multi > 0)
         if option(obj,'apparatus.value')
            RadioHandler(obj,'Prepare');
         else
            RadioHandler(obj,'Measure');
         end
      end

      %camera('spin',0.2);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   
   profiler('SpinMeasurement',0);
   return
end

%==========================================================================
% Radio Button Setup
%==========================================================================

function RadioButtonSetup(obj)
%
% RADIO-BUTTON-SETUP
%
   multi = 'Multi';
   labels = {'Prepare','Measure','Up','Down','Left','Right',multi,'New','Help'};
   hdl = radio(obj,labels,call('RadioHandler'));
   
   Display(obj,labels);    % setup display for measurements
   return
end

%==========================================================================
% Display
%==========================================================================

function Display(obj,arg)
%
% DISPLAY   Display value from measurement
%
%              Display(obj);             % setup display
%              Display(obj,value);       % display new value
%
   if isa(arg,'cell')
      labels = arg;
      pos = get(gcf,'position');   % get position of figure
      width = pos(3);              % get figure width

      l = length(labels);
      w = width/l; W = 2*w;
      h = 25;  H = pos(4);
      
      m = round((H-3*h)/h);        % number of rows
      n = round(W/h);              % number of columns
      
      dsp.w = W/n;                 % cell width
      dsp.h = (H-3*h)/m;           % cell height
      dsp.m = m;                   % number of cell rows
      dsp.n = n;                   % number of cell columns
      dsp.cnt = 0;                 % no cells drawn

      dsp.x0 = (l-2)*w;            % home x position for cells
      dsp.y0 = H-2*dsp.h;          % home y position for cells

      hdl = uicontrol('parent',gcf,'style','pushbutton','String','Measurements');
      set(hdl,'position',[dsp.x0,H-h,2*w,h]);

      hdl = uicontrol('parent',gcf,'style','pushbutton','String','');
      set(hdl,'position',[dsp.x0,2*h,2*w,H-3*h]);

      hdl = uicontrol('parent',gcf,'style','pushbutton','String','Average:');
      set(hdl,'position',[dsp.x0,h,2*w,h]);
      dsp.hdl.average = hdl;
      
      setting('apparatus.display',dsp);
      return
   end
   
   if isa(arg,'double')
      value = arg;
      dsp = setting('apparatus.display');
      
         % update average
         
      histo = setting('apparatus.histo');
      histo(end+1) = value;
      setting('apparatus.histo',histo);
      
      avg = mean(histo);
      txt = sprintf('Average: %3.2f',avg);
      set(dsp.hdl.average,'String',txt);
      
         % update measurement board
         
      dsp.cnt = length(histo);
      
      txt = iif(value>0,'+1','-1');
      
      i = dsp.cnt-1;
      if (i < dsp.m*dsp.n)
         j = 0;
         while (i >= dsp.n)
            i = i-dsp.n;  j = j+1;
         end
            
         hdl = uicontrol('parent',gcf,'style','pushbutton','String',txt);
         set(hdl,'position',[dsp.x0+i*dsp.w,dsp.y0-j*dsp.h,dsp.w,dsp.h]);
         set(hdl,'userdata','#DISPLAY#');
         shg
      end
         % update display setting
         
      setting('apparatus.display',dsp);
      return
   end
   return
end

%==========================================================================
% Clear Display
%==========================================================================

function ClearDisplay(obj)
%
% CLEAR-DISPLAY   Clear measurement display
%
%
   children = get(gcf,'children');
   for (i = 1:length(children))
      hdl = children(i);
      eval('tp = get(hdl,''type'');','tp='''';');
      if strcmp(tp,'uicontrol')
         ud = get(hdl,'userdata');
         if isa(ud,'char')
            if strcmp(ud,'#DISPLAY#')
               delete(hdl);  
            end
         end
      end
   end
   return
end

%==========================================================================
% Key Hit Event Handler
%==========================================================================

function KeyHit(obj)
%
% KEY-HIT
%
   key = arg(obj,1);
   %fprintf('*** key hit: %s\n',key);
   
   switch key
      case {'M','m'}
         RadioHandler(obj,'Measure');
      case {'N','n'}
         RadioHandler(obj,'New');
      case {'P','p'}
         RadioHandler(obj,'Prepare');
      case {'X','x'}
         RadioHandler(obj,'Multi');
      case 'uparrow'
         RadioHandler(obj,'Up');
      case 'downarrow'
         RadioHandler(obj,'Down');
      case 'rightarrow'
         RadioHandler(obj,'Right');
      case 'leftarrow'
         RadioHandler(obj,'Left');
   end
   return
end

%==========================================================================
% Radio Button Handler
%==========================================================================

function RadioHandler(obj,mode)
%
% RADIO-HANDLER
%
   if (nargin < 2)
      mode = arg(obj,1);
   end
   
   az = option(obj,'apparatus.az');
   el = option(obj,'apparatus.el');
   dphi = pi/4;
   
   switch mode
      case 'New'
         NewSpin(obj);
         ResetApparatus(obj,1);
      case 'Prepare'
         PrepareSpin(obj);
         ResetApparatus(obj,0);
      case 'Measure'
         Measurement(obj);
      case {'Multi','50x'}
         ResetApparatus(obj,0);
         Multi(obj,50);
      case 'Up'
         ResetApparatus(obj,1);
         el = max(0,el-dphi);
      case 'Down'
         ResetApparatus(obj,1);
         el = min(el+dphi,pi);
      case 'Left'
         ResetApparatus(obj,1);
         az = az - dphi;
      case 'Right'
         ResetApparatus(obj,1);
         az = az + dphi;
      case 'Help'
   end
   
   setting('apparatus.az',az);
   setting('apparatus.el',el);

      % obviously the radio buttons destroy the keyhit handler setup
      % thus we must repe4atedly initiate the view owner call
      
   %keyhit(obj,'KeyHit',{});        % keyhit will install a callback
   %view(obj,'Owner','Apparatus');

   return
end

%==========================================================================
% Set Spin
%==========================================================================

function obj = SetSpin(obj,az,el,state,prepare);
%
% SET-SPIN  Update spin settings
%
   setting('spin.state',state);
   setting('spin.az',az);
   setting('spin.el',el);

   if (nargin >= 5)
      setting('spin.prepare',prepare);
   end
   
   obj = option(obj,'spin',setting('spin'));
   return
end

%==========================================================================
% New Spin
%==========================================================================

function obj = NewSpin(obj);
%
% NEW-SPIN  Setup a new spin. Store results in setting('spin')
%
   n = 8;
   az = round(n*rand)/n*2*pi;  
   el = round(n*rand)/n*2*pi;

   Sn = spin(toy,az,el);     % general spin operator
   state = spin(Sn);         % spin state
   
   obj = SetSpin(obj,az,el,state,state);
   return
end

%==========================================================================
% Prepare Spin
%==========================================================================

function obj = PrepareSpin(obj);
%
% PREPARE-SPIN  Restore spin to the prepared state. Store results in
%               setting('spin')
%
   state = setting('spin.prepare');
   [Sn,n,az,el] = spin(state);
   obj = SetSpin(obj,az,el,state);
   return
end

%==========================================================================
% Reset Apparatus
%==========================================================================

function obj = ResetApparatus(obj,total);
%
% RESET-APPARTUS  Reset measurement apparatus to blank state.
%                 Store results in setting('apparatus')
%
   appa = setting('apparatus');

   appa.value = 0;                    % set apparatus to blank state
   if (total)
      appa.histo = [];                % history
      appa.multi = 0;                 % clear multi measurement
      ClearDisplay(obj);
   end
   
   %fprintf('*** reset apparatus\n');   
   setting('apparatus',appa);
   obj = option(obj,'apparatus',appa);
   return
end

%==========================================================================
% Perform Measurement
%==========================================================================

function Measurement(obj,number);
%
% MEASUREMENT  Perform measurement
%
   profiler('Measurement',1);

      % if apparatus is already in a result state (showing +1 or -1)
      % we simply reset the apparatus to the blank state and return

   value = option(obj,'apparatus.value');
   if (value ~= 0)
      ResetApparatus(obj,0);
      profiler('Measurement',0);
      return
   end

      % otherwise the apparatus is in the blank state and we can perform
      % the actual measurement

   if (nargin < 2)
      number = 1;        % only 1 measurement by default
   end
   
      % get current spin operator with according eigen vectors of
      % measurement apparatus
      
   az = option(obj,'apparatus.az');
   el = option(obj,'apparatus.el');
      
   for (i=1:number)
      state = setting('spin.state');            % get spin state
      Sn = spin(space(state),az,el);            % spin operator
      [p,m] = spin(Sn);                         % plus & minus (eigen vectors)

         % perform measurement

      Pp = state'*p*p'*state;                   % probability(+1)
      Pm = state'*m*m'*state;                   % probability(-1)

      assert(abs(Pp+Pm-1) < 30*eps);

      r = rand;                                 % a randum number 0 <= r <= 1
      value = iif(r<=Pp,+1,-1);                 % random result 
      Display(obj,value);
      
      if (i < number)
         PrepareSpin(obj);
      end
   end
   
      % update apparatus with result of measurment
      
   setting('apparatus.value',value);         % result of measurement
   setting('apparatus.Sn',Sn);               % spin operator

      % decrement counter for multi measurement

   multi = setting('apparatus.multi');
   if (multi > 0)
      setting('apparatus.multi',multi-1);
   end

      % update spin state
   
   state = iif(value>0,p,m);
   
   [Sn,n,az,el] = spin(state);
   SetSpin(obj,az,el,state);

   %beep
   profiler('Measurement',0);
   return
end

%==========================================================================
% Prepare for Multi Measurement
%==========================================================================

function Multi(obj,number);
%
% MULTI  Prepare for multi measurement
%
   setting('apparatus.multi',number);
   return
end

%==========================================================================
% Draw  Apparatus
%==========================================================================

function [az,el] = Draw(obj,az,el)
%
% DRAW   Draw apparatus
%
   profiler('Draw',1);
   
   aznew = setting('apparatus.az');
   elnew = setting('apparatus.el');
   dphi = pi/8/3;
   
   if (az > aznew)
      az = max(aznew,az-dphi);
   elseif (az < aznew)
      az = min(aznew,az+dphi);
   elseif (el > elnew)
      el = max(elnew,el-dphi);
   elseif (el < elnew)
      el = min(elnew,el+dphi);
   end

   obj = option(obj,'azimuth',az,'elongation',el);
      

   col = 'b';  alfa = 1;
   
   b.o = 2;  % offset x for body
   b.x = 0.2;
   b.y = 0.4;
   b.z = 3;  % height of body
   
   t.x = b.o;
   t.y = 0.4;    % top cover
   t.z = 0.2;
   t.o = t.x/2 - b.x/2 - b.o;
   
   c.r = 0.5;
   c.c = 1.3*c.r;   % cone peek
   c.h = 0.4;
   c.o = b.z/2 + t.z/2;
   
   %Brick(obj,[b.x b.y b.z],[-b.o 0 0],col,alfa);
   %Brick(obj,[t.x t.y t.z],[t.o 0 b.z/2+t.z/2],col,alfa);
   %Brick(obj,[t.x t.y t.z],[t.o 0 -b.z/2-t.z/2],col,alfa);

   value = option(obj,'apparatus.value');
   colp = iif(value>0,'r','b');
   colm = iif(value<0,'r','b');

   Cone(obj,c.r,c.c,[0 0 c.o+c.h/2+c.c/2],colp,alfa);
   Cylinder(obj,c.r,c.h,[0 0 c.o],colp,alfa);
   Cylinder(obj,c.r,c.h,[0 0 -c.o],colm,alfa);

   value = option(obj,'apparatus.value');
   
   radius = b.z/2+t.z/2;
   thick = 0.3*c.h;  width = 1.8*c.h;  chamfer = 0.05/2;
   Bow(obj,radius,thick,width,[-0*c.r,0,0],'b');
   Cube(obj,width-4*chamfer,chamfer,[-radius-width/2-2*chamfer 0 0],value,'b');

   d = 3;
   col = 0.5*[1 1 1];    % color of the axes and axes labels
   
   update(gao,color(text(d+0.2,0,0,'+x'),col));
   update(gao,color(text(-d-0.3,0,0,'-x'),col));
   update(gao,color(text(0,d+0.2,0,'+y'),col));
   update(gao,color(text(0,-d-0.2,0,'-y'),col));
   update(gao,color(text(0,0,d+0.2,'+z'),col));
   update(gao,color(text(0,0,-d-0.2,'-z'),col));

   hdl(1) = color(plot3([-d d],[0 0],[0 0],'-.'),col);
   hdl(2) = color(plot3([0 0],[-d d],[0 0],'-.'),col);
   hdl(3) = color(plot3([0 0],[0 0],[-d*0.9 d],'-.'),col);
   update(gao,hdl);

   col = 'b';    % color of the apparatus axis

   [x,y,z] = rot(obj,[0 0],[0 0],[-2.5 3]*0.95);
   update(gao,color(plot3(x,y,z,'-.'),col,2));

   profiler('Draw',0);
   return
end

%==========================================================================
% Brick
%==========================================================================

function Brick(obj,whl,offset,col,alfa)
%
% BRICK  Draw a 3D brick with width: whl(1), height: whl(2) and length
%        whl(3) at offset.
%
%            Set options azimuth and elongation to control 3D rotation
%
%               obj = option(toy,'azimuth',pi/3);
%               obj = option(obj,'elongation',pi/4);
%               Brick(obj,whl,offset,col,alfa);
%
   profiler('Brick',1);
   
   [X,Y,Z] = cylinder([0 1 1 0]/sqrt(2),4);
   one = ones(size(Z(1,:)));
   Z=[-one;-one;one;one]/2;            % overwrite Z
   
   H = ones(size(X));
   C = cindex(obj,H,col);     % color indices

   T = diag(whl)*rotz(obj,pi/4);
   
      % rotation according to phase

   Xp = T(1,1)*X + T(1,2)*Y + T(1,3)*Z + offset(1); 
   Yp = T(2,1)*X + T(2,2)*Y + T(2,3)*Z + offset(2); 
   Zp = T(3,1)*X + T(3,2)*Y + T(3,3)*Z + offset(3);

   [X,Y,Z] = rot(obj,Xp,Yp,Zp);
   
      % surf plot body

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   update(gao,hdl);

   profiler('Brick',0);
   return
end

%==========================================================================
% Cylinder
%==========================================================================

function Cylinder(obj,r,h,offset,col,alfa)
%
% CYLINDER  Draw a 3D brick with width: whl(1), height: whl(2) and length
%           whl(3) at offset.
%
%           Set options azimuth and elongation to control 3D rotation
%
%              obj = option(toy,'azimuth',pi/3);
%              obj = option(obj,'elongation',pi/4);
%              Cylinder(obj,r,h,offset,col,alfa);
%
   profiler('Cylinder',1);
   
   [X,Y,Z] = cylinder([0 1 1 0],200);
   one = ones(size(Z(1,:)));
   Z=[-one;-one;one;one]/2;            % overwrite Z
   
   H = ones(size(X));
   C = cindex(obj,H,col);     % color indices

   T = diag([r r h]);
   
      % rotation according to phase

   Xp = T(1,1)*X + T(1,2)*Y + T(1,3)*Z + offset(1); 
   Yp = T(2,1)*X + T(2,2)*Y + T(2,3)*Z + offset(2); 
   Zp = T(3,1)*X + T(3,2)*Y + T(3,3)*Z + offset(3);
   
   [X,Y,Z] = rot(obj,Xp,Yp,Zp);
   
      % surf plot body

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   update(gao,hdl);

   profiler('Cylinder',0);
   return
end

%==========================================================================
% Cone
%==========================================================================

function Cone(obj,r,h,offset,col,alfa)
%
% BRICK  Draw a 3D brick with width: whl(1), height: whl(2) and length
%        whl(3) at offset.
%
   profiler('Cone',1);
   
   [X,Y,Z] = cylinder([0 1 0],200);
   one = ones(size(Z(1,:)));
   Z=[-one;-one;one]/2;            % overwrite Z
   
   H = ones(size(X));
   C = cindex(obj,H,col);     % color indices

   T = diag([r r h]);
   
      % rotation according to phase

   Xp = T(1,1)*X + T(1,2)*Y + T(1,3)*Z + offset(1); 
   Yp = T(2,1)*X + T(2,2)*Y + T(2,3)*Z + offset(2); 
   Zp = T(3,1)*X + T(3,2)*Y + T(3,3)*Z + offset(3);

   [X,Y,Z] = rot(obj,Xp,Yp,Zp);
   
      % surf plot body

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   update(gao,hdl);

   profiler('Cone',0);
   return
end

%==========================================================================
% Spinning Gem
%==========================================================================

function Gem(obj,offset,r,col,alfa)
%
% GEM  Draw a 3D Gem
%
   profiler('Gem',1);

   if (nargin < 2)
      offset = [0 0 0];
   end
   if (nargin < 3)
      r = 1;
   end
   if (nargin < 4)
      phi = 0;
   end
   if (nargin < 5)
      col = 'r';
   end
   if (nargin < 6)
      alfa = 1;
   end
   
   %[X,Y,Z] = cylinder(sqrt(3)/2*[0 1 1 1 0],6);
   [X,Y,Z] = cylinder(sqrt(3)/2*[0 1 1 0],6);
   Z = Z*2-1;
   
   H = ones(size(X));
   C = cindex(obj,H,col);     % color indices

      % rotation transformations
      
   T = r * rotz(obj,phi);        % spin rotation
   
      % rotation according to phase

   Xp = T(1,1)*X + T(1,2)*Y + T(1,3)*Z + offset(1); 
   Yp = T(2,1)*X + T(2,2)*Y + T(2,3)*Z + offset(2); 
   Zp = T(3,1)*X + T(3,2)*Y + T(3,3)*Z + offset(3);
   
   [X,Y,Z] = rot(obj,Xp,Yp,Zp);
   
      % surf plot body

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   update(gao,hdl);

   profiler('Gem',0);
   return
end

%==========================================================================
% Draw Bow of Apparatus
%==========================================================================

function Bow(obj,radius,thick,width,offset,col)
%
% BOW   Draw bow of measurement apparatus
%
   r = radius;
   o = offset;

   n = 50;                           % angle discretization 
   u = (-pi/2:pi/n:pi/2);
   v = thick*([0 1 1 0 0]-1/2);
   w = width*([0 0 1 1 0]-1/2);
   
   [U,V] = meshgrid(u,v);            % get UV-meshgrid
   [U,W] = meshgrid(u,w);            % get UW-meshgrid

   X = -(r+V).*cos(U);
   Y = W;
   Z = +(r+V).*sin(U);

   surf(obj,X+o(1),Y+o(2),Z+o(3),col);
   
   return
end

%==========================================================================
% Cube
%==========================================================================

function Cube(obj,field,chamfer,offset,value,col)
%
% CUBE
%
   if (nargin < 2)
      field = 0.7;
   end
   if (nargin < 3)
      chamfer = 0.02;
   end
   if (nargin < 4)
      offset = [-2.2 0 0];                    % offset
   end
   if (nargin < 5)
      value = 1;
   end
   if (nargin < 6)
      col = 'b';
   end

   o = offset;                      % offset
   s = field;  c = 2*chamfer;       % inner space (s) and chamfer width (c) 
   a = s+3*c;                       % thickness of cube

   u = [-s-[3 2 1 0]*c, s*[-3:3]/4, s+[0 1 2 3]*c]/2;   % total width = s+3*c
   v = [-s-[3 2 1 0]*c, s*[-3:3]/4, s+[0 1 2 3]*c]/2;   % total width = s+3*c
   
   [U,V] = meshgrid(u,v);           % get UV-meshgrid

   X = U;
   Y = V;
   W = ones(size(X));
   W(1,:) = 0*W(1,:);
   W(end,:) = 0*W(end,:);
   W(:,1) = 0*W(:,1);
   W(:,end) = 0*W(:,end);
   W(4:12,4:12) = 0*W(4:12,4:12);
   W = c/2*W + a/2;

   n = length(X);
   el = option(obj,'apparatus.el');
   
   if (el <= pi/2)
      C = DigitalUp(obj,n,value,col);
   else
      C = DigitalDown(obj,n,value,col);
   end
      % draw the cube
      
   tab = [0 0; 0 pi; 0 pi/2; pi/2 pi/2; pi pi/2; -pi/2 pi/2];
   for (i=1:size(tab,1))
      az = tab(i,1);  el = tab(i,2);
      [X,Y,Z] = rot(obj,U,V,W,az,el);
      surf(obj,X+o(1),Y+o(2),Z+o(3),C);
   end
   
   return
end

%==========================================================================
% Setup Color Indices for Digital Display
%==========================================================================

function C = DigitalUp(obj,n,value,col)
%
% DIGITAL  Setup color index matrix for a digital display
%
   C = cindex(obj,ones(n,n),col);       % cube's color indices   
   
      % if value ~= 0 we modify the color matrix in order to
      % display the value +1 or -1
      
   if (value ~= 0)
      B = cindex(obj,ones(n,n),'k');       % black color indices   
      b = B(1);

      i = 6;  j = 7;
      C(i,j) = b;  C(i+1,j) = b;  C(i-1,j) = b; 

      if (value > 0)
         C(i,j-1) = b;  C(i,j+1) = b;  
      end

      i = i + 3;  k = 5;  l = 10;
      for (j=k:l)
         C(i,j) = b;
      end
      %C(k,j-1) = b;  C(k,j+1) = b; 
      C(i-1,k+1) = b;
      
         % rotate
         
      n = length(C);
      for (k=1:0)
         for (i=1:n)
            B(:,i) = C(n+1-i,:)';
         end
         C = B;
      end
   end
   return
end

function C = DigitalDown(obj,n,value,col)
%
% DIGITAL  Setup color index matrix for a digital display
%
   C = cindex(obj,ones(n,n),col);       % cube's color indices   
   
      % if value ~= 0 we modify the color matrix in order to
      % display the value +1 or -1
      
   if (value ~= 0)
      B = cindex(obj,ones(n,n),'k');       % black color indices   
      b = B(1);

      i = 6+3;  j = 7;
      C(i,j) = b;  C(i+1,j) = b;  C(i-1,j) = b; 

      if (value > 0)
         C(i,j-1) = b;  C(i,j+1) = b;  
      end

      i = i - 3;  k = 5;  l = 10;
       for (j=k:l)
         C(i,j) = b;
      end
      C(i+1,l-1) = b;
      
   end
   return
end

%==========================================================================
% Setup Color Indices for Digital Display
%==========================================================================

function C = Digital1(obj,n,value,col)
%
% DIGITAL  Setup color index matrix for a digital display
%
   C = cindex(obj,ones(n,n),col);       % cube's color indices   
   
      % if value ~= 0 we modify the color matrix in order to
      % display the value +1 or -1
      
   if (value ~= 0)
      B = cindex(obj,ones(n,n),'k');       % black color indices   
      b = B(1);

      i = 7;  j = 6;
      C(i,j) = b;  C(i,j+1) = b;  C(i,j-1) = b; 

      if (value > 0)
         C(i-1,j) = b;  C(i+1,j) = b;  
      end

      j = j + 3;  k = 5;  l = 10;
      for (i=k:l)
         C(i,j) = b;
      end
      %C(k,j-1) = b;  C(k,j+1) = b; 
      C(l-1,j-1) = b;
      
         % rotate
         
      n = length(C);
      for (k=1:0)
         for (i=1:n)
            B(:,i) = C(n+1-i,:)';
         end
         C = B;
      end
   end
   return
end
