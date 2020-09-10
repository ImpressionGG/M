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
%        See also: CUK, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,@Cost,...
                   @StudyB1,@StudyB2,@StudyB3,@StudyB4,...
                   @StudyC1,@StudyC2,@StudyC3,@StudyC4,...
                   @StudyH1,@StudyH2,@StudyH3,@StudyH4,@StudyH5,...
                   @StudyP1L,@StudyP2L,@StudyP3L,@StudyP4L,@PhaseCutZoom,...
                   @Simulation,@SimuPR,...
                   @StudyPR1,@StudyPR2,@StudyPR3,@StudyPR4,...
                   @StudyP1LR,@StudyP2LR,@StudyP3LR,@StudyP4LR,...
                   @SimuCapa,@SettingC1,...
                   @SimuBP1,@SimuBP2,@SettingBP1,@SettingBP2,...
                   @SimuBPA,@SimuBPB,@SimuBPC,...
                   @SettingBPA,@SettingBPB,@SettingBPC,...
                   @SimuKalman1,@SimuKalman2,@SettingK1,@SettingK2,...
                   @SettingH1,@SettingH2,@SettingH3,@SettingH4);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   Register(o);
   
   setting(o,{'study.zoom',false});

   oo = mhead(o,'Study');
   ooo = mitem(oo,'Simulation',{@invoke,mfilename,'Simulation'});
   ooo = SimulationParameters(oo);
   
   ooo = mitem(oo,'-');
   ooo = ConverterMenu(oo);            % Add Converter Menu
   
   ooo = mitem(oo,'-');
   ooo = BuckMenu(oo);                 % Add Buck Converter Menu
   ooo = CukMenu(oo);                  % Add Cuk Menu
   ooo = HuckMenu(oo);                 % Add Huck Menu
   ooo = PhaseCutMenu(oo);             % Add Phase Cut R Converter Menu
   ooo = CapaMenu(oo);                 % Add Capacity Divider Menu
   ooo = BoostMenu(oo);                % Add Boost PSU Menu
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'buck'));             % register 'buck' configuration
   Config(type(o,'cuk'));              % register 'cuk' configuration
   Config(type(o,'huck'));             % register 'huck' configuration
   Config(type(o,'pcut'));             % register 'pcut' configuration
   Config(type(o,'capa'));             % register 'capa' configuration
   Config(type(o,'boost'));           % register 'boost' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Signal(o)                 % Study Specific Signal Menu    
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   switch active(o);                   % depending on active type
      case {'cuk','huck','buck','pcut'}
         oo = mitem(o,'I',{@Config},'I');
         oo = mitem(o,'U',{@Config},'U');
         oo = mitem(o,'I/U',{@Config},'UI');
         oo = mitem(o,'-');
         oo = mitem(o,'All',{@Config},'All');
      case {'capa'}
         oo = mitem(o,'I',{@Config},'I');
         oo = mitem(o,'U',{@Config},'U');
         oo = mitem(o,'I/U',{@Config},'UI');
      case {'boost'}
         oo = mitem(o,'Grid',{@Config},'Grid');
         oo = mitem(o,'Control',{@Config},'Control');
         oo = mitem(o,'-');
         oo = mitem(o,'Triac',{@Config},'Triac');
         oo = mitem(o,'Boost',{@Config},'Boost');
         oo = mitem(o,'-');
         oo = mitem(o,'Ug',{@Config},'Ug');
         oo = mitem(o,'Up',{@Config},'Up');
         oo = mitem(o,'Ur',{@Config},'Ur');
         oo = mitem(o,'S',{@Config},'S');
         oo = mitem(o,'E',{@Config},'E');
   end
end
function o = Config(o)                 % Install a Configuration       
%
% CONFIG Setup a configuration
%
%           Config(type(o,'mytype'))   % register a type specific config
%           oo = Config(arg(o,{'XY'})  % change configuration
%
   mode = o.either(arg(o,1),'Default');% get mode or provide default

   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = subplot(o,'Signal',mode);       % set signal mode   
   o = category(o,1,[],[],'V');        % setup category 1
   o = category(o,2,[],[],'A');        % setup category 2
   o = category(o,3,[],[],'V');        % setup category 3
   o = category(o,4,[],[],'ms');       % setup category 4
   o = category(o,5,0.1,[],'V');       % setup category 5 (voltage error)
   o = category(o,6,50,[],'V');        % setup category 6 (uncertainty)
     
   switch type(o)
      case 'buck'
         switch mode
            case {'U'}
               o = config(o,'u2',{1,'b',1});
               o = config(o,'us',{2,'bk',3});
            case {'I'}
               o = config(o,'i1',{1,'r',2});
            case {'UI','Default'}
               o = config(o,'u2',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'us',{3,'bk',1});
            case {'All'}
               o = config(o,'u2',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'im',{2,'r:',2});
               o = config(o,'us',{3,'bk',3});
         end
      case 'cuk'
         switch mode
            case {'I'}
               o = config(o,'i1',{1,'r',2});
               o = config(o,'i2',{1,'m',2});
            case {'U'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'us',{2,'bk',3});
               o = config(o,'uz',{2,'c',2});
            case {'UI','Default'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'i2',{2,'m',2});
               o = config(o,'uz',{3,'ck',3});
               o = config(o,'us',{3,'bk',3});
            case {'All'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'i2',{3,'m',2});
               o = config(o,'us',{4,'bk',3});
               o = config(o,'uz',{4,'ck',3});
         end
      case 'huck'
         switch mode
            case {'I'}
               o = config(o,'il',{1,'r',1});
            case {'U'}
               o = config(o,'uc',{1,'b',2});
               o = config(o,'us',{2,'bk',3});
            case {'UI','Default'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'il',{2,'r',2});
            case {'All'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'il',{2,'r',2});
               o = config(o,'im',{2,'r:',2});
               o = config(o,'us',{3,'bk',3});
         end
      case 'pcut'
         switch mode
            case {'U'}
               o = config(o,'uz',{1,'bw',1});
               o = config(o,'uc',{1,'b',1});
               o = config(o,'us',{2,'bk',3});
            case {'I'}
               o = config(o,'i1',{1,'r',2});
            case {'UI','Default'}
               o = config(o,'uz',{1,'bw',1});
               o = config(o,'uc',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'us',{3,'bk',1});
            case {'All'}
               o = config(o,'uc',{1,'b',1});
               o = config(o,'i1',{2,'r',2});
               o = config(o,'im',{2,'r:',2});
               o = config(o,'us',{3,'bk',3});
         end
      case 'capa'
         switch mode
            case {'U'}
               o = config(o,'u1',{1,'bw',3});
               o = config(o,'u2',{1,'bk',3});
               o = config(o,'u',{1,'b',3});
            case {'I'}
               o = config(o,'i',{1,'r',2});
               o = config(o,'i1',{2,'m',2});
               o = config(o,'i2',{2,'ry',2});
            case {'UI','Default'}
               o = subplot(o,'Layout',2);   % layout with 1 subplot column   
               o = config(o,'u1',{1,'bw',3});
               o = config(o,'u2',{1,'bk',3});
               o = config(o,'u', {2,'b',3});
               o = config(o,'i1',{3,'m',2});
               o = config(o,'i2',{3,'ry',2});
               o = config(o,'i', {4,'r',2});
         end
      case 'boost'
         o = category(o,4,[-0.1 0.1],[],'ms');   % setup category 4
         switch mode
            case {'Grid','Default'}
               o = subplot(o,'Layout',2);        % 2 subplot columns   
               o = config(o,'up',{1,'bk.-',3});
               o = config(o,'ur',{1,'m',3});
               o = config(o,'p',{2,'ry',6});
               o = config(o,'s', {3,'g',4});
               o = config(o,'e', {4,'r',5});
               mode = 'Grid';
            case {'Control'}
               o = subplot(o,'Layout',2);        % 2 subplot columns   
               o = config(o,'u',{1,'b',3});      % grid voltage U
               o = config(o,'q',{1,'ryk',3});    % output Q
               o = config(o,'g',{1,'gk',3});     % gate
               o = config(o,'ug',{2,'bw',3});    % grid voltage U
               o = config(o,'b',{2,'br',3});     % boost signal
               o = config(o,'s', {3,'g',4});
               o = config(o,'e', {4,'r',5});
            case {'Triac'}
               o = config(o,'u',{1,'b',3});      % grid voltage U
               o = config(o,'q',{1,'ryk',3});    % output Q
               o = config(o,'g',{1,'gk',3});     % gate
            case {'Boost'}
               o = config(o,'ug',{1,'bw',3});    % grid voltage U
               o = config(o,'b',{1,'br',3});     % boost signal
            case {'Ug'}
               o = config(o,'ug',{1,'bw',3});
            case {'Up'}
               o = config(o,'up',{1,'bk.-',3});
            case {'Ur'}
               o = config(o,'ur',{1,'m',3});
            case {'S'}
               o = config(o,'s',{1,'g',4});
            case {'E'}
               o = config(o,'e',{1,'r',5});
         end
   end
   change(o,'Config');
end

%==========================================================================
% Study
%==========================================================================

function oo = ConverterMenu(o)         % Submenu Converter             
   setting(o,{'study.mode'},'PhaseCutRConverter');
   setting(o,{'study.repeats'},1);           

   oo = mitem(o,'Converter',{},'study.mode');
   choice(oo,{{'Buck Oscillation','BuckOscillation'},...
               {'Buck Converter','BuckConverter'},...
               {'Advanced Buck Converter','AdvancedBuckConverter'},...
               {},...
               {'Phase Cut R','PhaseCutRConverter'},...
               {'Phase Cut LR','PhaseCutLRConverter'},...
               {'Phase Cut L','PhaseCutLConverter'},...
               {},...
               {'Capacitive Divider','CapaConverter'},...
               {},...
               {'Boost & Phase Angle Control 1','Boost & Pac 1'},...
               {'Boost & Phase Angle Control 2','Boost & Pac 2'},...
               {'Boost & Phase Angle Control A','Boost & Pac A'},...
               {'Boost & Phase Angle Control B','Boost & Pac B'},...
               {'Boost & Phase Angle Control C','Boost & Pac C'},...
               {'Boost TI Kalman','Time Invariant Kalman'},...
               {'Boost TV Kalman','Time Variant Kalman'},...
              },{@Simulation});
end
function oo = Simulation(o,mode)       % Converter Type Simulation     
   refresh(o,o);                       % come back here for refresh
   if (nargin == 2)
      choice(o,'study.mode',mode);
      o = pull(o);                     % refresh object
   end
   mode = opt(o,'study.mode');
   switch mode
      case 'BuckOscillation'
         oo = StudyB1(o);
      case 'BuckConverter'
         oo = StudyB2(o);
      case 'AdvancedBuckConverter'
         oo = SimuB(o);
      case 'PhaseCutRConverter'
         oo = SimuPR(o);
      case 'PhaseCutRPConverter'
         oo = SimuRP(o);
      case 'CapaConverter'
         oo = SimuCapa(o);
      case 'PhaseCutLConverter'
         oo = StudyP1L(o);
      case 'Boost & Pac 1'
         oo = SimuBP1(o);
      case 'Boost & Pac 2'
         oo = SimuBP2(o);
      case 'Boost & Pac A'
         oo = SimuBPA(o);
      case 'Boost & Pac B'
         oo = SimuBPB(o);
      case 'Boost & Pac C'
         oo = SimuBPC(o);
      case 'Time Invariant Kalman'
         oo = SimuKalman1(o);
      case 'Time Variant Kalman'
         oo = SimuKalman2(o);
      otherwise
         error('bad mode!');
   end
end
function oo = SimulationParameters(o)  % Simulation Parameters         
   setting(o,{'simu.periodes'},1);
   setting(o,{'simu.T'},20);
   
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Periodes',{},'simu.periodes');
   choice(ooo,[0.1 0.2 0.3 0.4 0.5 1 2 3 4 5 10 15 20:10:50],{@Periodes});
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Tp: Periode [ms]','','simu.Tp',20); 
   ooo = Charm(oo,'Ts: Sampling Time [µs]','','simu.Ts',5); 
end
function oo = Periodes(o,N)            % Set Periodes                  
   if (nargin < 2)
      N = opt(o,'simu.periodes');
   else
      charm(o,'simu.periodes',N);
   end
   Tp = opt(o,'simu.Tp');
   T = Tp * N;
   setting(o,'simu.T',T);

   oo = Simulation(pull(o));
end

%==========================================================================
% Buck Study
%==========================================================================

function oo = BuckMenu(o)              % Buck Converter Menu           
   oo = mitem(o,'Buck');
   ooo = mitem(oo,'Buck Oscillation',{@SimuB1});
   ooo = mitem(oo,'Buck Converter',  {@SimuB2});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Buck PWM Converter (V1)',{@StudyB3});
   ooo = mitem(oo,'Buck PWM Converter (V2)',{@StudyB4});
   ooo = mitem(oo,'-');
   ooo = BuckParameters(oo);
end   
function oo = SimuB(o)                 % Buck Converter Simulation     
%
% SIMUB  Buck converter simulation
%
%        Circuit: 
%                |   +-----+    L   il              i2     
%           o--|>|---+     +--/\/\/\->--o--------o--->---o----o
%                |\o +-----+  ----->    |        |       |      
%           |           Rl      uL      |        v iC   +++   |
%           | us                       ---   C -----    | |   | u2
%           |                       Uz /Z\     -----    | |   |
%           v                           |        |      +++   v
%                                       |        |       | R2
%           o---------------------------o--------o-------o----o
%                
%        Differential Equations
%
%           u2 = min(u2,Uz)
%           i2 = u2 / R2
%           u1  =  i1*Rl      =>   i1 = u1/R1
%           uL  =  L*di1/dt   =>   di1/dt = 1/L * (us - i1*R1 - u2)
%           iC  =  C*du2/dt   =>   du2/dt = 1/C * (il - u2/R2)
%              
%           =>  di1/dt = [-R1  -1 ]/L * [i1; u2] + [1/L] * us
%           =>  du2/dt = [ 1 -1/R2]/C * [i1; u2] + [ 0 ] * us
%      
   oo = huck('buck');                  % create a 'buck' typed object
   oo = log(oo,'t','i1','u2','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');
   
   o = with(o,'buck');
   [R1,R2] = Par(o,'R1','R2');
   [C,L,Un,Uc,Uz,U0] = Par(o,'C','L','Un','Uc','Uz','U0');
   [f0,duty] = Par(o,'f0','duty');
   
      % some calculations
      
   Um = Un*sqrt(2);                    % max mains voltage
   f = 1/(2*pi*sqrt(L*C));
   T0 = 1/f0;                          % control periode

   Ac = [[-R1  -1]/L; [1 -1/R2]/C];  
   Bc = [1; 0]/L;   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
      % run the system
      
   x = [0; 0];  
   us = 0;  k = 0;  t0 = 0;
   for r = 1:ceil(T/Tp)                % for number of repeats
      oo = log(oo);                    % next repeat
      N = round(min(T,Tp)/Ts);
      t_ = zeros(1,N); i1_ = t_; u2_ = t_; us_ = t_;  
      for i = 1:N
         k = k+1;
         t = k*Ts;                     % actual time stamp
         u = Um*sin(2*pi*50*t);        % sine voltage

         x(2) = min(x(2),Uz);          % cut capacitor voltage
         y = x;                        % system output
         i1 = x(1);
         u2 = y(2);  

         us = u * (t0 <= T0*duty);
         t0 = t0 + Ts;
         if (t0 >= T0)
            t0 = 0;
         end
         
            % log variables
            
         t_(i) = t;  i1_(i) = i1;  u2_(i) = u2;  us_(i) = us; 
         
%        oo = log(oo,t,i1,u2,us);      % record log data
         x = A*x + B*us;               % state transition
      end
      oo = log(oo,t_,i1_,u2_,us_);     % record log data
   end
   
      % define as working object, provide title and plot graphics
   
   [i1,us,u2] = data(oo,'i1','us','u2');
   Q = sum(i1*Ts);  i1max = max(i1);
   usmax = max(us);  I = Uz/R2;  Iq = Q/T;  du = max(u2) - min(u2);
   P = sum(i1.*us - u2.*u2/R2)*Ts/T;
   
   oo = var(oo,'R1',R1,'R2',R2,'C',C,'L',L);
   oo = var(oo,'f',f,'f0',f0,'duty',duty,'Uz',Uz,'du',du);
   oo = var(oo,'Ts',Ts,'usmax',usmax,'i1max',i1max,'Q',Q);
   oo = var(oo,'I',I,'Iq',Iq,'P',P);
   oo = set(oo,'title',['Phase Cut R+ Converter @ ',o.now]);
   
   Plot(oo);                           % plot graphics
   Zoom(o);                            % zoom if activated
end

function o = SimuB1(o)                 % Study B1: Buck Oscillator     
%
% STUDY1 Buck oscillator
%
   oo = huck('buck');                  % create a 'buck' typed object
   oo = log(oo,'t','i1','u2','us','im');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');

   o = with(o,'buck');
   [R,C,L] = Par(o,'R','C','L');
   
   Ac = [-1/(R*C) 1/C; -1/L 0];  
   Bc = [0; 1/L];   
   [A,B] = c2d(trf,Ac,Bc,Ts);             % convert to discrete system
   
      % run the system
      
   x = [0; 0];  im = 0;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      us = 40;                         % switched voltage
      
      y = x;                           % system output
      uc = y(1);  il = y(2);  
      
      oo = log(oo,t,il,uc,us,im);      % record log data
      x = A*x + B*us;                  % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Buck Oscillation @ ',o.now]);
   oo = set(oo,'comment',{sprintf('T = %g µs',Ts*1e6),...
           sprintf('R = %g Ohm, C = %g µF, L = %g nH',R,C*1e6,L*1e9)});
   plot(oo);                           % plot graphics
end
function o = SimuB2(o)                 % Study B2: Buck Converter      
%
% STUDY2 Buck converter
%
%        Circuit:
%                        il        ir
%           o-------/\/\/\-->--o--->--o-----o
%                      L       |      |
%           |                  v ic  +++    |
%           | us           C -----   | | R  | uc
%           |                -----   | |    |
%           v                  |     +++    v
%                              |      |
%           o------------------o------o-----o
%                
%        Differential Equations
%
%           ul  =  L*dil/dt   =>   dil/dt = 1/L * (us - uc)
%           ic  =  C*duc/dt   =>   duc/dt = 1/C * (il - uc/R)
%      
%
%           [ dil/dt ]     [  0       -1/L   ]   [ il ]     [ 1/L ]
%           [        ]  =  [                 ] * [    ]  +  [     ] * us
%           [ duc/dt ]     [ 1/C    -1/(R*C) ]   [ uc ]     [  0  ]
%
   oo = huck('buck');                   % create a 'buck' typed object
   oo = log(oo,'t','i1','u2','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');

   o = with(o,'buck');
   [R,C,L] = Par(o,'R','C','L');

   Ac = [0  -1/L; 1/C  -1/(R*C)];  
   Bc = [1/L; 0];   
   [A,B] = c2d(trf,Ac,Bc,Ts);             % convert to discrete system
   
      % run the system
      
   x = [0; 0];  U = 40;
   us = U;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      
      y = x;                           % system output
      il = y(1);  uc = y(2);

      if (us > 0) && (uc > 3.3) 
         us = 0;                       % switched voltage
      elseif (us == 0) && (uc < 3)
         us = U;
      end
    
      oo = log(oo,t,il,uc,us);         % record log data
      x = A*x + B*us;                  % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Buck Converter @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),...
           sprintf('R = %g Ohm, C = %g µF, L = %g µH',R,C*1e6,L*1e6)});
   plot(oo);                           % plot graphics
end

