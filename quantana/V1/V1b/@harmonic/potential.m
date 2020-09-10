function V = potential(obj)
%
% POTENTIAL Return potential values of harmonic oscillator object according
%           to zspace
%
%              V = potential(harmonic(2,z))   % return potential values
%
%           Example
%              o = harmonic(2,-10:0.1:10)     % define harmonic oscillator
%              plot(zspace(o),potential(o));  % plot eigen function (0..10)
%
%           See also: HARMONIC, EIG, COHERENT, ZSPACE
%
   dat = data(obj);
   z = dat.zspace(:);
   m = dat.m;  omega = dat.omega;

   V = 1/2*m*omega^2 * z.^2;
   return

% eof