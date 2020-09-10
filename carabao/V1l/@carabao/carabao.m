classdef carabao < caracow & carabull  % v0c/@carabao/carabao.m
   methods
      function o = carabao(arg)        % carabao constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caracow(arg);               % construct Caracow base object
         o@carabull;                   % construct Carabull base object
         o.tag = mfilename;            % tag must equal derived class name
         
            % if data is a list of bags we have to convert all 
            % bags into objects

         if iscell(o.data)
            for (i=1:length(o.data))
               if isstruct(o.data{i})
                  o.data{i} = construct(o,o.data{i});
               end
            end
         end
      end
   end
end
