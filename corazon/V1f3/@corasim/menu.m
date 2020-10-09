function oo = menu(o,varargin)         % CORASIM Menu Building Blocks  
   [gamma,o] = manage(o,varargin,@Error,@Filter,@Scale,@Bode,@Rloc,...
                      @Nyquist,@Simu,@NyquistMapping);
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
         Choice(ooo,[1e-4 1e-3 1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'bode.omega.high');
         Choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Magnitude',{},'bode.magnitude.low');
         Choice(ooo,[-100:10:-20],{});
   ooo = mitem(oo,'Upper Magnitude',{},'bode.magnitude.high');
         Choice(ooo,[20:10:100],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Phase',{},'bode.phase.low');
         Choice(ooo,[-270:45:-90],{});
   ooo = mitem(oo,'Upper Phase',{},'bode.phase.high');
         Choice(ooo,[-90:45:135],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Magnitude Plot',{},'bode.magnitude.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Phase Plot',{},'bode.phase.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Points',{},'bode.omega.points');
   choice(ooo,[100,500,1000,5000,10000],{});

   function Choice(o,values,cblist)    % Choice Menu List With Auto    
      list = {{'Auto',[]},{}};         % list head
      
         % sort values in reverse order
         
      values = sort(values);
      values = values(length(values):-1:1);
      
         % add values to choice items
         
      for (i=1:length(values))
         list{end+1} = {sprintf('%g',values(i)),values(i)};
      end
      
         % add choice menu items
         
      choice(o,list,cblist);
   end
end
function oo = Nyquist(o)               % Nyquist Settings Menu         
   setting(o,{'nyq.omega.low'},1e-1);
   setting(o,{'nyq.omega.high'},1e5);
   setting(o,{'nyq.magnitude.low'},-60);
   setting(o,{'nyq.magnitude.high'},60);
   setting(o,{'nyq.magnitude.delta'},20);
   setting(o,{'nyq.zoom'},2);
   
   setting(o,{'nyq.log'},true);
   setting(o,{'nyq.omega.points'},10000);
   
   
   oo = mitem(o,'Nyquist');
   ooo = mitem(oo,'Lower Frequency',{},'nyq.omega.low');
         Choice(ooo,[1e-4 1e-3 1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'nyq.omega.high');
         Choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8],{});
   ooo = mitem(oo,'Points',{},'nyq.omega.points');
   choice(ooo,[100,500,1000,5000,10000,20000,50000],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Magnitude [dB]',{},'nyq.magnitude.low');
         Choice(ooo,[-400 -300 -260 -220 -180 -140 -100:10:-20],{});
   ooo = mitem(oo,'Upper Magnitude [dB]',{},'nyq.magnitude.high');
         Choice(ooo,[20:10:100],{});
   ooo = mitem(oo,'Delta Magnitude [dB]',{},'nyq.magnitude.delta');
         choice(ooo,[10 20 40 60 80 100],{});
   ooo = mitem(oo,'Zoom',{},'nyq.zoom');         
   choice(ooo,[0.1 0.2 0.5 1 1.2 1.5 2 5 10 20 50 100],{});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'More');
   oooo = mitem(ooo,'Scaling',{},'nyq.log');
   choice(oooo,{{'Linear',0},{'Logarithmic',1}},{});
   oooo = mitem(ooo,'Mapping',{@menu,'NyquistMapping'});

   function Choice(o,values,cblist)    % Choice Menu List With Auto    
      list = {{'Auto',[]},{}};         % list head
      
         % sort values in reverse order
         
      values = sort(values);
      values = values(length(values):-1:1);
      
         % add values to choice items
         
      for (i=1:length(values))
         list{end+1} = {sprintf('%g',values(i)),values(i)};
      end
      
         % add choice menu items
         
      choice(o,list,cblist);
   end
end
function oo = Rloc(o)                  % Root Locus Settings Menu      
   setting(o,{'rloc.xlim'},[]);
   setting(o,{'rloc.ylim'},[]);
   setting(o,{'rloc.zoom'},2);
   setting(o,{'rloc.delta'},0.01);
   
   
   oo = mitem(o,'Root Locus');
   ooo = mitem(oo,'Real Part',{},'rloc.xlim');
   choice(ooo,{{'Auto',[]},{},{'[-1 0.5]',[-1 0.5]},...
               {'[-2 1]',[-2 1]},{'[-5 2]',[-5 2]},...
               {'[-10 2]',[-10 2]},{'[-100 20]',[-100 20]},...
               {'[-10e2 2e2]',[-10e2 2e2]},{'[-10e3 2e3]',[-10e3 2e3]},...
               {'[-10e4 2e4]',[-10e4 2e4]},{'[-10e5 2e5]',[-10e5 2e5]}});
   ooo = mitem(oo,'Imaginary Part',{},'rloc.ylim');
   choice(ooo,{{'Auto',[]},{},{'[-1 +1]',[-1 1]},...
               {'[-2 +2]',[-2 +2]},{'[-5 +5]',[-5 5]},...
               {'[-10 +10]',[-10 10]},{'[-100 +100]',[-100 100]},...
               {'[-10e2 +10e2]',[-10e2 10e2]},{'[-10e3 +10e3]',[-10e3 10e3]},...
               {'[-10e4 +10e4]',[-10e4 10e4]},{'[-10e5 +10e5]',[-10e5 10e5]}});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Zoom',{},'rloc.zoom');
   choice(ooo,[0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100],{});
   ooo = mitem(oo,'Delta',{},'rloc.delta');
   choice(ooo,[0.05 0.02 0.01 0.005 0.002 0.001],{});
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

%==========================================================================
% Helper
%==========================================================================

function o = NyquistMapping(o)         % Plot Nyquist Mapping          
   refresh(o,o);                       % come back here for refresh
   
   o = with(o,'nyq');
   [olow,ohigh,points,mag] = opt(o,'olow,ohigh,points,magnitude');
   mag = [mag.low,mag.high];           % change representation

   if (mag(1) >= 0 || mag(2) <= 0)
      error('bad magnitude boundaries');
   end

      % calculate order 2 mapping polynomial

   x = [mag(1),0.75*mag(1) 0, mag(2)];
   y = [0 0.1 1 2];
   map = polyfit(x,y,3);

      % plot mapping

   cls(o);
   m = mag(1):0.1:mag(2);           % magnitude range
   plot(o,m,polyval(map,m),'r1',  x,y,'cp');
   title('magnitude mapping');
   xlabel('magnitude [dB]');
   ylabel('radial distance [1]');

   subplot(o);
end

