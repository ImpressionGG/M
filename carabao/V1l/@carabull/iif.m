function value = iif(condition,v1,v2)  % Inline If                     
%
% IIF   Inline if function
%
%    Depending on the condition (arg1) return arg2 ('if' expression) if
%    condition is true or arg3 ('else' expression') if condition is false.
%
%          value = carabull.iif(condition,v1,v2)
%
%    Note that always both expressions (arg2 and arg3) are evaluated!
%    Use a short hand for better readability.
%
%       iif = @carabull.iif            % provide short hand (8 µs)
%       iif = util(carabull,'iif')     % provide short hand (190 µs)
%
%       value = iif(condition,v1,v2)   % inline if function
%    
%    See also: CARABULL, UTIL, EITHER
%
   if (condition)
      value = v1;
   else
      value = v2;
   end
end

