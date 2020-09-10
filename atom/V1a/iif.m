function value = iif(condition,v1,v2)  % Inline If                     
%
% IIF   Inline if function
%
%    Depending on the condition (arg1) return arg2 ('if' expression) if
%    condition is true or arg3 ('else' expression') if condition is false.
%
%          value = iif(condition,v1,v2)
%
%    Note that always both expressions (arg2 and arg3) are evaluated!
%    
%    See also: ATOM, GLUON, UTIL, EITHER
%
   if (condition)
      value = v1;
   else
      value = v2;
   end
end

