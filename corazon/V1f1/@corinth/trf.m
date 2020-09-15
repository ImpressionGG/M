function oo = trf(o,num,den)
%
% TRF    Construct a transfer function based on double valued coefficients
%
%        1) Rational function constructed from row vectors
%           
%           num = [3 4]
%           den = [1 5 6]
%           oo = trf(o,num,den)        % create rational function
%
%        2) Rational function constructed from polynomials
%
%           o = corinth                % base 1e6
%           p = poly(o,[3 4])          % numerator polynomial
%           q = poly(o,[1 5 6])        % denominator polynomial
%           oo = trf(p,q)              % create rational function
%
%        3) Casting
%
%           oo = number(o,22,7)
%           oo = trf(oo)               % cast number to a trf
%
%           oo = poly(o,[1 5 6])
%           oo = trf(oo)               % cast polynomial to a trf
%
%           oo = trf(o,[2 1],[1 5 6])
%           oo = trf(oo)               % cast ratio to ratio (no action)
%
%           oo = matrix(o,[8.88])      % 1x1 matrix
%           oo = trf(oo)               % cast 1x1 rational matrix to trf
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, POLY, MATRIX
%
   if (nargin == 1)                    % casting
      oo = Cast(o);
   elseif (nargin == 2)
      if iscell(num)
         oo = Matrix(o,num);
      elseif isa(num,'double')
         p = poly(o,num);
         q = poly(o,1);
         oo = Trf(p,q);
      else
         p = o;  q = num;              % rename args
         oo = Trf(o,p,q);
      end
   elseif (nargin == 3)
      %p = poly(o,num);
      %q = poly(o,den);
      oo = Trf(o,num,den);
   else
      error('bad arg list');
   end
   oo = can(oo);
   oo = trim(oo);   
end

%==========================================================================
% Transfer Function Construction
%==========================================================================

function oo = Trf(o,num,den)           % Construct Rational Function   
   if (~isa(num,'double') || size(num,1) ~= 1)
      error('double row vector expected for numerator (arg2)');
   end
   if (~isa(den,'double') || size(den,1) ~= 1)
      error('double row vector expected for denominator (arg3)');
   end
   
   oo = corinth(o,'trf');                % 'trf' typed output arg   
   oo = poke(oo,0,num,den);
   
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
      case 'trf'
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
