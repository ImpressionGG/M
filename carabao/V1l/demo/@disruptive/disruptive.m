classdef disruptive < caramel            % Disruptive Class Definition
   methods                             % public methods                
      function o = disruptive(arg)     % disruptive constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
