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
%       refresh(o,o);                       % setup caller for refresh
%
%       o = refresh(o,cblist);              % provide cblist opt if empty
%       o = refresh(o,{});                  % clear cblist opt
%
%    Note: this method carabao/refresh overloads the caracow/refresh
%    callback, as it invokes the refresh function with the current object!
%    The call syntax o = refresh(o,inf) is equivalent to o = refresh(o,o)
%    but should not be used as it will be obsoleted in the future.
%
%    See also: CARABAO, REBUILD 
%
   tag = 'refresh';                         % control tag for refresh cb
   if (nargin == 1)
      o = pull(o);                          % refresh object from figure
      cblist = control(o,tag);              % refresh calling list
      tag = control(o,{'class',o.tag});     % refresh object class
      o = carabull.master([],[],tag,cblist);% invoke master callback
   elseif (nargin == 2) && (nargout == 0)
      if isequal(cblist,inf) || isobject(cblist)
         if isequal(cblist,inf)
            fprintf('*** Call syntax o = refresh(o,inf) will be obsoleted!\n');
            fprintf('*** Use o = refresh(o,o) instead!\n');
         end
         [args{2},args{1}] = caller(o,1);   % get calling function
         args(3:2+arg(o,inf)) = arg(o,0);
         refresh(o,args);
      else
         control(o,tag,cblist);             % setup refresh cback setting
         control(o,'class',class(o));       % setup refresh cback setting
         control(o,'type',active(o));       % setup refresh cback setting
      end
   elseif (nargin == 2) && (nargout > 0)
      if isempty(cblist)
         o = control(o,tag,{});             % clear refresh callback
         o = control(o,'class',class(o));   % clear refresh callback
      %elseif isempty(opt(o,tag))
      else
         o = control(o,{tag},cblist);       % provide refresh callback
         o = control(o,{'class'},class(o)); % provide refresh callback
      end
   end
end

