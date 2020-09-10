classdef gaco < caramel                % Gaco Class Definition
   methods                             % public methods                
      function o = gaco(arg)           % gaco constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
