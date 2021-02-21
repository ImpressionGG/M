function out = is(arg1,arg2)           % General Is Function           
%
% IS      Check for non empty value or string compare
%
%    Static Carabul function. Provide a function handle for easy usage
%
%       is = @corazito.is              % provide short hand
%
%    1) For 1 input arg IS is equivalent to the call ~isempty(x). As such
%    IS returns true if the input arg is not empty, and false if empty.
%
%       nonempty = is(x);            % same as: nonempty = ~isempty(x)
%
%    2) String find in list: this applies if first argument is char and
%       second arg is a cell array. The index of first match is returned
%
%       idx = is('foo',{'fool','foo','fee'})    % idx = 2
%       idx = is('fool',{'foo','fee'})          % idx = 0
%
%    3) Save comparison against special values
%
%       match = is(x,inf)                       
%       match = is(x,nan)
%       match = is(x,[])
%       match = is(x,'')
%       match = is(x,{})
%
%    4) General comparison (same as ISEQUAL)
%
%       match = is(x,8)                % scalar comparison
%       match = is(x,[2 4 6])          % vector comparison
%       match = is({pi,'a'},{pi,'a'})  % list comparison
%
%    Note: IS always returns a boolean or integer value
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, ISEMPTY, ANY, ALL, ISEQUAL
%
   if (nargin == 1)
      out = ~isempty(arg1);
   elseif (nargin == 2)
      if isempty(arg1) && isempty(arg2)
         out = isequal(class(arg1),class(arg2));
      elseif ischar(arg1) && iscell(arg2)
         for (out = 1:length(arg2))
            if strcmp(arg1,arg2{out})
               return                  % return index of first match
            end
         end
         out = 0;                      % otherwise not found
      else
         out = isequal(arg1,arg2);     % general comparison
      end
   else
      error('1 or 2 args expected!');
   end
end
