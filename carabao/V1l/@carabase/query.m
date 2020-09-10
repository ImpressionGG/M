function info = query(o,filename)
%
% QUERY   Retrieve query info
%
%    Retrieve object's internal info, or query info from file
%
%       info = query(o)                % retrieve object's internal info
%       info = query(o,filepath)       % retrieve query info from file
%
%    Code lines: 14
%
%    See also: CARABASE
%
   if (nargin == 1)
      info.query = o.query;
      info.admin = o.admin;
      return
   end
%
% otherwise retrieve query info from file
%
   info.query = [];                    % init empty by default
   info.admin = [];                    % init empty by default
   [~,oo] = load(o,filename);

   if ~isempty(oo)
      info.query = oo.query;
      info.admin = oo.admin;
   end
end


