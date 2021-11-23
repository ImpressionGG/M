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
