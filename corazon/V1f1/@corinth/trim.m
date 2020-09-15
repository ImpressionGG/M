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
   if (nargin == 1 && isequal(work(o,'trim'),1))  
      oo = o;                    
      return                           % object already trimmed - bye!
   end

   if (nargin == 1)      
      corazon.profiler('trim',1);
   
      switch o.type
         case 'trf'
            oo = Trf(o);
         case 'number'
            oo = Number(o);
         case 'poly'
            oo = Poly(o);
         case 'ratio'
            oo = Ratio(o);
         case 'matrix'
            oo = Matrix(o);
         otherwise
            error('internal');
      end
      
      oo.work.trim = true;             % mark as trimmed
      corazon.profiler('trim',0);
   elseif (nargin == 2)
      oo = Trim(o,x);
   elseif (nargin == 4)
      corazon.profiler('trim',1);
      [oo,y,e] = Triple(o,x,y,e);
      corazon.profiler('trim',0);
   end
end

%==========================================================================
% Trim Mantissa
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading mantissa zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end

%==========================================================================
% Trim Transfer Function
%==========================================================================

function o = Trf(o)                    % Trim Transfer Function         
%
% TRF        Trim transfer function object: remove leading zeros
%            in numerator and denominator.
%
   o.data.num = Trim(o,o.data.num);
   o.data.den = Trim(o,o.data.den);
   
   if isequal(o.data.num,0)
      o.data.den = 1;
   end
end

%==========================================================================
% Trim Mantissa
%==========================================================================

function o = Number(o)                 % Trim Rational Number         
%
% TRIMOBJ    Trim object: remove leading and trailing zeros and adjust
%            exponent accordingly
%
   expo = o.data.expo;
   num  = o.data.num;
   den  = o.data.den;

   [num,den,expo] = Triple(o,num,den,expo);

   o.data.expo = expo;
   o.data.num = num;
   o.data.den = den;
end

%==========================================================================
% Trim Triple
%==========================================================================

function [x,y,e] = Triple(o,x,y,e)     % Trim Triple                   
%
% TRIMTRIPLE  Trim triple: remove leading and trailing zeros and adjust
%             exponent accordingly
%
   x = Trim(o,x);
   y = Trim(o,y);
   
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

function o = Poly(o)                   % Trim Polynomial               
%
% TRIMPOLY    Trim polynomial: remove leading and trailing zeros and adjust
%             exponent accordingly
%
   assert(isequal(o.type,'poly'));
   
   for (k=0:order(o))
      oo = peek(o,k);
      oo = trim(oo);
      o = poke(o,oo,k);
   end
   
      % reduce coefficients if zero
    
   if (digits(o) == 1)
      [num,den,xpo] = peek(o);

      n = length(xpo);
      for (i=n:-1:2)
         if (num(i) == 0)      % zero numerator coefficient ?
            num(i) = [];
            den(i) = [];
            xpo(i) = [];
         else
            break;
         end
      end

      o = poke(o,xpo,num,den);
   end
end

%==========================================================================
% Trim Ratio
%==========================================================================

function o = Ratio(o)                  % Trim Rational Function        
%
% TRIMRATIO   Trim rational function: remove leading and trailing zeros and
%             adjust exponent accordingly
%
   assert(isequal(o.type,'ratio'));
   
   [num,den,xpo] = peek(o);
   assert(type(num,{'poly'}));
   assert(type(den,{'poly'}));

   num = trim(num);
   den = trim(den);

   o = poke(o,xpo,num,den);
end

%==========================================================================
% Trim Matrix
%==========================================================================

function o = Matrix(o)                 % Trim Matrix                   
   assert(type(o,{'matrix'}));

   M = o.data.matrix;
   [m,n] = size(M);

   for (i=1:m)
      for (j=1:n)
         oo = trim(M{i,j});
         M{i,j} = oo;
      end
   end
   o.data.matrix = M;
end

