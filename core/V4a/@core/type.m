function obj = type(obj,typ,tag)
% 
% TYPE   Get/set type of a CORE object. Optionally provide also a tag.
%      
%    Syntax:
%       obj = core('xyz');                  % create a CORE object
%       typ = type(obj);                    % get type
%       obj = type(obj,'mytype');           % set type
%
%       obj = type(obj,'mytype','mytag');   % set type & tag
%
%    See also CORE GET SET DISPLAY INFO DATA
%
   if (nargin < 2)
      obj = obj.type;
   elseif (nargin == 2)
      obj.type = typ;
   else
      obj.type = typ;
      obj.tag = tag;
   end
   return
end
