function o = lepton(info)
% 
% LEPTON   Construct a LEPTON object
%
%    LEPTON objects are used to provide query informations in a LEPTON
%    database system. 
%
%       o = lepton(query)          % construct LEPTON object from query info
%       o = lepton                 % construct a generic LEPTON object
%       o = lepton(struct(oo))     % copy constructor
%
%    'query' is a structure which contains tags which can be seeked by 
%    database queries. See help lepton/query for query structure details.
%
%    Lepton database information is stored in the file system as .MAT files
%    where every .MAT file contains two kinds of information 
%
%       a) object information for particular class objects
%       b) query information for the Lepton database
%
%   Methods:
%      lepton       % constructor                                     (#24)
%      display      % display LEPTON object                           (#32)
%      load         % load object from .MAT file                      (#16)
%      mountable    % check path for being mountable                  (# 8)
%      query        % get query info from .MAT file                   (#14)
%      save         % save object to .MAT file                        (# 7)
%      sync         % sync file system                                (#43)
%      validate     % validate integrity of the query information     (#44)
%      version      % LEPTON toolbox version, release notes           (#12)
% 
%   Code lines: 24                                              total: #200
%
%   See also LEPTON, DISPLAY, LOAD, SAVE, QUERY, SYNC, VALIDATE, VERSION
%
   if (nargin == 0)
      o.query = [];
      o.admin = [];
   elseif isfield(info,'admin') && isfield(info,'query') % copy constructor
      o.query = info.query;
      o.admin = info.admin;
   else
      o.query = info;                  % init query information
      o.admin = [];                    % init admin information
   end
%
% set object data members & construct object
%
   if isempty(o.admin) && (nargin > 0)
      admin.version = version(lepton); % LEPTON version
      admin.octave = ver;              % OCTAVE version
      admin.created = now;             % object creation date
      admin.saved = 0;                 % object save date
      o.admin = admin;                 % store admin data to object
   end
   
   o = class(o,'lepton');              % construct LEPTON object
%
% validate object
%
   if (nargin ~= 0)
      validate(o);                     % validate object integrity
   end
   return
end

% Comments to the implementation
%
% - total exactly 200 code lines
% - no eval statement used
% - used isequal for string comparison (lepton/validate/check)
% - used sequential evaluation of && operator (lepton/mountable)
%   => ok = (length(name)>=2) && (name(1) == '[') && (name(end) == ']');
%