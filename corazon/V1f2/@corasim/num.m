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
         oo = num;
      otherwise
         error('bad object type');
   end
end
