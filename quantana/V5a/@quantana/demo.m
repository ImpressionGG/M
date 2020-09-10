function oo = demo(o,varargin)         % Quantana Demo                 
%
% Demo  QUANTANA demo shell
%
%         See also: CARAMEL, MENU
%
   [gamma,oo] = manage(o,varargin,@Shell,@Dynamic,@Register);
   oo = gamma(oo);                     % invoke local function
end

function olddemo(obj,varargin)
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
% %    [cmd,obj,list,func] = dispatch(obj,varargin,{},'setup');
% %    
% %    if ~propagate(obj,func,which(func)) 
% %       eval(cmd);
% %    end
% %    return
% %    
%    if (nargin <= 1)                        % dispatch: setup or callback?
%       setup(obj);                          % open figure & setup menu items 
%    elseif ~propagate(obj,func,which(func)) 
%       fig = busy;
%       eval([func,'(obj);']);               % invoke callback
%       ready(fig);
%    end
%    return
end      

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Setup Demo Shell              
%
% SHELL   Setup shell
%
   o = Init(o);                        % initialize object

   o = menu(o,'Begin');                % begin menu setup
   oo = menu(o,'File');                % add File menu
   oo = View(o);                       % add View menu
%  oo = bestof(o,'Setup');
   oo = Basics(o);                     % add Basics menu
%  oo = quondemo(o,'Setup');
   oo = Harmonic(o);                   % add Harmonic menu
%  oo = FreeParticle(o);
%  oo = Bions(o);
%  oo = Scattering(o);
%  oo = Ladder(o);
   oo = menu(o,'Info');                % add Info menu
   o = menu(o,'End');                  % end menu setup

%  cls(obj);
%  refresh(obj);
end
function o = Init(o)                   % Init Object                   
   o = set(o,{'title'},'Quantana Shell');
   o = set(o,{'comment'},...
           {'Simulation and Visualization of Quantum Mechanical Systems'});

   o = dynamic(o,false);               % setup as a static shell
   o = launch(o,mfilename);            % setup launch function
   o = refresh(o,{@menu,'About'});     % provide refresh callback function
end
   
%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % Setup View Menu               
%
   a = 5;
   
   setting(o,{'dark'},1);
   setting(o,{'profiler'},0);

   setting(o,{'global.size'},50);        % size of operators & states
   setting(o,{'global.xmin'},-a);        % minimum x coordinate
   setting(o,{'global.xmax'},+a);        % maximum x coordinate
   setting(o,{'global.ymin'},-a);        % minimum y coordinate
   setting(o,{'global.ymax'},+a);        % maximum y coordinate
   setting(o,{'global.zmin'},-a);        % minimum z coordinate
   setting(o,{'global.zmax'},+a);        % maximum z coordinate
   setting(o,{'global.tmin'}, 0);        % minimum t coordinate
   setting(o,{'global.tmax'},+a);        % maximum t coordinate
   setting(o,{'global.dt'},0.1);         % time interval
   setting(o,{'wing.multi'},1);          % number of wings in wing plot
   setting(o,{'wing.ripple'},0);         % ripple of wing plot
   setting(o,{'wing.transparency'},0.8); % transparency of wing plot

   oo = mhead(o,'View');
   ooo = mitem(oo,'Standard Menues',{@StandardMenues});
   ooo = Toolbar(oo);                  % add toolbar menu item
   ooo = Grid(oo);                     % add grid menu item
   
   ooo = mitem(oo,'Clear Sceene',{@sceene});
   ooo = mitem(oo,'Spinning','camera spinning;');
   ooo = mitem(oo,'Background dark/bright',{@CbBackground});
   ooo = mitem(oo,'Standard Window Size',{},{@StandardWindowSize});
   ooo = mitem(oo,'-');
         
   ooo = mitem(oo,'Wings',{},'wing.multi');
   choice(ooo,{{'1 Wing',1},{'2 Wings',2},{'3 Wings',3},...
               {'4 Wings',4},{'5 Wings',5}},{});

   ooo = mitem(oo,'Ripple',{},'wing.ripple');
   choice(ooo,[0:0.1:0.9],{});

   ooo = mitem(oo,'Transparency',{},'wing.transparency');
   choice(ooo,[0:0.1:1.0],{});
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
   function o = Grid(o)                % Grid Menu                     
   %
      setting(o,{'view.grid'},0);         % no grid by default

      oo = mitem(o,'Grid',{},'view.grid');
      choice(oo,{{'Off',0},{'On',1}},{});
   end
   function o = CbBackground(o)        % Set Window Background         
   %
      drk = setting('dark');
      if (isempty(drk))
         drk = 0;
      end
      setting('dark',~drk);
      refresh(obj);
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

