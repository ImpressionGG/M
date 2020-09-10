function oo = study(o,varargin)        % Do Some Studies               
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Study1')   % raw signal
%       oo = study(o,'Study2')   % raw & filtered signal
%       oo = study(o,'Study3')   % filtered
%       oo = study(o,'Study4')   % signal noise
%
%    See also: PLL, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                  @ScenarioMenu,@KalmanMenu,@PllMenu,@McuMenu,...
                  @Basics,@PeriodEstimation,...
                  @StateSpace,@SystemStudy,@PolePlace,@LqrControl,...
                  @Luenberger,@McuKalf,@Kalman,@TwinKalf,@TestKalf,...
                  @PwmBasics,@PwmSystem,@KafiBasics0,@KafiBasics1,...
                  @KafiBasics2,@KafiBasics3,@KafiBasics4,@KafiBasics5,...
                  @KafiBasics6,@KafiBasics7,@KafiBasics8,@KafiBasics9,...
                  @KafiBasics10,@KafiBasics11,@KafiBasics12,@KafiBasics13,...
                  @KafiBasics14,...
                  @PwmControl,@PwmFeedForward,@PwmControlSimu,...
                  @DirectPll,...
                  @SystemPll,@LqrPll,@KalmanPll,@TwinKalfPll);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                                                  
   setting(o,{'simu.another'},0);

   oo = mitem(o,'Another Run',{},'simu.another');
        check(oo,{});

   oo = mitem(o,'-');
   oo = mitem(o,'Basics',{@Callback,'Basics'},[]);
   oo = mitem(o,'Period Estimation',{@Callback,'PeriodEstimation'},[]);

   oo = mitem(o,'-');
   oo = mitem(o,'State Space',{@Callback,'StateSpace'},[]);
   oo = mitem(o,'System Study',{@Callback,'SystemStudy'},[],'enable','off');
   oo = mitem(o,'Pole Placement',{@Callback,'PolePlace'},[]);
   oo = mitem(o,'LQR Controller',{@Callback,'LqrControl'},[]);

   oo = mitem(o,'-');
   oo = mitem(o,'Luenberger');
   ooo = mitem(oo,'Luenberger Observer',{@Callback,'Luenberger'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'[0.4 1.5] @ [10 0]',{@Callback,'Luenberger',[0.4 1.5],[10 0]});
   ooo = mitem(oo,'[0.1 1.5] @ [10 0]',{@Callback,'Luenberger',[0.1 1.5],[10 0]});
   ooo = mitem(oo,'[0.4 0.5] @ [10 0]',{@Callback,'Luenberger',[0.4 0.5],[10 0]});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'[0.4 1.5] @ [10 0]',{@Callback,'Luenberger',[0.4 1.5],[10 0]});
   ooo = mitem(oo,'[0.4 1.5] @ [18 0]',{@Callback,'Luenberger',[0.4 1.5],[18 0]});
   ooo = mitem(oo,'[0.4 1.5] @ [20 0]',{@Callback,'Luenberger',[0.4 1.5],[20 0]});
   ooo = mitem(oo,'[0.4 1.5] @ [22 0]',{@Callback,'Luenberger',[0.4 1.5],[22 0]});
   ooo = mitem(oo,'[0.4 1.5] @ [30 0]',{@Callback,'Luenberger',[0.4 1.5],[30 0]});

   oo = mitem(o,'-');

   oo = mitem(o,'PWM Basics', {@Callback,'PwmBasics'},[]);
   oo = mitem(o,'PWM System',  {@Callback,'PwmSystem'},[]);
   oo = mitem(o,'PWM Control',{@Callback,'PwmControl'},[]);
   oo = mitem(o,'PWM Feed Forward',{@Callback,'PwmFeedForward'},[]);
end
function oo = Callback(o)                                              
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   study(oo);
end

%==========================================================================
% Parameter Menu
%==========================================================================

function oo = ScenarioMenu(o)                                          
   oo = SpecialMenu(o);
   oo = SimuMenu(o);
   oo = mitem(o,'-');
   oo = GridMenu(o);
   oo = ClockMenu(o);
   oo = TimerMenu(o);
   oo = PwmMenu(o);
   oo = KalmanParameter(o);
end
function oo = SpecialMenu(o)                                           
   setting(o,{'simu.mini'},0);           % mini study setup

   oo = mitem(o,'Special Scenario',{},'simu.mini');
          choice(oo,{{'Individual',0},...
                     {'PWM Study',1},...
                     {'Kalman Study',2},...
                     {'LQR Study',3}...
                     {'MCU Study (Kalman/Noise On)',4}...
                    },{});
end
function oo = SimuMenu(o)                                              
   setting(o,{'simu.periods'},50);
   setting(o,{'simu.random'},1);         % no random seed reset
   setting(o,{'simu.noise'},1);          % noise on/off
   setting(o,{'simu.trace'},0);          % tracing on/off

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Periods',{},'simu.periods');
         choice(ooo,[1 2 5 10 20 50 100 200 500 1000 2000 5000 10000,...
                     20000,50000],{});
   ooo = mitem(oo,'Random',{},'simu.random');
         choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Noise',{},'simu.noise');
         choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Trace',{},'simu.trace');
         choice(ooo,{{'Off',0},{'On',1}},{});
end
function oo = GridMenu(o)                                              
   setting(o,{'grid.f'},50);
   setting(o,{'grid.urms'},230);
   setting(o,{'grid.offset'},10);      % 10 ms offset
   setting(o,{'grid.jitter'},60e-6);   % zero cross jitter 3*sigma
   setting(o,{'grid.latency'},100e-6); % interrupt latency
   setting(o,{'grid.vario'},10e-6);    % frequency variation 3*sigma

   oo = mitem(o,'Grid');
   ooo = oo;                           % legacy
   oooo = mitem(ooo,'RMS Voltage [V]',{},'grid.urms');
          charm(oooo,{});
   oooo = mitem(ooo,'Frequency [Hz]',{},'grid.f');
          choice(oooo,{{'49.2 Hz',49.2},{'49.91 Hz',49.91},...
             {'50 Hz',50},{'50.17 Hz',50.17},{'50.8 Hz',50.8}},{});
   oooo = mitem(ooo,'Offset [ms]',{},'grid.offset');
          choice(oooo,[0:2:20],{});
   oooo = mitem(ooo,'Jitter (3*sigma) [us]',{},'grid.jitter');
          choice(oooo,{{'0 us',0},{'10 us',10e-6},{'60 us',60e-6},{'1 ms',1e-3},{'3 ms',3e-3}},{});
   oooo = mitem(ooo,'Variation (3*sigma) [us]',{},'grid.vario');
          choice(oooo,{{'0 us',0},{'1 us',1e-6},{'2 us',2e-6},...
                {'5 us',5e-6},{'10 us',10e-6},{'20 us',20e-6},...
                {'50 us',50e-6},{'100 us',100e-6},{'200 us',200e-6}},{});
   oooo = mitem(ooo,'Latency (3*sigma) [us]',{},'grid.latency');
          choice(oooo,{{'0 us',0},{'100 us',100e-6},{'200 us',200e-6},...
                       {'1 ms',1e-3}},{});
end
function oo = ClockMenu(o)                                             
   setting(o,{'clock.f0'},32e6);
   setting(o,{'clock.kappa'},1);

   oo = mitem(o,'Clock');
   ooo = oo;                           % legacy
   oooo = mitem(ooo,'Clock [Mhz]',{},'clock.f0');
          choice(oooo,{{'16 MHz',16e6},{'32 MHz',32e6}},{});
   oooo = mitem(ooo,'Kappa',{},'clock.kappa');
          choice(oooo,{{'1',1},{'32/31',32/31},{'32/20',32/20}},{});
end
function oo = PwmMenu(o)                                               
   setting(o,{'pwm.hlim'},[0.8 1.2]);
   setting(o,{'pwm.pwmplot'},1);
   setting(o,{'pwm.setpoint'},0.4);    % normalized reference value

   oo = mitem(o,'PWM');
   ooo = mitem(oo,'Phase Setpoint',{},'pwm.setpoint');
         choice(ooo,[0:10]/10,{});
   ooo = mitem(oo,'Constraints',{},'pwm.hlim');
          choice(ooo,{{'No Constraint',[-inf inf]},...
                       {'0.8 ... 1.2',[0.8,1.2]}},{});
   ooo = mitem(oo,'PWM Plot',{},'pwm.pwmplot');
          choice(ooo,{{'Off',0},{'On',1}},{});
end
function oo = TimerMenu(o)                                             
   setting(o,{'tim6.period'},40000-1);
   setting(o,{'tim6.prescale'},32);
   setting(o,{'tim6.offset'},(3+pi)/1000);  % some irrational arround 6ms

   setting(o,{'tim2.period'},10000-1);
   setting(o,{'tim2.prescale'},32);
   setting(o,{'tim2.offset'},(4+pi)/1000);  % some irrational arround 6ms

   oo = mitem(o,'Timer6');
   ooo = oo;
   oooo = mitem(ooo,'Period',{},'tim6.period');
          choice(oooo,{{'10',9},{'40',39},{'60',59},{'40000',39999}},{});
   oooo = mitem(ooo,'Prescaler',{},'tim6.prescale');
          choice(oooo,{{'32',32},{'32000',32000},{'16000',16000}},{});
   oooo = mitem(ooo,'Offset',{},'tim6.offset');
          choice(oooo,{{'0 ms',0},{'6.141 ms',(3+pi)/1000}},{});

   ooo = mitem(o,'Timer2');
   oooo = mitem(ooo,'Period',{},'tim2.period');
          choice(oooo,{{'10',9},{'16',15},{'10000',9999},{'16000',15999}},{});
   oooo = mitem(ooo,'Prescaler',{},'tim2.prescale');
          choice(oooo,{{'20',20},{'32',32},{'10000',10000},...
                       {'20000',20000},{'32000',32000}},{});
   oooo = mitem(ooo,'Offset',{},'tim2.offset');
          choice(oooo,{{'0 ms',0},{'4 ms',4/1000},{'7.141 ms',(4+pi)/1000}},{});
end
function oo = KalmanParameter(o)                                       
   setting(o,{'kalman.pimp'},1);

   oo = mitem(o,'Kalman');
   ooo = mitem(oo,'Pimp',{},'kalman.pimp');
          choice(ooo,[0.1:0.1:1.5],{});
end

%==========================================================================
% Kalman Menu
%==========================================================================

