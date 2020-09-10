function oo = simu(o,varargin)         % Simulation Menu               
%
% SIMU   Manage simulation menu
%
   [gamma,oo] = manage(o,varargin,@Setup,@Zmovement,@IndexingStroke,...
                @MotionPlot,@DutyPlot,...
                @YieldMode,@YieldMode1,@AccuracyMode,@ThroughputMode,@JandlIteration,...
                @FullCycle,@Dependance,@SimpleAlignment,@MultiHead);
   oo = gamma(oo);
end

%==========================================================================
% Setup Simu Menu
%==========================================================================

function o = Setup(o)                  % Setup Simulation Menu         
   o = Init(o);                        % init design parameters
   oo = mhead(o,'Ultra');
%  ooo = mitem(oo,'Simple Alignment',{@SimpleAlignment});
%  ooo = mitem(oo,'-');
   ooo = Parameters(oo);
   ooo = MotionStudies(oo);
   ooo = mitem(oo,'-');
   ooo = CycleStudies(oo);             % Cycle Studies
   ooo = KalmanStudies(oo);            % Kalman Filter Studies
end
function o = Init(o)                   % Initialize Settings           
   Default(o,'head.number',4);         % number of bond heads
   Default(o,'head.distance',50);      % distance between bond heads

   Default(o,'diesize.min',0.5);       % min die size
   Default(o,'diesize.max',25);        % max die size
   Default(o,'diesize.actual',2);      % actual die size
   
   Default(o,'z.stroke',0.5);          % z working stroke
   Default(o,'z.over',0.5);            % z overtravel
   Default(o,'z.vmax',2500);           % bonding z max velocity 
   Default(o,'z.amax',25000);          % bonding z max acceleration 
   Default(o,'z.tj',0.01);             % bonding z jerk time 

   Default(o,'xy.vmax',2500);          % xy max velocity 
   Default(o,'xy.amax',25000);         % xy max acceleration 
   Default(o,'xy.tj',0.01);            % xy jerk time 

   Default(o,'camdelay.small',10);     % small camera delay 
   Default(o,'camdelay.large',50);     % large camera delay 
   Default(o,'camdelay.huge',150);     % huge camera delay 
   
   Default(o,'capture.small',10);      % small capture time 
   Default(o,'capture.large',50);      % large capture time
   Default(o,'capture.huge',100);      % huge capture time 
   
%    Default(o,'correct.smax',0.01);     % correction max velocity 
%    Default(o,'correct.vmax',2000);     % correction max velocity 
%    Default(o,'correct.amax',5000);     % correction max acceleration 
%    Default(o,'correct.tj',0.02);       % correction jerk time 

   Default(o,'park.smax',175);         % xy max velocity 
   Default(o,'park.vmax',3000);        % xy max velocity 
   Default(o,'park.amax',25000);       % xy max acceleration 
   Default(o,'park.tj',0.01);          % xy jerk time 
   
   Default(o,'pick.delay',80);         % pick delay
   Default(o,'bond.delay',160);        % bond delay
   
   Default(o,'park.distance',175);     % distance to park position
end
function Default(o,tag,value)          % Provide Default Setting       
   setting(o,{Tag(tag)},value);        % provide default setting
end
function Setting(o,tag,value)          % Change Setting                
   %setting(o,['simu.',tag],value);    % change setting
   charm(o,Tag(tag),value);            % change setting
end

%==========================================================================
% Cycle Studies
%==========================================================================

function o = CycleStudies(o)           % Cycle Studies                 
   oo = mitem(o,'Cycle Studies');
   ooo = mitem(oo,'Throughput Mode',{@invoke,mfilename,@ThroughputMode});
   ooo = mitem(oo,'Accuracy Mode',{@invoke,mfilename,@AccuracyMode});
   ooo = mitem(oo,'Yield Mode',{@invoke,mfilename,@YieldMode});
   ooo = mitem(oo,'Jandl Iteration',{@invoke,mfilename,@JandlIteration});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Dependance',{@invoke,mfilename,@Dependance});
