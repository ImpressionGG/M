function oo = pkg(o)
%
% PKG       Retrieve package object corresponding to given object with
%           inherited options from shell object.
%
%                oo = pkg(o);              % retrieve package object  
%
%           The package object is identified by an object's package ID:
%
%              package = get(o,'package');
%
%           If package ID is invalid or empty, or if given object is a
%           shell object then an empty matrix is returned
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZON, CONTAINER
%
   package = get(o,'package');
   oo = [];
   
   if (isempty(package) || container(o))
      return
   end
   
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      pid = get(oo,'package');
      
      if (isequal(pid,package) && isequal(oo.type,'pkg'))
         oo = inherit(oo,o);           % inherit options from shell object
         return
      end
   end
   
   oo = [];                            % not found
end
