classdef corazon < corazita & corazito % Corazon Class                 
%
%    CORAZON  Class constructor for CORAZON class. CORAZON class is both
%             derived from CORAZITA and CORAZITO class
%
%                o = corazon           % create generic object instance
%                o = corazon('smp')    % create 'smp' typed object instance
%                corazon               % launch corazon shell
%                
%             Key Methods:         
%
%                type                  % get/set/ask object type
%                get                   % get object parameters
%                set                   % set object parameters
%                data                  % get/set object data
%                work                  % get/set object's working data
%                var                   % get/set object variables
%                opt                   % get/set object options
%                arg                   % get/set object arguments
%
%                shell                 % launch corazon standard shell
%                launch                % launch any shell
%
%                push                  % push object into shell
%                pull                  % pull object from shell
%                current               % get/set current object
%                cuo                   % short hand for current object
%                sho                   % shorthand for shell object
%                children              % get children of shell or package
%                id                    % get ID of object/ retrieve by ID
%
%                gcf                   % get current figure
%                figure                % get/set object related figure hdl
%                figure                % get/set object related axes handle 
%                menu                  % menu creation building blocks
%                mitem                 % create a menu item
%                mhead                 % create a menu header
%                check                 % add check feature to menu item
%                choice                % add choice feature to menu item
%                charm                 % add charm feature to menu item
%                heading               % add heading to graphics
%                footer                % add footer to graphics
%                dark                  % dark mode control
%                grid                  % grid control
%                subplot               % subplot control
%                cls                   % clear screen
%
%             Toolbox Generation
%
%                rapid                 % rapid toolbox construction
%
%             Plugin
%
%                plugin                % plugin control
%                sample                % plugin sample
%                simple                % plugin sample
%                legacy                % tiny plugin sample (a good start)
%
%             Auxillaty Methods:
%
%                folder                % get parent folder of class
%                shelf                 % get/set shelf data
%
%             Copyright(c): Bluenetics 2020 
%
%             See also: CORAZON, SHELL, SHO, CUO
%
   methods
      function o = corazon(arg)        % corazon constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazita(arg);              % construct Corazita base object
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

