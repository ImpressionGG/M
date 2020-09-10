function [b,lab] = basis(obj,idx)
%
% BASIS     Retrieve complete orthonormal basis or basis vector of a
%           Hilbert space object.
%
%              H = space(tensor,1:7);    % construct a Hilbert space
%              b3 = basis(H,3);          % 3rd basis vector
%
%              S = space(tensor,{'up','down'}); % construct a Hilbert space
%              B = basis(S);             % complete list of basios vectors
%              u = basis(S,'up');        % basis vector labeled 'up'
%              u = basis(S,'down');      % basis vector labeled 'down'
%
%           Also the label (or list of labels) can be retrieved
%
%              [u,lab] = basis(S,'up');  % retrieve also label
%
%           Finally basis vector list can be compacted to an nxn matrix:
%
%              M = basis(S,[]);          % compact to a basis matrix
%
%           See also: TENSOR, SPACE
%
   assert(obj);
   
   if ~(property(obj,'space') || property(obj,'projector') || property(obj,'vector'))
      error('space or projector type tensor object required!');
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
