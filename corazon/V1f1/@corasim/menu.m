function oo = menu(o,varargin)         % CORASIM Menu Building Blocks  
   [gamma,o] = manage(o,varargin,@Error,@Filter,@Scale,@Simu);
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
function oo = Scale(o)                 % Add Scale Menu Items          
   setting(o,{'view.xunit'},[]);       % time scaling unit
   setting(o,{'view.xscale'},[]);      % time scaling factor

   oo = mitem(o,'Scale');
   ooo = mitem(oo,'Time Scale',{},'view.xunit');
   choice(ooo,{{'Auto',[]},{},{'h','h'},{'min','min'},{'s','s'},...
               {'ms','ms'},{'us','us'}},{@XscaleCb});
   
   function o = XscaleCb(o)
      unit = setting(o,'view.xunit');
      if isempty(unit)
         setting(o,'view.xscale',[]);
         return
      end
         
      switch unit
         case 'h'
            setting(o,'view.xscale',1/3600);
         case 'min'
            setting(o,'view.xscale',1/60);
         case 's'
            setting(o,'view.xscale',1);
         case 'ms'
            setting(o,'view.xscale',1e3);
         case 'us'
            setting(o,'view.xscale',1e6);
      end
      refresh(o);
   end
   function o = YscaleCb(o)
      unit = setting(o,'view.yunit');
      switch unit
         case 'm'
            setting(o,'view.yscale',1);
         case 'mm'
            setting(o,'view.yscale',1e3);
         case 'um'
            setting(o,'view.yscale',1e6);
      end
      refresh(o);
   end
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
