function oo = jumbo(o,varargin)         % Jumbo Menu                   
%
% JUMBO   Manage Jumbo menu
%
   [gamma,oo] = manage(o,varargin,@Setup,@Zmovement,@IndexingStroke,...
                @MotionPlot,@DutyPlot,...
                @YieldMode,@YieldMode1,@AccuracyMode,@ThroughputMode,@JandlIteration,...
                @FullCycle,@Dependance,@SimpleAlignment,@MultiHead);
   oo = gamma(oo);
end

%==========================================================================
% Setup Jumbo Menu
%==========================================================================

function o = Setup(o)                  % Setup Jumbo Menu              
   o = Init(o);                        % init design parameters
   oo = mhead(o,'Jumbo');
   ooo = Parameters(oo);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Slow Settings',{@SlowSettings});
   ooo = mitem(oo,'Fast Settings',{@FastSettings});
   ooo = mitem(oo,'-');
   ooo = JumboStudies(oo);
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

   Default(o,'xy.vmax',3000);          % xy max velocity 
   Default(o,'xy.amax',25000);         % xy max acceleration 
   Default(o,'xy.tj',0.02);            % xy jerk time 

   Default(o,'camdelay.small',10);     % small camera delay 
   Default(o,'camdelay.large',50);     % large camera delay 
   Default(o,'camdelay.huge',150);     % huge camera delay 
   
   Default(o,'capture.small',10);      % small capture time 
   Default(o,'capture.large',50);      % large capture time
   Default(o,'capture.huge',100);      % huge capture time 
   
   Default(o,'park.smax',175);         % xy max velocity 
   Default(o,'park.vmax',3000);        % xy max velocity 
   Default(o,'park.amax',25000);       % xy max acceleration 
   Default(o,'park.tj',0.01);          % xy jerk time 
   
   Default(o,'pick.delay',80);         % pick delay
   Default(o,'bond.delay',100);        % bond delay
   
   Default(o,'park.distance',175);     % distance to park position
end
function Default(o,tag,value)          % Provide Default Setting       
   setting(o,{Tag(tag)},value);  % provide default setting
end
function Setting(o,tag,value)          % Change Setting                
   %setting(o,['simu.',tag],value);    % change setting
   charm(o,Tag(tag),value);      % change setting
end

%==========================================================================
% Jumbo Studies
%==========================================================================

function o = JumboStudies(o)           % Motion Studies                
   %oo = mitem(o,'Jumbo Studies');
   oo = o;
   ooo = mitem(oo,' 2 Bond Heads',{@invoke,mfilename,@MultiHead,2});
   ooo = mitem(oo,' 4 Bond Heads',{@invoke,mfilename,@MultiHead,4});
   ooo = mitem(oo,' 8 Bond Heads',{@invoke,mfilename,@MultiHead,8});
   ooo = mitem(oo,'12 Bond Heads',{@invoke,mfilename,@MultiHead,12});
