function hdl = wing(obj,psi,z,col,trsp,mp,np,Rp);
%
% WING   Wing plotting according to given psi function and z-space
%
%           hdl = wing(obj,psi,z,color,transparency)
%           hdl = wing(obj,psi,z,'r',0.5,mp,np)
%           hdl = wing(obj,psi,z,'r',0.5)           % mp = np = 10;
%
%           hdl = wing(obj,psi,z)   % color = 'r', transparency = 0.5
%
%        Radius of wing border tube equals 1/4* dz_average; 
%        np is the number of segments around the border tube circumference
%
%        See also: QUANTANA, PALE, BALLEY
%
   if (nargin < 4)  col = 0.5;  end
   if (nargin < 5)  trsp = 0.5; end
   if (nargin < 6)  mp = 10; end          % number of segments around tube
   if (nargin < 7)  np = 10; end          % number of segments around tube
   if (nargin < 8)
      Rp = mean(sdiff(z)) / 4;               % radius of pale
   end
   
   Lp = 1/pi*(max(z)-min(z));             % length of pale
   Lp = max(abs(psi));

      % prepare part of mesh grid for pale
      % (missing u is calculated in the loop)

   u = [0:1/(2*np):1];               % coordinate along wing
   [U,Z] = meshgrid(u,z);            % get UZ-meshgrid
   [U,R] = meshgrid(u,abs(psi));     % get UR-meshgrid
   [U,P] = meshgrid(u,angle(psi));   % get UP-meshgrid

      % map meshgrid to wing

   X = Z;
   Y = -R.*U.*sin(P);
   Z = R.*U.*cos(P);

   H = (U.*R)/max(R(:));
   H = min(H,1);                     % just be safe
   C = cindex(obj,H,col);            % color indices

      % surf plot of wing

   hdl1 = surf(X,Y,Z,C,'EdgeColor','none');
   alpha(hdl1,abs(trsp));

      % border tube of wing

   v = [0:1/(2*np):1];               % coordinate along wing
   [V,Z] = meshgrid(v,z);            % get VZ-meshgrid
   [V,R] = meshgrid(u,abs(psi));     % get VR-meshgrid
   [V,P] = meshgrid(u,angle(psi));   % get VP-meshgrid

   Y = -R.*sin(P) + Rp * min(1*R,1) .* sin(2*pi*V);
   Z =  R.*cos(P) + Rp * min(1*R,1) .* cos(2*pi*V);

   H = ones(size(H));                % just be safe
   C = cindex(obj,H,col);            % color indices

      % surf plot of wing border tube

   hdl2 = surf(X,Y,Z,C,'EdgeColor','none');
   alpha(hdl2,sqrt(abs(trsp)));

   hdl = [hdl1(:); hdl2(:)];
   update(smart,hdl);                % update control
   return
   
% eof