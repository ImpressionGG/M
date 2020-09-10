function list = save(o,object,filepath)
%
% SAVE   Save a object to a CARABASE .MAT file
%
%    An arbirary class object is saved to a CARABASE type .MAT file
%    saving also the query information of CARABASE object o. The query
%    info can be loaded afterwards by the QUERY method.
%
%       save(o,object,filepath)        % save object to file path
%       save(o,object,'e:/tmp/o.mat')  % save object to e:/tmp/o.mat
%       save(o,object,'./o.mat')       % save object to ./o.mat
%       save(o,object,'o.mat')         % save object to ./o.mat
%
%    After saving the file system is 'synced', which means that all modi-
%    fied dates of parent++ directories are updated, until a 'mount point'  
%    directory '[...]' is finally reached in the path.
%
%    Remarks: it is recommended not to store objects directly but only
%    the underlying data structures. It makes sense to store the class
%    information in a class tag. After loading the constructot must be 
%    able to construct an object from the structure.
%
%    Example 1:
%
%       qo = query(object);            % generate a CARABASE query object
%       s = struct(object);            % get data structure of object
%       assert(strcmp(s.tag),class(object));
%       save(qo,s,filepath);
%
%    On load we have to do:
%
%       s = load(carabase,filepath);     % load object structure from file
%       cmd = [s.tag,'(s)'];           % create a construction command
%       object = eval(cmd);            % re-construct the object
%
%    Example 2: Caramba core function for save
%
%       function Save(o,filepath)      % Actual Saving of an Object
%          oo = access(o,'core');      % access core object
%          Object = struct(oo);        % get object structure
% 
%          if exist('carabase') ~= 2
%             save(filepath,'Object'); % save object structure
%          else
%             qo = query(o);           % get a query object
%             save(qo,Object,filepath);% save object with query info
%          end
%       end
%
%    Performance:
%       overhead for save(o,object,filepath) w/o actual save: 70 µs
%       saving empty CARACOW object (save(o,core,'core.mat')): 4.5 ms
%       saving empty CARABAO object (save(o,caramba,'caramba.mat')): 4.5 ms
%
%    Code lines: 7
%
%    See also: CARABASE, LOAD, QUERY
%
   o.admin.saved = now;                % update time stamp of saving
   
   Query = struct(o);                  % save only struct of CARABASE object
   Object = object;                    % object to be saved
   
   save(filepath,'Object','Query');    % save both data
   list = sync(o,filepath);            % sync file system
end

