function demo(obj,func)
% 
% DEMO   Filter Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(fito)               % open menu and add demo menus
%             demo(fito,'setup')       % add demo menus to existing menu
%             demo(fito,func)          % handle callbacks
%             demo(fito,'')            % empty action - existency check
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        See also   FITO SHELL MENU GFO
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
   title = 'Filter Simulation';
   comment = {'We study several filters, such as'
              '1) Ordinary Order 1 Filters (PT1)'
              '2) Twin Filters (TWIN)'
              '3) Enhanced Twin Filters (XTWIN)'
              '4) Kalman Filters (KAFI)'
              '5) Regression Filters (REFI)'
             };

   obj = set(obj,'title',title,'comment',comment);
   return

%==========================================================================

function setup(obj)  % hook in user defined menu items
%
% SETUP    Create a FITO object, add object's info and setup menu
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];  VI = 'visible';
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')]; 
   MF = mfilename; 

   obj = addinfo(obj);
   menu(obj);                          % open menu
   
      % setup defaults

%   setting([]);                       % clear all default settings
   
   %default('shell.callback','');
   default('deterministic',0);
   default('uniform',0);              % uniform filter time constant
   default('kind','twin');            % filter kind
   default('type',2);                 % filter type
   default('Tf',3);                   % filter time constant Tf = 3
   default('Kp',0.1);                 % filter parameter Kp = 0.1
   default('Ns',1);                   % number of runs per parameter set

   default('ref.mode',1);             % reference: exponential curve
   default('ref.V',50);               % reference: V  = 50
   default('ref.T',35);               % reference: T = 35
   default('ref.T1',30);              % reference: T1 = 30
   default('ref.Ts',0.2);             % reference: Ts = 0.2
   default('ref.Tmax',100);           % reference: Tmax = 100
   default('ref.Nx',0);               % reference: Nx = 0

   default('execcmd','');             % command to be executed in CbExec
   default('analysis',5);
   
      % Menu Setup: View

   men = mount(obj,'<main>',LB,'View');
         uimenu(men,LB,'Standard Menues',CB,call('stdmenu'));
         uimenu(men,LB,'Grid on/off',CB,'grid;');
         uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');

      % Menu Setup: Test Functions
            
   men = mount(obj,'<main>',LB,'Test Functions');
   itm = uimenu(men,LB,'Deterministic Noise',CB,CHKR,UD,'deterministic');
         check(itm,setting('deterministic'));  
         uimenu(men,LB,'Show Current Test Function', CB,call('CbTest'));
         uimenu(men,LB,'--------------------------------------------');
         uimenu(men,LB,'Exponential Curve, V = 50, T = 35',CB,call('CbReference'),UD,[1,50 35]);
         uimenu(men,LB,'Symmetric Ramp, T = 10',CB,call('CbReference'),UD,[2 10 35 100]);
         uimenu(men,LB,'Asymmetric Ramp, T = 2',CB,call('CbReference'),UD,[3 2 35 100]);
         uimenu(men,LB,'Square Wave, T = 5', CB,call('CbReference'),UD,[4 5]);
         uimenu(men,LB,'Time Varying System, T = 35', CB,call('CbReference'),UD,[5 50 35]);
         uimenu(men,LB,'--------------------------------------------');
   itm = uimenu(men,LB,'Exponential Curves');
         uimenu(itm,LB,'Breaks, V = 5, T = 35',    CB,call('CbReference'),UD,[1 5 35 30 100]);
         uimenu(itm,LB,'Breaks, V = 10,T = 35',    CB,call('CbReference'),UD,[1 10 35 30 100]);
         uimenu(itm,LB,'Breaks, V = 20,T = 35',    CB,call('CbReference'),UD,[1 20 35 30 100]);
         uimenu(itm,LB,'Breaks, V = 50,T = 35 !!!',CB,call('CbReference'),UD,[1 50 35 30 100]);
         uimenu(itm,LB,'--------------------------');
         uimenu(itm,LB,'Continuous, V = 50, T = 20',    CB,call('CbReference'),UD,[1 50 20 100]);
         uimenu(itm,LB,'Continuous, V = 50, T = 35 !!!',CB,call('CbReference'),UD,[1 50 35 100]);
         uimenu(itm,LB,'Continuous, V = 50, T = 60',    CB,call('CbReference'),UD,[1 50 60 100]);
   itm = uimenu(men,LB,'Symmetric Ramps');
         uimenu(itm,LB,'Symmetric Ramp, T = 1',CB,call('CbReference'),UD,[2 1 35 30 100]);
         uimenu(itm,LB,'Symmetric Ramp, T = 2',CB,call('CbReference'),UD,[2 2 35 30 100]);
         uimenu(itm,LB,'Symmetric Ramp, T = 5',CB,call('CbReference'),UD,[2 5 35 30 100]);
         uimenu(itm,LB,'Symmetric Ramp, T = 10 !!!',CB,call('CbReference'),UD,[2 10 35 30 100]);
         uimenu(itm,LB,'Symmetric Ramp, T = 20',CB,call('CbReference'),UD,[2 20 35 30 100]);
   itm = uimenu(men,LB,'Asymmetric Ramps');
         uimenu(itm,LB,'Asymmetric Ramp, T = 1',CB,call('CbReference'),UD,[3 1 35 30 100]);
         uimenu(itm,LB,'Asymmetric Ramp, T = 2 !!!',CB,call('CbReference'),UD,[3 2 35 30 100]);
         uimenu(itm,LB,'Asymmetric Ramp, T = 5',CB,call('CbReference'),UD,[3 5 35 30 100]);
         uimenu(itm,LB,'Asymmetric Ramp, T = 10',CB,call('CbReference'),UD,[3 10 35 30 100]);
         uimenu(itm,LB,'Asymmetric Ramp, T = 20',CB,call('CbReference'),UD,[3 20 35 30 100]);
   itm = uimenu(men,LB,'Square Waves');
         uimenu(itm,LB,'Square Wave, T = 1', CB,call('CbReference'),UD,[4 1 35 30 100]);
         uimenu(itm,LB,'Square Wave, T = 2', CB,call('CbReference'),UD,[4 2 35 30 100]);
         uimenu(itm,LB,'Square Wave, T = 5 !!!', CB,call('CbReference'),UD,[4 5 35 30 100]);
         uimenu(itm,LB,'Square Wave, T = 10', CB,call('CbReference'),UD,[4 10 35 30 100]);
         uimenu(itm,LB,'Square Wave, T = 20', CB,call('CbReference'),UD,[4 20 35 30 100]);
         uimenu(men,LB,'--------------------------------------------');
         uimenu(men,LB,'Zoom Symmetric Ramp',CB,call('CbReference'),UD,[2 10 0.2 35 10]);
         uimenu(men,LB,'Zoom Asymmetric Ramp',CB,call('CbReference'),UD,[3 2 0.2 35 50]);

      % Menu Setup: Filter Simulation
            
   men = mount(obj,'<main>',LB,'Filter Simulation');
         uimenu(men,LB,'Uniform Filter Time Constant',CB,call('CbUniform'));
         uimenu(men,LB,'------------------------');
         uimenu(men,LB,'NOFI (1)  -  No Filter',CB,call('CbFilter'),UD,{'orfi',1});
         uimenu(men,LB,'ORFI (0)  -  Ordinary PT1 Filter',CB,call('CbFilter'),UD,{'orfi',0});
         uimenu(men,LB,'TWIN (1)  -  Twin Filter - Type 1',CB,call('CbFilter'),UD,{'twin',1});
         uimenu(men,LB,'XTWIN (2) -  XTwin Filter - Type 2',CB,call('CbFilter'),UD,{'twin',2});
         uimenu(men,LB,'ATWIN (3) -  ATwin Filter - Type 3',CB,call('CbFilter'),UD,{'twin',3});
         uimenu(men,LB,'DKAFI (1) -  Kalman Filter - Type 1 (DI)',CB,call('CbFilter'),UD,{'kafi',1});
         uimenu(men,LB,'PKAFI (2) -  Kalman Filter - Type 2 (PT1)',CB,call('CbFilter'),UD,{'kafi',2});
         uimenu(men,LB,'SKAFI (3) -  Kalman Filter - Type 3 (Scalar)',CB,call('CbFilter'),UD,{'kafi',3});
         uimenu(men,LB,'TKAFI (4) -  Kalman Filter - Type 4 (Twin)',CB,call('CbFilter'),UD,{'kafi',4});
         uimenu(men,LB,'REFI (1)  -  Regression Filter - Type 1',CB,call('CbFilter'),UD,{'refi',1});
         uimenu(men,LB,'------------------------');

   itm = uimenu(men,LB,'Tf: Filter Time Constant',UD,'Tf');
         uimenu(itm,LB,'Tf = 0.1',CB,CHCR,UD,0.1);
         uimenu(itm,LB,'Tf = 0.25',CB,CHCR,UD,0.25);
         uimenu(itm,LB,'Tf = 0.5',CB,CHCR,UD,0.5);
         uimenu(itm,LB,'Tf = 0.75',CB,CHCR,UD,0.75);
         uimenu(itm,LB,'Tf = 1.0',CB,CHCR,UD,1.0);
         uimenu(itm,LB,'Tf = 1.25',CB,CHCR,UD,1.25);
         uimenu(itm,LB,'Tf = 1.5',CB,CHCR,UD,1.5);
         uimenu(itm,LB,'Tf = 1.75',CB,CHCR,UD,1.75);
         uimenu(itm,LB,'Tf = 2.0',CB,CHCR,UD,2.0);
         uimenu(itm,LB,'Tf = 2.25',CB,CHCR,UD,2.25);
         uimenu(itm,LB,'Tf = 2.5',CB,CHCR,UD,2.5);
         uimenu(itm,LB,'Tf = 2.75',CB,CHCR,UD,2.75);
         uimenu(itm,LB,'Tf = 3.0',CB,CHCR,UD,3.0);
         uimenu(itm,LB,'Tf = 3.25',CB,CHCR,UD,3.25);
         uimenu(itm,LB,'Tf = 3.5',CB,CHCR,UD,3.5);
         uimenu(itm,LB,'Tf = 3.75',CB,CHCR,UD,3.75);
         uimenu(itm,LB,'Tf = 4.0',CB,CHCR,UD,4.0);
         uimenu(itm,LB,'Tf = 4.25',CB,CHCR,UD,4.25);
         uimenu(itm,LB,'Tf = 4.5',CB,CHCR,UD,4.5);
         uimenu(itm,LB,'Tf = 4.75',CB,CHCR,UD,4.75);
         uimenu(itm,LB,'Tf = 5.0',CB,CHCR,UD,5.0);
         choice(itm,setting('Tf'));

   itm = uimenu(men,LB,'Kp: Kalman Parameter');
         uimenu(itm,LB,'Kp = 0.1',CB,call('CbKp'),UD,0.1);
         uimenu(itm,LB,'Kp = 0.2',CB,call('CbKp'),UD,0.2);
         uimenu(itm,LB,'Kp = 0.3',CB,call('CbKp'),UD,0.3);
         uimenu(itm,LB,'Kp = 0.4',CB,call('CbKp'),UD,0.4);
         uimenu(itm,LB,'Kp = 0.5',CB,call('CbKp'),UD,0.5);
         uimenu(itm,LB,'Kp = 0.6',CB,call('CbKp'),UD,0.6);
         uimenu(itm,LB,'Kp = 0.7',CB,call('CbKp'),UD,0.7);
         uimenu(itm,LB,'Kp = 0.8',CB,call('CbKp'),UD,0.8);
         uimenu(itm,LB,'Kp = 0.9',CB,call('CbKp'),UD,0.9);
         uimenu(itm,LB,'Kp = 1.0',CB,call('CbKp'),UD,1.0);
   itm = uimenu(men,LB,'Nx: Extra Measurements After Break');
         uimenu(itm,LB,'Nx = 0',CB,call('CbNx'),UD,[0]);
         uimenu(itm,LB,'Nx = 1',CB,call('CbNx'),UD,[1]);
         uimenu(itm,LB,'Nx = 2',CB,call('CbNx'),UD,[2]);
         uimenu(itm,LB,'Nx = 3',CB,call('CbNx'),UD,[3]);
         uimenu(men,LB,'------------------------');
   itm = uimenu(men,LB,'Number of simulation runs Ns');
         uimenu(itm,LB,'Ns = 1',CB,call('CbNs'),UD,1);
         uimenu(itm,LB,'Ns = 5',CB,call('CbNs'),UD,5);
         uimenu(itm,LB,'Ns = 30',CB,call('CbNs'),UD,30);
         uimenu(itm,LB,'Ns = 50',CB,call('CbNs'),UD,50);
         uimenu(itm,LB,'Ns = 100',CB,call('CbNs'),UD,100);
         uimenu(itm,LB,'Ns = 200',CB,call('CbNs'),UD,200);
         uimenu(itm,LB,'Ns = 500',CB,call('CbNs'),UD,500);
         uimenu(itm,LB,'Ns = 1000',CB,call('CbNs'),UD,1000);
      
      % Menu Setup: Optimal Behavior
        
   men = mount(obj,'<main>',LB,'Optimal Behavior');
   itm = uimenu(men,LB,'Exponential Curve');
         uimenu(itm,LB,'Exponential Curve, V = 50, T = 35',CB,call('CbReference'),UD,[1,50 35]);
         uimenu(itm,LB,'--------------------------------------------');
         uimenu(itm,LB,'ORFI(0): Tf = 0.5',CB,call('CbFilter'),UD,{'orfi',0, 0.5,0.6});
         uimenu(itm,LB,'TWIN(1): Tf = 1.25',CB,call('CbFilter'),UD,{'twin',1, 1.25,0.1});
         uimenu(itm,LB,'XTWIN(2): Tf = 1.25, Kp = 0.3',CB,call('CbFilter'),UD,{'twin',2, 1.25,0.3});
         uimenu(itm,LB,'ATWIN(3): Tf = 1, Kp = 0.6',CB,call('CbFilter'),UD,{'twin',3, 1,0.6});
         uimenu(itm,LB,'DKAFI(1): Tf = 2, Kp = 0.3',CB,call('CbFilter'),UD,{'kafi',1, 2,0.3});
         uimenu(itm,LB,'PKAFI(2): Tf = 0.5, Kp = 0.4',CB,call('CbFilter'),UD,{'kafi',2, 0.5,0.4});
         uimenu(itm,LB,'SKAFI(3): Tf = 0.5, Kp = 0.2',CB,call('CbFilter'),UD,{'kafi',3, 0.5,0.2});
         uimenu(itm,LB,'TKAFI(4): Tf = 1.5, Kp = 0.1',CB,call('CbFilter'),UD,{'kafi',4, 1.5,0.1});
         uimenu(itm,LB,'REFI(1): Tf = 2.8, Kp = 0.8',CB,call('CbFilter'),UD,{'refi',1, 2.8,0.8});
   itm = uimenu(men,LB,'Asymmetric Ramp');
         uimenu(itm,LB,'Asymmetric Ramp, T = 2',CB,call('CbReference'),UD,[3 2]);
         uimenu(itm,LB,'--------------------------------------------');
         uimenu(itm,LB,'ORFI(0): Tf = 0.3',CB,call('CbFilter'),UD,{'orfi',0, 0.3,0.6});
         uimenu(itm,LB,'TWIN(1): Tf = 0.75',CB,call('CbFilter'),UD,{'twin',1, 0.75,0.1});
         uimenu(itm,LB,'XTWIN(2): Tf = 0.75, Kp = 0.1',CB,call('CbFilter'),UD,{'twin',2, 0.75,0.1});
         uimenu(itm,LB,'ATWIN(3): Tf = 2.5, Kp = 0.1',CB,call('CbFilter'),UD,{'twin',3, 2.5,0.1});
         uimenu(itm,LB,'DKAFI(1): Tf = 0.1, Kp = 0.1',CB,call('CbFilter'),UD,{'kafi',1, 0.1,0.1});
         uimenu(itm,LB,'PKAFI(2): Tf = 0.3, Kp = 0.1',CB,call('CbFilter'),UD,{'kafi',2, 0.3,0.1});
         uimenu(itm,LB,'SKAFI(3): Tf = 0.5, Kp = 0.2',CB,call('CbFilter'),UD,{'kafi',3, 0.5,0.2});
         uimenu(itm,LB,'TKAFI(4): Tf = 0.8, Kp = 0.1',CB,call('CbFilter'),UD,{'kafi',4, 0.8,0.1});
         uimenu(itm,LB,'REFI(1): Tf = 0.3, Kp = 0.1',CB,call('CbFilter'),UD,{'refi',1, 0.3,0.1});
   itm = uimenu(men,LB,'Symmetric Ramp');
         uimenu(itm,LB,'Symmetric Ramp, T = 10',CB,call('CbReference'),UD,[2 10]);
         uimenu(itm,LB,'DKAFI(1): Tf = 3, Kp = 0.3',CB,call('CbFilter'),UD,{'kafi',1,3,0.3},EN,'off');
         uimenu(itm,LB,'PKAFI(2): Tf = 4, Kp = 0.4',CB,call('CbFilter'),UD,{'kafi',2,4,0.4},EN,'off');
         uimenu(itm,LB,'REFI(1): Tf = 2.5, Kp = 0.6',CB,call('CbFilter'),UD,{'refi',1,2.5,0.6},EN,'off');
   itm = uimenu(men,LB,'Zoom Asymmetric Ramp');
         uimenu(itm,LB,'Zoom Asymmetric Ramp, T = 2 (2.7 Sigma)',CB,call('CbReference'),UD,[3 2 0.2 35 50]);
         uimenu(itm,LB,'--------------------------------------------');
         uimenu(itm,LB,'ORFI(0): Tf = 0.25 (4.1 Sigma)',CB,call('CbFilter'),UD,{'orfi',0,0.25,0.1,0});
         uimenu(itm,LB,'DKAFI(1.3): Tf = 0.75, Kp = 0.1 (3.7 Sigma)',CB,call('CbFilter'),UD,{'kafi',1,0.75,0.1,3});
         uimenu(men,LB,'------------------------');
         uimenu(men,LB,'Filter Analysis (5 runs)',CB,call('CbAnalysis'),UD,5);
         uimenu(men,LB,'Filter Analysis (15 runs)',CB,call('CbAnalysis'),UD,15);
         uimenu(men,LB,'Filter Analysis (30 runs)',CB,call('CbAnalysis'),UD,30);
         uimenu(men,LB,'Filter Analysis (50 runs)',CB,call('CbAnalysis'),UD,50);
         uimenu(men,LB,'Filter Analysis (100 runs)',CB,call('CbAnalysis'),UD,100);
         uimenu(men,LB,'Filter Analysis (200 runs)',CB,call('CbAnalysis'),UD,200);
         uimenu(men,LB,'Filter Analysis (400 runs)',CB,call('CbAnalysis'),UD,400);
         uimenu(men,LB,'Filter Analysis (1000 runs)',CB,call('CbAnalysis'),UD,1000);

      % Menu Setup: Principles
            
   men = mount(obj,'<main>',LB,'Principles');
         uimenu(men,LB,'Filter Cpk 1x(filtercpk(1))',CB,call('CbExec'),UD,'filtercpk(1)');
         uimenu(men,LB,'Filter Cpk 3x (filtercpk(3))',CB,call('CbExec'),UD,'filtercpk(3)');
         uimenu(men,LB,'Filter Cpk 30x (filtercpk(30))',CB,call('CbExec'),UD,'filtercpk(30)');
         uimenu(men,LB,'Kalman Demo 1 @ PT1-Glied (kaldemo1)',CB,call('CbExec'),UD,'kaldemo1');
         uimenu(men,LB,'Kalman Demo 2 @ PT1-Glied (kaldemo2)',CB,call('CbExec'),UD,'kaldemo2');
         uimenu(men,LB,'Kalman Demo 3 @ Doppelintegrierer (kafidemo3)',CB,call('CbExec'),UD,'kafidemo3');

      % Menu Setup: Info
            
   %men = mount(obj,'<main>',LB,'Info');
   %itm = uimenu(men,LB,'Plot Info',CB,'plotinfo(gfo)');
         
   %menu(gfo,'InfoMenu',[]);    % last not least add CHAMEO info menu
   refresh(obj);
   return
   