function o = StudyB3(o)                % Buck PWM Converter V1         
   Schematics(o,'buck.png','Buck PWM (V1)');
   charm(o,'simu.Ts',1);

   charm(o,'buck.R1',0.4);
   Component(o,'R1','0.4@1/4W'); 
   charm(o,'buck.R2',100);
   Component(o,'R2','100@1/4W'); 
   charm(o,'buck.R',220);
   Component(o,'R','220@1/4W'); 

   Component(o);
   charm(o,'buck.C',300);
   Component(o,'C(1)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 

   Component(o);
   charm(o,'buck.L',100);
   %Component(o,'L(1)', '100µF@6.3V'); 

   Component(o);
   charm(o,'buck.Uz',500);
   %Component(o,'Z','Z3.3V@.3W');
   Component(o,'S','BT169H');

   charm(o,'buck.Un',230);
   charm(o,'buck.U0',5.4);
   charm(o,'buck.f0',1000);
   charm(o,'buck.duty',0.1);
   o = Simulation(o,'AdvancedBuckConverter');
end
function o = StudyB4(o)                % Buck PWM Converter V2         
   Schematics(o,'buck.png','Buck PWM (V2)');
   charm(o,'simu.Ts',1);
   
   charm(o,'buck.R1',0.4);
   Component(o,'R1','0.4@1/4W'); 
   charm(o,'buck.R2',100);
   Component(o,'R2','100@1/4W'); 
   charm(o,'buck.R',220);
   Component(o,'R','220@1/4W'); 

   Component(o);
   charm(o,'buck.C',300);
   Component(o,'C(1)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 

   Component(o);
   charm(o,'buck.L',100);
   %Component(o,'L(1)', '100µF@6.3V'); 

   Component(o);
   charm(o,'buck.Uz',500);
   %Component(o,'Z','Z3.3V@.3W');
   Component(o,'S','BT169H');

   charm(o,'buck.Un',230);
   charm(o,'buck.U0',5.4);
   charm(o,'buck.f0',10000);
   charm(o,'buck.duty',0.1);
   o = Simulation(o,'AdvancedBuckConverter');
end

function oo = BuckParameters(o)        % Buck Parameters Sub Menu      
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'R: Load Resistance [Ohm]','','buck.R',150); 
   ooo = Charm(oo,'R1: Load Resistance [Ohm]','','buck.R1',0.044); 
   ooo = Charm(oo,'R2: Load Resistance [Ohm]','','buck.R2',220); 
   ooo = Charm(oo,'C: Buck Capacitance [µF]','','buck.C',47); 
   ooo = Charm(oo,'L: Inductance [µH]','','buck.L',4.7); 
   ooo = Charm(oo,'Uz: Zener Diode [V]','','buck.Uz',3.3); 
   ooo = Charm(oo,'Un: RMS Mains Voltage [V]','','buck.Un',230); 
   ooo = Charm(oo,'U0: Initial Voltage [V]','','buck.U0',4.4); 
   ooo = Charm(oo,'f0: PWM Frequency [Hz]','','buck.f0',1000); 
   ooo = Charm(oo,'duty: PWM Duty [1]','','buck.duty',0.1); 
end

%==========================================================================
% Cuk Study
%==========================================================================

function oo = CukMenu(o);              % Cuk Menu                      
   oo = mitem(o,'Cuk');
   ooo = mitem(oo,'Cuk Principle',{@invoke,mfilename,@StudyC1});
   ooo = mitem(oo,'Cuk Converter',{@invoke,mfilename,@StudyC2});
   ooo = mitem(oo,'-');
   ooo = CukParameters(oo);
end
function o = StudyC1(o)                % Study C1: Cuk Principle       
%
% STUDYC1 Cuk principle
%
   oo = huck('cuk');                   % create a 'cuk' typed object
   oo = log(oo,'t','uc','uz','i1','i2','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'cuk');
   [Ts,R,C,Cz,L,T] = opt(o,'Ts','R','C','Cz','L','T');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;  T = T/1000;
   Cz = Cz/1e6;  L1 = L;  L2 = L;

   Ac1 = [-1/(R*C) 0 1/C 0; 0 0 1/Cz 0; -1/L1 -1/L1 0 0; 0 0 0 0]; 
   Bc1 = [0; 0; 1/L1; 0];
   [A1,B1] = c2d(trf,Ac1,Bc1,Ts);      % convert to discrete system
   
   Ac2 = [-1/(R*C) 0 0 1/C; 0 0 0 -1/Cz; 0 0 0 0; -1/L2 1/L2 0 0]; 
   Bc2 = [0; 0; 0; 0];
   [A2,B2] = c2d(trf,Ac2,Bc2,Ts);      % convert to discrete system
   
      % total capacity & max. current
      
   U = 24;
   Ctot = C*Cz/(C+Cz); 
   im = U*sqrt(Ctot/L);                   % im: max current
   
      % run the system
      
   x = [0; 0; 0; 0]; 
   us = U;  N = ceil(T/Ts);
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      
      y = x;                           % system output
      uc = y(1);  uz = y(2);  
      i1 = y(3);  i2 = y(4);

      if (us > 0) && (uc > 3.3) 
%         us = 0;                       % switched voltage
      elseif (us == 0) && (uc < 3)
%         us = U;
      end
      
      oo = log(oo,t,uc,uz,i1,i2,us);   % record log data
      if (us > 0)
         x = A1*x + B1*us;             % state transition
      else
         x = A2*x + B2*us;             % state transition
      end
   end
   
      % define as working object, provide title and plot graphics
      
   txt = sprintf('R = %g Ohm, C = %g µF, Cz = %g µF, L = %g µH',...
                  R,C*1e6,Cz*1e6,L*1e6);
   oo = set(oo,'title',['Buck Oscillation @ ',txt]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt});
   plot(oo);                           % plot graphics
end
function o = StudyC2(o)                % Study C2: Cuk Converter       
%
% STUDYC2 Cuk converter
%
   oo = huck('cuk');                   % create a 'cuk' typed object
   oo = log(oo,'t','uc','uz','i1','i2','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'cuk');
   [Ts,R,C,Cz,L1,L2,T] = opt(o,'Ts','R','C','Cz','L1','L2','T');
   [R1,R2] = opt(o,'R1','R2');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L1 = L1/1e6;  L2 = L2/1e6;
   T = T/1000;  R1 = R1/1;  R2 = R2/2;
   Cz = Cz/1e6;

   Ac1 = [-1/(R*C) 0 1/C 0; 0 0 1/Cz 0; -1/L1 -1/L1 -R1/L1 0; 0 0 0 0]; 
   Bc1 = [0; 0; 1/L1; 0];
   [A1,B1] = c2d(trf,Ac1,Bc1,Ts);      % convert to discrete system
   
   Ac2 = [-1/(R*C) 0 0 1/C; 0 0 0 -1/Cz; 0 0 0 0; -1/L2 1/L2 0 -R2/L2]; 
   Bc2 = [0; 0; 0; 0];
   [A2,B2] = c2d(trf,Ac2,Bc2,Ts);      % convert to discrete system
   
   Ac3 = [-1/(R*C) 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]; 
   Bc3 = [0; 0; 0; 0];
   [A3,B3] = c2d(trf,Ac3,Bc3,Ts);      % convert to discrete system
   
   A = {A1,A2,A3};  B = {B1,B2,B3};
   
      % total capacity & max. current
      
   U = 24;  duty = 0.3;                % duty rate
   Ctot = C*Cz/(C+Cz); 
   f0 = 1/sqrt(Ctot*L1) / (2*pi);      % eigen frequency
   im = U*sqrt(Ctot/L1);               % im: max current
   
      % run the system
      
   x = [0; 0; 0; 0]; 
   us = U;  N = ceil(T/Ts);
   state = 1;                          % start with pumping
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      
      y = x;                           % system output
      uc = y(1);  uz = y(2);  
      i1 = y(3);  i2 = y(4);

      switch state
         case 1
            if (i1 < 0)
               us = 0;  x(3) = 0;      % stop pumping & set i1 := 0  
               state = 3;
            end
         case 2
            if (i2 < 0) || (uz < 5)    % trick with uz < 1 used for R2 >>
               us = U;  x(4) = 0;      % stop transfer & set i2 := 0  
               state = 1;
            end
         case 3
            if (uc < 3.0)              % transfer condition reached?
               state = 2;
            end
      end
      
      oo = log(oo,t,uc,uz,i1,i2,us);   % record log data
      x = A{state}*x + B{state}*us;    % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   txt = sprintf('R = %g Ohm, C = %g µF, Cz = %g µF, L1 = %g µH, L2 = %g µH',...
                  R,C*1e6,Cz*1e6,L1*1e6,L2*1e6);
   oo = set(oo,'title',['Buck Oscillation @ ',txt]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt});
   plot(oo);                           % plot graphics
end
function oo = CukParameters(o)         % Cuk Parameters Sub Menu       
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'Ts: Sampling Time [µs]','','cuk.Ts',0.5); 
   ooo = Charm(oo,'R: Load Resistance [Ohm]','','cuk.R',1); 
   ooo = Charm(oo,'C: Output Capacitance [µF]','','cuk.C',100); 
   ooo = Charm(oo,'Cz: Input Capacitance [µF]','','cuk.Cz',0.1); 
   ooo = Charm(oo,'L1: Inductance [µH]','','cuk.L1',4.7); 
   ooo = Charm(oo,'R1: Inductance [Ohm]','','cuk.R1',0.3); 
   ooo = Charm(oo,'L2: Inductance [µH]','','cuk.L2',1); 
   ooo = Charm(oo,'R2: Inductance [Ohm]','','cuk.R2',0.3); 
   ooo = Charm(oo,'U: Mains RMS Voltage [V]','','cuk.U',230);
   ooo = Charm(oo,'T: Simulation Time [ms]','','cuk.T',0.2); 
end

%==========================================================================
% Huck Study
%==========================================================================

function oo = HuckMenu(o);             % Huck Menu                     
   oo = mitem(o,'Huck');
   ooo = mitem(oo,'Capacitor Load',{@invoke,mfilename,@StudyH1});
   ooo = mitem(oo,'Huck Oscillation',{@invoke,mfilename,@StudyH2});
   ooo = mitem(oo,'Huck Oscillations',{@invoke,mfilename,@StudyH3});
   ooo = mitem(oo,'Huck Pump',{@invoke,mfilename,@StudyH4});
   ooo = mitem(oo,'Huck Converter',{@invoke,mfilename,@StudyH5});
   ooo = mitem(oo,'-');
   ooo = HuckParameters(oo);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Nominal Huck Converter',{@invoke,mfilename,@SettingH1});
   ooo = mitem(oo,'4.7µH/1µF Huck Converter',{@invoke,mfilename,@SettingH2});
   ooo = mitem(oo,'4.7µH/15µH/1µF Huck Converter',{@invoke,mfilename,@SettingH3});
end

function o = StudyH1(o)                % Study H1: Capacitor Load      
%
% STUDYH1 Capacitor LOad
%
   oo = huck('huck');                    % create a 'buck' typed object
   oo = log(oo,'t','uc','il','us','im');  % setup a data log object

   % setup parameters and system matrix
      
   o = with(o,'huck');
   [Ts,R,C,L,U,f,Td,T,T0] = opt(o,'Ts','R','C','L','U','f','Td','T','T0');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;
   U = sqrt(2)*U; om = 2*pi*f;  Td = Td/1000;  T = T/1000;  T0 = T0/1000;
   N = ceil(T/Ts);
   
   Ac = [0 1/C; -1/L 0]; 
   Bc = [0; 1/L];
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
      % run the system
      
   x = [0; 0];  U = 24;
   us = U;
   im = U*sqrt(C/L);                   % im: max current
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      
      y = x;                           % system output
      uc = y(1);  il = y(2);  

      if (t >= T0)
         oo = log(oo,t,uc,il,us,im);   % record log data
      end
      x = A*x + B*us;                  % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Capacitor Load @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),...
           sprintf('R = %g Ohm, C = %g µF, L = %g nH',R,C*1e6,L*1e9)});
   plot(oo);                           % plot graphics
end
function o = StudyH2(o)                % Study H2: Huck Oscillation    
%
% STUDYH2 Mains Driven Huck Oscillation
%
   oo = huck('huck');                   % create a 'huck' typed object
   oo = log(oo,'t','uc','il','us','im'); % setup a data log object

   % setup parameters and system matrix
      
   o = with(o,'huck');
   [Ts,R,C,L,U,f,Td,T,T0] = opt(o,'Ts','R','C','L','U','f','Td','T','T0');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;
   U = sqrt(2)*U; om = 2*pi*f;  Td = Td/1000;  T = T/1000;  T0 = T0/1000;
   N = ceil(T/Ts);
   
   Ac = [0 1/C; -1/L 0]; 
   Bc = [0; 1/L];
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
      % run the system
      
   x = [0; 0]; 
   im = U*sqrt(C/L);                   % im: max current
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      us = U*sin(om*t) * Sigma(t,Td);
      
      y = x;                           % system output
      uc = y(1);  il = y(2);  

      if (t >= T0)
         oo = log(oo,t,uc,il,us,im);   % record log data
      end
      x = A*x + B*us;                  % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Huck Oscillation @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),...
           sprintf('R = %g Ohm, C = %g µF, L = %g nH',R,C*1e6,L*1e9)});
   plot(oo);                           % plot graphics
end
function o = StudyH3(o)                % Study H3: Huck Oscillations   
%
% STUDYH3 A couple of mains driven Huck oscillations
%
   oo = huck('huck');                   % create a 'huck' typed object
   oo = log(oo,'t','uc','il','us','im'); % setup a data log object

   % setup parameters and system matrix
      
   o = with(o,'huck');
   [Ts,R,C,L,U,f,Td,T,T0] = opt(o,'Ts','R','C','L','U','f','Td','T','T0');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;
   U = sqrt(2)*U; om = 2*pi*f;  Td = Td/1000;  T = T/1000;  T0 = T0/1000;
   N = ceil(T/Ts);
   
   Ac = [0 1/C; -1/L 0]; 
   Bc = [0; 1/L];
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
      % run the system
    
   for (u0 = [1.4,3,5])
      oo = log(oo);                    % next repeat
      Td = asin(u0/U)/om;              % delay time before switch
      
      x = [0; 0];
      im = U*sqrt(C/L);                % im: max current
      for k = 1:N
         t = k*Ts;                     % actual time stamp
         us = U*sin(om*t) * Sigma(t,Td);

         y = x;                        % system output
         uc = y(1);  il = y(2);  

         if (t >= T0)
            oo = log(oo,t,uc,il,us,im);% record log data
         end
         x = A*x + B*us;               % state transition
      end
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['Huck Oscillation @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),...
           sprintf('R = %g Ohm, C = %g µF, L = %g nH',R,C*1e6,L*1e9)});
   plot(oo);                           % plot graphics
end
function o = StudyH4(o)                % Study H4: Huck Pump           
%
% STUDYH4 Huck Pump
%
   oo = huck('huck');                   % create a 'huck' typed object
   oo = log(oo,'t','uc','il','us','im'); % setup a data log object

   % setup parameters and system matrix
      
   o = with(o,'huck');
   [R,C,L,RL] = opt(o,'R','C','L','RL');
   R = R/1;  C = C/1e6;  L = L/1e6;  RL = RL/1; 

   [Ts,U,Uz,I,Iz,f,Td,T,T0] = opt(o,'Ts','U','Uz','I','Iz','f','Td','T','T0');
   Ts = Ts/1e6;  Td = Td/1000;  T = T/1000;  T0 = T0/1000;
   U = sqrt(2)*U;  Uz = Uz/1;  Iz = Iz/1;  om = 2*pi*f;  I = I/1000;
   N = ceil(T/Ts);
   
   Ac = [-1/(R*C) 1/C; -1/L -RL/L]; 
   Bc = [0 -1/C; 1/L 0];
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
      % run the system
      
   x = [0; 0]; 
   im = U*sqrt(C/L);                   % im: max current
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      us = U*sin(om*t) * Sigma(t,Td);
      id = I;
      
      y = x;                           % system output
      uc = y(1);  il = y(2);  

      if (t >= T0)
         oo = log(oo,t,uc,il,us,im);   % record log data
      end
      x = A*x + B*[us;id];             % state transition
      x(1) = min(x(1),Uz);             % uc <= Uz!
%     x(2) = min(x(2),Iz);             % uc <= Uz!
   end
   
      % define as working object, provide title and plot graphics
      
   txt = sprintf('R = %g Ohm, C = %g µF, L = %g µH, RL = %g Ohm',...
                 R,C*1e6,L*1e6,RL);
   oo = set(oo,'title',['Huck Pump @ ',txt]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt});
   plot(oo);                           % plot graphics
end
function o = StudyH5(o)                % Study H5: Huck Converter      
%
% STUDYH5 Huck Converter
%
   iif = @o.iif;                       % short hand
   PUMP = 1;  LOAD = 2;  IDLE = 3;     % state definition
   
   oo = huck('cuk');                   % create a 'huck' typed object
   oo = log(oo,'t','uc','uz','i1','i2','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'huck');
   [Ts,R,C,Cz,L1,L2,T,Td] = opt(o,'Ts','R','C','Cz','L1','L2','T','Td');
   [R1,R2,f,U,U0,U1,U2,UC0,Uz] = opt(o,'R1','R2','f','U','U0','U1','U2','UC0','Uz');
   Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L1 = L1/1e6;  L2 = L2/1e6;
   T = T/1000;  Td = Td/1000;  R1 = R1/1;  R2 = R2/2; om = 2*pi*f;
   Cz = Cz/1e6;  U = U*sqrt(2);

      % PUMP dynamics
      
   Ac1 = [-1/(R*C) 0 1/C 0; 0 0 1/Cz 0; -1/L1 -1/L1 -R1/L1 0; 0 0 0 0]; 
   Bc1 = [0; 0; 1/L1; 0];
   [A1,B1] = c2d(trf,Ac1,Bc1,Ts);      % convert to discrete system
   
      % LOAD dynamics
      
   Ac2 = [-1/(R*C) 0 0 1/C; 0 0 0 -1/Cz; 0 0 0 0; -1/L2 1/L2 0 -R2/L2]; 
   Bc2 = [0; 0; 0; 0];
   [A2,B2] = c2d(trf,Ac2,Bc2,Ts);      % convert to discrete system
   
      % IDLE dynamics
      
   Ac3 = [-1/(R*C) 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]; 
   Bc3 = [0; 0; 0; 0];
   [A3,B3] = c2d(trf,Ac3,Bc3,Ts);      % convert to discrete system
   
      % setup set of dynamic matrices
      
   A = {A1,A2,A3};  B = {B1,B2,B3};
   
      % total capacity & max. current
      
   Ctot = C*Cz/(C+Cz); 
   f0 = 1/sqrt(Ctot*L1) / (2*pi);      % eigen frequency
   im = U*sqrt(Ctot/L1);               % im: max current
   
      % run the system
      
   x = [0; 0; 0; 0]; 
   N = ceil(T/Ts);
   state = IDLE;                       % start with idle state
   for k = 1:N
      t = k*Ts;                        % actual time stamp
      ui = U*sin(om*t);                % input voltage
      
      x(2) = max(0,x(2));
      y = x;                           % system output
      uc = y(1);  uz = y(2);  
      i1 = y(3);  i2 = y(4);

      feas = (U1 <= ui && ui <= U2);   % if infeasible mains voltage
      switch state
         case IDLE                     % IDLE state
            us = 0;                    % zero input voltage
            x(3) = 0;  x(4) = 0;       % zero pump & load currents
            if (feas && uz <= U0)
               state = PUMP; 
               continue
            elseif (feas && uz > U0 && uc <= UC0)
               state = LOAD; 
               continue
            end
         case PUMP                     % PUMP state
            us = min(ui,Uz);           % switch input voltage to pump
%           us = ui;
            x(4) = 0;                  % zero load current
            if (i1 < 0)                % change to CHARGE state?
               state = IDLE;           % stop pumping & set i1 := 0  
               continue  
            end
         case LOAD                     % LOAD state
            us = 0;                    % no more pumping  
            x(3) = 0;                  % zero pump current
%           if (i2 < 0) || (uz < U0)   % trick with uz < 1 used for R2 >>
            if (i2 < 0 || uz == 0)     % trick with uz < 1 used for R2 >>
               state = IDLE;           % stop loading
               continue
            end
      end
      
      oo = log(oo,t,uc,uz,i1,i2,us);   % record log data
      x = A{state}*x + B{state}*us;    % state transition
   end
   
      % define as working object, provide title and plot graphics
      
   txt = sprintf('R = %g Ohm, C = %g µF, Cz = %g µF, L1 = %g µH, L2 = %g µH',...
                  R,C*1e6,Cz*1e6,L1*1e6,L2*1e6);
   oo = set(oo,'title',['Buck Oscillation @ ',txt]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt});
   plot(oo);                           % plot graphics
end

function o = SettingH1(o)              % Standard Huck Converter       
   charm(o,'huck.R',200); 
   charm(o,'huck.C',100);
   charm(o,'huck.Cz',0.33); 

   charm(o,'huck.L',10); 
   charm(o,'huck.RL',0.05); 
   charm(o,'huck.L1',10); 
   charm(o,'huck.R1',0.05); 
   charm(o,'huck.L2',10); 
   charm(o,'huck.R2',0.05); 

   charm(o,'huck.U',230);
   charm(o,'huck.Uz',1000); 
   charm(o,'huck.I',0); 
   charm(o,'huck.Iz',1); 
   charm(o,'huck.f',50); 

   charm(o,'huck.U0',0.0);    % 3.1
   charm(o,'huck.U1',3.0);
   charm(o,'huck.U2',32);
   charm(o,'huck.UC0',3.0);   % 2.5

   charm(o,'huck.Ts',0.2); 
   charm(o,'huck.T0',0.0); 
   charm(o,'huck.Td',0.0); 
   charm(o,'huck.T',0.40); 

   o = call(pull(o),{@invoke,mfilename,@StudyH5});
end
function o = SettingH2(o)              % 4.7µH/1µF Huck Converter      
   charm(o,'huck.R',200); 
   charm(o,'huck.C',100);
   charm(o,'huck.Cz',1); 

   charm(o,'huck.L',1.0); 
   charm(o,'huck.RL',0.05); 
   charm(o,'huck.L1',4.7); 
   charm(o,'huck.R1',0.03); 
   charm(o,'huck.L2',4.7); 
   charm(o,'huck.R2',0.03); 

   charm(o,'huck.U',230);
   charm(o,'huck.Uz',1000); 
   charm(o,'huck.I',0); 
   charm(o,'huck.Iz',1); 
   charm(o,'huck.f',50); 

   charm(o,'huck.U0',0.0);    % 3.1
   charm(o,'huck.U1',3.0);
   charm(o,'huck.U2',32);
   charm(o,'huck.UC0',3.0);   % 2.5

   charm(o,'huck.Ts',0.2); 
   charm(o,'huck.T0',0.0); 
   charm(o,'huck.Td',0.0); 
   charm(o,'huck.T',0.40); 

   o = call(pull(o),{@invoke,mfilename,@StudyH5});
