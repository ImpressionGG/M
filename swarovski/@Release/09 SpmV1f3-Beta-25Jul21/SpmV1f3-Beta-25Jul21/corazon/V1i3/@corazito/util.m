%
% UTIL   Get function handles for utility functions
%
%    One reason to provide utility functions via function handles is to
%    provide utility functions without function name clashes
%
%    Setup some short hands (function handles) in base environment
%
%       util(corazito);      % setup: either, iif, is, cuo, sho, ticn, tocn
%    
%    Assign utility functions
%
%       [iif,either..] = util('iif','either',..)  % return function hdls
%
%    Utility functions:
%       color                % color setting
%       either               % either function
%       iif                  % inline if
%       is                   % isempty or find string in list or compare
%       isfigure             % check if handle is a figure handle
%       isghandle            % check if handle is a graphics handle
%       isscreen             % check if handle is a screen handle
%       rd                   % round to n digits
%       trim                 % trim text
%       uscore               % manage underscores in texts
%
%    Examples:
%
%       iif = util(o,'iif');
%       value = iif(flag,1,0);
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
