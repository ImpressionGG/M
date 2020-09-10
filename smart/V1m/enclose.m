function list = enclose(obj)
%
% ENCLOSE  Conditionally encloses an object in a list, if it is not
%          already a list (a cell array)
%

   if iscell(obj)
      list = obj;     % do not enclose if already a list
   else
      list = {obj};   % enclose!
   end

% eof
