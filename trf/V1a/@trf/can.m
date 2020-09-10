function oo = can(o)
%
% CAN   Cancel poles & zeros of a transfer function if possible
%
%            G = can(G)
%
%       See also: TRF, LF, QF
%
   if (~isa(o,'trf'))
      o = trf(o);
   end
   
   G = data(o);
   G = tffcan(G);
   
   oo = trf(G);
end
