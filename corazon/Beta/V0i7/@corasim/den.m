function oo = den(o)                   % Get CORASIM Denominator       
%
% DEN   Get the denominator polynomial of a CORASIM object
%
%          o = system(corasim,{[1 2],[3 4 5]});
%	        d = den(o)                  % => [3 4 5]
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM, NUM, SYSTEM
%
   switch o.type
      case {'strf','ztrf','qtrf','css','dss'}
         [num,den] = peek(o);
         oo = Trim(o,den);
      case {'szpk','zzpk','qzpk'}
         o = trf(o);
         [num,den] = peek(o);
         oo = Trim(o,den);
      case 'modal'
         o = trf(o);
         [num,den] = peek(o);
         oo = Trim(o,den);
      otherwise
         error('bad object type');
   end
end

%==========================================================================
% Helper
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading mantissa zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end