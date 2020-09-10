function oo = qtf(o,Ts)
%
% CAN   Cancel poles & zeros of a transfer function if possible
%
%            G = can(G)
%
%       See also: TRF, LF, QF
% QTF   Q-Transformation.
%
%            Gq = qtf(Gs,Ts)
%            Gq = qtf(Gz)
%
%       Gq = qtf(Gs,Ts) calculates the q-transform Gq corresponding to the
%       continuous system transfer function Gs and a given sampling period
%       Ts.
%
%	     If a discrete system transfer function Gz is given, Gq = qtf(Gz)
%       calculates  the corresponding  q-transform  performing	the variable
%	     substitution
%
%			       Omega0 + q
%		     z = ------------ ,  Omega0 = 2/Ts
%			       Omega0 - q
%
%	     See TRF, ZTF.
%
   if (~isa(o,'trf'))
      o = trf(o);
   end
   
   G = data(o);
   switch o.type
      case 'strf'
         if (nargin < 2)
            error('Samplig time (arg2) missing!');
         end
         Gq = tffqtf(G,Ts);
         oo = trf(Gq);
      case 'ztrf'
         Gq = tffqtf(G);
         oo = trf(Gq);
      case 'qtrf'
         oo = o;
      otherwise
         error('bad transfer function type!')
   end
end