end
function o = SettingH3(o)              % 4.7µH/15µH/1µH Huck Converter 
   charm(o,'huck.R',200); 
   charm(o,'huck.C',100);
   charm(o,'huck.Cz',1); 

   charm(o,'huck.L',1.0); 
   charm(o,'huck.RL',0.05); 
   charm(o,'huck.L1',4.7);             % 4.7H pump inductance
   charm(o,'huck.R1',0.03); 
   charm(o,'huck.L2',15);              % 15µH instead of symmetrical 4.7µH 
   charm(o,'huck.R2',0.03); 

   charm(o,'huck.U',230);
   charm(o,'huck.Uz',7);               % 7V Zener voltage, instead of 6.5V 
   charm(o,'huck.I',0); 
   charm(o,'huck.Iz',1); 
   charm(o,'huck.f',50); 

   charm(o,'huck.U0',0.0);    % 3.1
   charm(o,'huck.U1',3.0);             % U1 = 4V starting threshold
   charm(o,'huck.U2',32);
   charm(o,'huck.UC0',3.0);   % 2.5

   charm(o,'huck.Ts',0.2); 
   charm(o,'huck.T0',0.0); 
   charm(o,'huck.Td',0.0); 
   charm(o,'huck.T',0.40); 

   o = call(pull(o),{@invoke,mfilename,@StudyH5});
end

function o = HuckParameters(o)         % Huck Parameters Sub Menu      
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'R: Load Resistance [Ohm]','','huck.R',200); 
   ooo = Charm(oo,'C: Output Capacitance [µF]','','huck.C',1); 
   ooo = Charm(oo,'Cz: Resonant Capacitance [µF]','','huck.Cz',1); 
   ooo = Charm(oo,'L: Inductance [µH]','','huck.L',4.7); 
   ooo = Charm(oo,'RL: Inductor Resistance [Ohm]','','huck.RL',0.28); 
   ooo = Charm(oo,'L1: Inductance [µH]','','huck.L1',4.7); 
   ooo = Charm(oo,'R1: Inductance [Ohm]','','huck.R1',0.3); 
   ooo = Charm(oo,'L2: Inductance [µH]','','huck.L2',1); 
   ooo = Charm(oo,'R2: Inductance [Ohm]','','huck.R2',0.3); 
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'U: Mains RMS Voltage [V]','','huck.U',230);
   ooo = Charm(oo,'Uz: Zener Voltage [V]','','huck.Uz',1000); 
   ooo = Charm(oo,'I: Load Current [mA]','','huck.I',0); 
   ooo = Charm(oo,'Iz: Zener Current [A]','','huck.Iz',1); 
   ooo = Charm(oo,'f: Mains frequency [Hz]','','huck.f',50); 
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'U0: Pumping Threshold [V]','','huck.U0',2.6);
   ooo = Charm(oo,'U1: Lower Feasible Input Voltage [V]','','huck.U1',3);
   ooo = Charm(oo,'U2: Upper Feasible Input Voltage [V]','','huck.U2',32);
   ooo = Charm(oo,'UC0: Minimum Output Voltage [V]','','huck.UC0',2.5);
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Ts: Sampling Time [µs]','','huck.Ts',0.1); 
   ooo = Charm(oo,'T0: Start Log Time [ms]','','huck.T0',0.0); 
   ooo = Charm(oo,'Td: Delay Time [ms]','','huck.Td',0.05); 
   ooo = Charm(oo,'T: Simulation Time [ms]','','huck.T',0.15); 
end

%==========================================================================
% Phase Cut Study
%==========================================================================

function o = PhaseCutMenu(o);          % Phase Cut R Converter Menu    
   oo = mitem(o,'Phase Cut');
   ooo = mitem(oo,'Phase Cut L Converter');
   oooo = mitem(ooo,'Simu with Current Settings',{@invoke,mfilename,@StudyP1L});
   oooo = mitem(ooo,'Phase Cut L-Converter (1 periode)',{@invoke,mfilename,@StudyP2L});
   oooo = mitem(ooo,'Phase Cut L-Converter (4 periodes)',{@invoke,mfilename,@StudyP3L});
   
   ooo = PhaseCutRMenu(oo);            % Add Phase Cut R Converter Menu

   ooo = mitem(oo,'Phase Cut LR-Converter');
   oooo = mitem(ooo,'Simu with Current Settings',{@invoke,mfilename,@StudyP1LR});
   oooo = mitem(ooo,'141µF/4.7µH',{@invoke,mfilename,@StudyP2LR});
   ooo = mitem(oo,'-');
   ooo = PhaseCutParameters(oo);
end

function o = StudyP1L(o)               % Phase Cut L-Converter         
%
% STUDYP1 Phase cut converter
%
%        Circuit: 
%                |         il     ir
%           o--|>|--/\/\/\-->--o--->--o-----o
%                |\o   L       |      |
%           |                  v ic  +++    |
%           | us           C -----   | | R  | uc
%           |                -----   | |    |
%           v                  |     +++    v
%                              |      |
%           o------------------o------o-----o
%                
%        Differential Equations
%
%           ul  =  L*dil/dt   =>   dil/dt = 1/L * (us - uc)
%           ic  =  C*duc/dt   =>   duc/dt = 1/C * (il - uc/R)
%      
%
%           [ dil/dt ]     [  0       -1/L   ]   [ il ]     [ 1/L ]
%           [        ]  =  [                 ] * [    ]  +  [     ] * us
%           [ duc/dt ]     [ 1/C    -1/(R*C) ]   [ uc ]     [  0  ]
%
   oo = huck('buck');                  % create a 'buck' typed object
   oo = log(oo,'t','il','uc','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'pcut');
   [T,Ts,R,C,L,Uc] = opt(o,'T','Ts','R','C','L','Uc');
   T = T/1e3;  Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;
   U = 230*sqrt(2);                    % max mains voltage
   Tp = 20e-3;                         % mains periode
   Tc = asin(Uc/U)*0.01/pi;
   f = 1/(2*pi*sqrt(L*C));

   Ac = [0  -1/L; 1/C  -1/(R*C)];  
   Bc = [1/L; 0];   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
   M = [0 0;0 1];
   [A0,B0] = c2d(trf,M*Ac*M',M*Bc,Ts); % convert to discrete system
   
      % run the system
      
   x = [0; 0];  
   us = 0;  on = false;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      u = U*sin(2*pi*50*t);            % sine voltage
      
      x(1) = max(x(1),0);              % cut negative current
      y = x;                           % system output
      il = y(1);  uc = y(2);

      phase = rem(t,Tp)/Tp;
      enable = (phase >= 0.5-Tc/Tp && phase < 0.5);
      
      if enable && ~on
         on = true;
      elseif on && (il <= 0)
         on = false;
      end
       
      if on
         us = u;
      else
         us = 0;
      end
    
      oo = log(oo,t,il,uc,us);         % record log data
      
      if on
         x = A*x + B*us;               % on state transition
      else
         x = A0*x + B0*us;             % off state transition
      end
   end
   
      % define as working object, provide title and plot graphics
   
   rd = @(x)carabull.rd(x,1);          % short hand
   Q = sum(data(oo,'il'))*Ts;  ilmax = max(data(oo,'il'));
   usmax = max(data(oo,'us'));  I = Q/T;
   txt1 = sprintf('R = %g Ohm, C = %g µF, L = %g µH, f = %g kHz, Uc = %g V, Ts = %g µs',...
                  R,C*1e6,L*1e6,rd(f/1000),Uc,Ts*1e6);
   txt2 = sprintf('usmax = %g V,  ilmax = %g A, Q = %g mAs,  I = %g mA',...
                  rd(usmax),rd(ilmax),rd(Q*1e3),rd(I*1e3));
   oo = set(oo,'title',['Phase Cut L-Converter @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt1,txt2});
   plot(oo);                           % plot graphics
   subplot(311);  xlabel(txt1);
   subplot(312);  xlabel(txt2);
   
   if opt(o,'pcut.zoom');
      PhaseCutZoom(o);
   end
end
function o = StudyP2L(o)               % Phase Cut Converter, 1xPeriode
   choice(o,'scale.xscale',1000);
   charm(o,'pcut.T',20); 
   o = StudyP1L(pull(o));
end
function o = StudyP3L(o)               % Phase Cut Converter, 4xPeriode
   charm(o,'pcut.T',80); 
   o = StudyP1L(pull(o));
end

function o = SimuP1R(o)                % Phase Cut R-Converter         
%
% STUDYP1R Phase cut converter
%
%        Circuit: 
%                |  +----+    il     ir
%           o--|>|--+    +-->--o--->--o-----o
%                |\o+----+     |      |     |
%           |         Rl       v ic  +++    |
%           | us           C -----   | | R  | uc
%           |                -----   | |    |
%           v                  |     +++    v
%                              |      |
%           o------------------o------o-----o
%                
%        Differential Equations
%
%           ul  =  il*Rl      =>   il = ul/R1 = us/R1 - uc/R1
%           ic  =  C*duc/dt   =>   duc/dt = 1/C * (il - uc/R)
%                             =>   duc/dt = 1/C * (us/R1 - uc/R1 - uc/R)
%      
%        On-State Model
%
%           [ duc/dt ] = [-1/(R*C)-1/(R1*C)] * [ uc ]  +  [(1/(R1*C)] * us
%
%        Off-State Model (il = 0)
%
%           [ duc/dt ] = [-1/(R*C)] * [ uc ]  +  [ 0 ] * us
%
   oo = huck('buck');                  % create a 'buck' typed object
   oo = log(oo,'t','il','uc','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'pcut');
   [T,Ts,R,R1,C,L,Uc,Uz] = opt(o,'T','Ts','R','R1','C','L','Uc','Uz');
   
   T = T/1e3;  Ts = Ts/1e6;  R = R/1;  R1 = R1/1;  C = C/1e6;  L = L/1e6;
   U = 230*sqrt(2);                    % max mains voltage
   Tp = 20e-3;                         % mains periode
   Tc = asin(Uc/U)*0.01/pi;
   f = 1/(2*pi*sqrt(L*C));

   Ac = [-1/(R*C)-1/(R1*C)];  
   Bc = [1/(R1*C)];   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
   Ac0 = [-1/(R*C)];  Bc0 = 0;
   [A0,B0] = c2d(trf,Ac0,Bc0,Ts);      % convert to discrete system
   
      % run the system
      
   x = [0];  
   us = 0;  on = false;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      u = U*sin(2*pi*50*t);            % sine voltage
      
      x(1) = max(x(1),0);              % cut negative current
      y = x;                           % system output
      uc = y(1);  il = max(0,(us - uc)/R1);

      phase = rem(t,Tp)/Tp;
      enable = (phase >= 0.5-Tc/Tp && phase < 0.5);
      
      if enable && ~on
         on = true;
      elseif on && (il <= 0)
         on = false;
      end
       
      if on
         us = min(u,Uz);
      else
         us = 0;
      end
    
      oo = log(oo,t,il,uc,us);         % record log data
      
      if on
         x = A*x + B*us;               % on state transition
      else
         x = A0*x + B0*us;             % off state transition
      end
   end
   
      % define as working object, provide title and plot graphics
   
   rd = @(x)carabull.rd(x,1);          % short hand
   Q = sum(data(oo,'il'))*Ts;  ilmax = max(data(oo,'il'));
   usmax = max(data(oo,'us'));  I = Q/T;
   txt1 = sprintf('R = %g Ohm, C = %g µF, R1 = %g Ohm, f = %g kHz, Uc = %g V, Uz = %g V',...
                  R,C*1e6,R1,rd(f/1000),Uc,Uz);
   txt2 = sprintf('Ts = %g s, usmax = %g V,  ilmax = %g A, Q = %g mAs,  I = %g mA',...
                  Ts*1e6,rd(usmax),rd(ilmax),rd(Q*1e3),rd(I*1e3));
   oo = set(oo,'title',['Phase Cut R-Converter @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt1,txt2});
   plot(oo);                           % plot graphics
   subplot(311);  xlabel(txt1);
   subplot(312);  xlabel(txt2);
   
   if opt(o,'pcut.zoom');
      PhaseCutZoom(o);
   end
end

function o = StudyP1LR(o)              % Phase Cut LR-Converter        
%
% STUDYP1 Phase cut converter
%
%        Circuit: 
%                |         +------+ il     ir
%           o--|>|--/\/\/\-|      |->--o--->--o-----o
%                |\o   L   +------+    |      |
%           |                 R1       v ic  +++    |
%           | us                   C -----   | | R  | uc
%           |                        -----   | |    |
%           v                          |     +++    v
%                                      |      |
%           o--------------------------o------o-----o
%                
%        Differential Equations
%
%           ul  =  L*dil/dt   =>   dil/dt = 1/L * (us - il*R1 - uc)
%           ic  =  C*duc/dt   =>   duc/dt = 1/C * (il - uc/R)
%      
%
%           [ dil/dt ]     [ -R1/L    -1/L   ]   [ il ]     [ 1/L ]
%           [        ]  =  [                 ] * [    ]  +  [     ] * us
%           [ duc/dt ]     [ 1/C    -1/(R*C) ]   [ uc ]     [  0  ]
%
   oo = huck('buck');                  % create a 'buck' typed object
   oo = log(oo,'t','il','uc','us');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'pcut');
   [T,Ts,R,R1,C,L,Uc,Uz] = opt(o,'T','Ts','R','R1','C','L','Uc','Uz');
   T = T/1e3;  Ts = Ts/1e6;  R = R/1;  C = C/1e6;  L = L/1e6;
   U = 230*sqrt(2);                    % max mains voltage
   Tp = 20e-3;                         % mains periode
   Tc = asin(Uc/U)*0.01/pi;
   f = 1/(2*pi*sqrt(L*C));

   Ac = [-R1/L -1/L; 1/C  -1/(R*C)];  
   Bc = [1/L; 0];   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
   M = [0 0;0 1];
   [A0,B0] = c2d(trf,M*Ac*M',M*Bc,Ts); % convert to discrete system
   
      % run the system
      
   x = [0; 0];  
   us = 0;  on = false;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      u = U*sin(2*pi*50*t);            % sine voltage
      
      x(1) = max(x(1),0);              % cut negative current
      y = x;                           % system output
      il = y(1);  uc = y(2);

      phase = rem(t,Tp)/Tp;
      enable = (phase >= 0.5-Tc/Tp && phase < 0.5);
      
      if enable && ~on
         on = true;
      elseif on && (il <= 0)
         on = false;
      end
       
      if on
         us = min(u,Uz);
      else
         us = 0;
      end
    
      oo = log(oo,t,il,uc,us);         % record log data
      
      if on
         x = A*x + B*us;               % on state transition
      else
         x = A0*x + B0*us;             % off state transition
      end
   end
   
      % define as working object, provide title and plot graphics
   
   rd = @(x)carabull.rd(x,1);          % short hand
   Q = sum(data(oo,'il'))*Ts;  ilmax = max(data(oo,'il'));
   usmax = max(data(oo,'us'));  I = Q/T;
   txt1 = sprintf('R = %g Ohm, C = %g µF, L = %g µH, f = %g kHz, Uc = %g V, R1 = %g Ohm',...
                  R,C*1e6,L*1e6,rd(f/1000),Uc,R1);
   txt2 = sprintf('Ts = %g µs, usmax = %g V,  ilmax = %g A, Q = %g mAs,  I = %g mA',...
                  Ts*1e6,rd(usmax),rd(ilmax),rd(Q*1e3),rd(I*1e3));
   oo = set(oo,'title',['Phase Cut LR-Converter @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt1,txt2});
   plot(oo);                           % plot graphics
   subplot(311);  xlabel(txt1);
   subplot(312);  xlabel(txt2);
   
   if opt(o,'pcut.zoom');
      PhaseCutZoom(o);
   end
end
function o = StudyP2LR(o)              % Phase Cut LR-Converter        
   choice(o,'scale.xscale',1000);
   charm(o,'pcut.L',4.7); 
   charm(o,'pcut.C',141); 
   o = StudyP1LR(pull(o));
end

%==========================================================================
% Phase Cut R Study
%==========================================================================

function o = PhaseCutRMenu(o)          % Phase Cut R Converter Submenu 
   oo = mitem(o,'Phase Cut R-Converter');
   ooo = mitem(oo,'V1: Steady Operation !!',{@StudyPR1});
   ooo = mitem(oo,'V2: Powering up !!',{@StudyPR2});
end
function o = SimuPR(o)                 % Phase Cut R Converter Simu    
%
% SIMUPR Phase cut R converter simulation
%
%        Circuit: 
%                |   +----+ il            ir      +-----+
%           o--|>|---+    +-->-o-------o-->---o---+     +---o->--o-----o
%                |\o +----+    |       |          +-----+   |    |      
%           |          Rl      |       v ic   |      R2     |   +++    |
%           | us              ---  C -----    |            ---  | | R  | uz
%           |                 /Z\    -----    | uc         /Z\  | |    |
%           v               UZ |       |      v         Uz  |   +++    v
%                              |       |                    |    |
%           o------------------o-------o------o-------------o----o-----o
%                
%        Differential Equations  (let R3 := R2 + R)
%
%           uz = min(uc*R/(R2+R),Uz)
%           ir = (uc - uz) / R2
%           u1  =  i1*Rl      =>   i1 = u1/R1 = us/R1 - uc/R1
%           ic  =  C*duc/dt   =>   duc/dt = 1/C * (il - ir)
%              
%           =>  duc/dt = 1/C * [(us - uc)/R1 - (uc - uz)/R2]
%           =>  duc/dt = -(1/R1 + 1/R2)/C * uc + [1/R1, 1/R2]/C * [us; uz]
%      
%        1) On-State Model: us > 0
%
%           uz = min(uc*R/(R2+R),Uz)
%           ir = (uc - uz) / R2
%           duc/dt = -(1/R1 + 1/R2)/C * uc  +  [1/R1, 1/R2]/C * [us; uz]
%
%        Off-State Model (il = 0) && R/(R2+r)*uc >= uz)
%
%           duc/dt = -1/(R2*C) * uc  +  [0, 1/R2]/C * [us; uz]
%
   oo = huck('pcut');                  % create a 'pcut' typed object
   oo = log(oo,'t','i1','uc','us','uz');    % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');
   
   o = with(o,'pcut');
   [R,R1,R2] = Par(o,'R','R1','R2');
   [C,L,Un,Uc,Uz,UZ,U0] = Par(o,'C','L','Un','Uc','Uz','UZ','U0');
   
      % some calculations
      
   Um = Un*sqrt(2);                    % max mains voltage
   Tc = asin(Uc/Um)*0.01/pi;
   f = 1/(2*pi*sqrt(L*C));

      % duc/dt = -(1/R1 + 1/R2)/C * uc  +  [1/(R1*C), 1/(R2*C)] * [us, uz]'

   Ac = [-1/R1-1/R2]/C;  
   Bc = [1/R1, 1/R2]/C;   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   
%           duc/dt = -1/(R2*C) * uc  +  [0, 1/R2]/C * [us, uz]'

   Ac0 = [-1/R2]/C;  Bc0 = [0, 1/R2]/C;
   [A0,B0] = c2d(trf,Ac0,Bc0,Ts);      % convert to discrete system

      % run the system
      
   x = [U0];  
   us = 0;  on = false;  k = 0;
   for r = 1:round(T/Tp)               % for number of repeats
      oo = log(oo);                    % next repeat
      N = round(min(T,Tp)/Ts);
      t_ = zeros(1,N); i1_ = t_; uc_ = t_; us_ = t_;  uz_ = t_;  
      for i = 1:N
         k = k+1;
         t = k*Ts;                     % actual time stamp
         u = Um*sin(2*pi*50*t);        % sine voltage

         x(1) = max(x(1),0);           % cut negative current
         x(1) = min(x(1),UZ);          % cut voltage larger than UZ
         y = x;                        % system output
         uc = y(1);  i1 = max(0,(us - uc)/R1);
         uz = min(uc*R/(R2+R),Uz);

         phase = rem(t,Tp)/Tp;
         enable = (phase >= 0.5-Tc/Tp && phase < 0.5);

         if (on == 0) && enable
            on = 1;
         elseif (abs(on) == 1) && (i1 <= 0)
            on = o.iif(u <= 0,0,-1);
         end

         if (on == 1)
            us = u;
         else
            us = 0;
         end

            % log variables
            
         t_(i) = t;  i1_(i) = i1;  uc_(i) = uc;  us_(i) = us;  uz_(i) = uz; 
         
         if (on == 1)
            x = A*x + B*[us;uz];       % on state transition
         else
            x = A0*x + B0*[us;uz];     % off state transition
         end
      end
      oo = log(oo,t_,i1_,uc_,us_,uz_); % record log data
   end
   
      % define as working object, provide title and plot graphics
   
   [i1,us,uz] = data(oo,'i1','us','uz');
   Q = sum(i1*Ts);  i1max = max(i1);
   usmax = max(us);  I = Uz/R;  Iq = Q/T;  du = max(uz) - min(uz);
   P = sum(i1.*us - uz.*uz/R)*Ts/T;
   
   oo = var(oo,'R',R,'R1',R1,'R2',R2,'C',C);
   oo = var(oo,'f',f,'Uc',Uc,'UZ',UZ,'Uz',Uz,'du',du);
   oo = var(oo,'Ts',Ts,'usmax',usmax,'i1max',i1max,'Q',Q);
   oo = var(oo,'I',I,'Iq',Iq,'P',P);
   oo = set(oo,'title',['Phase Cut R+ Converter @ ',o.now]);
   
   Plot(oo);                           % plot graphics
   Zoom(o);                            % zoom if activated
end
function o = StudyPR1(o)               % Phase Cut R-Converter Study 1 
   Schematics(o,'phasecutr.png','Phase Cut R (V1) - Steady Operation');
   charm(o,'simu.Ts',5);
   
   charm(o,'pcut.R1',0.4);
   Component(o,'R1','0.4@1/4W'); 
   charm(o,'pcut.R2',100);
   Component(o,'R2','100@1/4W'); 
   charm(o,'pcut.R',220);
   Component(o,'R','220@1/4W'); 

   Component(o);
   charm(o,'pcut.C',300);
   Component(o,'C(1)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 

   Component(o);
   charm(o,'pcut.UZ',6.3);
   Component(o,'Z1','Z6.3V@.3W');
   charm(o,'pcut.Uz',3.3);
   Component(o,'Z2','Z3.3V@.3W');
   Component(o,'S','BT169H');

   charm(o,'pcut.U0',5.4);
   charm(o,'pcut.Uc',12);
   o = Simulation(o,'PhaseCutRConverter');
end
function o = StudyPR2(o)               % Phase Cut R-Converter Study 2 
   Schematics(o,'phasecutr.png','Phase Cut R (V2) - Steady Operation');
   charm(o,'simu.Ts',5);
   
   charm(o,'pcut.R1',0.4);
   Component(o,'R1','0.4@1/4W'); 
   charm(o,'pcut.R2',100);
   Component(o,'R2','100@1/4W'); 
   charm(o,'pcut.R',220);
   Component(o,'R','220@1/4W'); 

   Component(o);
   charm(o,'pcut.C',300);
   Component(o,'C(1)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 
   Component(o,'C(2)', '100µF@6.3V'); 

   Component(o);
   charm(o,'pcut.UZ',6.3);
   Component(o,'Z1','Z6.3V@.3W');
   charm(o,'pcut.Uz',3.3);
   Component(o,'Z2','Z3.3V@.3W');
   Component(o,'S','BT169H');

   charm(o,'pcut.U0',0);
   charm(o,'pcut.Uc',12);
   o = Simulation(o,'PhaseCutRConverter');
end

function o = PhaseCutParameters(o)     % Phase Cut Parameters Sub Menu 
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'R: Load Resistance [Ohm]','','pcut.R',220); 
   ooo = Charm(oo,'R1: Input Resistance [Ohm]','','pcut.R1',0.4); 
   ooo = Charm(oo,'R2: Internal Resistance [Ohm]','','pcut.R2',1); 
   ooo = Charm(oo,'C: Buck Capacitance [µF]','','pcut.C',220); 
   ooo = Charm(oo,'L: Inductance [µH]','','pcut.L',47); 
   ooo = Charm(oo,'Un: RMS Mains Voltage [V]','','pcut.Un',230); 
   ooo = Charm(oo,'Uc: Cut Voltage [V]','','pcut.Uc',10); 
   ooo = Charm(oo,'UZ: Zener Voltage [V]','','pcut.UZ',6.3); 
   ooo = Charm(oo,'Uz: Zener Voltage [V]','','pcut.Uz',3.3); 
   ooo = Charm(oo,'U0: Initial Voltage [V]','','pcut.U0',4.4); 
end

%==========================================================================
% Capacitive Devider Study
%==========================================================================

function o = CapaMenu(o);              % Capacitive Devider Menu       
   oo = mitem(o,'Capacitive Devider');
   ooo = mitem(oo,'Basic Capacitive Divider',{@invoke,mfilename,@SettingC1});
   ooo = mitem(oo,'-');
   ooo = CapaParameters(oo);
end

function o = SettingC1(o)              % Simple Capacitive Divider     
   charm(o,'simu.Ts',50);
   charm(o,'capa.R',200); 
   charm(o,'capa.R0',0.1); 
   charm(o,'capa.RA',1); 
   charm(o,'capa.RB',1); 
   charm(o,'capa.C1',0.1);
   charm(o,'capa.C2',0.1); 
   charm(o,'capa.Un',230);
   o = call(pull(o),{@invoke,mfilename,@SimuCapa});
end
function o = SimuCapa(o)               % Capacitive Divider            
%
% STUDYP1R Phase cut converter
%
%        Circuit: 
%              
%           o----->-----+--------+--------+      
%           |     i     |        |        |      |
%           |          +++       v i1     |      |
%           |      RA  | |  C1 -----     \-/ D1  | u1
%           |          | |     -----     ---     |
%           |          +++       |        |      |
%           |           |        |        |      V
%           |           +--------o--------+
%           |                    |
%           |                   +++
%           | u             R0  | |
%           |                   | |
%           |                   +++
%           |                    |
%           |           +--------o--------+
%           |           |        |        |      |    
%           |          +++       v i2     |      |
%           | u        | |     -----     ---     |
%           |      RB  | |  C2 -----     /-\ D2  | u2
%           |          +++       |        |      |
%           v           |        |        |      V
%           o-----------+--------+--------+
%                
%        Differential Equations
%
%           i  =  (u - u1 - u2)/R0
%           i1 = i * (u1 < Ud) 
%           i2 = i - (u2 > -Ud) 
%           i1  =  C1*du1/dt  => du1/dt = 1/C1 * [(u - u1 - u2)/R0 - uA/RA]
%           i2  =  C2*du2/dt  => du2/dt = 1/C2 * [(u - u1 - u2)/R0 - u2/RB]
%      
%        State Model
%
%           [ du1/dt ]   [-1/(R0*C1)-1/(RA*C1) -1/(R0*C1)]   [ u1 ]  +  [1/(R0*C1)]
%           [        ] = [                               ] * [    ]  +  [         ] * u
%           [ du2/dt ]   [-1/(R0*C2) -1/(R0*C2)-1/(RB*C2)]   [ u2 ]  +  [1/(R0*C2)]
%
   oo = huck('capa');                  % create a 'capa' typed object
   oo = log(oo,'t','i','i1','i2','u','u1','u2'); % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');

   o = with(o,'capa');
   [R0,RA,RB,C1,C2,Un] = Par(o,'R0','RA','RB','C1','C2','Un');
   
   Ac = [-1/(R0*C1)-1/(RA*C1) -1/(R0*C1); -1/(R0*C2) -1/(R0*C2)-1/(RB*C2)];  
   Bc = [1/(R0*C1); 1/(R0*C2)];   
   [A,B] = c2d(trf,Ac,Bc,Ts);          % convert to discrete system
   Ud = 0.7;                           % threshold value of diode
   t0 = 0.065;                          % burst time
   
      % run the system
      
   x = [0;0];  
   f = 50;
   for k = 1:T/Ts
      t = k*Ts;                        % actual time stamp
      u = Un*sqrt(2)*sin(2*pi*f*t);    % sine voltage
      u = u + 1000*exp(-(t-t0)/0.01) * (t >= t0);

      x(1) = min(x(1),Ud);
      x(2) = max(x(2),-Ud);
      
      u1 = x(1);  u2 = x(2);
      i = (u - u1 - u2)/R0;
      i1 = i * (u1 < Ud);
      i2 = i * (u2 > -Ud);

      oo = log(oo,t,i,i1,i2,u,u1,u2);  % record log data
      
      x = A*x + B*u;                   % state transition
   end
   
      % define as working object, provide title and plot graphics
   
   rd = @(x)carabull.rd(x,1);          % short hand
   Q = sum(data(oo,'i'))*Ts;  imax = max(data(oo,'i'));
   umax = max(data(oo,'u'));  I = Q/T;
   txt1 = sprintf('R0 = %g Ohm, RA = %g MOhm, RB = %g MOhm, C1 = %g µF,  C1 = %g µF, f = %g kHz',...
                  R0,RA/1e6,RB/1e6,C1*1e6,C2*1e6,rd(f/1000));
   txt2 = sprintf('Ts = %g s, umax = %g V,  imax = %g A, Q = %g mAs,  I = %g mA',...
                  Ts*1e6,rd(umax),rd(imax),rd(Q*1e3),rd(I*1e3));
   oo = set(oo,'title',['Capacitive Divider @ ',o.now]);
   oo = set(oo,'comment',{sprintf('Ts = %g µs',Ts*1e6),txt1,txt2});
   Plot(oo);                           % plot graphics
end
function o = CapaParameters(o)         % Capa Parameters Sub Menu      
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'R: Load Resistance [Ohm]','','capa.R',200); 
   ooo = Charm(oo,'C1: Upper Capacitance [µF]','','capa.C1',0.1); 
   ooo = Charm(oo,'C2: Lower Capacitance [µF]','','capa.C2',2); 
   ooo = Charm(oo,'R0: Parasitic Resistance [Ohm]','','capa.R0',0.1); 
   ooo = Charm(oo,'RA: Discharge Resistance [MOhm]','','capa.RA',1); 
   ooo = Charm(oo,'RB: Parasitic Resistance [MOhm]','','capa.RB',1); 
   ooo = Charm(oo,'Un: RMS Mains Voltage [V]','','capa.Un',230); 
end

%==========================================================================
% Boost PSU Study
%==========================================================================

function o = BoostMenu(o)              % Boost PSU Menu                
   oo = mitem(o,'Boost PSU');
   ooo = mitem(oo,'Boost & Phase Angle Control 1',{@invoke,mfilename,@SettingBP1});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Boost & Phase Angle Control A',{@invoke,mfilename,@SettingBPA});
   ooo = mitem(oo,'Boost & Phase Angle Control B',{@invoke,mfilename,@SettingBPB});
   ooo = mitem(oo,'Boost & Phase Angle Control C',{@invoke,mfilename,@SettingBPC});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Boost & Phase Angle Control 2',{@invoke,mfilename,@SettingBP2});
   ooo = mitem(oo,'Time Invariant Kalman',{@invoke,mfilename,@SettingK1});
   ooo = mitem(oo,'Time Variant Kalman',{@invoke,mfilename,@SettingK2});
   ooo = mitem(oo,'-');
   ooo = BoostParameters(oo);
end
function o = SettingBP1(o)             % Boost & Phase Angle Control 1 
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuBP1});
end
function o = SettingBP2(o)             % Boost & Phase Angle Control 2 
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuBP2});
end
function o = SettingBPA(o)             % Boost & Phase Angle Control A 
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuBPA});
end
function o = SettingBPB(o)             % Boost & Phase Angle Control B 
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuBPB});
end
function o = SettingBPC(o)             % Boost & Phase Angle Control C 
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuBPC});
end
function o = SettingK1(o)              % Time Invariant Kalman         
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuKalman1});
end
function o = SettingK2(o)              % Time Variant Kalman           
   charm(o,'simu.Ts',1000);
   Periodes(o,10);                     % simulation of 10 periodes
   o = call(pull(o),{@invoke,mfilename,@SimuKalman2});
