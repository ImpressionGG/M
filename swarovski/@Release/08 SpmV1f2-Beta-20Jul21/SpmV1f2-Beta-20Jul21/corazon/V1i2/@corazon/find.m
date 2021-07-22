%
% FIND   Find first occurence of a match
%
%    Find first occurence of a substring within a string, or find first
%    occurrence in a logical vector. The function always return an integer,
%    which simplifies subsequent processing.
%
%       idx = find(o,'cde','abcdefgh')               % idx = 3
%       idx = find(o,'ghi','abcdefgh')               % idx = 0
%       idx = find(o,'','abcdefgh')                  % idx = 0
%
%       idx = find(o,[0 0 1 1 0])                    % idx = 3
%       idx = find(o,[0 0 0 0 0])                    % idx = 0
%       idx = find(o,[])                             % idx = 0
%
%       idx = find(o,[5 6 7]==[7 6 7])               % idx = 2
%       idx = find(o,[5 6 7]==[7 8 9])               % idx = 0
%       idx = find(o,[5 6 7]==7)                     % idx = 3
%
%       idx = find(o,'bc',{'abc','ab','bc'})         % idx = 3
%       idx = find(o,'bc',{'bc0','bc','bc'})         % idx = 2
%       idx = find(o,'bc',{'abc','ab','de'})         % idx = 0
%       idx = find(o,'bc',{})                        % idx = 0
%
%    Note: the function needs less than 20 micro seconds
%
%       Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, STRFIND
%
