function [oo,ooo] = loop(o)
%
% LOOP   Calculate closed loop transfer function from open loop transfer
%        function
%
%           T = loop(L)               % tracking
%           [T,S] = loop(L)           % tracking & sensitivity
%
%       See also: TRF, LF, QF
%
   if (~isa(o,'trf'))
      o = trf(o);
   end
   
   L = data(o);
   if (nargout <= 1)
      T = tffloop(L);
      oo = trf(T);
   else
      [T,S] = tffloop(L);
      oo = trf(T);
      ooo = trf(S);
   end
end
