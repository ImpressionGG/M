function [mgn,phase] = fqr(obj,omega)
%
% FQR    Evaluate frequency response of transfer function. The call
%
% 		      [mgn, phase] = fqr(G,omega)
% 
%    	   calculates magnitude and phase of the frequency response
% 	      of transfer function G (omega may be a vector argument).
%        The calculations depend on the type and are sketched out
% 	      below.
% 
% 		      fqr(Gs,omega) ... Gs(j*omega)		         (s-domain)
% 		      fqr(Hz,omega) ... Hz(exp(j*omega*Ts))  	(z-domain)
% 		      fqr(Gq,Omega) ... Gq(j*Omega)		         (q-domain)
% 
% 		      fqr(Gs,omega,phi1,phi2)   ==> phi1 <= phi <= phi2
% 
%       See also: TFF, BODE, MAGNI, PHASE
%
     
   G = data(obj);
   [mgn,phase] = tfffqr(G,omega);
   
   return
   
%eof   