%==========================================================================
% Basics Menu
%==========================================================================

function oo = Basics(o)                % Setup Basics Menu             
%
   setting(o,{'pale.m'},2);    % number of segments along pale (mp = 10)
   setting(o,{'pale.n'},6);    % number of segments around pale (np = 10)
   setting(o,{'pale.t'},0.8);  % transparency (tp = 0.8)

   oo = mhead(o,'Basics');
   ooo = mitem(oo,'Camera');
   oooo = mitem(ooo,'Zoom',{@CbBasics,'CbZoom'});
   oooo = mitem(ooo,'Spin',{@CbBasics 'CbSpin'});
   ooo = mitem(oo,'Spin & Zoom',{@CbBasics 'CbSpinZoom'});
   ooo = mitem(oo,'Phase Colors');
% %          uimenu(sub,LB,'Phase Colors (Single)',CB,call('CbBasics'),UD,'CbPhaseColors');
% %          uimenu(sub,LB,'Phase Colors (Multi)',CB,call('CbBasics'),UD,'CbMultiColors');
% %    sub = uimenu(men,LB,'Color Maps');
% %          uimenu(sub,LB,'Fire Color Map',CB,call('CbBasics'),UD,'CbFireCmap');
% %          uimenu(sub,LB,'Alpha Color Map',CB,call('CbBasics'),UD,'CbAlphaCmap');
% %          uimenu(sub,LB,'Phase Color Map',CB,call('CbBasics'),UD,'CbPhaseCmap');
% %          uimenu(sub,LB,'Complex Color Map',CB,call('CbBasics'),UD,'CbComplexCmap');
% %    sub = uimenu(men,LB,'3D Visualization');
% %          uimenu(sub,LB,'3D Tube Visualization',CB,call('CbBasics'),UD,'Cb3DTube');
% %          uimenu(sub,LB,'3D Wing Visualization',CB,call('CbBasics'),UD,'Cb3DWing');
% %          uimenu(sub,LB,'3D Pale Visualization',CB,call('CbBasics'),UD,'Cb3DPale');
% %          
% %    sub = uimenu(men,LB,'---------------------');
% %    sub = uimenu(men,LB,'3D Matlab Basics');
% %          uimenu(sub,LB,'Transparency',CB,call('CbMatlab'),UD,'transpdemo');
% %          
% %          uimenu(men,LB,'Planck Ball',CB,call('CbBlackBody'),UD,'CbPlanckBall');
% % 
% %    sub = uimenu(men,LB,'---------------------');
% %          uimenu(men,LB,'Infinite Waves (1D)',CB,call('CbSchroed'),UD,'CbInfWaves1D');
% %          uimenu(men,LB,'Infinite Waves (1P)',CB,call('CbSchroed'),UD,'CbInfWaves1P');
end
function o = CbBasics(o)               % Basics Callback               
%
   CbExecute(obj,'basics');
end
function o = CbMatlab(o)               % Execute a Matlab Demo         
%
   butpress(o,'CbRefresh');            % refresh on next key press
   cmd = arg(o,1);
   eval(cmd);
end
function CbSchroed(obj)                % Schroedinger Callback         
%
   CbExecute(obj,'schroedinger');
end
function CbBlackBody(obj)              % BlackBody Callback            
%
   CbExecute(obj,'blackbody');
