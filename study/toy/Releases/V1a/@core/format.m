function obj = format(obj,fmt,dummy)
% 
% FORMAT   Get/set format of a CORE object
%      
%    Syntax
%       obj = core;                      % create a core object
%       fmt = format(obj);               % get format
%       obj = format(obj,'myformat');    % set format
%
%    See also CORE, GET, SET, TYPE, DATA, DISP

   if (nargin == 3)
      obj = eval('obj.data.format','''''');
      return
   end
   
   fprintf('*** warning: format() used!');
   
   if (nargin == 1)
      obj = eval('obj.data.format','''''');
   else
      obj.data.format = fmt;
   end
   return
end
