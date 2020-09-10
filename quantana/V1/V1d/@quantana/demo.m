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
   MenuSetupQuons(obj);
   MenuSetupHarmonic(obj);
   MenuSetupFreeParticle(obj);
   MenuSetupBions(obj);
   MenuSetupScattering(obj);
   MenuSetupLadder(obj);

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
   default('profiler',0);

   default('global.size',50);        % size of operators & states
   default('global.xmin',-a);        % minimum x coordinate
   default('global.xmax',+a);        % maximum x coordinate
   default('global.ymin',-a);        % minimum y coordinate
   default('global.ymax',+a);        % maximum y coordinate
   default('global.zmin',-a);        % minimum z coordinate
   default('global.zmax',+a);        % maximum z coordinate
   default('global.tmin', 0);        % minimum t coordinate
   default('global.tmax',+a);        % maximum t coordinate
   default('global.dt',0.1);         % time interval
   default('wing.multi',1);          % number of wings in wing plot
   default('wing.ripple',0);         % ripple of wing plot
   default('wing.transparency',0.8); % transparency of wing plot

   men = mount(obj,'<main>',LB,'View');
   sub = uimenu(men,LB,'Profiling');
   itm = uimenu(sub,LB,'Profiler on/off',CB,CHKR,UD,'profiler');
         check(itm,setting('profiler'));
         uimenu(sub,LB,'Profiling Info',CB,call('profiler'));

         uimenu(men,LB,'Standard Menues',CB,call('CbStdMenu'));
         uimenu(men,LB,'Tool Bar',CB,call('CbToolBar'));
         uimenu(men,LB,'Grid on/off',CB,'grid;');
         uimenu(men,LB,'Clear Sceene',CB,'sceene(quantana);');
         uimenu(men,LB,'Spinning',CB,'camera spinning;');
         uimenu(men,LB,'Background dark/bright',CB,call('CbBackground'));
         uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');
         uimenu(men,LB,'--------------------');
         
   sub = uimenu(men,LB,'Wings',UD,'wing.multi');
         uimenu(sub,LB,'1 Wing',CB,CHCR,UD,1);
         uimenu(sub,LB,'2 Wings',CB,CHCR,UD,2);
         uimenu(sub,LB,'3 Wings',CB,CHCR,UD,3);
         uimenu(sub,LB,'4 Wings',CB,CHCR,UD,4);
         uimenu(sub,LB,'5 Wings',CB,CHCR,UD,5);
         choice(sub,setting('wing.multi'));

   sub = uimenu(men,LB,'Ripple',UD,'wing.ripple');
         uimenu(sub,LB,'0.0',CB,CHCR,UD,0.0);
         uimenu(sub,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(sub,LB,'0.2',CB,CHCR,UD,0.2);
         uimenu(sub,LB,'0.3',CB,CHCR,UD,0.3);
         uimenu(sub,LB,'0.4',CB,CHCR,UD,0.4);
         uimenu(sub,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(sub,LB,'0.6',CB,CHCR,UD,0.6);
         uimenu(sub,LB,'0.7',CB,CHCR,UD,0.7);
         uimenu(sub,LB,'0.8',CB,CHCR,UD,0.8);
         uimenu(sub,LB,'0.9',CB,CHCR,UD,0.9);
         choice(sub,setting('wing.ripple'));

   sub = uimenu(men,LB,'Transparency',UD,'wing.transparency');
         uimenu(sub,LB,'0.0',CB,CHCR,UD,0.0);
         uimenu(sub,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(sub,LB,'0.2',CB,CHCR,UD,0.2);
         uimenu(sub,LB,'0.3',CB,CHCR,UD,0.3);
         uimenu(sub,LB,'0.4',CB,CHCR,UD,0.4);
         uimenu(sub,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(sub,LB,'0.6',CB,CHCR,UD,0.6);
         uimenu(sub,LB,'0.7',CB,CHCR,UD,0.7);
         uimenu(sub,LB,'0.8',CB,CHCR,UD,0.8);
         uimenu(sub,LB,'0.9',CB,CHCR,UD,0.9);
         uimenu(sub,LB,'1.0',CB,CHCR,UD,1.0);
         choice(sub,setting('wing.transparency'));

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
   itm = gcbo;                          % get menu item handle
   toolbar = get(gcf,'toolbar');        % get current toolbar status
   if strcmp(get(itm,'checked'),'on')
      set(gcf,'menubar','none');
      set(itm,'checked','off');
   else
      set(gcf,'menubar','figure');
      set(itm,'checked','on');
   end
   set(gcf,'toolbar',toolbar);          % restore toolbar status
   return
       
function CbToolBar(obj)  % switch on icon tool bar
%
   itm = gcbo;   % get menu item handle
   if strcmp(get(itm,'checked'),'on')
      set(gcf,'toolbar','none');
      set(itm,'checked','off');
   else
      set(gcf,'toolbar','figure');
      set(itm,'checked','on');
   end
   return
   
%==========================================================================
% Basics Menu
%==========================================================================

function MenuSetupBasics(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('pale.m',2);   % number of segments along pale (mp = 10)
   default('pale.n',6);   % number of segments around pale (np = 10)
   default('pale.t',0.8);  % transparency (tp = 0.8)

   men = mount(obj,'<main>',LB,'Basics');
   sub = uimenu(men,LB,'Camera');
         uimenu(sub,LB,'Zoom',CB,call('CbBasics'),UD,'CbZoom');
         uimenu(sub,LB,'Spin',CB,call('CbBasics'),UD,'CbSpin');
         uimenu(sub,LB,'Spin & Zoom',CB,call('CbBasics'),UD,'CbSpinZoom');
   sub = uimenu(men,LB,'Phase Colors');
         uimenu(sub,LB,'Phase Colors (Single)',CB,call('CbBasics'),UD,'CbPhaseColors');
         uimenu(sub,LB,'Phase Colors (Multi)',CB,call('CbBasics'),UD,'CbMultiColors');
   sub = uimenu(men,LB,'Color Maps');
         uimenu(sub,LB,'Fire Color Map',CB,call('CbBasics'),UD,'CbFireCmap');
         uimenu(sub,LB,'Alpha Color Map',CB,call('CbBasics'),UD,'CbAlphaCmap');
         uimenu(sub,LB,'Phase Color Map',CB,call('CbBasics'),UD,'CbPhaseCmap');
         uimenu(sub,LB,'Complex Color Map',CB,call('CbBasics'),UD,'CbComplexCmap');
   sub = uimenu(men,LB,'3D Visualization');
         uimenu(sub,LB,'3D Tube Visualization',CB,call('CbBasics'),UD,'Cb3DTube');
         uimenu(sub,LB,'3D Wing Visualization',CB,call('CbBasics'),UD,'Cb3DWing');
         uimenu(sub,LB,'3D Pale Visualization',CB,call('CbBasics'),UD,'Cb3DPale');
         
   sub = uimenu(men,LB,'---------------------');
   sub = uimenu(men,LB,'3D Matlab Basics');
         uimenu(sub,LB,'Transparency',CB,call('CbMatlab'),UD,'transpdemo');
         
         uimenu(men,LB,'Planck Ball',CB,call('CbBlackBody'),UD,'CbPlanckBall');

   sub = uimenu(men,LB,'---------------------');
         uimenu(men,LB,'Infinite Waves (1D)',CB,call('CbSchroed'),UD,'CbInfWaves1D');
         uimenu(men,LB,'Infinite Waves (1P)',CB,call('CbSchroed'),UD,'CbInfWaves1P');
   return

function CbBasics(obj)   
%
   CbExecute(obj,'basics');
   return

function CbMatlab(obj)   % execute a Matlab demo
%
   keypress(obj,'CbRefresh');    % continue next keypress with refresh
   cmd = arg(obj);
   eval(cmd);
   return

function CbSchroed(obj)   
%
   CbExecute(obj,'schroedinger');
   return

function CbBlackBody(obj)   
%
   CbExecute(obj,'blackbody');
   return
   
%==========================================================================
% Quons Menu
%==========================================================================

function MenuSetupQuons(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
   
   default('quon.center',0.0);    % center of gaussian wave packet
%            
   men = mount(obj,'<main>',LB,'Quons');
   sub = uimenu(men,LB,'Particle in a Box');
         uimenu(sub,LB,'Eigen functions',CB,call('CbQuons'),UD,'CbPiBoxEigenFunctions');
         uimenu(sub,LB,'Gaussian Wave Packet',CB,call('CbQuons'),UD,'CbPiBoxGaussian');
         
         
   sub = uimenu(men,LB,'--------------------');
         
   sub = uimenu(men,LB,'Center',UD,'quon.center');
         uimenu(sub,LB,'0.0',CB,CHCR,UD,0.0);
         uimenu(sub,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(sub,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(sub,LB,'1.0',CB,CHCR,UD,1.0);
         uimenu(sub,LB,'2.5',CB,CHCR,UD,2.5);
         choice(sub,setting('quon.center'));   

   return

function CbQuons(obj)   
%
   profiler([]);
   CbExecute(obj,'quondemo');
   if (option(obj,'profiler')) profiler; end
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
   default('harmonic.modes',[0 0]);         % activated modes
   default('harmonic.field',0.5);           % field strength
   default('harmonic.omega',1.0);           % field frequency
   default('harmonic.pulse',1e99);          % pulse width for external force
   default('harmonic.pseudo',1.0);          % pseudo factor
   default('harmonic.static',0);            % static study

   men = mount(obj,'<main>',LB,'Harmonic');
   sub = uimenu(men,LB,'Basics');
         uimenu(sub,LB,'Energy Levels',CB,call('CbHarmonic'),UD,'CbEnergyLevels');
         uimenu(sub,LB,'Eigen Functions',CB,call('CbHarmonic'),UD,'CbEigenFuncs');
         uimenu(sub,LB,'Eigen Oscillations',CB,call('CbHarmonic'),UD,'CbEigenOscis');

   sub = uimenu(men,LB,'Eigen Oscillations');
         uimenu(sub,LB,'3D Eigen Oscillations',CB,call('CbHarmonic'),UD,'Cb3DEigenOscis');
   
   sub = uimenu(men,LB,'Superposition');
         uimenu(sub,LB,'Superposition |0>+|1>',CB,call('CbHarmonic'),UD,'CbSuper1');
         uimenu(sub,LB,'Superposition |0>+|1>+|2>',CB,call('CbHarmonic'),UD,'CbSuper2');
         
   sub = uimenu(men,LB,'Coherent State');
         uimenu(sub,LB,'Coherent Oscillation',CB,call('CbHarmonic'),UD,'CbCoherent');
         uimenu(sub,LB,'Coherent Speedup',CB,call('CbHarmonic'),UD,'CbCoherentSpeedup');
         
   itm = uimenu(sub,LB,'Coherence Number',UD,'harmonic.N');
         uimenu(itm,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(itm,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(itm,LB,'1',CB,CHCR,UD,1);
         uimenu(itm,LB,'3',CB,CHCR,UD,3);
         uimenu(itm,LB,'10',CB,CHCR,UD,10);
         uimenu(itm,LB,'25',CB,CHCR,UD,25);
         uimenu(itm,LB,'50',CB,CHCR,UD,50);
         uimenu(itm,LB,'75',CB,CHCR,UD,75);
         uimenu(itm,LB,'100',CB,CHCR,UD,100);
         choice(itm,setting('harmonic.N'));   

   sub = uimenu(men,LB,'Pulse Field');
         uimenu(sub,LB,'External Pulse Field',CB,call('CbHarmonic'),UD,'CbPulseField');
         uimenu(sub,LB,'Analysis',CB,call('CbHarmonic'),UD,'CbPulseAnalysis');

   sub = uimenu(men,LB,'Harmonic Field');
         uimenu(sub,LB,'External Harmonic Field',CB,call('CbHarmonic'),UD,'CbHarmonicField');
         uimenu(sub,LB,'Analysis',CB,call('CbHarmonic'),UD,'CbHarmonicAnalysis');

         uimenu(men,LB,'---------------------');
         
   sub = uimenu(men,LB,'Oscillator Type',UD,'harmonic.pseudo');
         uimenu(sub,LB,'Harmonic',CB,CHCR,UD,1);
         uimenu(sub,LB,'Pseudo 1 (q=1.1)',CB,CHCR,UD,1.1);
         uimenu(sub,LB,'Pseudo 2 (q=1.2)',CB,CHCR,UD,1.2);
         uimenu(sub,LB,'Pseudo 3 (q=1.5)',CB,CHCR,UD,1.5);
         uimenu(sub,LB,'Pseudo 4 (q=2.0)',CB,CHCR,UD,2.0);
         choice(sub,setting('harmonic.pseudo'));   

   sub = uimenu(men,LB,'Active Modes',UD,'harmonic.modes');
         uimenu(sub,LB,'[0]',CB,CHCR,UD,[0 0]);
         uimenu(sub,LB,'[1]',CB,CHCR,UD,[1 1]);
         uimenu(sub,LB,'[2]',CB,CHCR,UD,[2 2]);
         uimenu(sub,LB,'[0 1]',CB,CHCR,UD,[0 1]);
         uimenu(sub,LB,'[0 2]',CB,CHCR,UD,[0 2]);
         uimenu(sub,LB,'[1 2]',CB,CHCR,UD,[1 2]);
         choice(sub,setting('harmonic.modes'));   
         
   sub = uimenu(men,LB,'Field Strength',UD,'harmonic.field');
         choice(sub,[0.1:0.1:0.4, 0.5:0.5:5],CHCR);

   sub = uimenu(men,LB,'Field Frequency',UD,'harmonic.omega');
         choice(sub,[0:0.1:0.5, 1, 1.48, 1.5:0.5:4, 4.19, 4.5 5],CHCR);

   sub = uimenu(men,LB,'Pulse Width',UD,'harmonic.pulse');
         choice(sub,[0:0.5:5, 1e99],CHCR);

   sub = uimenu(men,LB,'Animation Speed',UD,'harmonic.speed');
         uimenu(sub,LB,'Slow',CB,CHCR,UD,1);
         uimenu(sub,LB,'Medium',CB,CHCR,UD,2);
         uimenu(sub,LB,'Fast',CB,CHCR,UD,3);
         choice(sub,setting('harmonic.speed'));   

   sub = uimenu(men,LB,'Static',CB,CHKR,UD,'harmonic.static');
         check(sub,setting('harmonic.static'));   
         
   sub = uimenu(men,LB,'Coloring',UD,'harmonic.coloring');
         uimenu(sub,LB,'Unicolor',CB,CHCR,UD,'uni');
         uimenu(sub,LB,'Multicolor',CB,CHCR,UD,'multi');
         choice(sub,setting('harmonic.coloring'));
         
   return         
   
   
function CbHarmonic(obj)   
%
   CbExecute(obj,'harmosc');
   return
   
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
   return         

   
function CbFree(obj)   
%
   CbExecute(obj,'freepart');
   return
   
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
   return

function CbBions(obj)   
%
   CbExecute(obj,'biondemo');
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
% Ladder Menu
%==========================================================================

function MenuSetupLadder(obj)
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

   sub = uimenu(men,LB,'Operator Visibility',CB,CHKR,UD,'ladder.operator');
         check(sub,setting('ladder.operator'));         
         
   return

function CbLadder(obj)   
%
   CbExecute(obj,'ladderdemo');
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
   profiler([]);                 % initialize profiler
   refresh(obj);
   if (option(obj,'profiler'))
      profiler;                  % display profiling information
   end
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
   keypress(obj,'CbRefresh');    % continue next keypress with refresh
   return
   
   
%==========================================================================
   
% eof