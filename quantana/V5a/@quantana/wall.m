function out = wall(obj,z,psi,col,trsp,mp,np,Rp);
%
% WALL   Wall plotting according to given psi function and z-space
%
%           hdl = wall(obj,z,psi,color,transparency)
%           hdl = wall(obj,z,psi,'r',0.5,mp,np)
%           hdl = wall(obj,z,psi,'r',0.5)           % mp = np = 10;
%
%           hdl = wall(obj,z,psi)   % color = 'r', transparency = 0.5
%
%        Radius of wall border tube equals 1/4* dz_average; 
%        np is the number of segments around the border tube circumference
%
%        Options:
%           hdl = wall(option(obj,'wing.ripple',0.3),z,psi)   % set ripple
%           hdl = wall(option(obj,'offset',[x0 y0 z0]),z,psi) % set offset
%
%        See also: QUANTANA, PALE, BALLEY, WING
%
   profiler('Wall',1);

   if (nargin < 4)  col = 'r';  end
   if (nargin < 5)
      trsp = either(option(obj,'wing.transparency'),0.9);
   end
   if (nargin < 6)  mp = 10; end          % number of segments around tube
   if (nargin < 7)  np = 10; end          % number of segments around tube
   if (nargin < 8)
      Rp = mean(sdiff(z)) / 2;            % radius of border tube
   end
 
      % handle multiple wing option
      
   multi = floor(either(option(obj,'wing.multi'),1));
   if (multi > 1)
      obj = option(obj,'wing.multi',1);  % reset to multi = 1
      for (j=1:multi)
         phasor = exp(i*2*pi/multi*(j-1));
         hdl = [];
         hdl = [hdl,wing(obj,z,psi*phasor,col,trsp,mp,np,Rp)];
      end
      if (nargout > 0)
         out = hdl;
      end
      return
   end
   
      % continue to draw a single wing
   
   ripple = either(option(obj,'wing.ripple'),0);
   o = either(option(obj,'offset'),[0 0 0]);
   
      % now swap real and imaginary part of psi
      
   psi = imag(psi) + i*real(psi);
   
   Lp = 1/pi*(max(z)-min(z));             % length of pale
   Lp = max(abs(psi));
   if (Rp > 0)
     % Rp=Lp/30;     % was Lp/20
   end
   
      % prepare part of mesh grid for wing
      % (missing u is calculated in the loop)

   u = [0:1/(2*np):1];               % coordinate along wing
   s = rem(1:length(psi),2);         % ripple sequence
   [U,Z] = meshgrid(u,z);            % get UZ-meshgrid
   [U,R] = meshgrid(u,abs(psi));     % get UR-meshgrid
   [U,P] = meshgrid(u,angle(psi));   % get UP-meshgrid
   [U,S] = meshgrid(u,s);            % get VS-meshgrid

   S = ones(size(S)) - S*ripple;

      % map meshgrid to wing

   X = Z;
   Y = -R.*S.*U.*sin(P);
   Z = R.*S.*U.*cos(P);

   H = (U.*R)/max(R(:));
   H = min(H,1);                     % just be safe
   C = cindex(obj,H,col);            % color indices

      % surf plot of wing

   hdl1 = surf(X+o(1),Y+o(2),Z+o(3),C,'EdgeColor','none');
   alpha(hdl1,abs(trsp));

      % border tube of wing

   v  = pi/4*([1 3 5 7 9] + 0.8*[-1 +1 -1 +1 -1]); 
   v  = 2*pi*(0:1/20:1); 
   %v  = pi/4*[1 3]; 
   %Rp = 4*Rp;
   [V,Z] = meshgrid(v,z);            % get VZ-meshgrid
   [V,R] = meshgrid(v,abs(psi));     % get VR-meshgrid
   [V,P] = meshgrid(v,angle(psi));   % get VP-meshgrid
   
   X = Z;
   Y = -R.*sin(P) + Rp * sin(V);
   Z =  R.*cos(P) + Rp * cos(V);

   H = ones(size(X));                % just be safe
   C = cindex(obj,H,col);            % color indices

      % surf plot of wing border tube

   hdl2 = surf(X+o(1),Y+o(2),Z+o(3),C,'EdgeColor','none');
   alpha(hdl2,sqrt(abs(trsp)));

   hdl = [hdl1(:); hdl2(:)];
   update(smart,hdl);                % update control
   
   if (nargout > 0)
      out = hdl;
   end
   
   profiler('Wall',0);
   return
   
% eof