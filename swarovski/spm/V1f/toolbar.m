function oo = toolbar(o,varargin)      % Toolbar Plugin              
%
% TOOLBAR  Toolbar plugin: Add toolbar and buttons
%
%              toolbar(sho)          % plugin registration
%
%              oo = toolbar(o,func)  % call local toolbar function
%
%           See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho);
   oo = gamma(oo);
end              

%==========================================================================
% Plugin Setup & Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   tag = class(o);
   plugin(o,[tag,'/menu/End'],{mfilename,'Menu'});
   plugin(o,[tag,'/current/Select'],{mfilename,'Menu'});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here

   mode = dark(o);
   dark(o,0);
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   
   mode = dark(o);                     % save dark mode
   dark(o,0);                          % disable dark mode shell setting
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   
      % oo = current(o) directly inherits options from shell object,
      % this we have to set dark mode option also for oo!
      
   oo = dark(oo,0);                    % disable dark mode
   
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode
end

%==========================================================================
% Plugin Definitions
%==========================================================================

function o = Menu(o)                   % Setup General Plugin Menus    
%
% MENU   Setup general plugin menus. General Plugins can be used to plug-
%        in menus at any menu location. All it needs to be done is to
%        locate a menu item by path and to insert a new menu item at this
%        location.
%
   oo = Toolbar(o);                    % add toolbar items
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Toolbar(o)               % Toolbar Setup              
%
% TOOLBAR   Add toolbar and some tool items
%
   oo = titem(o);                                  % create toolbar
   ooo = titem(oo,'guideicon.gif',{@Rebuild},[]);
   ooo = titem(oo,'greenarrowicon.gif',{@Refresh},[]);
   ooo = titem(oo,'unknownicon.gif',{@Stop},[]);
   
   function o = Rebuild(o)
      rebuild(o);
   end   
   function o = Refresh(o)
      refresh(o);
   end
   function o = Stop(o)
      stop(o,'Callback');
   end
end


function oo = titem(o,icon,cblist,userdata)
%
% TITEM   Create toolbar or toolbar item
%
%            oo = titem(o)             % create toolbar
%
%            rebuild = 'guideicon.gif';
%            refresh = 'greenarrowicon.gif'
%            stop = 'tool_hand.png'
%
%            ooo = titem(oo,rebuild,{@Rebuild},[])  % add Rebuild button
%            ooo = titem(oo,refresh,{@Refresh},[])  % add Refresh button
%            ooo = titem(oo,stop,{@Stop},[])        % add Stop button
%
%         Copyright(c): Bluenetics 2021
%
%         See also: CORAZON, MITEM
%
   if (nargin == 1)
      oo = Toolbar(o);
      return
   else
      oo = ToolButton(o,nargin)
   end
   
   function oo = ToolButton(o,nin)
      tb = work(o,'titem');
      pt = uipushtool(tb);
      pt.CData = Icon(o,icon);

         % set callback

      if (nin >= 3)
         callback = call(o,class(o),cblist); % construct callback
         set(pt,'ClickedCallback',callback);
      end

         % set user data

      if (nin >= 4)
         set(pt,'userdata',userdata);
      end

         % set out arg

      oo = work(o,'titem',pt);
   end
   function oo = Toolbar(o)
      tb = uitoolbar(figure(o));
      oo = work(o,'titem',tb);
   end
   function icn = Icon(o,icon)
      [img,map] = imread(fullfile(matlabroot,...
            'toolbox','matlab','icons',icon));
      icn = ind2rgb(img,map);
   end
end