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
         oo = den;
      otherwise
         error('bad object type');
   end
end

