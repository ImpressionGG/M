function dd
%
% DD     Data directed command line interpreter
%        To return from DD enter 'exit'
%
%
   while (1)
      cmd = input('dd : ','s');

      if ( strcmp(cmd,'exit') )
         break;
      end

      if ( length(cmd) > 0 )
         % mexdd(cmd);
         mexdd(['(convert(dd "',cmd,'"))']);
 who
      end
   end

% eof

