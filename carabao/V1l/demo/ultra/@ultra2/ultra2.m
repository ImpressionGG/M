classdef ultra2 < caramel              % Ultra2 Class Definition
   methods                             % public methods                
      function o = ultra2(arg)         % ultra2 constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
