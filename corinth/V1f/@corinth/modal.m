function oo = modal(o,num,den)
%
% TRF    Construct a rational function in modal form
%
%        1) Rational function constructed from row vectors
%           
%           num = [3 4]
%           den = [1 5 6]
%           oo = trf(o,num,den)        % create rational function
%
%        Example:
%
%           omega = [2 8]';            % circular eigen frequencies
%           zeta = [0.1 0.1]';         % damping
%           a0 = omega.*omega;
%           a1 = 2*zeta.*omega;
%           psi = [1+0*a1,a1,a0];      % characteristic polynomials
%
%           num = psi(1,:) + psi(2,:)
%           den = conv(conv(psi(1,:),psi(2,:)),psi(3,:))
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, POLY, MATRIX
%
   if (nargin == 1)                    % casting
      error('implementation');
      oo = Cast(o);
   elseif (nargin == 2)
      if iscell(num)
         oo = Matrix(o,num);
      elseif isa(num,'double')
         p = num;  q = 1;
         oo = Trf(o,p,q);
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
      case 'trf'
         oo = o;                       % easy :-)
         
      case 'number'
         num = poly(o);  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         
      case 'poly'
         num = o;  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         
      case 'ratio'
         [on,od] = peek(o);
         num = real(on);
         den = real(od);
         oo = trf(o,num,den);          % trf of two row vectors
         
      case 'matrix'
         if (prod(size(o)) ~= 1)
            error('cannot cast non-scalar matrix to ratio');
         end
         oo = o.data.matrix{1};
         
      otherwise
         error('internal')
   end
end
