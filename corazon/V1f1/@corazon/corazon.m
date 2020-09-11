classdef corazon < corazita & corazito  % Corazon Class                
%
%    CORAZON  Class constructor for CORAZON class. CORAZON class is both
%             derived from CORAZITO and CORAZINO
%
%                o = corazon           % create generic object instance
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, SHELL, SHO, CUO
%
   methods
      function o = corazon(arg)        % corazon constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazita(arg);               % construct Corazita base object
         o@corazito;                   % construct Corazito base object
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
         if (nargout == 0)
            launch(o);
            clear o;
         end
      end
   end
end

