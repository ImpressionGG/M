function [psi,eco,Psit] = wave(obj,t)
%
% WAVE      Get wave function psi(z,t) at time t
%
%              eob = envi(quantana,'box');
%              qob = quon(eob);            % create particle in a box quon
%
%              psi = wave(qob,t);   % wave function psi(z,5) at time t
%              psi = wave(qob);     % wave function psi(z,0) at time t=0
%
%           Retrieving more details
%
%              [psi,eco,Psit] = wave(qob,t);
%
%                 % psi(x1,x2,t) = psi1(x1,t)*psi2(x2,t)
%                 % psi1(x1,t)      % wave function of particle 1
%                 % psi2(x2,t)      % wave function of particle 2
%                 % Psit = [psi_ij(t)]
%           
%           See also: QUON, EIG
%
   if (nargin < 2) t = 0;  end
   if (nargin < 3) cut = 4;  end
   
   dat = data(obj);
   psi = dat.psi;  hbar = dat.hbar;  m = dat.m; z = dat.zspace; 
      
      % Retrieve phi, our expansion coefficient vector,
      % calculate omega we and subsequently the time phasor
      % and apply time phasor to phi
         
   om = dat.energy(:)/hbar;
   phasor = exp(-i*om*t);
   eco = dat.eco .* phasor;        % phi(t)
      
      % map phi(t) back to psi(t)
      
   psi = dat.map * eco;     % psi at time t=0
   
   if (nargout >= 3)
      n = length(eco);
      for (j=1:n)
         Psit(:,j) = dat.map(:,j)*eco(j);
      end
   end
   
   return
   
%eof   