end
function o = ThroughputMode(o)         % Throughput Mode Bond Cyc Study
   PickPlace(o,'throughput');
end
function o = AccuracyMode(o)           % Accuracy Mode Bond Cycle Study              
   PickPlace(o,'accuracy');
end
function o = YieldMode(o)              % Yield Mode Bond Cycle Study              
   PickPlace(o,'yield');
end
function o = JandlIteration(o)         % Jandl Iteration Cycle Study              
   PickPlace(o,'jandl');
end
function o = PickPlace(o,mode)         % Accuracy Mode Bond Cycle Study              
   gray = 0.9*[1 1 1];
   fprintf('Full Bond Cycle Parameters\n');
   
      % Travel Parameters
      
   xytr = Motion(o,'travel');          % motion of index
   fprintf('   Travel: %g mm @ %g ms\n',xytr.s,xytr.t);

   p = Motion(o,'pick');               % motion of pick z movement
   fprintf('   Pick-z: %g mm @ %g ms\n',p.s,p.t);

   pick.t = opt(o,Tag('pick.delay'));  % pick delay
   fprintf('   Pick Delay: %g ms\n',pick.t);

   xyco = Motion(o,'correct');         % motion of correction
   fprintf('   Correction: %g mm @ %g ms\n',xyco.s,xyco.t);

   xy2mm = Motion(o,'two');           % motion of 5mm shift
   fprintf('   2mm Shift: %g mm @ %g ms\n',xy2mm.s,xy2mm.t);

   xy5mm = Motion(o,'five');           % motion of 5mm shift
   fprintf('   5mm Shift: %g mm @ %g ms\n',xy5mm.s,xy5mm.t);
   
      % Upward Camera
      
   u = Motion(o,'ucam');               % motion of pick z movement
   fprintf('   Move to UC: %g mm @ %g ms\n',u.s,u.t);

   switch mode
      case {'yield','jandl'}
         ulc.d = opt(o,Tag('camdelay.small'));   % UC camera delay
         ulc.c = opt(o,Tag('capture.small'));    % UC capture time
      otherwise
         ulc.d = opt(o,Tag('camdelay.huge'));    % UC camera delay
         ulc.c = opt(o,Tag('capture.huge'));     % UC capture time
   end
   fprintf('   UC delay: %g ms\n',ulc.d);
   fprintf('   UC capture: %g ms\n',ulc.c);

      % Correction
      
   ulc.s = xyco.s;                     % UC iteration stroke 
   ulc.t = xyco.t;                     % UC iteration time
   fprintf('   UC move: %g mm @ %g ms \n',ulc.s,ulc.t);
   
      % Substrate Camera
      
   switch mode
      case {'yield','jandl'}
         suc.d = opt(o,Tag('camdelay.small'));   % UC camera delay
         suc.c = opt(o,Tag('capture.small'));    % UC capture time
      otherwise
         suc.d = opt(o,Tag('camdelay.huge'));    % UC camera delay
         suc.c = opt(o,Tag('capture.huge'));     % UC capture time
   end
   fprintf('   SC delay: %g ms\n',suc.d);
   fprintf('   SC capture: %g ms\n',suc.c);

   suc.s = xyco.s;                     % SC iteration stroke 
   suc.t = xyco.t;                     % SC iteration time
   fprintf('   SC move: %g mm @ %g ms \n',suc.s,suc.t);
   
      % Bonding
   
   z = Motion(o,'bond');               % motion of bond z movement
   fprintf('   Bond-z: %g mm @ %g ms\n',z.s,z.t);
   
   bond.t = opt(o,Tag('bond.delay'));  % pick delay
   fprintf('   Bond Delay: %g ms\n',bond.t);

      % Setup Process Steps
      
   xypk = ramp(dproc('XY->PK'),xytr.t,[2 2],gray);
   
   pd = ramp(dproc('PD'),p.t,[2 1],'d');
   p0 = ramp(dproc('PICK'),pick.t,[1 1],'g');
   pu = ramp(dproc('PU'),p.t,[1 2],'d');

   xyuc = ramp(dproc('XY->UC'),u.t,[2 2],gray);
   ud = ramp(dproc('UD'),ulc.d,[2 2],'c');
   uc = ramp(dproc('UC'),ulc.c,[2 2],'b');
   um = ramp(dproc('Uk'),ulc.t,[2 2],gray);

   xysc = ramp(dproc('XY->SC'),xytr.t,[2 2],gray);
   sd = ramp(dproc('SD'),suc.d,[2 2],'c');
   sc = ramp(dproc('SC'),suc.c,[2 2],'m');
   sm = ramp(dproc('SM'),suc.t,[2 2],gray);
   
   xybd = ramp(dproc('XY->BD'),xy5mm.t,[2 2],gray);
   bd = ramp(dproc('BOND'),bond.t,[1 1],'y');
   zu = ramp(dproc('ZU'),z.t,[1 2],'y');
   switch mode
      case {'yield','jandl'}
         zd = ramp(dproc('ZD'),z.t,[2 1.2],'y');
      otherwise
         zd = ramp(dproc('ZD'),z.t,[2 1.08],'y');
   end

   sc0 = ramp(dproc('SC0'),suc.c,[1.2 1.2],'m');
   sm0 = ramp(dproc('SM0'),suc.t,[1.20 1.00],gray);

   sc1 = ramp(dproc('SC1'),suc.c,[1.2 1.2],'m');
   sm1 = ramp(dproc('SM1'),suc.t,[1.20 1.16],gray);

   sc2 = ramp(dproc('SC2'),suc.c,[1.16 1.16],'m');
   sm2 = ramp(dproc('SM2'),suc.t,[1.16 1.12],gray);
   
   sc3 = ramp(dproc('SC3'),suc.c,[1.12 1.12],'m');
   sm3 = ramp(dproc('SM3'),suc.t,[1.12 1.08],gray);
   
   sc4 = ramp(dproc('SC4'),suc.c,[1.08 1.08],'m');
   sm4 = ramp(dproc('SM4'),suc.t,[1.08 1.04],gray);
   
   sc5 = ramp(dproc('SC5'),suc.c,[1.04 1.04],'m');
   sm5 = ramp(dproc('SM5'),suc.t,[1.04 1.00],gray);
   
   switch mode
      case 'accuracy'
         chn = chain(dproc('z motion'),...
                  xypk,pd,p0,pu,...
                  xyuc,ud,uc,um,uc,...
                  xysc,sd,sc,sm,sc,...
                  xybd,zd,sc4,sm4,sc5,sm5,bd,zu);
         prc = process(dproc('Accuracy Mode'),chn);

      case 'throughput'
         zd = ramp(dproc('ZD'),z.t,[2 1],'y');
         chn = chain(dproc('z motion'),...
                  xypk,pd,p0,pu,...
                  xyuc,ud,uc,...
                  xysc,sd,sc,...
                  xybd,zd,bd,zu);
         prc = process(dproc('Throughput Mode'),chn);
 
      case 'yield'
         chn = chain(dproc('z motion'),...
                  xypk,pd,p0,pu,...
                  xyuc,ud,uc,um,uc,um,uc,um,uc,uc,uc,uc,uc,uc,uc,...
                  xysc,sd,sc,sc,sc,sc,sc,sc,sc,sc,sc,sc,...
                  xybd,zd,sc1,sc1,sc1,sc1,sc1,sc1,sm1,sc2,sm2,sc3,sm3,sc4,sm4,sc5,sm5,bd,zu);
         prc = process(dproc('Yield Mode'),chn);

      case 'jandl'
         chn = chain(dproc('z motion'),...
                  xysc,sd,sc,sc,sc,sc,sc,sc,sc,sc,sc,sc,...
                  xybd,zd,sc1,sc1,sc1,sc1,sc1,sc1,sm1,sc2,sm2,sc3,sm3,sc4,sm4,sc5,sm5,bd);
         prc = process(dproc('Jandl Iteration'),chn);
   end
   
   plot(prc);
   Tcy = duration(chn);
   uph = 2*3600 / (Tcy/1000);
   xlabel(sprintf('Cycle time: %g ms (%g UPH)',o.rd(Tcy,0),o.rd(uph,-1)));
