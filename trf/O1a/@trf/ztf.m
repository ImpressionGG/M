function oo = ztf(o,Ts)
%
% ZTF     z-transformation.
%
%            Hz = ztf(Gs,Ts)
%            Hz = ztf(Gq)
%
%         Hz = ztf(Gs,Ts)  calculates the z-transform Gz corresponding
%         to the  continuous system transfer function Gs and a given
%         sampling period Ts.
%
%         If a discrete  system transfer  function Gq is given, the call
%         Hz = ztf(Gq) calculates  the corresponding  z-transform  perfor-
%         ming	the variable substitution
%
%			                 z - 1
%		       q = Omega0 --------- ,  Omega0 = 2/Ts
%			                 z + 1
%
%	  See TFF, STF, QTF, WTF
%
     
   Gs = o.data;
   if (nargin >= 2)
      Hz = tffztf(Gs,Ts);
   else
      Hz = tffztf(Gs,1);
   end
   oo = trf(Hz);
end
