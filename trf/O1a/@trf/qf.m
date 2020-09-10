function o = qf(omega,zeta)
%
% QF      Quadratic factor transfer function. Short form for tffqf().
%
%            G = qf(omega,zeta)
%            G = qf(omega)            % zeta = 1
%
%         G = qf(omega,zeta) constructs a so called quadratic factor,
%         i.e. the transfer function
%
%	            	       1 + 2 s zeta / omega + s^2 / omega^2
%	          G(s)  =  -----------------------------------------
%					                           1
%
%	       where zeta is the damping rate and omega the eigen frequency
%         of the quadratic factor.
%
%         See TRF, LF, QF

   if ( nargin < 1 )
      error('one or two input arguments expected');
   elseif (nargin < 2)
      zeta = 1;
   end
   
   G = tffqf(zeta,omega);
   o = trf;
   o.data = G;
end
