function value = either(value,defval)  % Either Function               
%
% EITHER   'either' function
%
%    Return either value of a nonempty expression or (if empty) provide a
%    default value.
%
%       value = gluon.either(value,defval)
%
%    Use a short hand for better readability.
%
%       either = @gluon.either           % provide short hand (8 ?s)
%       either = util(gluon,'either')    % provide short hand (190 ?s)
%
%       value = either(value,defval)        % inline if function
%    
%    See also: GLUON, UTIL, IIF
%
   if isempty(value)
      value = defval;
   end
end

