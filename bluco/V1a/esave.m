function oo = esave(o,varargin)       % Esave Plugin                 
%
% ESAVE   Esave plugin
%
%             esave(sho)              % plugin registration
%
%             oo = esave(o,func)      % call local esave function
%
%          See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,@WithCuo,...
                                  @WithSho,@WithBsk,@New,@Simu,...
                                  @Plot,@Stream,@Scatter,@EsaveSpec);
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
%  oo = Simu(o);                       % add Simu parameter menu items
%  oo = Plot(o);                       % add Plot menu items
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
   if isempty(oo)
      return
   end
   
   ooo = mhead(oo,'Esave');
   oooo = mitem(ooo,'ESAVE',{@NewEsave});
   return
   
   function oo = NewEsave(o)           % create ne simple object       
      oo = construct(o,class(o));      % construct empty class object
      oo.type = 'esave';               % esave type
      
      t = 0:1000;
      x = 10*randn * randn(size(t));
      y = 10*randn * randn(size(t));
      
      oo.par.title = sprintf('Esave Object (%s)',datestr(now));
      oo = data(oo,'t,x,y',t,x,y);
      
      paste(o,oo);                     % paste new object into shell
   end
end

%==========================================================================
% Select Menu Plugins
%==========================================================================

function oo = Simu(o)                  % Simulation Parameter Menu                    
%
% SIMU   Add simulation parameter menu items
%
   oo = mseek(o,{'#','Select'});       % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   setting(o,{'simu.tmax'},5);
   setting(o,{'simu.dt'},0.1);

   ooo = mitem(oo,'Simulation');
   oooo = mitem(ooo,'Max Time (tmax)',{},'simu.tmax');
          choice(oooo,[1 2 5 10 20 50 100],{});
   oooo = mitem(ooo,'Time Increment (dt)',{},'simu.dt');
          choice(oooo,[0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5],{});
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Plot(o)                  % Plot Menu Setup               
%
% PLOT   Add some Plot menu items
%
   oo = mseek(o,{'#','Plot'});         % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   types = {'shell','esave'};          % supported types
   
   ooo = mitem(oo,'Esave');
        enable(ooo,basket(o,types));
   oooo = mitem(ooo,'Stream',{@WithBsk,'Stream'});
   oooo = mitem(ooo,'Scatter',{@WithBsk,'Scatter'});
end
function o = Stream(o)                 % Stream Plot                   
   if ~o.is(type(o),{'esave'})
      o = [];  return
   end
   
   o = with(o,'style');                % unpack style options
   [t,x,y] = data(o,'t,x,y');          % fetch data

   oo = opt(o,'subplot',211,'xlabel','t', 'ylabel','x', 'title','X Data');
   plot(corazon(oo),t,x,'r');

   oo = opt(o,'subplot',212,'xlabel','t', 'ylabel','y', 'title','Y Data');
   plot(corazon(oo),t,y,'bc');

   heading(o);
end
function o = Scatter(o)                % Scatter Plot                  
   if ~o.is(type(o),{'esave'})
      o = [];  return
   end
   
   o = with(o,'style');                % unpack style options
   [x,y] = data(o,'x,y');              % fetch data

   oo = opt(o,'xlabel','x', 'ylabel','y', 'title','Scatter Plot');
   col = o.iif(dark(o),'wo','ko');
   plot(corazon(oo),x,y,col);
   
   set(gca,'visible','on');            % don't know, but is needed !!!
   heading(o);
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
   ooo = mitem(oo,'Degrading Spec',{@WithCuo,'EsaveSpec'});
end
function o = EsaveSpec(o)              % Study 1: 2nd Order System     
   refresh(o,o);                       % use THIS function for refresh
   
   T = [-30   40   50   60];
   I = [0.9  0.9  0.8  0.6];
   
   hdl = plot(o,T,I,'k2');
   xlabel('Ambient Temperature (°C)');
   ylabel('Output RMS Current (A)');
end
