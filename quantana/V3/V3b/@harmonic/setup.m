function [obj,psi,ev] = setup(obj,n)
%
% SETUP     Setup pre-calculated eigen functions of harmonic oscillator
%           for index 0..n.
%
%              osc = harmonic(2,-10:0.1:10)  % define harmonic oscillator
%              osc = setup(osc,50)           % setup 0..50 eigen functions
%              osc = setup(osc)              % same as setup(osc,50)
% 
%           This alows faster calculation fore methods EIG and COHERENT
%
%           To retrieve also psi-matrix and eigenvalues
%
%              [osc,psi,ev] = setup(osc,50)  % retrieve also psi-matrix &ev
%
%           See also: HARMONIC, EIG, COHERENT
%
   if (nargin < 2)  n = 50;  end

   if (length(n) ~= 1 || any(floor(n) ~= n))
      error('n must be an integer scalar (arg 2)!');
   end
   
   [psi,ev] = eig(obj,0:n);
   obj = set(obj,'psi',psi);
   return

% eof