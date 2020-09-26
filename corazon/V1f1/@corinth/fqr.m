function Gjw = fqr(o,om,i,j)
%
% FQR  Frequency response of transfer function.
%
%               G = trf(corinth,[2 3],[1 5 6])
%		          Gjw = Fqr(G,omega)
%
%	    Calculation of complex frequency response of a transfer function 
%      G(s) = num(s(/den(s) (omega may be a vector argument).
%	    The calculations depend on the type as follows:
%
%		     fqr(Gs,omega):  Gs(j*omega)		      (s-domain)
%		     fqr(Hz,omega):  Hz(exp(j*omega*Ts))	(z-domain)
%		     fqr(Gq,Omega):  Gq(j*Omega)		      (q-domain)
%
%      Remarks: system representations in modal form are computed in a 
%      special way to achieve good numerical results for high system orders
%
%          oo = system(o,A,B,C,D)      % let oo be a modal form
%          Fjw = rsp(oo,om,i,j)        % frequency response of Gij(j*om)
%
%      Copyright(c): Bluenetics 2020
%
%      See also: CORINTH, PEEK, TRIM, BODE
%
   switch o.type
      case 'trf'
         [num,den] = peek(o);
         jw = sqrt(-1)*om;
         Gjw = polyval(num,jw) ./ polyval(den,jw);
         
      otherwise
         error('bad type');
   end
end
