%
% CHILDREN   Access children or specific child of a container or package
%            object with inherited options from shell object. If object o
%            (arg1) is a container object (shell object) then
%
%               list = children(o)     % return list of package objects
%
%            returns a list of all package objects. If object po is a 
%            package object then
%
%               list = children(po)    % return children of package
%               list = children(po,o)  % same but explicite shell object o
%
%            returns a list of all (non-package and non container) objects
%            belonging to the package. if arg1 is neither a container object 
%            nor a package object then an empty list is returned.
%
%               oo = children(o,i)     % return i-th child
%               n = children(o,inf)    % return number of children
%
%            Whenever a returned list is non-empty then all objects in the
%            list inherit their options from either the package object or
%            the (implicitely fetched or explicitely provided) shell object.
%
%            Example 1: List package IDs
%
%               list = children(pull(o))
%               for (i=1:length(list))
%                  oo = list{i};
%                  fprintf('package %s\n',get(oo,{'package',''}));
%               end
%
%            Example 2: plot some quantity of all children of a package
%
%               assert(type(o,{'pkg'}))
%               list = children(o)     % get children list of package
%               progress(o,2,'calculate quantity');
%               for (i=1:length(list))
%                  quantity(i) = cook(list{i},'quantity')
%               end
%               plot(quantity)
%
%            Example 3: plot some quantity of all children of a package
%               and use progress and stop mechanism
%
%               assert(type(o,{'pkg'}))
%               [list,n] = children(o)     % get children list of package
%               progress(o,2,'calculate quantity');
%               stop(o,'Enable');
%               for (i=1:n)
%                  progress(o,i);
%                  quantity(i) = cook(list{i},'quantity')
%                  if stop(o)
%                     break
%                  end
%               end
%               stop(o,'Disable');
%               progress(o);
%               plot(quantity)
%
%            Example 4: option inheritance from package object
%
%               assert(type(po,{'pkg'}))
%               po = opt(po,'color','r')
%               oo = children(po,2)              % get 2nd package child
%               assert(isequal(opt(oo,'color'),'r'))
%
%            Copyright(c): Bluenetics 2021
%
%            See also: CORAZON,TREE,PROGRESS,STOP
%
