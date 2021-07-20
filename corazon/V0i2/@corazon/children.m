function [oo,n] = children(o,i)
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
   ni = nargin;
   
      % we always need the shell object as a source for option
      % inheritance. The shell object has to be fetched explicitely
      % except a call with two input args with arg2 being a CORAZON 
      % object where arg2 is the shell object
      
   if (ni == 2 && isa(i,'corazon'))
      so = i;                          % arg2 is the shell object
      ni = 1;                          % effectively only 1 input arg
      O = so;                          % object which inherits options
   elseif container(o)
      so = o;                          % arg1 is the shell object
      O = so;                          % object which inherits options
   else
      so = pull(o);                    % pull shell object from shell
      if isequal(o.type,'pkg')
         O = o;                        % object which inherits options
      else
         O = so;                       % object which inherits options
      end
   end

      % handle two input args
      
   if (ni == 2)
      if (length(i) ~= 1)
         error('scalar expected (arg2)');
      end
      
      list = children(o);
      if isinf(i)
         oo = length(list); 
      elseif (1 <= i && i <= length(list))
         oo = list{i};
      else
         oo = [];
      end
      n = 0;
      return
   end
   
      % handle 1 input arg
      
   if container(o)
      list = {}; 
      for (i=1:length(so.data))
         oo = so.data{i};
         if type(oo,{'pkg'})
            oo = inherit(oo,O);        % inherit options from shell object
            list{end+1} = oo;          % add to list
         end
      end
   elseif type(o,{'pkg'})
      list = {};
      
      package = get(o,{'package',''});
      if ~isempty(package)
         for (i=1:length(so.data))
            oo = so.data{i};
            
               % add to list if package identifier matches and
               % no package object and no container object
               
            if isequal(get(oo,{'package',''}),package)
               if (~type(oo,{'pkg'})  && ~container(oo))
                  oo = inherit(oo,O);  % inherit opts from shell/pkg object
                  list{end+1} = oo;    % add to list
               end
            end
         end
      end
   else                                % no container and no package object
      list = {};
   end
   
      % set output args
      
   oo = list;
   n = length(list);
end
