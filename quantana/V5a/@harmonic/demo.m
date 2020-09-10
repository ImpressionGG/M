function oo = demo(o,varargin)         % Harmonic Demo Shell           
% 
% DEMO   Harmonic Oscillator Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(o)                  % setup new demo shell
%             demo(harmonic,'setup')   % add demo menus to existing menu
%             demo(harmonic,func)      % handle callbacks
%             demo(harmonic,'')        % empty action - existency check
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        See also   HARMONIC, QUANTANA, SHELL, MENU, GFO
%
   [gamma,oo] = manage(o,varargin,@Shell);
   oo = gamma(oo);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Demo Shell Setup              
   o = Init(o);                        % initialize object

   o = menu(o,'Begin');                % begin menu setup
   oo = menu(o,'File');                % add File menu
   oo = View(o);                       % add View menu
   oo = Harmonic(o);                   % add Harmonic menu
   oo = menu(o,'Info');                % add Info menu
   o = menu(o,'End');                  % end menu setup

   %cls(obj);  dark(obj);
   %refresh(obj);
end
function o = Init(o)                   % Object Initializing           
   o = set(o,{'title'},'Harmonic Oscillator Shell');
   o = set(o,{'comment'},{'Simulation and Visualization of Harmonic Oscillator Properties'});

   o = dynamic(o,false);               % setup as a static shell
   o = launch(o,mfilename);            % setup launch function
   o = refresh(o,{@menu,'About'});     % provide refresh callback function
end
   
%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
%
   setting(o,{'light.rvisu'},0);
   CbBackground(o);                    % toggle to dark background

   oo = mhead(o,'View');
   ooo = mitem(oo,'Standard Menues',{@StandardMenues});
   ooo = Toolbar(oo);                  % add toolbar menu item
   ooo = Grid(oo);                     % add grid menu item
   ooo = mitem(oo,'Background dark/bright',{@CbBackground});
   ooo = mitem(oo,'Standard Window Size',{},{@StandardWindowSize});

   ooo = mitem(oo,'Display Light',{},'light.rvisu');
   choice(ooo,{{'Off',0},{'On',0.5}},{});
   return
   
   function o = StandardMenues(o)      % Standard Menus On/Off         
   %
      itm = gcbo;                      % get menu item handle
      toolbar = get(gcf,'toolbar');    % get current toolbar status
      if strcmp(get(itm,'checked'),'on')
         set(gcf,'menubar','none');
         set(itm,'checked','off');
      else
         set(gcf,'menubar','figure');
         set(itm,'checked','on');
      end
      set(gcf,'toolbar',toolbar);      % restore toolbar status
   end
   function o = CbBackground(o)        % Set Window Background         
   %
      drk = setting(o,'dark');
      if (isempty(drk))
         drk = 0;
      end
      setting(o,'dark',~drk);
      refresh(o);
   end
   function o = StandardWindowSize(o)  % Set Standard Window Size      
      set(gcf,'position',[50,100,1100,600]);
   end
end
function oo = Toolbar(o)               % Toolbar Menu                  
%
   setting(o,{'view.toolbar'},'none');

   oo = mitem(o,'Toolbar','','view.toolbar'); 
   choice(oo,{{'Off','none'},{'On','figure'}},{@ToolbarCb});
   return

   function o = ToolbarCb(o)           % Toolbar Callback              
   %
   % ToolbarCb has two working modes: a basic working mode and an advanced
   % mode. In the basic working mode we make just change the 'menubar' 
   % property of the figure. In advanced mode we lookup the callback
   % function which is used by the MATLAB figure menu
   %
      mode = opt(o,'view.toolbar');
      oo = mseek(o,{'#' 'Figure' 'View' 'Figure Toolbar'});

      if isempty(oo)                   % basic working mode
         set(gcf,'menubar',mode);
      else                             % advanced working mode
         hdl = mitem(oo,inf);          % get menu item handle
         callback = get(hdl,'callback');
         if ischar(callback)
            eval(callback);
         else
            set(gcf,'menubar',mode);   % backup: basic working mode
         end
      end
   end
end
function o = Grid(o)                   % Grid Menu                     
%
   setting(o,{'view.grid'},0);         % no grid by default

   oo = mitem(o,'Grid',{},'view.grid');
   choice(oo,{{'Off',0},{'On',1}},{});
end

%==========================================================================
% Harmonic Oscillator Menu
%==========================================================================

function oo = Harmonic(o)              % Harmonic Menu                 
%
   setting(o,{'harmonic.speed'},1);         % speed of animation
   setting(o,{'harmonic.N'},10);            % coherence number
   setting(o,{'harmonic.coloring'},'uni');  % coloring of animation

   oo = mhead(o,'Harmonic');
   ooo = mitem(oo,'Energy Levels',{@Basics,'EnergyLevels'});

   ooo = mitem(oo,'Eigen Functions',{@Basics,'EigenFuncs'});
   ooo = mitem(oo,'Eigen Oscillations',{@Basics,'EigenOscis'});
   return
         %uimenu(men,LB,'Coherent State',CB,call('CbBasics'),UD,'CbCoherent');
         uimenu(men,LB,'--------------------');
         uimenu(men,LB,'Superposition |0>+|1>',CB,call('CbBasics'),UD,'CbSuper1');
         uimenu(men,LB,'Superposition |0>+|1>+|2>',CB,call('CbBasics'),UD,'CbSuper2');
         uimenu(men,LB,'--------------------');
         uimenu(men,LB,'Coherent',CB,call('CbBasics'),UD,'CbCoherent');
   sub = uimenu(men,LB,'Coherence Number',UD,'harmonic.N');
         uimenu(sub,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(sub,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(sub,LB,'1',CB,CHCR,UD,1);
         uimenu(sub,LB,'3',CB,CHCR,UD,3);
         uimenu(sub,LB,'10',CB,CHCR,UD,10);
         uimenu(sub,LB,'25',CB,CHCR,UD,25);
         uimenu(sub,LB,'50',CB,CHCR,UD,50);
         uimenu(sub,LB,'75',CB,CHCR,UD,75);
         uimenu(sub,LB,'100',CB,CHCR,UD,100);
         choice(sub,setting('harmonic.N'));   

         uimenu(men,LB,'--------------------');

   sub = uimenu(men,LB,'Animation Speed',UD,'harmonic.speed');
         uimenu(sub,LB,'Slow',CB,CHCR,UD,1);
         uimenu(sub,LB,'Medium',CB,CHCR,UD,2);
         uimenu(sub,LB,'Fast',CB,CHCR,UD,3);
         choice(sub,setting('harmonic.speed'));   

   sub = uimenu(men,LB,'Coloring',UD,'harmonic.coloring');
         uimenu(sub,LB,'Unicolor',CB,CHCR,UD,'uni');
         uimenu(sub,LB,'Multicolor',CB,CHCR,UD,'multi');
         choice(sub,setting('harmonic.coloring'));
         
end
   
function oo = Basics(o)   
%
   o = arg(o,[{'basics'},arg(o,0)]);
   invoke(o);
end
