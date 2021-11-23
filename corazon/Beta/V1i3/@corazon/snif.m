%
% SNIF   Snif n lines into text file and return first n lines as a list
%        of text strings. If text file has less than n lines than empty
%        strings are returned
%
%           lines = snif(o,path,n)     % snif n lines
%           lines = snif(o,path)       % snif 10 lines
%
%        By setting verbose option >= 3 read lines are echoed to console
%
%           lines = snif(opt(o,'verbose',3),path)
%
%        Options:
%           verbose          % echoing read lines (default: 0)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORAZON, IMPORT, READ
%
