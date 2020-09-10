function M = matrix(obj,varargin)
%
% MATRIX     Get or set tensor matrix
%
%            1) for a Hilbert space object ('#SPACE') return the matrix
%            of basis vectors.
%
%               S = space(tensor,{'u','d'},[1 1;-1 1]/sqrt(2));
%               M = matrix(S);
%
%            This is the same as: M = basis(S,[]);
%
%            2) for an operator or vector return the operator matrix
%
%               V = S(1);
%               M = matrix(V);
%
%               O = operator(S,'forward');
%               M = matrix(O);
%
%            3) Change specific matrix elements
%
%               S = space(tensor,{'a','b','c'});
%               O = eye(S);
%               O =  matrix(O,{'a','b'},5,{'b','c'},-2)   % change
%
%            See also: TENSOR, DISPLAY
%
   fmt = format(obj);
   
   
   if (length(varargin) == 0)
      switch fmt
         case '#SPACE'
            M = basis(obj,[]);
            return

         case '#PROJECTOR'
            n = dim(obj);
            index = property(obj,'index');

            M = sparse(n,n);           % projection matrix
            for (i=1:length(index))
               %b = basis(obj,index(i));
               V = vector(obj,index(i));
               b = matrix(V);
               if any(any(b+0))
                  b = b/norm(b+0);       % normalize
               end
               Mi = b(:)*b(:)';
               M = (M+Mi);
               M = M/norm(M+0);        % not very clean since missing sparse norm
            end
            return

         case '#OPERATOR'
            M = data(obj,'oper.matrix');

         case '#VECTOR'
            M = data(obj,'vector.matrix');

         otherwise
            error(['matrix method does not support format ''',fmt,'''!']);
      end
      return
   end
   
% set tensor matrix

   if (length(varargin) == 1)
      value = varargin{1};
      
      switch fmt
         case '#PROJECTOR'
            M = operator(space(obj),sparse(value));            
            %error('implementation restriction for projectors');
            return

         case '#OPERATOR'
            n = dim(obj);
            if any(size(value) ~= [n n])
               error('bad dimensions of matrix!');
            end
            M = data(obj,'oper.matrix',sparse(value));

         case '#VECTOR'
            n = dim(obj);
            sizes = size(labels(obj));
            if ~(all(size(value) == sizes))
            %if (prod(size(value)) ~= n)
               error('bad dimensions of matrix!');
            end
            M = data(obj,'vector.matrix',sparse(value));
         otherwise
            error(['cannot apply matrix setting to this tensor type: ',fmt]);
      end
      return
   end


% set matrix elements

   if (length(varargin) > 1)
      switch fmt
         case '#OPERATOR'
            M = matrix(obj);
            labs = labels(obj);
            
            ilist = varargin;
            while (length(ilist) >= 2)
               idx = ilist{1};
               value = ilist{2};
               
               if ~iscell(idx) || length(idx) ~= 2
                  error('indices must be two element lists!');
               end
               labi = idx{1};  labj = idx{2};
               
               idxi = min(match(labi,labs(:)));
               idxj = min(match(labj,labs(:)));
               
               if isempty(idxi) || isempty(idxj)
                  error('unsupported index!');
               end
               
               M(idxi,idxj) = value;
               ilist(1:2) = [];
            end
            
            if (length(ilist) > 0)
               error('number of input args must be even!');
            end
            
            M = matrix(obj,M);
            
         otherwise
            error(['cannot apply setting of matrix elements to this tensor type: ',fmt]);
      end
      return
   end
end


%==========================================================================
% Auxillary Functions
%==========================================================================

function M = CalculateMatrix(varargin)
%
% MATRIX   Calculate product matrix
%
%               M = matrix(magic(3),ones(2,2));
%               T = matrix([5;7;9],[2 3],ones(2,2));
%
   list = varargin;
   if length(list) == 1
      if iscell(list{1})
         list = list{1};
      end
   end
   
   N = length(list);
   if (N == 0)
      M = [];
   elseif (N==1)
      M = list{1};
   elseif (N==2)
      A = list{1};
      B = list{2};
      [m,n] = size(A);
      M = [];
      for (i=1:m)
         N = [];
         for (j=1:n)
            N = [N,A(i,j)*B];
         end
         M = [M;N];
      end
   else
      tail = matrix(list(end-1:end));
      list = list(1:end-1);
      list{end} = tail;       % overwrite
      M = matrix(list);
   end
   return
end
