function oo = ratio(o,num,den)
%
% RATIO  Construct a rational function
%
%        1) Rational function constructed from row vectors
%           
%           num = [3 4]
%           den = [1 5 6]
%           oo = ratio(o,num,den)      % create rational function
%
%           o = corinth                % base 1e6
%
%        2) Rational function constructed from polynomials
%
%           o = corinth                % base 1e6
%           p = poly(o,[3 4])          % numerator polynomial
%           q = poly(o,[1 5 6])        % denominator polynomial
%           oo = ratio(p,q)            % create rational function
%
%        3) Casting
%
%           oo = number(o,22,7)
%           oo = ratio(oo)             % cast number to a ratio
%
%           oo = poly(o,[1 5 6])
%           oo = ratio(oo)             % cast polynomial to a ratio
%
%           oo = ratio(o,[2 1],[1 5 6])
%           oo = ratio(oo)             % cast ratio to ratio (no action)
%
%           oo = matrix(o,[8.88])      % 1x1 matrix
%           oo = ratio(oo)             % cast 1x1 rational matrix to ratio
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX
%
   if (nargin == 1)                    % casting
      oo = Cast(o);
   elseif (nargin == 2)
      if iscell(num)
         oo = Matrix(o,num);
      elseif isa(num,'double')
         p = poly(o,num);
         q = poly(o,1);
         oo = Rational(p,q);
      else
         p = o;  q = num;                 % rename args
         oo = Rational(p,q);
      end
   elseif (nargin == 3)
      p = poly(o,num);
      q = poly(o,den);
      oo = Rational(p,q);
   else
      error('bad arg list');
   end
   oo = can(oo);
   oo = trim(oo);   
end

%==========================================================================
% Rational Function Construction
%==========================================================================

function oo = Rational(p,q)            % Construct Rational Function   
   if isa(q,'double')
      q = poly(p,q);
   end
   
   if ~isequal(p.type,'poly')
      error('polynomial expected (arg2)');
   end
   if ~isequal(q.type,'poly')
      error('polynomial expected (arg3)');
   end
   if (p.data.base ~= q.data.base)
      error('base mismatch');
   end
   
   oo = poke(corinth(p,'ratio'),NaN,p,q);
   oo = touch(oo);
end
function oo = Matrix(o,M)              % Construct Rational Matrix     
   assert(iscell(M));
   [m,n] = size(M);
   
   Num = {};  Den = {};
   for (i=1:m)
      Nrow = {};  Drow = {};
      for (j=1:n)
         oo = M{i,j};
         if ~isequal(oo.type,'matrix')
            error('arg2 must be a cell array of rational matrices');
         end
         [num,den,~] = peek(oo);
         Nrow = [Nrow,num];
         Drow = [Drow,den];
      end
      Num = [Num;Nrow];
      Den = [Den;Drow];
   end
   oo = poke(corinth(o,'matrix'),NaN,Num,Den);
end

%==========================================================================
% Cast Corinthian Object To a Rational Function
%==========================================================================

function oo = Cast(o)
   switch o.type
      case 'number'
         num = poly(o);  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
      case 'poly'
         num = o;  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
      case 'ratio'
         oo = o;                       % easy :-)
      case 'matrix'
         if (prod(size(o)) ~= 1)
            error('cannot cast non-scalar matrix to ratio');
         end
         oo = o.data.matrix{1};
      otherwise
         error('internal')
   end
end
