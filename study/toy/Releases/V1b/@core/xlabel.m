function xlabel(obj,txt)
%
% XLABEL Set xlabel
%
%    Set xlabel using UNDERSCORE method to display the underscores
%            
%       xlabel(underscore(smart,'text_with_underscores'));
%       xlabel(smart,'text_with_underscores');              % same as above
%
%    See also: CORE UNDERSCORE TITLE YLABEL TEXT
%
   xlabel(underscore(obj,txt)); 
   return
   
% eof   