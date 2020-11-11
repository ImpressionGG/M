function oo = isig(o,varargin)       % Isig Plugin                 
%
% ISIG   Isig plugin: study integer arithmetic for signal processing
%        on a micro controller
%
%             isig(sho)              % plugin registration
%
%             oo = isig(o,func)      % call local isig function
%
%          See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,@WithCuo,...
                                  @WithSho,@WithBsk,@New,@Simu,...
                                  @Plot,@Stream,@Scatter,@Study1);
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
   oo = New(o);                        % add New menu items
   oo = Select(o);                     % add Select menu items
   oo = Plot(o);                       % add Plot menu items
   oo = Study(o);                      % add Study menu items
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function oo = New(o)                   % New Menu                      
%
% NEW   Add New menu to create simple typed objects
%
   oo = mseek(o,{'#','File','New'});   % find File/New rolldown menu
   visible(oo,0);
end

%==========================================================================
% Select Menu Plugins
%==========================================================================

function oo = Select(o)                % Select Parameter Menu                    
%
% SELECT   Add parameter selection menu items
%
   oo = mseek(o,{'#','Select'});       % find Select rolldown menu
   
   if isempty(oo)
      return
   end
   
   setting(o,{'select.bits'},12);

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bits',{},'select.bits');
         choice(ooo,[4:20],{});
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Plot(o)                  % Plot Menu Setup               
%
% PLOT   Add some Plot menu items
%
   oo = mseek(o,{'#','Plot'});         % find Select rolldown menu
   visible(oo,0);
end

%==========================================================================
% Study Menu Plugins
%==========================================================================

function oo = Study(o)                 % Study Menu                    
%
% STUDY   Add some Study menu items
%
   oo = mseek(o,{'#','Study'});   % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Integer Filter',{@WithCuo,'Study1'});
end
function o = Study1(o)                 % Study 1: 2nd Order System     
   Ts = 0.02;
   t = 0:Ts:5;
   u = 0*t + 2000;                     % 2000 milli units
   y = 0;
   
      % define base and filter coefficients
      
   bits = opt(o,'select.bits');
   base = 2^bits;
   
   lambda = 0.95;
   a = round(lambda*base);  
   b = round((1-lambda)*base);
   b = base - a;
   
   for (k=1:length(t)-1)
      y(k+1) = round((a*y(k) + b*u(k) + base/2) / base); 
   end
   
   PlotUY(o,111);
   
   disp(y(end-10:end)');
   
   function PlotUY(o,sub)
      subplot(o,sub);
      plot(o,t,u,'bc');
      hold on;
      plot(o,t,y,'ro|');
      subplot(o);                      % subplot complete
   end
end
