function ylabel(obj,txt)
%
% YLABEL Set ylabel
%
%    Set ylabel using UNDERSCORE method to display the underscores
%            
%       ylabel(underscore(smart,'text_with_underscores'));
%       ylabel(smart,'text_with_underscores');              % same as above
%
%    See also: CORE, UNDERSCORE, TITLE, XLABEL, TEXT
% 
   ylabel(underscore(obj,txt)); 
   return
   
% eof   