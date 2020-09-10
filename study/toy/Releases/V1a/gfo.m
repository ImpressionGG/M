function out = gfo(obj,fig)
%
% GFO   Get current figure object including figure settings. 
%
%    Fetch menu's user data of current figure, extract object and push
%    down current figure's settings into object. In addition user
%    data of current object is stored in 'args' parameter. Note that
%    the object entry is removed before pushing settings into object
%    (to prevent duplicate data, which might sometimes be huge.
%
%    Push the object up:
%
%       gfo(obj)            % push obj into figure
%       gfo(obj,fig)        % push obj into figure with handle fig
%
%    Get the object down:
%
%       obj = gfo           % get figure object (including settings)
%       obj = gfo(5)        % get figure object from figure 5
%
%    Get some parameters down:
%
%       filter = get(gfo,'filter');
%
%    Example:
%       obj = chameo;       % create CHAMEO object
%       menu(obj);          % open figure & menu for the object
%       obj = gfo;          % current fig. object with fig. settings 
%       ud = arg(obj);      % same as: ud = get(obj,'arg')
%       settings = setting; % retrieve settings
%             
%    See also: CORE, GCBO, GAO, ARG, CHECK, CHOICE, SETTING
%
   if (nargin == 0)
      obj = [];
   end
   
   if (nargin < 2)
      fig = gcf;
   end
   
   obj = newgfo(obj,fig);
   
      % post process. In case of a syntax obj = gfo, or obj = gfo(fig)
      % we get already a non empty object. On the other hand if we push
      % an object to GFO, like gfo(obj), we will get an empty obj back by
      % newgfo. If an output obj is required then we have again to fetch it
      % with GFO.
      
   if isempty(obj) && nargout > 0
      if (nargin == 1)
         obj = gfo;
      elseif (nargin == 2)
         obj = gfo(fig);
      end
   end
   
   if (nargout > 0)
      out = obj;
   end
      
   return

%==========================================================================   

function obj = oldgfo(obj)          % old, alternative style

   if isempty(obj)                   % get object
      ohdl = setting('shell.ohdl'); 
      obj = ohdl{1};                 % work around style
      settings = setting;            % get menu/figure settings
      settings.shell.ohdl = [];      % clear handle to figure's object
      obj = option(obj,settings);    % push settings into object's options
   else
      ohdl = {};
      ohdl{1} = obj;                 % work around style
      setting('shell.ohdl',ohdl);    % push object into figure
   end
   return

%==========================================================================

function obj = newgfo(obj,fig)       % new style

      % we begin with some tricky preprocessing. The call gfo(5) means
      % that we fetch the object from figure 5 instead of the current
      % figure. This syntax needs some tricky argument shifts.
      
   if (~isempty(obj))
      if isa(obj,'double')           % is it a figure handle?
         fig = obj;  obj = [];       % shift arguments
      end
   end

   %ohdl = setting('shell.ohdl'); 
   settings = get(fig,'userdata');
   ohdl = eval('settings.shell.ohdl','[]');
   
   
      % no we do the main task
   
   if isempty(obj)                   % get object
      if isempty(ohdl)
         error('gfo(): cannot access handle for object''s user data!');
      end
      userdata = get(ohdl,'userdata');
      obj = userdata{1};
      %settings = setting;           % get menu/figure settings
      settings.shell.ohdl = [];      % clear handle to figure's object
      settings.shell.figure = fig;
      obj = option(obj,settings);    % push settings into object's options
      ud = eval('get(gcbo,''userdata'')','[]');
      obj = arg(obj,[],ud);          % set object's argument
   else
      if isempty(ohdl)
         ohdl = uimenu(fig,'label','@@@','visible','off');
         %setting('shell.ohdl',ohdl); % store object handle in settings
         settings.shell.ohdl = ohdl;
         settings.shell.figure = fig;
         set(fig,'userdata',settings)
      end
      set(ohdl,'userdata',{obj});    % push object into figure
      obj = [];
   end
   return

% eof   