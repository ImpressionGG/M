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
   [o1,o2] = Comply(o1,o2);            % make compiant to each other
   
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
% Multiply Scalar With Matrix
%==========================================================================

function o = Multiply(o,s)             % Multiply Matrix by Scalar     
   M = o.data.matrix;
   [m,n] = size(M);
   
   for (i=1:m)
      for (j=1:n)
         M{i,j} = M{i,j} * s;
      end
   end
   o.data.matrix = M;
end

%==========================================================================
% Make Args Compiant To Each Other
%==========================================================================

function [o1,o2] = Comply(o1,o2)       % Make Compiant to Each Other   
   if (~isa(o1,'corinth'))
      o1 = Cast(o2,o1);
   elseif (~isa(o2,'corinth'))
      o2 = Cast(o1,o2);
   elseif ~isequal(o1.type,o2.type)
      if isequal(o1.type,'matrix')
         o2 = Cast(o1,o2);
      elseif isequal(o2.type,'matrix')
         o1 = Cast(o2,o1);
      elseif isequal(o1.type,'ratio')
         o2 = Cast(o1,o2);
      elseif isequal(o2.type,'ratio')
         o1 = Cast(o2,o1);
      elseif isequal(o1.type,'poly')
         o2 = Cast(o1,o2);
      elseif isequal(o2.type,'poly')
         o1 = Cast(o2,o1);
      else
         error('implementation');
      end
   end
    
   assert(isa(o1,'corinth') && isa(o2,'corinth'));
   
   function oo = Cast(o,x)             % Cast to Higher Order Corinth  
      [~,oo] = cast(o,x);              % delegate corinthian cast method
   end
end
