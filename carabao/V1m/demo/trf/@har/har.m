classdef har < trf                     % Har Class Definition
   methods                             % public methods                
      function o = har(arg)            % har constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@trf(arg);                   % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
