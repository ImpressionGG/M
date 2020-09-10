function oo = plot(o,varargin)         % CORASIM Plot Method           
%
% PLOT   CORASIM plot method
%
%           plot(o)                    % plot step response (default)
%
%        Options:
%           - simu.tmax                % max simulation time
%           - simu.dt                  % simulation increment
%     
%        See also: CORASIM, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Basket,@Menu,@Callback,@Step);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   oo = mitem(o,'Step Response',{@Basket,'Step'});
%  oo = mitem(o,'Impulse Response',{@Basket,'Impulse'});

   oo = Style(o);                      % add Style menu to Select menu
end
function oo = Style(o)                 % Add Style Menu Items          
   setting(o,{'style.bullets'},1);     % provide bullets default
   setting(o,{'style.linewidth'},1);   % provide linewidth default
   setting(o,{'style.scatter'},'k');   % provide scatter color default

      % filter settings
     
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mseek(o,{'#','Select'});

   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Style');
   oooo = mitem(ooo,'Bullets','','style.bullets');
   check(oooo,{});
   oooo = mitem(ooo,'Line Width','','style.linewidth');
   choice(oooo,[1:3],{});
   oooo = mitem(ooo,'Scatter Color','','style.scatter');
   charm(oooo,{});

   ooo = mitem(oo,'Filter');
   oooo = mitem(ooo,'Mode','','filter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'filter.type');
   choice(oooo,{{'Order 2 Low Pass','LowPass2'},{'Order 2 High Pass','HighPass2'},...
               {'Order 4 Low Pass','LowPass4'},{'Order 4 High Pass','HighPass4'}},{});
   oooo = mitem(ooo,'Bandwidth',{},'filter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'filter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'filter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end

%==========================================================================
% General Callback and Acting on Basket
%==========================================================================

function oo = Callback(o)              % General Callback              
%
% CALLBACK   A general callback with refresh function redefinition, screen
%            clearing, current object pulling and forwarding to executing
%            local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket, screen clearing, 
%         current object pulling and forwarding to executing local func-
%         tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
  
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Default Plot Function
%==========================================================================

function o = Plot(o)                   % Plot Object                   
   switch type(o)
      case 'css'                       % continuous state space system
         PlotCss(o);
      case 'dss'                       % discrete state space system
         PlotDss(o);
      otherwise
         error('no idea how to plot this type  of object!');
   end
end
function o = PlotCss(o)                % Plot Contin.  State Space Sys 
   o = with(corazon(o),'style');       % cast object and unpack style opts

   [n,ni,no] = size(cast(o,'corasim'));
   [t,x,y] = data(o,'t,x,y');
   u = data(o,{'u',zeros(ni,length(t))});
   
   Plot311(o);                         % plot input
   Plot312(o);                         % plot state
   Plot313(o);                         % plot output
   
   heading(o);
   
   function Plot311(o)                 % Subplot Input                
      subplot(311);
      hdl = plot(t,u, t,u,'k.');
      set(hdl,'LineWidth',1);
      title(sprintf('Input (%d)',ni));
      xlabel('t');  ylabel('u');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
   function Plot312(o)                 % Subplot State                 
      subplot(312);
      hdl = plot(t,x, t,x,'k.');
      set(hdl,'LineWidth',1);
      title(sprintf('State (%d)',n));
      xlabel('t');  ylabel('x');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
   function Plot313(o)                 % Subplot Output                
      subplot(313);
      hdl = plot(t,y, t,y,'k.');
      set(hdl,'LineWidth',1);
      title(sprintf('Output (%d)',no));
      xlabel('t');  ylabel('y');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
end
function o = PlotDss(o)                % Plot Discrete State Space Sys 
   o = with(corazon(o),'style');       % cast object and unpack style opts
   
   [n,ni,no] = size(cast(o,'corasim'));
   T = get(o,{'system.T',1});
   
   [x,y] = data(o,'x,y');
   if (isempty(x))
      m = size(y,2);
   else
      m = size(x,2);
   end
   
   t = T*(0:m-1);                      % default in case t is not provided
   t = data(o,{'t',t});
   u = data(o,{'u',zeros(ni,m)});
   
   Plot311(o);                         % plot input
   Plot312(o);                         % plot state
   Plot313(o);                         % plot output
   
   heading(o,['Step Response ',get(o,'title')]);
   
   function Plot311(o)                 % Subplot Output                
      subplot(311);
      hdl = plot(o,t,u,'~');
      set(hdl,'LineWidth',1);
      title(sprintf('Input (%d)',ni));
      xlabel('t');  ylabel('u');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
   function Plot312(o)                 % Subplot State                 
      subplot(312);
      hdl = plot(o,t,x,'~');
      set(hdl,'LineWidth',1);
      title(sprintf('State (%d)',n));
      xlabel('t');  ylabel('x');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
   function Plot313(o)                 % Subplot Output                
      subplot(313);
      hdl = plot(o,t,y,'~');
      set(hdl,'LineWidth',1);
      title(sprintf('Output (%d)',no));
      xlabel('t');  ylabel('y');
      set(gca,'xlim',[min(t),max(t)]);
      grid(o);                         % set grid on/off
   end
end

%==========================================================================
% Step Plot Functions
%==========================================================================

function o = Step(o)                   % Step Plot                     
   o = with(o,'simu');                 % unpack simulation options
   
   switch type(o)
      case 'css'                       % continuous state space system
         StepCss(o);
      case 'dss'                       % discrete state space system
         StepDss(o);
      otherwise
         o = [];  return
   end
   return
   
   function o = StepCss(o)             % Step Plot for Continuous SS   
      tmax = opt(o,{'tmax',5});
      dt = opt(o,{'dt',tmax/100});
      
      [~,m] = size(o);                    % number of inputs
      I = eye(m);
      t = 0:dt:tmax;
      u = I(:,m)*ones(size(t));

      oo = sim(o,u,[],t);
      plot(oo);
   end
   function o = StepDss(o)             % Step Plot for Discrete SS     
      tmax = opt(o,{'tmax',5});
      Ts = get(o,'system.T');
      N = floor(tmax/Ts);
      
      [~,m] = size(o);                 % number of inputs
      I = eye(m);
      u = I(:,m)*ones(1,N);

      oo = sim(o,u);
      plot(oo);
   end
end
