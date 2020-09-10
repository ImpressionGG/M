function oo = poly(o,num,den,xpo)
%
% POLY   Construct a rational polynomial
%
%        1) Cast Number to Polynomial
%
%           oo = poly(o)
%
%        2) Polynomial construction from real valued vectors
%
%           o = corinth                % base 1e6
%           p = poly(o,[3.2 4.17])     % numerator polynomial
%           p = poly(o,oo)             % casting: same as p = poly(oo)
%
%        3) Casting
%
%           oo = number(o,22,7)
%           oo = poly(oo)              % cast number to a polynomial
%
%           oo = poly(o,[1 5 6])
%           oo = poly(oo)              % cast polynomial to polynomial
%
%           oo = ratio(o,[1 5 6],[1])
%           oo = poly(oo)              % cast ratio to polynomial
%
%           oo = matrix(o,[8.88])      % 1x1 matrix
%           oo = poly(oo)              % cast 1x1 rational matrix to ratio
%
%        Example:
%
%           o = corinth                % base 1e6
%           p = poly(o,[2 3.2 4.17])   % numerator polynomial
%           oo = ratio(o,p,q)          % create rational function
%
%        creates a polynomial
%
%           2*s^2 + 16/5*s + 417/100
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX
%
   if (nargin == 1)                    % casting
      oo = Cast(o);
   elseif (nargin == 2)
      if isobject(num)
         oo = Cast(num);
      else
         oo = PolyReal(o,num);
      end
   elseif (nargin == 3)
      oo = PolyNumDen(o,num,den,0);
   elseif (nargin == 4)
      oo = PolyNumDen(o,num,den,xpo);
   else
      error('bad arg list');
   end
end

%==========================================================================
% Rational Polynomial Construction
%==========================================================================

function oo = PolyReal(o,x)            % Construct Number From Real    
   oo = corinth(o,x);
   oo.type = 'poly';
end

%==========================================================================
% Cast Corinthian Object To a Polynomial
%==========================================================================

function oo = Cast(o)                  % Cast CORINTH To Polynomial
   switch o.type
      case 'number'
         oo = type(o,'poly');          % just change type
      case 'poly'
         oo = o;                       % easy :-)
      case 'ratio'
         o = can(o);
         [onum,oden,~] = peek(o);
         
         if ~(order(oden) == 0)
            error('cannot convert non polynomial ratio to polynomial');
         end
         
         c0 = peek(oden,0);            % peek 0-th coefficient
         for (k=0:order(onum))
            ck = peek(onum,k);
            ck = div(ck,c0);
            onum = poke(onum,ck,k);
         end
         oo = onum;                    % return polynomial
      case 'matrix'
         oo = ratio(o);                % cast matrix to ratio
         oo = Cast(o);                 % cast ratio to polynomial
      otherwise
         error('internal')
   end
end
