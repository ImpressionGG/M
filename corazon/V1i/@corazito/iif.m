%
% IIF   Inline if function
%
%    Depending on the condition (arg1) return arg2 ('if' expression) if
%    condition is true or arg3 ('else' expression') if condition is false.
%
%          value = corazito.iif(condition,v1,v2)
%
%    Note that always both expressions (arg2 and arg3) are evaluated!
%    Use a short hand for better readability.
%
%       iif = @corazito.iif            % provide short hand (8 �s)
%       iif = util(corazito,'iif')     % provide short hand (190 �s)
%
%       value = iif(condition,v1,v2)   % inline if function
%    
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL, EITHER
%
