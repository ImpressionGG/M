function [func,manager,file,line] = caller(obj,level)
%
% CALLER  Return the name of a calling function
%
%    Return the name of the calling function or caller of calling
%    functions. Optional also m-file name and line of calling
%    statement can be returned
%
%       [func,file,line] = caller(obj);    % return calling function
%
%    Optional a level argument can be provided to retrieve the name
%    of the calling function at a higher calling stack level.
%
%       func = caller(obj,1);  % same as: func = caller(obj)
%       func = caller(obj,2);  % get caller of caller
%       func = caller(obj,3);  % get caller of caller of caller
%
%    See also: CORE, REFRESH
%
   if (nargin < 2)
      level = 1;                % default level = 1
   end
   
   stack = dbstack;
   idx = level+2;
   
   try
      func = stack(idx).name;
      file = stack(idx).file;
      line = stack(idx).line;
   
      [dir,manager,ext] = fileparts(file);
   catch
      func = '';  manager = '';  file = '';  line = [];
   end
   return
end