function out = pale(obj,z,psi,col,trsp,mp,np);
%
% PALE   Pale plotting according to given psi function and z-space
%
%           hdl = pale(obj,z,psi,color,transparency)
%           hdl = pale(obj,z,psi,'r',0.5,mp,np)
%           hdl = pale(obj,z,psi,'r',0.5)           % mp = np = 10;
%
%           hdl = pale(obj,z,psi)   % color = 'r', transparency = 0.5
%
%        Length of pale equals magnitude of psi function
%        Radius of pale equals 1/4* dz_average; 
%        mp is the number of segments along the pale direction
%        np is the number of segments around the pale circumference
%
%        Options:
%           hdl = pale(option(obj,'offset',[x0 y0 z0]),z,psi) % set offset
%
%        Example 1:
%           pale(quantana,0,1);
%
%        Example 2:
%           pale(quantana,[-1 -0.5 0 0.5 1],[0 i 1 -1 0],'g');
%           camlight;
%           lighting gouraud;
%           axis off;
%           camera spinning
%
%        Example 3:
%           sceene(quantana);
%           pale(quantana,0,1, 'r',1,20,20);
%           pale(quantana,0,i, 'b',1,20,20);
%           pale(quantana,0,-1,'g',1,20,20);
%           pale(quantana,0,-i,'y',1,20,20);
%           camera('spinning',[0.1 10]);
%
%        See also: QUANTANA, WING, BALLEY
%
   if (nargin < 4)  col = 'r'; end
   if (nargin < 5)  trsp = 1; end
   if (nargin < 6)  mp = 1; end          % number of segments along pale
   if (nargin < 7)  np = 12; end         % number of segments around pale
   
   if (length(z) ~= length(psi))
      error('length of z (arg2) and psi (arg3) must match!');
   end

   o = either(option(obj,'offset'),[0 0 0]);
   
   %Lp = 1/pi*(max(z)-min(z));            % length of pale
   Lp = max(abs(psi));
   Rp = mean(sdiff(z)) / 4;               % radius of pale
   
      % now swap real and imaginary part of psi
      
   psi = -i*psi;
   
   if (Lp == 0) Lp = 1; end               % correct if weird Lp
   if (Rp == 0) Rp = Lp/8; end            % correct if weird Rp
      
      % prepare part of mesh grid for pale
      % (missing u is calculated in the loop)

   v  = 0 : 2*pi/np : 2*pi;               % cordinate around pale          

      % setup all pales

   hdl = [];  shdl = [];
   for (j=1:length(z))
      zj = z(j);                          % z-coordinate of pale
      Lpj = abs(psi(j));                  % actual length of pale
      phij = angle(psi(j));               % actual angle of pale

         % either a sphere or a pale is plotted ...

      caxis manual;  caxis([0 1]);

      if (Lpj < 1e-3)     % surf a sphere for zero like wave function
         if (0)
            [Xp,Yp,Zp] = sphere(np);
            C = cindex(obj,ones(size(Zp)),col);     % color indices
            shdl = surf(zj+2*Rp*Xp+o(1),2*Rp*Yp+o(2),2*Rp*Zp+o(3),C,'edgecolor','none'); 
         end
      else
         %r = [ 0 ones(size([0:1/mp:1])) 2 0]*Rp;% radial coordinate of pale
         %u = [-Rp [0:1/mp:1]*Lpj Lpj Lpj+4*Rp];     % coordinate along pale

         Rp = Lpj/10;
         r = [ 0 ones(size([0:1/mp:1])) 1.5 0]*Rp;% radial coordinate of pale
         u = [-Rp [0:1/mp:1]*Lpj Lpj Lpj+3*Rp ];     % coordinate along pale

         %r = [ 0 ones(size([0:1/mp:1])) 1.5 1.5 0]*Rp;% radial coordinate of pale
         %u = [-Rp [0:1/mp:1]*Lpj Lpj Lpj+2*Rp Lpj+2*Rp];     % coordinate along pale

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

         shdl = surf(zj+Xp+o(1),Yj+o(2),Zj+o(3),C,'EdgeColor','none');
         hold on;
      end % if

      alpha(shdl,trsp);
      hdl = [hdl; shdl(:)];
      hold on;
   end % for
   caxis([0 1]);                     % need to set again, as surf changes 
   
   update(smart,hdl);                % update control
   
   daspect([1 1 1]);                 % set uniform data aspect ratios
   if (nargout > 0)
      out = hdl;
   end
   return
   
% eof