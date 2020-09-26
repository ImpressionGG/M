function oo = menu(o,varargin)         % CORASIM Menu Building Blocks  
   [gamma,o] = manage(o,varargin,@Error,@Filter,@Scale,@Bode,...
                      @Simu);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Error handling
%==========================================================================

function o = Error(o)                  % Error Handling                
   error('mode argument (arg2) missing');
end

%==========================================================================
% View Menu
%==========================================================================

function oo = Filter(o)                % Add Filter Menu Items         
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mitem(o,'Filter');
   ooo = mitem(oo,'Mode','','filter.mode');
   choice(ooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Type',{},'filter.type');
   choice(ooo,{{'Order 2 Low Pass','LowPass2'},{'Order 2 High Pass','HighPass2'},...
               {'Order 4 Low Pass','LowPass4'},{'Order 4 High Pass','HighPass4'}},{});
   ooo = mitem(oo,'Bandwidth',{},'filter.bandwidth');
   charm(ooo,{});
   ooo = mitem(oo,'Zeta',{},'filter.zeta');
   charm(ooo,{});
   ooo = mitem(oo,'Method',{},'filter.method');
   choice(ooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end
function oo = Scale(o)                 % Add Time Scale Menu Items     
   setting(o,{'scale.xunit'},[]);      % time scaling unit
   setting(o,{'scale.xscale'},[]);     % time scaling factor

   oo = mitem(o,'Scale',{},'scale.xunit');
   choice(oo,{{'Auto',[]},{},{'h','h'},{'min','min'},{'s','s'},...
               {'ms','ms'},{'us','us'}},{@XscaleCb});
   
   function o = XscaleCb(o)
      unit = setting(o,'scale.xunit');
      if isempty(unit)
         setting(o,'scale.xscale',[]);
         return
      end
         
      switch unit
         case 'h'
            setting(o,'scale.xscale',1/3600);
         case 'min'
            setting(o,'scale.xscale',1/60);
         case 's'
            setting(o,'scale.xscale',1);
         case 'ms'
            setting(o,'scale.xscale',1e3);
         case 'us'
            setting(o,'scale.xscale',1e6);
      end
      refresh(o);
   end
end
function oo = Bode(o)                  % Bode Settings Menu            
   setting(o,{'bode.omega.low'},1e-1);
   setting(o,{'bode.omega.high'},1e5);
   setting(o,{'bode.magnitude.low'},-80);
   setting(o,{'bode.magnitude.high'},80);
   setting(o,{'bode.phase.low'},-270);
   setting(o,{'bode.phase.high'},90);
   
   setting(o,{'bode.magnitude.enable'},true);
   setting(o,{'bode.phase.enable'},true);
   setting(o,{'bode.omega.points'},1000);
   
   
   oo = mitem(o,'Bode');
   ooo = mitem(oo,'Lower Frequency',{},'bode.omega.low');
         choice(ooo,[1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'bode.omega.high');
         choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Magnitude',{},'bode.magnitude.low');
         choice(ooo,[-100:10:-20],{});
   ooo = mitem(oo,'Upper Magnitude',{},'bode.magnitude.high');
         choice(ooo,[20:10:100],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Phase',{},'bode.phase.low');
         choice(ooo,[-270:45:-90],{});
   ooo = mitem(oo,'Upper Phase',{},'bode.phase.high');
         choice(ooo,[-90:45:135],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Magnitude Plot',{},'bode.magnitude.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Phase Plot',{},'bode.phase.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Points',{},'bode.omega.points');
   choice(ooo,[100,500,1000,5000,10000],{});
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Simu(o)                  % Simulation Parameter Menu     
%
% SIMU   Add simulation parameter menu items
%
   setting(o,{'simu.tmax'},[]);
   setting(o,{'simu.dt'},[]);
   setting(o,{'simu.plot'},200);       % number of points to plot

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Max Time (tmax)',{},'simu.tmax');
          choice(ooo,{{'Auto',[]},{},{'1 h',3600},{},...
                      {'30 min',30*60},{'20 min',20*60},{'10 min',600},...
                      {'5 min',5*60},{'2 min',2*60},{'1 min',1*60},{},...
                      {'30 s',30},{'20 s',20},{'10 s',10},{'5 s',5},...
                      {'2 s',2},{'1 s',1},{},{'500 ms',0.5}},{});
   ooo = mitem(oo,'Time Increment (dt)',{},'simu.dt');
          choice(ooo,[1e-6,2e-6,5e-6, 1e-5,2e-5,5e-5, 1e-4,2e-4,5e-4,...
                      1e-3,2e-3,5e-3, 1e-2,2e-2,5e-2, 1e-2,2e-2,5e-2],{});
   ooo = mitem(oo,'Number of Plot Intervals',{},'simu.plot');
          choice(ooo,{{'50',50},{'100',100},{'200',200},{'500',500},...
                      {'1000',1000},{},{'Maximum',inf}},{});
end
