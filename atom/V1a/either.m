function value = either(value,defval)  % Either Function               
%
% EITHER   'either' function
%
%    Return either value of a nonempty expression or (if empty) provide a
%    default value.
%
%       value = either(value,defval)
%    
%    See also: ATOM, GLUON, UTIL, IIF
%
   if isempty(value)
      value = defval;
   end
end

