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
%           o = corinth([1 5 6])       % corinthian polynomial
%           oi = peek(o,i)             % peek i-th coefficient (ratio)
%
%        See also: CORINTH, PEEK, POKE
%
   if (nargout == 3)                   % super fast access
      data = o.data;  xpo = data.expo;
      oo = data.num;  den = data.den;  
      return
   end
   
   switch o.type
      case 'poly'
         oo = PeekPoly(o,i);
      otherwise
         error('implementation restriction!');
   end
end

%==========================================================================
% Pick from Polynomial
%==========================================================================

function oo = PeekPoly(o,i)
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