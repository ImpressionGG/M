function [oo,den,xpo] = peek(o,i,j)    % Peek Corinthian Sub-Object    
%
% PEEK   Peek corinthian sub-object from corinthian mother object
%
%        1) Peek num, den and expo
%
%           [num,den,xpo] = peek(o)
%
%        2) Peek i-th polynomial coefficient
%
%           oo = poly(o,[1 5 6])       % corinthian polynomial
%           oi = peek(o,i)             % peek i-th coefficient (ratio)
%
%        3) Peek numerator or denominator or i-th numerator/denominator
%           coefficient of a rational function
%
%           oo = ratio(o,[1 5],[1 2 3])% rational function
%           on = peek(o,1)             % peek numerator
%           od = peek(o,2)             % peek denominator
%           oi = peek(o,1,j)           % peek j-th numerator coefficiient
%           oi = peek(o,2,j)           % peek j-th denominator coefficient
%
%        4) Peek i-th matrix element or i-j-th matrix element
%
%           oo = matrix(o,magic(3))    % corinthian matrix
%           oi = peek(oo,i)            % peek i-th matrix element
%           oij = peek(o,i,j)          % peek i-j-th matrix element
%
%        See also: CORINTH, PEEK, POKE
%
   if (nargout >= 2)                   % super fast access
      data = o.data;  xpo = data.expo;
      oo = data.num;  den = data.den;  
      return
   end
   
   switch o.type
      case 'poly'
         oo = PeekPoly(o,i);
      case 'ratio'
         if (nargin >= 3)
            oo = PeekRatio(o,i,j);
         else
            oo = PeekRatio(o,i);
         end
      case 'matrix'
         if (nargin >= 3)
            oo = PeekMatrix(o,i,j);
         else
            oo = PeekMatrix(o,i);
         end
      otherwise
         error('implementation restriction!');
   end
end

%==========================================================================
% Peek Polynomial Coefficient
%==========================================================================

function oo = PeekPoly(o,i)            % Peek Polynomial Coefficient   
   assert(isequal(o.type,'poly'));

   expo = o.data.expo;
   if (i < 0)
      error('index out of range!');
   end
   i = i+1;
      
   oo = type(o,'number');
   if (i > length(expo))
      oo.data.expo = 0;
      oo.data.num = 0;
      oo.data.den = 1;
   else
      oo.data.expo = expo(i);
      oo.data.num = o.data.num(i,:);
      oo.data.den = o.data.den(i,:);
   end
end

%==========================================================================
% Peek from Rational Function
%==========================================================================

function oo = PeekRatio(o,i,j)         % Peek from Rational Function   
%
% PEEKRATIO Peek from rational function
%
%              oo = PeekRatio(o,1)     % peek numerator polynomial
%              oo = PeekRatio(o,2)     % peek denominator polynomial
%
%              oo = PeekMatrix(o,1,j)  % peek j-th coeff from numerator
%              oo = PeekMatrix(o,2,j)  % peek j-th coeff from denominator
%
   assert(type(o,{'ratio'}));
   [num,den] = peek(o);
   
   switch i
      case 1
         oo = num;
      case 2
         oo = den;
      otherwise
         error('1 or 2 expected for index (arg2)');
   end
      
   if (nargin == 3)
      n = order(oo);
      if (j < 0 || j > n)
         oo = [];
      else
         oo = peek(oo,j);
      end
   end
end

%==========================================================================
% Peek Matrix Element (or Sub-Matrix)
%==========================================================================

function oo = PeekMatrix(o,i,j)        % Peek Matrix Element           
%
% PEEKMATRIX  Peek matrix element or sub matrix
%
%                oo = PeekMatrix(o,i)         % M{i}
%                oo = PeekMatrix(o,i,j)       % M{i,j}
%
%                oo = PeekMatrix(o,i,[])      % M(i,:)
%                oo = PeekMatrix(o,[],j)      % M(:,j}
%
   assert(type(o,{'matrix'}));
   M = o.data.matrix;
   [m,n] = size(M);
   
   if (nargin == 2)
      
      if (i < 1 || i > m*n)
         error('bad index (arg2)');
      end
      oo = M{i};
      
   elseif (nargin == 3)
      
      if (i < 1 || i > m)
         error('bad row index (arg2)');
      end
      if (j < 1 || j > n)
         error('bad column index (arg3)');
      end
      oo = M{i,j};
      
   end
end
