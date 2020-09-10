function oo = minus(o1,o2)
%
% MINUS    Overloaded operator + for CORINTH objects (rational objects)
%
%             o1 = corinth(1,6);       % rational number 1/6
%             o2 = corinth(2,6);       % rational number 2/6
%
%             oo = o1 - o2;            % subtract two ratios
%             oo = o1 - 7;             % subtract real number to ratio
%             oo = 5 - o2;             % subtract ratio to real number
%
%          See also: CORINTH, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'corinth'))
      o1 = corinth(o2,o1);
   elseif (~isa(o2,'corinth'))
      o2 = corinth(o1,o2);
   end
    
   assert(isa(o1,'corinth') && isa(o2,'corinth'));
   
      % now we are sure to deal with CORINTH objects only

   o1 = touch(o1);                     % just in case of a copy somewhere
   o2 = touch(o2);                     % just in case of a copy somewhere

      % perform subtraction

   [m1,n1] = size(o1);
   [m2,n2] = size(o2);
   
      % perform addition

   if (m1*n1 == 1)
      oo = ScalarMinusAny(o1,o2);
   elseif (m2*n2 == 1)
      oo = AnyMinusScalar(o1,o2);
   else
      oo = MatrixMinusMatrix(o1,o2);
   end
      
   oo = can(oo);
   oo = trim(oo);
end

%==========================================================================
% Scalar Minus Any
%==========================================================================

function oo = ScalarMinusAny(os,oa)    % Scalar (os) Minus Any (oa)     
   os = ratio(os);                     % cast scalar to a ratio
   
   if isequal(oa.type,'matrix')        % in case oa is a matrix
      M = oa.data.matrix;
      [m,n] = size(M);
      for (i=1:m)
         for (j=1:n)
            M{i,j} = sub(os,M{i,j});
         end
      end
      oo = oa;
      oo.data.matrix = M;
   else                                % otherwise oa is a scalar too 
      oa = ratio(oa);                  % cast oa to a ratio    
      oo = sub(os,oa);                 % subtract the two ratios
   end
end

%==========================================================================
% Any Minus Scalar
%==========================================================================

function oo = AnyMinusScalar(oa,os)    % Any (oa) Minus Scalar (os)     
   os = ratio(os);                     % cast scalar to a ratio
   
   if isequal(oa.type,'matrix')        % in case oa is a matrix
      M = oa.data.matrix;
      [m,n] = size(M);
      for (i=1:m)
         for (j=1:n)
            M{i,j} = sub(M{i,j},os);
         end
      end
      oo = oa;
      oo.data.matrix = M;
   else                                % otherwise oa is a scalar too 
      oa = ratio(oa);                  % cast oa to a ratio    
      oo = sub(oa,os);                 % subtract the two ratios
   end
end

%==========================================================================
% Matrix Plus Matrix
%==========================================================================

function oo = MatrixMinusMatrix(o1,o2) % Matrix Minus Matrix            
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
         Mij = sub(M1ij,M2ij);
         M{i,j} = Mij;
      end
   end

   oo = corinth(o1,'matrix');
   oo.data.matrix = M;
end