%==========================================================================
% User Defined Menu Callback functions
%==========================================================================
% View Menu

function stdmenu(obj,cbo)  % switch standard menus on/off
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
       
function CbDeterministic(obj)
%   
   itm = arg(obj);   % gcbo;   % get menu item handle
   if strcmp(get(itm,'checked'),'on')
      set(itm,'checked','off');
      setting('deterministic',0);
   else
      set(itm,'checked','on');
      setting('deterministic',1);
   end
   return
   
%==========================================================================
% Test Function Menu

function CbTest(obj,cbo)
%
   cbsetup(obj);                      % setup current function for refresh
   showref(obj);          
   return

function CbReference(obj)  % exponential curve
%
   cbo = arg(obj);
   if (length(cbo) >= 1) setting('ref.mode',cbo(1)); end
   if (length(cbo) >= 2) setting('ref.V',cbo(2));    end
   if (length(cbo) >= 3) setting('ref.T',cbo(3));    end
   if (length(cbo) >= 4) setting('ref.T1',cbo(4));   end
   if (length(cbo) >= 5) setting('ref.Tmax',cbo(5)); end
   showref(gfo);                % show reference
   return
         
%==========================================================================
% Filter Simulation Function Menu

function CbUniform(obj)
%   
   itm = arg(obj);  % gcbo;   % get menu item handle
   if strcmp(get(itm,'checked'),'on')
      set(itm,'checked','off');
      setting('uniform',0);
   else
      set(itm,'checked','on');
      setting('uniform',1);
   end
   return

