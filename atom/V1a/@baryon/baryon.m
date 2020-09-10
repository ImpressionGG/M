classdef baryon < quark & gluon        % BARYON class
   methods
      function o = baryon(arg)         % BARYON constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@quark(arg);                 % construct QUARK base object
         o@gluon;                      % construct GLUON base object
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
