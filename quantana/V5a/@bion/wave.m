function [psi,eco,Psit] = wave(obj,t)
%
% WAVE      Get wave function psi(z,t) at time t
%
%              hob = harmonic(2);   % create harmonic oscillator
%
%              psi = wave(hob,t);   % wave function psi(z,5) at time t
%              psi = wave(hob);     % wave function psi(z,0) at time t=0
%
%           Retrieving eigen functions at time t
%
%              [psi,eco,Psit] = wave(hob,t);   % Psit = [psi_0(t),...,psi_n(t)]
%           
%           See also: HARMONIC, HARMONIC/EIG
%
   if (nargin < 2) t = 0;  end
   if (nargin < 3) cut = 4;  end
   
   dat = data(obj);
   psi = dat.psi;  hbar = dat.hbar; 
      
      % Retrieve phi, our expansion coefficient vector,
      % calculate omega we and subsequently the time phasor
      % and apply time phasor to phi
         
   om = dat.energy/hbar;
   phasor = exp(-i*om*t);
   eco = dat.eco .* phasor;        % eco(t)
      
      % map eco(t) back to psi(t)
      
   psi = 0;
   for (j=1:length(eco(:)))
      psi = psi + dat.basis{j} * eco(j);
   end
   
   if (nargout >= 3)
      n = length(eco);
      for (j=1:n)
         Psit{j} = dat.basis{j}*eco(j);
      end
   end
   
   return
   
%eof   