end
function o = MultiHead(o)              % Multi Head Simulation         
   heads = arg(o,1);
   gray = 0.9*[1 1 1];
   fprintf('Full Bond Cycle Parameters\n');
   
      % Travel Parameters
      
   fprintf('   Travel\n');
   
   xytr = Motion(o,'travel');          % motion of index
   fprintf('      Long X/YTravel: %g mm @ %g ms\n',xytr.s,xytr.t);
   xysh = Motion(o,'short');           % motion of index
   fprintf('      Short X/YTravel: %g mm @ %g ms\n',xysh.s,xysh.t);
   ztr = Motion(o,'ztravel');          % long motion of z-axis
   fprintf('      Long Z-Travel: %g mm @ %g ms\n',ztr.s,ztr.t);

      % Picking
      
   fprintf('   Pickup\n');
   
   pd = Motion(o,'pick.down');         % motion of pick-up z movement
   fprintf('      Pick-z (down): %g mm @ %g ms\n',pd.s,pd.t);
   PD = ramp(dproc('PD'),pd.t,[1.2 1],'d');

   p0.t = opt(o,Tag('pick.delay'));  % pick delay
   fprintf('      Pick Delay: %g ms\n',p0.t);
   P0 = ramp(dproc('PICK'),p0.t,[1 1],'g');

   pu = Motion(o,'pick.up');           % motion of pick-up z movement
   fprintf('      Pick-z (up): %g mm @ %g ms\n',pu.s,pu.t);
   PU = ramp(dproc('PU'),pu.t,[1 1.2],'d');

      % Bonding
   
   fprintf('   Bonding\n');
   
   bf = Motion(o,'bond.fast');         % fast down motion of bond z movement
   fprintf('      Bond-z (fast): %g mm @ %g ms\n',bf.s,bf.t);
   BF = ramp(dproc('BF'),bf.t,[2 1.9],'y');

   bd = Motion(o,'bond.down');         % down motion of bond z movement
   fprintf('      Bond-z (down): %g mm @ %g ms\n',bd.s,bd.t);
   BD = ramp(dproc('BD'),bd.t,[1.9 1.8],'y');

   b0.t = opt(o,Tag('bond.delay'));  % pick delay
   fprintf('      Bond Delay: %g ms\n',b0.t);
   B0 = ramp(dproc('BOND'),b0.t,[1.8 1.8],'r');

   bu = Motion(o,'bond.up');           % down motion of bond z movement
   fprintf('      Bond-z (up): %g mm @ %g ms\n',bu.s,bu.t);
   BU = ramp(dproc('BU'),bu.t,[1.8 2],'y');
  
      % Setup Process Steps
      
   xypk = ramp(dproc('XY->PK'),xytr.t,[2 2],gray);
   ztrd  = ramp(dproc('Z-DOWN'),ztr.t,[2 1.2],'g');
   ztru  = ramp(dproc('Z-UP'),ztr.t,[1.2 2],'g');
   
   xybd = ramp(dproc('PK->XY'),xytr.t,[2 2],gray);
   
   xysh = ramp(dproc('XY++'),xysh.t,[2 2],gray);

   switch heads
       case 2
         chn = chain(dproc('z motion'),...
                     xypk,ztrd, PD,P0,PU,ztru,...
                     xybd,BF,BD,B0,BU);
       case 4
         chn = chain(dproc('z motion'),...
                     xypk,ztrd, PD,P0,PU,ztru,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU);
       case 8
          chn = chain(dproc('z motion'),...
                     xypk,ztrd, PD,P0,PU,ztru,...
                     xybd,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU);
       case 12
          chn = chain(dproc('z motion'),...
                     xypk,ztrd, PD,P0,PU,ztru,...
                     xybd,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU,...
                     xysh,BF,BD,B0,BU);
          otherwise
           error('number of heads not supported!');
   end
   
   prc = process(dproc('Throughput Mode'),chn);
 
   plot(prc);
   Tcy = duration(chn);
   uph = heads*3600 / (Tcy/1000);
   xlabel(sprintf('Cycle time: %g ms (%g UPH)',o.rd(Tcy,0),o.rd(uph,-1)));
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   oo = mitem(o,'Parameters');