%==========================================================================

function CbAnalysis(obj)
%
   cbsetup(obj);                       % setup current function for refresh
   keypress(obj,'CbIgnore')
   value = arg(obj);

   if (~isempty(value))
      setting('analysis',value);
   else
      value = setting('analysis');
   end
   
   
   plotinfo(obj,[]);              % reset plot info
   %setting('shell.callback','');
   det = 0;                       % non deterministic
   ref = option(obj,'ref');            % reference
   kind = option(obj,'kind');          % filter kind
   typ = option(obj,'type');           % filter type

   analysis(kind,{typ det ref},value);
   return

function CbFilter(obj)                  % define filter kind, type, params
%   
   cbo = arg(obj);
   
   kind = cbo{1};  setting('kind',kind); % filter kind
   typ = cbo{2};   setting('type',typ);  % filter type

   if (length(cbo) >= 3)
      Tf = cbo{3};  setting('Tf',Tf);    % filter time constant Tf
   end
   if (length(cbo) >= 4)
      Kp = cbo{4};  setting('Kp',Kp);    % filter parameter Kp
   end

   if (length(cbo) >= 5)
      Nx = cbo{5};  setting('ref.Nx',Nx);  % filter parameter Nx
   end

   filtersimu(gfo);             % filter simulation
   return

         
