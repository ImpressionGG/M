function detector(obj,varargin)
%
% DETECTOR  Package handler for simple detector toy model demo
%
%       detector(toy,'Demo')                 % detector demo
%       detector(toy,'Draw');                % new drawing of detector
%       detector(obj,'KeyHit',key);          % handle key hit events
%       detector(obj,'Help');                % help for detector demo
%
%    See also: TOY, BALL, GEM, BRICK, APPARATUS
%
   [cmd,obj,list,func] = dispatch(obj,varargin);
   eval(cmd);
   return
end

%==========================================================================
% Detector Demo
%==========================================================================

function Demo(obj)
%
% DEMO  Run detector demo
%
   sceene(obj,'3D',-3:3); 
   camera('zoom',2.2,'spin',-20);  
  
   RadioButtonSetup(obj);             % setup radio buttons
   %view(obj,'Owner','Default',mfilename,'KeyHit');
   H = toy('detector');
   setting('toy.space',H);            % setup simple detector toy model
   
   obj = gfo;
   Draw(obj);
   Action(obj,'Init');                % initialize scenario
   
   ready;
   profiler('DetectorDemo',1);
   
   [t,dt] = timer(gao,0.1);  om = 3;

   while (control(gao))
      obj = gfo;                      % pull down obj from figure and pull
      s = option(obj,'toy.state');
      M = matrix(s);
      for (i=1:size(M,2))
         value = sum(M(:,i));
         if (value)
            pale(obj,value,[i-4 0 0],'r');                                      
         end
      end
      for (j=1:size(M,1))
         value = sum(M(j,:));
         if (value)
            pale(obj,value,[0 j 0],'r');                                      
         end
      end
      camera('spin',0.0);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   
   profiler('DetectorDemo',0);
   return
end

%==========================================================================
% Draw  Sceene
%==========================================================================

function [az,el] = Draw(obj)
%
% DRAW   Draw sceene
%
   profiler('Draw',1);
   
   obj = option(obj,'toy.space');
   side = 0.2;
   spaces = data(obj,'space.list');    % list of spaces
   
   xyz = get(obj,'position.L');      % location space site positions
   labels = property(spaces{1},'labels');
   for (i=1:size(xyz,2))
      hdl1 = Gem(obj,'cube','y',xyz(:,i),side);
      color(text(xyz(1,i),xyz(2,i),xyz(3,i)-2.5*side,labels{i}),'w');
   end

   [X,Y,Z] = cylinder(side/3*[1 1],50);
   [X,Y,Z] = rot(obj,X,Y,Z,roty(obj,pi/2));
   l = xyz(1,end) - xyz(1,1);
   hdl2 = surf(obj,X*l-l/2,Y,Z,'y');
   
   xyz = get(obj,'position.D');      % location space site positions
   labels = property(spaces{2},'labels');
   for (i=1:size(xyz,2))
      hdl3 = Gem(obj,'cube','b',xyz(:,i),side);
      text(xyz(1,i),xyz(2,i),xyz(3,i)-2.5*side,labels{i});
   end
   
   [X,Y,Z] = cylinder(side/3*[1 1],50);
   [X,Y,Z] = rot(obj,X,Y,Z,rotx(obj,-pi/2));
   l = xyz(2,end) - xyz(2,1);
   hdl4 = surf(obj,X,l+Y*l,Z,'b');

   profiler('Draw',0);
   return
end

%==========================================================================
% Radio Button Setup
%==========================================================================

function RadioButtonSetup(obj)
%
% RADIO-BUTTON-SETUP
%
   labels = {'Init','Next','Help'};
   hdl = radio(obj,labels,call('Action'));
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
   modifier = arg(obj,2);
   Action(obj,key);
   return
end

%==========================================================================
% Action
%==========================================================================

function Action(obj,mode)
%
% ACTION  Perform action
%
   if (nargin < 2)
      mode = arg(obj,1);
   end
   
   H = option(obj,'toy.space');
   
   switch mode
      case {'i','Init'}
         s = ket(H,'-1°0');        % initial state
         setting('toy.state',s);     % update state
      case {'n','Next'};
         s = setting('toy.state');
         T = operator(H,'T');
         s = T*s;
         setting('toy.state',s);     % update state
      case 'Help'
         msgbox('So far no help!');
   end
   
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
% Spinning Gem
%==========================================================================

function hdl = Gem(obj,type,col,offset,r,phi,alfa)
%
% GEM  Draw a 3D Gem
%
   profiler('Gem',1);

   type = eval('type','''standard''');
   offset = eval('offset','[0 0 0]');
   r = eval('r','1.0');
   phi = eval('phi','0.0');
   col = eval('col','''r''');
   alfa = eval('alfa','1.0');

   o = offset;
   
   switch type
      case 'flat'
         n = 6;
         h = [0  0  0.3 0.7  1  1];  
         radius = [0 0.5  1   1 0.5 0];
         p = [0:n]*2*pi/n;
         
         [P,R] = meshgrid(p,radius);
         [P,H] = meshgrid(p,h);
         
         X = R.*cos(P);  Y = R.*sin(P);  Z = H*2-1; 
         
      case 'cube'
         n = 8;
         h = [0  0  0.1 0.9  1  1];  
         radius = 1.2*[0 0.75  1   1 0.75 0];
         p = [0:n]*2*pi/n + [1 -1 1 -1 1 -1 1 -1 1]*1.3*pi/n/2 + pi/n;
         
         [P,R] = meshgrid(p,radius);
         [P,H] = meshgrid(p,h);
         
         X = R.*cos(P);  Y = R.*sin(P);  Z = H*2-1; 
         
      otherwise
         [X,Y,Z] = cylinder(sqrt(3)/2*[0 1 1 0],6);
         Z = Z*2-1;
   end
   
      % rotation transformations
      
   T = r * rotz(obj,phi);        % spin rotation
   
      % rotation according to phase

   [Xp,Yp,Zp] = rot(obj,X,Y,Z,T);
   [X,Y,Z] = rot(obj,Xp,Yp,Zp);
   
      % surf plot body

   hdl = surf(obj,X+o(1),Y+o(2),Z+o(3),col);
   if (nargout == 0)
      update(gao,hdl);
   end
   
   profiler('Gem',0);
   return
end

