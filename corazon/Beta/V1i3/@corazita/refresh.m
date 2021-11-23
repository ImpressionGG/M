%
% REFRESH   Invoke or setup refresh callback
%
%    A callback represented by a callback list is either invoked or
%    prepared (as a setup). Note that the first list element must be the
%    name (char type) of the callback function (not a function handle)
%
%       refresh(o)                          % invoke refresh callback
%       refresh(o,cblist)                   % setup refresh callback
%       refresh(o,{'PlotCallback',1,'r'})   % setup refresh callback
%
%       o = refresh(o,cblist);              % provide cblist opt if empty
%       o = refresh(o,{});                  % clear cblist opt
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, REBUILD 
%