function oo = KalmanMenu(o)                                            
   oo = mitem(o,'Kalman Basics - Noise',{@Callback,'KafiBasics0'},[]);
   oo = mitem(o,'Kalman Basics - Literature', {@Callback,'KafiBasics6'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Kalman Basics - Order 2',{@Callback,'KafiBasics1'},[]);
   oo = mitem(o,'Kalman Basics - Order 3',{@Callback,'KafiBasics2'},[]);
   oo = mitem(o,'Kalman Basics - Order 4',{@Callback,'KafiBasics3'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Kalman Basics - Twin',   {@Callback,'KafiBasics4'},[]);
   oo = mitem(o,'Kalman Basics - TwinD',{@Callback,'KafiBasics9'},[]);
   oo = mitem(o,'Kalman Basics - Twin Lu !!',{@Callback,'KafiBasics10'},[]);
   oo = mitem(o,'Kalman Basics - Twin Tri',{@Callback,'KafiBasics11'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Kalman Basics - Delta 4 !!!',{@Callback,'KafiBasics8'},[]);
   oo = mitem(o,'Kalman Basics - Know H 4',{@Callback,'KafiBasics7'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Kalman Basics - Quick & Brilliant', {@Callback,'KafiBasics5'},[]);
   oo = mitem(o,'Kalman Basics - Brilliant 1',{@Callback,'KafiBasics12'},[]);
   oo = mitem(o,'Kalman Basics - Brilliant 2 !!!', {@Callback,'KafiBasics13'},[]);
   oo = mitem(o,'Kalman Basics - Brilliant 3 !!!', {@Callback,'KafiBasics14'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Order 2 Kalman Filter',{@Callback,'Kalman'},'order2');
   oo = mitem(o,'Order 3 Kalman Filter',{@Callback,'Kalman'},'order3');
   oo = mitem(o,'Order 4 Kalman Filter',{@Callback,'Kalman'},'order4');
   oo = mitem(o,'-');
   oo = mitem(o,'Cascade Kalman Filter',{@Callback,'Kalman'},'casc');
   oo = mitem(o,'Twin Kalman Filter',   {@Callback,'Kalman'},'twin');
   oo = mitem(o,'-');
   oo = mitem(o,'iTwin Kalman Filter',  {@Callback,'Kalman'},'itwin');
   oo = mitem(o,'-');
   oo = mitem(o,'Steady Kalman Filter', {@Callback,'Kalman'},'steady');
   oo = mitem(o,'MCU Kalman Filter',{@Callback,'McuKalf'},[],'enable','off');
end

%==========================================================================
% PLL Menu
%==========================================================================

function oo = PllMenu(o)                                               
   oo = mitem(o,'Twin Kalman PLL',{@Callback,'KalmanPll'},'twin');
   oo = mitem(o,'iTwin Kalman PLL',{@Callback,'KalmanPll'},'itwin');

   oo = mitem(o,'-');
   oo = mitem(o,'Kalman PLL',{@Callback,'KalmanPll'},'order4');
   oo = mitem(o,'Cascade Kalman PLL',{@Callback,'KalmanPll'},'casc');

   oo = mitem(o,'-');
   oo = mitem(o,'Steady Kalman PLL',{@Callback,'KalmanPll'},'steady','enable','off');
   oo = mitem(o,'Simple PLL',{@Callback,'KalmanPll'},'simple');

   oo = mitem(o,'-');

   oo = mitem(o,'Direct PLL', {@Callback,'DirectPll'},[],'enable','off');
   oo = mitem(o,'System PLL', {@Callback,'SystemPll'},[],'enable','off');
   oo = mitem(o,'LQR PLL',{@Callback,'LqrPll'},[]);
end

%==========================================================================
% Helpers
%==========================================================================

function kmax = Kmax(o)                % Maximum Simulation Index      
   kmax = opt(o,'simu.periods');
end
function [sigw,sigv] = Sigma(o)        % Get Noise Sigma Values        
   [Tt0,Tt,Dt] = TimerParameter(o);
   sigw = opt(o,{'grid.vario',10e-6}) / 3 / Dt;
   sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;
end
function o = Random(o)                 % Random/Deterministic Setup    
   random = opt(o,{'simu.random',1});
   if (~random)
      rng(0);                          % set random seed to zero
   end
end
function o = Scenario(o)               % Setup Specifc Scenario        
   mini = opt(o,{'simu.mini',0});

   switch (mini)
      case 0
         % break
      case 1   % mini model without noise

            % setup simulation parameters for mini model study

         o = opt(o,'simu.periods',5);
         o = opt(o,'simu.random',0);
         o = opt(o,'simu.noise',1);
         o = opt(o,'simu.trace',0);

            % setup grid for mini model study

         o = opt(o,'grid.f',50);
         o = opt(o,'grid.offset',0);       % 0 ms offset
         o = opt(o,'grid.jitter',0);       % no zero cross jitter 3*sigma
         o = opt(o,'grid.latency',0);      % no interrupt latency
         o = opt(o,'grid.vario',0);        % no frequency variation 3*sigma

            % setup clock for mini model study

         o = opt(o,'clock.f0',32e6);
         o = opt(o,'clock.kappa',1);

            % setup timers for mini model study

         o = opt(o,'tim6.period',40-1);
         o = opt(o,'tim6.prescale',32000);
         o = opt(o,'tim6.offset',0.004);   % 4ms offset

         o = opt(o,'tim2.period',10-1);
         o = opt(o,'tim2.prescale',32000);
         o = opt(o,'tim2.offset',0.006);   % some irrational arround 6ms

      case 2   % kalman study

            % setup simulation parameters for mini model study

         o = opt(o,'simu.periods',200);
         o = opt(o,'simu.random',0);
         o = opt(o,'simu.noise',1);
         o = opt(o,'simu.trace',0);

            % setup grid for mini model study

         o = opt(o,'grid.f',50);
         o = opt(o,'grid.offset',10);      % 10 ms offset
         o = opt(o,'grid.jitter',60e-6);   % 60us zero cross jitter 3*sigma
         o = opt(o,'grid.latency',1e-4);   % no interrupt latency
         o = opt(o,'grid.vario',10e-6);    % 10us frequency variation 3*sigma

            % setup clock for mini model study

         o = opt(o,'clock.f0',32e6);
         o = opt(o,'clock.kappa',1);

            % setup timers for mini model study

         o = opt(o,'tim6.period',40000-1);
         o = opt(o,'tim6.prescale',32);
         o = opt(o,'tim6.offset',(3+pi)/1000);   % 4ms offset

         o = opt(o,'tim2.period',10000-1);
         o = opt(o,'tim2.prescale',32);
         o = opt(o,'tim2.offset',0);      % some irrational arround 6ms

            % setup Kalman settings

         o = opt(o,'pwm.pwmplot',0);

      case 3   % LQR study

            % setup simulation parameters for mini model study

         o = opt(o,'simu.periods',20);
         o = opt(o,'simu.random',0);
         o = opt(o,'simu.noise',1);
         o = opt(o,'simu.trace',0);

            % setup grid for mini model study

         o = opt(o,'grid.f',50);
         o = opt(o,'grid.offset',0);       % 0 ms offset
         o = opt(o,'grid.jitter',0);       % no zero cross jitter 3*sigma
         o = opt(o,'grid.latency',0);      % no interrupt latency
         o = opt(o,'grid.vario',0);        % no frequency variation 3*sigma

            % setup clock for mini model study

         o = opt(o,'clock.f0',32e6);
         o = opt(o,'clock.kappa',1);

            % setup timers for mini model study

         o = opt(o,'tim6.period',40-1);
         o = opt(o,'tim6.prescale',32000);
         o = opt(o,'tim6.offset',0.004);   % 4ms offset

         o = opt(o,'tim2.period',10-1);
         o = opt(o,'tim2.prescale',32000);
         o = opt(o,'tim2.offset',0.006);   % some irrational arround 6ms

      case 4   % MCU study (Kalman/Noise Off)
         o = opt(o,'mcu.scenario',114231);

            % setup simulation parameters for mini model study

         %o = opt(o,'simu.periods',10);
         o = opt(o,'simu.random',0);
         o = opt(o,'simu.noise',1);
         o = opt(o,'simu.trace',1);

            % setup grid for mini model study

         o = opt(o,'grid.f',50);
         o = opt(o,'grid.offset',10);      % 10 ms offset
         o = opt(o,'grid.jitter',60e-6);   % 60us zero cross jitter 3*sigma
         o = opt(o,'grid.latency',1e-4);   % no interrupt latency
         o = opt(o,'grid.vario',10e-6);    % 10us frequency variation 3*sigma

            % setup clock for mini model study

         o = opt(o,'clock.f0',32e6);
         o = opt(o,'clock.kappa',1);

            % setup timers for mini model study

         o = opt(o,'tim6.period',40000-1);
         o = opt(o,'tim6.prescale',32);
         o = opt(o,'tim6.offset',(3+pi)/1000);   % 4ms offset

         o = opt(o,'tim2.period',10000-1);
         o = opt(o,'tim2.prescale',32);
         o = opt(o,'tim2.offset',0);      % some irrational arround 6ms

            % setup Kalman settings

         o = opt(o,'pwm.pwmplot',0);

   end
   Random(o);                          % handle random seed
end
function o = Mini(o)                   % Setup for Mini Study          

end
function y = Quantize(x,mod)           % Quantization Function         
   y = rem(x+mod,mod);
   y = floor(y);
end
function y = Sat(x,xm)                 % Saturation Function           
   y = max(-xm,min(x,xm));
end
function [y,idx] = Steady(x)           % Steady value of 2nd Half      
   idx = max(1,ceil(length(x)/2));
   idx = idx:length(x);
   y = mean(x(idx));
end

function hdl = Step(t,y,col)           % Step Plot                     
   t = [t;t(2:end) t(end)];
   y = [y;y];

   hdl = plot(t(:),y(:));
   if (nargin >= 3)
      corazito.color(hdl,col);
   end
end
function o = Plot(o)                   % General Plot Function         
   kk = var(o,'kk');   vt = var(o,'vt');   yt = var(o,'yt');
   zt = var(o,'zt');   ym = var(o,'ym');   yd = var(o,'yd');
   xt1 = var(o,'xt1'); xm1 = var(o,'xm1');

      % observer error = jitter free counter reading - model output

   ye = ym - zt;

      % First Plot

   subplot(311);
   plot(kk,vt,'g', kk,vt,'ko');
   hold on
   plot(kk,yt-zt,'r');
   ylabel('jitter [us]');
   sig = std(vt);
   title(sprintf('Jitter (%g us @ 3s)',o.rd(3*sig,0)));

      % Second Plot

   subplot(312);
   plot(kk,0*kk,'k');
   hold on;
   plot(kk,yd,'r',  kk,yd,'r.');
   plot(kk,ye,'b',  kk,ye,'b.');
   sigd = std(yd(round(end*0.3):end));
   sige = std(ye(round(end*0.3):end));
   title(sprintf('Observer Deviation yd=ym-yt (-> %d us @ 3s) & Observer Error ye=ym-zt (-> %d us @ 3s)',...
                 o.rd(3*sigd,0),o.rd(3*sige,0)));
   ylabel('r: yd [us], b: ye [us]');
   set(gca,'ylim',3*(sigd+sige)*[-1 1]);

      % Third Plot

   subplot(313);
%  plot(kk,xg1*1000,'k');
   xe = xm1 - xt1;      % period observation error
   plot(kk,xt1*1000,'r', kk,xt1*1000,'r.');
   hold on;
   plot(kk(2:end),xm1(2:end)*1000,'b', kk(2:end),xm1(2:end)*1000,'b.');
   %plot(kk(2:end),xe(2:end)*1000,'g', kk(2:end),xe(2:end)*1000,'g.');
   hold on;
   sigt = std(xt1(round(end*0.3):end))*1e6;
   sigm = std(xm1(round(end*0.3):end))*1e6;
   title(sprintf('System Period (r: -> %d us @ 3s) & Observed Period (b: -> %d us @3s)',...
                 o.rd(3*sigt,0),o.rd(3*sigm,0)));
   %set(gca,'ylim',[0 25]);
   ylabel('period [ms]');
end
function o = ConPlot(o,con,sys)        % Plot Controller Signals       
   time = con.t;
   kmax = length(time);

   subplot(321);
   plot(time,con.o,'r', time,con.o,'r.');
   [st,idx] = Steady(con.o);
   title(sprintf('Controlled PWM Phase (-> %g)',o.rd(st)));
   ylabel('o [#]');

   subplot(322);
   plot(time,con.e,'k', time,con.e,'k.');
   title('Error');
   ylabel('e [#]');

   eavg = mean(con.e(round(kmax/2):kmax));
   %set(gca,'ylim',eavg+[-100 100]);

   subplot(323);
   x = sys.x(1,1:end-1);
   h = sys.x(2,1:end-1);
   plot(time,x,'g', time,x,'go');
   hold on
   plot(time,2*h,'m', time,2*h,'m.');
   st = o.rd(Steady(x));
   title(sprintf('Grid (Period -> %g)',st));
   ylabel('g: x [#], m:2*h [#]');
   set(gca,'ylim',[0.9*st 1.1*st]);
   xlabel('time [s]');

   subplot(324);
   plot(time,con.u,'b', time,con.u,'b.');
   title('Control Signal');
   ylabel('u [#]');
   xlabel('time [s]');

   if (nargin < 3)
      return
   end

   subplot(313);
   t = Timing(with(o,'tim2'));
   period = Pwm(o);
   q = Pwm(o,t,sys.p);
   PwmPlot(o,t,q,sys.tz,sys.o);
end
function PwmPlot(o,t,q,tz,qz)          % Plot PWM Timer Signals        
   tmin = min(t);
   tmax = max(t);

   hdlpwm = Step(t*1000,q,'rk');
   [stqz,idx] = Steady(qz);
   sigqz = std(qz(idx));
   title(sprintf('PWM Phase (-> %g +- %g@3s)',stqz,o.rd(3*sigqz)));
   set(gca,'xlim',[tmin tmax]*1000);

   if (opt(o,{'simu.mini',0}) == 1)
      set(gca,'Xtick',0:2:200);
      set(gca,'Ytick',1:12);
      set(gca,'Ylim',[0 12]);
      set(hdlpwm,'Linewidth',2);
      grid on;
   end

      % add zero crossing to PWM plot

   if (nargin >= 4)
      ylim = get(gca,'Ylim');
      for (i=1:length(tz))
         hdl = plot(tz(i)*[1 1]*1000,ylim,'b-.');
         if (opt(o,{'simu.mini',0})==1)
            set(hdl,'LineWidth',2);
         end
      end
      hdl = plot(tz*1000,qz,'ro', tz*1000,qz,'r');
      set(hdl,'LineWidth',1.5);
   end
end
function [K,P]=Dlqr(A,B,Q,R)           % Linear Quadratic Regulator    
%
% DLQR   Linear quadratic regulator design for discrete-time systems.
%
%	         [K,P] = Dlqr(A,B,Q,R)
%
%        calculates the optimal feedback gain matrix K such that the
%        feedback law:
%
%		      u(k) = -K*x(k)
%
%	      minimizes the cost function:
%
%		      J = Sum {x(k)'*Q*x(k) + u(k)'*R*u(k)}
%
%	      subject to the constraint equation:
%
%		      x(k+1) = A*x(k) + B*u(k)
%
%	      Also returned is S, the steady-state solution to the associated
%	      algebraic Riccati equation:
%
%           K = (R+B'*P'*B) \ B'*P*A;
%           P = A'*P*A - A'*P*B * K + Q;
%
%        See TRF, LQR
%
   P = 0*Q;

   for (i=1:1000)
      K = (R+B'*P'*B) \ B'*P*A;
      P = A'*P*A - A'*P*B * K + Q;
   end
end

%==========================================================================
% Grid
%==========================================================================

function u = Grid(o,t)                 % grid voltage for given time   
   f = opt(o,'grid.f');                % grid frequency
   toff = opt(o,'grid.offset')/1000;   % grid time offset
   Urms = opt(o,'grid.urms');          % grid RMS voltage
   om = 2*pi*f;
   u = Urms*sqrt(2)*sin(om*(t+toff));
end
function [jitter,lambda] = Jitter(o)   % random jitter & latency       
    n = opt(o,'simu.periods');

    sigma = 1/3 * opt(o,{'grid.jitter',60e-6});
    jitter = sigma*randn(1,n);

    latency = 1/3 * opt(o,{'grid.latency',100e-6});
    lambda = (2*randn(1,n)).^2*latency;
end
function [t,tj,tl] = ZeroCross(o,tmin,tmax)                            
%
% ZEROCROSS
%
%         Return time stamps of zero crossing in interval [tmin,tmax]
%
%         See also: Counter
%
   if (nargin < 2)
      tmin = var(o,'tmin');
      tmax = var(o,'tmax');
   end

   f = opt(o,{'grid.f',50});
   toff = opt(o,{'grid.offset',0});    % time offset

   period = 1/f;
   t = [tmin-toff-period/2:period:tmax];

   idx = find(tmin <= t & t <= tmax);
   t = t(idx);

      % jitter

   [jitter,latency] = Jitter(o);       % random jitter/latency

   if (nargout >= 2)
      sigma = 1/3 * opt(o,{'grid.jitter',60e-6});
      tj = t + sigma*randn(size(t));
      %tj = t + jitter;
   end

      % interrupt latency

   if (nargout >= 3)
      latency = 1/3 * opt(o,{'grid.latency',100e-6});
      lambda = randn(size(t));
      tl = tj + (2*lambda).^2*latency;
      %tl = tj + latency;
   end

end
function [t0,period] = GridParameter(o)                                
   f = opt(o,{'grid.f',50});
   toff = opt(o,{'grid.offset',0});    % time offset

   period = 1/f;
   tmin = 0; tmax = period;
   t = [tmin-toff-period/2:period:tmax];

   idx = find(tmin <= t & t <= tmax);
   t0 = t(idx(1));
end
function [Tt0,Tt,Dt] = TimerParameter(o)                               
   f0 = opt(o,'clock.f0');
   kappa = opt(o,'clock.kappa');

   Kt = opt(o,'tim6.prescale');
   Dt = Kt/f0*kappa;

   period = opt(o,'tim6.period')+1;
   Tt = period*Dt;

   offset = opt(o,'tim6.offset');
   Tt0 = offset;
end
function [Tt0,Tt,Dt] = PwmParameter(o)                                 
   f0 = opt(o,'clock.f0');
   kappa = opt(o,'clock.kappa');

   Kt = opt(o,'tim2.prescale');
   Dt = Kt/f0*kappa;

   period = opt(o,'tim2.period')+1;
   Tt = period*Dt;

   offset = opt(o,'tim2.offset');
   Tt0 = offset;
end

%==========================================================================
% Timer Functions
%==========================================================================

function t = Timing(o,tmin,tmax)                                       
%
% TIMING return counter value(s) to given time value(s)
%
%            t = Timing(with(o,'tim6'),tmin,tmax)
%
%         See also: Counter
%
   if (nargin < 2)
      tmin = var(o,'tmin');
      if isempty(tmin)
         tmin = 0;
      end
      tmax = var(o,'tmax');
      if isempty(tmax)
         f = opt(o,{'grid.f',50});
         periods = opt(o,{'simu.periods',1});
         tmax = 1/f*periods;
      end
   end

   f0 = opt(o,{'clock.f0',32e6});
   kappa = opt(o,{'clock.kappa',1});

   offset = opt(o,{'offset',0});
   %period = opt(o,{'period',40000-1});
   K = opt(o,{'prescale',32});
   delta = K/f0*kappa;

   t = [tmin, tmin+rem(offset,0.001):delta:tmax];
   t = round(t*1e6)/1e6;
end
function cnt = Counter(o,t,delta,period,offset)                        
%
% COUNTER return counter value(s) to given time value(s)
%
%            cnt = Counter(o,t,delta,period,offset)
%            cnt = Counter(with(o,'tim6'),t)
%
%         See also: Timing
%
   if (nargin < 5)
      offset = opt(o,{'offset',0});
   end
   if (nargin < 4)
      period = opt(o,{'period',40000-1});
   end
   if (nargin < 3)
      f0 = opt(o,{'clock.f0',32e6});
      kappa = opt(o,{'clock.kappa',1});
      K = opt(o,{'prescale',32});
      delta = K/f0*kappa;
   end

   modulus = period + 1;
tt = (t-offset)/delta+modulus;
   cnt = rem((t-offset)/delta+modulus,modulus);
   cnt = floor(cnt);

       % sometimes we have still some values which are approx the modulus
       % this is because of limited precision. to fix it we have to
       % round cnt and run it once more through the remainder function

   if (max(round(cnt)) >= modulus)
       cnt = rem(round(cnt),modulus);
   end
end
function [cnt,delta,t0] = Pwm(o,t,p,t0) % Return PWM counter           
%
% PWM     Return PWM counter value(s) to given time value(s) and
%         sequence of PWM periods p (note that actual timer periods
%         are period(k) = p(k)-1.
%
%            cnt = Counter(o,t,delta,period,offset)
%            cnt = Counter(with(o,'tim6'),t,p)
%
%         Get PWM key parameters
%
%            [period,delta,t0] = Pwm(o)
%
%         See also: Timing
%
   oo = with(o,'tim2');    % PWM timer

   if (nargin < 3)
      p = opt(oo,{'period',40000});
   end
   if (nargin < 4)
      t0 = opt(oo,{'offset',0});
   end

   f0 = opt(oo,{'clock.f0',32e6});
   kappa = opt(oo,{'clock.kappa',1});
   K = opt(oo,{'prescale',32});
   delta = K/f0*kappa;

   if (nargin == 1)                    % return PWM key parameters
      cnt = opt(oo,'period')+1;        % nominal period
      return
   end

      % convert time to timer increments

   z = round(t/delta);
   z0 = round(t0/delta);

   cnt = 0*z;                          % init counter values
   zmax = max(z);
   zk = z0;

   k = 1;                              % index through p(k)
   while (zk <= zmax)
      period = p(k);
      modulus = period;                % not period+1 !

         % get indices of next counter tooth

      idx = find(z >= zk & z < zk+modulus);

         % calculate counter values of current tooth

      if ~isempty(idx)
         zidx = (z(idx)-zk);
         tooth = rem(zidx,modulus);
         cnt(idx) = tooth;
      end

         % progress to next tooth

      zk = zk + modulus;
      k = min(k+1,length(p));          % increment k, unless end of p
   end
end

%==========================================================================
% Basics
%==========================================================================

function o = Basics(o)                 % Basic Study                   
   o = Mini(o);                        % eventual mini study setup
   Tus = 1e-6;                         % us time step
   periods = opt(o,'simu.periods');  % number of periods

      % general calculations

   tmin = 0;
   tmax = periods*20e-3;

      % grid voltage

   t = tmin:Tus:tmax;                  % time vector
   ug = Grid(o,t);

%  o = Timer(o,tmin,tmax);

      % plot grid voltage

   subplot(311);
   plot(t*1000,ug,'b');
   title('Grid Voltage');
   set(gca,'xlim',[tmin tmax]*1000);

      % plot TIM6 counter

   subplot(312);
   oo = with(o,'tim6');
   t6 = Timing(oo,tmin,tmax);
   q6 = Counter(oo,t6);
   Step(t6*1000,q6,'mk');
   title('Timer 6');
   set(gca,'xlim',[tmin tmax]*1000);

      % plot TIM2 counter

   subplot(313);
   oo = with(o,'tim2');
   t2 = Timing(oo,tmin,tmax);
   q2 = Counter(oo,t2);
   Step(t2*1000,q2,'rk');
   title('Timer 2');
   set(gca,'xlim',[tmin tmax]*1000);

      % highlight zero crosses

   [t0,t0j,t0l] = ZeroCross(o,tmin,tmax);

   subplot(311);
   hold on;
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   plot(xlim,[0 0],'k');

   for (i=1:length(t0))
      plot(t0(i)*[1 1]*1000,ylim,'k:');
      plot(t0j(i)*[1 1]*1000,ylim,'r');
      plot(t0l(i)*[1 1]*1000,ylim,'g');
   end

      % add zero crossing to TIM6 plot

   subplot(312);
   hold on;
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   for (i=1:length(t0))
      plot(t0(i)*[1 1]*1000,ylim,'k:');
      plot(t0j(i)*[1 1]*1000,ylim,'r');
   end
   q0j = Counter(with(o,'tim6'),t0j);
   plot(t0j*1000,q0j,'ro');

      % add zero crossing to TIM2 plot

   subplot(313);
   hold on;
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   for (i=1:length(t0))
      plot(t0(i)*[1 1]*1000,ylim,'k:');
      plot(t0j(i)*[1 1]*1000,ylim,'r');
   end
   z0j = Counter(with(o,'tim2'),t0j);
   plot(t0j*1000,z0j,'ro');

      % some output vars

   o = var(o,'jitter',t0j-t0);
end

%==========================================================================
% Period Estimation
%==========================================================================

function o = PeriodEstimation(o)       % Estimate Periods              
   tmax = 1;
   [t0,t0j,t0l] = ZeroCross(o,0,tmax);

      % overview about zero crossing process

   subplot(321);
   plot([0 tmax*1000],[0 tmax*1000],'k', t0*1000,t0j*1000,'ro', t0*1000,t0l*1000,'go');
   title('Zero Crossing Process');

      % estimate periods

   for (i=1:length(t0l)-1)
      T0(i) = t0(i+1) - t0(i);
      Tj(i) = t0j(i+1) - t0j(i);
      Tl(i) = t0l(i+1) - t0l(i);
   end

      % exact periods

   subplot(322);
   plot(1:length(T0),T0*1000,'r', 1:length(T0),T0*1000,'ko');
   avg = mean(T0)*1e3;
   sig = std(T0)*1e3;
   title(sprintf('Exact periods (%g ms | %g @ 3S)',o.rd(avg),o.rd(3*sig)));
   ylabel('period [ms]');
   set(gca,'ylim',[19.5,20.5]);

      % zerocrossing jitter

   subplot(323);
   plot([0 tmax]*1000,[0 0],'k');
   hold on
   %plot(t0*1000,(t0j-t0)*1e6,'r', t0*1000,(t0l-t0)*1e6,'g');
   plot(t0*1000,(t0j-t0)*1e6,'r', t0*1000,(t0j-t0)*1e6,'ko');
   set(gca,'xlim',[0 tmax*1000]);
   avg = mean(t0j-t0)*1e3;
   sig = std(t0j-t0)*1e6;
   title(sprintf('Zerocross with Jitter (%g ms | %g us @ 3S)',o.rd(avg),o.rd(3*sig,0)));
   ylabel('jitter [us]');

      % period estimates under jitter

   subplot(324);
   plot(1:length(T0),T0*1000,'k');
   hold on
   plot(1:length(Tj),Tj*1000,'r', 1:length(Tj),Tj*1000,'ko');
   avg = mean(Tj)*1e3;
   sig = std(Tj)*1e6;
   title(sprintf('Estimated Period @ Jitter (%g ms | %g us @ 3S)',o.rd(avg),o.rd(3*sig,0)));
   ylabel('period [ms]');
   %set(gca,'ylim',[19.5,20.5]);

      % zerocrossing with latency

   subplot(325);
   plot([0 tmax]*1000,[0 0],'k');
   hold on
   plot(t0*1000,(t0l-t0)*1e6,'g', t0*1000,(t0l-t0)*1e6,'ko');
   set(gca,'xlim',[0 tmax*1000]);
   avg = mean(t0l-t0)*1e3;
   sig = std(t0l-t0)*1e6;
   title(sprintf('Zerocross with Latency (%g ms | %g us @ 3S)',o.rd(avg),o.rd(3*sig,0)));
   ylabel('jitter [us]');

      % period estimates under latency

   subplot(326);
   plot(1:length(T0),T0*1000,'k');
   hold on
   plot(1:length(Tl),Tl*1000,'g', 1:length(Tl),Tl*1000,'ko');
   avg = mean(Tl)*1e3;
   sig = std(Tl)*1e6;
   title(sprintf('Estimated Period @ Latency (%g ms | %g us @ 3S)',o.rd(avg),o.rd(3*sig,0)));
   ylabel('period [ms]');
   %set(gca,'ylim',[19.5,20.5]);

      % calculate periods

   o2 = with(o,'tim2');                % with timer 2
   p = Counter(o2,t0l);

   o6 = with(o,'tim6');                % with timer 6
   q = Counter(o6,t0l);

end

%==========================================================================
% Kafi Basics
%==========================================================================

function [sigw,sigv,sigx] = KafiSigma(o)    % Uniform Sigmas           
%  sigx = [1e3,1e4,1e4,1e4];
   sigw = 1;  sigv = 10;  sigx=[100 100 100 100];
end
function [P,K] = Riccati(A,C,P,Q,R)    % Riccati Equation              
   I = eye(size(A));

      % Iterate Ricati equation 

   K = P*C' * inv(C*P*C'+R);
   S = (I-K*C)*P;
   P = A*S*A' + Q;
end
function y = ShiftL(x,bits)            % shift left                    
   y = round(x*2^bits);
end
function y = ShiftR(x,bits)            % shift right                   
   y = floor(x/2^bits);
end

function o = KafiBasics0(o)            % Basics - Jitter               
   o = Scenario(o);

   [sigw,sigv,sigx] = KafiSigma(o);  
   sigw = [0 1 1]*sigw;
   sigv = [1 0 1]*sigv;
   
   for (ii=1:3)
      A = [1 0;1 1]; B = [1;-1]; C = [0 1]; x = [20000;0];  W = [1;0];
      P=diag(sigx(3:4).^2);
      Q = diag(sigw(ii)^2*[0 1]);  R = sigv(ii)^2; z = 0*x; 
      kT = 0.5*[1.5,-0.5]; u = 0; y_ = 0;  p_ = 0; 

      oo = log(o,'t,x,y,w,v,p,j');
      for (k=0:Kmax(o))
         t = 0.02*k;
         w = sigw(ii)*randn;
         v = sigv(ii)*randn;

            % system output

         y = C*x + v;
         p = y - y_;                   % measured period
         j = p - p_;                   % jitter
         y_ = y;  p_ = p;              % update history

            % Kalman observer 

         oo = log(oo,t,x,y,w,v,p,j);

            % controller

         u = 0;

             % system dynamics

         x = A*x + B*u + W*w;
      end
      Plot(oo);
   end
   
   function o = Plot(o)
      [t,x,y,v,w,p,j] = data(o,'t','x','y','v','w','p','j');

      g = x(1,:);
      p(1) = p(end);  j(1) = j(end-1); j(2) = j(end);
      [avgg,sigg] = steady(o,g);
      [avgp,sigp] = steady(o,p);
      [avgj,sigj] = steady(o,j);
      [avgv,Sigv] = steady(o,v);
      [avgw,Sigw] = steady(o,w);
      [avgy,sigy] = steady(o,y);

      while (1)                        % dynamic noise w               
         subplot(5,3,0*3+ii);
         plot(t,w,'g', t,w,'k.');
         hold on
         ylabel('w [us]');    grid on;
         title(sprintf('dynamic noise: +/- %g us @3s',o.rd(3*Sigw,1)))
         break
      end
      while (2)                        % measure noise v               
         subplot(5,3,1*3+ii);
         plot(t,v,'b', t,v,'k.');
         hold on
         ylabel('v [us]');    grid on;
         title(sprintf('measure noise: +/- %g us @3s',o.rd(3*Sigv,1)))
         break
      end
      while (3)                        % grid period g       
         subplot(5,3,2*3+ii);
         plot(t,g,'m', t,g,'m.');
         hold on
         ylabel('g [us]');    grid on;
         title(sprintf('Grid Period: %g ms +/- %g us @3s',...
                        o.rd(3*avgg/1000,1),o.rd(3*sigg,1)))
         %set(gca,'ylim',20000+[-50,50]);
         break
      end
      while (4)                        % measured period p             
         subplot(5,3,3*3+ii);
         plot(t,p,'r', t,p,'k.');
         hold on
         ylabel('p [us]');    grid on;
         title(sprintf('Measured Period: %g ms +/- %g us @3s',...
                        o.rd(avgp/1000,1),o.rd(3*sigp,1)))
         %set(gca,'ylim',20000+[-50,50]);
         break
      end
      while (5)                        % jitter             
         subplot(5,3,4*3+ii);
         plot(t,j,'c', t,j,'k.');
         hold on
         ylabel('j [us]');    grid on;
         title(sprintf('Jitter: %g ms +/- %g us @3s',...
                        o.rd(avgj/1000,1),o.rd(3*sigj,1)))
         %set(gca,'ylim',20000+[-50,50]);
         break
      end
   end
end
function o = KafiBasics1(o)            % Basics - Order 2              
   o = Scenario(o);

   [sigw,sigv,sigx] = KafiSigma(o);
   varx = sigx.^2; 
   
   A = [1 0;-2 1]; B = [1;-1]; C = [0 1]; x = [1000;500];  W = [0;1];
   P=diag(sigx(3:4).^2);  Q = diag(sigw^2*[0 1]);  R = sigv^2; z = 0*x; 
   kT = 0.5*[1.5,-0.5]; u = 0;
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = sigw*randn;
      v = sigv*randn;
      
         % system output
         
      y = C*x + v;
      
         % Kalman observer 
         
      [P,K] = Riccati(A,C,P,Q,R);

         % observer state transition

      h = A*z + B*u;                   % half transition
      e = y - C*h;                     % error signal
      z = h + K*e;                     % full transition

          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K);

         % controller

      u = -kT*z;

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(oo);
   
   function o = Plot(o)
      [t,y,u,x,z,q,K] = data(o,'t','y','u','x','z','q','K');

      cT = C;
      e = cT*(z-x);
      p = cT*x;                   % actual PWM phase

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y);

      subplot(421);
      plot(t,y,'r', t,y,'k.');
      hold on
      ylabel('measurement y [us]');    grid on;
      title(sprintf('y: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))

      subplot(422);
      plot(t,p,'m', t,p,'k.');  hold on;
      ylabel('Phase p [us]');  grid on;
      plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
      set(gca,'ylim',[-100 100]);
      title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))

      subplot(423);
      plot(t,u,'b', t,u,'k.');
      ylabel('u');  grid on;

      subplot(424);
      plot(t,y,'r', t,y,'k.');
      hold on
      plot(t,x(2,:),'g', t,x(2,:),'g.');
      ylabel('y');  grid on;
      plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
      set(gca,'ylim',[-100 100]);

      subplot(425);
      plot(t,e,'m', t,e,'k.');
      ylabel('e = z(2)-x(2)');   grid on;
      set(gca,'ylim',[-100 100]);
      title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))

      subplot(426);
      plot(t,u,'b', t,u,'k.');
      plot(t,u,'b', t,u,'k.');
      ylabel('u');   grid on;
      set(gca,'ylim',[-100 100]);

      subplot(427);
      plot(t,K(1,:),'g', t,K(1,:),'g.');
      title(sprintf('Kalman gain:  K1:%g', o.rd(K(1,end),3)));
      ylabel('K1');
      xlabel('Time [s]');

      subplot(428);
      plot(t,K(2,:),'b', t,K(2,:),'b.');
      title(sprintf('Kalman gain:  K2:%g', o.rd(K(2,end),3)));
      ylabel('K2');
      xlabel('Time [s]');
   end
end
function o = KafiBasics2(o)            % Basics - Order 3              
%
% The order 3 model is as follows
%
%    [ g´]   [ 1  0  0 ] [ g ]   [ 0  0 ]         [ 1 ]
%    [   ]   [         ] [   ]   [      ] [ u ]   [   ]
%    [ f´] = [ 1  0  0 ]*[ f ] + [ 0  0 ]*[   ] + [ 0 ]*w
%    [   ]   [         ] [   ]   [      ] [ h ]   [   ]
%    [ q´]   [ 1  0  1 ] [ q ]   [-1 -2 ]         [ 0 ]
%
%                        [ g ]
%    [ p ]   [ 0  1  0 ] [   ]   [ 1 -1 ] [ v ]
%    [   ] = [         ]*[ f ] + [      ]*[   ]
%    [ y ]   [ 0  0  1 ] [   ]   [ 1  0 ] [`v ]
%                        [ q ]
%
%  This requires an additional iteration of h:
%
%      h´  =  sat(h + u,hmin,hmax)
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A4 = [1 0 0 0; 1 0 0 0; 0 0 1 0; 1 0 -2 1];
   B4 = [0;0;1;-1];  W4 = [1;0;0;0];
   C4 = [0 1 0 0; 0 0 0 1]; 
   x4 = [20000;20000;10000;1000]; z4 = [0;0;10000;0];
   
   
   A = [1 0 0;  1 0 0;  1 0 1];
   B = [0 0;  0 0; -1 -2];  W = [1;0;0];  V = [1 -1; 1 0];
   C = [0 1 0;  0 0 1]; 
   x = [20000;20000;1000];  z = 0*x;  
   h = 10000; v_ = 0;  r = 1000;  hmin = 8000;  hmax = 12000;
   
   P=diag(sigx([1 2 4]).^2); Q = diag(sigw^2*[ 1 0 1]);  R = diag(sigv^2*[2 1]);
   
   
   P4=diag(sigx.^2);  Q4 = diag(sigw^2*[ 1 0 0 1]);  R4 = diag(sigv^2*[2 1]);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = sigw*randn;
      v = sigv*randn;
      
         % system output
         
      y4 = C4*x4 + V*[v;v_];
      y = C*x + V*[v;v_];
      
         % Kalman observer 
         
      [P4,K4] = Riccati(A4,C4,P4,Q4,R4);
      [P,K] = Riccati(A,C,P,Q,R);

         % observer state transition

      p4 = A4*z4 + B4*u;               % half transition
      p = A*z + B*[u;h];

      e4 = y4 - C4*p4;                 % error signal
      e = y - C*p;
           
      z4 = p4 + K4*e4;                 % full transition
      z = p + K*e;
            
          % output signals

      q4 = C4*z4;                         % Kalman filter output
      d4 = y4 - q4;                       % output deviation

      q = C*z;
      d = y - q;
      
          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u4 = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z4(1);z4(3);z4(4);r];
u  = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1); h;z4(4);r];  % still good!
%     u  = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1); h; z(3);r];

      if (abs(h-x4(3)) > eps)
         error('implementation error: h');
      end
      
      if (h + u < hmin)
         u = hmin-h;
      elseif (h+u > hmax)
         u = hmax-h;
      end
         
          % system dynamics
          
      x4 = A4*x4 + B4*u + W4*w;
      x = A*x + B*[u;h] + W*w;
      h  = h + u;
      v_ = v;                          % shift v into history
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         plot(t,cT*z,'c', t,cT*z,'c.');  hold on;
         ylabel('Phase m:p, c:p^ [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3)));
         ylabel('g: K11, b: K21, m: K31');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(4,:),'g', t,K(4,:),'g.');
         hold on;
         plot(t,K(5,:),'b', t,K(5,:),'b.');
         plot(t,K(6,:),'m', t,K(6,:),'m.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g',...
            o.rd(K(4,end),3),o.rd(K(5,end),3),o.rd(K(6,end),3)));
         ylabel('g: K12, b: K22, m: K32');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Order 3 Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics3(o)            % Basics - Order 4              
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2*ones(2,2);
   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = sigw*randn;
      v = sigv*randn;
      
         % system output
         
      y = C*x + v;
      
         % Kalman observer 
         
      [P,K] = Riccati(A,C,P,Q,R);

         % observer state transition

      h = A*z + B*u;                   % half transition
      e = y - C*h;                     % error signal
      z = h + K*e;                     % full transition

          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Order 4 Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics4(o)            % Basics - Twin                 
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   [sigw,sigv,sigx] = KafiSigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;

   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2;

   i1 = 1:2;  i2 = 3:4     % index to Kf1
   A1 = A(i1,i1);  A2 = A(i2,i2);  B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  
   C1 = C(1,i1);   C2 = C(2,i2);   W1 = W(i1);  W2 = W(i2);
   Q1 = Q(i1,i1);  Q2 = Q(i2,i2); P1=P(i1,i1);  P2 = P(i2,i2);

   y1 = []; y2 = []; q1 = []; q2 = []; K1 = [];  K2 = []; v = []; w = [];
   z1 = z(i1); z2 = z(i2);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
%  kT = dlqr(o,AA,BB,diag([10 100]),1);
   kT = place(AA,BB,poles); 

   function Measure(o)                 % Noise & Measurement           
      w = sigw*randn;
      v = sigv*randn;
         
      y1 = C1*x(i1) + v;
      y2 = C2*x(i2) + v;
   end
   function Observer(o)                % Kalman observer transition    
      [P1,K1] = Riccati(A1,C1,P1,Q1,R);
      [P2,K2] = Riccati(A2,C2,P2,Q2,R);

         % Kalman transition
         
      h1 = A1*z1 + B1*u;               % half transition
      e1 = y1 - C1*h1;                 % error signal 1
      z1 = h1 + K1*e1;                 % full transition

      h2 = A2*z2 + B2*[z1;u];          % half transition
      e2 = y2 - C2*h2;                 % error signal 1
      z2 = h2 + K2*e2;                 % full transition

         % output signals

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function Logging(o)                 % Data Logging                  
      z = [z1;z2];  y = [y1;y2];  q = [q1;q2];  K = [K1;K2];
      oo = log(oo,t,x,y,u,v,z,q,K);
   end
   function Controller(o)              % State Feedback Controller     
   %
   %  calculate u = K1/2*g - K1*h  - K2*q + K2*r
   %
      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
   end
   function System(o)                  % System Dynamics               
      x = A*x + B*u + W*w;
   end  
   function oo = Plot(oo)              % Plot Data                     
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break;
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break;
      end
      
      while (21)                       % plot g (estimated grid period)
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot y (close up)             
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);
         break
      end

      while (31)                       % plot e (observation error)    
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end
      while (32)                       % plot u (control signal)       
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end

      while (41)                       % plot K1 (Kalman gain 1)       
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         title(sprintf('Kalman gains:  K1:%g, K2:%g',...
                       o.rd(K(1,end),6),o.rd(K(2,end),6)));
         ylabel('g: K1, b: K2');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K2 (Kalman gain 2)       
         subplot(428);
         plot(t,K(3,:),'g', t,K(3,:),'g.');
         hold on;
         plot(t,K(4,:),'b', t,K(4,:),'b.');
         title(sprintf('Kalman gains:  K3:%g, K4:%g',...
                       o.rd(K(3,end),6),o.rd(K(4,end),6)));
         ylabel('g: K3, b: K4');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('Twin Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end

   o = Scenario(o);
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      Measure(o);
      Observer(o);
      Logging(o);
      Controller(o);
      System(o);
   end
   Plot(oo);
end
function o = KafiBasics5(o)            % Basics - Qick & Brilliant     
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   [sigw,sigv,sigx] = KafiSigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;

   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = diag(sigv^2*[1 1]);

   i1 = 1:2;  i2 = 3:4     % index to Kf1
   A1 = A(i1,i1);  A2 = A(i2,i2);  B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  
   C1 = C(1,i1);   C2 = C(2,i2);   W1 = W(i1);  W2 = W(i2);
   Q1 = Q(i1,i1);  Q2 = Q(i2,i2); P1=P(i1,i1);  P2 = P(i2,i2);

   y1 = []; y2 = []; q1 = []; q2 = []; K1 = [];  K2 = []; v = []; w = [];
   z1 = z(i1); z2 = z(i2);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
%  kT = dlqr(o,AA,BB,diag([10 100]),1);
   kT = place(AA,BB,poles); 
   
      % QnB state
      
   g_ = 20000;  y1_1 = 0;  g_1 = 20000;  g_2 = 0;

      % Pseudo Kalman Filter
      
   K0_ = 0.6;  K1_ = 0.125;  K2_ = 0.441;
   p_ = 1;  a_ = [0;0]; b_ = [0;0];
   
   function Measure(o)                 % Noise & Measurement           
      w = sigw*randn;
      v = sigv*randn;
         
      y1 = C1*x(i1) + v;
      y2 = C2*x(i2) + v;
   end
   function Observer(o)                % Kalman observer transition    
      [P1,K1] = Riccati(A1,C1,P1,Q1,R(1,1));
      [P2,K2] = Riccati(A2,C2,P2,Q2,R(2,2));
      
         % Kalman transition
         
      h1 = A1*z1 + B1*u;               % half transition
      e1 = y1 - C1*h1;                 % error signal 1
      z1 = h1 + K1*e1;                 % full transition

      h2 = A2*z2 + B2*[z1;u];          % half transition
      e2 = y2 - C2*h2;                 % error signal 1
      z2 = h2 + K2*e2;                 % full transition

         % output signals

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function QnB(o)                     % Quick & Brilliant             
      K1 = [0.08; 0.36];               % exact: K1 = [0.0799; 0.3618];   
      K2 = [0.0;  0.1];                % exact: K2 = [0; 0.0952];
      h = x(3);                        % PWM control period
      if (k<=1)
         z1 = [y1;y1];
         z2 = [h;y2];
      else
         z1 = A1*z1 + B1*u;            % prediction
         z1 = z1 + K1*(y1-C1*z1);      % correction / estimation

         z2 = A2*z2 + B2*[z1;u];       % basic prediction
         z2 = z2 + K2*(y2-C2*z2);      % correction / estimation
         
         z2(1) = h;                    % use h directly!
      end

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function Pseudo(o)                  % Quick & Brilliant             
      b_(1) = K1_ + (1-K1_)*p_;  a_(1) = 1-b_(1);
      b_(2) = K2_ + (1-K2_)*p_;  a_(2) = 1-b_(2);
      
      dz = y1-y1_1;
      g_ =  (a_(1)+a_(2))*g_1 + b_(1)*dz - a_(2)*g_2;
      p_ = K0_*p_;
      
         % update history
        
      y1_1 = y1;  g_2 = g_1;  g_1 = g_;
   end
   function Logging(o)                 % Data Logging                  
      z = [z1;z2];  y = [y1;y2];  q = [q1;q2];  K = [K1;K2];
      oo = log(oo,t,x,y,u,v,z,q,K,g_,b_);
   end
   function Controller(o)              % State Feedback Controller     
   %
   %  calculate u = K1/2*g - K1*h  - K2*q + K2*r
   %
      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
   end
   function System(o)                  % System Dynamics               
      x = A*x + B*u + W*w;
   end  
   function oo = Plot(oo)              % Plot Data                     
      [t,y,u,x,z,q,K,g_,b_] = data(oo,'t','y','u','x','z','q','K','g_','b_');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);
      eg = g_-x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);
      [avgeg,sigeg] = steady(o,eg);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break;
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break;
      end
      
      while (21)                       % plot g (estimated grid period)
         subplot(423);
         plot(t,g,'c', t,g,'c.');
         hold on
         plot(t,g,'r', t,g,'r.');
         plot(t,g_,'y', t,g_,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot y (close up)             
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);
         break
      end

      while (31)                       % plot e (observation error)    
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('eg = g_-x(1)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('eg = g_ - x1: %g +/- %g @3s',o.rd(avgeg,0),o.rd(3*sigeg,0)))
         break
      end
      while (32)                       % plot u (control signal)       
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end

      while (41)                       % plot K1 (Kalman gain 1)       
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');

         plot(t,b_(1,:),'g');
         plot(t,b_(2,:),'b');

         title(sprintf('Kalman gains:  K1:%g, K2:%g',...
                       o.rd(K(1,end),3),o.rd(K(2,end),3)));
         ylabel('g: K1, b: K2');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K2 (Kalman gain 2)       
         subplot(428);
         plot(t,K(3,:),'g', t,K(3,:),'g.');
         hold on;
         plot(t,K(4,:),'b', t,K(4,:),'b.');
         title(sprintf('Kalman gains:  K3:%g, K4:%g',...
                       o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K3, b: K4');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('QnB Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end

   o = Scenario(o);
   oo = log(o,'t,x,y,u,v,z,q,K,g_,b_');
   for (k=0:Kmax(o))
      t = 0.02*k;
      Measure(o);
%     Observer(o);
      QnB(o);                          % Quick & Brilliant             
%     Pseudo(o);                       % Pseudo Kalman             
      Logging(o);
      Controller(o);
      System(o);
   end
   Plot(oo);
end
function o = KafiBasics6(o)            % Basics - Literature           
%
% Rainer Marchthaler and Sebastian Dingler present the algorith as follows:
%
%    P = diag(sigx.^2)                 % cov matrix of predicted state
%    h = h0                            % predicted state
%
%    loop
%       y = measurement                % measure system outputs
%
%          % correction phase
%
%       K = P*C' / (C*P*C' + R)        % calculate Kalman gain K from M
%
%       e = y - C*h                    % prediction error
%       x = h + K*e                    % estimated (corrected) state
%
%       S = (I-K*C)*M                  % cov matrix of estimated state
%
%          % calculate control signal
%
%       u = f(x)                       % control law
%
%          % prediction phase
%
%       h` = A*x + B*u                 % predicted state (for next loop)
%       P` = A*S*A' + Q                % cov matrix of predicted state
%
% The QnB (quick&brilliant) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];  I = eye(size(A));
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;  h = z;
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2;

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;

   poles = 0.2*[1 1];
   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      
         % measurement
         
      w = sigw*randn;
      v = sigv*randn;
      y = C*x + v;
      
         % correction phase 
         
      K = P*C' / (C*P*C' + R);         % calculate Kalman gain K from P

      e = y - C*h;                     % prediction error
      z = h + K*e;                     % estimated (corrected) state

      S = (I-K*C)*P;                   % cov matrix of estimated state

         % output signals (optional)
         
      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
      
         % logging

      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % prediction phase (state transition)

      h = A*z + B*u;                   % predicted state for next loop
      P = A*S*A' + Q;                  % cov matrix of predicted state

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('Literature 4 Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics7(o)            % Basics - Know H               
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1; 0 0 1 0];  V = [1;1;0];
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;
   
   P=diag(sigx.^2);
   Q = diag(sigw^2*[ 1 0 0 1]);  R = diag(sigv^2*[1 1 0.001]);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = sigw*randn;
      v = sigv*randn;
      
         % system output
         
      y = C*x + V*v;
      
         % Kalman observer 
         
      [P,K] = Riccati(A,C,P,Q,R);

         % observer state transition

      h = A*z + B*u;                   % half transition
      e = y - C*h;                     % error signal
      z = h + K*e;                     % full transition

          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Order 4 Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics8(o)            % Basics - Delta 4              
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 0 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;20000;10000;1000]; z = 0*x;  v_ = 0;
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = diag(sigv^2*[2 1]);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = sigw*randn;
      v = sigv*randn;
      
         % system output
         
      y = C*x + [v-v_;v];  v_ = v;
      
         % Kalman observer 
         
      [P,K] = Riccati(A,C,P,Q,R);

         % observer state transition

      h = A*z + B*u;                   % half transition
      e = y - C*h;                     % error signal
      z = h + K*e;                     % full transition

          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Delta 4 Kalman - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics9(o)            % Basics - TwinD                
%
% The TwinD system equations are
%
%    [ g']   [ 1   0 ] [ g ]   [ 1 ]
%    [   ] = [       ]*[   ] + [   ]*w 
%    [ f']   [ 1   0 ] [ f ]   [ 0 ]
%
%      p   = [ 0   1 ]*[ g  f ]' + (w - ´w)
%
   [sigw,sigv,sigx] = KafiSigma(o);

   A = [1 0 0 0; 1 0 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;

   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2;

   i1 = 1:2;  i2 = 3:4     % index to Kf1
   A1 = A(i1,i1);  A2 = A(i2,i2);  B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  
   C1 = C(1,i1);   C2 = C(2,i2);   W1 = W(i1);  W2 = W(i2);
   Q1 = Q(i1,i1);  Q2 = Q(i2,i2); P1=P(i1,i1);  P2 = P(i2,i2);

   y1 = []; y2 = []; q1 = []; q2 = []; K1 = [];  K2 = []; v = []; w = [];
   z1 = z(i1); z2 = z(i2); v_ = 0;

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
%  kT = dlqr(o,AA,BB,diag([10 100]),1);
   kT = place(AA,BB,poles); 

   function Measure(o)                 % Noise & Measurement           
      w = sigw*randn;
      v = sigv*randn;
         
      y1 = C1*x(i1) + (v - v_);  v_ = v;
      y2 = C2*x(i2) + v;
   end
   function Observer(o)                % Kalman observer transition    
      [P1,K1] = Riccati(A1,C1,P1,Q1,2*R);
      [P2,K2] = Riccati(A2,C2,P2,Q2,R);

         % Kalman transition
         
      h1 = A1*z1 + B1*u;               % half transition
      e1 = y1 - C1*h1;                 % error signal 1
      z1 = h1 + K1*e1;                 % full transition

      h2 = A2*z2 + B2*[z1;u];          % half transition
      e2 = y2 - C2*h2;                 % error signal 1
      z2 = h2 + K2*e2;                 % full transition

         % output signals

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function Logging(o)                 % Data Logging                  
      z = [z1;z2];  y = [y1;y2];  q = [q1;q2];  K = [K1;K2];
      oo = log(oo,t,x,y,u,v,z,q,K);
   end
   function Controller(o)              % State Feedback Controller     
   %
   %  calculate u = K1/2*g - K1*h  - K2*q + K2*r
   %
      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
   end
   function System(o)                  % System Dynamics               
      x = A*x + B*u + W*w;
   end  
   function oo = Plot(oo)              % Plot Data                     
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break;
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break;
      end
      
      while (21)                       % plot g (estimated grid period)
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot y (close up)             
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);
         break
      end

      while (31)                       % plot e (observation error)    
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end
      while (32)                       % plot u (control signal)       
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end

      while (41)                       % plot K1 (Kalman gain 1)       
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         title(sprintf('Kalman gains:  K1:%g, K2:%g',...
                       o.rd(K(1,end),3),o.rd(K(2,end),3)));
         ylabel('g: K1, b: K2');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K2 (Kalman gain 2)       
         subplot(428);
         plot(t,K(3,:),'g', t,K(3,:),'g.');
         hold on;
         plot(t,K(4,:),'b', t,K(4,:),'b.');
         title(sprintf('Kalman gains:  K3:%g, K4:%g',...
                       o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K3, b: K4');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('TwinD Basics - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end

   o = Scenario(o);
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      Measure(o);
      Observer(o);
      Logging(o);
      Controller(o);
      System(o);
   end
   Plot(oo);
end
function o = KafiBasics10(o)           % Basics - Twin Lu              
%
% Tin Lu. Twin Filter with two cascaded Luenberger observers
%
   [sigw,sigv,sigx] = KafiSigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;

   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2;

   i1 = 1:2;  i2 = 3:4     % index to Kf1
   A1 = A(i1,i1);  A2 = A(i2,i2);  B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  
   C1 = C(1,i1);   C2 = C(2,i2);   W1 = W(i1);  W2 = W(i2);

   y1 = []; y2 = []; q1 = []; q2 = []; K1 = [];  K2 = []; v = []; w = [];
   z1 = z(i1); z2 = z(i2);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
%  kT = dlqr(o,AA,BB,diag([10 100]),1);
   kT = place(AA,BB,poles); 
   
      % in the final phase we use the Kalman stationary gains
      
   function Measure(o)                 % Noise & Measurement           
      w = sigw*randn;
      v = sigv*randn;
         
      y1 = C1*x(i1) + v;
      y2 = C2*x(i2) + v;
   end
   function Observer(o)                % Kalman observer transition    
      K1 = [0.08; 0.36];               % exact: K1 = [0.0799; 0.3618];   
      K2 = [0.0;  0.1];                % exact: K2 = [0; 0.0952];
      
      z1 = A1*z1 + B1*u;            % prediction
      z1 = z1 + K1*(y1-C1*z1);      % correction / estimation

      z2 = A2*z2 + B2*[z1;u];       % basic prediction
      z2 = z2 + K2*(y2-C2*z2);      % correction / estimation
         
         % override all calculations in the initial phase
         
      if (k<=1)
         z1 = [y1;y1];
         z2 = [x(3);y2];
      end

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function Logging(o)                 % Data Logging                  
      z = [z1;z2];  y = [y1;y2];  q = [q1;q2];  K = [K1;K2];
      oo = log(oo,t,x,y,u,v,z,q,K);
   end
   function Controller(o)              % State Feedback Controller     
   %
   %  calculate u = K1/2*g - K1*h  - K2*q + K2*r
   %
      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
   end
   function System(o)                  % System Dynamics               
      x = A*x + B*u + W*w;
   end  
   function oo = Plot(oo)              % Plot Data                     
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break;
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break;
      end
      
      while (21)                       % plot g (estimated grid period)
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         hold on
         plot(t,z(1,:),'y', t,z(1,:),'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot y (close up)             
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);
         break
      end

      while (31)                       % plot e (observation error)    
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end
      while (32)                       % plot u (control signal)       
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end

      while (41)                       % plot K1 (Kalman gain 1)       
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         title(sprintf('Kalman gains:  K1:%g, K2:%g',...
                       o.rd(K(1,end),3),o.rd(K(2,end),3)));
         ylabel('g: K1, b: K2');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K2 (Kalman gain 2)       
         subplot(428);
         plot(t,K(3,:),'g', t,K(3,:),'g.');
         hold on;
         plot(t,K(4,:),'b', t,K(4,:),'b.');
         title(sprintf('Kalman gains:  K3:%g, K4:%g',...
                       o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K3, b: K4');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('Twin Dead - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end

   o = Scenario(o);
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      Measure(o);
      Observer(o);
      Logging(o);
      Controller(o);
      System(o);
   end
   Plot(oo);
end
function o = KafiBasics11(o)           % Basics - Twin Tri             
%
% Tin Lu. Twin Filter with two cascaded Luenberger observers
%
   [sigw,sigv,sigx] = KafiSigma(o);

   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;

   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2;

   i1 = 1:2;  i2 = 3:4     % index to Kf1
   A1 = A(i1,i1);  A2 = A(i2,i2);  B1 = B(i1);  B2 = [A(i2,i1),B(i2)];  
   C1 = C(1,i1);   C2 = C(2,i2);   W1 = W(i1);  W2 = W(i2);
   Q1 = Q(i1,i1);  Q2 = Q(i2,i2); P1=P(i1,i1);  P2 = P(i2,i2);

   y1 = []; y2 = []; q1 = []; q2 = []; K1 = [];  K2 = []; v = []; w = [];
   z1 = z(i1); z2 = z(i2);

   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
%  kT = dlqr(o,AA,BB,diag([10 100]),1);
   kT = place(AA,BB,poles); 
   
      % in the stabilization phase we use a Luenberger observer with 
      % poles at 0.2
      
   K1_1 = place(A1',C1',[0.2 0.2])';
   K2_1 = place(A2',C2',[0.2 0.2])';
   
      % in the final phase we use the Kalman stationary gains
      
   K1_2 = [0.0799; 0.3618];
   K2_2 = [0; 0.0952]

   function Measure(o)                 % Noise & Measurement           
      w = sigw*randn;
      v = sigv*randn;
         
      y1 = C1*x(i1) + v;
      y2 = C2*x(i2) + v;
   end
   function Observer(o)                % Kalman observer transition    
      %[P1,K1] = Riccati(A1,C1,P1,Q1,R);
      %[P2,K2] = Riccati(A2,C2,P2,Q2,R);

      if (k <= 2000)                   % stabilization with Luenberger gain 
         K1 = K1_1;
         K2 = K2_1;
      else                             % final phase: use Kalman gains
         K1 = K1_2;
         K2 = K2_2;
      end
      
      if (k<=1)
         z1 = [y1;y1];
      else
         z1 = A1*z1 + B1*u;            % prediction
         z1 = z1 + K1*(y1-C1*z1);      % correction / estimation
      end
      
      if (k<=1)
         z2 = [x(3);y2];
      else
         z2 = A2*z2 + B2*[z1;u];          % basic prediction
         z2 = z2 + K2*(y2-C2*z2);         % correction / estimation
         
z2(1)=x(3);         
      end

      q1 = C1*z1;                      % Kalman filter 1 output
      d1 = y1 - q1;                    % output deviation

      q2 = C2*z2;                      % Kalman filter 2 output
      d2 = y2 - q2;                    % output deviation
   end
   function Logging(o)                 % Data Logging                  
      z = [z1;z2];  y = [y1;y2];  q = [q1;q2];  K = [K1;K2];
      oo = log(oo,t,x,y,u,v,z,q,K);
   end
   function Controller(o)              % State Feedback Controller     
   %
   %  calculate u = K1/2*g - K1*h  - K2*q + K2*r
   %
      u = -[-kT(1)/2, kT(1), kT(2), -kT(2)] * [z(1);z(3);z(4);r];
   end
   function System(o)                  % System Dynamics               
      x = A*x + B*u + W*w;
   end  
   function oo = Plot(oo)              % Plot Data                     
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break;
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break;
      end
      
      while (21)                       % plot g (estimated grid period)
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         hold on
         plot(t,z(1,:),'y', t,z(1,:),'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot y (close up)             
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);
         break
      end

      while (31)                       % plot e (observation error)    
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end
      while (32)                       % plot u (control signal)       
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end

      while (41)                       % plot K1 (Kalman gain 1)       
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         title(sprintf('Kalman gains:  K1:%g, K2:%g',...
                       o.rd(K(1,end),3),o.rd(K(2,end),3)));
         ylabel('g: K1, b: K2');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K2 (Kalman gain 2)       
         subplot(428);
         plot(t,K(3,:),'g', t,K(3,:),'g.');
         hold on;
         plot(t,K(4,:),'b', t,K(4,:),'b.');
         title(sprintf('Kalman gains:  K3:%g, K4:%g',...
                       o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K3, b: K4');
         xlabel('Time [s]');
         break
      end
      
      xlabel(sprintf('Twin Dead - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end

   o = Scenario(o);
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      Measure(o);
      Observer(o);
      Logging(o);
      Controller(o);
      System(o);
   end
   Plot(oo);
end
function o = KafiBasics12(o)           % Basics - Brilliant 1          
%
% The Qnd (quick&dirty) control law is:
%
%    dh = h - g/2;
%    dq = q - r
%    u = -K*[dh;dq] = -K1*(h - g/2) - K2*(q - r)
%
%    [dh']   [ 1   0 ] [ dh ]   [ 1 ]
%    [   ] = [       ]*[    ] + [   ]*u 
%    [dq']   [-2   1 ] [ dq ]   [-1 ]
%
% This can be rearranged as
%
%    u = -K1*h + K1/2*g - K2*q + K2*r = -[-K1/2 K1 K2 -K2]*[g;h;q;r]
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 1 0 0; 0 0 1 0; 1 0 -2 1];
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1]; 
   x = [20000;0;10000;1000]; z = 0*x;
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2*[1 1;1 1];

   i1 = 1:2;  i2 = 3:4;                % access indices
   A1 = A(i1,i1); A2 = A(i2,i2); C1 = C(1,i1);  C2 = C(2,i2);
   P1 = P(i1,i1); P2 = P(i2,i2);
   Q1 = Q(i1,i1); Q2 = Q(i2,i2); R1 = R(1,1); R2 = R(2,2);
   
   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   for (i=0:20)
      [P,K] = Riccati(A,C,P,Q,R);      % find steady Kalman gain matrix
   end
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = round(sigw*randn);
      v = round(sigv*randn);
      
         % system output
         
      y = C*x + v;
      
         % observer state transition

      p = A*z + B*u;                   % predicted state
      e = y - C*p;                     % prediction error
      z = p + K*e;                     % estimated state
      
         % here's the second part of the brilliant idea
         
      if (k <= 1)
         z = [y(1);y(1);y(1)/2; y(2)]; % override in initial phase
      end
      
          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, 0, kT(1), kT(2), -kT(2)] * [z;r];

          % system dynamics
          
      x = A*x + B*u + W*w;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Billiant 1 - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics13(o)           % Basics - Brilliant 2          
%
% Delta implementation of Brilliant Kalman filter
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 0 0 0; 0 0 1 0; 1 0 -2 1];  % Delta-Model !!!
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1];  V = [1 0; 1 -1]; 
   x = [20000;20000;10000;1000]; z = 0*x;  v_ = 0; p = z;  e = [0;0];
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = sigv^2*ones(2,2);
   i1 = 1:2;  i2 = 3:4;                % access indices
   A1 = A(i1,i1); A2 = A(i2,i2); C1 = C(1,i1);  C2 = C(2,i2);
   P1 = P(i1,i1); P2 = P(i2,i2);
   Q1 = Q(i1,i1); Q2 = Q(i2,i2); R1 = R(1,1); R2 = R(2,2);
   
   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   for (i=0:20)
      [P,K] = Riccati(A,C,P,Q,R);      % find steady Kalman gain matrix
   end
   for (i=0:1000)
      [P1,K1] = Riccati(A1,C1,P1,Q1,R1);
      [P2,K2] = Riccati(A2,C2,P2,Q2,R2);
   end
      % the results: 
      
   a1 = 0.0782;  a2 = 0.0564;  a3 = 0.024;  a4 = -0.009;  a5 = 0.3549;  
   K = [a1 a2; a1 a2; a3 a4; a2 a5];
   K = [0.079889 0; 0.361769 0;  0 0;  0 0.09517];
K1=[0.1;0.1]; K2 = [0;0.1];   
   K = [K1 0*K1; 0*K2 K2];
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = round(sigw*randn);
      v = round(sigv*randn);
      
         % system output
         
      y = C*x + V*[v;v_];
      
         % p = A*z + B*u;              % predicted state
         
      p(1) = z(1);                     % predicted state 1
      p(2) = z(1);                     % predicted state 2
      p(3) = z(3) + u;                 % predicted state 3
      p(4) = z(1) - z(3) + z(4) - p(3);% predicted state 4

         % e = y - C*p;                % prediction error
         
      e(1) = y(1) - p(2);   
      e(2) = y(2) - p(4);
      
          % first part of brilliant idea: use a static gain      
          % z = p + K*e;               % estimated state
    
      z(1) = p(1) + a1*e(1) + a2*e(2);
      z(2) = p(2) + a1*e(1) + a2*e(2);
      z(3) = p(3) + a3*e(1) + a4*e(2);
      z(4) = p(4) + a2*e(1) + a5*e(2);
          
         % here's the second part of the brilliant idea
         
      if (k <= 1)
         z = [y(1);y(1);y(1)/2; y(2)]; % override in initial phase
      end
      
          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, 0, kT(1), kT(2), -kT(2)] * [z;r];
      
         % constrain control signal 
         
      if (u + z(3) > 12000)
         u = 12000 - z(3);
      elseif (u + z(3) < 8000)
         u = 8000 - z(3);
      end
      
          % system dynamics
          
      x = A*x + B*u + W*w;
      v_ = v;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Billiant 2 - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end
function o = KafiBasics14(o)           % Basics - Brilliant 3          
%
% integer based Delta implementation of Brilliant Kalman filter
%
   o = Scenario(o);
   [sigw,sigv,sigx] = KafiSigma(o);
   
   A = [1 0 0 0; 1 0 0 0; 0 0 1 0; 1 0 -2 1];  % Delta-Model !!!
   B = [0;0;1;-1];  W = [1;0;0;0];
   C = [0 1 0 0; 0 0 0 1];  V = [1 0; 1 -1]; 
   x = [20000;20000;10000;1000]; z = 0*x;  v_ = 0; p = z;  e = [0;0];
   r = 1000;
   
   P=diag(sigx.^2);  Q = diag(sigw^2*[ 1 0 0 1]);  R = diag(sigv^2*[1 1]);

   i1 = 1:2;  i2 = 3:4;                % access indices
   A1 = A(i1,i1); A2 = A(i2,i2); C1 = C(1,i1);  C2 = C(2,i2);
   P1 = P(i1,i1); P2 = P(i2,i2);
   Q1 = Q(i1,i1); Q2 = Q(i2,i2); R1 = R(1,1); R2 = R(2,2);
   
   AA = [1 0;-2 1]; BB = [1;-1];  u = 0;
   poles = 0.0*[1 1];
   poles=0.2*[1 1];

   kT = place(AA,BB,poles); 
   kT = dlqr(o,AA,BB,diag([10 100]),1);
   
   for (i=0:20)
      [P,K] = Riccati(A,C,P,Q,R);      % find steady Kalman gain matrix
   end
   
      % override K values, at the same time use integer representation 
      % @ 2^14 base
   
   bits = 14;                          % ipar representation base = 2^bits
   
   a1 = ShiftL(0.0782,bits); 
   a2 = ShiftL(0.0564,bits);
   a3 = ShiftL(0.0240,bits);
   a4 = ShiftL(-0.009,bits);
   a5 = ShiftL(0.3549,bits);
   
   K = [a1 a2; a1 a2; a3 a4; a2 a5];
   
   oo = log(o,'t,x,y,u,v,z,q,K');
   for (k=0:Kmax(o))
      t = 0.02*k;
      w = round(sigw*randn);
      v = round(sigv*randn);
      
         % system output
         
      y = C*x + V*[v;v_];
      
         % p = A*z + B*u;              % predicted state
         
      p(1) = z(1);                     % predicted state 1
      p(2) = z(1);                     % predicted state 2
      p(3) = z(3) + u;                 % predicted state 3
      p(4) = z(1) - z(3) + z(4) - p(3);% predicted state 4

         % e = y - C*p;                % prediction error
         
      e(1) = y(1) - p(2);   
      e(2) = y(2) - p(4);
      
          % first part of brilliant idea: use a static gain      
          % z = p + K*e;               % estimated state
    
      z(1) = p(1) + ShiftR(a1*e(1) + a2*e(2),bits);
      z(2) = p(2) + ShiftR(a1*e(1) + a2*e(2),bits);
      z(3) = p(3) + ShiftR(a3*e(1) + a4*e(2),bits);
z(3) = p(3);      
      z(4) = p(4) + ShiftR(a2*e(1) + a5*e(2),bits);
          
         % here's the second part of the brilliant idea
         
      if (k <= 1)
         z = [y(1);y(1);y(1)/2; y(2)]; % override in initial phase
      end
      
          % output signals

      q = C*z;                         % Kalman filter output
      d = y - q;                       % output deviation

          % logging
          
      oo = log(oo,t,x,y,u,v,z,q,K(:));

         % controller: u = K1/2*g - K1*h  - K2*q + K2*r

      u = -[-kT(1)/2, 0, kT(1), kT(2), -kT(2)] * [z;r];
      
         % constrain control signal 
         
      if (u + z(3) > 12000)
         u = 12000 - z(3);
      elseif (u + z(3) < 8000)
         u = 8000 - z(3);
      end
      
          % system dynamics
          
      x = A*x + B*u + W*w;
      v_ = v;
   end
   Plot(o);
   
   function Plot(o)                    % Plot Signals                  
      [t,y,u,x,z,q,K] = data(oo,'t','y','u','x','z','q','K');

      cT = C(2,:);
      e = cT*(z-x);
      p = cT*x;                        % actual PWM phase
      g = x(1,:);

      [avge,sige] = steady(o,e);
      [avgp,sigp] = steady(o,p);
      [avgy,sigy] = steady(o,y(2,:));
      [avgg,sigg] = steady(o,g);

      while (11)                       % plot y                        
         subplot(421);
         plot(t,y(2,:),'r', t,y(2,:),'k.');
         hold on
         plot(t,p,'g', t,p,'g.');
         ylabel('y(r), x2(g)');    grid on;
         title(sprintf('y and x2: %g +/- %g @3s',o.rd(avgy,0),o.rd(3*sigy,0)))
         break
      end      
      while (12)                       % plot p (phase)                
         subplot(422);
         plot(t,p,'m', t,p,'k.');  hold on;
         ylabel('Phase p [us]');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgp,-2)+[-100 100]);
         title(sprintf('Actual Phase p = x2: %g +/- %g @3s',o.rd(avgp,0),o.rd(3*sigp,0)))
         break
      end
      
      while (21)                       % plot g (grid period)          
         subplot(423);
         plot(t,g,'g', t,g,'k.');
         ylabel('g [us]');  grid on;
         set(gca,'ylim',o.rd(avgg,-2)+[-100 100]);
         title(sprintf('Grid Period g: %g +/- %g @3s',o.rd(avgg,0),o.rd(3*sigg,0)))
         break
      end      
      while (22)                       % plot r/y                      
         subplot(424);
         plot(t,y,'r', t,y,'k.');
         hold on
         plot(t,x(2,:),'g', t,x(2,:),'g.');
         ylabel('y');  grid on;
         plot(t,0*t-3*sigv,'b-', t,0*t+3*sigv,'b-');
         set(gca,'ylim',o.rd(avgy,-2)+[-100 100]);

         break
      end
      
      while (31)                       % plot e                        
         subplot(425);
         plot(t,e,'m', t,e,'k.');
         ylabel('e = z(2)-x(2)');   grid on;
         set(gca,'ylim',[-100 100]);
         title(sprintf('e = z2 - x2: %g +/- %g @3s',o.rd(avge,0),o.rd(3*sige,0)))
         break
      end      
      while (32)                       % plot u                        
         subplot(426);
         plot(t,u,'b', t,u,'k.');
         plot(t,u,'b', t,u,'k.');
         ylabel('u');   grid on;
         set(gca,'ylim',[-100 100]);
         break
      end
      
      while (41)                       % plot K                        
         subplot(427);
         plot(t,K(1,:),'g', t,K(1,:),'g.');
         hold on;
         plot(t,K(2,:),'b', t,K(2,:),'b.');
         plot(t,K(3,:),'m', t,K(3,:),'m.');
         plot(t,K(4,:),'k', t,K(4,:),'k.');
         title(sprintf('Kalman gains:  K11:%g, K21:%g, K31:%g, K41:%g',...
            o.rd(K(1,end),3),o.rd(K(2,end),3),o.rd(K(3,end),3),o.rd(K(4,end),3)));
         ylabel('g: K11, b: K21, m: K31, k: K41');
         xlabel('Time [s]');
         break
      end
      while (42)                       % plot K                        
         subplot(428);
         plot(t,K(5,:),'g', t,K(5,:),'g.');
         hold on;
         plot(t,K(6,:),'b', t,K(6,:),'b.');
         plot(t,K(7,:),'m', t,K(7,:),'m.');
         plot(t,K(8,:),'k', t,K(8,:),'k.');
         title(sprintf('Kalman gains:  K12:%g, K22:%g, K32:%g, K42:%g',...
            o.rd(K(5,end),3),o.rd(K(6,end),3),o.rd(K(7,end),3),o.rd(K(8,end),3)));
         ylabel('g: K12, b: K22, m: K32, k: K42');
         xlabel('Time [s]');
         break
      end
      xlabel(sprintf('Billiant 2 - sigma = [%g,%g,%g]',...
                     sigw,sigv,sigx(1)));
   end
end

%==========================================================================
% State Space Representation & Luenberger Observer
%==========================================================================

function o = StateSpace(o)             % Kalman filtering              
   oo = Basics(o);
   jitter = var(oo,'jitter');

   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   wg = [0;0]*jitter;                  % dynamic noise (grid frequency)
   vg = jitter;                        % measurement noise (jitter)

   wt = wg;                            % dynamic noise visible on timer
   vt = jitter/Dt;                     % timer jitter

   kmax = length(vg);

   xg = [Tg;Tg0];                      % grid state
   xt = [Tg;Tg0-Tt0];                  % timer state
   A = [1 0; 1 1];
   Cg = [0 1];
   Ct = [0 1/Dt];

   for (k=1:kmax)
       zg(k) = Cg*xg;                  % exact zero cross
       yg(k) = Cg*xg + vg(k);          % zero cross with jitter

       zt(k) = Ct*xt;                  % timer counter reading
       yt(k) = Ct*xt + vt(k);          % timer counter reading under jitter

       xg = A*xg + wg(:,k);
       xt = A*xt + wt(:,k);

       subplot(311);  hold on;
       plot(zg(k)*1000,Grid(o,zg(k)),'ko');
       plot(yg(k)*1000,Grid(o,yg(k)),'ro');

       subplot(312);  hold on;
       ztq = Quantize(zt(k),Tt/Dt);
       ytq = Quantize(yt(k),Tt/Dt);
       plot(zg(k)*1000,ztq,'ko');
       plot(yg(k)*1000,ytq,'mo');
   end

   subplot(313); hold off
   plot(0:k-1,1e6*vg,'g', 0:k-1,1e6*vg,'ko');
   hold on
   plot(0:k-1,yt-zt,'r');
   ylabel('jitter [us]');
   title('Jitter');

end
function o = SystemStudy(o)            % System Modelling Study        
   o = Mini(o);                        % eventual mini study setup
end
function o = Luenberger(o)             % Luenberger Observer           
   [Tt0,Tt,Dt] = TimerParameter(o);
   A = [1 0; 1 1];  C = [0 1/Dt];

   K  = arg(o,1)*1e-6;                 % observer gain vector
   xm = arg(o,2)*1e-3;                 % model initial state

   LuenbergerSimu(o);
end
function o = LuenbergerSimu(o)         % Luenberger Observer Simulation
   Random(o);                          % hande random seed
   K  = arg(o,1)*1e-6;                 % observer gain vector
   xm = arg(o,2)*1e-3;                 % model initial state

%K = [0.4 1.5]*1e-6;
%xm = [0.02 0.006];
%xm=[];
   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   kmax = opt(o,'simu.periods');
   sigv = opt(o,{'grid.jitter',60e-6}) / 3;
   sigw = opt(o,{'grid.vario',10e-6}) / 3;

   vg = sigv*randn(1,kmax);            % measurement noise (jitter)
   wg = sigw*[1;0]*randn(1,kmax);      % dynamic noise (grid frequency)

   wt = wg;                            % dynamic noise visible on timer
   vt = vg/Dt;                         % timer jitter

   xg = [Tg;Tg0];                      % grid state
   Ag = [1 0; 1 1];                    % grid system matrix
   Cg = [0 1];                         % grid output matrix

   xt = [Tg;Tg0-Tt0];                  % timer state
   At = Ag;                            % timer system matrix
   Ct = [0 1/Dt];                      % timer output matrix

   xm = o.either(xm(:),0.9*xt);        % model state
   Am = At;                            % model system matrix
   Cm = Ct;                            % model output matrix

      % observer gain: note that K = [0 1e-6]' does the job

   Knom = [0.4 1.5]'*1e-6;
   Knom = -place(Am',-Cm',0.7*[1 1])';
   K = o.either(K(:),Knom);            % observer gain vector

   for (k=1:kmax)
       xg1(k) = xg(1);                 % actual period
       zg(k) = Cg*xg;                  % exact zero cross
       yg(k) = Cg*xg + vg(k);          % zero cross with jitter

       xt1(k) = xt(1);
       zt(k) = Ct*xt;                  % timer counter reading w/o jitter
       yt(k) = Ct*xt + vt(k);          % timer counter reading under jitter

       xm1(k) = xm(1);
       ym(k) = Cm*xm;                  % model counter reading
       yd(k) = yt(k) - ym(k);          % output deviation

       xg = Ag*xg + wg(:,k);           % grid transition
       xt = At*xt + wt(:,k);           % timer transition
       xm = Am*xm + K*yd(k);           % model transition
   end

   o = var(o,'kk',0:k-1);  o = var(o,'vt',vt);   o = var(o,'yt',yt);
   o = var(o,'zt',zt);     o = var(o,'ym',ym);   o = var(o,'yd',yd);
   o = var(o,'xg1',xg1);   o = var(o,'xt1',xt1); o = var(o,'xm1',xm1);

   Plot(o);
end

%==========================================================================
% System Studies
%==========================================================================

function p = SystemSetup(o)            % Setup System Parameters       
   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   p.sigw = opt(o,{'grid.vario',10e-6}) / 3;
   p.sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;

   kmax = Kmax(o);
   p.k = 0;                            % init run index

   p.w = p.sigw*[1;0]*randn(1,kmax);   % dynamic noise (grid frequency)
   p.v = p.sigv*randn(1,kmax);         % measurement noise (jitter)

   p.Xk = [Tg;Tg0-Tt0];                % timer state
   p.A = [1 0; 1 1];                   % system matrix
   p.C = [0 1/Dt];                     % timer output matrix

end
function p = SystemLoop(p)             % Loop System                   
   k = p.k+1;                          % next index
   p.k = k;                            % update run index

   p.xt1(k) = p.Xk(1);

   p.zk = p.C*p.Xk;                    % timer counter reading w/o jitter
   p.yk = p.C*p.Xk + p.v(k);           % timer counter reading under jitter

      % logging

   p.x(:,k) = p.Xk;
   p.y(k) = p.yk;
   p.z(k) = p.zk;

      % state transition

   p.Xk = p.A*p.Xk + p.w(:,k);         % timer transition
end

function o = Sys_Init(o)               % Init System Parameters        
   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   sigw = opt(o,{'grid.vario',10e-6}) / 3;
   sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;

   kmax = Kmax(o);
   k = 0;                              % init run index

   w = sigw*[1;0]*randn(1,kmax);       % dynamic noise (grid frequency)
   v = sigv*randn(1,kmax);             % measurement noise (jitter)

   x = [Tg;Tg0-Tt0];                   % timer state
   A = [1 0; 1 1];                     % system matrix
   C = [0 1/Dt];                       % timer output matrix

      % variable storage

   o = var(o,'k',k, 'sigw',sigw, 'sigv',sigv, 'w',w, 'v',v);
   o = var(o,'A',A, 'C',C, 'x',x);

      % log init

   o = log(o,'x,y,z,w,v,g,t,tj');
end
function o = Sys_Loop(o)               % Loop System                   
   [k,A,C,x] = var(o,'k','A','C','x');

      % signal calculation

   k = k+1;                            % next index

   g = x(1);
   w = var(o).w(:,k);                  % dynamic noise
   v = var(o).v(k);                    % measurement noise

   z = C*x;                            % timer counter reading w/o jitter
   y = C*x + v;                        % timer counter reading under jitter

   t = z;                              % zero cross time, without jitter
   tj = y;                             % jittered time

      % data logging

   o = log(o,x,y,z,w,v,g,t,tj);

      % state transition

   x = A*x + w;                        % timer transition

      % variable storage

   o = var(o,'k',k, 'x',x, 'y',y, 'g',g, 't',t, 'tj',tj);
end

function o = PolePlace(o)              % Pole Placement Control        
%
%
%   [ x(k+1) ]   [ 1   0   0 ]   [ x(k) ]   [ 0 ]          [ 1 ]
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ h(k+1) ] = [ 0   1   0 ] * [ h(k) ] + [ 1 ] * u(k) + [ 0 ] * w(k)
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ z(k+1) ]   [ 1  -2   1 ]   [ z(k) ]   [-1 ]          [ 0 ]
%
%       y(k)   = [ 0   0   1 ] *   x(k) + v(k)
%
   A = [
          1   0   0
          0   1   0
          1  -2   1
       ];
   B = [  0   1  -1 ]';
   C = [  0   0   1 ];

   x0 = 1;  h0 = 1;  z0 = 0;
   xk = [x0 h0 z0]';
   fk = 0;

   AA = [A(2:3,2:3) [0;0]; C(2:3) 1];
   BB = [B(2:3); 0];

   poles = 0.4*[1 1 0.5];
   K = [0 place(AA,BB,poles)];

   kmax = 20;
   for (k=1:kmax+1)
      yk = C*xk;
      uk = -K*[xk;fk];

      xk = A*xk + B*uk;
      fk = fk + C*xk;

      x(:,k) = xk;
      y(k) = yk;
      u(k) = uk;
      f(k) = fk;
   end

   t=0:kmax;
   subplot(211);
   plot(t,u*0,'k', t,u,'b', t,u,'bo');
   title('u');

   subplot(212);
   plot(t,y,'r',  t,y,'ro');
   title('y');
end
function o = LqrControl(o)             % LQR Controller                
%
%
%   [ x(k+1) ]   [ 1   0   0 ]   [ x(k) ]   [ 0 ]          [ 1 ]
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ h(k+1) ] = [ 0   1   0 ] * [ h(k) ] + [ 1 ] * u(k) + [ 0 ] * w(k)
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ z(k+1) ]   [ 1  -2   1 ]   [ z(k) ]   [-1 ]          [ 0 ]
%
%       y(k)   = [ 0   0   1 ] *   x(k) + v(k)
%
   o = Mini(o);

   A = [
          1   0   0
          0   1   0
          1  -2   1
       ];
   B = [  0   1  -1 ]';
   C = [  0   0   1 ];

   x0 = 20;  h0 = 10;  q0 = 4;  f0 = 0;
   %z0 = opt(o,'grid.offset')/20;

   AA = [A(2:3,2:3) [0;0]; C(2:3) 1];
   BB = [B(2:3); 0];

      % LQR Controller

   Q = diag([1 1 1]);  R = 1;  P = 0*eye(3);
   for (i=1:500)
      K = inv(R+BB'*P'*BB) * BB'*P*AA;
      P = AA'*P*AA - AA'*P*BB * K + Q;
   end
   K = [0 K];

      % overwrite K with 'pretty' values for mini model

   if (opt(o,{'simu.mini',0}) == 3)
      K = [0 1.2 -0.5 -0.2];
      x0 = 20; h0 = 10; z0 = 4; f0 = 0;
   end

   X0 = [x0; h0; q0; f0];
   x = [x0 h0 q0]';
   f = f0;

   kmax = Kmax(o);
   o = log(o,'k,x,y,u,f'),
   for (k=0:kmax)
      y = C*x;
      u = -K*[x;f];

      o = log(o,k,x,y,u,f);

      f = f + C*x;
      x = A*x + B*u;
   end

   [t,x,y,u,f] = log(o);
   subplot(311);
   plot(t,u*0,'k', t,u,'b', t,u,'bo');
   title('Control Signal');
   ylabel('u');

   subplot(312);
   plot(t,u*0,'k', t,f,'g', t,f,'go');
   title('Auxillary Signal');
   ylabel('f');

   subplot(313);
   plot(t,y,'r',  t,y,'ro');
   title('Objective Signal');
   ylabel('y');

      % print data stream


   fprintf('A:\n');
   disp(A);
   fprintf('B'':\n');
   disp(B');
   fprintf('C:\n');
   disp(C);
   fprintf('X0'' = [x0 h0 z0 f0]:\n');
   disp(X0');
   fprintf('K = \n');
   disp(K);

   fprintf('        t        u        y |        x        h         z       f\n');
   for (k=1:kmax+1)
      tk = Rd(o,t(k));    uk = Rd(o,u(k));  yk = Rd(o,y(k));
      xk = Rd(o,x(1,k));  hk = Rd(o,x(2,k));
      zk = Rd(o,x(3,k));  fk = Rd(o,f(k));
      fprintf(' %8g %8.2g %8.1g | %8g %8g %8g %8g\n',...
                 tk, uk,  yk,  xk, hk, zk, fk);
   end

   function y = Rd(o,x)
      y = o.rd(x,2);
   end
end


%==========================================================================
% Kalman Filter
%==========================================================================

function p = KalmanSetup(o)            % Setup Kalman Parameters       
   p.pimp = opt(o,{'kalman.pimp',1});  % Kalman pimp factor
   p.k = 0;                            % init run index

   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   p.sigw = opt(o,{'grid.vario',10e-6}) / 3;
   p.sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;

   p.A = [1 0; 1 1];                   % system matrix
   p.C2 = 1/Dt;

      % for model state 1 (period) we make a compromise between
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms

   p.x1 = 0.018;                       % model state(1)
   p.x2 = 0;                           % model state(2)

      % setup Kalman parameter matrices
      % P = 1e6*I
      % Q = [sigw^2 0; 0 0]
      % R = sigv^2

   p.P11 = 1e6; p.P12 = 0;
   p.P21 = 0; p.P22 = 1e6;

   p.Q11 = p.sigw^2;
   p.R = p.sigv^2;
end
function p = KalmanLoop(p,y)           % Loop Kalman Filter            
   k = p.k+1;                          % next index
   p.k = k;                            % update run index

   p.M11 = p.P11 + p.Q11;
   p.M12 = p.P11 + p.P12;
   p.M21 = p.P11 + p.P21;
   p.M22 = p.M12 + p.P21 + p.P22;

      % Ricati equation part 2: K = M*Cm'*inv(Cm*M*Cm'+R)

   q = p.C2 / (p.C2 * p.M22 * p.C2 + p.R);
   p.K1 = p.M12 * q;
   p.K2 = p.M22 * q;

      % Ricati equation part 3: P = (I-K*Cm)*M

   K1C2 = p.K1 * p.C2;
   K2C2 = p.K2 * p.C2;
   p.P11 = p.M11 - K1C2 * p.M12;
   p.P12 = p.M12 - K1C2 * p.M22;
   p.P21 = p.M21 * (1-K2C2);
   p.P22 = p.M22 * (1-K2C2);

      % part 1 of observer transition
      %    hk = Am*xm;           % half transition
      %    ek = yt(k) - Cm*hk;   % error signal

   h1 = p.x1;
   h2 = p.x1 + p.x2;
   ek = y - p.C2 * h2;

      % dirty hack to improve

   if (k > 20)
      ek = ek * p.pimp;
   end

      % part 2 of observer transition
      %    xm = hk + K*ek              % full transition
      %    ym(k) = Cm*xm               % model counter reading

   p.x1 = h1 + p.K1 * ek;
   p.x2 = h2 + p.K2 * ek;
   p.ym(k) = p.C2 * p.x2;              % model counter reading

   p.yd(k) = p.ym(k) - y;              % output deviation
   p.xm1(k) = p.x1;
end
function o = KalmanPlot(o,sy,km)       % Plot Calman Simulation        
   kmax = Kmax(o);
   o = var(o,'kk',0:kmax-1);

   o = var(o,'vt',sy.v);     o = var(o,'yt',sy.y);
   o = var(o,'zt',sy.z);     o = var(o,'ym',km.ym);  o = var(o,'yd',km.yd);
   o = var(o,'xt1',sy.xt1);  o = var(o,'xm1',km.xm1);
   Plot(o);
end

function o = KalInit(o)                % Init Kalman Filter            
   pimp = opt(o,{'kalman.pimp',1});    % Kalman pimp factor
   k = 0;                              % init run index

   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = TimerParameter(o);

   sigw = opt(o,{'grid.vario',10e-6}) / 3;
   sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;

   A = [1 0; 1 1];                     % system matrix
   C2 = 1/Dt;

      % for model state 1 (period) we make a compromise between
      % 50 Hz period (20ms) and 60 Hz period (16.7ms) => 18 ms

   x1 = 0.018;                       % model state(1)
   x2 = 0;                           % model state(2)

      % setup Kalman parameter matrices
      % P = 1e6*I
      % Q = [sigw^2 0; 0 0]
      % R = sigv^2

   P11 = 1e6; P12 = 0;
   P21 = 0;   P22 = 1e6;

   Q11 = sigw^2;
   R   = sigv^2;

      % variable storage

   o = var(o,'k',k, 'pimp',pimp, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'C2',C2, 'x1',x1, 'x2',x2);
   o = var(o,'P11',P11, 'P12',P12, 'P21',P21, 'P22',P22, 'Q11',Q11, 'R',R);

      % log init

   o = log(o,'k,x1,x2,ym,yd');
end
function o = KalLoop(o,y)              % Loop Kalman Filter            
   [k,pimp,sigw,sigv] = var(o,'k','pimp','sigw','sigv');
   [A,C2,x1,x2] = var(o,'A','C2','x1','x2');
   [P11,P12,P21,P22,Q11,R] = var(o,'P11','P12','P21','P22','Q11','R');

   k = k+1;

      % loop

   M11 = P11 + Q11;
   M12 = P11 + P12;
   M21 = P11 + P21;
   M22 = M12 + P21 + P22;

      % Ricati equation part 2: K = M*Cm'*inv(Cm*M*Cm'+R)

   q = C2 / (C2 * M22 * C2 + R);
   K1 = M12 * q;
   K2 = M22 * q;

      % Ricati equation part 3: P = (I-K*Cm)*M

   K1C2 = K1 * C2;
   K2C2 = K2 * C2;
   P11 = M11 - K1C2 * M12;
   P12 = M12 - K1C2 * M22;
   P21 = M21 * (1-K2C2);
   P22 = M22 * (1-K2C2);

      % part 1 of observer transition
      %    hk = Am*xm;           % half transition
      %    ek = yt(k) - Cm*hk;   % error signal

   h1 = x1;
   h2 = x1 + x2;
   ek = y - C2 * h2;

      % dirty hack to improve

   if (k > 20)
      ek = ek * pimp;
   end

      % part 2 of observer transition
      %    xm = hk + K*ek              % full transition
      %    ym(k) = Cm*xm               % model counter reading

   x1 = h1 + K1 * ek;
   x2 = h2 + K2 * ek;
   ym = C2 * x2;                       % model counter reading

   yd = ym - y;                        % output deviation
   xm1 = x1;

      % variable storage

   o = var(o,'k',k, 'pimp',pimp, 'sigw',sigw, 'sigv',sigv);
   o = var(o,'A',A, 'C2',C2, 'x1',x1, 'x2',x2, 'y',y);
   o = var(o,'P11',P11, 'P12',P12, 'P21',P21, 'P22',P22, 'Q11',Q11, 'R',R);

      % logging

   o = log(o,k,x1,x2,ym,yd);
end

%==========================================================================
% Kalman Simulation
%==========================================================================

function o = Kalman(o)                 % Order n Kalman Filter         
   o = Scenario(o);                    % setup scenario
   order = arg(o,1);                   % get order                    

   oc = controller(o);                 % passive controller
   os = system(o);
   ok = kalman(type(o,order));         % init Order n Kalman Filter

   for (k=1:Kmax(o))
      os = system(os,oc);              % run system (timer) loop
      ok = kalman(ok,os);              % run Kalman filter loop
   end

   plot(type(o,'kalman'),os,ok);       % plot results
end
function o = McuKalf(o)                % MCU Kalman Filter             
   o = Scenario(o);                    % setup scenario

   oc = controller(o);                 % passive controller
   os = system(o);
   ok = kalman(type(o,'mcukalf'));     % init Kalman Filter

   for (k=1:Kmax(o))
      os = system(os,oc);              % run system (timer) loop
      ok = kalman(ok,os);              % run Kalman filter loop
   end

   plot(type(o,'kalman'),os,ok);       % plot results
end

%==========================================================================
% PWM Model
%==========================================================================

function [p,z0] = PwmSetup(o)          % Setup PWM Module              
   tmin = o.either(var(o,'tmin'),0);
   tmax = o.either(var(o,'tmax'),opt(o,'simu.periods')*20e-3);

   [p.period,p.delta,toff] = Pwm(o);
   t0 = ZeroCross(o,tmin,tmax);

   [T0,Tgrid] = GridParameter(o);

   p.b = round(toff/p.delta);
   while (t0(1) <= toff)
      t0(1) = [];
   end
   z0 = round(t0/p.delta);
   kmax = length(t0);
   p.k = 0;                              % init run index

      % initialize state model

   p.h = [p.period];                     % system initial state
   p.A = [1];                            % system dynamic matrix
   p.B = [1];                            % system output matrix
   p.C = [1];                            % system output matrix

   p.p = p.C * p.h;
   p.z = 0;
   p.y = 0;

   p.tk = -10;
   p.wk = 0;
   p.xk = Tgrid/p.delta;
   p.hk = p.h;
   p.zk = (Tgrid/2 + T0 - toff)/p.delta;
   p.yk = p.zk;
   p.bk = p.b;

   p.yk = rem(p.yk+p.hk,p.hk);
   p.ok = p.yk/p.period;
   p.p = p.hk;

   p.x = [p.xk; p.hk; p.zk; p.tk];
   p.var.x = p.x;
end
function p = PwmLoop(o,p,tk,uk)        % Loop PWM module               
   k = p.k+1;                          % next index
   p.k = k;                            % update run index

   p.h = p.A * p.h + p.B * uk;

   while ((p.b+p.p(end)) < tk)
      p.b = p.b + p.p(end);            % update start count of PWM ramp
      p.p(end+1) = p.p(end);
   end

   p.b = p.b + 2*p.p(end);
   p.p(end+1) = p.C * p.h;

   p.z = Pwm(o,tk*p.delta,p.p);
   %if (p.y < -p.period/2)
   %   p.y = p.y + p.period;
   %elseif (p.y > p.period/2)
   %   p.y = p.y - p.period;
   %end
   p.xk = tk-p.tk;                     % xk is the period
   p.tk = tk;
   p.hk = p.h;
   p.bk = p.b;
   p.zk = p.z;
   p.yk = p.zk + p.wk;

   p.ok = rem(p.yk+p.hk,p.hk) / p.period;   % ok: output(k)

   p.p = [p.p p.hk p.hk];
   p.tz(p.k) = tk*p.delta;
   p.o(p.k) = p.ok;

   p.var.x = [p.xk; p.hk; p.zk; p.tk];
   p.x(:,k+1) = [p.xk; p.hk; p.zk; p.tk];
end

%==========================================================================
% Controlers
%==========================================================================

function p = LqrSetup(o)               % LQR Controller Setup          
%
%   [ x(k+1) ]   [ 1   0   0 ]   [ x(k) ]   [ 0 ]          [ 1 ]
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ h(k+1) ] = [ 0   1   0 ] * [ h(k) ] + [ 1 ] * u(k) + [ 0 ] * w(k)
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ z(k+1) ]   [ 1  -2   1 ]   [ z(k) ]   [-1 ]          [ 0 ]
%
%       y(k)   = [ 0   0   1 ] *   x(k) + v(k)
%
   p.period = opt(o,'tim2.period')+1;
   reference = opt(o,'pwm.setpoint')*p.period;

   A = [
          1   0   0
          0   1   0
          1  -2   1
       ];
   B = [  0   1  -1 ]';
   C = [  0   0   1 ];

   p.A = [A [0;0;0]; C 1];
   p.B = [B;0];
   p.C = [C 0];

   AA = p.A(2:4,2:4);
   BB = p.B(2:4);

      % LQR Controller

   Q = diag([1 5 10]);  R = 1;  P = 0*eye(3);
   KK = Dlqr(AA,BB,Q,R);               % linear quadratic regulator design
   p.K = [0 KK];

      % overwrite K with 'pretty' values for mini model

   if (opt(o,{'simu.mini',0}) == 1)
      p.K = [0 1.2 -0.5 -0.2];
   end

   p.rk = reference;
   p.gk = p.rk / ([0 1 0]*inv(eye(3)-AA+BB*KK)*[0 0 1]');

      % continue with general stuff

   p.k = 0;                            % init run index
   p.tk = 0;
   p.ek = nan;
   p.fk = 0;

   p.t = [];                           % init log variable
   p.r = [];                           % init log variable
   p.y = [];                           % init log variable
   p.e = [];                           % init log variable
   p.f = [];                           % init log variable
   p.q = [];                           % init log variable
   p.u = [];                           % init log variable
   p.o = [];                           % init log variable
end
function p = LqrLoop(o,p,osys)         % LQR Controller loop           
%
%  Note:
%
%     Xk = [x(k); f(k)] = [x(k) h(k) z(k) f(k)]
%
%  Controller Implementatiom
%
%     x' = A*x + B*u
%     u = -K*x
%
%     x' = A*x - BK*x = (A-BK)*x
%
%  Now consider a new equilibrium state xe to which we want to drive
%  the system. How do we have to do to achieve xe steady state?
%
%  Extend the system:
%
%     x' = A*x + B*u + g
%     u = -K*x
%
%     x' = A*x - BK*x + g = (A-BK)*x + g
%
%  Note that for steady state we have
%
%     xe = (A-BK)*xe + g
%     (I-A+BK)*xe = g
%     xe = (I-A+BK)\g
%
%  In particular we are not interested to achieve a given (entire) xe
%  state but only in the second component xe(2) := rk. Thus we have
%
%     rk = e2'*xe = e2'*inv(I-A+BK)*g
%
%  If we decide g := e3 = gk*[0 0 1]' then
%
%     rk = e2'*xe = e2'*inv(I-A+BK)*(gk*e3)
%     rk = gk * e2'*inv(I-A+BK)*e3
%
%  To calculate gk for given rk we get
%
%     gk = rk / (e2'*inv(I-A+BK)*e3)
%
%  while the controller implementation has to be:
%
%     u = -K*x = -K*[hk zk fk]'
%     fk = fk + zk + gk = fk + C*xk + gk
%
   k = p.k+1;                          % next index
   p.k = k;                            % update run index

   p.tk = k * 0.02;
   xk = var(osys,'x');
   p.yk = p.C*xk;                      % calc control signal value
   p.ok = p.yk / p.period;             % relative value

   p.k0 = -7000;

   p.ek = p.rk-p.yk;
   p.qk = 0;

   p.Xk = [xk(1:3); p.fk];
   p.uk = p.K * ([0; 0; p.rk; 0] - p.Xk);
   %p.uk = Sat(p.uk,500);

      % dynamic controller transition

   p.fk = p.fk + p.C*xk + p.gk;

      % data logging

   p.t(k) = p.tk;
   p.r(k) = p.rk;
   p.y(k) = p.yk;
   p.e(k) = p.ek;
   p.f(k) = p.ek;
   p.q(k) = p.qk;
   p.u(k) = p.uk;
   p.o(k) = p.ok;
end

function p = OpenSetup(o)              % Open Loop Control Setup       
   p.k = 0;                            % init run index

      % signal init

   p.tk = 0;
   p.rk = 0;
   p.yk = 0;
   p.ek = 0;
   p.qk = 0;
   p.uk = 0;

      % data logging

   p.t = [];                           % init log variable
   p.r = [];                           % init log variable
   p.y = [];                           % init log variable
   p.e = [];                           % init log variable
   p.q = [];                           % init log variable
   p.u = [-2, +4, -3, +1, 0];          % sample control signal
end
function p = OpenLoop(o,p,y)           % PD Controller loop            
   k = p.k+1;                          % next index
   p.k = k;                            % update run index

   p.tk = p.k * 0.02;
   p.uk = p.u(min(length(p.u),p.k));   % control signal
   p.ok = p.yk/0.02;

      % data logging

   p.t(k) = p.tk;
   p.r(k) = p.rk;
   p.y(k) = p.yk;
   p.e(k) = p.ek;
   p.q(k) = p.qk;
   p.u(k) = p.uk;
   p.o(k) = p.ok;
end

function p = ConSetup(o)               % General Controller Setup      
   mini = opt(o,{'simu.mini',0});
   switch mini
      case 0
         p = LqrSetup(o);
      case 1
         p = OpenSetup(o);
   end
end
function p = ConLoop(o,p,sys)          % General Controller Loop       
   mini = opt(o,{'simu.mini',0});
   switch mini
      case 0
         p = LqrLoop(o,p,sys);
      case 1
         p = OpenLoop(o,p,sys);
   end
end

%==========================================================================
% PWM Control
%==========================================================================

function o = GridBasics(o)             % Grid Basics Study             
   o = Mini(o);                        % eventual mini study setup
   Random(o);                          % hande random seed
   Tus = 1e-6;                         % us time step
   periods = opt(o,'simu.periods');  % number of periods

      % general calculations

   tmin = 0;
   tmax = periods*20e-3;

      % grid voltage

   t = tmin:Tus:tmax;                  % time vector
   ug = Grid(o,t);

%  o = Timer(o,tmin,tmax);

      % plot grid voltage

   subplot(311);
   plot(t*1000,ug,'b');
   title('Grid Voltage');
   set(gca,'xlim',[tmin tmax]*1000);

      % highlight zero crosses

   [t0,t0j,t0l] = ZeroCross(o,tmin,tmax);

   subplot(311);
   hold on;
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   plot(xlim,[0 0],'k');

   for (i=1:length(t0))
      plot(t0(i)*[1 1]*1000,ylim,'k:');
      plot(t0j(i)*[1 1]*1000,ylim,'r');
      plot(t0l(i)*[1 1]*1000,ylim,'g');
   end

      % plot TIM6 counter

   subplot(312);
   oo = with(o,'tim6');
   t6 = Timing(oo,tmin,tmax);
   q6 = Counter(oo,t6);
   Step(t6*1000,q6,'mk');
   title('Timer 6');
   set(gca,'xlim',[tmin tmax]*1000);

      % add zero crossing to TIM6 plot

   subplot(312);
   hold on;
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   for (i=1:length(t0))
      plot(t0(i)*[1 1]*1000,ylim,'k:');
      plot(t0j(i)*[1 1]*1000,ylim,'r');
   end
   q0j = Counter(with(o,'tim6'),t0j);
   plot(t0j*1000,q0j,'ro');

      % some output vars

   o = var(o,'jitter',t0j-t0);
   o = var(o,'tmin',tmin);
   o = var(o,'tmax',tmax);
end
function o = PwmBasics(o)              % PWM Basics Study              
   o = GridBasics(o);

   subplot(313);
   o = with(o,'tim2');

   t = Timing(o);
   tz = ZeroCross(o);

   p = [1.0, 0.8, 0.8, 1.2, 1.2, 0.9 0.9 1.1 1.1 1.0]*Pwm(o);
   q = Pwm(o,t,p);
   qz = Pwm(o,tz,p);
   PwmPlot(o,t,q,tz,qz);

      % some output vars

%  o = var(o,'jitter',t0j-t0);
end
function o = PwmSystem(o)              % PWM System Study              
   o = GridBasics(o);

   kmax = opt(o,'simu.periods');
   u = [-0.2, +0.4, -0.3, +0.2, -0.1 zeros(1,kmax-5)]*Pwm(o);

   os = system(o);
   oc = type(o,'controller');          % controller dummy

   for (k=1:Kmax(o))
      oc = var(oc,'u',u(k));           % set new u(k)
      os = system(os,oc);              % run PWM loop
   end

   [q,Z,y] = data(os,'q','Z','y');     % recall log data

   subplot(313);
   t = Timing(with(o,'tim2'));
   q = Pwm(os,t,var(os,'pwm'));
   PwmPlot(o,t,q,Z,y);
end
function o = PwmControl(o)             % PWM Feed Forward Control      
   o = GridBasics(o);
   subplot(313);
   o = with(o,'tim2');

   t = Timing(o);
   [tz,tj,tl] = ZeroCross(o);

      % control loop

   subplot(313);
   plot(t*1000,0*t,'k');
   hold on;

   [~,delta,toff] = Pwm(o);
   tpwm = toff;

      % remove all zerocross timestamps < tpwm

   while (tz(1) <= tpwm)
      tz(1) = [];  tj(1) = [];  tl(1) = [];
   end

      % ready to start

   z = 2*[0.8 1.2 0.9 1.1 1.0]*Pwm(o);        % PWM double period

   Tk = 2*Pwm(o);
   p = [round(Tk/2)];

   kmax = length(tz);
   bk = tpwm/delta;

   for (k=1:kmax)
      tk = tz(k);
      hk = round(Tk/2);

      period = round(Tk/2)*delta;

      while (tpwm+period < tk)
         tpwm = tpwm + period;
         bk = tpwm/delta;
         p(end+1) = hk;
      end

         % calculate new PWM period Tk

      Tk = z(min(k,length(z)));
      hk = round(Tk/2);

      tpwm = tpwm + period;
      bk = (tpwm+period)/delta;

      period = hk*delta;
      p(end+1) = hk;

         % plot

      idx = find(t < toff+sum(p)*delta);
      tidx = t(idx);
      q = Pwm(o,tidx,p);
      hdlpwm = Step(tidx*1000,q,'rk');
      if (opt(o,{'simu.mini',0}) == 1)
         set(gca,'Xtick',0:2:100);
         set(gca,'Ytick',0:12, 'Ylim',[0 12]);
         grid on
      end
   end

      % add zero crossing to PWM plot

   subplot(313);

   qz = Pwm(o,tz,p);
   PwmPlot(o,t,q, tz,qz);

   title('PWM (Timer 2)');
end

function o = PwmFeedForward(o)         % PWM Feed Forward Control      
   o = PwmControl(o);

   [pwm,z] = PwmSetup(o);

   [~,delta] = Pwm(o);
   t = z*delta;                      % time stamps of zero crosses

   u = [-2 +4 -3 +2 -1 0]*Pwm(o)/10;

   for (k=1:length(z))
      uk = u(min(k,length(u)));
      pwm = PwmLoop(o,pwm,z(k),uk);
      y(k) = pwm.y;
      set(plot(z(k)*pwm.delta*[1 1]*1000,[0 y(k)],'b'),'LineWidth',3);
   end

      % plotting

   z0 = Pwm(o,t,pwm.p);
   hdl = plot(t*1000,z0,'c');
   set(hdl,'LineWidth',2)
   hdl = plot(t*1000,z0,'k.');
end

%==========================================================================
% PLL Control
%==========================================================================

function [oc,os,ok] = Mission(oc,os,ok)% Special Mission Settings      
   special = opt(os,{'simu.mini',0});
   switch special
      case 4
         vars = var(os);
         vars.x(1) = 20000;
         vars.x(2) = 0;
         vars.x(3) = 10000;
         vars.x(4) = 4000;
         os = var(os,vars);

         vars = var(ok);
         vars.x(1) = 18000;
         vars.x(2) = 0;
         vars.x(3) = 10000;
         vars.x(4) = 0;
         
         vars.x1 = vars.x(1:2);
         vars.x2 = vars.x(3:4);
         
         %vars.P1 = diag([1e5 1e7]);
         %vars.P2 = diag([1e3 1e6]);

         ok = var(ok,vars);
   end
end
function SignalTrace(oc,os,ok)         % Trace Signal Values           
%   fprintf('k =%3g, u = %5.1f, y = %5.1f |  g = %5.1f, h = %5.1f, q = %5.1f, f = %5.1f\n',...
%               k, sys.u, sys.y,  sys.g, sys.h, sys.q, sys.f);
   if (opt(oc,{'simu.trace',0}) == 0)
      return
   end
   
   d = data(os);
   i = length(d.k);
   
   k = d.k(i)-1;  u = floor(d.u(i));  y = floor(d.y(i));
   g = floor(d.x(1,i));  h = floor(d.x(3,i));  q = floor(d.x(4,i)); 
   
   d = data(oc);
   f = floor(d.f(i));
   
   d = data(os);
   w = d.w(i);  v = d.v(i);
   
   sum = k+u+y+g+h+q+f+w+v;
   
   scenario = opt(oc,{'mcu.scenario',0});
   switch scenario
      case 00010                       % small values - noise off
         table = [280 599 1057 1283 1243 1056];
      case 00011                       % small values - noise on
         table = [356 627 1005 1280 1335 1148];
      case 00030                           % large values - noise off
         table = [28000 59801 105542 128165 124162 105434];
      case 00031                           % large values - noise on
         table = [28076 59829 105490 128162 124252 105525];
      case 10010                       % small values - noise off
         table = [-3901,11869,19106,11159,775,-5642];
      case 110011                       % small values - noise off
         table = [-3798,12183,18464,10539,1878,-2548];
      case 114230                       % small values - noise off
         table = [38585,23686,68289,90389,82021,76242];
      case 114231                       % small values - noise off
         table = [36076,40063,50000,67149,79901,84591,84308,77888,73824,73959];
    otherwise
         error('bad scenario');
   end
   
   if (k+1 > length(table))
      nonce = 99999;
   else
      nonce = sum - table(k+1);
   end
   ch = oc.iif(nonce,'*** ','    ');
   
   fprintf(['%sk:%3g u:%6g, y:%6g |  w:%3g v:%3g | ',...
            'g:%6g, h:%6g, q:%6g, f:%6g\n'],ch,k,u,y,w,v,g,h,q,f);

   xf = data(ok,'x');
   if ~isempty(xf)
      gf = floor(xf(1,i));
      tf = floor(xf(2,i));
      hf = floor(xf(3,i));
      qf = floor(xf(4,i));
      fprintf(['                             |              | ',...
            'g^%6g, h^%6g, q^%6g, t^%6g\n'],gf,hf,qf,tf);
   end
end

function o = DirectPll(o)              % PWM Feed Forward Control      
   [pwm,x] = PwmSetup(o);
   [con] = ConSetup(o);                % controller setup

   [~,delta] = Pwm(o);
   t = x*delta;                        % time stamps of zero crosses

   kmax = length(x);
   for (k=1:kmax)
      osys = var(o,'x',pwm.var.x);
      con = ConLoop(o,con,osys);       % run cntroller loop
      pwm = PwmLoop(o,pwm,x(k),con.uk);% run PWM loop
   end

   ConPlot(o,con,pwm);                 % plot controller signals
end
function o = SystemPll(o)              % PWM Model Based Control       
   o = Mini(o);                        % eventual mini study setup

   os = system(o);                     % system setup
   oc = type(o,'controller');          % controller dummy

   %[~,delta] = Pwm(o);

   A = var(os).A(2:3,2:3);
   B = var(os).B(2:3);

   K = place(A,B,0.7*[1 1]);

   oc = log(oc,'k,y,r,e,u');
   for (k=1:Kmax(o))
      x = var(os).x(2:3);

      y = var(os).y;
      r = 0;
      e = r-y;
      u = -K*x;

      oc = var(oc,'u',u);              % store in controller
      os = system(os,oc);              % run system loop

      oc = log(oc,k,y,r,e,u);
   end

   plot(type(o,'con'),oc,os);          % plot controller signals
end
function o = LqrPll(o)                 % LQR based PWM Control         
   o = Scenario(o);                    % eventual mini study setup

   oc = controller(o);                 % controller setup
   os = system(o);                     % system setup

   for (k=1:Kmax(o)+1)
      oc = controller(oc,os);          % run controller loop
      os = system(os,oc);              % run system loop
   end

   plot(type(o,'con'),oc,os);
end
function o = KalmanPll(o)              % PWM Feed Forward Control      
   o = Scenario(o);                    % setup scenario
   kind = arg(o,1);                    % Kalman filter kind

   oc = controller(o);                 % passive controller
   os = system(o);
   ok = kalman(type(o,kind));          % init Full (Matrix) Kalman Filter

   %[oc,os,ok] = Mission(oc,os,ok);    % Special Mission Settings
   
   for (k=1:Kmax(o))
      os = system(os,[]);              % system measurement (only)
      ok = kalman(ok,os);              % run Kalman filter loop
      oc = controller(oc,ok);          % run controller loop
      os = system(os,oc);              % run system (timer) loop
      SignalTrace(oc,os,ok);           % tracing if active
   end

   plot(type(o,'pll'),os,ok,oc);       % plot results
end
