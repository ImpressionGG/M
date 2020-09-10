function oo = inv(o,M)
%
% INV    invert a matrix (or corinthian object)
%
%           M = matrix(o,magic(3))
%           InvM = inv(M)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX, DET
%
   switch o.type
      case 'number'
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'poly'
         o = ratio(o);
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'ratio'
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'matrix'
         oo = o;                       % easy :-)
      otherwise
         error('internal')
   end
end

%==========================================================================
% Rational Matrix Construction
%==========================================================================

function oo = Matrix(o,M)              % Construct Rational Matrix     
   [m,n] = size(M);
   if isa(M,'double')
      A = M;  M = {};
      for (i=1:m)
         for (j=1:n)
            M{i,j} = number(o,A(i,j));
         end
      end
   end
   
   if ~iscell(M)
      error('cell arrax expected (arg2)');
   end
   
      % convert to rational function matrix
   
   for (i=1:m)
      for (j=1:n)
         oo = M{i,j};
         switch oo.type
            case 'number'
               M{i,j} = ratio(poly(oo),poly(o,1));
            case 'poly'
               M{i,j} = ratio(oo,poly(o,1));
            case 'ratio'
               'ok';                   % data format ok, nothing to change
            otherwise
               error('implementation');
         end
      end
   end
   
   oo = corinth(o,'matrix');
   oo.data.matrix = M;
end

%==========================================================================
% Cast Corinthian Object To a Matrix of Rational Functions
%==========================================================================

function oo = Cast(o)
   switch o.type
      case 'number'
         num = poly(o);  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         oo = Cast(oo);                % cast ratio to matrix
      case 'poly'
         num = o;  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         oo = Cast(oo);                % cast ratio to matrix
      case 'ratio'
         oo = matrix(o,{o});           % cast ratio to matrix
      case 'matrix'
         oo = o;                       % easy :-)
      otherwise
         error('internal')
   end
end