end

   % the most important: SimuBP1
   
function o = SimuBP1(o)                % Boost & Phase Angle Control 1 
%
% SIMUBP1 Boost & Phase Angle Control
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function Z = Log(Z,X)               % Log Data to Log Object        
   %
   % LOGGING   log data or initialize a log object
   %
   %              Z = Log(Z)           % initialize log object
   %              Z = Log(Z,X)         % log data from states X,Z
   %
      if (nargin == 1)
         oo = huck('boost');           % create a 'boost' typed object
         oo = log(oo,'t','ug','up','ur','s','e','p','u','q','b','g');
      else
         t = Z.scheduler.t;            % actual simulation time
         ug = X.grid.ug;               % noise free grid voltage
         up = X.grid.up;               % sensed line voltage
         s = PhaseError(X);            % phase estimation error [ms]
         p = X.kalman.p;               % uncertainty indicator
         ur = X.kalman.q;              % reconstructed grid voltage
         e = ur - ug;                  % observation error
         u = X.grid.u;                 % 230V RMS grid voltage
         q = X.triac.out;              % Triac controlled output
         b = X.boost.b;                % boost signal
         g = X.triac.gate * 100;       % triac gate signal (scaled *100) 
         
            % log data to log object
            
         oo = log(Z.oo,t,ug,up,ur,s,e,p,u,q,b,g);   % record log data
      end
      Z.oo = oo;                       % store log object in scheduler state
   end
   function X = InitState(o);          % Initialize State              
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      
      X.grid.f = f;                    % frequency (50 Hz)
      X.grid.df = df;                  % frequency deviation (0 or 1 Hz)
      X.grid.Un = Un;                  % nominal RMS voltage (230 V)
      X.grid.T0 = T0;                  % time shift for simulation (2 ms)
      X.grid.S = S;                    % Voltage step down factor (0.0075)
      
         % init system for grid voltage generation
         
      x0 = [0;Un*sqrt(2)];             % nominal grid (system) init state
      X.grid.x = System(X,f,-T0) * x0; % actual grid (system) init state  
      X.grid.ug = 0;                   % init noise free grid voltage
      X.grid.up = 0;                   % init sensed line voltage
      X.grid.u = 0;                    % init 230V RMS voltage
      X.grid.phi = NaN;                % init grid phase
      
         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
      
      X.stochastics.sigx = sigx;       % initial uncertainty (100 V)
      X.stochastics.sigw = sigw;       % process noise (0.5 V)
      X.stochastics.sigv = sigv;       % measurement noise (0.1 V)
      
      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      X.kalman.Q = Q;                  % Q matrix for Kalman Filter
      X.kalman.R = R;                  % R matrix for Kalman Filter

         % init Kalman filter state
   
      X.kalman.z = [0;1];              % init Kalman filter system state
      X.kalman.P = eye(2,2) * sigx^2;  % initial error covariance matrix
     
      X.kalman.q = 0;                  % init reconstructed voltage
      X.kalman.p = 0;                  % init uncertainty indicator
      X.kalman.phi = NaN;              % init estimated phase
      
         % init phase angle control
         
      dphi = 5;                        % pulse with for gate signal [°]
      phi = Par(o,'phi');              % Triac ignition phase [°]

      X.triac.dphi = dphi*pi/180;      % init pulse width in radians
      X.triac.phi1 = phi*pi/180;       % init ignition angle in radians
      X.triac.phi2 = pi-2*dphi*pi/180; % max ignition angle in radians
      X.triac.out = 0;                 % init Triac output
      X.triac.gate = 0;                % init Triac gate signal (inactive)
      X.triac.state = 0;               % init Triac state (not conductive)
    
         % init boost controil
         
      X.boost.b = 0;                   % init boost signal (inactive)
      X.boost.enable = 0;              % initially boost not enabled
      X.boost.phi1 = 45 * pi/180;      % angle to switch boost signal on
      X.boost.phi2 = 135 * pi/180;     % angle to switch boost signal off
      
         % init scheduler
         
      X.scheduler.agenda = {};         % no timer events in scheduler
      X.scheduler.t = 0;               % init scheduler time
   end
   function [A,B,C] = System(X,f,T)    % Get System Matrices           
      S = X.grid.S;                    % voltage step down factor
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: step down factor V-measurement
   end
   function s = PhaseError(X)          % Phase Estimation Error [ms]   
      periode = 1 / X.grid.f;          % grid periode
      phig = X.grid.phi;               % phase of grid
      phik = X.kalman.phi;             % phase estimated by kalman filter
      om = 2*pi*X.grid.f;              % circular frequency
      s = (phik-phig)/om;              % phase error
      while (s < periode/2)
         s = s + periode;              % map s to interval [0,periode)
      end
      while (s >= periode/2)
         s = s - periode;              % map s to interval [0,periode)
      end
      s = s * 1000;                    % phase error converted to miisec
   end

   function Z = InitScheduler(o)       % Init Scheduler State (Z)      
      o = with(o,'simu');
      [T,Ts] = Par(o,'T','Ts');        % get timing (simulation) parameters

      Z.scheduler.t = 0;               % init actual simulation time
      Z.scheduler.T = T;               % total simulation time
      Z.scheduler.Ts = Ts;             % nominal sample time
      Z.scheduler.agenda = {};         % init agenda (empty at beginning)

         % setup timing jitter stochastics from menu settings
         
      o = with(o,'boost');
      sigj = Par(o,'sigj');            % jitter stochastics for timing

      Z.stochastics.sigj = sigj;       % timing jitter (0.1 = 10%)
      
         % init log object
         
      Z = Log(Z);                      % init log object
   end
   function Agenda(Z)                  % Print Agenda (for Debug)      
      agenda = Z.scheduler.agenda;
      fprintf('Agenda (t = %6.2f ms)\n',1000*Z.scheduler.t);
      for (i=1:length(agenda))
         event = agenda{i};
         time = sprintf('   time: %5.2f ms, ',1000*event.t);
         ms = sprintf('  delta: %6.2f ms,   ',1000*event.delta);
         data = event.data;
         if (isa(data,'double') && length(data) == 1)
            dstr = sprintf(',   data = %g',data);
         elseif isempty(data)
            dstr = sprintf(',   data = []');
         else
            dstr = ',   data = <any>';
         end
         fprintf([time,ms,char(event.callback),dstr,'\n']);
      end
   end
   function Z = Schedule(Z,delta,cb,cd)% schedule a callback for timer 
   %
   % SCHEDULE   Schedule a next timer callback
   %
   %               Z = schedule(Z,delta,cb,cd)
   %               
   %               meaning of args:
   %                  Z:      scheduler state
   %                  delta:  time interval until scheduled callback
   %                  cb:     callback function
   %                  cd:     call data
   %
      t = Z.scheduler.t + delta;       % scheduled time
      agenda = Z.scheduler.agenda;     % get agenda
      index = 0;
      for (i=1:length(agenda))
         event = agenda{i};
         if (t < event.t)
            index = i;                 % index for inserting in agenda
            break
         end
      end
      
      event.t = t;                     % store wakeup time in event record
      event.delta = delta;             % store time interval in event rec.
      event.callback = cb;             % store callback in event record
      event.data = cd;                 % store call data in event record
      
      if (index == 0)                  % t was greater then all schedules
         if ~isempty(agenda)
            lastone = agenda{end};
            event.delta = event.t - lastone.t;
         end
         agenda{end+1} = event;
      else
         affected = agenda{index};
         affected.delta = affected.t - event.t;
         agenda{index} = affected;     % update affected event structure.
         if (index > 1)
            lastone = agenda{index-1};
            event.delta = event.t - lastone.t;
         end
         agenda = [agenda(1:index-1),{event},agenda(index:end)];
      end
      
      Z.scheduler.agenda = agenda;     % update agenda in scheduler state
   end
   function [Z,event] = NextEvent(Z)   % get next event from agenda    
      agenda = Z.scheduler.agenda;     % fetch agenda
      if isempty(agenda)
         event = [];                   % return empty event if empty agenda
      else
         event = agenda{1};
         agenda(1) = [];               % delete event from agenda
         Z.scheduler.t = event.t;      % adjust time
      end
      
      T = Z.scheduler.T;               % total simulation time
      if (event.t > T)
         event = {};                   % no more events if simulation over
         Z.scheduler.t = T;            % adjust time
      end
      Z.event = event;                 % event available for application
      Z.scheduler.agenda = agenda;     % update agenda in scheduler
   end
   function delta = Delta(Z)           % Calculate New Time Delta      
      sigj = Z.stochastics.sigj;       % time jitter sigma
      Ts = Z.scheduler.Ts;             % nominal sampling time
      
      jitter = 1 + abs(sigj*randn);    % time jitter
      delta = Ts * jitter;             % return jittered sampling time
   end

   function X = Process(X,Ts)          % Grid Voltage Measurement      
      uold = X.grid.u;                 % save old value of grid voltage

      sigv = X.stochastics.sigv;       % sigma of measurement noise
      f = X.grid.f;                    % grid frequency
      df = X.grid.df;                  % grid frequency deviation
      x = X.grid.x;                    % grid (system) state

      [A,B,C] = System(X,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      phi = atan2(x(1),x(2));          % phase
      phi = rem(phi+2*pi,2*pi);        % map phase to [0,2*pi)

      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage
      u = x(1);                        % 230V RMS grid voltage

      X.grid.phi = phi;                % update phase
      X.grid.x = x;                    % update grid (system) state
      X.grid.u = u;                    % update 230V RMS grid voltage
      X.grid.ug = ug;                  % update noise free grid voltage
      X.grid.up = up;                  % update sensed line voltage

         % phase angle switch off
         % usually this is done if Triac current passes zero

      if (sign(u) ~= sign(uold))       % then zero pass of grid voltage
         X.triac.state = 0;            % clear triac state
      end
      if (X.triac.state ~= 0)
         X.triac.out = abs(u);
      else
         X.triac.out = 0;
      end
   end
   function X = Kalman(X,Ts)           % Kalman Filter Transition      
      y = X.grid.up;                   % sensed line voltage

      f = X.grid.f;                    % grid frequency
      R = X.kalman.R;                  % R matrix for Kalman filter
      Q = X.kalman.Q;                  % Q matrix for Kalman filter
      [A,B,C] = System(X,f,Ts);        % system model (oscillator)

      z = X.kalman.z;                  % Kalman model state
      P = X.kalman.P;                  % Kalman error covariance matrix
      u = 0;                           % no input signal (irelevant)

      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z+B*u)];    % observer state correction
      else
         c = 0*z;                      % disable correction
      end 
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P

      phi = atan2(z(1),z(2));          % estimated phase
      phi = rem(phi+2*pi,2*pi);        % mapped to interval [0,2*pi)
      
      X.kalman.z = z;                  % update Kalman model state
      X.kalman.P = P;                  % update error covariance matrix
      X.kalman.phi = phi;              % update estimated phase
      X.kalman.q = q;                  % update reconstructed voltage
      X.kalman.p = p;                  % update uncertainty indicator
   end

   function Z = SetKalmanTimer(Z,delta)% Set Next Event @ Kalman Timer 
      cb = @CbKalman;                  % timer callback
      Z = Schedule(Z,delta,cb,[]);     % schedule next callback
   end

   function Z = InitKalmanTimer(Z)     % init timer for Kalman filter  
      delta = Delta(Z);                % get new time delta
      Z = SetKalmanTimer(Z,delta);     % CbKalman callback after delta
   end
   function Z = InitTriacTimer(Z)      % init timer for Triac          
      delta = Delta(Z);                % get new time delta
      cb = @CbTriac;                   % timer callback
      Z = Schedule(Z,8*delta,cb,0);    % schedule next callback
   end
   function Z = InitBoostTimer(Z)      % init timer for boost control  
      delta = Delta(Z);                % get new time delta
      cb = @CbBoost;                   % timer callback
      
         % to enable boost mode we have to provide call data 2
         
      Z = Schedule(Z,5*delta,cb,2);    % schedule next callback
   end

   function [X,Z] = CbKalman(X,Z)      % Kalman Filter Callback        
 
      delta = Z.event.delta;           % get time delta
      X = Process(X,delta);            % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data
      
      delta = Delta(Z);                % get next time delta
      Z = SetKalmanTimer(Z,delta);     % set Kalmann timer next event
   end
   function [X,Z] = CbTriac(X,Z)       % Triac Controller Callback     
   %
   % CBTRIAC   Triac controller callback
   %
   %    The callback comes with a mode argument in call data
   %
   %       mode = -1:   Triac state off
   %       mode = 0:    Triac gate off
   %       mode = 1:    Triac gate on, Triac state on
   %
      function Z = TriacSchedule(X,Z)  % Schedule Phase Angle Control      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         gate = X.triac.gate;          % gate signal
         state = X.triac.state;        % Triac state
         
         assert(0 <= phi && phi < 2*pi);
         if (gate == 0 && state == 0)  % gate and triac is off
            phi0 = X.triac.phi1;       % phase angle to switch on
            m = 1;                     % next time mode = 1 (gate on)
         elseif (gate ~= 0)            % else if gate activated
            phi1 = X.triac.phi1;       % phase angle to switch on
            dphi = X.triac.dphi;       % delta angle for gate pulse width
            phi0 = phi1 + dphi;        % angle to switch gate off
            m = 0;                     % next time gate off
         else
            assert(gate == 0 && state ~= 0);
            phi0 = pi;                 % phase angle to switch triac off
            m = -1;                    % next time triac off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbTriac;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,m);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Process(X,delta);            % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data before state change

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % triac off
            X.triac.state = 0;         % turn triac state off
            X.triac.out = 0;           % turm triac output off
         case 0                        % triac gate off
            X.triac.gate = 0;          % turn Triac gate off
         case 1                        % triac gate on, triac on
            u = X.grid.u;              % 230V RMS grid voltage
            X.triac.gate = 1;          % turn Triac gate on
            X.triac.state = 1;         % triac state switches on
            X.triac.out = abs(u);      % set triac output to grid voltage 
         otherwise
            'ignore!';
      end
      Z = TriacSchedule(X,Z);
      Z = Log(Z,X);                    % log data after state change
   end
   function [X,Z] = CbBoost(X,Z)       % Boost Controller Callback     
   %
   % CBBOOST   Boost control callback
   %
   %           The callback comes with a mode argument in call data
   %
   %              mode = -1:   disable boost control
   %              mode = 0;    boost signal off
   %              mode = 1:    boost signal on
   %              mode = 2:    enable boost control
   %
      function Z = BoostSchedule(X,Z)  % Schedule Boost Signal Switch      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         b = X.boost.b;                % boost signal
         
         assert(0 <= phi && phi < 2*pi);
         if (b == 0)                   % if boost signal off
            phi0 = X.boost.phi1;       % phase angle to switch on
            b = 1;                     % next time switch on
            if ~X.boost.enable
               b = 0;                  % next time switch off
            end
         else                          % else b ~= 0
            phi0 = X.boost.phi2;       % phase angle to switch off
            b = 0;                     % next time switch off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbBoost;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,b);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Process(X,delta);            % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % disable boost mode
            X.boost.enable = 0;        % boost mode now disabled
            X.boost.b = 0;             % boost signal switched off
         case 0                        % boost signal off
            X.boost.b = 0;             % boost signal switch off
         case 1                        % boost signal on
            X.boost.b = 1;             % boost signal switch on
         case 2                        % enable boost mode
            X.boost.enable = 1;        % boost mode now enabled
            X.boost.b = 0;             % boost signal still off
         otherwise
            'ignore!';
      end
      Z = BoostSchedule(X,Z);          % schedule new boost calllback event
      Z = Log(Z,X);                    % log data after state change
   end

      % let's go - start with initializing
  
   X = InitState(o);                   % init state using menu settings
   Z = InitScheduler(o);               % init scheduler state (Z)

      % init timers
      
   Z = InitKalmanTimer(Z);             % init timer for Kalman filter
   Z = InitTriacTimer(Z);              % init timer for Triac control
   Z = InitBoostTimer(Z);              % init timer for boost control
   
      % event loop
      
   while (1)                           % simulation loop
      [Z,event] = NextEvent(Z);        % get next event from agenda
   
      if isempty(event)
         break;                        % no more events
      end

      gamma = event.callback;          % fetch callback
      [X,Z] = gamma(X,Z);              % execute callback
   end
   
   PlotBoost(o,Z.oo);                  % plot graphics
