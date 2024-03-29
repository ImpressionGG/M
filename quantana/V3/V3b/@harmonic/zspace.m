function z = zspace(obj)
%
% ZSPACE    Return z-space of harmonic oscillator object
%
%              osc = harmonic(2,-10:0.1:10)   % define harmonic oscillator
%              z = zspace(osc)                % return z coordinates
%
%           Example
%              o = harmonic(2,-10:0.1:10)     % define harmonic oscillator
%              plot(zspace(o),eig(o,0:10));   % plot eigen function (0..10)
%
%           See also: HARMONIC, EIG, COHERENT
%
   dat = data(obj);
   z = dat.zspace(:);
   return

% eof