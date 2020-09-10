function oo = matrix(o,M)
%
% MATRIX Construct a matrix of rational functions
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX
%
   if (nargin == 1)                    % casting
      oo = Cast(o);
   elseif (nargin == 2)
      oo = Matrix(o,M);
   else
      error('bad arg list');
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
