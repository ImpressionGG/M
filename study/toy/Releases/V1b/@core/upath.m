function path = upath(obj,path,file,arg4)
%
% UPATH     Convert to unix style path, which means replacing all '\' by
%           '/' characters.
%
%              path = upath(core,path);            % replace '\' by '/'
%
%           In addition path concatenation can e performed. Automatic
%           determination whether a separation character '/' needs to
%           be inserted.
%
%              path = upath(core,'c:\tmp\','db\dir1');
%              path = upath(core,'c:\tmp','db\dir1');       % insert '/'
%              path = upath(core,'c:\tmp','db\dir1','');    % trailing '/'
%
%           Also mention:
%
%              path = upath(core,'c:/dir','');     % has one trailing '/'
%              path = upath(core,'c:/dir/','');    % has one trailing '/'
%
%           See also: CORE
%
   if (nargin == 4)
      path = upath(obj,path,file);
      path = upath(obj,path,arg4);
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
      
      path = upath(obj,path);
      file = upath(obj,file);
      
      if any(path)
         if (path(end) ~= '/')
            path(end+1) = '/';
         end
      end
      path = [path,file];
      
   end
   return
end