end

function o = SimuBP2(o)                % Boost & Phase Angle Control 2 
%
% SIMUBP2 Boost & Phase Angle Control
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function X = InitState(o);          % Initialize State              
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      
      X.grid.f = f;                    % frequency (50 Hz)
      X.grid.df = df;                  % frequency deviation (0 or 1 Hz)
      X.grid.Un = Un;                  % nominal RMS voltage (230 V)
      X.grid.T0 = T0;                  % time shift for simulation (2 ms)
      X.grid.S = S;                    % Voltage step down factor (0.0075)
      
         % init system for grid voltage generation
         
      x0 = [0;Un*sqrt(2)];             % nominal grid (system) init state
      X.grid.x = System(X,f,-T0) * x0; % actual grid (system) init state  

         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv,sigj] = Par(o,'sigx','sigw','sigv','sigj');
      
      X.stochastics.sigx = sigx;       % initial uncertainty (100 V)
      X.stochastics.sigw = sigw;       % process noise (0.5 V)
      X.stochastics.sigv = sigv;       % measurement noise (0.1 V)
      X.stochastics.sigj = sigj;       % timing jitter (0.1 = 10%)
      
      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      X.kalman.Q = Q;                  % Q matrix for Kalman Filter
      X.kalman.R = R;                  % R matrix for Kalman Filter

         % init Kalman filter state
   
      X.kalman.z = [0;1];              % init Kalman filter system state
      X.kalman.P = eye(2,2) * sigx^2;  % initial error covariance matrix
      
         % phase angle control
         
      phi = Par(o,'phi');
      X.triac.phi = phi*pi/180;
   end
   function [A,B,C] = System(X,f,T)    % Get System Matrices           
      S = X.grid.S;                    % voltage step down factor
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: step down factor V-measurement
   end
   function [T0,phi] = Shift(x,f,t)    % Phase Shift Calculation       
      om = 2*pi*f;                     % omega (circular fequency)
      phi = atan2(x(1),x(2));          % phi = om*(t+T0)
      phi = rem(phi+2*pi,2*pi);        % map phi to interval [0,2*pi)
      T0 = t - phi/om;                 % time shift
      periode = 2*pi/om;               % periode of grid oscillation
      T0 = rem(T0,periode)*1000;       % convert to ms (debug only)
   end
   function [Ts,t] = Timing(X,t,Ts)    % Calculate New Time            
      sigj = X.stochastics.sigj;       % time jitter sigma

      jitter = 1 + abs(sigj*randn);    % time jitter
      Ts = Ts * jitter;                % return jittered sampling time
      t = t + Ts;                      % return new time
   end
   function [X,up,ug] = Grid(X,t,Ts)   % Grid Voltage Measurement      
      sigv = X.stochastics.sigv;       % sigma of measurement noise
      f = X.grid.f;                    % grid frequency
      df = X.grid.df;                  % grid frequency deviation
      x = X.grid.x;                    % grid (system) state
      
      [A,B,C] = System(X,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      phi = atan2(x(1),x(2));          % phase
      phi = rem(phi+2*pi,2*pi);        % map phase to [0,2*pi)
      
      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage
      
      X.grid.phi = phi;                % update phase
      X.grid.x = x;                    % update grid (system) state
   end
   function [X,q,p] = Kalman(X,t,y,Ts) % Kalman Filter Transition      
      f = X.grid.f;                    % grid frequency
      R = X.kalman.R;                  % R matrix for Kalman filter
      Q = X.kalman.Q;                  % Q matrix for Kalman filter
      [A,B,C] = System(X,f,Ts);        % system model (oscillator)
      
      z = X.kalman.z;                  % Kalman model state
      P = X.kalman.P;                  % Kalman error covariance matrix
      u = 0;                           % no input signal (irelevant)
      
      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z + B*u)];  % observer state correction
      else
         c = 0*z;                      % disable correction
      end
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P
      [s,phi] = Shift(z,f,t);          % calculate time shift
      
      X.kalman.z = z;                  % update Kalman model state
      X.kalman.P = P;                  % update error covariance matrix
      X.kalman.phi = phi;              % update estimated phase
   end
   function [u,q] = Triac(X)           % Triac Controlled Voltage      
      phi = X.triac.phi;               % get control angle
      u = X.grid.x(1);                 % original grid voltage (230V RMS)
      ph = X.grid.phi;
      q = 0;                           % by default = zero
      if (0 <= ph && ph < pi)
         if (ph >= phi)
            q = u;
         end
      else
         if (ph >= phi+pi)
            q = abs(u);
         end
      end
   end
   function s = PhaseError(X)          % phase estimation error [ms]   
      phig = X.grid.phi;               % phase of grid
      phik = X.kalman.phi;             % phase estimated by kalman filter
      om = 2*pi*X.grid.f;              % circular frequency
      s = (phik-phig)/om * 1000;       % phase error converted to miisec
   end

      % prepare and init a log object
      
   oo = huck('boost');                 % create a 'boost' typed object
   oo = log(oo,'t','ug','up','ur','s','e','p','u','q','b');

      % setup parameters and system matrix
      
   X = InitState(o);                   % setup state using menu settings

      % run the system
      
   o = with(o,'simu');
   [T,Ts0] = Par(o,'T','Ts');          % get simulation parameters

   t = 0;                              % init simulation time
   for k = 1:T/Ts0                     % simulation loop
      [Ts,t] = Timing(X,t,Ts0);        % get new time (Ts = t - told)

         % measure grid voltage
         
      [X,up,ug] = Grid(X,t,Ts);
      
         % run kalman filter step
         
      [X,ur,p] = Kalman(X,t,up,Ts);

         % Triac & boost control
         
      [u,q] = Triac(X);                % Triac control
      b = (abs(ug) > 2);               % dummy boost signal
      
         % logging

      s = PhaseError(X);               % phase estimation error [ms]
      e = ur-ug;                       % observation error
      oo = log(oo,t,ug,up,ur,s,e,p,u,q,b);   % record log data
    end
   
   PlotBoost(o,oo);                    % plot graphics
end
function o = SimuBPA(o)                % Boost & Phase Angle Control A 
%
% SIMUBPA Boost & Phase Angle Control
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function Z = Log(Z,X)               % Log Data to Log Object        
   %
   % LOGGING   log data or initialize a log object
   %
   %              Z = Log(Z)           % initialize log object
   %              Z = Log(Z,X)         % log data from states X,Z
   %
      if (nargin == 1)
         oo = huck('boost');           % create a 'boost' typed object
         oo = log(oo,'t','ug','up','ur','s','e','p','u','q','b','g');
      else
         t = Z.scheduler.t;            % actual simulation time
         ug = X.grid.ug;               % noise free grid voltage
         up = X.grid.up;               % sensed line voltage
         s = PhaseError(X);            % phase estimation error [ms]
         p = X.kalman.p;               % uncertainty indicator
         ur = X.kalman.q;              % reconstructed grid voltage
         e = ur - ug;                  % observation error
         u = X.grid.u;                 % 230V RMS grid voltage
         q = X.triac.out;              % Triac controlled output
         b = X.boost.b;                % boost signal
         g = X.triac.gate * 100;       % triac gate signal (scaled *100) 
         
            % log data to log object
            
         oo = log(Z.oo,t,ug,up,ur,s,e,p,u,q,b,g);   % record log data
      end
      Z.oo = oo;                       % store log object in scheduler state
   end
   function X = InitState(o);          % Initialize State              
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      
      X.grid.f = f;                    % frequency (50 Hz)
      X.grid.df = df;                  % frequency deviation (0 or 1 Hz)
      X.grid.Un = Un;                  % nominal RMS voltage (230 V)
      X.grid.T0 = T0;                  % time shift for simulation (2 ms)
      X.grid.S = S;                    % Voltage step down factor (0.0075)
      
         % init system for grid voltage generation
         
      x0 = [0;Un*sqrt(2)];             % nominal grid (system) init state
      X.grid.x = System(X,f,-T0) * x0; % actual grid (system) init state  
      X.grid.ug = 0;                   % init noise free grid voltage
      X.grid.up = 0;                   % init sensed line voltage
      X.grid.u = 0;                    % init 230V RMS voltage
      X.grid.phi = NaN;                % init grid phase
      
         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
      
      X.stochastics.sigx = sigx;       % initial uncertainty (100 V)
      X.stochastics.sigw = sigw;       % process noise (0.5 V)
      X.stochastics.sigv = sigv;       % measurement noise (0.1 V)
      
      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      X.kalman.Q = Q;                  % Q matrix for Kalman Filter
      X.kalman.R = R;                  % R matrix for Kalman Filter

         % init Kalman filter state
   
      X.kalman.z = [0;1];              % init Kalman filter system state
      X.kalman.P = eye(2,2) * sigx^2;  % initial error covariance matrix
     
      X.kalman.q = 0;                  % init reconstructed voltage
      X.kalman.p = 0;                  % init uncertainty indicator
      X.kalman.phi = NaN;              % init estimated phase
      
         % init phase angle control
         
      dphi = 5;                        % pulse with for gate signal [°]
      phi = Par(o,'phi');              % Triac ignition phase [°]

      X.triac.dphi = dphi*pi/180;      % init pulse width in radians
      X.triac.phi1 = phi*pi/180;       % init ignition angle in radians
      X.triac.phi2 = pi-2*dphi*pi/180; % max ignition angle in radians
      X.triac.out = 0;                 % init Triac output
      X.triac.gate = 0;                % init Triac gate signal (inactive)
      X.triac.state = 0;               % init Triac state (not conductive)
    
         % init boost controil
         
      X.boost.b = 0;                   % init boost signal (inactive)
      X.boost.enable = 0;              % initially boost not enabled
      X.boost.phi1 = 45 * pi/180;      % angle to switch boost signal on
      X.boost.phi2 = 135 * pi/180;     % angle to switch boost signal off
      
         % init scheduler
         
      X.scheduler.agenda = {};         % no timer events in scheduler
      X.scheduler.t = 0;               % init scheduler time
   end
   function [A,B,C] = System(X,f,T)    % Get System Matrices           
      S = X.grid.S;                    % voltage step down factor
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: step down factor V-measurement
   end
   function s = PhaseError(X)          % Phase Estimation Error [ms]   
      periode = 1 / X.grid.f;          % grid periode
      phig = X.grid.phi;               % phase of grid
      phik = X.kalman.phi;             % phase estimated by kalman filter
      om = 2*pi*X.grid.f;              % circular frequency
      s = (phik-phig)/om;              % phase error
      while (s < periode/2)
         s = s + periode;              % map s to interval [0,periode)
      end
      while (s >= periode/2)
         s = s - periode;              % map s to interval [0,periode)
      end
      s = s * 1000;                    % phase error converted to miisec
   end

   function Z = InitScheduler(o)       % Init Scheduler State (Z)      
      o = with(o,'simu');
      [T,Ts] = Par(o,'T','Ts');        % get timing (simulation) parameters

      Z.scheduler.t = 0;               % init actual simulation time
      Z.scheduler.T = T;               % total simulation time
      Z.scheduler.Ts = Ts;             % nominal sample time
      Z.scheduler.agenda = {};         % init agenda (empty at beginning)

         % setup timing jitter stochastics from menu settings
         
      o = with(o,'boost');
      sigj = Par(o,'sigj');            % jitter stochastics for timing

      Z.stochastics.sigj = sigj;       % timing jitter (0.1 = 10%)
      
         % init log object
         
      Z = Log(Z);                      % init log object
   end
   function Agenda(Z)                  % Print Agenda (for Debug)      
      agenda = Z.scheduler.agenda;
      fprintf('Agenda (t = %6.2f ms)\n',1000*Z.scheduler.t);
      for (i=1:length(agenda))
         event = agenda{i};
         time = sprintf('   time: %5.2f ms, ',1000*event.t);
         ms = sprintf('  delta: %6.2f ms,   ',1000*event.delta);
         data = event.data;
         if (isa(data,'double') && length(data) == 1)
            dstr = sprintf(',   data = %g',data);
         elseif isempty(data)
            dstr = sprintf(',   data = []');
         else
            dstr = ',   data = <any>';
         end
         fprintf([time,ms,char(event.callback),dstr,'\n']);
      end
   end
   function Z = Schedule(Z,delta,cb,cd)% schedule a callback for timer 
   %
   % SCHEDULE   Schedule a next timer callback
   %
   %               Z = schedule(Z,delta,cb,cd)
   %               
   %               meaning of args:
   %                  Z:      scheduler state
   %                  delta:  time interval until scheduled callback
   %                  cb:     callback function
   %                  cd:     call data
   %
      t = Z.scheduler.t + delta;       % scheduled time
      agenda = Z.scheduler.agenda;     % get agenda
      index = 0;
      for (i=1:length(agenda))
         event = agenda{i};
         if (t < event.t)
            index = i;                 % index for inserting in agenda
            break
         end
      end
      
      event.t = t;                     % store wakeup time in event record
      event.delta = delta;             % store time interval in event rec.
      event.callback = cb;             % store callback in event record
      event.data = cd;                 % store call data in event record
      
      if (index == 0)                  % t was greater then all schedules
         if ~isempty(agenda)
            lastone = agenda{end};
            event.delta = event.t - lastone.t;
         end
         agenda{end+1} = event;
      else
         affected = agenda{index};
         affected.delta = affected.t - event.t;
         agenda{index} = affected;     % update affected event structure.
         if (index > 1)
            lastone = agenda{index-1};
            event.delta = event.t - lastone.t;
         end
         agenda = [agenda(1:index-1),{event},agenda(index:end)];
      end
      
      Z.scheduler.agenda = agenda;     % update agenda in scheduler state
   end
   function [Z,event] = NextEvent(Z)   % get next event from agenda    
      agenda = Z.scheduler.agenda;     % fetch agenda
      if isempty(agenda)
         event = [];                   % return empty event if empty agenda
      else
         event = agenda{1};
         agenda(1) = [];               % delete event from agenda
         Z.scheduler.t = event.t;      % adjust time
      end
      
      T = Z.scheduler.T;               % total simulation time
      if (event.t > T)
         event = {};                   % no more events if simulation over
         Z.scheduler.t = T;            % adjust time
      end
      Z.event = event;                 % event available for application
      Z.scheduler.agenda = agenda;     % update agenda in scheduler
   end
   function delta = Delta(Z)           % Calculate New Time Delta      
      sigj = Z.stochastics.sigj;       % time jitter sigma
      Ts = Z.scheduler.Ts;             % nominal sampling time
      
      jitter = 1 + abs(sigj*randn);    % time jitter
      delta = Ts * jitter;             % return jittered sampling time
   end

   function X = Grid(X,Ts)             % Grid Voltage Measurement      
      uold = X.grid.u;                 % save old value of grid voltage

      sigv = X.stochastics.sigv;       % sigma of measurement noise
      f = X.grid.f;                    % grid frequency
      df = X.grid.df;                  % grid frequency deviation
      x = X.grid.x;                    % grid (system) state

      [A,B,C] = System(X,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      phi = atan2(x(1),x(2));          % phase
      phi = rem(phi+2*pi,2*pi);        % map phase to [0,2*pi)

      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage
      u = x(1);                        % 230V RMS grid voltage

      X.grid.phi = phi;                % update phase
      X.grid.x = x;                    % update grid (system) state
      X.grid.u = u;                    % update 230V RMS grid voltage
      X.grid.ug = ug;                  % update noise free grid voltage
      X.grid.up = up;                  % update sensed line voltage

         % phase angle switch off
         % usually this is done if Triac current passes zero

      if (sign(u) ~= sign(uold))       % then zero pass of grid voltage
         X.triac.state = 0;            % clear triac state
      end
      if (X.triac.state ~= 0)
         X.triac.out = abs(u);
      else
         X.triac.out = 0;
      end
   end
   function X = Kalman(X,Ts)           % Kalman Filter Transition      
      y = X.grid.up;                   % sensed line voltage

      f = X.grid.f;                    % grid frequency
      R = X.kalman.R;                  % R matrix for Kalman filter
      Q = X.kalman.Q;                  % Q matrix for Kalman filter
      [A,B,C] = System(X,f,Ts);        % system model (oscillator)

      z = X.kalman.z;                  % Kalman model state
      P = X.kalman.P;                  % Kalman error covariance matrix
      u = 0;                           % no input signal (irelevant)

      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z+B*u)];    % observer state correction
      else
         c = 0*z;                      % disable correction
      end 
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P

      phi = atan2(z(1),z(2));          % estimated phase
      phi = rem(phi+2*pi,2*pi);        % mapped to interval [0,2*pi)
      
      X.kalman.z = z;                  % update Kalman model state
      X.kalman.P = P;                  % update error covariance matrix
      X.kalman.phi = phi;              % update estimated phase
      X.kalman.q = q;                  % update reconstructed voltage
      X.kalman.p = p;                  % update uncertainty indicator
   end

   function Z = SetKalmanTimer(Z,delta)% Set Next Event @ Kalman Timer 
      cb = @CbKalman;                  % timer callback
      Z = Schedule(Z,delta,cb,[]);     % schedule next callback
   end

   function Z = InitKalmanTimer(Z)     % init timer for Kalman filter  
      delta = Delta(Z);                % get new time delta
      Z = SetKalmanTimer(Z,delta);     % CbKalman callback after delta
   end
   function Z = InitTriacTimer(Z)      % init timer for Triac          
      delta = Delta(Z);                % get new time delta
      cb = @CbTriac;                   % timer callback
      Z = Schedule(Z,8*delta,cb,0);    % schedule next callback
   end
   function Z = InitBoostTimer(Z)      % init timer for boost control  
      delta = Delta(Z);                % get new time delta
      cb = @CbBoost;                   % timer callback
      
         % to enable boost mode we have to provide call data 2
         
      Z = Schedule(Z,5*delta,cb,2);    % schedule next callback
   end

   function [X,Z] = CbKalman(X,Z)      % Kalman Filter Callback        
 
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
%     X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data
      
      delta = Delta(Z);                % get next time delta
      Z = SetKalmanTimer(Z,delta);     % set Kalmann timer next event
   end
   function [X,Z] = CbTriac(X,Z)       % Triac Controller Callback     
   %
   % CBTRIAC   Triac controller callback
   %
   %    The callback comes with a mode argument in call data
   %
   %       mode = -1:   Triac state off
   %       mode = 0:    Triac gate off
   %       mode = 1:    Triac gate on, Triac state on
   %
      function Z = TriacSchedule(X,Z)  % Schedule Phase Angle Control      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         gate = X.triac.gate;          % gate signal
         state = X.triac.state;        % Triac state
         
         assert(0 <= phi && phi < 2*pi);
         if (gate == 0 && state == 0)  % gate and triac is off
            phi0 = X.triac.phi1;       % phase angle to switch on
            m = 1;                     % next time mode = 1 (gate on)
         elseif (gate ~= 0)            % else if gate activated
            phi1 = X.triac.phi1;       % phase angle to switch on
            dphi = X.triac.dphi;       % delta angle for gate pulse width
            phi0 = phi1 + dphi;        % angle to switch gate off
            m = 0;                     % next time gate off
         else
            assert(gate == 0 && state ~= 0);
            phi0 = pi;                 % phase angle to switch triac off
            m = -1;                    % next time triac off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbTriac;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,m);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data before state change

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % triac off
            X.triac.state = 0;         % turn triac state off
            X.triac.out = 0;           % turm triac output off
         case 0                        % triac gate off
            X.triac.gate = 0;          % turn Triac gate off
         case 1                        % triac gate on, triac on
            u = X.grid.u;              % 230V RMS grid voltage
            X.triac.gate = 1;          % turn Triac gate on
            X.triac.state = 1;         % triac state switches on
            X.triac.out = abs(u);      % set triac output to grid voltage 
         otherwise
            'ignore!';
      end
      Z = TriacSchedule(X,Z);
      Z = Log(Z,X);                    % log data after state change
   end
   function [X,Z] = CbBoost(X,Z)       % Boost Controller Callback     
   %
   % CBBOOST   Boost control callback
   %
   %           The callback comes with a mode argument in call data
   %
   %              mode = -1:   disable boost control
   %              mode = 0;    boost signal off
   %              mode = 1:    boost signal on
   %              mode = 2:    enable boost control
   %
      function Z = BoostSchedule(X,Z)  % Schedule Boost Signal Switch      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         b = X.boost.b;                % boost signal
         
         assert(0 <= phi && phi < 2*pi);
         if (b == 0)                   % if boost signal off
            phi0 = X.boost.phi1;       % phase angle to switch on
            b = 1;                     % next time switch on
            if ~X.boost.enable
               b = 0;                  % next time switch off
            end
         else                          % else b ~= 0
            phi0 = X.boost.phi2;       % phase angle to switch off
            b = 0;                     % next time switch off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbBoost;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,b);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % disable boost mode
            X.boost.enable = 0;        % boost mode now disabled
            X.boost.b = 0;             % boost signal switched off
         case 0                        % boost signal off
            X.boost.b = 0;             % boost signal switch off
         case 1                        % boost signal on
            X.boost.b = 1;             % boost signal switch on
         case 2                        % enable boost mode
            X.boost.enable = 1;        % boost mode now enabled
            X.boost.b = 0;             % boost signal still off
         otherwise
            'ignore!';
      end
      Z = BoostSchedule(X,Z);          % schedule new boost calllback event
      Z = Log(Z,X);                    % log data after state change
   end

      % let's go - start with initializing
  
   X = InitState(o);                   % init state using menu settings
   Z = InitScheduler(o);               % init scheduler state (Z)

      % init timers
      
   Z = InitKalmanTimer(Z);             % init timer for Kalman filter
