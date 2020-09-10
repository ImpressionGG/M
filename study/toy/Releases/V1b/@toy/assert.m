function bool = assert(obj)
%
% ASSERT   Assert integrity of a toy objet
%
%             assert(obj);
%
%          See also: TOY, DISPLAY
%
   profiler('assert',1);
   assertion = either(setting('shell.assert'),0);
   
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
         
      case '#SPACE'
         spc = dat.space;
         basis = spc.basis;
         
         if property(obj,'simple?')
            assert(all(size(spc.size)==[1 2]));
            n = property(obj,'dimension');
            cond1 = isempty(basis);
            cond2 = all(size(basis)==[n n]);
            cond3 = (iscell(basis) && all(size(basis)==[1 n]));
            assert(cond1 || cond2 || cond3);
            assert(prod(size(spc.labels)) == n);
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

