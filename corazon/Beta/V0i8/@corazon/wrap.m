function oo = wrap(o,varargin)         % Wrap Support for CUTE Objects 
%
% WRAP   Wrap a function in order to build entry points for event
%        handling.
%
%        Wrappers for local functions of SHELL method
%
%           oo = wrap(o,'Export')      % wrap Export menu
%           oo = wrap(o,'Signal')      % wrap Signal menu
%           oo = wrap(o,'Plot')        % wrap Analysis menu
%           oo = wrap(o,'Analysis')    % wrap Analysis menu
%
%        Wrappers for local functions of MENU method
%
%           oo = wrap(o,'Config')      % wrap Config menu
%           oo = wrap(o,'Objects')     % wrap Objects menu
%           oo = wrap(o,'Basket')      % wrap Basket menu
%           oo = wrap(o,'Bias')        % wrap Bias menu
%           oo = wrap(o,'Style')       % wrap Style menu
%           oo = wrap(o,'Scale')       % wrap Scale menu
%
%        Wrapper functions implement an additional layer which act as 
%        event registration layers and event handler enntry points.
%        Wrapper functions call usually the shell method for menu build
%        or menu rebuild.
%
%        Overview: Wrapper functions, driven by which events
%
%           wrap(o,'Export')   <=    event 'Select'
%           wrap(o,'Signal')   <=    event 'Select', 'Signal'
%           wrap(o,'Plot')     <=    event 'Select', 'Plot'
%           wrap(o,'Analysis') <=    event 'Select', 'Plot'
%           wrap(o,'Config')   <=    event 'Select', 'Config'
%           wrap(o,'Objects')  <=    event 'Select'
%           wrap(o,'Basket')   <=    event 'Select'
%           wrap(o,'Facette')  <=    event 'Select'
%           wrap(o,'Bias')     <=    event 'Bias'
%           wrap(o,'Style')    <=    event 'Style'
%           wrap(o,'Scale')    <=    event 'Scale'
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, SHELL, MENU, EVENT
%
   [gamma,oo] = manage(o,varargin,@Error,@Export,@Signal,@Plot,...
                       @Analysis,@Config,@Objects,@Facette,@Basket,...
                       @Overlays,@Bias,@Style,@Scale);
   oo = gamma(oo);
end

function oo = Error(o)                 % Error Function Handler        
   error('mode argument (varargin{1} or arg(o,1)) is missing!');
end

%==========================================================================
% Local Wrapper Functions for Shell Functions
%==========================================================================

function oo = Export(o)                % Export Menu Wrapper           
%
% EXPORT   This function is a wrapper function for local function
%          Export and is used as an even handler for the 'select' 
%          event. It allows overloading of an Export function which
%          is called each time an object selection changes.
%
%          The overloaded Export function may thus enable/disable 
%          certain Export menu items.
%
   event(o,'Select',o);                % call this wrapper @ 'select' event
   oo = shell(o,'Export');             % delegate to Export menu builder
end
function oo = Signal(o)                % Signal Menu Wrapper           
%
% SIGNAL   This wrapper function allows dynamical rebuilding of the
%          View>Signal menu. Each time the 'select' event is invoked the 
%          Signal wrapper is invoked which will delegate its job to a
%          shell's Signal menu.
%
   event(o,'Select',o);                % call this wrapper @ 'select' event
   event(o,'Signal',o);                % call this wrapper @ 'select' event
   oo = shell(o,'Signal');             % delegate to Signal menu builder
   change(o,'Signal');                 % check menu items properly 
end
function oo = Plot(o)                  % Plot Menu Wrapper             
%
% PLOT   This wrapper function allows dynamical rebuilding of the
%        Plot menu. Since Plot is a dynamic menu, the actual plot menu
%        has to be built up depending on the class of the current object
%
   event(o,'Plot',o);                  % call this wrapper @ 'Plot' event
   event(o,'Select',o);                % call this wrapper @ 'Select' event
   o = cast(o,current(o));             % cast to current object's class 
   oo = shell(o,'Plot');               % delegate to Plot menu builder
end
function oo = Analysis(o)              % Analysis Menu Wrapper         
%
% ANALYSIS   This wrapper function allows dynamical rebuilding of the
%            Analysis menu. Each time the 'select' event is invoked the 
%            Analysis wrapper is invoked which will delegate its job to a
%            shell's Analysis menu.
%
   event(o,'Plot',o);                  % call this wrapper @ 'Plot' event
   event(o,'Select',o);                % call this wrapper @ 'select' event
   o = cast(o,current(o));             % cast to current object's class 
   oo = shell(o,'Analysis');           % delegate to Analysis menu builder
end

%==========================================================================
% Local Wrapper Functions for Menu Functions
%==========================================================================

function oo = Config(o)                % Config Menu Wrapper           
   event(o,'Select',o);                % call Config on 'Select' event
   event(o,'Config',o);                % call Config on 'Config' event
   oo = menu(o,'Config');              % continue with MENU method
end
function oo = Objects(o)               % Objects Menu Wrapper          
   event(o,'Select',o);                % call Objects on 'Select' event
   oo = menu(o,'Objects');             % continue with MENU method
end
function oo = Facette(o)               % Facette Menu Wrapper          
   event(o,'Select',o);                % call Objects on 'Select' event
   oo = menu(o,'Facette');             % continue with MENU method
end
function oo = Basket(o)                % Basket Menu Wrapper           
   event(o,'Select',o);                % call View on 'Select' event
   oo = menu(o,'Basket');              % continue with MENU method
end
function oo = Bias(o)                  % Bias Menu Wrapper             
   event(o,'Bias',o);                  % call Bias on 'Bias' event
   oo = menu(o,'Bias');                % continue with MENU method
end
function oo = Style(o)                 % Style Menu Wrapper            
   event(o,'Style',o);                 % call Style on 'Style' event
   oo = menu(o,'Style');               % continue with MENU method
end
function oo = Scale(o)                 % Scale Menu Wrapper            
   event(o,'Scale',o);                 % call Scale on 'Scale' event
   oo = menu(o,'Scale');               % continue with MENU method
end
