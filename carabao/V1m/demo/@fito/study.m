function oo = study(o,varargin)        % Study Menu                    
%
% STUDY   Manage Study menu
%
%           study(o,'Setup');          %  Setup STUDY menu
%
%           study(o,'Study1');         %  Study 1
%           study(o,'Study2');         %  Study 2
%           study(o,'Study3');         %  Study 3
%           study(o,'Study4');         %  Study 4
%
%           study(o,'Signal');         %  Setup STUDY specific Signal menu
%
%        See also: FITO, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,@Analysis,...
                       @Study,...
                       @Reference,@Test,@Uniform,@Filter,@FilterSimu,...
                       @Optimal,...
                       @Principles,@FilterCpk,@KafiDemo);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menus
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   Defaults(o);                        % provide defaults
   Register(o);
   
%  oo = mhead(o,'Study');
%  ooo = TestFunctions(oo);            % add Test Functions submenu
%  ooo = FilterSimulation(oo);         % add Filter Simulation submenu 
%  ooo = OptimalBehavior(oo);          % add Optimal Behavior submenu
%  ooo = Principles(oo);               % add Principles submenu
end
function o = Register(o)               % Register Some Stuff           
   Config(type(fito(o),'fito'));       % register configuration for fito
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
%  plugin(o,['fito/shell/Analysis'],{mfilename,'Analysis'});
end
function o = Defaults(o)               % provide Default settings      
   setting(o,{'fito.deterministic'},0);
   setting(o,{'fito.uniform'},0);     % uniform filter time constant
   setting(o,{'fito.kind'},'twin');   % filter kind
   setting(o,{'fito.type'},2);        % filter type
   setting(o,{'fito.Tf'},3);          % filter time constant Tf = 3
   setting(o,{'fito.Kp'},0.1);        % filter parameter Kp = 0.1
   setting(o,{'fito.Ns'},1);          % number of runs per parameter set

   setting(o,{'fito.ref.mode'},1);    % reference: exponential curve
   setting(o,{'fito.ref.V'},50);      % reference: V  = 50
   setting(o,{'fito.ref.T'},35);      % reference: T = 35
   setting(o,{'fito.ref.T1'},30);     % reference: T1 = 30
   setting(o,{'fito.ref.Ts'},0.2);    % reference: Ts = 0.2
   setting(o,{'fito.ref.Tmax'},100);  % reference: Tmax = 100
   setting(o,{'fito.ref.Nx'},0);      % reference: Nx = 0

   setting(o,{'fito.execcmd'},'');    % command to be executed in CbExec
   setting(o,{'fito.analysis'},5);
end

%==========================================================================
% Configuration Menu
%==========================================================================

function o = Signal(o)                 % Study Specific Signal Menu    
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   switch active(o);                   % depending on active type
      case {'fito'}
         oo = mitem(o,'All',{@Config},'All');
         oo = mitem(o,'Signals',{@Config},'Signals');
         oo = mitem(o,'Errors',{@Config},'Errors');
   end
