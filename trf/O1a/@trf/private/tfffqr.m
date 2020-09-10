function [ma,ph] = tfffqr(G,om,phi1,phi2)
%
% TFFFQR  Evaluate FREQUENCY RESPONSE of transfer function. The
%	  call
%		       [mgn, phase] = tfffqr(G,omega)
%
%	  calculates magnitude and phase of the frequency response
%	  of transfer function G (omega may be a vector argument).
%	  The calculations depend on the type and are sketched out
%	  below.
%
%		tfffqr(Gs,omega) ... Gs(j*omega)		(s-domain)
%		tfffqr(Hz,omega) ... Hz(exp(j*omega*Ts))	(z-domain)
%		tfffqr(Gq,Omega) ... Gq(j*Omega)		(q-domain)
%
%		tfffqr(Gs,omega,phi1,phi2)   ==> phi1 <= phi <= phi2
%
%	  See TFFNEW, TFFBODE, TFFMAGNI, TFFPHASE
%
%
   G = tfftrim(G);		 % remove leading zeros

   n360 = 0;

   m = max(size(G));
   num = G(1,2:m);
   den = G(2,2:m);

% Do not use 'ma = bode(num,den,om);'

   [class,kind] = ddmagic(G);
   if ( class ~= tffclass )
      error('Arg1 must be instance of tffclass')
   end

   if ( kind == 1 | kind == 3 )
      idx = find(om == inf);

      om(idx) = 1+0*idx;

      frsp_num = polyval(num,sqrt(-1)*om);
      frsp_den = polyval(den,sqrt(-1)*om);
      if ( length(idx) > 0 )
         if ( num(1) ~= 0 & den(1) == 0 )
            f = inf;
	 elseif ( num(1) == 0 & den(1) ~= 0 )
	    f = 0;
	 else
            f = num(1) / den(1);
         end;
         frsp_num(idx) = f*(1+0*idx);  frsp_den(idx) = 1+0*idx;
      end
   else
      Ts = G(2);
      z = exp(sqrt(-1)*om*Ts);
      frsp_num = polyval(num,z);
      frsp_den = polyval(den,z);
   end

   idx = find(frsp_den == 0 & frsp_num ~= 0);
   frsp_den(idx) = 1+0*idx;
   frsp_den(idx) = 1+0*idx;

   ma = abs(frsp_num) ./ abs(frsp_den);
   ma(idx) = inf*idx;

   j = sqrt(-1);
   if ( exist('TfPhaseHi') == 0 )
      TfPhaseHi = 180;  TfPhaseLo = -180;
   end

   if (nargin < 3) phi1 = TfPhaseLo; end
   if (nargin < 4) phi2 = TfPhaseHi; end

   ph = phasedeg(exp(j*(angle(frsp_num) - angle(frsp_den))),phi1,phi2,n360);

% eof