end

function o = FullCycle(o)              % Full Cycle Study              
   rd = @carma.rd;                     % need some utility

   n = arg(o,1);
   if isempty(n)
      n = opt(o,Tag('head.number'));   % number of bond heads
   end
   list = {};

   fprintf('Full Bond Cycle Parameters\n');
   x = Motion(o,'index');             % motion of index
   fprintf('   Index: %g mm @ %g ms\n',x.s,x.t);

   z = Motion(o,'bond');               % motion of bond z movement
   fprintf('   Bond-z: %g mm @ %g ms\n',z.s,z.t);
   
   b.t = opt(o,Tag('bond.delay'));     % bond delay
   fprintf('   Bond Delay: %g ms\n',b.t);
   
   for (i=1:n)
      zd = ramp(dproc(sprintf('ZD%g',i)),z.t,[2 1],'m');
      zb = ramp(dproc(sprintf('BD%g',i)),b.t,[1 1],'y');
      zu = ramp(dproc(sprintf('ZU%g',i)),z.t,[1 2],'m');
   
      list = [list,{zd,zb,zu}];

      if (i < n)
         xy = ramp(dproc(sprintf('XY%g',i)),x.t,-[1 1],'g');
         list{end+1} = xy;
      end
   end
   
   p = Motion(o,'park');
   fprintf('   Park-x: %g mm @ %g ms\n',p.s,p.t);
   u.t = 10;                           % upward camera time
   fprintf('   Upward Camera: %g ms\n',u.t);

   xp1 = ramp(dproc('XY-'),p.t,-[1 1],'g');
   uc = ramp(dproc('UC'),u.t,[1 1],'b');
   xp2 = ramp(dproc('XY+'),p.t,-[1 1],'g');
   
   pick.t = 20;                           % pick delay
   
   zld = ramp(dproc('ZLD'),z.t,[2 1],'m');
   zlp = ramp(dproc('PI'),pick.t,[1 1],'c');
   zlu = ramp(dproc('ZLU'),z.t,[1 2],'m');
   
      % load bond heads, remove robot hand, uc, back table for bond
      
      
   r.t = 60;                           % 60 ms for removal of robot hand
   ro = ramp(dproc('RO'),r.t,-[1 1],'r');
   
   list = [list,{xp1,zld,zlp,zlu,ro,uc,xp2}];
   
   chn = chain(dproc('z motion'),list);
   str = o.iif(n==1,'1 head',sprintf('%g heads',n));
   prc = process(dproc(sprintf('Bond Sequence (%s)',str)),chn);
   plot(prc);
   
      % calculate bond cycle time
    
   Tcy = 2*n*z.t + n*b.t + (n-1)*x.t + 2*p.t + u.t + 2*z.t+pick.t+r.t; 
   
   uph = n*3600/(Tcy/1000);
   xlabel(sprintf('Cycle time: %g ms (%g UPH)',rd(Tcy),rd(uph,-1)));
