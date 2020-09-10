classdef carasteak < carma             % Carasteak Class Definition
   methods                             % public methods                
      function o = carasteak(arg)      % carasteak constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carma(arg);                 % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
