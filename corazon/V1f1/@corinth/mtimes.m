function oo = mtimes(o1,o2)
%
% MTIMES   Overloaded operator * for CORINTH objects (rational objects)
%
%             o1 = corinth(1,6);       % ratio 1/6
%             o2 = corinth(2,6);       % ratio 2/6
%
%             oo = o1 * o2;            % multiply two ratios
%             oo = o1 * 7;             % multiply real number to ratio
%             oo = 5 * o2;             % multiply ratio to real number
%
%          See also: CORINTH, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'corinth'))
      o1 = Cast(o2,o1);
   elseif (~isa(o2,'corinth'))
      o2 = Cast(o1,o2);
   elseif ~isequal(o1.type,o2.type)
      if isequal(o1.type,'matrix')
         o2 = Cast(o1,o2);
      elseif isequal(o2.type,'matrix')
         o1 = Cast(o2,o1);
      else
         error('implementation');
      end
   end
    
   assert(isa(o1,'corinth') && isa(o2,'corinth'));
   
      % now we are sure to deal with CORINTH objects only

   o1 = touch(o1);                     % just in case of a copy somewhere
   o2 = touch(o2);                     % just in case of a copy somewhere

   if (isequal(o1.type,'matrix') && isequal(o2.type,'ratio'))
      oo = Multiply(o1,o2);            % matrix x scalar
   elseif (isequal(o2.type,'matrix') && isequal(o1.type,'ratio'))
      oo = Multiply(o2,o1);            % matrix x scalar
   else
      oo = mul(o1,o2);
   end

   oo = can(oo);
   oo = trim(oo);
end

%==========================================================================
% Cast real number to higher order CORINTH type
%==========================================================================

function oo = Cast(o,x)                % Cast to Higher Order Corinth
   if isa(x,'double')
      assert(prod(size(x))==1);

      switch o.type
         case 'number'
            oo = number(o,x);
         case 'poly'
            oo = poly(o,x);
         case 'ratio'
            oo = ratio(o,x,1);
         case 'matrix'
            oo = poly(o,x);
         otherwise
            error('internal');
      end
   elseif isobject(x)
      switch x.type
         case 'number'
            oo = ratio(o,x,1);
         case 'poly'
            oo = ratio(x,poly(o,1));
         case 'ratio'
            oo = x;
         case 'matrix'
            error('what ....?');
         otherwise
            error('internal');
      end
   else
      error('bad args');
   end
end

%==========================================================================
% Multiply Scalar With Matrix
%==========================================================================

function o = Multiply(o,s)             % Multiply Matrix by Scalar     
   M = o.data.matrix;
   [m,n] = size(M);
   
   for (i=1:m)
      for (j=1:n)
         M{i,j} = mul(M{i,j},s);
      end
   end
   o.data.matrix = M;
end

