function n = order(o)                  % system order
%
% ORDER   Return system order which is either state dimension of a state
%         space or modal representation, or max degree of numerator or
%         denominator polynomial for transfer function representation or
%         max number of zeros or poles for zpk representations
%
%            n = order(o)              % return system order
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM, SYSTEM, TRF, ZPK
%
   switch o.type
      case {'css','dss'}
         A = data(o,'A');
         n = length(A);
         
      case {'modal'}
         a0 = data(o,'a0');
         n = 2*length(a0);
         
      case {'strf','ztrf','qtrf'}
         [num,den] = peek(o);
         n = max(length(num),length(den)) - 1;
         
      case {'szpk','zzpk','qzpk'}
         zeros = data(o,'zeros');
         poles = data(o,'poles');
         n = max(length(zeros),length(poles));
         
      otherwise
         n = NaN;
   end
end

         