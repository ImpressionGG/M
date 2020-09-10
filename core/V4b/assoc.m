function value = assoc(key,list)
%
% ASSOC   Look-up a value from a list which is associated with a key.
%
%    Key can be a numeric scalar or a character string. 
%
%       assoc(1,{{1,'red'},{2,'green'},'black'})   % => 'red'
%       assoc(2,{{1,'red'},{2,'green'},'black'})   % => 'green'
%       assoc(5,{{1,'red'},{2,'green'},'black'})   % => 'black'
%
%       assoc('$T',{{'$T','r'},{'$F','b'},'k'})    % => 'r'
%       assoc('$F',{{'$T','r'},{'$F','b'},'k'})    % => 'b'
%       assoc('$w',{{'$T','r'},{'$F','b'},'k'})    % => 'k'
%
%    An assoc list consists of a list of pairs {key,value} with an
%    optional single default value as the last list element; If no
%    default value is provided, the default value is an empty
%    matrix.
%
%       assoc(0,{{1,'r'},{2,'b'},'k'})             % => 'k'
%       assoc(0,{{1,'r'},{2,'b'}})                 % => []
%
%    See also: CORE
%
   if (nargin ~= 2)
      error('2 input arguments required!');
   end
   
   if ~(isnumeric(key) || ischar(key)) 
      error('Input arg1 (key) must be numeric or character string!');
   end
   
   if ~iscell(list)
      error('Input arg2 (assoc list) must be a list (cell array)!');
   end

   n = length(list);
   for (i=1:n)
      pair = list{i};
      if iscell(pair)    
         if (length(pair) ~= 2)
            error('assoc list needs to be built-up of assoc pairs (optionally terminated by a default value)!');
         else
            pairkey = pair{1};  value = pair{2};
            scalar = (length(key)*length(pairkey) == 1);
            if (isnumeric(key) && isnumeric(pairkey) && scalar)
               if (key == pairkey)
                  return
               end
            elseif (ischar(key) && ischar(pairkey))
               if strcmp(key,pairkey)
                  return;
               end
            end
         end
      else                   % potentially a default value!
         if (i == n)         % last element?
            value = pair;    % return default value
            return
         else
            error('Default value of assoc list must be last list element!');
         end   
      end
   end
   
   value = [];               % if no default value is provided we return []
   return

% eof   