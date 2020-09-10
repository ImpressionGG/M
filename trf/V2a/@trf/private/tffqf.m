function G = tffqf(zeta,omega)
%
% TFFQF	  Quadratic factor transfer function:
%
%            G = tffqf(zeta,omega);
%
%         G = tffqf(zeta,omega) construcs a so called quadratic factor,
%         i.e. the transfer function
%
%			1 + 2 s zeta / omega + s^2 / omega^2
%	     G(s)  =  -----------------------------------------
%					 1
%
%	  where zeta is the damping rate and omega the eigen frequency
%         of the quadratic factor.
%
%	  See TFFNEW, TFFLF
%
%

   G = tffnew([1/omega/omega, 2*zeta/omega, 1], 1);

% eof
