function [Gjw,om] = fqr(o,om,i,j)
%
% FQR  Frequency response of transfer function.
%
%         G = trf(corinth,[2 3],[1 5 6])
%		    Gjw = Fqr(G,omega)
%
%      Auto omega:
%
%		    [Gjw,omega] = Fqr(G)
%		    [Gjw,omega] = Fqr(G,[],i,j)
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
   if (nargin == 1)
      oml = opt(o,{'omega.low',1e-5});
      omh = opt(o,{'omega.high',1e5});
      points = opt(o,{'omega.points',1000});
      om = logspace(log10(oml),log10(omh),points);
   end

   switch o.type
      case 'trf'
         [num,den] = peek(o);
         jw = sqrt(-1)*om;
         Gjw = polyval(num,jw) ./ polyval(den,jw);
         
      otherwise
         error('bad type');
   end
end

%==========================================================================
% Helper
%==========================================================================

function omega = Lim(o)  % Get Limits                    

      % omega limits
      
   omega = shelf(o,gca,'omega');
   omega = o.either(omega,[1e-1,1e5]);
   
   omega(1) = opt(o,{'omega.low',omega(1)});
   omega(2) = opt(o,{'omega.high',omega(2)});

      % magnitude limits
      
   magni = shelf(o,gca,'magnitude');
   magni = o.either(magni,[-80,80]);

   magni(1) = opt(o,{'magnitude.low',magni(1)});
   magni(2) = opt(o,{'magnitude.high',magni(2)});

      % phase limits
      
   phase = shelf(o,gca,'phase');
   phase = o.either(phase,[-270,90]);

   phase(1) = opt(o,{'phase.low',phase(1)});
   phase(2) = opt(o,{'phase.high',phase(2)});
end