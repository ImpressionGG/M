function [b,lab] = basis(obj,idx)
%
% BASIS     Retrieve complete orthonormal basis or basis vector of a
%           Hilbert space object.
%
%              H = space(toy,1:7);        % construct a Hilbert space
%              b3 = basis(H,3);           % 3rd basis vector
%
%              H = space(toy,{'u';'d'});  % construct a Hilbert space
%              B = basis(H);              % complete list of basios vectors
%              u = basis(H,'u');          % basis vector labeled 'u'
%              u = basis(H,'d');          % basis vector labeled 'd'
%
%           Also the label (or list of labels) can be retrieved
%
%              [u,lab] = basis(S,'u');    % retrieve also label
%
%           Finally basis vector list can be compacted to an nxn matrix:
%
%              M = basis(S,[]);           % compact to a basis matrix
%
%           See also: TOY, SPACE
%
   assert(obj);
   
   if ~(property(obj,'space?') || property(obj,'cspace?') || property(obj,'projector?') || property(obj,'vector?'))
      error('space or projector type toy object required!');
   end
   
   labels = property(obj,'labels');
   base = data(obj,'space.basis');
   dim = property(obj,'dimension');

   if (nargin < 2)
      for (i=1:dim)
         idx = labels(2);
         b{i} = Vector(base,labels,i);
      end
      lab = labels;
      return
   elseif isempty(idx)
      [list,lab] = basis(obj);
      for (i=1:length(list))
         M = list{i};
         b(:,i) = M(:);
      end
      return
   end
   
% Otherwise return the indexed basis vector

   if property(obj,'cspace?')
      basis = property(obj,'basis');
      for (i=1:length(basis))
         base{i} = basis(:,i);
      end
      if iscell(idx)
         [b,lab] = VectorByEigenValue(obj,base,idx);
         return
      end
   end
   
   [b,lab] = Vector(base,labels,idx);
   return
end

%==========================================================================
% Retrieve a basis vector
%==========================================================================

function [b,lab] = Vector(base,labels,idx)
%
% VECTOR   Retrieve a basis vector by index
%
   b = [];  lab = '';              % by default (error)
   n = prod(size(labels));
   
   if ischar(idx)
      i = min(match(idx,labels(:)));
      if isempty(i)
         error(['unproper label for indexing: ',idx]);
         return;
      end
   else
      i = idx;
   end

   if (i < 1 || i > n)
      error('index out of range');
      return
   end
   
   if isempty(base)
      b = sparse(n,1);              % b = zeros(n,1);
      b(i) = 1;
   else
      b = base{i};
   end
   
   if iscell(labels)
      lab = labels{i};
   else
      assert(0);
      %lab = labels(i);
   end
   
      % reshape vector
      
   b = reshape(b,size(labels));
   return
end

%==========================================================================
% Vector By Eigen Value
%==========================================================================

function [b,lab] = VectorByEigenValue(obj,base,idx)
%
% VECTOR-BY-EIGENVALUE
%
   assert(iscell(idx));
   assert(property(obj,'cspace?'));
   
   lab = '{';                        % don't care about labels right now
   index = property(obj,'index');    % get list of index sets
   if (length(index) ~= length(idx))
      error('bad number of indices for indexing by eigen values!');
   end
   for (k=1:length(idx))
      eig = idx{k};
      if ~isa(eig,'double') || length(eig) > 1
         error('all eigen values to index a basis vector must be double scalars!');
      end
      ntuple(k) = either(min(find(abs(eig-index{k})<7e-15)),0);
      if ntuple(k) == 0
         error(sprintf('%g is not an eigenvalue for observable #%g!',eig,k));
      end
      lab = [lab,iif(k==1,'',','),sprintf('%g',eig)];
   end
   lab = [lab,'}'];
   ntuple;
   
      % now search ntupel in index table
      
   itab = property(obj,'itab');
   assert(size(itab,1)==length(base));
   assert(size(itab,2)==length(ntuple));
   
   for (i=1:length(base))
      if all(ntuple==itab(i,:))
         b = base{i};
         b = reshape(space(obj),b);
         return;
      end
   end
   
   error(['unable to index a basis vector with ',lab,'!']);
   return
end
