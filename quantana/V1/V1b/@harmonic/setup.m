function obj = setup(obj,n)
%
% SETUP     Setup pre-calculated eigen functions of harmonic oscillator
%           for index 0..n.
%
%              obj = harmonic(2,-10:0.1:10)  % define harmonic oscillator
%              obj = setup(obj,50)           % setup 0..50 eigen functions
%
%           This alows faster calculation fore methods EIG and COHERENT
%
%           See also: HARMONIC, EIG, COHERENT
%
   if (length(n) ~= 1 || any(floor(n) ~= n))
      error('n must be an integer scalar (arg 2)!');
   end

   psi = eig(obj,0:n);
   obj = set(obj,'psi',psi);
   return

% eof