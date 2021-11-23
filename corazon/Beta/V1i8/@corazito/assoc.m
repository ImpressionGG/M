%
% ASSOC   Look-up a value from a list which is associated with a key.
%
%    Generic forms:
%
%       value = o.assoc(key,table)               % associate key with value
%       table = o.assoc(key,table,{key,value})   % add/update assoc pair
%       table = o.assoc(key,table,{})            % delete assoc pair
%
%    Key can be a numeric scalar or a character string. 
%
%       o.assoc(1,{{1,'red'},{2,'green'},'black'})   % => 'red'
%       o.assoc(2,{{1,'red'},{2,'green'},'black'})   % => 'green'
%       o.assoc(5,{{1,'red'},{2,'green'},'black'})   % => 'black'
%
%       o.assoc('$T',{{'$T','r'},{'$F','b'},'k'})    % => 'r'
%       o.assoc('$F',{{'$T','r'},{'$F','b'},'k'})    % => 'b'
%       o.assoc('$w',{{'$T','r'},{'$F','b'},'k'})    % => 'k'
%
%    An assoc list consists of a list of pairs {key,value} with an
%    optional single default value as the last list element; If no
%    default value is provided, the default value is an empty
%    matrix.
%
%       o.assoc(0,{{1,'r'},{2,'b'},'k'})             % => 'k'
%       o.assoc(0,{{1,'r'},{2,'b'}})                 % => []
%   
%    Assoc pairs can be updated, added, or replaced:
%
%       table = {{1,'red'},{2,'green'},'black'}
%       table = o.assoc(3,table,{3,'blue'})     % add/update assoc pair
%       table = o.assoc(2,table,{})             % delete assoc pair
%
%    Optionally get index of find position (index = 0 if not found)
%
%       [value,idx] = o.assoc(0,{{1,'r'},{2,'b'}})
%       [table,idx] = o.assoc(2,table,{2,'y'})
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