%  ooo = mitem(oo,'Bond Heads');
%  oooo = Charm(ooo,'Number [#]','head.number');
%  oooo = Charm(ooo,'Distance [mm]','head.distance');
   
   ooo = mitem(oo,'Die Size');
   oooo = Charm(ooo,'Min [mm]','diesize.min');
   oooo = Charm(ooo,'Max [mm]','diesize.max');
   
   ooo = mitem(oo,'Strokes');
   %oooo = mitem(ooo,'Indexing Stroke',{@invoke,mfilename,@IndexingStroke});
   oooo = MotionParameters(ooo,'X/Y: Long Travel','travel',300,3000,25000,0.02);
   oooo = MotionParameters(ooo,'X/Y: Short Travel','short',8,3000,25000,0.02);
   oooo = MotionParameters(ooo,'z: Long Travel','ztravel',100,3000,25000,0.02);
   oooo = MotionParameters(ooo,'X/Y: Move to UC','ucam',80,2000,20000,0.03);
   oooo = MotionParameters(ooo,'X/Y: Correction','correct',0.01,2000,220,0.01);
   oooo = MotionParameters(ooo,'K: 5mm Shift','five',5,2000,5000,0.03);
   oooo = MotionParameters(ooo,'K: 2mm Shift','two',2,2000,5000,0.03);
   %oooo = MotionParameters(ooo,'Z: Bonding','bond',1,5,5000,0.01);

   ooo = mitem(oo,'Camera Delay');
   oooo = Charm(ooo,'Small [ms]','camdelay.small');
   oooo = Charm(ooo,'Large [ms]','camdelay.large');
   oooo = Charm(ooo,'Huge [ms]','camdelay.huge');

   ooo = mitem(oo,'Capture Time');
   oooo = Charm(ooo,'Small [ms]','capture.small');
   oooo = Charm(ooo,'Large [ms]','capture.large');
   oooo = Charm(ooo,'Huge [ms]','capture.huge');
   
%  ooo = MotionParameters(oo,'Parking','park',200,3000,25000,0.01);

   ooo = mitem(oo,'Picking');
   oooo = MotionParameters(ooo,'Z-Down','pick.down',1,5,5000,0.01);
   oooo = Charm(ooo,'Delay [ms]','pick.delay');
   oooo = MotionParameters(ooo,'Z-Up','pick.up',1,5,5000,0.01);
   
   ooo = mitem(oo,'Bonding');
   oooo = MotionParameters(ooo,'Z-Fast','bond.fast',0.5,2000,25000,0.01);
   oooo = MotionParameters(ooo,'Z-Down','bond.down',0.5,10,25000,0.01);
   oooo = Charm(ooo,'Delay [ms]','bond.delay');
   oooo = MotionParameters(ooo,'Z-Up','bond.up',1,2000,25000,0.01);
 
   ooo = mitem(oo,'Z-Motion',{@invoke,mfilename,@Zmovement});
end
function o = SlowSettings(o)           % Change to Slow Parameters     
   Setting(o,'camdelay.huge',150);     % huge camera delay 
   Setting(o,'capture.huge',100);      % huge capture time 

   Setting(o,'ztravel.smax',100);
   Setting(o,'travel.vmax',3000);
   Setting(o,'travel.amax',25000);

   Setting(o,'ztravel.vmax',3000);
   Setting(o,'ztravel.amax',25000);

   Setting(o,'pick.down.vmax',5);
   Setting(o,'pick.delay',80);
   Setting(o,'pick.up.vmax',10);

   Setting(o,'bond.down.vmax',10);
   Setting(o,'bond.delay',100);
   Setting(o,'bond.up.vmax',1000);

   refresh(o);
end
function o = FastSettings(o)           % Change to Fast Parameters     
   Setting(o,'camdelay.huge',100);     % huge camera delay 
   Setting(o,'capture.huge',50);       % huge capture time 
   
   Setting(o,'travel.vmax',3000);
   Setting(o,'travel.amax',50000);

   Setting(o,'ztravel.smax',20);
   Setting(o,'ztravel.vmax',3000);
   Setting(o,'ztravel.amax',50000);

   Setting(o,'travel.vmax',3000);
   Setting(o,'travel.amax',50000);

   Setting(o,'pick.down.vmax',10);
   Setting(o,'pick.delay',20);
   Setting(o,'pick.up.vmax',20);

   Setting(o,'bond.down.vmax',20);
   Setting(o,'bond.delay',80);
   Setting(o,'bond.up.vmax',1000);

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
% Auxillary Functions
%==========================================================================

function tag = Tag(suffix)
%
% TAG   Create a full tag, given pos fix tag
%
%          tag = Tag('z')              % tag = 'jumbo.z'
%          tag = Tag('slow.stroke')    % tag = 'jumbo.slow.stroke'
%
   tag = ['jumbo.',suffix];
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
