function obj = qf(obj,omega,zeta)
%
% QF      Quadratic factor transfer function. Short form for tffqf().
%         The first argument is just a dummy to access the TFF method.
%
%            G = qf(tff,omega,zeta)
%            G = qf(tff,omega)        % zeta = 1
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
%         See TFF, LF, QF

   if ( nargin < 2 )
      error('2 or 3 input arguments expected');
   elseif (nargin < 3)
      zeta = 1;
   else
      G = tffqf(zeta,omega);   % reverse order of args
   end
   
   obj = tff(G);

% eof
