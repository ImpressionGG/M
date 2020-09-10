function psi = wave(obj,t,cut)
%
% WAVE      Get wave function psi(z,t) at time t
%
%              fob = gauss(free);   % create free particle wave packet
%
%              psi = wave(fob,5);   % wave function psi(z,5) at time t=5
%              psi = wave(fob,0:5); % wave function psi(z,5) at time t=0:5
%              psi = wave(fob);     % wave function psi(z,0) at time t=0
%
%           See also: FREE, GAUSS
%
   if (nargin < 2) t = 0;  end
   if (nargin < 3) cut = 4;  end
   
   dat = data(obj);
   psi = dat.psi;

   if (t ~= 0)
      dat = data(obj);
      hbar = dat.hbar;  m = dat.m; z = dat.zspace; 
      K = dat.k;  sigma = dat.sigma;  center = dat.center;
      
         % we calculate phi, the discrete Fourier transform of psi
         
      phi = dat.phi;           % phi = dft(quantana,psi);
      [k,om] = kspace(obj);      
      
         % As we have now omega we can calculate the time phasor
      
      phasor = exp(-i*om*t);
      phi = phi .* phasor;
      psi = dat.map*phi;      % psi = idft(quantana,phi);
      
      %[P,sigma] = prob(psi,z);
      
      if (~isnan(center) & ~isnan(cut))
         v = hbar*K/m;                 % group velocity: v = p/m
         center = center + v*t;        % move of group center
         upper = center + sigma*cut;
         lower = center - sigma*cut;
         fcut = 1./(1 + exp(2*(z-upper)/sigma) + exp(-2*(z-lower)/sigma));
         psi = psi .* fcut;            % cut off with exponential fading
      end
   end
   
   return
   
%eof   