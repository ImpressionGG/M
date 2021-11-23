function [func,manager,file,line] = caller(o,level)
%
% CALLER  Return the name of a calling function
%
%    1) Return the name of the calling function or caller of calling
%    functions. Optional also m-file name and line of calling
%    statement can be returned
%
%       [func,file,line] = caller(o);    % return calling function
%
%    2) Optional a level argument can be provided to retrieve the name
%    of the calling function at a higher calling stack level.
%
%       func = caller(o,1);  % same as: func = caller(o)
%       func = caller(o,2);  % get caller of caller
%       func = caller(o,3);  % get caller of caller of caller
%
%    3) Check if a function is in calling stack
%
%       found = caller(o,'Activate');
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, REFRESH
%
   if (nargin < 2)
      level = 1;                % default level = 1
   end
 
   stack = dbstack;
   if isa(level,'double')
      idx = level+2;
      try
         func = stack(idx).name;
         [~,func,~] = fileparts(func);    % strip off 'plot/' of 'plot/PlotCb'
         file = stack(idx).file;
         line = stack(idx).line;

         [dir,manager,ext] = fileparts(file);
      catch
         func = '';  manager = '';  file = '';  line = [];
      end
   elseif ischar(level)
      for (i=1:length(stack))
         func = stack(i).name;
         [~,func,~] = fileparts(func);    % strip off 'plot/' of 'plot/PlotCb'
         if isequal(level,func)
            func = true;
            return
         end
      end
      func = false;                       % not found
   else
      error('arg2 must be either double or char!');
   end
   return
end