end
function o = Dependance(o)             % Dependance Study              
   verbose = control(o,'verbose');
   fprintf('Full Bond Cycle Parameters\n');
   x = Motion(o,'index');              % motion of index
   fprintf('   Index: %g mm @ %g ms\n',x.s,x.t);

   z = Motion(o,'bond');               % motion of bond z movement
   fprintf('   Bond-z: %g mm @ %g ms\n',z.s,z.t);
   
   b.t = 50;                           % bond delay
   fprintf('   Bond Delay: %g ms\n',b.t);

   zd = ramp(dproc('ZD','',{{'ZU','XY2'}}),z.t,[2 1],'b');
   zb = ramp(dproc('ZB','',{{'ZD'}}),b.t,[1 1],'y');
   zu = ramp(dproc('ZU','',{{'ZB'}}),z.t,[1 2],'b');
   
   zmot = chain(dproc('z motion'),zd,zb,zu);
   
   xyw = ramp(dproc('XYW','',{{'XY2'}}),0,[2 2],'k');
   xy1 = ramp(dproc('XY1','',{{'XYW','ZU'}}),x.t,[2 1],'g');
   xy2 = ramp(dproc('XY2','',{{'XY1'}}),x.t,[1 2],'g');
   
   xymot = chain(dproc('xy motion'),xyw,xy1,xy2);
   
   prc = process(dproc('Bond Sequence'),zmot,xymot);
   prc = schedule(prc,400,verbose);   % stop after 400 ms
   plot(prc);
   
   Tcy = 2*z.t + b.t + x.t;  % bond cycle time
   xlabel(sprintf('Cycle time: %g ms',o.rd(Tcy)));
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Slow Settings',{@SlowSettings});
   ooo = mitem(oo,'Fast Settings',{@FastSettings});

   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Bond Heads');
   oooo = Charm(ooo,'Number [#]','head.number');
   oooo = Charm(ooo,'Distance [mm]','head.distance');
   
   ooo = mitem(oo,'Die Size');
   oooo = Charm(ooo,'Min [mm]','diesize.min');
   oooo = Charm(ooo,'Max [mm]','diesize.max');
   
   ooo = mitem(oo,'Strokes');
   %oooo = mitem(ooo,'Indexing Stroke',{@invoke,mfilename,@IndexingStroke});
   oooo = MotionParameters(ooo,'X/Y: Long Travel','travel',250,2000,10000,0.03);
   oooo = MotionParameters(ooo,'X/Y: Move to UC','ucam',80,2000,20000,0.03);
   oooo = MotionParameters(ooo,'X/Y: Correction','correct',0.01,2000,220,0.01);
   oooo = MotionParameters(ooo,'K: 5mm Shift','five',5,2000,5000,0.03);
   oooo = MotionParameters(ooo,'K: 2mm Shift','two',2,2000,5000,0.03);
   oooo = MotionParameters(ooo,'Z: Bonding','bond',1,5,5000,0.01);

   ooo = mitem(oo,'Camera Delay');
   oooo = Charm(ooo,'Small [ms]','camdelay.small');
   oooo = Charm(ooo,'Large [ms]','camdelay.large');
   oooo = Charm(ooo,'Huge [ms]','camdelay.huge');

   ooo = mitem(oo,'Capture Time');
   oooo = Charm(ooo,'Small [ms]','capture.small');
   oooo = Charm(ooo,'Large [ms]','capture.large');
   oooo = Charm(ooo,'Huge [ms]','capture.huge');
   
   ooo = MotionParameters(oo,'Parking','park',200,3000,25000,0.01);

   ooo = MotionParameters(oo,'Picking','pick',1,5,5000,0.01);
   ooo = Charm(ooo,'Delay [ms]','pick.delay');
   
   oooo = mitem(ooo,'-');
   oooo = Charm(ooo,'Bond Delay [ms]','bond.delay');
   
   
   ooo = mitem(oo,'Z-Motion',{@invoke,mfilename,@Zmovement});
