function oo = select(o,i,j)            % CORAZON Select Method         
%
% SELECT   Get object tree or select object by package and object index.
%
%             tree = select(o)         % get (hierarchical) object tree
%
%          Output arg numbers has dimension equal to number of packages
%          where numbers(i) tells the number of objects in package i
%
%             list = select(o,i)       % get all objects of i-th package
%             oo = select(o,i,j)       % get j-th object from i-th package
%
%          Show object tree:
%
%             select(sho)
%
%          Select by object ID
%
%             oo = select(o,id(oo))               % select by object ID
%             oo = select(o,'@LPC03.200609.3')    % select by object ID
%
%          Example:
%
%             tree = select(o);
%             for (i=1:length(tree))
%                list = tree{i};       % package list
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
      tree = Tree(o);                  % get object tree
      if (nargout >= 1)
         oo = tree;
      else
         Show(o,tree);                 % show object tree
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
   tree = select(o);
   for (i=1:length(tree))
      list = tree{i};                  % package list
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

function tree = Tree(o)                % Build Object Tree             
   if ~container(o)
      error('no shell object');
   end
   
   list = o.data;
   assert(iscell(list));
   
      % first find all packages
      
   tree = {};  package = {};  index = [];
   
   for (k=1:length(list))
      oo = list{k};
      if isequal(oo.type,'pkg')
         index(end+1) = k;
         package{end+1} = get(oo,{'package',''});
         tree{end+1} = {oo};
      end
   end
   
      % now find number of obects
      
   for (k=1:length(list))
      oo = list{k};
      if ~isequal(oo.type,'pkg')
         for (i=1:length(package))
            if isequal(get(oo,{'package','?'}),package{i})
               branch = tree{i};
               branch{end+1} = oo;
               tree{i} = branch;
            end
         end
      end
   end   
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