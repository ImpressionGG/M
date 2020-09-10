classdef carasim < carabao             % Carasim Class Definition
   methods                             % public methods                
      function o = carasim(arg)        % carasim constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
