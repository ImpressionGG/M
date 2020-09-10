function otxt = underscore(o,txt)
%
% UNDERSCORE Treat a text string with underscores
%
%    Treat a text string with underscores to show underscores
%    properly. The reason to have this function is that MATLAB
%    functions like TITLE, XLABEL, YLABEL, TEXT treat the under-
%    score character as a meta character to interprete the
%    following character as a subscript. This is prevented by the 
%    UNDERSCORE function.
%            
%       txt = underscore(o,'sample_text');
%
%    Try this:
%       title('sample_text');
%       title(underscore(o,'sample_text'));
%
%    The UNDERSCORE functionality can be deactivated by clearing
%    option 'underscore', e.g.
%
%       o = opt(core,'underscore',0);
%       title(underscore(o,'sample_text')); % no substitution !!!
%
%    See also: CARALOG, UPATH
%
   either = @o.either;                 % need some utility
   
   if isempty(txt)
      otxt = '';
      return
   end
   
   if (~ischar(txt) || size(txt,1) > 1)
      error('arg1 must be a character string!');
   end

   usc = either(opt(o,'underscore'),1);
   
   if (usc)
      otxt = '';
      for (i=1:length(txt))
         c = txt(i);
         if (c == '_')
            otxt(1,end+1:end+2) = '\_';
         else
            otxt(1,end+1) = c;
         end
      end
   else
      otxt = txt;       % no substitution
   end
   return
   
% eof   