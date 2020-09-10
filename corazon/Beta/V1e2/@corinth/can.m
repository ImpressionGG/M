function [o1,o2] = can(o,x,y)          % Cancel Common Factors         
%
% CAN   Cancel common factors. First calculate greatest common divisor
%       (GCD) of two rational objects and then cancel by GCD (common
%       factors) 
%
%       1) Cancel common factors of two Mantissa
%
%          o = base(rat,100);
%          [x,y] = can(o,[10 71],[4 62])   % cancel two mantissa
%
%       2) Cancel internal comon factors of an Object
%
%          oo = can(o)                 % cancel object
%
%       Example 1:
%
%          o = base(rat,10);
%          [f,x,y] = gcd(o,[10 71],[4 62])   % divide two mantissa
%
%          => f = [7] (gcd), x = [51], y = [22] 
%
%       See also: CORINTH, TRIM, FORM, GCDs
%
   if (nargin == 1)
      switch o.type
         case 'number'
            o1 = CanNumber(o);
         case 'poly'
            o1 = CanPoly(o);
         case 'ratio'
            o1 = CanRatio(o);
         case 'matrix'
            o1 = o;
         otherwise
            error('implementation restriction!');
      end
    elseif (nargin == 3)
      cf = gcd(o,x,y);                 % common factor
      
      [o1,r] = div(o,x,cf);             % cancel common factor
      assert(all(r==0));
      
      [o2,r] = div(o,y,cf);             % cancel common factor
      assert(all(r==0));
   else
      error('implementation restriction!');
   end
end

%==========================================================================
% Cancel Number
%==========================================================================

function oo = CanNumber(o)             % Cancel Ratio                  
   e = o.data.expo;
   x = o.data.num;
   y = o.data.den;
   cf = gcd(o,x,y);

   if ~isequal(cf,[1])
      [x,r] = div(o,x,cf);             % cancel common factor
      assert(isequal(r,[0]));

      [y,r] = div(o,y,cf);             % cancel common factor
      assert(isequal(r,[0]));
   end
   
   oo = poke(o,e,x,y);
end

%==========================================================================
% Cancel Polynomial
%==========================================================================

function oo = CanPoly(o)               % Cancel Polynomial             
   [num,den,expo] = peek(o);
   Num = [];  Den = [];
   
   for (i=1:length(expo))
      x = num(i,:);
      y = den(i,:);
      
      cf = gcd(o,x,y);

      if ~isequal(cf,[1])
         [x,r] = div(o,x,cf);          % cancel common factor
         assert(all(r==0));
         [y,r] = div(o,y,cf);          % cancel common factor
         assert(all(r==0));
      end
      [x,y,e] = trim(o,x,y,expo(i));     
      nx = length(x);  ny = length(y);
      idx = nx:-1:1;   idy = ny:-1:1;
      
      Xpo(i,1) = e;
      Num(i,idx) = x;
      Den(i,idy) = y;
   end
   
   Num = Num(:,size(Num,2):-1:1);                   % swap columns
   Den = Den(:,size(Den,2):-1:1);
   
   for (i=length(expo):-1:2)
      if all(Num(i,:)==0)
         Xpo(i)  = [];
         Num(i,:) = [];
         Den(i,:) = [];
      else
         break
      end
   end
   
   oo = poke(o,Xpo,Num,Den);
end

%==========================================================================
% Cancel Ratio
%==========================================================================

function oo = CanRatio(o)              % Cancel Ratio                  
   [x,y,e] = peek(o);
   cf = gcd(x,y);

   if ~iseye(cf) && ~iszero(cf)  
      [x,r] = div(x,cf);                % cancel common factor
      assert(iszero(r));

      [y,r] = div(y,cf);                % cancel common factor
      assert(iszero(r));
   end
   
   oo = poke(o,e,x,y);
end
