function cb = click(o,cblist)
%
% CLICK  Setup button click callback function
%
%    Syntax
%
%       click(o);                % standard redirection
%       callback = click(o);     % get current callback
%
%       click(o,{@refresh})      % setup figure refreshment
%       click(o,{@Click})        % call Click callback
%       click(o,{})              % deactivate click callback
%
%    Example:
%
%       menu(o,'Click')          % run default button click callback
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, INVOKE, MENU, REFRESH
%

%
% One input argument
% a) click(o) % standard redirection
%
   while (nargin == 1)
      if (nargout == 0)
         cb = control(o,'click');               % default click callback
         set(gcf,'WindowButtonDownFcn',cb);
      else
         cb = get(gcf,'WindowButtonDownFcn');
      end
      return
   end
%
% Two input arguments and empty arg2
% a) click(o,'') % deactivate click callback
%
   while (nargin == 2) && isempty(cblist)
      set(gcf,'WindowButtonDownFcn','');
      return
   end
%
% Two input arguments and non-empty arg2
% a) click(o,{@refresh}) % setup figure refreshment
% b) click(o,'Click') % call Click callback
%
   while (nargin == 2) && iscell(cblist)
      callback = call(o,o.tag,cblist);   % construct callback
      set(gcf,'WindowButtonDownFcn',callback);
      return
   end
%
% never run beyond that point
%
   error('bad calling syntax!');
end