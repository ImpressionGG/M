function o = refresh(o,cblist)              % Refresh Handling         
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
   tag = 'control.refresh';                 % tag for refresh setting
   if (nargin == 1)
      o = pull(o);                          % refresh object from figure
      cblist = opt(o,tag);                  % refresh calling list
      o = call(o,cblist);                   % invoke callback list
   elseif (nargin == 2) && (nargout == 0)
      setting(o,tag,cblist);                % setup refresh cback setting
   elseif (nargin == 2) && (nargout > 0)
      if isempty(cblist)
         o = opt(o,tag,{});                 % clear refresh
      elseif isempty(opt(o,tag))
         o = opt(o,tag,cblist);             % setup refresh option
      end
   end
end

