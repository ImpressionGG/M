function oo = den(o)                   % Get Corinthian Denominator    
%
% DEN   Get the denominator polynomial of a rational number or function
%
%          o = base(corinth,1e6);      % corinthian base object (base 1e6)
%
%          oo = trf(o,[1 2],[3 4 5]);
%	        d = den(o)                  % => [3 4 5]
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORINTH, NUM, TRF, NUMBER, RATIO
%
   switch o.type
      case 'trf'
         [num,den] = peek(o);
         oo = den;
      case 'number'
         [num,den] = peek(o);
         oo = den;
      case 'poly'
         den = 1;
      case 'ratio'
         oo = peek(o,2);
      case 'matrix'
         error('cannot return denominator of a matrix');
   end
end