end
   
%==========================================================================
% Harmonic Oscillator Menu
%==========================================================================

function oo = Harmonic(o)              % Setup Harmonic Menu           
%
   setting(o,{'harmonic.speed'},1);    % speed of animation
   setting(o,{'harmonic.N'},10);       % coherence number
   setting(o,{'harmonic.coloring'},'uni'); % coloring of animation
   setting(o,{'harmonic.modes'},[0 0]);% activated modes
   setting(o,{'harmonic.field'},0.5);  % field strength
   setting(o,{'harmonic.omega'},1.0);  % field frequency
   setting(o,{'harmonic.pulse'},1e99); % pulse width for external force
   setting(o,{'harmonic.pseudo'},1.0); % pseudo factor
   setting(o,{'harmonic.static'},0);   % static study
   setting(o,{'harmonic.stop'},0);     % no optimal stop
   setting(o,{'harmonic.wave'},1);     % show wave

   oo = mhead(o,'Harmonic');
   ooo = mitem(oo,'Basics');
   oooo = mitem(ooo,'Energy Levels',{@CbHarmonic,'EnergyLevels'});
   oooo = mitem(ooo,'Eigen Functions',{@CbHarmonic,'EigenFuncs'});
   oooo = mitem(ooo,'Eigen Oscillations',{@CbHarmonic,'EigenOscis'});

