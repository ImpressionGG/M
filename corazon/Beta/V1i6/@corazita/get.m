%
% GET   Get a parameter from a CORAZITA.
%
%          bag = get(o)                % get a bag of all parameters
%          date = get(o,'date')        % get a specific parameter
%          date = get(o,{'date',now})  % get with default value (if empty)
%
%       Multiple get
%
%          [a,b,...] = get(o,'a','b',...)
%          [a,b,...] = get(o,{'a',1},{'b',2},...)
%
%          [a,b,c] = get(o,'a,b,c')
%          [a,b,c] = get(o,{'a,b,c',1,2,3})
%
%          [A,B,C] = get(o,'system','A,B,C')     % system.A, system.B, ...
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORAZITA, SET, PROP
%
