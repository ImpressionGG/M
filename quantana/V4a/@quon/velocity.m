function [v,ny,gradpsi] = velocity(obj,psi,z)
%
% VELOCITY  Get Bohmian velocity psi(z,t) at time t
%
%              eob = envi(quantana,'box');
%              qob = quon(eob);     % create particle in a box quon
%
%              z = zspace(qob);
%              [v,ny] = velocity(qob,psi,z);  % velocity at position z
%
%           Remark
%              ny := grad(psi)/psi
%
%           See also: QUON, WAVE, EIG
%
   zspc = zspace(obj);
   
   if any(size(zspc) ~= size(psi))
      error('dimensions of psi and zspace(obj) must match!');
   end
   
   if (nargin < 3) 
      z = zspc;
   end

      % calculate gradient of psi
      
   dz = 2e-10;                      % differential dz
   Zpm = [z(:)-dz/2, z(:)+dz/2]';   % a z matrix with plus/minus dz/2
   zpm = Zpm(:)';
   
   psi = normalize(psi);
   psiofz = interp1(zspace(obj),psi,z,'cubic');
   
   psipm = interp1(zspace(obj),psi,zpm,'cubic');
   Psipm = reshape(psipm,size(Zpm,1),size(Zpm,2));
   
   gradpsi = diff(Psipm)/dz;    % gradient of psi = dpsi/dz
   gradpsi = gradpsi(:);
   
   ny = gradpsi(:)./psiofz(:);
   
   m = data(obj,'m');
   hbar = data(obj,'hbar');
   
   v = hbar/m * imag(ny);   
   return
   
%eof   