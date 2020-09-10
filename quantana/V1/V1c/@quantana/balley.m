function hdl = pale(obj,P,z,col,trsp,np);
%
% BALLEY Balley plotting according to given psi function and z-space
%
%           hdl = balley(obj,P,z,color,trsp)
%           hdl = balley(obj,P,z,'r',0.5,np)
%           hdl = balley(obj,P,z,'r',0.5)           % np = 50;
%
%           hdl = pale(obj,P,z)   % color = 'g', transparency = 0.5
%
%        Length of pale equals magnitude of psi function
%        Radius of pale equals 1/4* dz_average; 
%        mp is the number of segments along the pale direction
%        np is the number of segments around the pale circumference
%
%        See also: QUANTANA
%
   if (nargin < 4)  col = 0.5;  end
   if (nargin < 5)  trsp = 0.5; end
   if (nargin < 6)  np = 100; end          % number of segments around pale
   
   Lp = 1/pi*(max(z)-min(z));             % length of pale
   Lp = max(abs(P));
   Rp = mean(sdiff(z)) / 4;              % radius of pale

      % prepare part of mesh grid for pale
      % (missing u is calculated in the loop)

    v = 0 : 2*pi/np : 2*pi;           % cordinate around balley          
   [V,Z] = meshgrid(v,z);            % get VZ-meshgrid
   [V,R] = meshgrid(v,P);            % get VR-meshgrid
  
      % map meshgrid to wing

   X = Z;
   Y = -R.*sin(V);
   Z =  R.*cos(V);

   H = ones(size(V));
   C = cindex(obj,H,col);            % color indices

      % surf plot of wing

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   alpha(hdl,abs(trsp));

   update(smart,hdl);                % update control
   return
   
% eof