end
function o = Config(o)                 % Install a Configuration       
%
% CONFIG Setup a configuration
%
%           Config(type(o,'mytype'))   % register a type specific config
%           oo = Config(arg(o,{'All'}) % change configuration
%
   mode = o.either(arg(o,1),'All');    % get mode or provide default

   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = subplot(o,'Signal',mode);       % set signal mode   
   o = category(o,1,[],[],'µ');        % setup category 1
   o = category(o,2,[],[-4 4],'µ');    % setup category 2
   
   switch mode
      case {'All'}
         o = config(o,'r',{1,'k',1,'reference signal'});
         o = config(o,'y',{1,'g',1,'noisy signal'});
         
         o = config(o,'f0',{1,'b',1,'ORFI(o): filtered output'});
         o = config(o,'f1',{1,'r',1,'TWIN(1): filtered output'});
         o = config(o,'f2',{1,'k.-',1,'FILTER(n): filtered output'});

         o = config(o,'n',{2,'g|o',2,'noise'});
         o = config(o,'e0',{2,'b.-',2,'ORFI(o): prediction error'});
         o = config(o,'e1',{2,'r.-',2,'TWIN(1):  prediction error'});
         o = config(o,'e2',{2,'k.-',2,'FILTER(n):  prediction error'});
         o = config(o,'q',{2,'m:.',2,'uncertainty'});
      case {'Signals'}
         o = config(o,'r',{1,'k',1,'reference signal'});
         o = config(o,'y',{1,'g',1,'noisy signal'});
         
         o = config(o,'f0',{1,'b',1,'ORFI(o): filtered output'});
         o = config(o,'f1',{1,'r',1,'TWIN(1): filtered output'});
         o = config(o,'f2',{1,'k.-',1,'FILTER(n): filtered output'});
      case {'Errors'}
         o = config(o,'n',{1,'g|o',2,'noise'});
         o = config(o,'e0',{1,'b.-',2,'ORFI(o): prediction error'});
         o = config(o,'e1',{1,'r.-',2,'TWIN(1):  prediction error'});
         o = config(o,'e2',{1,'k.-',2,'FILTER(n):  prediction error'});
         o = config(o,'q',{1,'m:.',2,'uncertainty'});
   end
   change(o,'Config');
end

%==========================================================================
% Analysis Menu
%==========================================================================

function o = Analysis(o)               % Analysis Menu                 
   if ~isa(current(o),'fito')          % if current object is FITO class
      return
   end
   
   oo = o;                             % without 'Optimal' menu header
   ooo = mitem(oo,'-');
   ooo = mhead(oo,'Filter Analysis (5 runs)',{@CbAnalysis},5);
   ooo = mhead(oo,'Filter Analysis (15 runs)',{@CbAnalysis},15);
   ooo = mhead(oo,'Filter Analysis (30 runs)',{@CbAnalysis},30);
   ooo = mhead(oo,'Filter Analysis (50 runs)',{@CbAnalysis},50);
   ooo = mhead(oo,'Filter Analysis (100 runs)',{@CbAnalysis},100);
   ooo = mhead(oo,'Filter Analysis (200 runs)',{@CbAnalysis},200);
   ooo = mhead(oo,'Filter Analysis (400 runs)',{@CbAnalysis},400);
   ooo = mhead(oo,'Filter Analysis (1000 runs)',{@CbAnalysis},1000);
end
function o = CbAnalysis(o)             % Analysis Callback             
%
   refresh(o,o);                       % come back here for refresh
   runs = arg(o,1);

   if (~isempty(runs))
      setting(o,'fito.analysis',runs);
   else
      runs = setting(o,'fito.analysis');
   end
   
   what(o,[]);                         % reset 'what info'
   det = 0;                            % non deterministic
   ref = opt(o,'fito.ref');            % reference
   kind = opt(o,'fito.kind');          % filter kind
   typ = opt(o,'fito.type');           % filter type

   analyse(o,kind,{typ det ref},runs);
end

%==========================================================================
% Study Menu
%==========================================================================

function o = Study(o)                  % Study Menu                    
%      
   setting(o,{'fito.uniform'},true);
   
   oo = mhead(o,'Study');
   
   ooo = mitem(oo,'Uniform Filter Time Constant',{},'fito.uniform');
         check(ooo,{@Uniform});
   ooo = TestFunction(oo);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'NOFI (1)  -  No Filter',{@Filter},{'orfi',1});
   ooo = mitem(oo,'ORFI (0)  -  Ordinary PT1 Filter',{@Filter},{'orfi',0});
   ooo = mitem(oo,'TWIN (1)  -  Twin Filter - Type 1',{@Filter},{'twin',1});
   ooo = mitem(oo,'XTWIN (2) -  XTwin Filter - Type 2',{@Filter},{'twin',2});
   ooo = mitem(oo,'ATWIN (3) -  ATwin Filter - Type 3',{@Filter},{'twin',3});
   ooo = mitem(oo,'DKAFI (1) -  Kalman Filter - Type 1 (DI)',{@Filter},{'kafi',1});
   ooo = mitem(oo,'PKAFI (2) -  Kalman Filter - Type 2 (PT1)',{@Filter},{'kafi',2});
   ooo = mitem(oo,'SKAFI (3) -  Kalman Filter - Type 3 (Scalar)',{@Filter},{'kafi',3});
   ooo = mitem(oo,'TKAFI (4) -  Kalman Filter - Type 4 (Twin)',{@Filter},{'kafi',4});
   ooo = mitem(oo,'PKAFI1(6) -  Kalman Filter - Type 6 (Polynomial #1)',{@Filter},{'kafi',6});
   ooo = mitem(oo,'REFI (1)  -  Regression Filter - Type 1',{@Filter},{'refi',1});
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Tf: Filter Time Constant',{},'fito.Tf');
         choice(ooo,[0.1, 0.25:0.25:5],{});

   ooo = mitem(oo,'Kp: Kalman Parameter',{},'fito.Kp');
         choice(ooo,[0.1:0.1:1.0],{@FilterSimu});
   ooo = mitem(oo,'Nx: Extra Measurements After Break',{},'fito.Nx');
         choice(ooo,[0:3],{@FilterSimu});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ns: Number of simulation runs',{},'fito.Ns');
         choice(ooo,[1,5,30,50,100,200,500,1000],{@FilterSimu});
