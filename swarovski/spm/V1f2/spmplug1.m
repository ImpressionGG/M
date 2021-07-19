function oo = spmplug1(o,varargin)    % Spmplug1 Plugin              
%
% SPMPLUG1  Spmplug1 plugin: Add batch print menu items
%
%              spmplug1(sho)          % plugin registration
%
%              oo = spmplug1(o,func)  % call local spmplug1 function
%
%           See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho,@WithBsk,...
                       @Batch1,@Batch2);
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
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
  end
  dark(o);                            % do dark mode actions
end
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
 
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
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
   oo = Batch(o);                      % add Batch menu items
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Batch(o)                 % Batch Menu Setup              
%
% BATCH   Add some Batch menu items
%
   oo = mseek(o,{'#','Batch'});        % find Batch rolldown menu
   if isempty(oo)
      return
   end
   
   types = {'shell','spmplug1'};       % supported types

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Special');
         enable(ooo,type(o,{'shell','pkg','cut'}));
   oooo = mitem(ooo,'Special Batch 1',{@WithCuo,'Batch1'});
   oooo = mitem(ooo,'Special Batch 2',{@WithCuo,'Batch2'});
end
function oo = Batch1(o)                % Process Batch 1               
   switch o.type
      case {'spm'}
         oo = SpmBatch(o);
      case {'pkg'}
         oo = PkgBatch(o);
      otherwise
         oo = ShellBatch(o);
   end
   
   function o = SpmBatch(o)            % Run Batch for SPM Object   
      message(o,'Run Batch1 for SPM Object');
   end
   function o = PkgBatch(o)            % Run Batch for Package Object   
      message(o,'Run Batch1 for Package Object');
   end
   function o = ShellBatch(o)          % Run Batch for Shell Object   
      message(o,'Run Batch1 for Shell Object');
   end
end
function oo = Batch2(o)                % Process Batch 2               
   switch o.type
      case {'spm'}
         oo = SpmBatch(o);
      case {'pkg'}
         oo = PkgBatch(o);
      otherwise
         oo = ShellBatch(o);
   end
   
   function o = SpmBatch(o)            % Run Batch for SPM Object   
      message(o,'Run Batch2 for SPM Object');
   end
   function o = PkgBatch(o)            % Run Batch for Package Object   
      message(o,'Run Batch2 for Package Object');
   end
   function o = ShellBatch(o)          % Run Batch for Shell Object   
      message(o,'Run Batch2 for Shell Object');
   end
end