%  Z = InitTriacTimer(Z);              % init timer for Triac control
%  Z = InitBoostTimer(Z);              % init timer for boost control
   
      % event loop
      
   while (1)                           % simulation loop
      [Z,event] = NextEvent(Z);        % get next event from agenda
   
      if isempty(event)
         break;                        % no more events
      end

      gamma = event.callback;          % fetch callback
      [X,Z] = gamma(X,Z);              % execute callback
   end
   
   PlotBoost(o,Z.oo);                  % plot graphics
end
function o = SimuBPB(o)                % Boost & Phase Angle Control B 
%
% SIMUBPB Boost & Phase Angle Control
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function Z = Log(Z,X)               % Log Data to Log Object        
   %
   % LOGGING   log data or initialize a log object
   %
   %              Z = Log(Z)           % initialize log object
   %              Z = Log(Z,X)         % log data from states X,Z
   %
      if (nargin == 1)
         oo = huck('boost');           % create a 'boost' typed object
         oo = log(oo,'t','ug','up','ur','s','e','p','u','q','b','g');
      else
         t = Z.scheduler.t;            % actual simulation time
         ug = X.grid.ug;               % noise free grid voltage
         up = X.grid.up;               % sensed line voltage
         s = PhaseError(X);            % phase estimation error [ms]
         p = X.kalman.p;               % uncertainty indicator
         ur = X.kalman.q;              % reconstructed grid voltage
         e = ur - ug;                  % observation error
         u = X.grid.u;                 % 230V RMS grid voltage
         q = X.triac.out;              % Triac controlled output
         b = X.boost.b;                % boost signal
         g = X.triac.gate * 100;       % triac gate signal (scaled *100) 
         
            % log data to log object
            
         oo = log(Z.oo,t,ug,up,ur,s,e,p,u,q,b,g);   % record log data
      end
      Z.oo = oo;                       % store log object in scheduler state
   end
   function X = InitState(o);          % Initialize State              
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      
      X.grid.f = f;                    % frequency (50 Hz)
      X.grid.df = df;                  % frequency deviation (0 or 1 Hz)
      X.grid.Un = Un;                  % nominal RMS voltage (230 V)
      X.grid.T0 = T0;                  % time shift for simulation (2 ms)
      X.grid.S = S;                    % Voltage step down factor (0.0075)
      
         % init system for grid voltage generation
         
      x0 = [0;Un*sqrt(2)];             % nominal grid (system) init state
      X.grid.x = System(X,f,-T0) * x0; % actual grid (system) init state  
      X.grid.ug = 0;                   % init noise free grid voltage
      X.grid.up = 0;                   % init sensed line voltage
      X.grid.u = 0;                    % init 230V RMS voltage
      X.grid.phi = NaN;                % init grid phase
      
         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
      
      X.stochastics.sigx = sigx;       % initial uncertainty (100 V)
      X.stochastics.sigw = sigw;       % process noise (0.5 V)
      X.stochastics.sigv = sigv;       % measurement noise (0.1 V)
      
      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      X.kalman.Q = Q;                  % Q matrix for Kalman Filter
      X.kalman.R = R;                  % R matrix for Kalman Filter

         % init Kalman filter state
   
      X.kalman.z = [0;1];              % init Kalman filter system state
      X.kalman.P = eye(2,2) * sigx^2;  % initial error covariance matrix
     
      X.kalman.q = 0;                  % init reconstructed voltage
      X.kalman.p = 0;                  % init uncertainty indicator
      X.kalman.phi = NaN;              % init estimated phase
      
         % init phase angle control
         
      dphi = 5;                        % pulse with for gate signal [°]
      phi = Par(o,'phi');              % Triac ignition phase [°]

      X.triac.dphi = dphi*pi/180;      % init pulse width in radians
      X.triac.phi1 = phi*pi/180;       % init ignition angle in radians
      X.triac.phi2 = pi-2*dphi*pi/180; % max ignition angle in radians
      X.triac.out = 0;                 % init Triac output
      X.triac.gate = 0;                % init Triac gate signal (inactive)
      X.triac.state = 0;               % init Triac state (not conductive)
    
         % init boost controil
         
      X.boost.b = 0;                   % init boost signal (inactive)
      X.boost.enable = 0;              % initially boost not enabled
      X.boost.phi1 = 45 * pi/180;      % angle to switch boost signal on
      X.boost.phi2 = 135 * pi/180;     % angle to switch boost signal off
      
         % init scheduler
         
      X.scheduler.agenda = {};         % no timer events in scheduler
      X.scheduler.t = 0;               % init scheduler time
   end
   function [A,B,C] = System(X,f,T)    % Get System Matrices           
      S = X.grid.S;                    % voltage step down factor
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: step down factor V-measurement
   end
   function s = PhaseError(X)          % Phase Estimation Error [ms]   
      periode = 1 / X.grid.f;          % grid periode
      phig = X.grid.phi;               % phase of grid
      phik = X.kalman.phi;             % phase estimated by kalman filter
      om = 2*pi*X.grid.f;              % circular frequency
      s = (phik-phig)/om;              % phase error
      while (s < periode/2)
         s = s + periode;              % map s to interval [0,periode)
      end
      while (s >= periode/2)
         s = s - periode;              % map s to interval [0,periode)
      end
      s = s * 1000;                    % phase error converted to miisec
   end

   function Z = InitScheduler(o)       % Init Scheduler State (Z)      
      o = with(o,'simu');
      [T,Ts] = Par(o,'T','Ts');        % get timing (simulation) parameters

      Z.scheduler.t = 0;               % init actual simulation time
      Z.scheduler.T = T;               % total simulation time
      Z.scheduler.Ts = Ts;             % nominal sample time
      Z.scheduler.agenda = {};         % init agenda (empty at beginning)

         % setup timing jitter stochastics from menu settings
         
      o = with(o,'boost');
      sigj = Par(o,'sigj');            % jitter stochastics for timing

      Z.stochastics.sigj = sigj;       % timing jitter (0.1 = 10%)
      
         % init log object
         
      Z = Log(Z);                      % init log object
   end
   function Agenda(Z)                  % Print Agenda (for Debug)      
      agenda = Z.scheduler.agenda;
      fprintf('Agenda (t = %6.2f ms)\n',1000*Z.scheduler.t);
      for (i=1:length(agenda))
         event = agenda{i};
         time = sprintf('   time: %5.2f ms, ',1000*event.t);
         ms = sprintf('  delta: %6.2f ms,   ',1000*event.delta);
         data = event.data;
         if (isa(data,'double') && length(data) == 1)
            dstr = sprintf(',   data = %g',data);
         elseif isempty(data)
            dstr = sprintf(',   data = []');
         else
            dstr = ',   data = <any>';
         end
         fprintf([time,ms,char(event.callback),dstr,'\n']);
      end
   end
   function Z = Schedule(Z,delta,cb,cd)% schedule a callback for timer 
   %
   % SCHEDULE   Schedule a next timer callback
   %
   %               Z = schedule(Z,delta,cb,cd)
   %               
   %               meaning of args:
   %                  Z:      scheduler state
   %                  delta:  time interval until scheduled callback
   %                  cb:     callback function
   %                  cd:     call data
   %
      t = Z.scheduler.t + delta;       % scheduled time
      agenda = Z.scheduler.agenda;     % get agenda
      index = 0;
      for (i=1:length(agenda))
         event = agenda{i};
         if (t < event.t)
            index = i;                 % index for inserting in agenda
            break
         end
      end
      
      event.t = t;                     % store wakeup time in event record
      event.delta = delta;             % store time interval in event rec.
      event.callback = cb;             % store callback in event record
      event.data = cd;                 % store call data in event record
      
      if (index == 0)                  % t was greater then all schedules
         if ~isempty(agenda)
            lastone = agenda{end};
            event.delta = event.t - lastone.t;
         end
         agenda{end+1} = event;
      else
         affected = agenda{index};
         affected.delta = affected.t - event.t;
         agenda{index} = affected;     % update affected event structure.
         if (index > 1)
            lastone = agenda{index-1};
            event.delta = event.t - lastone.t;
         end
         agenda = [agenda(1:index-1),{event},agenda(index:end)];
      end
      
      Z.scheduler.agenda = agenda;     % update agenda in scheduler state
   end
   function [Z,event] = NextEvent(Z)   % get next event from agenda    
      agenda = Z.scheduler.agenda;     % fetch agenda
      if isempty(agenda)
         event = [];                   % return empty event if empty agenda
      else
         event = agenda{1};
         agenda(1) = [];               % delete event from agenda
         Z.scheduler.t = event.t;      % adjust time
      end
      
      T = Z.scheduler.T;               % total simulation time
      if (event.t > T)
         event = {};                   % no more events if simulation over
         Z.scheduler.t = T;            % adjust time
      end
      Z.event = event;                 % event available for application
      Z.scheduler.agenda = agenda;     % update agenda in scheduler
   end
   function delta = Delta(Z)           % Calculate New Time Delta      
      sigj = Z.stochastics.sigj;       % time jitter sigma
      Ts = Z.scheduler.Ts;             % nominal sampling time
      
      jitter = 1 + abs(sigj*randn);    % time jitter
      delta = Ts * jitter;             % return jittered sampling time
   end

   function X = Grid(X,Ts)             % Grid Voltage Measurement      
      uold = X.grid.u;                 % save old value of grid voltage

      sigv = X.stochastics.sigv;       % sigma of measurement noise
      f = X.grid.f;                    % grid frequency
      df = X.grid.df;                  % grid frequency deviation
      x = X.grid.x;                    % grid (system) state

      [A,B,C] = System(X,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      phi = atan2(x(1),x(2));          % phase
      phi = rem(phi+2*pi,2*pi);        % map phase to [0,2*pi)

      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage
      u = x(1);                        % 230V RMS grid voltage

      X.grid.phi = phi;                % update phase
      X.grid.x = x;                    % update grid (system) state
      X.grid.u = u;                    % update 230V RMS grid voltage
      X.grid.ug = ug;                  % update noise free grid voltage
      X.grid.up = up;                  % update sensed line voltage

         % phase angle switch off
         % usually this is done if Triac current passes zero

      if (sign(u) ~= sign(uold))       % then zero pass of grid voltage
         X.triac.state = 0;            % clear triac state
      end
      if (X.triac.state ~= 0)
         X.triac.out = abs(u);
      else
         X.triac.out = 0;
      end
   end
   function X = Kalman(X,Ts)           % Kalman Filter Transition      
      y = X.grid.up;                   % sensed line voltage

      f = X.grid.f;                    % grid frequency
      R = X.kalman.R;                  % R matrix for Kalman filter
      Q = X.kalman.Q;                  % Q matrix for Kalman filter
      [A,B,C] = System(X,f,Ts);        % system model (oscillator)

      z = X.kalman.z;                  % Kalman model state
      P = X.kalman.P;                  % Kalman error covariance matrix
      u = 0;                           % no input signal (irelevant)

      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z+B*u)];    % observer state correction
      else
         c = 0*z;                      % disable correction
      end 
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P

      phi = atan2(z(1),z(2));          % estimated phase
      phi = rem(phi+2*pi,2*pi);        % mapped to interval [0,2*pi)
      
      X.kalman.z = z;                  % update Kalman model state
      X.kalman.P = P;                  % update error covariance matrix
      X.kalman.phi = phi;              % update estimated phase
      X.kalman.q = q;                  % update reconstructed voltage
      X.kalman.p = p;                  % update uncertainty indicator
   end

   function Z = SetKalmanTimer(Z,delta)% Set Next Event @ Kalman Timer 
      cb = @CbKalman;                  % timer callback
      Z = Schedule(Z,delta,cb,[]);     % schedule next callback
   end

   function Z = InitKalmanTimer(Z)     % init timer for Kalman filter  
      delta = Delta(Z);                % get new time delta
      Z = SetKalmanTimer(Z,delta);     % CbKalman callback after delta
   end
   function Z = InitTriacTimer(Z)      % init timer for Triac          
      delta = Delta(Z);                % get new time delta
      cb = @CbTriac;                   % timer callback
      Z = Schedule(Z,8*delta,cb,0);    % schedule next callback
   end
   function Z = InitBoostTimer(Z)      % init timer for boost control  
      delta = Delta(Z);                % get new time delta
      cb = @CbBoost;                   % timer callback
      
         % to enable boost mode we have to provide call data 2
         
      Z = Schedule(Z,5*delta,cb,2);    % schedule next callback
   end

   function [X,Z] = CbKalman(X,Z)      % Kalman Filter Callback        
 
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data
      
      delta = Delta(Z);                % get next time delta
      Z = SetKalmanTimer(Z,delta);     % set Kalmann timer next event
   end
   function [X,Z] = CbTriac(X,Z)       % Triac Controller Callback     
   %
   % CBTRIAC   Triac controller callback
   %
   %    The callback comes with a mode argument in call data
   %
   %       mode = -1:   Triac state off
   %       mode = 0:    Triac gate off
   %       mode = 1:    Triac gate on, Triac state on
   %
      function Z = TriacSchedule(X,Z)  % Schedule Phase Angle Control      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         gate = X.triac.gate;          % gate signal
         state = X.triac.state;        % Triac state
         
         assert(0 <= phi && phi < 2*pi);
         if (gate == 0 && state == 0)  % gate and triac is off
            phi0 = X.triac.phi1;       % phase angle to switch on
            m = 1;                     % next time mode = 1 (gate on)
         elseif (gate ~= 0)            % else if gate activated
            phi1 = X.triac.phi1;       % phase angle to switch on
            dphi = X.triac.dphi;       % delta angle for gate pulse width
            phi0 = phi1 + dphi;        % angle to switch gate off
            m = 0;                     % next time gate off
         else
            assert(gate == 0 && state ~= 0);
            phi0 = pi;                 % phase angle to switch triac off
            m = -1;                    % next time triac off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbTriac;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,m);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data before state change

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % triac off
            X.triac.state = 0;         % turn triac state off
            X.triac.out = 0;           % turm triac output off
         case 0                        % triac gate off
            X.triac.gate = 0;          % turn Triac gate off
         case 1                        % triac gate on, triac on
            u = X.grid.u;              % 230V RMS grid voltage
            X.triac.gate = 1;          % turn Triac gate on
            X.triac.state = 1;         % triac state switches on
            X.triac.out = abs(u);      % set triac output to grid voltage 
         otherwise
            'ignore!';
      end
      Z = TriacSchedule(X,Z);
      Z = Log(Z,X);                    % log data after state change
   end
   function [X,Z] = CbBoost(X,Z)       % Boost Controller Callback     
   %
   % CBBOOST   Boost control callback
   %
   %           The callback comes with a mode argument in call data
   %
   %              mode = -1:   disable boost control
   %              mode = 0;    boost signal off
   %              mode = 1:    boost signal on
   %              mode = 2:    enable boost control
   %
      function Z = BoostSchedule(X,Z)  % Schedule Boost Signal Switch      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         b = X.boost.b;                % boost signal
         
         assert(0 <= phi && phi < 2*pi);
         if (b == 0)                   % if boost signal off
            phi0 = X.boost.phi1;       % phase angle to switch on
            b = 1;                     % next time switch on
            if ~X.boost.enable
               b = 0;                  % next time switch off
            end
         else                          % else b ~= 0
            phi0 = X.boost.phi2;       % phase angle to switch off
            b = 0;                     % next time switch off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbBoost;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,b);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % disable boost mode
            X.boost.enable = 0;        % boost mode now disabled
            X.boost.b = 0;             % boost signal switched off
         case 0                        % boost signal off
            X.boost.b = 0;             % boost signal switch off
         case 1                        % boost signal on
            X.boost.b = 1;             % boost signal switch on
         case 2                        % enable boost mode
            X.boost.enable = 1;        % boost mode now enabled
            X.boost.b = 0;             % boost signal still off
         otherwise
            'ignore!';
      end
      Z = BoostSchedule(X,Z);          % schedule new boost calllback event
      Z = Log(Z,X);                    % log data after state change
   end

      % let's go - start with initializing
  
   X = InitState(o);                   % init state using menu settings
   Z = InitScheduler(o);               % init scheduler state (Z)

      % init timers
      
   Z = InitKalmanTimer(Z);             % init timer for Kalman filter
   Z = InitTriacTimer(Z);              % init timer for Triac control
   Z = InitBoostTimer(Z);              % init timer for boost control
   
      % event loop
      
   while (1)                           % simulation loop
      [Z,event] = NextEvent(Z);        % get next event from agenda
   
      if isempty(event)
         break;                        % no more events
      end

      gamma = event.callback;          % fetch callback
      [X,Z] = gamma(X,Z);              % execute callback
   end
   
   PlotBoost(o,Z.oo);                  % plot graphics
