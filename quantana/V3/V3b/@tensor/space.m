function sob = space(obj,varargin)
%
% SPACE      Create a simple or compound Hilbert space. The resulting
%            object is represented by a tensor object with format '#SPACE'.
%
%               S = space(tensor,labels,matrix)
%               S = space(tensor,labels,[])
%               S = space(tensor,labels)           % same as above
%
%            Extract space from a projector
%
%               S = space(tensor,{'u','d'});
%               P = projector(S,'u');
%               S = space(P);                % extract projector's space
%
%            A Hilbert space can be of two types:
%               1) simple space
%               2) compound space
%
%            Examples (simple Hilbert space creation):
%
%               S1 = space(tensor,1:7);      % Hilbert space of dimension 7
%                                            % indexed by labels 1:7
%
%               S2 = space(tensor,0:6);      % Hilbert space of dimension 7
%                                            % indexed by labels 0:6
%
%               labels = {'a','b','c'};
%               S3 = space(tensor,labels);   % Hilbert space of dimension 3
%                                            % indexed by labels 'a','b','c'
%            
%            Examples (compound Hilbert space creation):
%
%               S4 = space(tensor,S1,S2);    % Tensor product of Hilbert
%                                            % spaces S1°S2
%
%               S5 = space(tensor,S1,S2,S3); % Tensor product of Hilbert
%                                            % spaces S1°S2°S3
%
%            Alternative calling syntax for tensor product spaces
%
%               S4 = space(tensor,{S1,S2});
%               S5 = space(tensor,{S1,S2,S3});
%
%            The type of the space can be checked by property 'simple',
%            e.g.
%                  
%               p = property(S1,'simple')        % p = 1
%               p = property(S4,'simple')        % p = 0
%
%            See also: TENSOR, BASIS, PROPERTY
%
   sizes = [];           % by default empty
   spaces = {};          % by default empty - means simple space
   ilist = varargin;
   
   if length(ilist) < 1
      switch format(obj)
         case {'#VECTOR','#PROJECTOR','#OPERATOR','#SPLIT','#UNIVERSE','#HISTORY'}
            dat.space = data(obj,'space');
            sob = tensor('#SPACE',[],dat);
            %sob = format(obj,'#SPACE');  % convert back to '#SPACE'
            return
         otherwise
            error('at least 2 input args expected!');
      end
   end
   
% handle alternative calling syntax for construction of tensor
% product space
      
   if iscell(ilist{1}) && (length(ilist) == 1)
      alist = ilist{1};
      if ~isempty(alist)
         if isa(alist{1},'tensor')
            ilist = alist;
         end
      end
   end
   
% now we have the input arguments in ilist. The first argument can
% be either a hilbert space, or it can be a vector with labels. Let's
% first handle the compound space (Hilbert space type)

   if isa(ilist{1},'tensor')
      if ~property(obj,'space')
         error('All arguments of a tensor product space must be spaces (arg1)!');
      end
      
      for (i=1:length(ilist))
         arg = ilist{i};
         isspace = isa(arg,'tensor');
         if (isspace)
            isspace = property(arg,'space');
         end
         
         if (~isspace)
            error('All arguments of a tensor product space must be spaces!');
         end
      end
      
         % if no error up to here then we have a consistent argument list
         
      spaces = cons(obj,ilist);
      
         % compose labels
         
      blabels = property(spaces{end},'labels');
      sizes = property(spaces{1},'size');
      
      for (q=1:length(spaces)-1)
         k = length(spaces) - q;
         sizeq = property(spaces{q+1},'size');
         sizes = [sizes; sizeq];
         
         arg = spaces{k};
         alabels = property(arg,'labels');

         [am,an] = size(alabels);
         [bm,bn] = size(blabels);

         for (ai=1:am)           % regarding rows of mi x ni ilabels
           for (aj=1:an)         % regarding cols of mi x ni ilabels
               for (bi=1:bm)     % regarding rows of mj x nj jlabels
                  for (bj=1:bn)  % regarding cols of mj x nj ilabels
                    i = (ai-1)*bm + bi;
                    j = (aj-1)*bn + bj;
                    composed{i,j} = [alabels{ai,aj},'°',blabels{bi,bj}];
                 end
               end
            end
         end
         blabels = composed;
      end
      labels = blabels;
      basis = [];
   end
   
      % otherwise we have to create a simple space
      
   if ~isa(ilist{1},'tensor')
      if (length(ilist) == 1)
         basis = [];
      elseif (length(ilist) == 2)
         basis = ilist{2};
      else
         error('Only 2 or 3 args expected for simple space construction!');
      end
      
      labels = ilist{1};
      if (min(size(labels)) > 1)
         %error('nx1 or 1xn label vector expected for arg2!');
      end
      
      if isa(labels,'double')
         vec = labels;
         labels = {};
         for (i=1:size(vec,1))
            for (j=1:size(vec,2)) 
              labels{i,j} = sprintf('%g',vec(i,j));
            end
         end
      elseif iscell(labels)
         labels = Expand(labels);
         for (i=1:size(labels,1))
            for (j=1:size(labels,2))
               if ~ischar(labels{i,j})
                  error('All labels expected in label list (arg2) expected to be string!');
               end
            end
         end
      else
         error('Either double vector or character list expected for labels (arg2)!');
      end

      if (length(basis) > 0)
         if iscell(basis)
            if (length(basis) ~= length(labels))
               error('dimension of labels (arg2) and basis (arg3) must match!');
            end
         elseif isa(basis,'double')
            if any(size(basis) ~= length(labels)*[1 1])
               error('dimension of basis matrix (arg3) must match length of labels (arg2)!');
            end
            B = basis;  basis = {};
            for (i=1:length(B))
               basis{i} = B(:,i);
            end
         else
            error('basis (arg3) must be either nxn double matrix or list of basis vectors!');
         end
      end
   end
   
% Now everything is prepared. We are ready now for the construction 
% of a space object as tensor object with '#SPACE' format 
         
   sob = tensor('#SPACE');                % generic tensor
   if isempty(sizes)
      sizes = size(labels);
   end

   space.list = spaces;
   space.size = sizes;
   space.basis = basis;                   % use the natural basis
   space.labels = labels;

   sob = data(sob,'space',space);
   
   assert(sob);
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function labels = Expand(list)
%
% EXPAND   Expand labels properly
%
   labels = list;
   if isempty(list)
      return
   end
   
   if ~iscell(list{1})
      return
   end

   [ml,nl] = size(list);
   labels = {};
   for (i=1:ml)
      row = {}; 
      for (j=1:nl)
         row = [row list{i,j}];
      end
      labels = [labels; row];
   end
   return
end

   
   
      