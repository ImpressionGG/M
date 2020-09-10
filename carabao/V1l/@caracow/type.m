function o = type(o,typ)
% 
% TYPE   Get/set type of a CARACOW object.
%      
%           typ = type(o);             % get type
%           o = type(o,'mytype');      % set type
%
%        Code lines: 7
%
%        See also: CARACOW
%
   if (nargin < 2)
      o = o.type;
   else
      o.type = typ;
   end
end
