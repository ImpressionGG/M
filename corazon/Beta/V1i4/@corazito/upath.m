%
% UPATH   Convert to Unix style path
%
%    Convert to unix style path, which means replacing all '\' by
%    '/' characters.
%
%       path = upath(o,path);          % replace '\' by '/'
%
%    In addition path concatenation can e performed. Automatic determina-
%    tion whether a separation character '/' needs to be inserted.
%
%       path = upath(o,'c:\tmp\','db\dir1');
%       path = upath(o,'c:\tmp','db\dir1');       % insert '/'
%       path = upath(o,'c:\tmp','db\dir1','');    % trailing '/'
%
%    Also keep in mind:
%
%       path = upath(o,'c:/dir','');      % has one trailing '/'
%       path = upath(o,'c:/dir/','');     % has one trailing '/'
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL, USCORE
%
