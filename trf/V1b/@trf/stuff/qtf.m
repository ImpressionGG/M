function Gq = qtf(obj,Ts)
%
% QTF     Q-transformation.
%
%            Gq = qtf(Gs,Ts)
%            Gq = qtf(Gz)
%
%         Gq = qtf(Gs,Ts)  calculates the q-transform Gq corresponding
%         to the  continuous system transfer function Gs and a given
%         sampling period Ts.
%
%         If a discrete  system transfer  function Hz is given, the call
%         Gq = qtf(Gz) calculates  the corresponding  q-transform  perfor-
%         ming	the variable substitution
%
%			         Omega0 + q
%		       z = ------------ ,  Omega0 = 2/Ts
%			         Omega0 - q
%
%	  See TFF, ZTF, STF
%
     
   Gs = data(obj);
   if (nargin >= 2)
      Gq = tffqtf(Gs,Ts);
   else
      Gq = tffqtf(Gs);
   end
   Gq = tff(Gq);
   
   return
   
%eof   