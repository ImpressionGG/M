function path = upath(o,path,file,arg4)
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
%    See also: CARABULL, UTIL, USCORE
%
   if (nargin == 4)
      path = upath(o,path,file);
      path = upath(o,path,arg4);
      return
   end

   if (nargin == 2)
      
      for (i=1:length(path))
         if (path(i) == '\')
            path(i) = '/';
         end
      end
      return
      
   elseif (nargin == 3)
      
      path = upath(o,path);
      file = upath(o,file);
      
      if any(path)
         if (path(end) ~= '/')
            path(end+1) = '/';
         end
      end
      path = [path,file];
      
   end
   return
end

