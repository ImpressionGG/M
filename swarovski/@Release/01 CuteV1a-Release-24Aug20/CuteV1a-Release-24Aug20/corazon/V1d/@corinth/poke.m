function o = poke(o,o1,o2,o3)         % Poke CORINTH Object @ Index    
%
% POKE   Poke corinthian object to an index location of an encapsulating
%        corinthian object
%
%        1) Poke numerator, denominatpor and exponent
%
%           o = poke(o,xpo,num,den)    % xpo anything but object
%
%        2) Poke i-th polynomial coefficient into polynomial
%
%           o = corinth([1 5 6])       % corinthian polynomial
%           oo = corinth(7)            % coefficient (ratio 7/1)
%           o = poke(o,oo,i)           % poke i-th coefficient
%
%        See also: CORINTH, PEEK, POKE
%
   if ~isobject(o1)                    % super fast access
      data = o.data;
      data.expo = o1;  data.num = o2;  data.den = o3;
      o.data = data;
      return
   end
   
   switch o.type
          case 'number'
             o = corinth(o,'poly');    % cast ratio to plynomial
             o = PokePoly(o,o1,o2);
          case 'poly'
             o = PokePoly(o,o1,o2);
      otherwise
         error('implementation restriction!');
   end
end

%==========================================================================
% Pick from Polynomial
%==========================================================================

function o = PokePoly(o,oo,i)
   assert(isequal(o.type,'poly'));
   if (o.data.base ~= oo.data.base)
      error('base mismatch!');
   end
   if ~isequal(oo.type,'number')
      error('object to be poked into polynomial must be rational!');
   end

   if (i < 0)
      error('index out of range!');
   end
   i = i+1;
      
   expo = oo.data.expo;
   num = oo.data.num;
   den = oo.data.den;

      % provide ones in denominators
      
   [mn,nn] = size(o.data.num);
   if (length(num) > nn)
      o.data.num = [zeros(mn,length(num)-nn),o.data.num];
      nn = length(num);
   end

   [md,nd] = size(o.data.den);
   if (length(den) > nd)
      o.data.den = [zeros(md,length(den)-nd),o.data.den];
      nd = length(den);
   end
   
   
   for (j=md+1:i-1)
      o.data.den(j,nd) = 1;
   end
   
      % now poke ...
      
   o.data.expo(i) = expo;
   o.data.num(i,1:nn) = [zeros(1,nn-length(num)),num];
   o.data.den(i,1:nd) = [zeros(1,nd-length(den)),den];
   o.data.blue = [];
end