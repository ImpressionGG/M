function bool = assert(obj)
%
% ASSERT   Assert integrity of a toy objet
%
%             assert(obj);
%
%          See also: TOY, DISPLAY
%
   profiler('assert',1);
   assertion = either(setting('shell.debug'),0);
   
   if ~assertion
      profiler('assert',0);
      return
   end

   typ = type(obj);
   dat = data(obj);
   
   assert(ischar(typ) && size(typ,1) == 1);
   
   switch typ
      case {'#GENERIC','#PLAY'}
         assert(isempty(dat));
         
      case '#VECTOR'
         M = matrix(obj);
         sizes = size(labels(obj));
         assert(isempty(M) || all(size(M) == sizes));
         
      case '#OPERATOR'
         M = matrix(obj);
         n = dim(obj);
         assert(isempty(M) || all(size(M)==[n n]));
         
      case '#CSPACE'
         index = property(obj,'index');  % list of indexing eigen values
         list = property(obj,'list');    % list of eigen vector matrices
         assert(iscell(index) && iscell(list));
         
         O = data(obj,'cspace.observable');
         B = data(obj,'cspace.basis');

         assert(rank(B) == length(B));   % check for full rank
         
            % check whether wave.basis contains eigen vectors of O
            
         if ~isempty(O)
            M = matrix(O);
            assert(all(size(M)==size(B)));
            for (i=1:length(B))          % check for eigen vector property
               bi = B(:,i);              % i-th basis vector
               r = rank([bi,M*bi]);      % bi || M*bi !!! 
               assert(r==1);             % vectors must be colinear
            end
         end
         
           % it follows a test whether each eigen vector is indexed
           % correctly bei the eigen value ntupel
           
         T = data(obj,'cspace.itab');      % index table
         [m,n] = size(T);
         assert(m==dim(O));
         assert(n==length(list) && n==length(index));

         olist = data(obj,'cspace.olist');
         for (i=1:length(olist))
            Oi = olist{i};
            Hi = space(Oi);
            spaces{i} = Hi;              % put space into space list
            sizes{i} = property(Hi,'size');
         end
         
         H = space(obj);
         for (k=1:m)
            idx = T(k,:);                % indexing n-tupel
            bk = reshape(H,B(:,k));      % k-th basis vector 
            
               % construct basis vector differently
               
            for (i=1:length(idx))
               Hi = spaces{i};
               Bi = list{i};                   % i-th basis
               Mi = Bi(:,idx(i));
               %Mi = reshape(Mi,sizes{i});
               Mi = reshape(Hi,Mi);
               Ii = index{i};
               ntupel(i) = Ii(idx(i));
               Vi = vector(Hi,Mi);
               if (i==1)
                  V = Vi;
               else
                  V = V.*Vi;
               end
            end
            
            b = matrix(V)+0;
            assert(all(all(b==bk)));                % vectors must match
         end
         
      case '#SPACE'
         spc = dat.space;
         %basis = spc.basis;
         
         if property(obj,'simple?')
            if isempty(spc)
               assert(~isempty(spc));   % very strange - fdind out why!
            else
               assert(all(size(spc.size)==[1 2]));
               n = property(obj,'dimension');
               assert(prod(size(spc.labels)) == n);
               assert(length(spc.column) == n);
               assert(length(spc.index) == n);
            end
         end
         
      case '#PROJECTOR'
         proj = dat.proj;
         typ = proj.type;
         index = proj.index;
         
         assert(~isempty(match(typ,{'???','ray'})));
         assert(isa(index,'double'));
         
      case '#SPLIT'
         list = dat.split.list;
         if ~isempty(list)
            assert(~isempty(data(obj,'space')));
            S = space(obj);
            P = operator(S,0);       % init with null operator
            for (i=1:length(list(:)))
               Pi = list{i};         % next projector
               P = P+Pi;
            end
            assert(property(P,'eye?'));
         end
         
      case '#UNIVERSE'
         assert(space(obj));
         list = data(obj,'uni.list');
         assert(iscell(list));

      case '#HISTORY'
         list = data(obj,'history.list');
         assert(iscell(list));
         
      otherwise
         error(['unsupported toy type: ',typ]);
   end
   
   profiler('assert',0);
   return
end

