function menu(obj,func)
% 
% MENU   Open new figure and setup menu for a ROBO object
%      
%           obj = robo;                    % create ROBO object
%           menu(obj)                      % open figure, setup menu
%
%        Internally the menu method is also used to dispatch callback
%        functions:
%
%           menu(obj,'open')      % call 'open' callback
%
%        See also: ROBO SHELL CHECK CHOICE MOUNT
%
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj);                          % open figure & setup menu items 
   elseif ~propagate(obj,func,which(func)) 
      eval([func,'(obj);']);               % invoke callback      
   end
   return
      
%==========================================================================
% User Defined Menu Setup
%==========================================================================

function inifig(obj)
%
% INIFIG    Initialize figure to comply with CHAMEO menu support
%
   parent = obj.shell;           % get parent class object
   if isempty(arg(parent))
      parent = arg(parent,obj);  % pass derived object as arg!
   end
   menu(parent,'setup');         % call menu setup of parent class object 
   gcfo(obj);                    % don't forget to push object into figure
   set(gcf,'name',info(obj));    % display objects title in title bar
   return

%==========================================================================      
   
function setup(obj)
%
% SETUP  Setup all standard menus
%
   inifig(obj);                        % initialize figure & set defaults
   
      % Now create menus as being advised by menu list
      
   menulist = get(obj,'menu');
   
   if ~property(obj,'generic')
      for (i=1:length(menulist))
         key = menulist{i};
         key = iif(iscell(key),'*',key);
         switch key
            case 'footprint'
               footprint(obj,'setup','<main>');  % setup FOOTPRINT menu
         end
      end
   end
   
   if strcmp(get(obj,'class'),'robo') % refresh only on top level
      drawnow;
      refresh(obj) ;                  % by default display object's info
   end

   return                             % otherweise invoke callback by clone

% eof