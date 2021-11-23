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
%       refresh(o,o);                       % setup caller for refresh
%
%       o = refresh(o,cblist);              % provide cblist opt if empty
%       o = refresh(o,{});                  % clear cblist opt
%
%    Note: this method corazon/refresh overloads the corazita/refresh
%    callback, as it invokes the refresh function with the current object!
%    The call syntax o = refresh(o,inf) is equivalent to o = refresh(o,o)
%    but should not be used as it will be obsoleted in the future.
%
%       Copyright (c): Bluenetics 2020 
%
%    See also: CORAZON, REBUILD 
%
