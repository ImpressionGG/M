function o = lf(omega)
%
% LF      Linear factor transfer function. Short form for tfflf().
%
%            G = lf(omega)
%            G = lf
%
%         Constructs a so called linear factor, i.e. a transfer function
%
%			              1 + s / omega
%	          G(s) =	-----------------
%			                    1
%
%	       If the argument is missing, the transfer function G(s) = s
%	       is generated. This is eqivalent to lf(inf).
%
%         See also: TRF, LF, QF

   if ( nargin == 0 )
      G = tfflf;
   elseif ( nargin == 1 )
      G = tfflf(omega);
   end
   o = trf(G);
end
