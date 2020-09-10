function hdl = pale(obj,psi,z,col,trsp,mp,np);
%
% PALE   Pale plotting according to given psi function and z-space
%
%           hdl = pale(obj,psi,z,color,transparency)
%           hdl = pale(obj,psi,z,'r',0.5,mp,np)
%           hdl = pale(obj,psi,z,'r',0.5)           % mp = np = 10;
%
%           hdl = pale(obj,psi,z)   % color = 'r', transparency = 0.5
%
%        Length of pale equals magnitude of psi function
%        Radius of pale equals 1/4* dz_average; 
%        mp is the number of segments along the pale direction
%        np is the number of segments around the pale circumference
%
%        See also: QUANTANA, WING, BALLEY
%
   if (nargin < 4)  col = 0.5;  end
   if (nargin < 5)  trsp = 0.5; end
   if (nargin < 6)  mp = 10; end          % number of segments along pale
   if (nargin < 7)  np = 10; end          % number of segments around pale
   
   Lp = 1/pi*(max(z)-min(z));             % length of pale
   Lp = max(abs(psi));
   Rp = mean(sdiff(z)) / 4;              % radius of pale

      % prepare part of mesh grid for pale
      % (missing u is calculated in the loop)

   v  = 0 : 2*pi/np : 2*pi;               % cordinate around pale          

      % setup all pales

   hdl = [];
   for (j=1:length(z))
      zj = z(j);                          % z-coordinate of pale
      Lpj = Lp*abs(psi(j));               % actual length of pale
      phij = angle(psi(j));               % actual angle of pale

         % either a sphere or a pale is plotted ...


      if (Lpj < 1e-10)    % surf a sphere for zero like wave function

         [Xp,Yp,Zp] = sphere(np);
         shdl = surf(zj+2*Rp*Xp,2*Rp*Yp,2*Rp*Zp,'edgecolor','none'); 
      else
         r = [ 0 ones(size([0:1/mp:1])) 2 0]*Rp;% radial coordinate of pale
         u = [-Rp [0:1/mp:1]*Lpj Lpj Lpj+4*Rp];     % coordinate along pale
         [V,U] = meshgrid(v,u);            % get VU-meshgrid
         [V,R] = meshgrid(v,r);            % get VR-meshgrid

            % map meshgrid to pale

         Xp = R.*cos(V);
         Yp = R.*sin(V);
         Zp = U; 
         H = (U - min(u))/(Lp+5*Rp);

         H = min(H,1);
         C = cindex(obj,H,col);     % color indices

            % rotation according to phase

         Yj =  Yp*cos(phij) + Zp*sin(phij); 
         Zj = -Yp*sin(phij) + Zp*cos(phij); 

            % surf plot of pale

         shdl = surf(zj+Xp,Yj,Zj,C,'EdgeColor','none');
         hold on;
      end % if

      alpha(shdl,trsp);
      hdl = [hdl; shdl(:)];
      hold on;
   end % for
   update(smart,hdl);                % update control
   
   return
   
% eof