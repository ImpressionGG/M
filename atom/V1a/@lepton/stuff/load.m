function [object,o] = load(o,filepath)
%
% LOAD   Load an object from a CARABASE .MAT file
%
%    An class object which has been saved previously to a CARABASE type .MAT
%    file will be loaded again. 'o' is a CORON object which provides the
%    LOAD method
%
%       object = load(o,filepath)      % load object from file path
%       object = load(o,'e:/tmp/o.mat')% load object from e:/tmp/o.mat
%       object = load(o,'./o.mat')     % load object from ./o.mat
%       object = load(o,'o.mat')       % load object from ./o.mat
%
%    It is also to return the saved CARABASE query object (o):
%
%       [object,o] = load(o,filepath)  % load object & CARABASE query object
%
%    Remarks: it is recommended not to store objects directly but only
%    the underlying data structures. It makes sense to store the class
%    information in a class tag. After loading the constructot must be 
%    able to construct an object from the structure.
%
%    Example 1:
%
%       quo = query(object);           % generate a CARABASE query object
%       s = struct(object);            % get data structure of object
%       assert(strcmp(s.tag),class(object));
%       save(quo,s,filepath);
%
%    On load we have to do:
%
%       s = load(carabase,filepath);   % load object structure from file
%       cmd = [s.tag,'(s)'];           % create a construction command
%       object = eval(cmd);            % re-construct the object
%
%    Example 2: core load function for Caramba objects. The reconstruction
%    of the original object happens in function access.
%
%       function oo = Load(o,filepath) % Actual Loading of an Object
%          if exist('carabase') == 2   % carabase toolbox accessible
%             [Object,qo] = load(carabase,filepath);
%             oo = core(Object);       % first construct a core object
%             oo = access(oo);         % restore balance
%          else
%             record = load(filepath); % loads 'Object' structure
%             oo = core(record.Object);% first construct a core object
%             oo = access(oo);         % restore balance
%          end
%       end
%
%    Code lines: 16
%
%    See also: CARABASE, SAVE, QUERY
%
   record = load(filepath);            % load all saved objects
   if isfield(record,'Object')
      object = record.Object;          % return saved object
   else
      object = [];
   end
   
   if (nargout > 1) 
      if isfield(record,'Query')
         o.query = record.Query.query;
         o.admin = record.Query.admin;
      elseif isfield(record,'Corona')
         o.query = record.Corona.query;
         o.admin = record.Corona.admin;
      else
         o = [];
      end
   end
end
