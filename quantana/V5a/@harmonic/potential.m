function [V,coeff] = potential(obj,F)
%
% POTENTIAL Return potential values of harmonic oscillator object according
%           to zspace
%
%              [V,coeff] = potential(harmonic(2,z))   % return potential values
%
%           Under influence of an electric force f
%
%              [V,coeff] = potential(harmonic(2,z),F) % additional Force
%
%           Example
%              o = harmonic(2,-10:0.1:10)     % define harmonic oscillator
%              plot(zspace(o),potential(o));  % plot eigen function (0..10)
%
%           Theorie:
%              Without force the potential of the harmonic oscillator has
%              the form
%                          V(z) = a^2 * z^2  where a^2 = m0/2 * omega0^2
%
%              Including an additional electric force F we get
%
%                          V(z) = a^2 * z^2 + F*z
%
%           See also: HARMONIC, EIG, COHERENT, ZSPACE
%
   if (nargin < 2) F = 0; end
      
   dat = data(obj);
   z = dat.zspace(:);
   m = dat.m;  omega = dat.omega;

   aa = 1/2*m*omega^2;  b = F/(2*aa);  c = aa*b*b;  
   coeff = [0 F aa];
   
   V = aa * z.^2 + (dat.F+F)*z;
   return

% eof