function CbKp(obj)               % define filter parameter Kp
%
   value = arg(obj);
   setting('Kp',value); 
   filtersimu(gfo);             % filter simulation
   return
         
function CbNx(obj)               % define number of extra measurements after break
%
   value = arg(obj);
   setting('ref.Nx',value); 
   filtersimu(gfo);             % filter simulation
   return
         
function CbNs(obj)               % define number of runs per parameter set
%
   value = arg(obj);
   setting('Ns',value); 
   filtersimu(gfo);             % filter simulation
   return

   
function CbExec(obj)   % execute call
%
   cbsetup(obj);                       % setup current function for refresh
   keypress(obj,'refresh')

   cmd = arg(obj);
   if (~isempty(cmd))
      setting('execcmd',cmd);
   else
      cmd = setting('execcmd');
   end
   
   if (~isempty(cmd))
      eval(cmd);
   end
   return

   
function CbIgnore(obj)
%
% CBIGNORE   Ignore keypress event
%
   return
   
%==========================================================================
% 4) auxillary functions
%==========================================================================

function filtersimu(obj)
%
% FILTERSIMU   Filter Simulation; also setup a filter simulation
%              callback string for key press function
%
   cbsetup(obj);                       % setup current function for refresh
   keypress(obj,'refresh')
   
   det = option(obj,'deterministic');
   ref = option(obj,'ref');            % reference
   kind = option(obj,'kind'); 
   typ = option(obj,'type'); 
   Tf = option(obj,'Tf'); 
   Kp = option(obj,'Kp'); 
   Ns = option(obj,'Ns'); 
   uniform = option(obj,'uniform');
   if (uniform) typ = -typ; end
   
   simu(kind,{typ,det,ref},Tf,Kp,Ns);
   
   text = {'Filter Input:',...
           '   black: reference signal',...
           '   green: noisy measurement data',...
           '','Filter Output',...
           '   blue/bullets: ORFI filter result (for comparison)',...
           '   red/bullets: TWIN filter result (for comparison)',...
           '   black/bullets: result of selected filter (to be investigated!)',...
           '','Filter Control:',...
           '   magenta: covariance level',...
          };
   plotinfo(obj,'Filter Simulation',text);          % reset plot info
   
   return

   
function showref(obj)
%
% SHOWREF    Show reference function
%
   ref = option(obj,'ref');
   reference(ref);

   typ = option(obj,'type');           % filter type
   kind = option(obj,'kind');
   eval(sprintf(['F=',kind,'(%g);'],typ));
   ylabel(sprintf(['Filter to be applied: ',upper(F.kind),', type %g'],typ));
   return
   
% eof