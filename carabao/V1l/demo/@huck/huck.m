classdef huck < caramel                % Cuk Class Definition
   methods                             % public methods                
      function o = huck(arg)           % huck constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