end
function o = SimuBPC(o)                % Boost & Phase Angle Control C 
%
% SIMUBPA Boost & Phase Angle Control
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function Z = Log(Z,X)               % Log Data to Log Object        
   %
   % LOGGING   log data or initialize a log object
   %
   %              Z = Log(Z)           % initialize log object
   %              Z = Log(Z,X)         % log data from states X,Z
   %
      if (nargin == 1)
         oo = huck('boost');           % create a 'boost' typed object
         oo = log(oo,'t','ug','up','ur','s','e','p','u','q','b','g');
      else
         t = Z.scheduler.t;            % actual simulation time
         ug = X.grid.ug;               % noise free grid voltage
         up = X.grid.up;               % sensed line voltage
         s = PhaseError(X);            % phase estimation error [ms]
         p = X.kalman.p;               % uncertainty indicator
         ur = X.kalman.q;              % reconstructed grid voltage
         e = ur - ug;                  % observation error
         u = X.grid.u;                 % 230V RMS grid voltage
         q = X.triac.out;              % Triac controlled output
         b = X.boost.b;                % boost signal
         g = X.triac.gate * 100;       % triac gate signal (scaled *100) 
         
            % log data to log object
            
         oo = log(Z.oo,t,ug,up,ur,s,e,p,u,q,b,g);   % record log data
      end
      Z.oo = oo;                       % store log object in scheduler state
   end
   function X = InitState(o);          % Initialize State              
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      
      X.grid.f = f;                    % frequency (50 Hz)
      X.grid.df = df;                  % frequency deviation (0 or 1 Hz)
      X.grid.Un = Un;                  % nominal RMS voltage (230 V)
      X.grid.T0 = T0;                  % time shift for simulation (2 ms)
      X.grid.S = S;                    % Voltage step down factor (0.0075)
      
         % init system for grid voltage generation
         
      x0 = [0;Un*sqrt(2)];             % nominal grid (system) init state
      X.grid.x = System(X,f,-T0) * x0; % actual grid (system) init state  
      X.grid.ug = 0;                   % init noise free grid voltage
      X.grid.up = 0;                   % init sensed line voltage
      X.grid.u = 0;                    % init 230V RMS voltage
      X.grid.phi = NaN;                % init grid phase
      
         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
      
      X.stochastics.sigx = sigx;       % initial uncertainty (100 V)
      X.stochastics.sigw = sigw;       % process noise (0.5 V)
      X.stochastics.sigv = sigv;       % measurement noise (0.1 V)
      
      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      X.kalman.Q = Q;                  % Q matrix for Kalman Filter
      X.kalman.R = R;                  % R matrix for Kalman Filter

         % init Kalman filter state
   
      X.kalman.z = [0;1];              % init Kalman filter system state
      X.kalman.P = eye(2,2) * sigx^2;  % initial error covariance matrix
     
      X.kalman.q = 0;                  % init reconstructed voltage
      X.kalman.p = 0;                  % init uncertainty indicator
      X.kalman.phi = NaN;              % init estimated phase
      
         % init phase angle control
         
      dphi = 5;                        % pulse with for gate signal [°]
      phi = Par(o,'phi');              % Triac ignition phase [°]

      X.triac.dphi = dphi*pi/180;      % init pulse width in radians
      X.triac.phi1 = phi*pi/180;       % init ignition angle in radians
      X.triac.phi2 = pi-2*dphi*pi/180; % max ignition angle in radians
      X.triac.out = 0;                 % init Triac output
      X.triac.gate = 0;                % init Triac gate signal (inactive)
      X.triac.state = 0;               % init Triac state (not conductive)
    
         % init boost controil
         
      X.boost.b = 0;                   % init boost signal (inactive)
      X.boost.enable = 0;              % initially boost not enabled
      X.boost.phi1 = 45 * pi/180;      % angle to switch boost signal on
      X.boost.phi2 = 135 * pi/180;     % angle to switch boost signal off
      
         % init scheduler
         
      X.scheduler.agenda = {};         % no timer events in scheduler
      X.scheduler.t = 0;               % init scheduler time
   end
   function [A,B,C] = System(X,f,T)    % Get System Matrices           
      S = X.grid.S;                    % voltage step down factor
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: step down factor V-measurement
   end
   function s = PhaseError(X)          % Phase Estimation Error [ms]   
      periode = 1 / X.grid.f;          % grid periode
      phig = X.grid.phi;               % phase of grid
      phik = X.kalman.phi;             % phase estimated by kalman filter
      om = 2*pi*X.grid.f;              % circular frequency
      s = (phik-phig)/om;              % phase error
      while (s < periode/2)
         s = s + periode;              % map s to interval [0,periode)
      end
      while (s >= periode/2)
         s = s - periode;              % map s to interval [0,periode)
      end
      s = s * 1000;                    % phase error converted to miisec
   end

   function Z = InitScheduler(o)       % Init Scheduler State (Z)      
      o = with(o,'simu');
      [T,Ts] = Par(o,'T','Ts');        % get timing (simulation) parameters

      Z.scheduler.t = 0;               % init actual simulation time
      Z.scheduler.T = T;               % total simulation time
      Z.scheduler.Ts = Ts;             % nominal sample time
      Z.scheduler.agenda = {};         % init agenda (empty at beginning)

         % setup timing jitter stochastics from menu settings
         
      o = with(o,'boost');
      sigj = Par(o,'sigj');            % jitter stochastics for timing

      Z.stochastics.sigj = sigj;       % timing jitter (0.1 = 10%)
      
         % init log object
         
      Z = Log(Z);                      % init log object
   end
   function Agenda(Z)                  % Print Agenda (for Debug)      
      agenda = Z.scheduler.agenda;
      fprintf('Agenda (t = %6.2f ms)\n',1000*Z.scheduler.t);
      for (i=1:length(agenda))
         event = agenda{i};
         time = sprintf('   time: %5.2f ms, ',1000*event.t);
         ms = sprintf('  delta: %6.2f ms,   ',1000*event.delta);
         data = event.data;
         if (isa(data,'double') && length(data) == 1)
            dstr = sprintf(',   data = %g',data);
         elseif isempty(data)
            dstr = sprintf(',   data = []');
         else
            dstr = ',   data = <any>';
         end
         fprintf([time,ms,char(event.callback),dstr,'\n']);
      end
   end
   function Z = Schedule(Z,delta,cb,cd)% schedule a callback for timer 
   %
   % SCHEDULE   Schedule a next timer callback
   %
   %               Z = schedule(Z,delta,cb,cd)
   %               
   %               meaning of args:
   %                  Z:      scheduler state
   %                  delta:  time interval until scheduled callback
   %                  cb:     callback function
   %                  cd:     call data
   %
      t = Z.scheduler.t + delta;       % scheduled time
      agenda = Z.scheduler.agenda;     % get agenda
      index = 0;
      for (i=1:length(agenda))
         event = agenda{i};
         if (t < event.t)
            index = i;                 % index for inserting in agenda
            break
         end
      end
      
      event.t = t;                     % store wakeup time in event record
      event.delta = delta;             % store time interval in event rec.
      event.callback = cb;             % store callback in event record
      event.data = cd;                 % store call data in event record
      
      if (index == 0)                  % t was greater then all schedules
         if ~isempty(agenda)
            lastone = agenda{end};
            event.delta = event.t - lastone.t;
         end
         agenda{end+1} = event;
      else
         affected = agenda{index};
         affected.delta = affected.t - event.t;
         agenda{index} = affected;     % update affected event structure.
         if (index > 1)
            lastone = agenda{index-1};
            event.delta = event.t - lastone.t;
         end
         agenda = [agenda(1:index-1),{event},agenda(index:end)];
      end
      
      Z.scheduler.agenda = agenda;     % update agenda in scheduler state
   end
   function [Z,event] = NextEvent(Z)   % get next event from agenda    
      agenda = Z.scheduler.agenda;     % fetch agenda
      if isempty(agenda)
         event = [];                   % return empty event if empty agenda
      else
         event = agenda{1};
         agenda(1) = [];               % delete event from agenda
         Z.scheduler.t = event.t;      % adjust time
      end
      
      T = Z.scheduler.T;               % total simulation time
      if (event.t > T)
         event = {};                   % no more events if simulation over
         Z.scheduler.t = T;            % adjust time
      end
      Z.event = event;                 % event available for application
      Z.scheduler.agenda = agenda;     % update agenda in scheduler
   end
   function delta = Delta(Z)           % Calculate New Time Delta      
      sigj = Z.stochastics.sigj;       % time jitter sigma
      Ts = Z.scheduler.Ts;             % nominal sampling time
      
      jitter = 1 + abs(sigj*randn);    % time jitter
      delta = Ts * jitter;             % return jittered sampling time
   end

   function X = Grid(X,Ts)             % Grid Voltage Measurement      
      uold = X.grid.u;                 % save old value of grid voltage

      sigv = X.stochastics.sigv;       % sigma of measurement noise
      f = X.grid.f;                    % grid frequency
      df = X.grid.df;                  % grid frequency deviation
      x = X.grid.x;                    % grid (system) state

      [A,B,C] = System(X,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      phi = atan2(x(1),x(2));          % phase
      phi = rem(phi+2*pi,2*pi);        % map phase to [0,2*pi)

      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage
      u = x(1);                        % 230V RMS grid voltage

      X.grid.phi = phi;                % update phase
      X.grid.x = x;                    % update grid (system) state
      X.grid.u = u;                    % update 230V RMS grid voltage
      X.grid.ug = ug;                  % update noise free grid voltage
      X.grid.up = up;                  % update sensed line voltage

         % phase angle switch off
         % usually this is done if Triac current passes zero

      if (sign(u) ~= sign(uold))       % then zero pass of grid voltage
         X.triac.state = 0;            % clear triac state
      end
      if (X.triac.state ~= 0)
         X.triac.out = abs(u);
      else
         X.triac.out = 0;
      end
   end
   function X = Kalman(X,Ts)           % Kalman Filter Transition      
      y = X.grid.up;                   % sensed line voltage

      f = X.grid.f;                    % grid frequency
      R = X.kalman.R;                  % R matrix for Kalman filter
      Q = X.kalman.Q;                  % Q matrix for Kalman filter
      [A,B,C] = System(X,f,Ts);        % system model (oscillator)

      z = X.kalman.z;                  % Kalman model state
      P = X.kalman.P;                  % Kalman error covariance matrix
      u = 0;                           % no input signal (irelevant)

      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z+B*u)];    % observer state correction
      else
         c = 0*z;                      % disable correction
      end 
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P

      phi = atan2(z(1),z(2));          % estimated phase
      phi = rem(phi+2*pi,2*pi);        % mapped to interval [0,2*pi)
      
      X.kalman.z = z;                  % update Kalman model state
      X.kalman.P = P;                  % update error covariance matrix
      X.kalman.phi = phi;              % update estimated phase
      X.kalman.q = q;                  % update reconstructed voltage
      X.kalman.p = p;                  % update uncertainty indicator
   end

   function Z = SetKalmanTimer(Z,delta)% Set Next Event @ Kalman Timer 
      cb = @CbKalman;                  % timer callback
      Z = Schedule(Z,delta,cb,[]);     % schedule next callback
   end

   function Z = InitKalmanTimer(Z)     % init timer for Kalman filter  
      delta = Delta(Z);                % get new time delta
      Z = SetKalmanTimer(Z,delta);     % CbKalman callback after delta
   end
   function Z = InitTriacTimer(Z)      % init timer for Triac          
      delta = Delta(Z);                % get new time delta
      cb = @CbTriac;                   % timer callback
      Z = Schedule(Z,8*delta,cb,0);    % schedule next callback
   end
   function Z = InitBoostTimer(Z)      % init timer for boost control  
      delta = Delta(Z);                % get new time delta
      cb = @CbBoost;                   % timer callback
      
         % to enable boost mode we have to provide call data 2
         
      Z = Schedule(Z,5*delta,cb,2);    % schedule next callback
   end

   function [X,Z] = CbKalman(X,Z)      % Kalman Filter Callback        
 
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data
      
      delta = Delta(Z);                % get next time delta
      Z = SetKalmanTimer(Z,delta);     % set Kalmann timer next event
   end
   function [X,Z] = CbTriac(X,Z)       % Triac Controller Callback     
   %
   % CBTRIAC   Triac controller callback
   %
   %    The callback comes with a mode argument in call data
   %
   %       mode = -1:   Triac state off
   %       mode = 0:    Triac gate off
   %       mode = 1:    Triac gate on, Triac state on
   %
      function Z = TriacSchedule(X,Z)  % Schedule Phase Angle Control      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         gate = X.triac.gate;          % gate signal
         state = X.triac.state;        % Triac state
         
         assert(0 <= phi && phi < 2*pi);
         if (gate == 0 && state == 0)  % gate and triac is off
            phi0 = X.triac.phi1;       % phase angle to switch on
            m = 1;                     % next time mode = 1 (gate on)
         elseif (gate ~= 0)            % else if gate activated
            phi1 = X.triac.phi1;       % phase angle to switch on
            dphi = X.triac.dphi;       % delta angle for gate pulse width
            phi0 = phi1 + dphi;        % angle to switch gate off
            m = 0;                     % next time gate off
         else
            assert(gate == 0 && state ~= 0);
            phi0 = pi;                 % phase angle to switch triac off
            m = -1;                    % next time triac off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbTriac;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,m);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data before state change

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % triac off
            X.triac.state = 0;         % turn triac state off
            X.triac.out = 0;           % turm triac output off
         case 0                        % triac gate off
            X.triac.gate = 0;          % turn Triac gate off
         case 1                        % triac gate on, triac on
            u = X.grid.u;              % 230V RMS grid voltage
            X.triac.gate = 1;          % turn Triac gate on
            X.triac.state = 1;         % triac state switches on
            X.triac.out = abs(u);      % set triac output to grid voltage 
         otherwise
            'ignore!';
      end
      Z = TriacSchedule(X,Z);
      Z = Log(Z,X);                    % log data after state change
   end
   function [X,Z] = CbBoost(X,Z)       % Boost Controller Callback     
   %
   % CBBOOST   Boost control callback
   %
   %           The callback comes with a mode argument in call data
   %
   %              mode = -1:   disable boost control
   %              mode = 0;    boost signal off
   %              mode = 1:    boost signal on
   %              mode = 2:    enable boost control
   %
      function Z = BoostSchedule(X,Z)  % Schedule Boost Signal Switch      
         om = 2*pi*X.grid.f;           % circular frequency
         phi = X.kalman.phi;           % fetch estimated grid phase angle
         b = X.boost.b;                % boost signal
         
         assert(0 <= phi && phi < 2*pi);
         if (b == 0)                   % if boost signal off
            phi0 = X.boost.phi1;       % phase angle to switch on
            b = 1;                     % next time switch on
            if ~X.boost.enable
               b = 0;                  % next time switch off
            end
         else                          % else b ~= 0
            phi0 = X.boost.phi2;       % phase angle to switch off
            b = 0;                     % next time switch off
         end
         
         while (phi >= phi0)
            phi = phi - pi;
         end
         dphi = phi0 - phi;            % which phase difference?
         
         delta = dphi/om;              % time delta to schedule
         cb = @CbBoost;                % callback to be scheduled
         Z = Schedule(Z,delta,cb,b);   % schedule an on switch
      end
      
      delta = Z.event.delta;           % get time delta
      X = Grid(X,delta);               % Grid (System) State Transition
      X = Kalman(X,delta);             % Kalman Filter State Transition
      Z = Log(Z,X);                    % log data

      mode = Z.event.data;             % fetch mode from call data
      switch mode
         case -1                       % disable boost mode
            X.boost.enable = 0;        % boost mode now disabled
            X.boost.b = 0;             % boost signal switched off
         case 0                        % boost signal off
            X.boost.b = 0;             % boost signal switch off
         case 1                        % boost signal on
            X.boost.b = 1;             % boost signal switch on
         case 2                        % enable boost mode
            X.boost.enable = 1;        % boost mode now enabled
            X.boost.b = 0;             % boost signal still off
         otherwise
            'ignore!';
      end
      Z = BoostSchedule(X,Z);          % schedule new boost calllback event
      Z = Log(Z,X);                    % log data after state change
   end

      % let's go - start with initializing
  
   X = InitState(o);                   % init state using menu settings
   Z = InitScheduler(o);               % init scheduler state (Z)

      % init timers
      
   Z = InitKalmanTimer(Z);             % init timer for Kalman filter
   Z = InitTriacTimer(Z);              % init timer for Triac control
   Z = InitBoostTimer(Z);              % init timer for boost control
   
      % event loop
      
   while (1)                           % simulation loop
      [Z,event] = NextEvent(Z);        % get next event from agenda
   
      if isempty(event)
         break;                        % no more events
      end

      gamma = event.callback;          % fetch callback
      [X,Z] = gamma(X,Z);              % execute callback
   end
   
   PlotBoost(o,Z.oo);                  % plot graphics
