function otxt = underscore(obj,txt)
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
%       txt = underscore(smart,'sample_text');
%
%    Try this:
%       title('sample_text');
%       title(underscore(smart,'sample_text'));
%
%    The UNDERSCORE functionality can be deactivated by clearing
%    option 'underscore', e.g.
%
%       obj = option(smart,'underscore',0);
%       title(underscore(obj,'sample_text')); % no substitution !!!
%
%    See also: CORE, CORE/TITLE, CORE/XLABEL, CORE/YLABEL, 
%              CORE/TEXT, XLABEL, YLABEL, TITLE, TEXT
%
   if (~ischar(txt) || size(txt,1) > 1)
      error('arg1 must be a character string!');
   end

   usc = either(option(obj,'underscore'),1);
   
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