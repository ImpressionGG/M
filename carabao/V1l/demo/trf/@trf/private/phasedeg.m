function phi = PHASEDEG(f,phi1,phi2,n360)
%
% PHASEDEG Phase in degrees of a complex vector with respect to sca-
%	   ling parameters. The call
%
%		       phi = PHASEDEG(f,phi1,phi2)
%
%	  where f is assumed to be a complex vector representing a
%	  'continuous' function returns pointwise  the angle argu-
%	  ments which are as best as possible aligned in the inter-
%	  val [phi1,phi2].  If 'phi1' and 'phi2'  are omitted, the
%	  default scaling parameters 'TfPhaseLo' and 'TfPhaseHi' are
%	  used. To rearrange a phase vector the call
%
%	     phi = 180/pi * phase(exp(sqrt(-1)*pi/180*phi),phi1,phi2)
%
%	  may be used. Add n*360 degrees to the phase: PHASEDEG(f,phi1,phi2,n)
%
%	  (Control toolbox 1.0c - Copyright 1990/1991 by Hugo Pristauz)
%
   if ( nargin < 4 ) n360 = 0; end

   if ( exist('TfPhaseHi') == 0 )
      TfPhaseHi = 180;  TfPhaseLo = -180;
   end

   if ( nargin < 3 )
      phi2 = TfPhaseHi;
      if ( nargin < 2 )
	 phi1 = TfPhaseLo;
      end
   end

   if ( phi1 > phi2 ) phit = phi1; phi1 = phi2; phi2 = phit; end
   dphi  = 360;
   delta = 180;

   phi = angle(f) * 180/pi + n360*360;
   n = max(size(phi));

   p0 = phi(1);
   while(p0 > phi2 ) p0 = p0 - dphi; end
   while(p0 < phi1 ) p0 = p0 + dphi; end
   phi(1) = p0;

   for ( i=2:n )
      p = phi(i);
      if ( p > p0 )
	 while ( p-p0 > delta ) p = p - dphi; end
      else
	 while ( p0-p > delta ) p = p + dphi; end
      end
      while(p > phi2 ) p = p - dphi; end
      while(p < phi1 ) p = p + dphi; end
      phi(i) = p;  p0 = p;
   end

PHA=phi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Rev   Date        Who   Comment
%  ---   ---------   ---   --------------------------------------------
%    0   19-Nov-93   hux   Version 2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
