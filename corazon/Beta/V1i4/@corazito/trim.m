%
% TRIM   Trim a character string
%
%    Remove leading and trailing white space.
%
%       txt = trim(' A B ');           % both side trim => return 'A B'
%       txt = trim(' A B ',0);         % both side trim => return 'A B'
%
%       txt = trim(' A B ',-1);        % left side trim => return 'A B '
%       txt = trim(' A B ',+1);        % right side trim => return ' A B'
%
%    If a second output argument is provided we will get either the
%    first character of the trimmed string if nonempty, or otherwise an
%    empty string.
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