end
function o = SimuKalman1(o)            % Time Invariant Kalman Simu    
%
% SIMUKALMAN1 Kalman Filter Simulation
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P

   function A = System(f,T)
      om = 2*pi*f;                     % omega (circular frequency)
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   end
   function T0 = Shift(x,om,t)
      phi = atan2(x(1),x(2));          % phi = om*(t+T0)
      T0 = t - phi/om;
      periode = 2*pi/om;              
      T0 = rem(T0,periode)*1000;       % convert to ms (debug only)
   end

   oo = huck('boost');                % create a 'boost' typed object
   oo = log(oo,'t','ug','up','ur','s','e','p','b'); % setup data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');

   o = with(o,'boost');
   [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
   [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
   
      % system matrices
      
   As = System(f+df,Ts);               % system matrix (oscillator)
   A = System(f,Ts);                   % system model (oscillator)
   B = [0;0];  C = [S 0];              % S: scale factor for measurement
   
      % initializing
   
%  sigx = 100;                         % +/-3*sigx = +/-300V
%  sigw = 0.1;                         % process noise
%  sigv = 0.1;                         % sigma of measurement noise
   
   x0 = [0;Un*sqrt(2)];                % initial state
   u = 0;                              % no input signal (irelevant)
   z = [0;1];                          % unknown system state
   I = eye(size(A));                   % identity matrix
   P = I*sigx^2;                       % initial error covariance matrix
   Q = I*sigw^2;                       % process covariance matrix
   R = sigv^2;                         % measurement covariance matrix

      % init system & observer state
      
   x = System(f,-T0) * x0;             % actual system initial state  
 
      % run the system
      
   t = Ts;
   for k = 1:T/Ts
      v  = sigv * randn;               % measurement noise
      w  = sigw * [randn randn]';      % process noise
      y = C*x + v;                     % system output (grid voltage)

        % Kalman filter

      q = C*z;                         % observer output

      M = A*P*A' + Q;                  % (1) short hand
      K = M*C' / (C*M*C' + R);         % (2) Kalman gain
      P = (I - K*C) * M;               % (3) recursive update of P

      c = K * [y - C*(A*z + B*u)];     % observer state correction
      z = A*z + B*u + c;               % observer state update

         % observation error
         
      e = C*(z-x);                     % observation error
      p = 3*sqrt(norm(P));             % 3*sigma of P

         % logging
      
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage 
      ur = C*z;                        % reconstructed voltage
      s = Shift(z,om,t-Ts) - T0*1000;  % calculate time shift error
      b = (abs(ug) > 2);               % dummy boost signal
      
      oo = log(oo,t,ug,up,ur,s,e,p,b); % record log data

         % state transition
         
      x = As*x;                        % system state transition
      t = t+Ts;                        % time transition
   end
   
   PlotBoost(o,oo);                    % plot graphics
end
function o = SimuKalman2(o)            % Time Variant Kalman Simu      
%
% SIMUKALMAN2 Kalman Filter Simulation
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P
%
   function o = Parameters(o);         % Parameter Setup               
      o = with(o,'boost');

         % prepare parameters for grid measurement
         
      [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
      o = var(o,'f',f,'df',df,'Un',Un,'T0',T0,'S',S);
      
         % prepare parameters for Kalman filter
 
      [sigx,sigw,sigv,sigj] = Par(o,'sigx','sigw','sigv','sigj');
      o = var(o,'sigx',sigx,'sigw',sigw,'sigv',sigv,'sigj',sigj);

      I = eye(2,2);                    % identity matrix
      Q = I*sigw^2;                    % process covariance matrix
      R = sigv^2;                      % measurement covariance matrix

      o = var(o,'Q',Q,'R',R);   
   end
   function [A,B,C] = System(o,f,T)    % Get System Matrices           
      S = var(o,'S');
      om = 2*pi*f;                     % omega (circular frequency)
      co = cos(om*T);  si = sin(om*T);
      A = [co si; -si co];             % oscillation
      B = [0;0];  C = [S 0];           % S: scale factor for measurement
   end
   function [T0,phi] = Shift(x,f,t)    % Phase Shift Calculation       
      om = 2*pi*f;                     % omega (circular fequency)
      phi = atan2(x(1),x(2));          % phi = om*(t+T0)
      phi = rem(phi+2*pi,2*pi);        % map phi to interval [0,2*pi)
      T0 = t - phi/om;
      periode = 2*pi/om;              
      T0 = rem(T0,periode)*1000;       % convert to ms (debug only)
   end
   function [t,Ts] = Timing(o,t,Ts)    % Calculate New Time            
      sigj = var(o,'sigj');

      jitter = max(0.5,1+sigj*randn);  % time jitter
      Ts = Ts * jitter;                % return jittered sampling time
      t = t + Ts;                      % return new time
   end
   function [up,ug,x] = Grid(o,t,Ts,x) % Grid Voltage Measurement      
      sigv = var(o,'sigv');            % sigma of measurement noise
      [f,df] = var(o,'f','df');        % frequency, frequency deviation
      
      [A,B,C] = System(o,f+df,Ts);     % system matrix (oscillator)
      x = A*x;                         % system state transition

      v  = sigv * randn;               % measurement noise
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage 
   end
   function [z,q,P,p,s] = Kalman(o,t,z,P,y,Ts) % Kalman Filter Trans.  
      [R,Q,f] = var(o,'R','Q','f');    % R and Q matrix of Kalman filter
      [A,B,C] = System(o,f,Ts);        % system model (oscillator)
      u = 0;                           % no input signal (irelevant)
      if (y > 0)
         I = eye(size(A));             % identity matrix
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P
         c = K * [y - C*(A*z + B*u)];  % observer state correction
      else
         c = 0*z;                      % disable correction
      end
      z = A*z + B*u + c;               % observer state update
      q = C*z;                         % reconstructed voltage
      p = 3*sqrt(norm(P));             % 3*sigma of P
      
      T0 = var(o,'T0');
      s = Shift(z,f,t) - T0*1000;      % calculate time shift
   end

      % prepare and init a log object
      
   oo = huck('boost');                % create a 'boost' typed object
   oo = log(oo,'t','ug','up','ur','s','e','p','b'); % setup data log object

      % setup parameters and system matrix
      
   o = Parameters(o);                  % parameter setup
   
      % init Kalman filter state
   
   z = [0;1];                          % unknown system state
   P = eye(2,2) * sigx^2;              % initial error covariance matrix

      % init system state

   [Un,f,T0] = var(o,'Un','f','T0');
   x0 = [0;Un*sqrt(2)];                % initial state
   x = System(o,f,-T0) * x0;           % actual system initial state  
   
      % run the system
      
   o = with(o,'simu');
   [T,Ts0] = Par(o,'T','Ts');          % get simulation parameters

   t = 0;
   for k = 1:T/Ts0                     % simulation loop
      [t,Ts] = Timing(o,t,Ts0);        % get new time (Ts = t - told)

         % measure grid voltage
         
      [up,ug,x] = Grid(o,t,Ts,x);
      
         % run kalman filter step
         
      [z,ur,P,p,s] = Kalman(o,t,z,P,up,Ts);

         % logging

      e = ur-ug;                       % observation error
      b = (abs(ug) > 2);               % dummy boost signal
      oo = log(oo,t,ug,up,ur,s,e,p,b); % record log data
    end
   
   PlotBoost(o,oo);                    % plot graphics
end
function o = SimuKalman3(o)            % Time Variant Kalman Simu      
%
% SIMUKALMAN3 Kalman Filter Simulation
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P

   function A = system(f,T)
      om = 2*pi*f;                     % omega (circular frequency)
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   end
   function T0 = shift(x,om,t)
      phi = atan2(x(1),x(2));          % phi = om*(t+T0)
      T0 = t - phi/om;
      periode = 2*pi/om;              
      T0 = rem(T0,periode)*1000;       % convert to ms (debug only)
   end

   oo = huck('boost');                % create a 'boost' typed object
   oo = log(oo,'t','ug','up','ur','s','e'); % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts] = Par(o,'T','Tp','Ts');

   o = with(o,'boost');
   [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
   [sigx,sigw,sigv] = Par(o,'sigx','sigw','sigv');
   
      % system matrices
      
   As = system(f+df,Ts);               % system matrix (oscillator)
   A = system(f,Ts);                   % system model (oscillator)
   B = [0;0];  C = [S 0];              % S: scale factor for measurement
   
      % initializing
   
%  sigx = 100;                         % +/-3*sigx = +/-300V
%  sigw = 0.1;                         % process noise
%  sigv = 0.1;                         % sigma of measurement noise
   
   x0 = [0;Un*sqrt(2)];                % initial state
   u = 0;                              % no input signal (irelevant)
   z = [0;1];                          % unknown system state
   I = eye(size(A));                   % identity matrix
   P = I*sigx^2;                       % initial error covariance matrix
   Q = I*sigw^2;                       % process covariance matrix
   R = sigv^2;                         % measurement covariance matrix

      % init system & observer state
      
   x = system(f,-T0) * x0;             % actual system initial state  
 
      % run the system
      
   t = Ts;
   for k = 1:T/Ts
      v  = sigv * randn;               % measurement noise
      w  = sigw * [randn randn]';      % process noise
%     y = C*x + v;                     % system output (grid voltage)

        % grid voltage measurement
        
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage 

        % Kalman filter

      q = C*z;                         % observer output

      if (up > 0)
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P

         y = up;                       % sensed line voltage
         c = K * [y - C*(A*z + B*u)];  % observer state correction
      else
         c = 0*z;                      % disable correction
      end
      z = A*z + B*u + c;               % observer state update

         % observation error
         
      e = C*(z-x);                     % observation error
      p = 3*sqrt(norm(P));             % 3*sigma of P

         % logging
      
      ur = C*z;                        % reconstructed voltage
      s = shift(z,om,t-Ts);            % calculate time shift
 %    e = ur - ug;                     % observation error
      
      oo = log(oo,t,ug,up,ur,s,e);     % record log data

         % state transition
         
      x = As*x;                        % system state transition
      t = t+Ts;                        % time transition
   end
   
   oo = set(oo,'title',sprintf(['Kalman Filter (%g ms) @ ',o.now],o.rd(s)));
   plot(oo);                           % plot graphics
end
function o = SimuKalman4(o)            % Time Variant Kalman Simu      
%
% SIMUKALMAN4 Kalman Filter Simulation
%
%        Time invariant observer for the system
%
%           x = A*x° + B*u° + w        % x,y,w,... means x(k),y(k),w(k),...
%           y = C*x  + v               % x°,u° means x(k-1),u(k-1)
%
%        and covariance matrices Q=E[w*w'), R=E[v*v']. The Kalman filter is
%        based on a model of the system equation based on an observed
%        state z which is augmented by a corrective term c.
%
%           z = A*z° + B*u° + c
%           c = K * [y - C*(A*z° + B*u°)]
%
%        where K is called the 'Kalman gain'. The Kalman gain K = K(k) is
%        calculated as the result of minimization of the error covariance
%        P = E[e*e'] where e := x - z. The result is a solution of recur-
%        sive Riccati equations:
%
%           M = A*P°*A' + Q            (1) short hand
%           K = M*C' / (C*M*C' + R)    (2) Kalman gain
%           P = (I - K*C) * M          (3) recursive update of P

   function A = system(f,T)
      om = 2*pi*f;                     % omega (circular frequency)
      A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
   end
   function T0 = shift(x,om,t)
      phi = atan2(x(1),x(2));          % phi = om*(t+T0)
      T0 = t - phi/om;
      periode = 2*pi/om;              
      T0 = rem(T0,periode)*1000;       % convert to ms (debug only)
   end

   oo = huck('boost');                % create a 'boost' typed object
   oo = log(oo,'t','ug','up','ur','s','e'); % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'simu');
   [T,Tp,Ts0] = Par(o,'T','Tp','Ts');

   o = with(o,'boost');
   [f,df,Un,T0,S] = Par(o,'f','df','Un','T0','S');
   [sigx,sigw,sigv,sigj] = Par(o,'sigx','sigw','sigv','sigj');
   
      % system matrices
      
%  As = system(f+df,Ts);               % system matrix (oscillator)
   A = system(f,Ts0);                  % system model (oscillator)
   B = [0;0];  C = [S 0];              % S: scale factor for measurement
   
      % initializing
   
%  sigx = 100;                         % +/-3*sigx = +/-300V
%  sigw = 0.1;                         % process noise
%  sigv = 0.1;                         % sigma of measurement noise
   
   x0 = [0;Un*sqrt(2)];                % initial state
   u = 0;                              % no input signal (irelevant)
   z = [0;1];                          % unknown system state
   I = eye(size(A));                   % identity matrix
   P = I*sigx^2;                       % initial error covariance matrix
   Q = I*sigw^2;                       % process covariance matrix
   R = sigv^2;                         % measurement covariance matrix

      % init system & observer state
      
   x = system(f,-T0) * x0;             % actual system initial state  
 
      % run the system
      
   t = 0;
   for k = 1:T/Ts0
      Ts = Ts0*max(0.5,1+sigj*randn);  % jittered sampling time

      v  = sigv * randn;               % measurement noise
      w  = sigw * [randn randn]';      % process noise
%     y = C*x + v;                     % system output (grid voltage)

        % grid voltage measurement
        
      ug = C*x;                        % grid voltage (noise free)
      up = max(-0.2,ug+v);             % sensed line voltage 

        % Kalman filter

      q = C*z;                         % observer output

      if (up > 0)
         M = A*P*A' + Q;               % (1) short hand
         K = M*C' / (C*M*C' + R);      % (2) Kalman gain
         P = (I - K*C) * M;            % (3) recursive update of P

         y = up;                       % sensed line voltage
         c = K * [y - C*(A*z + B*u)];  % observer state correction
      else
         c = 0*z;                      % disable correction
      end
      z = A*z + B*u + c;               % observer state update
      A = system(f,Ts);                % system model (oscillator)

         % observation error
         
      e = C*(z-x);                     % observation error
      p = 3*sqrt(norm(P));             % 3*sigma of P

         % logging
      
      ur = C*z;                        % reconstructed voltage
%     s = shift(z,om,t-Ts);            % calculate time shift
      s = shift(z,om,t);               % calculate time shift
%     e = ur - ug;                     % observation error
      
      oo = log(oo,t,ug,up,ur,s,e);     % record log data

         % state transition
         
      As = system(f+df,Ts);            % system matrix (oscillator)
      x = As*x;                        % system state transition
      t = t + Ts;                      % time transition
    end
   
   oo = set(oo,'title',sprintf(['Kalman Filter (%g ms) @ ',o.now],o.rd(s)));
   plot(oo);                           % plot graphics
end
function o = PlotBoost(o,oo)           % Plot Graphics for Boost       
   oo = set(oo,'title',['Triac & Boost Control @ ',o.now]);
   plot(oo);
   mode = setting(o,'mode.signal');    % get signal mode
   switch mode
      case {'Grid','Default'}
         subplot(222);
         title(sprintf('Uncertainty @ 3 Sigma'));
      case {'Control'}
         subplot(221);
         Phi = Par(o,'boost.phi');
         title(sprintf('Triac Control (Phi = %g°)',Phi));

         subplot(222);
         title(sprintf('Boost Signal'));
   end
   switch mode
      case {'All','Control'}
         subplot(223);
         T0 = Par(o,'boost.T0');
         title(sprintf('Phase Angle Estimation Error [ms] @ T0 = %g ms',T0));

         subplot(224);
         title(sprintf('Grid Voltage Prediction Error (after step down)'));
   end
end
function o = BoostParameters(o)        % Kalman Parameters Sub Menu    
   oo = mitem(o,'Parameters');
   ooo = Charm(oo,'f: Frequency [Hz]','','boost.f',50); 
   ooo = Charm(oo,'df: Frequency Error [Hz]','','boost.df',0); 
   ooo = Charm(oo,'Un: RMS Mains Voltage [V]','','boost.Un',230); 
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'T0: Time Shift [ms]','','boost.T0',2); 
   ooo = Charm(oo,'S: Voltage Scaling Factor [1]','','boost.S',0.0075);
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Phi: Phase Control Angle [°]','','boost.phi',60); 
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'sigx: Initial Uncertainty','','boost.sigx',100); 
   ooo = Charm(oo,'sigw: Process Noise','','boost.sigw',0.1); 
   ooo = Charm(oo,'sigv: Measurement Noise','','boost.sigv',0.1); 
   ooo = Charm(oo,'sigj: Timing Jitter','','boost.sigj',0.1); 
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Charm(o,label,cblist,tag,default)  % Create Charm Item   
   setting(o,{tag},default);
   oo = mitem(o,label,cblist,tag); 
   charm(oo,{});
end
function y = Sigma(t,T)                % Sigma Function                
   if (t >= T)
      y = 1;
   else
      y = 0;
   end
end
function varargout = Par(o,varargin)   % Get Parameter                 
   if (nargout ~= nargin-1)
      error('number of input & output args not matching!');
   end
   
   for (i=1:length(varargin))
      tag = varargin{i};
      [unit,factor] = Unit(o,tag);
      value = opt(o,tag) * factor;
      varargout{i} = value;
   end
end
function [unit,factor] = Unit(o,tag)   % Get Unit and Factor           
   unit = '';  factor = 1;             % default
   switch tag
      case {'C','C1','C2'}
         unit = 'µF';  factor = 1e-6;
      case {'L','L1','L2'}
         unit = 'µH';  factor = 1e-6;
      case {'R','R0','R1','R2','R3','R4'}
         unit = 'Ohm'; factor = 1;
      case {'RA','RB'}
         unit = 'MOhm'; factor = 1e6;
      case {'T','Tp','T0'}
         unit = 'ms';  factor = 1e-3;
      case {'Ts'}
         unit = 'µs';  factor = 1e-6;
      case {'Uc','Uz','UZ','Um','Un'}
         unit = 'V';  factor = 1;
      case {'I','i1','i2','i'}
         unit = 'mA';  factor = 1e-3;
      case {'il'}
         unit = 'A';  factor = 1;
      case {'f','f0'}
         unit = 'Hz';  factor = 1;
      case {'Phi'}
         unit = '°';  factor = pi/180;
   end
end
function o = Component(o,name,id)      % Component Definition          
%
% COMPONENT Use component
%
%    Component(o,'Phase Cut R')        % init component list
%    Component(o)                      % add separator
%    Component(o,'C1','4.7µF@10V')     % add to component list
%    Component(o,'C2','10µF@6.3V')     % add to component list
%
   if (nargin == 1) && (nargout == 0)
      list = setting(o,{'component',{}});
      list{end+1} = [];
   elseif (nargin == 1) && (nargout == 1)
      list = setting(o,{'component',{''}});
      o = list{1};
      return
   elseif (nargin == 2)
      list = {name};
   else
      list = setting(o,{'component',{}});
      list{end+1} = {name,id};
   end
   setting(o,'component',list);
end
function oo = Zoom(o)                  % Zoom Scenario                 
   if opt(o,'study.zoom');
      kids = get(figure(o),'Children');
      for(i=length(kids):-1:1)
         kid = kids(i);
         type = get(kid,'type');
         if isequal(type,'axes')
            set(kid,'xlim',[9.5,10.5]);
         end
      end
   end
   oo = o;
end
function o = Plot(o)                   % Plot Object                   
   switch o.type
      case 'buck'
         o = PlotBuck(o);
      case 'pcut'
         o = PlotPcut(o);
      case 'capa'
         o = PlotCapa(o);
      otherwise
         error('type not supported');
   end
   function o = PlotBuck(o)            % Plot Pcut Typed Object
      rd = @(x)carabull.rd(x,1);       % short hand

      [R1,R2,C,L] = var(o,'R1','R2','C','L');
      txt11 = sprintf('R1 = %gOhm, R2 = %gOhm, C = %gµF, L = %gµH',...
                      R1,R2,C*1e6,L*1e6);

      [f,Uz,du,f0,duty] = var(o,'f','Uz','du','f0','duty');
      txt12 = sprintf('f = %gkHz, f0 = %gkHz, duty = %g, Uz = %gV, du = %gmV',...
                     rd(f/1000),f0/1000,duty,Uz,round(du*1000));

      [Ts,usmax,i1max,Q] = var(o,'Ts','usmax','i1max','Q');
      txt21 = sprintf('Ts = %gms, usmax = %gV,  i1max = %gA, Q = %gmAs',...
                      Ts*1e6,rd(usmax),rd(i1max),rd(Q*1e3));

      [I,Iq,P] = var(o,'I','Iq','P');
      txt22 = sprintf('I = %gmA, Iq = %gmA, P = %gmW',...
                      I*1e3,rd(Iq*1e3),round(P*1e3));

         % plot data

      o = set(o,'title',Component(o));
      plot(o);

         % post processing

      txt = {[txt11,', ',txt12],[txt21,', ',txt22]};
      kids = get(gcf,'Children');
      j = 1;
      for(i=length(kids):-1:1)
         kid = kids(i);
         type = get(kid,'type');
         if isequal(type,'axes') && (j <= length(txt))
            txtj = txt{j};  j = j+1;
            xlabel(kid,txtj);
         end
      end
   end
   function o = PlotPcut(o)            % Plot Pcut Typed Object        
      rd = @(x)carabull.rd(x,1);          % short hand

      [R,R1,R2,C] = var(o,'R','R1','R2','C');
      txt11 = sprintf('R = %gOhm, R1 = %gOhm, R2 = %gOhm, C = %gµF',...
                      R,R1,R2,C*1e6);

      [f,Uc,UZ,Uz,du] = var(o,'f','Uc','UZ','Uz','du');
      txt12 = sprintf('f = %gkHz, Uc = %gV, UZ = %gV, Uz = %gV, du = %gmV',...
                     rd(f/1000),Uc,UZ,Uz,round(du*1000));

      [Ts,usmax,i1max,Q] = var(o,'Ts','usmax','i1max','Q');
      txt21 = sprintf('Ts = %gms, usmax = %gV,  i1max = %gA, Q = %gmAs',...
                      Ts*1e6,rd(usmax),rd(i1max),rd(Q*1e3));

      [I,Iq,P] = var(o,'I','Iq','P');
      txt22 = sprintf('I = %gmA, Iq = %gmA, P = %gmW',...
                      I*1e3,rd(Iq*1e3),round(P*1e3));

         % plot data

      o = set(o,'title',Component(o));
      plot(o);

         % post processing

      txt = {[txt11,', ',txt12],[txt21,', ',txt22]};
      kids = get(gcf,'Children');
      j = 1;
      for(i=length(kids):-1:1)
         kid = kids(i);
         type = get(kid,'type');
         if isequal(type,'axes') && (j <= length(txt))
            txtj = txt{j};  j = j+1;
            xlabel(kid,txtj);
         end
      end
   end
   function o = PlotCapa(o)            % Plot Capa Typed Object        
      rd = @(x)carabull.rd(x,1);       % short hand

         % plot data

      o = set(o,'title',Component(o));
      plot(o);

         % post processing

      txt = get(o,'comment');  txt(1) = [];
      kids = get(gcf,'Children');
      j = 1;
      for(i=length(kids):-1:1)
         kid = kids(i);
         type = get(kid,'type');
         if isequal(type,'axes') && (j <= length(txt))
            txtj = txt{j};  j = j+1;
            xlabel(kid,txtj);
         end
      end
   end
end
function Schematics(o,imagefile,title) % Show Schematics               
   setting(o,'study.schematics',imagefile);
   Component(o,title);              % init component list
end