end
function o = SlowSettings(o)           % Change to Slow Parameters     
   Setting(o,'camdelay.huge',150);     % huge camera delay 
   Setting(o,'capture.huge',100);      % huge capture time 
   Setting(o,'pick.vmax',5);           % slow pick velocity 
   refresh(o);
end
function o = FastSettings(o)           % Change to Fast Parameters     
   Setting(o,'camdelay.huge',100);     % huge camera delay 
   Setting(o,'capture.huge',50);       % huge capture time 
   Setting(o,'pick.vmax',7.5);         % fast pick velocity 
   refresh(o);
end
function oo = MotionParameters(o,label,tag,smax,vmax,amax,tj)          
%
% PARAMETER-SET   Add charm menu items for parameter settings
%
%                    oo = Parameters(o,'Parking','park',200,3000,25000,0.01);
%
   context = Tag([tag,'.']);           
   setting(o,{[context,'smax']},smax); % park motion parameter smax
   setting(o,{[context,'vmax']},vmax); % park motion parameter vmax
   setting(o,{[context,'amax']},amax); % park motion parameter amax
   setting(o,{[context,'tj']},tj);     % park motion parameter tj

   context = [tag,'.'];           
   oo = mitem(o,label);
   ooo = mitem(oo,'Motion',{@invoke,mfilename,@MotionPlot,tag});
   ooo = mitem(oo,'Duty',{@invoke,mfilename,@DutyPlot,tag});
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Stroke [mm]',[context,'smax']);
   ooo = Charm(oo,'Velocity [mm/s]',[context,'vmax']);
   ooo = Charm(oo,'Acceleration [mm/s2]',[context,'amax']);
   ooo = Charm(oo,'Jerk Time [s]',[context,'tj']);
