function [oo,y,e] = trim(o,x,y,e)      % Trim CORINTH Object or Mantissa  
%
% TRIM    Remove leading zeros
%
%            o = trim(o)               % trim object
%            x = trim(o,x)             % trim mantissa
%            [x,y,e] = trim(o,x,y,e)   % trim triple
%
%         See also: RAT
%
   if (nargin == 1)
      switch o.type
         case 'number'
            oo = TrimNumber(o);
         case 'poly'
            oo = TrimPoly(o);
         otherwise
            error('implemenation restriction!');
      end
   elseif (nargin == 2)
      oo = Trim(o,x);
   elseif (nargin == 4)
      [oo,y,e] = TrimTriple(o,x,y,e);
   end
end

%==========================================================================
% Trim Mantissa
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading and trailing zeros
%
   while (length(x) > 1)
      if (x(1) == 0)
         x(1) = [];
      else
         break;
      end
   end
   y = x;
end

%==========================================================================
% Trim Mantissa
%==========================================================================

function o = TrimNumber(o)              % Trim Rational Number         
%
% TRIMOBJ    Trim object: remove leading and trailing zeros and adjust
%            exponent accordingly
%
   expo = o.data.expo;
   num  = o.data.num;
   den  = o.data.den;

   [num,den,expo] = TrimTriple(o,num,den,expo);

   o.data.expo = expo;
   o.data.num = num;
   o.data.den = den;
end

%==========================================================================
% Trim Triple
%==========================================================================

function [x,y,e] = TrimTriple(o,x,y,e) % Trim Triple                   
%
% TRIMTRIPLE  Trim triple: remove leading and trailing zeros and adjust
%             exponent accordingly
%
   x = trim(o,x);
   y = trim(o,y);
   
   idx = find(x~=0);
   n = length(x);
   
   if (~isempty(idx) && length(idx) < n)
      i = idx(end);
      e = e + (n-i);
      x(:,i+1:end) = [];
   end
 
   idx = find(y~=0);
   n = length(y);
   
   if (~isempty(idx) && length(idx) < n)
      i = idx(end);
      e = e - (n-i);
      y(:,i+1:end) = [];
   end
end

%==========================================================================
% Trim Polynomial
%==========================================================================

function o = TrimPoly(o)               % Trim Polynomial               
%
% TRIMPOLY    Trim polynomial: remove leading and trailing zeros and adjust
%             exponent accordingly
%
   assert(isequal(o.type,'poly'));
   
   expo = o.data.expo;
   num = o.data.num;
   den = o.data.den;
   
   o.data.num = [];  o.data.den = [];
   for (i=1:length(expo))
      [x,y,e] = trim(o,num(i,:),den(i,:),expo(i));
      o.data.expo(i) = e;
      o.data.num(i,1:length(x)) = x;
      o.data.den(i,1:length(y)) = y;
   end
end


