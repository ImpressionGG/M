function value = iif(condition,v1,v2)  % Inline If                     
%
% IIF   Inline if function
%
%    Depending on the condition (arg1) return arg2 ('if' expression) if
%    condition is true or arg3 ('else' expression') if condition is false.
%
%          value = gluon.iif(condition,v1,v2)
%
%    Note that always both expressions (arg2 and arg3) are evaluated!
%    Use a short hand for better readability.
%
%       iif = @gluon.iif               % provide short hand
%       iif = util(gluon,'iif')        % provide short hand
%
%       value = iif(condition,v1,v2)   % inline if function
%    
%    See also: GLUON, UTIL, EITHER
%
   if (condition)
      value = v1;
   else
      value = v2;
   end
end

