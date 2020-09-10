classdef corasim < corazon             % Corasim Class Definition
   methods                             % public methods
      function o = corasim(arg)        % corasim constructor
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazon(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name

         if (nargout == 0)
            launch(o);
            clear o;
         end
      end
   end
end
