function value = labels(obj,value)
%
% LABELS     Get or set tensor labels
%
%            1) for a Hilbert space object ('#SPACE') return the matrix
%            of labels. This works as well for vectors and operators.
%
%               S = space(tensor,{'u','d'},[1 1;-1 1]/sqrt(2));
%               lab = labels(S);
%
%            2) Set labels
%
%               S = labels(S,lab);
%
%            See also: TENSOR, DISPLAY
%
   fmt = format(obj);
   
% get labels

   if (nargin == 1)
      switch fmt
         case {'#SPACE','#VECTOR','#MATRIX','#OPERATOR','#PROJECTOR','#UNIVERSE'}
            value = data(obj,'space.labels');
            return

         case '#SPLIT'
            list = property(obj,'list');
            [m,n] = size(list);
            value = {};
            
            for (i=1:m)
               for (j=1:n)
                  P = list{i,j};
                  value{i,j} = info(P);
               end
            end
            
         otherwise
            error(['implementation restriction for format:',fmt,'!']);
      end
      return
   end
   
% set labels

   if (nargin == 2)
      switch fmt
         case {'#SPACE','#VECTOR','#MATRIX','#OPERATOR','#PROJECTOR'}
            value = data(obj,'space.labels',value);
            return

         otherwise
            error(['implementation restriction for format:',fmt,'!']);
      end
      return
   end
end
