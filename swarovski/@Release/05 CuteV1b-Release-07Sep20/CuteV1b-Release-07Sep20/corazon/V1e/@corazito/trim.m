function [txt,c] = trim(txt,where)
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
   if (nargin < 3)
      where = 0;
   end
   
   if (where <= 0)
      while ~isempty(txt)
         if isspace(txt(1))
            txt(1) = '';
         else
            break
         end
      end
   end
   
   if (where >= 0)
      while ~isempty(txt)
         if isspace(txt(end))
            txt(end) = '';
         else
            break
         end
      end
   end
   
   if (nargout > 1)
      c = '';
      if ~isempty(txt)
         c  = txt(1);
      end
   end
   return
end
