classdef cappuccino < carabao            % Cappuccino Class Definition
   methods                             % public methods                
      function o = cappuccino(arg)     % cappuccino constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
