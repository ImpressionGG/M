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
%            For a cspace we can only get the labels. The labels are
%            a readable version of the indexing ntuples of the eigen
%            vectors.
%
%               C = space(toy,'game');
%               lab = labels(S);
%
%            See also: TENSOR, DISPLAY
%
   typ = type(obj);
   
% get labels

   if (nargin == 1)
      switch typ
         case {'#SPACE','#VECTOR','#MATRIX','#OPERATOR','#PROJECTOR','#UNIVERSE'}
            value = data(obj,'space.labels');
            return

         case '#CSPACE'
            index = property(obj,'index');
            itab = property(obj,'itab');
            for (i=1:size(itab,1))
               ntuple = itab(i,:);
               assert(size(itab,2)==length(index));
               lab = '{';
               for (k=1:length(ntuple))
                  domk = index{k}; 
                  ev = domk(ntuple(k));
                  lab = [lab,iif(k==1,'',','),sprintf('%g',ev)];
               end
               lab = [lab,'}'];
               value{i,1} = lab;
            end
            
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
            error(['implementation restriction for type:',typ,'!']);
      end
      return
   end
   
% set labels

   if (nargin == 2)
      switch typ
         case {'#SPACE','#VECTOR','#MATRIX','#OPERATOR','#PROJECTOR'}
            value = data(obj,'space.labels',value);
            return

         otherwise
            error(['implementation restriction for type:',typ,'!']);
      end
      return
   end
end
