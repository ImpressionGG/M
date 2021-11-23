function oo = legacy(o,varargin)       % Plugin for Debug Menu Extension         
%
% LEGACY  Debug plugin for Demo menu extension, serving as an excellent
%         tiny plugin template for quick and dirty plugins
%
%            legacy(sho)               % plugin registration
%
%         See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
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
% Plugin Menu Items
%==========================================================================

function o = Menu(o)                   % Setup General Plugin Menus    
%
% MENU   Setup general plugin menus. General Plugins can be used to plug-
%        in menus at any menu location. All it needs to be done is to
%        locate a menu item by path and to insert a new menu item at this
%        location.
%      
   o = mseek(o,{'#' 'Info' 'Debug'});  % seek plug point
   
   oo = mitem(o,'-');                  % add a menu separator
   oo = Legacy(o);                     % add a legacy selection menu item
end

%==========================================================================
% Legacy
%==========================================================================

function oo = Legacy(o)                % 
%
% LEGACY   Add a choice item to activate 'debug.legacy' setting. THe idea
%          is to provide the possibility to select between standard code
%          and legacy code as follows:
%
%             if opt(o,{'debug.legacy',0})
%                % execute legacy code
%             else
%                % execute standard code
%             end
%
%          The legacy code is only executed if setting 'debug.legacy' is 
%          defined and true.
%
   setting(o,{'debug.legacy'},0);      % execute new functions by default

   oo = mhead(o,'Legacy',{},'debug.legacy');
   choice(oo,{{'Off' 0},{'On',1}});
end