% % %    sub = uimenu(men,LB,'Eigen Oscillations');
% % %          uimenu(sub,LB,'3D Eigen Oscillations',CB,call('CbHarmonic'),UD,'Cb3DEigenOscis');
% % %    
% % %    sub = uimenu(men,LB,'Superposition');
% % %          uimenu(sub,LB,'Superposition |0>+|1>',CB,call('CbHarmonic'),UD,'CbSuper1');
% % %          uimenu(sub,LB,'Superposition |0>+|1>+|2>',CB,call('CbHarmonic'),UD,'CbSuper2');
% % %          
% % %    sub = uimenu(men,LB,'Coherent State');
% % %          uimenu(sub,LB,'Coherent Oscillation',CB,call('CbHarmonic'),UD,'CbCoherent');
% % %          uimenu(sub,LB,'Coherent Speedup',CB,call('CbHarmonic'),UD,'CbCoherentSpeedup');
% % %          
% % %    itm = uimenu(sub,LB,'Coherence Number',UD,'harmonic.N');
% % %          uimenu(itm,LB,'0.1',CB,CHCR,UD,0.1);
% % %          uimenu(itm,LB,'0.5',CB,CHCR,UD,0.5);
% % %          uimenu(itm,LB,'1',CB,CHCR,UD,1);
% % %          uimenu(itm,LB,'3',CB,CHCR,UD,3);
% % %          uimenu(itm,LB,'10',CB,CHCR,UD,10);
% % %          uimenu(itm,LB,'25',CB,CHCR,UD,25);
% % %          uimenu(itm,LB,'50',CB,CHCR,UD,50);
% % %          uimenu(itm,LB,'75',CB,CHCR,UD,75);
% % %          uimenu(itm,LB,'100',CB,CHCR,UD,100);
% % %          choice(itm,setting('harmonic.N'));   
% % % 
% % %    sub = uimenu(men,LB,'Pulse Field');
% % %          uimenu(sub,LB,'External Pulse Field',CB,call('CbHarmonic'),UD,'CbPulseField');
% % %          uimenu(sub,LB,'Analysis',CB,call('CbHarmonic'),UD,'CbPulseAnalysis');
% % % 
% % %    sub = uimenu(men,LB,'Harmonic Field');
% % %          uimenu(sub,LB,'External Harmonic Field',CB,call('CbHarmonic'),UD,'CbHarmonicField');
% % %          uimenu(sub,LB,'Analysis',CB,call('CbHarmonic'),UD,'CbHarmonicAnalysis');
% % % 
% % %          uimenu(sub,LB,'Harmonic Excitation (!)',CB,call('CbHarmonic'),UD,'HarmonicExcitation');
% % %          
% % %          uimenu(men,LB,'---------------------');
% % %          
% % %    sub = uimenu(men,LB,'Oscillator Type',UD,'harmonic.pseudo');
% % %          uimenu(sub,LB,'Harmonic',CB,CHCR,UD,1);
% % %          uimenu(sub,LB,'Pseudo 1 (q=1.1)',CB,CHCR,UD,1.1);
% % %          uimenu(sub,LB,'Pseudo 2 (q=1.2)',CB,CHCR,UD,1.2);
% % %          uimenu(sub,LB,'Pseudo 3 (q=1.5)',CB,CHCR,UD,1.5);
% % %          uimenu(sub,LB,'Pseudo 4 (q=2.0)',CB,CHCR,UD,2.0);
% % %          choice(sub,setting('harmonic.pseudo'));   
% % % 
% % %    sub = uimenu(men,LB,'Active Modes',UD,'harmonic.modes');
% % %          uimenu(sub,LB,'[0]',CB,CHCR,UD,[0 0]);
% % %          uimenu(sub,LB,'[1]',CB,CHCR,UD,[1 1]);
% % %          uimenu(sub,LB,'[2]',CB,CHCR,UD,[2 2]);
% % %          uimenu(sub,LB,'[0 1]',CB,CHCR,UD,[0 1]);
% % %          uimenu(sub,LB,'[0 2]',CB,CHCR,UD,[0 2]);
% % %          uimenu(sub,LB,'[1 2]',CB,CHCR,UD,[1 2]);
% % %          choice(sub,setting('harmonic.modes'));   
% % %          
% % %    sub = uimenu(men,LB,'Field Strength',UD,'harmonic.field');
% % %          choice(sub,[0:0.02:0.08, 0.1:0.1:0.4, 0.5:0.5:5],CHCR);
% % % 
% % %    sub = uimenu(men,LB,'Field Frequency',UD,'harmonic.omega');
% % %          choice(sub,[0:0.1:0.5, 1, 1.48, 1.5:0.5:4, 4.19, 4.5 5],CHCR);
% % % 
% % %    sub = uimenu(men,LB,'Pulse Width',UD,'harmonic.pulse');
% % %          choice(sub,[0:0.5:4.5, 4.55:0.05:5, 5.5:0.5:10, 1e99],CHCR);
% % % 
% % %    sub = uimenu(men,LB,'Animation Speed',UD,'harmonic.speed');
% % %          uimenu(sub,LB,'Slow',CB,CHCR,UD,1);
% % %          uimenu(sub,LB,'Medium',CB,CHCR,UD,2);
% % %          uimenu(sub,LB,'Fast',CB,CHCR,UD,3);
% % %          choice(sub,setting('harmonic.speed'));   
% % % 
% % %    sub = uimenu(men,LB,'Static',CB,CHKR,UD,'harmonic.static');
% % %          check(sub,setting('harmonic.static'));   
% % %          
% % %    sub = uimenu(men,LB,'Coloring',UD,'harmonic.coloring');
% % %          uimenu(sub,LB,'Unicolor',CB,CHCR,UD,'uni');
% % %          uimenu(sub,LB,'Multicolor',CB,CHCR,UD,'multi');
% % %          choice(sub,setting('harmonic.coloring'));
% % % 
% % %    sub = uimenu(men,LB,'Optimal Stop',UD,'harmonic.stop');
% % %          check(sub,CHKR);   
% % % 
% % %    sub = uimenu(men,LB,'Show Wave',UD,'harmonic.wave');
% % %          check(sub,CHKR);   
end
   
   
function o = CbHarmonic(o)   
%
   o = arg(o,[{'harmosc'},arg(o,0)]);
   CbExecute(o);
end
   
%==========================================================================
% Free Particle Menu
%==========================================================================

