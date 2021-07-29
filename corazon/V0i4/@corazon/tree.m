function oo = tree(o,i,j)              % Object Tree                            
%
% TREE     Get object tree or select object by package and object index.
%          if object is a container object the whole object tree is
%          returned (or displayed). If object is a package object (of type
%          'pkg' then the subtree of the package object is being returned
%          (displayed).
%
%             list = tree(o)           % get (hierarchical) object tree
%
%          Input argument must be container object (shell object) or
%          package object (type 'pkg'). Output arg is a list of lists with
%          length equal to number of packages.
%
%             list = tree(o,i)         % get all objects of i-th package
%             oo = tree(o,i,j)         % get j-th object from i-th package
%
%          Show object tree:
%
%             tree(sho)
%
%          Select by object ID
%
%             oo = tree(o,id(oo))                 % select by object ID
%             oo = tree(o,'@LPC03.200609.3')      % select by object ID
%
%          Example:
%
%             otree = tree(o);         % get object tree
%             for (i=1:length(otree))
%                list = otree{i};      % package list
%                fprintf('package %s\n',get(list{1},{'title','?'}));
%                for (j=2:length(list))
%                   oo = list{j};      % package object
%                   fprintf('   object %s\n',get(oo,{'title','?'}));
%                end
%             end
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORAZON
%
   if (nargin == 1)
      otree = Tree(o);                 % get object tree
      if (nargout >= 1)
         oo = otree;
      else
         Show(o,otree);                % show object tree
      end
   elseif (nargin == 2)
      if ischar(i)
         oo = SelectByObjId(o,i);
      else
         oo = List(o,i);               % get object list of a package
      end
   elseif (nargin == 3)
      oo = Object(o,i,j);              % select j-th object from i-th pkg
   else
      error('too many input args');
   end
end

%==========================================================================
% Show Object Tree
%==========================================================================

function Show(o,list)                  % Show Object Tree              
   if isempty(list) && ~container(o) && ~type(o,{'pkg'})
      fprintf('   Empty tree for data objects!\n');
      return
   end

   otree = tree(o);
   for (i=1:length(otree))
      list = otree{i};                  % package list
      fprintf('package %s\n',get(list{1},{'title','?'}));
      for (j=2:length(list))
         oo = list{j};                 % package object
         fprintf('   object %s\n',get(oo,{'title','?'}));
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function otree = Tree(o)                % Build Object Tree             
   if ~container(o)
      if type(o,{'pkg'})
         otree = PackageTree(o);
         return
      else
         otree = {};
         return
      end
   end
   
   list = o.data;
   assert(iscell(list));
   
      % first find all packages
      
   otree = {};  package = {};  index = [];
   
   for (k=1:length(list))
      oo = list{k};
      if isequal(oo.type,'pkg')
         index(end+1) = k;
         package{end+1} = get(oo,{'package',''});
         otree{end+1} = {oo};
      end
   end
   
      % now find number of obects
      
   for (k=1:length(list))
      oo = list{k};
      if ~isequal(oo.type,'pkg')
         for (i=1:length(package))
            if isequal(get(oo,{'package','?'}),package{i})
               branch = otree{i};
               branch{end+1} = oo;
               otree{i} = branch;
            end
         end
      end
   end   
end
function list = PackageTree(o)         % Get Subtree of Package
   oo = o;                             % rename package object
   package = get(oo,'package');
   if isempty(package)
      error('empty package ID');
   end
   
   o = pull(oo);                       % pull shell object
   otree = Tree(o);

   for (i=1:length(otree))
      list = otree{i};
      oi = list{1};
      if isequal(get(oi,'package'),package)
         list = {list};
         return
      end
   end
   
   error('cannot retrieve package tree');
end
function list = List(o,i)              % Get Object List of a Package  
   tree = Tree(o);
   list = tree{i};
end
function oo = Object(o,i,j)            % Get j-th Object @ i-th Package
   list = List(o,i);
   oo = list(j+1);
end

%==========================================================================
% Select By Object ID
%==========================================================================

function oo = SelectByObjId(o,ID)      % Select Object By Object ID    
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      ooid = id(oo);
      if isequal(ooid,ID)
         oo = inherit(oo,o);
         return
      end
   end
   oo = [];                            % not found
end