function Hw = wtf(obj)
%
% WTF     w-transformation.
%
%            Hw = wtf(Gq)
%            Hw = wtf(Hz)
%
%         Hw = wtf(Gq)  calculates the w-transform Hw corresponding
%         to the discrete system transfer function Gq.
%
%         If a discrete  system transfer  function Gq is given, the call
%         Hw = wtf(Gq) calculates  the corresponding  w-transform  perfor-
%         ming	the variable substitution
%
%			                 z - 1
%		       q = Omega0 --------- ,  Omega0 = 2/Ts
%			                 z + 1
%
%	  See TFF, STF, QTF, ZTF
%
     
   Gq = data(obj);
   Hw = tffztf(Gq);
   
   return
   
%eof   