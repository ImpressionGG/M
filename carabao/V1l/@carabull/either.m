function value = either(value,defval)  % Either Function               
%
% EITHER   'either' function
%
%    Return either value of a nonempty expression or (if empty) provide a
%    default value.
%
%       value = carabull.either(value,defval)
%
%    Use a short hand for better readability.
%
%       either = @carabull.either           % provide short hand (8 �s)
%       either = util(carabull,'either')    % provide short hand (190 �s)
%
%       value = either(value,defval)        % inline if function
%    
%    See also: CARABULL, UTIL, IIF
%
   if isempty(value)
      value = defval;
   end
end

