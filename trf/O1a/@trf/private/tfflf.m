function G = tfflf(omega)
%
% TFFLF	 Linear factor transfer function:
%
%            G = tfflf(omega)     % G(s) = 1 + s/omega
%            G = tfflf(0)         % G(s) = s
%            G = tfflf            % G(s) = s (short hand)
%
%         For non-zero omega construction a so called linear factor,
%         i.e. a transfer function
%
%		         	            1 + s / omega
%	              G(s)  =	-----------------
%			                           1
%
%	  If the argument is missing, the transfer function G(s) = s
%	  is generated. This is eqivalent to tfflf(inf).
%
%         See also TFFNEW, TFFQF
%

   if ( nargin == 0 )
      G = tffnew([1, 0],1);
   else
      if ( omega == 0 )
         G = tffnew([1, 0],1);
      elseif ( omega == inf )
         G = tffnew([1, 0],1);
      else
         G = tffnew([1/omega, 1], 1);
      end
   end
end
