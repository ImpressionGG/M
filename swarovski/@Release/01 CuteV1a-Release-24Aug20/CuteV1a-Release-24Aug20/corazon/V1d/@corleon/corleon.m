classdef corleon
% 
% CORLEON   Construct a CORLEON object
%
%    Corleon objects are used to provide query informations in a Corleon
%    database system. 
%
%       o = corleon(query)      % construct CORLEON object from query info
%       o = corleon             % construct a generic CORLEON object
%       o = corleon(struct(oo)) % copy constructor
%
%    'query' is a structure which contains tags which can be seeked by 
%    database queries. See help corleon/query for query structure details.
%
%    Corleon database information is stored in the file system as .MAT 
%    files where every .MAT file contains two kinds of information 
%
%       a) object information for particular class objects
%       b) query information for the Corleon database
%
%   Methods:
%      corleon      % constructor                                    (#24)
%      display      % display CORLEON object                         (#32)
%      load         % load object from .MAT file                     (#16)
%      mountable    % check path for being mountable                 (# 8)
%      query        % get query info from .MAT file                  (#14)
%      save         % save object to .MAT file                       (# 7)
%      sync         % sync file system                               (#43)
%      validate     % validate integrity of the query information    (#44)
%      version      % Corleon toolbox version, release notes         (#12)
% 
%   Copyright(c): Bluenetics 2020 
%
%   See also CORLEON, DISPLAY, LOAD, SAVE, QUERY, SYNC, VALIDATE, VERSION
%
   properties
      query                            % query data
      admin                            % administration data
   end
   methods
       function o = corleon(info)

            if (nargin == 0)
            o.query = [];
            o.admin = [];
         elseif isfield(info,'admin') && isfield(info,'query') 
            o.query = info.query;            % copy constructor
            o.admin = info.admin;
         else
            o.query = info;                  % init query information
            o.admin = [];                    % init admin information
            end
      
            % set object data members & construct object
            
         if isempty(o.admin) && (nargin > 0)
            admin.version = version(corleon);% CORLEON version
            admin.matlab = ver;              % MATLAB version
            admin.created = now;             % object creation date
            admin.saved = 0;                 % object save date
            o.admin = admin;                 % store admin data to object
         end

            % validate object

         if (nargin ~= 0)
            validate(o);                     % validate object integrity
         end
         return
       end
   end
end

% Comments to the implementation
%
% - total exactly 200 code lines
% - no eval statement used
% - used isequal for string comparison (corleon/validate/check)
% - used sequential evaluation of && operator (corleon/mountable)
%   => ok = (length(name)>=2) && (name(1) == '[') && (name(end) == ']');
%