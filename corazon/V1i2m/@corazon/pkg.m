function [oo,list] = pkg(o)
%
% PKG       Get package object related to an object, optionally get also
%           list of all data objects belonging to the package (without
%           package object itself. Below syntax is appropriate for package
%           objects and data objects
%
%              oo = pkg(o)         % get package object
%              [oo,list] = pkg(o)  % get also list of related data objects
%
%           If arg1 is a container object then output arg 1 is empty and
%           output arg 2 is the list of all package objects in the contai-
%           ner object.
%
%              [~,list] = pkg(sho) % get list of all package objects   
%
%           Notes:
%            - arg1 is usually a package object (type 'pkg') or a data 
%              object. If arg1 is a container object then both return args
%              are empty
%            - package objects are identified by the package ID which can
%              be retrieved by PID = get(o,'package'). If PID is empty then
%              both return args are empty
%
%           Copyright(c): Bluenetics 2021 
%
%           See also: CORAZON, CONTAINER, ID
%
   package = get(o,'package');
   oo = [];
   list = {};
   
   if (container(o))
      o = pull(o);                        % access shell object
      for (i=1:length(o.data))
         oi = o.data{i};
         if isequal(oi.type,'pkg')
            list{end+1} = oi;
         end
      end
      return
   elseif isempty(package)
      return
   else

         % seek package object and optionally list of related data objects

   o = pull(o);                        % access shell object
   for (i=1:length(o.data))
      oi = o.data{i};
      PID = get(oi,'package');

      if isequal(PID,package)
         if isequal(oi.type,'pkg')
            oo = oi;                   % package object found
            if (nargout <= 1)
               break;
            end
         else
            list{end+1} = oi;          % add data object to list
         end
      end
   end
end
