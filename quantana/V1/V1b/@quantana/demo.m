function demo(obj,func)
% 
% DEMO   Quantana Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(quantana)           % open menu and add demo menus
%             demo(quantana,'setup')   % add demo menus to existing menu
%             demo(quantana,func)      % handle callbacks
%             demo(quantana,'')        % empty action - existency check
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        See also   QUANTANA SHELL MENU GFO
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
   title = 'Quantana Shell';
   comment = {'Simulation and Visualization of quantum mechanical systems'
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
   MenuSetupBasics(obj);
   MenuSetupSchroedinger(obj);
   MenuSetupHarmonic(obj);
   MenuSetupScattering(obj);

   cls(obj);
   refresh(obj);
   return
   
%==========================================================================
% View Menu
%==========================================================================

function MenuSetupView(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%
   a = 5;
   
   default('dark',1);

   default('global.size',50);         % size of operators & states
   default('global.xmin',-a);        % minimum x coordinate
   default('global.xmax',+a);        % maximum x coordinate
   default('global.ymin',-a);        % minimum y coordinate
   default('global.ymax',+a);        % maximum y coordinate
   default('global.zmin',-a);        % minimum z coordinate
   default('global.zmax',+a);        % maximum z coordinate
   default('global.tmin', 0);        % minimum t coordinate
   default('global.tmax',+a);        % maximum t coordinate
   default('global.dt',0.1);         % time interval

   men = mount(obj,'<main>',LB,'View');
         uimenu(men,LB,'Standard Menues',CB,call('CbStdMenu'));
         uimenu(men,LB,'Grid on/off',CB,'grid;');
         uimenu(men,LB,'Background dark/bright',CB,call('CbBackground'));
         uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');
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
% Basicss Menu
%==========================================================================

function MenuSetupBasics(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   men = mount(obj,'<main>',LB,'Basics');
   sub = uimenu(men,LB,'Phase Colors');
         uimenu(sub,LB,'Phase Colors (Single)',CB,call('CbBasics'),UD,'CbPhaseColors');
         uimenu(sub,LB,'Phase Colors (Multi)',CB,call('CbBasics'),UD,'CbMultiColors');
   sub = uimenu(men,LB,'Color Maps');
         uimenu(sub,LB,'Fire Color Map',CB,call('CbBasics'),UD,'CbFireCmap');
         uimenu(sub,LB,'Phase Color Map',CB,call('CbBasics'),UD,'CbPhaseCmap');
         uimenu(sub,LB,'Complex Color Map',CB,call('CbBasics'),UD,'CbComplexCmap');
   return

function CbBasics(obj)   
%
   CbExecute(obj,'basics');
   return
   
%==========================================================================
% Schroedinger Menu
%==========================================================================

function MenuSetupSchroedinger(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   men = mount(obj,'<main>',LB,'Schroedinger');
         uimenu(men,LB,'Infinite Waves (1D)',CB,call('CbSchroed'),UD,'CbInfWaves1D');
         uimenu(men,LB,'Infinite Waves (1P)',CB,call('CbSchroed'),UD,'CbInfWaves1P');
   return

function CbSchroed(obj)   
%
   CbExecute(obj,'schroedinger');
   return
   
%==========================================================================
% Harmonic Oscillator Menu
%==========================================================================

function MenuSetupHarmonic(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('control.target','Tt');             % pre-load temperature

   men = mount(obj,'<main>',LB,'Harmonic');
         uimenu(men,LB,'Eigen Functions',CB,call('CbHarmonic'),UD,'CbEigenFuncs');
         uimenu(men,LB,'Eigen Oscillations',CB,call('CbHarmonic'),UD,'CbEigenOscis');
         uimenu(men,LB,'Coherent State',CB,call('CbHarmonic'),UD,'CbCoherent');
   return         

   
function CbHarmonic(obj)   
%
   CbExecute(obj,'harmosc');
   return
   
%==========================================================================
% Scattering Menu
%==========================================================================

function MenuSetupScattering(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   default('scatter.tmax',5);     % animation time
   default('scatter.light',1);    % use light
%            
   men = mount(obj,'<main>',LB,'Scattering');
   sub = uimenu(men,LB,'Classical Particles');
         uimenu(sub,LB,'Classic Pass (1D)',CB,call('CbScatter'),UD,'CbClassicPass1D');
         uimenu(sub,LB,'Classic Pass (3D)',CB,call('CbScatter'),UD,'CbClassicPass3D');
         uimenu(sub,LB,'-----------------');
         uimenu(sub,LB,'Classic Bump (1D)',CB,call('CbScatter'),UD,'CbClassicBump1D');
         uimenu(sub,LB,'Classic Bump (3D)',CB,call('CbScatter'),UD,'CbClassicBump3D');
         
   sub = uimenu(men,LB,'Boson Scattering');
         uimenu(sub,LB,'Boson Scattering (1D)',CB,call('CbScatter'),UD,'CbBoson1D');
         uimenu(sub,LB,'Boson Scattering (1C)',CB,call('CbScatter'),UD,'CbBoson1C');
         uimenu(sub,LB,'Boson Scattering (3D)',CB,call('CbScatter'),UD,'CbBoson3D');
         uimenu(sub,LB,'Boson Scattering (3C)',CB,call('CbScatter'),UD,'CbBoson3C');
         
   sub = uimenu(men,LB,'Fermion Scattering');
         uimenu(sub,LB,'Fermion Scattering (1D)',CB,call('CbScatter'),UD,'CbFermion1D');
         uimenu(sub,LB,'Fermion Scattering (1C)',CB,call('CbScatter'),UD,'CbFermion1C');
         uimenu(sub,LB,'Fermion Scattering (3D)',CB,call('CbScatter'),UD,'CbFermion3D');
         uimenu(sub,LB,'Fermion Scattering (3C)',CB,call('CbScatter'),UD,'CbFermion3C');

         uimenu(men,LB,'------------------------');

   sub = uimenu(men,LB,'Animation Time',UD,'scatter.tmax');
         uimenu(sub,LB,' 5 s',CB,CHCR,UD,5);
         uimenu(sub,LB,'10 s',CB,CHCR,UD,10);
         uimenu(sub,LB,'20 s',CB,CHCR,UD,20);
         choice(sub,setting('scatter.tmax'));         % init 'tmax' item

   sub = uimenu(men,LB,'Light',CB,CHKR,UD,'scatter.light');
         check(sub,setting('scatter.tmax'));         
   return         

   
function CbScatter(obj)
%
   CbExecute(obj,'scatter');
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
   keypress(obj,'CbTerminate');
  
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
   fprintf('CbRefresh: key pressed!\n');
   refresh(obj)
   return

function CbIgnore(obj)
%
% CBIGNORE   Ignore keypress event
%
   %fprintf('CbIgnore: key pressed!\n');
   return

function CbTerminate(obj)
%
% CBTERMINATE   Set termination flag on keypress event
%
   %fprintf('CbTerminate: key pressed!\n');
   terminate(smart);
   return
   
   
%==========================================================================
   
% eof