end
function o = MotionPlot(o)             % Motion Plot Callback          
   tag = arg(o,1);                     % get tag argument
   Motion(o,tag);
end
function o = DutyPlot(o)               % Motion Plot Callback          
   tag = arg(o,1);                     % get tag argument
   Duty(o,tag);
end
function o = IndexingStroke(o)         % Index Stroke                  
   oo = with(o,Tag('head'));
   n = opt(oo,'number');               % number of bond heads
   d = opt(oo,'distance');             % distance of bond heads
   
   amin = opt(o,Tag('diesize.min'));
   amax = opt(o,Tag('diesize.max'));
   
   pitches = amin:0.1:amax;
   for (i = 1:length(pitches))
      p = pitches(i);
      mnp = (0:1000)*n*p;
      delta = mnp + p - d;
      stroke = min(abs(delta));
      idx = min(find(abs(delta)==stroke));
      
      gaps(i) = mnp(idx) / (n*p);     % gap in number of pitches
      strokes(i) = delta(idx);        % stroke to move
   end
   
   cls(o);                            % clear screen
   
   subplot(211);
   stem(pitches,strokes,'m');         % plot stroke
   smax = max(abs(strokes));
   title(sprintf('Indexing Stroke over Pitch (max stroke: %g mm)',smax));

   subplot(212);
   stem(pitches,gaps,'g');            % plot stroke
   title(sprintf('Gap between bond columns [number of pitches]'));
   
   o = opt(o,Tag('index.smax'),smax);
   bag = Motion(o,'index');
   
   xlabel(sprintf('%g bond heads with %g mm distance (%g ms)',n,d,bag.t));
   grid(o.iif(opt(o,'view.grid'),'on','off'));
end
function o = Zmovement(o)              % Plot Z-Motion                 
   Zmotion(o);                         % plot z-motion
   tmax = Zmotion(o);                  % get max time
   title(sprintf('Motion time: %g ms',Ms(tmax)));
end

%==========================================================================
% Motion Studies
%==========================================================================

function o = MotionStudies(o)          % Motion Studies                              
   oo = mitem(o,'Motion Studies');
   ooo = MotionParameters(oo,'Generic','generic',10,3000,25000,0.01);
end

%==========================================================================
% Kalman Studies
%==========================================================================

function o = KalmanStudies(o)          % Motion Studies                              
   oo = mitem(o,'Kalman Studies');
   ooo = mitem(oo,'Simple Alignment',{@SimpleAlignment});
end