function MenuSetupFreeParticle(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('control.target','Tt');             % pre-load temperature

   men = mount(obj,'<main>',LB,'Free Particle');
   sub = uimenu(men,LB,'Free Particle Study');
         uimenu(sub,LB,'Forward Study',CB,call('CbFree'),UD,'CbFreeFwdStudy');
         uimenu(sub,LB,'Backward Study',CB,call('CbFree'),UD,'CbFreeBckStudy');
         
   sub = uimenu(men,LB,'Wave Packet Study');
         uimenu(sub,LB,'Pale Packet: k=-15, sigma = 1',CB,call('CbFree'),UD,'CbPacketStudyPale');
         uimenu(sub,LB,'Wing Packet: k=-15, sigma = 1',CB,call('CbFree'),UD,'CbPacketStudyWing');
         uimenu(sub,LB,'Moving Pale Packet',CB,call('CbFree'),UD,'CbPacketMovePale');
         uimenu(sub,LB,'Moving Wing Packet',CB,call('CbFree'),UD,'CbPacketMoveWing');
         
         uimenu(men,LB,'Free Particle Movement',CB,call('CbFree'),UD,'CbFreeMove');
         uimenu(men,LB,'Wave Packet Movement',CB,call('CbFree'),UD,'CbWavePacket');
         uimenu(men,LB,'--------------------------');
         
   sub = uimenu(men,LB,'Scattering');
         uimenu(sub,LB,'Total Reflection',CB,call('CbFree'),UD,'CbTotalReflection');
         uimenu(sub,LB,'Delta Scattering',CB,call('CbFree'),UD,'CbDeltaScattering');
         
         uimenu(men,LB,'--------------------------');
         uimenu(men,LB,'Fourier Transform',CB,call('CbFree'),UD,'CbFourier');
         uimenu(men,LB,'Eigen Functions',CB,call('CbFree'),UD,'CbEigenFuncs');
end

   
function CbFree(obj)   
%
   CbExecute(obj,'freepart');
end
   
%==========================================================================
% Bions Menu
%==========================================================================

function MenuSetupBions(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('bion.type',0);        % general type for bion (distinguishable)
   default('bion.modes',[1 2]);   % eigen modes for bion
%   
   men = mount(obj,'<main>',LB,'Bions');
         uimenu(men,LB,'Bion Eigen Functions',CB,call('CbBions'),UD,'CbBionEigen');
         uimenu(men,LB,'Destinguishable Particles',CB,call('CbBions'),UD,'CbDistinguish');
         uimenu(men,LB,'--------------------');
         
   sub = uimenu(men,LB,'Bion Type',UD,'bion.type');
         uimenu(sub,LB,'General',CB,CHCR,UD,0);
         uimenu(sub,LB,'Boson',CB,CHCR,UD,+1);
         uimenu(sub,LB,'Fermion',CB,CHCR,UD,-1);
         choice(sub,setting('bion.type'));  
         
   sub = uimenu(men,LB,'Modes',UD,'bion.modes');
         uimenu(sub,LB,'modes [1 1]',CB,CHCR,UD,[1 1]);
         uimenu(sub,LB,'modes [1 2]',CB,CHCR,UD,[1 2]);
         uimenu(sub,LB,'modes [1 3]',CB,CHCR,UD,[1 3]);
         uimenu(sub,LB,'modes [2 1]',CB,CHCR,UD,[2 1]);
         uimenu(sub,LB,'modes [2 2]',CB,CHCR,UD,[2 2]);
         uimenu(sub,LB,'modes [2 3]',CB,CHCR,UD,[2 3]);
         uimenu(sub,LB,'modes [3 1]',CB,CHCR,UD,[3 1]);
         uimenu(sub,LB,'modes [3 2]',CB,CHCR,UD,[3 2]);
         uimenu(sub,LB,'modes [3 3]',CB,CHCR,UD,[3 3]);
         uimenu(sub,LB,'modes [1 2;1 3]',CB,CHCR,UD,[1 2;1 3]);
         uimenu(sub,LB,'modes [1 2;2 3]',CB,CHCR,UD,[1 2;2 3]);
         uimenu(sub,LB,'modes [1 2;1 3;2 3]',CB,CHCR,UD,[1 2;1 3;2 3]);
         choice(sub,setting('bion.modes'));   

         uimenu(men,LB,'Destinguishable Particles',CB,call('CbBions'),UD,'CbDistinguish');
end

function CbBions(obj)   
%
   CbExecute(obj,'biondemo');
end
   
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
end

   
function CbScatter(obj)
%
   CbExecute(obj,'scatter');
end

%==========================================================================
% Ladder Menu
%==========================================================================

function Ladder(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('ladder.nmax',3);         % max. particle number
   default('ladder.omega',1);        % eigen frequency
   default('ladder.operator',1);     % operator visibility
%   
   men = mount(obj,'<main>',LB,'Ladder');
         uimenu(men,LB,'Particle Creation',CB,call('CbLadder'),UD,'CbCreation');
         uimenu(men,LB,'Particle Anihilation',CB,call('CbLadder'),UD,'CbAnihilation');
         uimenu(men,LB,'Creation & Anihilation',CB,call('CbLadder'),UD,'CbCreationAnihilation');

         uimenu(men,LB,'--------------');
   sub = uimenu(men,LB,'Maximum Particle Number',UD,'ladder.nmax');
         uimenu(sub,LB,'1',CB,CHCR,UD,1);
         uimenu(sub,LB,'2',CB,CHCR,UD,2);
         uimenu(sub,LB,'3',CB,CHCR,UD,3);
         uimenu(sub,LB,'4',CB,CHCR,UD,4);
         uimenu(sub,LB,'5',CB,CHCR,UD,5);
         uimenu(sub,LB,'10',CB,CHCR,UD,10);
         uimenu(sub,LB,'20',CB,CHCR,UD,20);
         choice(sub,setting('ladder.nmax'));
         
   sub = uimenu(men,LB,'Eigen Frequency',UD,'ladder.omega');
         uimenu(sub,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(sub,LB,'1.0',CB,CHCR,UD,1);
         uimenu(sub,LB,'2.0',CB,CHCR,UD,2);
         uimenu(sub,LB,'5.0',CB,CHCR,UD,5);
         choice(sub,setting('ladder.omega'));   

   sub = uimenu(men,LB,'Operator Visibility',UD,'ladder.operator');
         choice(sub,{{'Visible',1},{'Transparent',0.1},...
                     {'Invisible',0}},CHCR);   
         
end

function o = CbLadder(o)   
%
   CbExecute(o,'ladderdemo');
end
   
%==========================================================================
% 4) Auxillary Functions
%==========================================================================

function [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];  VI = 'visible';
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')]; 
   MF = mfilename; 
end

%==========================================================================
   
function oo = CbExecute(o,handler)     % execute callback              
%
% Cbexecute    Execute an external handler function which dispatches
%              to the particular handler given by user data
%
   if (nargin == 2)
      o = arg(o,{handler});
   end
   
   %clc;
   oo = invoke(o);
   return
   
   clc(o);
   refresh(o,o);                       % setup current function for refresh
   butpress(obj,'CbTerminate');
  
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

   butpress(obj,'CbRefresh')
end

%==========================================================================
% Key Press Handlers
%==========================================================================
   
function CbRefresh(obj)
%
% CBREFRESH   Ignore keypress event
%
   fprintf('CbRefresh: key pressed!\n');
   profiler([]);                 % initialize profiler
   refresh(obj);
   if (option(obj,'profiler'))
      profiler;                  % display profiling information
   end
end

function CbIgnore(obj)
%
% CBIGNORE   Ignore keypress event
%
   %fprintf('CbIgnore: key pressed!\n');
end

function o = CbTerminate(o)
%
% CBTERMINATE   Set termination flag on keypress event
%
   %fprintf('CbTerminate: key pressed!\n');
   terminate(smart);
   butpress(obj,'CbRefresh');    % continue next keypress with refresh
end
   
function o = Profiler(o)               % Show Profiling Info           
   o.profiler;
end
