function obj = type(obj,typ)
% 
% TYPE   Get type of a CORE object
%      
%    Syntax:
%       obj = shell('xyz');            % create a core object
%       typ = type(obj);               % get type
%       obj = type(obj,'mytype');      % set type
%
%    See also CORE GET SET DISPLAY INFO DATA
%
   if (nargin < 2)
      obj = obj.type;
   else
      obj.type = typ;
   end
   return
end
