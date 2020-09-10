classdef cut < caramel                  % CUT class
%
% CUT Class objects for cutting studies
%
%        o = cut
%        o = cut(type)
%
%     See also: CUT, UNI, HOGA, SIMU
%   
   methods
      function o = cut(arg)            % CAT constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@caramel(arg);               % construct CARAMEL base object
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
