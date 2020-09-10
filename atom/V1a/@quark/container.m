function oo = container(o,list)
%
% CONTAINER   create a container, or return status whether object is a
%             container object?
%
%                o = container(quark,{o1,o2,...});   % create a container  
%                ok = container(o)        % is object a container object?
%
%           See also: QUARK
%
   if (nargin == 1)
      oo = iscell(o.data);
   elseif (nargin == 2)
      if ~iscell(list)
         error('list expected for arg2!');
      end
      for (i=1:length(list))
         if ~isobject(list{i})
            error('all list elements (arg2) must e objects!');
         end
      end
      
      oo = add(o,list);                % add list of objects
   else
      error('1 or 2 input args expected!');
   end
end