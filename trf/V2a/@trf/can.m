function oo = can(o,epsi)
%
% CAN   Cancel poles & zeros of a transfer function if possible
%
%            G = can(G)
%            G = can(G,epsi)
%
%       See also: TRF, LF, QF
%
   if (~isa(o,'trf'))
      o = trf(o);
   end
   
   G = data(o);
   if (nargin >= 2)
      G = tffcan(G,epsi);
   else
      G = tffcan(G);
   end
   
   oo = trf(G);
end
