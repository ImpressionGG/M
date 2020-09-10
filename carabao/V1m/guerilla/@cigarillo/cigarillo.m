classdef cigarillo < caramel           % Cigarillo Class Definition
   methods                             % public methods                
      function o = cigarillo(arg)      % cigarillo constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
