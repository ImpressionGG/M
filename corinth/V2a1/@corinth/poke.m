function o = poke(o,o1,o2,o3)         % Poke CORINTH Object @ Index    
%
% POKE   Poke corinthian object to an index location of an encapsulating
%        corinthian object
%
%        1) Poke numerator, denominatpor and exponent
%
%           o = poke(o,num,den)
%           o = poke(o,xpo,num,den)    % xpo anything but object
%
%        2) Poke i-th polynomial coefficient into polynomial
%
%           o = corinth([1 5 6])       % corinthian polynomial
%           oo = corinth(7)            % coefficient (ratio 7/1)
%           o = poke(o,oo,i)           % poke i-th coefficient
%
%        3) Poke numerator and/or denominator into rational function
%
%           o = corinth(o,'ratio')
%           o = poke(o,p,1)            % poke numerator polynomial p             
%           o = poke(o,q,2)            % poke denominator polynomial q             
%           o = poke(o,p,q)            % poke num/den polynomials p/q             
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
      case 'trf'
         o = PokeTrf(o,o1,o2);

      case 'number'
         o = corinth(o,'poly');    % cast ratio to plynomial
         o = PokePoly(o,o1,o2);

      case 'poly'
         o = PokePoly(o,o1,o2);

      case 'ratio'
         if (nargin ~= 3)
            error('3 input args expected');
         end
         if ~type(o1,{'poly'})
            error('polynomial expected for arg2');
         end
         
         if isequal(o2,1)              % o = poke(o,p,1)
            o.data.num = o1;
         elseif isequal(o2,2)          % o = poke(o,q,2)
            o.data.den = o1;
         elseif type(o2,{'poly'})      % o = poke(o,p,q)
            o.data.num = o1;
            o.data.den = o2;
            o.data.expo = NaN;
         else
            error('polynomial expected for arg3');
         end
         
      case 'matrix'
         o = PokeMatrix(o,o1,o2,o3);

      otherwise
         error('implementation restriction!');
   end
end

%==========================================================================
% Poke Numerator/Denominator of Transfer Function
%==========================================================================

function o = PokeTrf(o,num,den)        % Poke TRF Numerator/DEnominator
   if (~(isa(num,'double') || isa(num,'sym')) || size(num,1) ~= 1)
      error('double row vector expected for numerator (arg2)');
   end
   if (~(isa(den,'double') || isa(den,'sym')) || size(den,1) ~= 1)
      error('double row vector expected for denominator (arg3)');
   end
   
   num = vpa(num);
   den = vpa(den);
   o.data.expo = NaN;
   o.data.num = num;
   o.data.den = den;

   o = touch(o);
end

%==========================================================================
% Poke Polynomial Coefficient
%==========================================================================

function o = PokePoly(o,oo,i)          % Poke Polynomial Coefficient   
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

%==========================================================================
% Poke Matrix Element (or Sub-Matrix)
%==========================================================================

function o = PokeMatrix(o,oo,i,j)     % Poke Matrix Element           
%
% PEEKMATRIX  Peek matrix element or sub matrix
%
%                o = PokeMatrix(o,i,j)       % M{i,j} = oo
%
%                o = PokeMatrix(o,oo,i,[])   % M(i,:) = oo
%                o = PokeMatrix(o,oo,[],j)   % M(:,j} = oo
%
   assert(type(o,{'matrix'}));
   M = o.data.matrix;
   [m,n] = size(M);
   
   if (i < 1)
      error('bad row index');
   end
   if (j < 1)
      error('bad column index');
   end
   
   oo = can(oo);
   oo = trim(oo);
   
   M{i,j} = oo;
   o.data.matrix = M;
end
