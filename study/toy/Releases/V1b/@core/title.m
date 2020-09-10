function title(obj,txt)
%
% TITLE  Set title 
%
%    Set title using UNDERSCORE method to display the underscores
%            
%       title(underscore(smart,'text_with_underscores'));
%       title(smart,'text_with_underscores');               % same as above
%
%    See also: CORE, UNDERSCORE, XLABEL, YLABEL, TEXT
%
% 
   title(underscore(obj,txt)); 
   return
   
% eof   