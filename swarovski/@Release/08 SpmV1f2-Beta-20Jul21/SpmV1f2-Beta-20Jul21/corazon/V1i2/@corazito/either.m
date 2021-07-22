%
% EITHER   'either' function
%
%    Return either value of a nonempty expression or (if empty) provide a
%    default value.
%
%       value = corazito.either(value,defval)
%
%    Use a short hand for better readability.
%
%       either = @corazito.either           % provide short hand (8 �s)
%       either = util(corazito,'either')    % provide short hand (190 �s)
%
%       value = either(value,defval)        % inline if function
%    
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, UTIL, IIF
%
