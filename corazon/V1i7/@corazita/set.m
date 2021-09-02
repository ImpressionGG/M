%
% SET   Set a parameter for a CORAZITA object
%
%          o = set(o,bag)              % refresh with a bag of parameters
%          o = set(o,[])               % clear all parameters
%          o = set(o,'date',date)      % set a specific parameter
%
%       Conditional set
%
%          o = set(o,{'date'},now)     % set only if empty
%
%       Multiple set
%
%          o = set(o,'a',1,'b',2,...)  % multiple setting
%          o = set(o,'a,b,c',1,2,3)    % compact multiple setting
%          o = set(o,'sys','A,B',1,2)  % compact multiple setting
%
%          o = set(o,{'a,b,c'},1,2,3)  % compact multiple setting
%          o = set(o,'sys',{'A,B'},1,2)% compact multiple setting
%
%       Example 1:
%       
%          A = [-1 0;0 -2]; B = [1;1]; C = [1 1]; D = 0;
%          o = set(o,'system','A,B,C,D',A,B,C,D);
%          [A,B,C,D] = get(o,'A,B,C,D');
%
%       Example 2:
%          o = set(o,{'b,c'},[1 0],1);
%          o = set(o,'system',{'C,D'},[1 0],1);
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORAZITA, GET, PROP
%
