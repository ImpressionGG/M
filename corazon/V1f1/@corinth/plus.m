function oo = plus(o1,o2)
%
% PLUS   Overloaded operator + for CORINTH objects (rational objects)
%
%             o1 = corinth(1,6);       % ratio 1/6
%             o2 = corinth(2,6);       % ratio 2/6
%
%             oo = o1 + o2;            % add two ratios
%             oo = o1 + 7;             % add real number to ratio
%             oo = 5 + o2;             % add ratio to real number
%
%          See also: CORINTH, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'corinth'))
      [o2,o1] = Cast(o2,o1);
   elseif (~isa(o2,'corinth'))
      [o1,o2] = Cast(o1,o2);
   end
   
   assert(isa(o1,'corinth') && isa(o2,'corinth'));
   
      % now we are sure to deal with CORINTH objects only

   o1 = touch(o1);                     % just in case of a copy somewhere
   o2 = touch(o2);                     % just in case of a copy somewhere

   [m1,n1] = size(o1);
   [m2,n2] = size(o2);
   
      % perform addition

   if (m1*n1 == 1)
      oo = ScalarPlusAny(o1,o2);
   elseif (m2*n2 == 1)
      oo = ScalarPlusAny(o2,o1);
   else
      oo = MatrixPlusMatrix(o1,o2);
   end
      
   oo = can(oo);
   oo = trim(oo);
end

%==========================================================================
% Scalar Plus Any
%==========================================================================

function oo = ScalarPlusAny(os,oa)     % Scalar (os) Plus Any (oa)     
   %os = ratio(os);                    % cast scalar to a ratio
   
   if isequal(oa.type,'matrix')        % in case oa is a matrix
      M = oa.data.matrix;
      [m,n] = size(M);
      for (i=1:m)
         for (j=1:n)
            M{i,j} = M{i,j} + os;
         end
      end
      oo = oa;
      oo.data.matrix = M;
   else                                % otherwise oa is a scalar too 
      %oa = ratio(oa);                 % cast oa to a ratio    
      [os,oa] = Cast(os,oa);
      oo = add(os,oa);                 % add the two ratios
   end
end

%==========================================================================
% Matrix Plus Matrix
%==========================================================================

function oo = MatrixPlusMatrix(o1,o2)  % Matrix Plus Matrix            
   if ~isequal(o1.type,'matrix') || ~isequal(o2.type,'matrix')
      error('matrix type expected');
   end
   
   [m1,n1] = size(o1);
   [m2,n2] = size(o2);
   
   if (m1 ~= m2 || n1 ~= n2)
      error('incompatible sizes');
   end

   M1 = o1.data.matrix;
   M2 = o2.data.matrix;
   
   for (i=1:m1)
      for (j=1:n1)
         M1ij = M1{i,j};
         M2ij = M2{i,j};
         Mij = M1ij + M2ij;
         M{i,j} = Mij;
      end
   end

   oo = corinth(o1,'matrix');
   oo.data.matrix = M;
end

%==========================================================================
% Cast to Same Types
%==========================================================================

function [o1,o2] = Cast(o1,o2)         % Cast Objects to be Compatible 
   if isa(o2,'double');
      if isequal(o1.type,'trf')
         o2 = trf(o1,o2);
         return
      else
         o2 = number(o1,o2);
      end
   end
   
   kind = max(Kind(o1),Kind(o2));
   switch kind
      case 0
         if ~isequal(o1.type,'trf')
            o1 = trf(o1);
         end
         if ~isequal(o2.type,'trf')
            o2 = trf(o2);
         end
         
      case 1
         if ~isequal(o1.type,'number')
            o1 = number(o1);
         end
         if ~isequal(o2.type,'number')
            o2 = number(o2);
         end
         
      case 2
         if ~isequal(o1.type,'poly')
            o1 = poly(o1);
         end
         if ~isequal(o2.type,'poly')
            o2 = poly(o2);
         end

      case 3
         if ~isequal(o1.type,'ratio')
            o1 = ratio(o1);
         end
         if ~isequal(o2.type,'ratio')
            o2 = ratio(o2);
         end
         
      otherwise
         error('internal');
   end

   function kind = Kind(o)
      switch o.type
         case 'trf'
            kind = 0;
         case 'number'
            kind = 1;
         case 'poly'
            kind = 2;
         case 'ratio'
            kind = 3;
         case 'matrix'
            kind = 4;
         otherwise
            kind = NaN;
      end
   end
end
