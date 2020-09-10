function demo(obj,func)
% 
% DEMO   Harmonic Oscillator Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(harmonic)           % open menu and add demo menus
%             demo(harmonic,'setup')   % add demo menus to existing menu
%             demo(harmonic,func)      % handle callbacks
%             demo(harmonic,'')        % empty action - existency check
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        See also   HARMONIC, QUANTANA, SHELL, MENU, GFO
%
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj);                          % open figure & setup menu items 
   elseif ~propagate(obj,func,which(func)) 
      fig = busy;
      eval([func,'(obj);']);               % invoke callback
      ready(fig);
   end
   return
      

%==========================================================================
% User Defined Menu Setup
%==========================================================================

function obj = addinfo(obj)              % only called for stand-alone menu
%
% ADDINFO   Add object info before creating menu
%
   title = 'Harmonic Oscillator Shell';
   comment = {'Simulation and Visualization of Harmonic Oscillator Properties'
             };

   obj = set(obj,'title',title,'comment',comment);
   return

%==========================================================================

function setup(obj)  % hook in user defined menu items
%
% SETUP    Create a TCON object, add object's info and setup menu
%
   obj = addinfo(obj);
   menu(obj);                          % open menu

   MenuSetupView(obj);
   MenuSetupHarmonic(obj);

   cls(obj);  dark(obj);
   refresh(obj);
   return
   
%==========================================================================
% View Menu
%==========================================================================

function MenuSetupView(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%
   default('light.rvisu',0);
   
   CbBackground(obj);   % toggle to dark background

   men = mount(obj,'<main>',LB,'View');
         uimenu(men,LB,'Standard Menues',CB,call('CbStdMenu'));
         uimenu(men,LB,'Grid on/off',CB,'grid;');
         uimenu(men,LB,'Background dark/bright',CB,call('CbBackground'));
         uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');

   sub = uimenu(men,LB,'Display Light',UD,'light.rvisu');
         uimenu(sub,LB,'Off',CB,CHCR,UD,0);
         uimenu(sub,LB,'On',CB,CHCR,UD,0.5);
         choice(sub,setting('light.rvisu'));
   return         


function CbBackground(obj)
%
   drk = setting('dark');
   if (isempty(drk))
      drk = 0;
   end
   setting('dark',~drk);
   refresh(obj);
   return

%==========================================================================
   
function CbStdMenu(obj)  % switch standard menus on/off
%
   itm = gcbo;   % get menu item handle
   if strcmp(get(itm,'checked'),'on')
      set(gcf,'menubar','none');
      set(itm,'checked','off');
   else
      set(gcf,'menubar','figure');
      set(itm,'checked','on');
   end
   return
   
%==========================================================================
% Harmonic Oscillator Menu
%==========================================================================

function MenuSetupHarmonic(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('harmonic.speed',1);             % speed of animation
   default('harmonic.N',10);                % coherence number
   default('harmonic.coloring','uni');      % coloring of animation

   men = mount(obj,'<main>',LB,'Harmonic');
         uimenu(men,LB,'Energy Levels',CB,call('CbBasics'),UD,'CbEnergyLevels');
         uimenu(men,LB,'Eigen Functions',CB,call('CbBasics'),UD,'CbEigenFuncs');
         uimenu(men,LB,'Eigen Oscillations',CB,call('CbBasics'),UD,'CbEigenOscis');
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
         
   return         
   
function CbBasics(obj)   
%
   CbExecute(obj,'basics');
   return
   
%==========================================================================
% 4) Auxillary Functions
%==========================================================================

function [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];  VI = 'visible';
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')]; 
   MF = mfilename; 
   return

%==========================================================================
   
function CbExecute(obj,handler)        % execute callback
%
% Cbexecute    Execute an external handler function which dispatches
%              to the particular handler given by user data
%
   cbsetup(obj);                       % setup current function for refresh
   %keypress(obj,'CbIgnore');           % ignore key press events
   keypress(obj,'CbStop');
  
   if (nargin <2)
      handler = setting('shell.execute');
      if (isempty(handler))
         return;                      % cannot continue
      end
   end
   setting('shell.execute',handler);  % for next time keypress
   
   busy;
   cmd = [handler,'(obj);'];
   eval(cmd);
   ready;

   keypress(obj,'CbRefresh')
   return

%==========================================================================
% Key Press Handlers
%==========================================================================
   
function CbRefresh(obj)
%
% CBREFRESH   Ignore keypress event
%
   %fprintf('CbRefresh: key pressed!\n');
   refresh(obj)
   return

function CbIgnore(obj)
%
% CBIGNORE   Ignore keypress event
%
   %fprintf('CbIgnore: key pressed!\n');
   return

function CbStop(obj)
%
% CBSTOP   Set stop flag on keypress event
%
   %fprintf('CbStop: key pressed!\n');
   terminate(smart);
   keypress(obj,'CbRefresh');    % continue next keypress with refresh
   return
   
   
%==========================================================================
   
% eof