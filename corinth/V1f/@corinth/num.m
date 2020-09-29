function oo = num(o)                   % Get Corinthian Numerator    
%
% NUM   Get the numerator polynomial of a rational number or function
%
%          o = base(corinth,1e6);      % corinthian base object (base 1e6)
%
%          oo = trf(o,[1 2],[3 4 5]);
%	        n = num(o)                  % => [1 2]
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORINTH, DEN, TRF, NUMBER, RATIO
%
   switch o.type
      case 'trf'
         [num,den] = peek(o);
         oo = num;
      case 'number'
         [num,den] = peek(o);
         oo = num;
      case 'poly'
         num = real(o);
      case 'ratio'
         oo = peek(o,1);
      case 'matrix'
         error('cannot return denominator of a matrix');
   end
end

