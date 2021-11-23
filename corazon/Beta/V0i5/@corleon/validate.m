function out = validate(o,query)       % Validate Query Data Integrity 
%
% VALIDATE   Validate integrity of a CORLEON object
%
%    With an output argument provided the function returns 1 if the
%    CORLEON object has valid integrity, otherwise 0. Without output
%    argument the function generates an error in case of invalid integrity.
%
%       valid = validate(o)            % return validation status (0/1)
%       valid = validate(corleon)       % return 0 (generic CORLEON)
%       validate(o)                    % error if invalid
%
%    Alternatively an external query structure can be checked for vali-
%    dation.
%
%       valid = validate(corleon,query) % validate query data passed as arg
%       valid = validate(o,query)      % validate query data passed as arg
%
%    Validation rules: The query information must be a structure with the
%    following components:
%
%       query.project                  % project identifier (string)
%       query.kind                     % kind of (list of strings)
%       query.serial                   % serial number (list of strings)
%       query.datenum                  % serial date number (double)
%
%    The serial date number is a date/time format used by MATLAB, which
%    is e.g. returned by functions DATENUM and NOW.
%
%    Example:
%
%       query.title = 'Sample Data'       % title for data object
%       query.comment = {'a trial'}       % comment for data object
%       query.project = 'My Project';     % project identifier
%       query.kind = 'ANY';               % data kind can be of any kind
%       query.serial = {'123456789'};     % list of serial numbers
%       query.datenum = now;              % date/time stamp
%       query.class = 'pbi'               % PBI class
%       query.author = 'emp001609'        % Author short cut or name
%
%       o = corleon(query);                % construct CORLEON object
%       valid = validate(o);              % valid = 1
%
%    Remarks: the CORLEON constructor implicitely validates the internal
%    query structure at the end of each construction process, unless the
%    corleon object is generic (empty query structure).
%
%    Performance: 60 us for validation of a query structure
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORLEON, QUERY
%
   valid = 1;                          % integrity is valid by default
   err = (nargout == 0);               % err=1: generate errors
   
   if (nargin < 2)
      query = o.query;                 % take object's query info
   end
%
% check if query data is a structure
%
   if valid && ~isstruct(query)
      valid = Error(err,'query data must be a structure!');
   end
   
   valid = check(query,err,valid,'title','char');     % check title
   valid = check(query,err,valid,'comment','cell');   % check comment
   valid = check(query,err,valid,'project','char');   % check project
   valid = check(query,err,valid,'kind','cell');      % check kind
   valid = check(query,err,valid,'serial','cell');    % check serial number
   valid = check(query,err,valid,'datenum','double'); % check datenum
   valid = check(query,err,valid,'class','char');     % check class
   valid = check(query,err,valid,'author','char');    % check author
%
% set output arg
%
   if (nargout > 0)
      out = valid;
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function valid = Error(errmode,errmsg) % Generate an Error             
%
   if (errmode == 0)
      valid = 0;
      return
   end
   
   error(errmsg);
end
   
function valid = check(query,err,valid,tag,type)
   if valid && ~isfield(query,tag)
      valid = Error(err,sprintf('%s is missing in query data!',tag));
   end
   if valid && ~isa(getfield(query,tag),type)
      valid = Error(err,sprintf('%s must be of type %s!',tag,type));
   end
   
   if isequal(type,'cell')
      list = getfield(query,tag);
      for (i=1:length(list))
         if valid && ~ischar(list{i})
            valid = Error(err,'All machine list items must be char type!');
         end
      end
   end
end

