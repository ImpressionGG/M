function o = type(o,typ)
% 
% TYPE   Get/set type of a CORAZITA object.
%      
%           typ = type(o);             % get type
%           o = type(o,'mytype');      % set type
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA
%
   if (nargin < 2)
      o = o.type;
   else
      o.type = typ;
   end
end