end
function o = Uniform(o)                % Change Uniform                
%   
   return
   itm = arg(o);
   if strcmp(get(itm,'checked'),'on')
      set(itm,'checked','off');
      setting('uniform',0);
   else
      set(itm,'checked','on');
      setting('uniform',1);
   end
end
function o = TestFunction(o)           % Test Function Menu            
%
   oo = mhead(o,'Test Function');
   ooo = mitem(oo,'Deterministic Noise',{},'fito.deterministic');
         check(ooo,{});
   ooo = mitem(oo,'Show Current Test Function',{@Test});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Exponential Curve, V = 50, T = 35',{@Reference},[1,50 35]);
   ooo = mitem(oo,'Symmetric Ramp, T = 10',{@Reference},[2 10 35 100]);
   ooo = mitem(oo,'Asymmetric Ramp, T = 2',{@Reference},[3 2 35 100]);
   ooo = mitem(oo,'Square Wave, T = 5',{@Reference},[4 5]);
   ooo = mitem(oo,'Time Varying System, T = 35',{@Reference},[5 50 35]);

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Exponential Curves');
   oooo = mitem(ooo,'Breaks, V = 5, T = 35',{@Reference},[1 5 35 30 100]);
   oooo = mitem(ooo,'Breaks, V = 10,T = 35',{@Reference},[1 10 35 30 100]);
   oooo = mitem(ooo,'Breaks, V = 20,T = 35',{@Reference},[1 20 35 30 100]);
   oooo = mitem(ooo,'Breaks, V = 50,T = 35 !!!',{@Reference},[1 50 35 30 100]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Continuous, V = 50, T = 20',{@Reference},[1 50 20 100]);
   oooo = mitem(ooo,'Continuous, V = 50, T = 35 !!!',{@Reference},[1 50 35 100]);
   oooo = mitem(ooo,'Continuous, V = 50, T = 60',{@Reference},[1 50 60 100]);

   ooo = mitem(oo,'Symmetric Ramps');
   oooo = mitem(ooo,'Symmetric Ramp, T = 1',{@Reference},[2 1 35 30 100]);
   oooo = mitem(ooo,'Symmetric Ramp, T = 2',{@Reference},[2 2 35 30 100]);
   oooo = mitem(ooo,'Symmetric Ramp, T = 5',{@Reference},[2 5 35 30 100]);
   oooo = mitem(ooo,'Symmetric Ramp, T = 10 !!!',{@Reference},[2 10 35 30 100]);
   oooo = mitem(ooo,'Symmetric Ramp, T = 20',{@Reference},[2 20 35 30 100]);
   
   ooo = mitem(oo,'Asymmetric Ramps');
   oooo = mitem(ooo,'Asymmetric Ramp, T = 1',{@Reference},[3 1 35 30 100]);
   oooo = mitem(ooo,'Asymmetric Ramp, T = 2 !!!',{@Reference},[3 2 35 30 100]);
   oooo = mitem(ooo,'Asymmetric Ramp, T = 5',{@Reference},[3 5 35 30 100]);
   oooo = mitem(ooo,'Asymmetric Ramp, T = 10',{@Reference},[3 10 35 30 100]);
   oooo = mitem(ooo,'Asymmetric Ramp, T = 20',{@Reference},[3 20 35 30 100]);

   ooo = mitem(oo,'Square Waves');
   oooo = mitem(ooo,'Square Wave, T = 1',{@Reference},[4 1 35 30 100]);
   oooo = mitem(ooo,'Square Wave, T = 2',{@Reference},[4 2 35 30 100]);
   oooo = mitem(ooo,'Square Wave, T = 5 !!!',{@Reference},[4 5 35 30 100]);
   oooo = mitem(ooo,'Square Wave, T = 10',{@Reference},[4 10 35 30 100]);
   oooo = mitem(ooo,'Square Wave, T = 20',{@Reference},[4 20 35 30 100]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Zoom Symmetric Ramp',{@Reference},[2 10 0.2 35 10]);
   oooo = mitem(ooo,'Zoom Asymmetric Ramp',{@Reference},[3 2 0.2 35 50]);
end
function o = Test(o)                   % Show Test Function            
%
   refresh(o,o);                       % come here to refresh
   ShowRef(o);          
end
function o = Reference(o)              % exponential curve             
%
   cbo = arg(o,1);
   if (length(cbo) >= 1) setting(o,'fito.ref.mode',cbo(1)); end
   if (length(cbo) >= 2) setting(o,'fito.ref.V',cbo(2));    end
   if (length(cbo) >= 3) setting(o,'fito.ref.T',cbo(3));    end
   if (length(cbo) >= 4) setting(o,'fito.ref.T1',cbo(4));   end
   if (length(cbo) >= 5) setting(o,'fito.ref.Tmax',cbo(5)); end
   ShowRef(pull(o));                   % show reference
end
function o = Filter(o)                 % Set Parameters for Filter Simu
%   
   cbo = arg(o,1);
   
   kind = cbo{1};  setting(o,'fito.kind',kind); % filter kind
   typ = cbo{2};   setting(o,'fito.type',typ);  % filter type

   if (length(cbo) >= 3)
      Tf = cbo{3};  setting(o,'fito.Tf',Tf);    % filter time constant Tf
   end
   if (length(cbo) >= 4)
      Kp = cbo{4};  setting(o,'fito.Kp',Kp);    % filter parameter Kp
   end

   if (length(cbo) >= 5)
      Nx = cbo{5};  setting(o,'fito.ref.Nx',Nx);% filter parameter Nx
   end

   o = pull(o);                        % refresh object
   o = FilterSimu(o);                  % filter simulation
end

%==========================================================================
% Optimal Menu
%==========================================================================
      
function o = Optimal(o)                % Optimal Behavior Menu         
   oo = mhead(o,'Optimal');
   ooo = mhead(oo,'Exponential Curve');
   oooo = mitem(ooo,'Exponential Curve, V = 50, T = 35',{@Reference},[1,50 35]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'ORFI(0): Tf = 0.5',{@Filter},{'orfi',0, 0.5,0.6});
   oooo = mitem(ooo,'TWIN(1): Tf = 1.25',{@Filter},{'twin',1, 1.25,0.1});
   oooo = mitem(ooo,'XTWIN(2): Tf = 1.25, Kp = 0.3',{@Filter},{'twin',2, 1.25,0.3});
   oooo = mitem(ooo,'ATWIN(3): Tf = 1, Kp = 0.6',{@Filter},{'twin',3, 1,0.6});
   oooo = mitem(ooo,'DKAFI(1): Tf = 2, Kp = 0.3',{@Filter},{'kafi',1, 2,0.3});
   oooo = mitem(ooo,'PKAFI(2): Tf = 0.5, Kp = 0.4',{@Filter},{'kafi',2, 0.5,0.4});
   oooo = mitem(ooo,'SKAFI(3): Tf = 0.5, Kp = 0.2',{@Filter},{'kafi',3, 0.5,0.2});
   oooo = mitem(ooo,'TKAFI(4): Tf = 1.5, Kp = 0.1',{@Filter},{'kafi',4, 1.5,0.1});
   oooo = mitem(ooo,'REFI(1): Tf = 2.8, Kp = 0.8',{@Filter},{'refi',1, 2.8,0.8});
   
   ooo = mhead(oo,'Asymmetric Ramp');
   oooo = mitem(ooo,'Asymmetric Ramp, T = 2',{@Reference},[3 2]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'ORFI(0): Tf = 0.3',{@Filter},{'orfi',0, 0.3,0.6});
   oooo = mitem(ooo,'TWIN(1): Tf = 0.75',{@Filter},{'twin',1, 0.75,0.1});
   oooo = mitem(ooo,'XTWIN(2): Tf = 0.75, Kp = 0.1',{@Filter},{'twin',2, 0.75,0.1});
   oooo = mitem(ooo,'ATWIN(3): Tf = 2.5, Kp = 0.1',{@Filter},{'twin',3, 2.5,0.1});
   oooo = mitem(ooo,'DKAFI(1): Tf = 0.1, Kp = 0.1',{@Filter},{'kafi',1, 0.1,0.1});
   oooo = mitem(ooo,'PKAFI(2): Tf = 0.3, Kp = 0.1',{@Filter},{'kafi',2, 0.3,0.1});
   oooo = mitem(ooo,'SKAFI(3): Tf = 0.5, Kp = 0.2',{@Filter},{'kafi',3, 0.5,0.2});
   oooo = mitem(ooo,'TKAFI(4): Tf = 0.8, Kp = 0.1',{@Filter},{'kafi',4, 0.8,0.1});
   oooo = mitem(ooo,'REFI(1): Tf = 0.3, Kp = 0.1',{@Filter},{'refi',1, 0.3,0.1});

   ooo = mhead(oo,'Symmetric Ramp');
   oooo = mitem(ooo,'Symmetric Ramp, T = 10',{@Reference},[2 10]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'DKAFI(1): Tf = 3, Kp = 0.3',{@Filter},{'kafi',1,3,0.3},'enable','off');
   oooo = mitem(ooo,'PKAFI(2): Tf = 4, Kp = 0.4',{@Filter},{'kafi',2,4,0.4},'enable','off');
   oooo = mitem(ooo,'REFI(1): Tf = 2.5, Kp = 0.6',{@Filter},{'refi',1,2.5,0.6},'enable','off');
   
   ooo = mhead(oo,'Zoom Asymmetric Ramp');
   oooo = mitem(ooo,'Zoom Asymmetric Ramp, T = 2 (2.7 Sigma)',{@Reference},[3 2 0.2 35 50]);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'ORFI(0): Tf = 0.25 (4.1 Sigma)',{@Filter},{'orfi',0,0.25,0.1,0});
   oooo = mitem(ooo,'DKAFI(1.3): Tf = 0.75, Kp = 0.1 (3.7 Sigma)',{@Filter},{'kafi',1,0.75,0.1,3});
end

%==========================================================================
% Principles Menu
%==========================================================================

function o = Principles(o)             % Principles Menu               
%
   me = mfilename;                     % shorthand
   
   oo = mhead(o,'Principles');
   ooo = mitem(oo,'Filter Cpk 1x',{@invoke,me,'FilterCpk',1});
   ooo = mitem(oo,'Filter Cpk 3x',{@invoke,me,'FilterCpk',3});
   ooo = mitem(oo,'Filter Cpk 30x',{@invoke,me,'FilterCpk',30});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Kalman Demo 1 @ PT1-System',{@invoke,me,'KafiDemo',1});
   ooo = mitem(oo,'Kalman Demo 2 @ PT1-System',{@invoke,me,'KafiDemo',2});
   ooo = mitem(oo,'Kalman Demo 3 @ Double Integrator',{@invoke,me,'KafiDemo',3});
end   
function o = FilterCpk(o)              % Study Filter Cpk              
   mode = arg(o,1);
   filtercpk(o,mode);                  % delegate to method
end
function o = KafiDemo(o)               % Kalman Filter Demo            
   mode = arg(o,1);
   switch mode
      case 1
         kaldemo1;
      case 2
         kaldemo2;
      case 3
         kafidemo3;
      otherwise
         error('bad mode!');
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function NotUsed                       % Stuff Which is not Used       
% function CbExec(obj)   % execute call
% %
%    cbsetup(obj);                       % setup current function for refresh
%    keypress(obj,'refresh')
% 
%    cmd = arg(obj);
%    if (~isempty(cmd))
%       setting('execcmd',cmd);
%    else
%       cmd = setting('execcmd');
%    end
%    
%    if (~isempty(cmd))
%       eval(cmd);
%    end
% end
% function CbIgnore(obj)
% %
% % CBIGNORE   Ignore keypress event
% %
% end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = FilterSimu(o)             % Filter Simulation             
%
% FILTERSIMU   Filter Simulation; also setup a filter simulation
%              callback string for key press function
%
   refresh(o,o);                       % setup current function for refresh
   o = with(o,'fito');

   det = opt(o,'deterministic');
   ref = opt(o,'ref');                 % reference
   kind = opt(o,'kind'); 
   typ = opt(o,'type'); 
   Tf = opt(o,'Tf'); 
   Kp = opt(o,'Kp'); 
   Ns = opt(o,'Ns'); 
   uniform = opt(o,'uniform');
   if (uniform)
      typ = -typ;
   end
   
   simu(o,kind,{typ,det,ref},Tf,Kp,Ns);
   
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
   what(o,'Filter Simulation',text);   % reset plot info
end
function o = ShowRef(o)                % Show Reference Functiuon      
%
% SHOWREF    Show reference function
%
   o = with(o,'fito');                % with 'fito' context
   ref = opt(o,'ref');
   reference(o,ref);

   typ = opt(o,'type');                % filter type
   kind = opt(o,'kind');
   eval(sprintf(['F=',kind,'(%g);'],typ));
   ylabel(sprintf(['Filter to be applied: ',upper(F.kind),', type %g'],typ));
end
