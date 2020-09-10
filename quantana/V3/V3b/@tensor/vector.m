function V = vector(obj,arg)
%
% VECTOR     Construct a vector object for a given space
%
%               S = space(tensor,{'u','d'});
%               P = projector(S,'u');
%
%               V = vector(S,1);
%               V = vector(S,'u');
%               V = vector(P,'u');
%
%               V = vector(S);         % null vector
%               V = vector(S,[]);      % null vector
%
%            See also: TENSOR, DISPLAY
%
   done = 0;

   if (nargin < 2)
      arg = [];
   end
   
   if property(obj,'projector')
      V = vector(space(obj),arg);
      return
   end
   
   if ~(property(obj,'space') || property(obj,'vector'))
      error('object (arg1) must be a space or vector or projector!');
   end
   
% Check if vector is initialized by a matrix
% This is given if the argument is a double non-scalar

   n = dim(obj);  sz = size(arg);

   if (length(arg) > 1 && isa(arg,'double'))
      V = vector(obj);
      V = option(V,option(obj));
      
      V = matrix(V,arg);
      if (min(sz) == 1)
         if (sz(2) == 1)    % bra vector
            %V = labels(V,labels(V)');    % transpose labels
         end
      end
      return
   end

% Process double argument which is the initializing matrix   
   
   if (isa(arg,'double') || ischar(arg))
      if isempty(arg)
         b = zeros(size(labels(obj)));
      elseif isa(arg,'double') 
         n = property(obj,'dimension');
         if (arg <= n)
            b = basis(obj,arg);
         else
            symbols = property(obj,'symbols');
            if (arg > length(symbols))
               error('vector index out of range!');
            else
               sym = symbols{arg}; 
               spec = data(obj,'space.spec');
               b = assoc(sym,spec);
            end
         end
      elseif ischar(arg)
         try
            b = basis(obj,arg);
         catch  % if empty then we can search in specific vector setup structure
            spec = data(obj,'space.spec');
            b = assoc(arg,spec);
         end
      else
         error('bad index type!');
      end
      

      V = format(obj,'#VECTOR');
      V = option(V,option(obj));
      V = matrix(V,b);
      done = 1;
   end
   
% Third case: both arguments are vectors. This means we have to create
% a tensor product of vectors

   if (~done && property(obj,'vector') && isa(arg,'tensor'))
      if property(arg,'vector')
         v1 = obj;  v2 = arg;
         
         S1 = space(v1);
         S2 = space(v2);
         S = space(S1,S2);            % tensor product space
         
         V = vector(S,[]);           % the null vector

         M = Product(v1,v2);
         V = data(V,'vector.matrix',M);
         done = 1;      
      end
   end
   
   
% if still not processed then we have an error

   if ~done
      error('bad input argument (arg2)!');
   end
      
   assert(V);
   return
end

%==========================================================================
% Tensor Product for Matrix Elements
%==========================================================================

function M = Product(op1,op2)
%
% PRODUCT
%
   Ma = matrix(op1);
   Mb = matrix(op2);

   [am,an] = size(Ma);
   [bm,bn] = size(Mb);

   M = sparse(am*bm,an*bn);

   for (ai=1:am)                      % regarding rows of mi x ni ilabels
     for (aj=1:an)                    % regarding cols of mi x ni ilabels
         for (bi=1:bm)                % regarding rows of mj x nj jlabels
            for (bj=1:bn)             % regarding cols of mj x nj ilabels
              i = (ai-1)*bm + bi;
              j = (aj-1)*bn + bj;
              M(i,j) = Ma(ai,aj) * Mb(bi,bj);
           end
         end
      end
   end
   return
end
