function oo = num(o)                   % Get CORASIM Numerator         
%
% NUM   Get the numerator polynomial of a CORASIM object
%
%          o = system(corasim,{[1 2],[3 4 5]});
%	        d = num(o)                  % => [1 2]
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM, DEN, SYSTEM
%
   switch o.type
      case {'strf','ztrf','qtrf','css','dss'}
         [num,den] = peek(o);
         oo = Trim(o,num);
      case 'modal'
         o = trf(o);
         [num,den] = peek(o);
         oo = Trim(o,num);
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