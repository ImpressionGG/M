function oo = simple(o,varargin)       % Simple Plugin                 
%
% SIMPLE   Simple plugin
%
%             simple(sho)              % plugin registration
%
%             oo = simple(o,func)      % call local simple function
%
%          Read Driver for Simple & Plain Objects
%
%             oo = simple(o,'New');
%             oo = simple(o,'Simu');
%             oo = simple(o,'Plot');
%
%          See also: CORAZON, PLUGIN, SAMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Plug,@Callback,...
                       @Basket,@New,@Simu,@Plot,@Stream,@Scatter,@Study1);
   oo = gamma(oo);
end              

%==========================================================================
% Plugin Setup & Registration, General Callback Invocation
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   tag = class(o);
   plugin(o,[tag,'/menu/End'],{mfilename,'Plug'});
   plugin(o,[tag,'/current/Select'],{mfilename,'Plug'});
end
function oo = Callback(o)              % General Callback              
%
% CALLBACK   A general callback with refresh function redefinition, 
%            screen clearing, current object pulling and forwarding
%            to the executing local function
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
   
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
   
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
end

%==========================================================================
% Plugin Definitions
%==========================================================================

function o = Plug(o)                   % General Plugin Definitions    
%
% PLUG   General Plugins can be used to plug-in menus at any menu locat-
%        ion. All it needs to be done is to locate a menu item by path and
%        to insert a new menu item at this location.
%
   oo = New(o);                        % add New menu items
   oo = Simu(o);                       % add Simu parameter menu items
   oo = Grid(o);                       % add Grid menu items
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
   if isempty(oo)
      return
   end
   
   ooo = mhead(oo,'Simple');
   oooo = mitem(ooo,'SMP',{@NewSmp});
   return
   
   function oo = NewSmp(o)             % create ne simple object
      oo = construct(o,class(o));      % construct empty class object
      oo.type = 'smp';                 % simple type
      
      t = 0:1000;
      x = 10*randn * randn(size(t));
      y = 10*randn * randn(size(t));
      
      oo.par.title = sprintf('Simple Object (%s)',datestr(now));
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
function oo = Grid(o)                  % Grid Menu                    
%
% GRID   Add grid menu items
%
   oo = mseek(o,{'#','Select'});       % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   setting(o,{'plot.grid'},0);

   ooo = mitem(oo,'Grid',{},'plot.grid');
         choice(ooo,{{'Off',0},{'On',1}},{});
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
   
   types = {'shell','smp'};            % supported types
   
   ooo = mitem(oo,'Simple');
        enable(ooo,basket(o,types));
   oooo = mitem(ooo,'Stream',{@Basket,'Stream'});
   oooo = mitem(ooo,'Scatter',{@Basket,'Scatter'});
end
function o = Stream(o)                 % Stream Plot                   
   if ~o.is(type(o),{'smp'})
      o = [];  return
   end
   
   o = with(o,'style');                % unpack style options
   [t,x,y] = data(o,'t,x,y');          % fetch data

   oo = opt(o,'subplot',211,'xlabel','t', 'ylabel','x', 'title','X Data');
   plot(corazon(oo),t,x,'r');
   grid on;

   oo = opt(o,'subplot',212,'xlabel','t', 'ylabel','y', 'title','Y Data');
   plot(corazon(oo),t,y,'b');
   grid on  
end
function o = Scatter(o)                % Scatter Plot                  
   if ~o.is(type(o),{'smp'})
      o = [];  return
   end
   
   o = with(o,'style');                % unpack style options
   [x,y] = data(o,'x,y');              % fetch data

   oo = opt(o,'xlabel','x', 'ylabel','y', 'title','Scatter Plot');
   plot(corazon(oo),x,y,'ko');
   
   %set(gca,'xlim',[-2 2],'ylim',[-2 2]);
   set(gca,'visible','on');            % don't know, but is needed !!!
   grid on;
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
   ooo = mitem(oo,'2nd Order System',{@Study1});
end
function o = Study1(o)                 % Study 1: 2nd Order System     
   refresh(o,o);                       % use THIS function for refresh
   T = opt(o,{'simu.dt',0.1});         % sample time
   
   oo = corasim(o);                    % keep options
   oo = system(oo, [-1 0; 0 -2], [1;1],  [1 -2]);
   oo = c2d(oo,T);                     % discretize with T = 0.1
   
   [A,B,C,D,T] = get(oo,'system','A,B,C,D,T'); 
   x = [0;0]; 
   
   oo = log(oo,'t,x,u,y');
   for (t=0:T:opt(o,{'simu.tmax',5}))
      u = 1;
      y = C*x + D*u;
      oo = log(oo,t,x,u,y);
      x = A*x + B*u;
   end
   
   oo.par.title = 'Second Order System';
   plot(oo);
   clip(o,oo);
end

