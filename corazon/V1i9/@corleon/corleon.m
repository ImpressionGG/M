% 
% CORLEON   Construct a CORLEON object
%
%    Corleon objects are used to provide query informations in a Corleon
%    database system. 
%
%       o = corleon(query)        % construct CORLEON object from query info
%       o = corleon               % construct a generic CORLEON object
%       o = corleon(struct(oo))   % copy constructor
%
%    'query' is a structure which contains tags which can be seeked by 
%    database queries. See help corleon/query for query structure details.
%
%    Corleon database information is stored in the file system as .MAT files
%    where every .MAT file contains two kinds of information 
%
%       a) object information for particular class objects
%       b) query information for the Corleon database
%
%   Methods:
%      corleon     % constructor                                     (#24)
%      display      % display CORLEON object                         (#32)
%      load         % load object from .MAT file                      (#16)
%      mountable    % check path for being mountable                  (# 8)
%      query        % get query info from .MAT file                   (#14)
%      save         % save object to .MAT file                        (# 7)
%      sync         % sync file system                                (#43)
%      validate     % validate integrity of the query information     (#44)
%      version      % Corleon toolbox version, release notes         (#12)
% 
%   Copyright(c): Bluenetics 2020 
%
%   See also CORLEON, DISPLAY, LOAD, SAVE, QUERY, SYNC, VALIDATE, VERSION
%
