%
% IS      Check for non empty value or string compare
%
%    Static CORAZITO function. Provide a function handle for easy usage
%
%       is = @corazito.is              % provide short hand
%
%    Alternatively use this style:
%
%       o = corazito                   % or: o = corazon
%       nonempty = o.is(x)
%       match = o.is('foo',{'foo','fee'})
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
