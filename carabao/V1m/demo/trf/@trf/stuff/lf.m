function obj = lf(obj,omega)
%
% LF      Linear factor transfer function. Short form for tfflf(). The
%         first argument is just a dummy to access the TFF method.
%
%            G = lf(tff,omega)
%            G = lf(tff)
%
%         Constructs a so called linear factor, i.e. a transfer function
%
%			              1 + s / omega
%	          G(s) =	-----------------
%			                    1
%
%	       If the argument is missing, the transfer function G(s) = s
%	       is generated. This is eqivalent to lf(tff,inf).
%
%         See also: TFF, LF, QF

   if ( nargin == 1 )
      G = tfflf;
   elseif ( nargin == 2 )
      G = tfflf(omega);
   end
   
   obj = tff(G);

% eof