function oo = SimpleAlignment(o)       % Simple Alignment              
   oo = new(o);
   [t,x,y] = data(oo,'t','x','y');
   
   a = 0.0;                            % init value of filter coefficient
   b = 0.9;                            % end value of filter coefficient
   sigx = 50;                          % stddev of x measurement
   Xk = 2000;                          % 2000 nm initial position
   xt = 0;                             % target x
   xf = 0;                             % initialize filter state
   n = 10;
   
   for (k=1:length(t))
      X(k) = Xk;                       % update position
      x(k) = Xk + sigx*randn;          % actual measurement of x
      xf = a*xf + (1-a)*x(k);          % filtered x measurement
      ex = xf - xt;                    % actual estimated error
      a = b - (b-a)^1.5;               % filter adaption
      
      Xk = Xk - ex;                    % apply x-correction
      xf = xf - ex;
   end
      
   y = X;
   oo = data(oo,'x',x','y',y);
   
   oo = category(oo,1,[-200 200],[0 0],'nm');
   paste(o,{oo});
   return
   
   function o = Config(o)
      
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function tag = Tag(suffix)             % Create Full Tag               
%
% TAG   Create a full tag, given pos fix tag
%
%          tag = Tag('z')              % tag = 'ultra.z'
%          tag = Tag('slow.stroke')    % tag = 'ultra.slow.stroke'
%
   tag = ['ultra.',suffix];
end
function oo = Charm(o,label,tag)       % Add Charm Menu Item           
%
% CHARM   Setup a menu item with CHARM functionality
%
   oo = mitem(o,label,{},Tag(tag));
   charm(oo,{});
end
function [tmax,smax,vmax,amax,tj] = Zmotion(o)                         
%
% Z-MOTION   Calculate z-motion time or draw z-motion plot
%
%               [tmax,zmax,vmax,amax,tj] = Zmotion(o)   % calculate
%               Zmotion(o)                              % plot
%
   oo = with(o,Tag('z'));
   stroke = opt(oo,'stroke');
   over = opt(oo,'over');
   
   smax = stroke + over;
   vmax = opt(oo,'vmax');
   amax = opt(oo,'amax');
   tj = opt(oo,'tj');

   if (nargout == 0)
      motion(o,smax,vmax,amax,tj);
   else
      tmax = motion(o,smax,vmax,amax,tj);
   end
end
function [out,smax,vmax,amax,tj] = Motion(o,tag) % Generic Motion [ms] 
%
% MOTION   Calculate generic motion time or draw generic timing [ms]
%
%               [tmax,smax,vmax,amax,tj] = Motion(o,'park') % calculate
%               Motion(o,'park')                            % plot
%
%          With 1 output arg all parameters are packed into a structure
%
%               bag = Motion(o,'park')                      % calculate
%
%          We get:
%               bag.t    (tmax)
%               bag.s    (smax)
%               bag.v    (vmax)
%               bag.a    (amax)
%               bag.tj   (tj)
%               

   oo = with(o,Tag(tag));
   parent = get(work(o,'object'),'parent');
   label = get(parent,'label');
   oo = opt(oo,'info',[label,' Motion Profile']);
   oo = carasim(oo);
   
   if (nargout == 0)
      %motion(oo,smax,vmax,amax,tj);
      motion(oo);
   else
      %tmax = motion(oo,smax,vmax,amax,tj);
      tmax = motion(oo);
      if (nargout == 0)
         out = Ms(tmax);
      else
         out.t = Ms(tmax);
         out.s = opt(oo,'smax');
         out.v = opt(oo,'vmax');
         out.a = opt(oo,'amax');
         out.tj = opt(oo,'tj');
      end
   end
end
function [out,smax,vmax,amax,tj] = Duty(o,tag)   % Generic Duty        
%
% DUTY   Calculate generic motion time or draw generic timing [ms]
%
%           Duty(o,'park')                        % plot
%
   oo = with(o,Tag(tag));
   parent = get(work(o,'object'),'parent');
   label = get(parent,'label');
   oo = opt(oo,'info',[label,' Motion Profile']);
   oo = carasim(oo);
   
   duty(oo);
end
function ms = Ms(t,n)                  % Convert [s] to (rounded) [ms] 
%
% MS   Convert seconds to mili seconds (rounded)
%
   if (nargin == 1)
      n = 0;
   end
   ms = carma.rd(1000*t,n);
end
