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
