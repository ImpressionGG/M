function value = getp(o,tag)
% 
% GETP   Get a CARASIM object's data value
%      
%           value = getp(o,tag);     % get parameter
%
%        See also: CARASIM, PLIST
%
   list = plist(o);
   if ~o.is(tag,list)
      error('data value is not supported!');
   end
   if isequal(tag,'type')
      value = o.type;
   else
      value = data(o,tag);
   end
end
