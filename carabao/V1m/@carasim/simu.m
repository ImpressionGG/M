function oo = simu(o,varargin)         % Simulation Menu               
%
% SIMU   Manage simulation menu
%
%        See also: CARASIM
%
   [gamma,oo] = manage(o,varargin,@Setup,@Step,@Ramp);
   oo = gamma(oo);
end

%==========================================================================
% Setup Simu Menu
%==========================================================================

function o = Setup(o)                  % Setup Siulation Menu          
   o = Init(o);                        % init design parameters
   oo = mhead(o,'Simulation');
   ooo = SimpleSteps(oo);              % add Simple Steps sub menu
end
function o = Init(o)                   % Initialize Settings           
end

%==========================================================================
% Callbacks
%==========================================================================

function o = SimpleSteps(o)            % Simple Steps Submenu          
   oo = mitem(o,'Simple Steps');
   ooo = mitem(oo,'Step',{@invoke,mfilename,@Step});
   ooo = mitem(oo,'Ramp',{@invoke,mfilename,@Ramp});
end
function o = Step(o)                   % Step Callback                 
   s1 = step(o,'S1',20,[1 1],'g','Green Step');
   Plot(s1);                           % plot step
end
function o = Ramp(o)                   % Ramp Callback                 
   r1 = step(o,'R1',20,[0.5 1],'y','Yellow Ramp');
   Plot(r1);                           % plot ramp
end
function Plot(o)
   cls(o);                             % clear screen
   plot(o);                            % plot object
   set(gca,'xlim',[0,30],'ylim',[-0,1.5])
   shg;                                % show graphics
end

%==========================================================================
% Cycle Studies
%==========================================================================

function o = CycleStudies(o)           % Cycle Studies                 
   oo = mitem(o,'Cycle Studies');
   ooo = mitem(oo,'Bond Cycle',{@invoke,mfilename,@BondCycle});
   ooo = mitem(oo,'Full Cycle',{@invoke,mfilename,@FullCycle});
   ooo = mitem(oo,'Dependance',{@invoke,mfilename,@Dependance});
end
function o = BondCycle(o)              % Bond Cycle Study              
   fprintf('Full Bond Cycle Parameters\n');
   x = Motion(o,'index');             % motion of index
   fprintf('   Index: %g mm @ %g ms\n',x.s,x.t);

   z = Motion(o,'bond');               % motion of bond z movement
   fprintf('   Bond-z: %g mm @ %g ms\n',z.s,z.t);
   
   b.t = 50;                           % bond delay
   fprintf('   Bond Delay: %g ms\n',b.t);

   zd = ramp(dproc('ZD'),z.t,[2 1],'b');
   zb = ramp(dproc('ZB'),b.t,[1 1],'y');
   zu = ramp(dproc('ZU'),z.t,[1 2],'b');
   xy = ramp(dproc('XY'),x.t,[2 2],'g');
   
   chn = chain(dproc('z motion'),zd,zb,zu,xy);
   prc = process(dproc('Bond Sequence'),chn);
   plot(prc);
   
   Tcy = 2*z.t + b.t + x.t;  % bond cycle time
   xlabel(sprintf('Cycle time: %g ms',o.rd(Tcy)));
end
function o = FullCycle(o)              % Full Cycle Study              
   rd = @carma.rd;                     % need some utility
   
   n = opt(o,'simu.head.number');      % number of bond heads
   list = {};

   fprintf('Full Bond Cycle Parameters\n');
   x = Motion(o,'index');             % motion of index
   fprintf('   Index: %g mm @ %g ms\n',x.s,x.t);

   z = Motion(o,'bond');               % motion of bond z movement
   fprintf('   Bond-z: %g mm @ %g ms\n',z.s,z.t);
   
   b.t = 50;                           % bond delay
   fprintf('   Bond Delay: %g ms\n',b.t);
   
   for (i=1:n)
      zd = ramp(dproc(sprintf('ZD%g',i)),z.t,[2 1],'m');
      zb = ramp(dproc(sprintf('ZB%g',i)),b.t,[1 1],'y');
      zu = ramp(dproc(sprintf('ZU%g',i)),z.t,[1 2],'m');
   
      list = [list,{zd,zb,zu}];

      if (i < n)
         xy = ramp(dproc(sprintf('XY%g',i)),x.t,[2 2],'g');
         list{end+1} = xy;
      end
   end
   
      
   p = Motion(o,'park');
   fprintf('   Park-x: %g mm @ %g ms\n',p.s,p.t);
   u.t = 10;                           % upward camera time
   fprintf('   Upward Camera: %g ms\n',u.t);
   
   xp1 = ramp(dproc('XP1'),p.t,[0 -1],'r');
   uc = ramp(dproc('UC'),u.t,[-1 -1],'b');
   xp2 = ramp(dproc('XP2'),p.t,[-1 0],'r');
   list = [list,{xp1,uc,xp2}];
   
   chn = chain(dproc('z motion'),list);
   prc = process(dproc('Bond Sequence'),chn);
   plot(prc);
   
   Tcy = 2*n*z.t + n*b.t + (n-1)*x.t + 2*p.t + u.t;  % bond cycle time
   
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

   ooo = mitem(oo,'Bond Heads');
   oooo = Charm(ooo,'Number [#]','head.number');
   oooo = Charm(ooo,'Distance [mm]','head.distance');
   
   ooo = mitem(oo,'Die Size');
   oooo = Charm(ooo,'Min [mm]','diesize.min');
   oooo = Charm(ooo,'Max [mm]','diesize.max');
   
   ooo = MotionParameters(oo,'Indexing','index',10,3000,25000,0.01);
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Indexing Stroke',{@invoke,mfilename,@IndexingStroke});

   ooo = MotionParameters(oo,'Parking','park',200,3000,25000,0.01);
   ooo = MotionParameters(oo,'Bonding','bond',1,3000,25000,0.01);
   ooo = mitem(oo,'Z-Motion',{@invoke,mfilename,@Zmovement});
end
function oo = MotionParameters(o,label,tag,smax,vmax,amax,tj)          
%
% PARAMETER-SET   Add charm menu items for parameter settings
%
%                    oo = Parameters(o,'Parking','park',200,3000,25000,0.01);
%
   context = ['simu.',tag,'.'];           
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
   oo = with(o,'simu.head');
   n = opt(oo,'number');               % number of bond heads
   d = opt(oo,'distance');             % distance of bond heads
   
   amin = opt(o,'simu.diesize.min');
   amax = opt(o,'simu.diesize.max');
   
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
   
   o = opt(o,'simu.index.smax',smax);
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
% Auxillary Functions
%==========================================================================

function oo = Charm(o,label,tag)       % Add Charm Menu Item           
%
% CHARM   Setup a menu item with CHARM functionality
%
   oo = mitem(o,label,{},['simu.',tag]);
   charm(oo,{});
end
function [tmax,smax,vmax,amax,tj] = Zmotion(o)                         
%
% Z-MOTION   Calculate z-motion time or draw z-motion plot
%
%               [tmax,zmax,vmax,amax,tj] = Zmotion(o)   % calculate
%               Zmotion(o)                              % plot
%
   oo = with(o,'simu.z');
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

   oo = with(o,['simu.',tag]);
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
   oo = with(o,['simu.',tag]);
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
