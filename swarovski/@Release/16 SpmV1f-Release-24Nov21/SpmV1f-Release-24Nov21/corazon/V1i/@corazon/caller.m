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
