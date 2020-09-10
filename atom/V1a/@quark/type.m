function o = type(o,typ)
% 
% TYPE   Get/set type of a QUARK object.
%      
%           typ = type(o);             % get type
%           o = type(o,'mytype');      % set type
%
%        Code lines: 7
%
%        See also: QUARK
%
   if (nargin < 2)
      o = o.typ;
   else
      o.typ = typ;
   end
end
