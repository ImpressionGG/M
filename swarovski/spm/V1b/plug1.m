function oo = plug1(o,varargin)        % SPM Plugin                 
%
% PLUG1    SPM plugin
%
%             plug1(sho)               % plugin registration
%
%             oo = plug1(o,func)      % call local simple function
%
%          Read Driver for Simple & Plain Objects
%
%             oo = plug1(o,'New');
%             oo = plug1(o,'Simu');
%             oo = plug1(o,'Plot');
%
%          See also: SPM, PLUGIN, SAMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Plug,@Basket,...
                       @Callback,@New,@Simu,@Plot,@Stream,@Step,@Ramp,...
                       @F3Ramp);
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
   oo = Simu(o);                       % add Simu parameter menu items
   oo = Grid(o);                       % add Grid menu items
   oo = Plot(o);                       % add Plot menu items
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
   
   setting(o,{'simu.tmax'},0.01);
   setting(o,{'simu.Fmax'},100);
   setting(o,{'simu.dt'},0.00005);

   ooo = mitem(oo,'Simulation');
   oooo = mitem(ooo,'Max Time (tmax)',{},'simu.tmax');
          choice(oooo,[0.001,0.002,0.005,0.01,0.02,0.05,0.1],{});
   oooo = mitem(ooo,'Time Increment (dt)',{},'simu.dt');
          choice(oooo,[0.00001 0.00002 0.00005 0.0001 0.0002 0.0005],{});
          
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Max Force [N]',{},'simu.Fmax');
          choice(oooo,[1 2 5 10 20 50 100 200 500 1000],{});
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
% SIMPLE   Add New menu to create simple typed objects
%
   oo = mseek(o,{'#','Plot'});         % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   types = {'shell','spm'};            % supported types
   
   oo = mitem(oo,'Response');
        enable(oo,basket(o,types));
        
   ooo = mitem(oo,'Step Response');
   oooo = mitem(ooo,'F1 Excitation',{@Callback,'Step'},1);
   oooo = mitem(ooo,'F2 Excitation',{@Callback,'Step'},2);
   oooo = mitem(ooo,'F3 Excitation',{@Callback,'Step'},3);

   ooo = mitem(oo,'Ramp Response');
   oooo = mitem(ooo,'F1 Excitation',{@Callback,'Ramp'},1);
   oooo = mitem(ooo,'F2 Excitation',{@Callback,'Ramp'},2);
   oooo = mitem(ooo,'F3 Excitation',{@Callback,'Ramp'},3);
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F3-Ramp',{@Callback,'F3Ramp'});
   
end

function o = Step(o)                   % Step Response                 
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   index = arg(o,1);
   t = Time(o);
   u = StepInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   heading(o,sprintf('Step Response: F%g->y (%s)',index,Title(o)));
end
function o = Ramp(o)                   % Ramp Response                 
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   index = arg(o,1);
   t = Time(o);
   u = RampInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   
   heading(o,sprintf('Ramp Response: F%g->y (%s)',index,Title(o)));
end

function o = F3Ramp(o)                 % F3-Ramp Response              
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,3,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Ramp Response: F3->y (%s)',Title(o)));
end

%==========================================================================
% Plotting
%==========================================================================

function o = PlotY(o)                  % Plot Output Signals           
   o = corazon(o);                     % use CORAZON plot method
   ms = 0.001;                         % factor ms/s
   um = 1e-6;
   [t,u,y] = data(o,'t,u,y');
   
   Plot11(o);                          % Elongation 1
   Plot12(o);                          % Elongation 2
   Plot21(o);                          % Elongation 3
   Plot22(o);                          % Input
   
   function Plot11(o)                  % Elongation 1                                              
      subplot(221);
      plot(o,t/ms,y(1,:)/um,'g');
      title('Output (Elongation)');
      xlabel('t [ms]');  ylabel('y1 [um]');
      grid(o);
   end
   function Plot12(o)                  % Elongation 2                                              
      subplot(222);
      plot(o,t/ms,y(2,:)/um,'c');
      title('Output (Elongation)');
      xlabel('t [ms]');  ylabel('y2 [um]');
      grid(o);
   end
   function Plot21(o)                  % Elongation 3                                              
      subplot(223);
      plot(o,t/ms,y(3,:)/um,'r');
      title('Output (Elongation)');
      xlabel('t [ms]');  ylabel('y3 [um]');
      grid(o);
   end
   function Plot22(o)                                                  
      subplot(224);
      plot(o,t/ms,u,'b');
      title('Input (Force)');
      xlabel('t [ms]');  ylabel('F [N]');
      grid(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function title = Title(o)              % Get Object Title              
   title = get(o,{'title',[class(o),' object']});
end
function t = Time(o)                   % Get Time Vector               
   T = opt(o,{'simu.dt',0.00005});
   tmax = opt(o,{'simu.tmax',0.01});
   t = 0:T:tmax;
end
function u = StepInput(o,t,index)  % Get Step Input Vector             
%
% STEPINPUT   Get step input vector (and optional time vector)
%
%                u = StepInput(o,t,index)
%
   [~,m] = size(o);                   % number of inputs
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*ones(size(t));
end
function u = RampInput(o,t,index,Fmax)  % Get Ramp Input Vector        
%
% RAMPINPUT   Get ramp input vector (and optional time vector)
%
%                u = RampInput(o,t,index)
%                u = RampInput(o,t,index,Fmax)
%
   if (nargin < 4)
      Fmax = max(t);
   end
   
   [~,m] = size(o);                   % number of inputs
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*t * Fmax/max(t);
end
