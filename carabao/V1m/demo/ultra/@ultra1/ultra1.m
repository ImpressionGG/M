classdef ultra1 < caramel              % Ultra1 Class Definition
   methods                             % public methods                
      function o = ultra1(arg)         % ultra1 constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
