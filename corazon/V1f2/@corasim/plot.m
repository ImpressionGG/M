function oo = plot(o,varargin)         % CORASIM Plot Method           
%
% PLOT   CORASIM plot method
%
%           plot(o)                    % plot step response (default)
%
%           plot(o,'Step');            % plot step response
%           plot(o,'Bode');            % plot bode diagram
%           plot(o,'Rloc');            % plot root locus diagram
%
%        Options:
%           - simu.tmax                % max simulation time
%           - simu.dt                  % simulation increment
%     
%        See also: CORASIM, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Basket,@Menu,@Callback,...
                       @Overview,@Step,@Bode,@Rloc,@Motion);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu   
   oo = mitem(o,'About',{@plot,'About'});
   oo = mitem(o,'Overview',{@WithCuo,'Overview'});
   oo = mitem(o,'-');
   
   
      % dynamic systems
      
   if type(current(o),{'css','dss','strf','ztrf','modal'})
      oo = mitem(o,'Step Response',{@WithCuo,'Step'});
      oo = mitem(o,'Bode Plot',{@WithCuo,'Bode'});
      oo = mitem(o,'Root Locus',{@WithCuo,'Rloc'});
%     oo = mitem(o,'Impulse Response',{@Basket,'Impulse'});
   end

      % motion objects
      
   if type(current(o),{'motion'})
      oo = mitem(o,'Motion Profile',{@WithCuo,'Motion'});
   end
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
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
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
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
   oo = plot(corazon,o);               % if arg list is for corazon/plot
   if ~isempty(oo)                     % is oo an array of graph handles?
      oo = []; return                  % in such case we are done - bye!
   end
   
   switch type(o)
      case 'css'                       % continuous state space system
         PlotCss(o);
      case 'dss'                       % discrete state space system
         PlotDss(o);
      case 'strf'                      % continuous transfer function
         o = system(o);                % cast strf into css
         PlotCss(o);
      case 'strf'                      % continuous transfer function
         o = system(o);                % cast strf into css
         PlotCss(o);
      case 'modal'                     % modal system
         o = system(o);                % cast ztrf into dsss
         PlotDss(o);
      case 'motion'                    % motion object
         Motion(o);
      otherwise
         error('no idea how to plot this type  of object!');
   end
end
function o = Overview(o)               % Plot Overview                 
   switch o.type
      case 'motion'
         oo = with(o,'simu');
         motion(oo,'Overview');
      otherwise
         Plot(o);
   end
   heading(o);
end
function o = PlotCss(o)                % Plot Contin.  State Space Sys 
   [n,ni,no] = size(cast(o,'corasim'));
   [t,x,y] = var(o,'t,x,y');
   
   u = var(o,{'u',zeros(ni,length(t))});
   [t,x,y,u] = reduce(o,t,x,y,u);      % reduce number of data points
   
   if isempty(t)
      plot(o,'About');
      return
   end
   
      % cast object to prepare for corazon/plot calls

   o = with(corazon(o),'style');       % cast object and unpack style opts

   Plot311(o);                         % plot input
   Plot312(o);                         % plot state
   Plot313(o);                         % plot output
   
   heading(o);
   
   function Plot311(o)                 % Subplot Input                
      subplot(o,311);
      hdl = plot(o,t,u, t,u,'K.');
      set(hdl,'LineWidth',1);
      title(sprintf('Input (%d)',ni));
      xlabel('t');  ylabel('u');
      set(gca,'xlim',[min(t),max(t)]);
      subplot(o);                      % subplot complete
   end
   function Plot312(o)                 % Subplot State                 
      subplot(o,312);
      hdl = plot(o,t,x, t,x,'K.');
      set(hdl,'LineWidth',1);
      title(sprintf('State (%d)',n));
      xlabel('t');  ylabel('x');
      set(gca,'xlim',[min(t),max(t)]);
      subplot(o);                      % subplot complete
   end
   function Plot313(o)                 % Subplot Output                
      subplot(o,313);
      hdl = plot(o,t,y, t,y,'K.');
      set(hdl,'LineWidth',1);
      title(sprintf('Output (%d)',no));
      xlabel('t');  ylabel('y');
      set(gca,'xlim',[min(t),max(t)]);
      subplot(o);                      % subplot complete
   end
end
function o = PlotDss(o)                % Plot Discrete State Space Sys 
   o = with(o,'view');                 % unwrap view options
   
   [n,ni,no] = size(cast(o,'corasim'));
   [~,~,~,~,T] = system(o);
   
   [x,y] = var(o,'x,y');
   if (isempty(x))
      m = size(y,2);
   else
      m = size(x,2);
   end
   
   t = T*(0:m-1);                      % default in case t is not provided
   t = var(o,{'t',t});
   u = var(o,{'u',zeros(ni,m)});
   
   [t,x,y,u] = reduce(o,t,x,y,u);      % reduce number of data points
   
      % cast object to prepare for corazon/plot calls
      
   o = with(corazon(o),'style');       % cast object and unpack style opts
   
   Plot311(o);                         % plot input
   Plot312(o);                         % plot state
   Plot313(o);                         % plot output
   
   heading(o,['Step Response ',get(o,'title')]);
   
   function Plot311(o)                 % Subplot Output                
      subplot(311);
      hdl = plot(o,t,u,'bc');
      set(hdl,'LineWidth',1);
      title(sprintf('Input (%d)',ni));
      xlabel(['t  [',opt(o,{'xunit','1'}),']']);
      ylabel('input u');
      subplot(o);                      % subplot complete
   end
   function Plot312(o)                 % Subplot State                 
      subplot(312);
      hdl = plot(o,t,x,'r');
      set(hdl,'LineWidth',1);
      title(sprintf('State (%d)',n));
      xlabel(['t  [',opt(o,{'xunit','1'}),']']);
      ylabel('state x');
      subplot(o);                      % subplot complete
   end
   function Plot313(o)                 % Subplot Output                
      subplot(313);
      hdl = plot(o,t,y,'g');
      set(hdl,'LineWidth',1);
      title(sprintf('Output (%d)',no));
      xlabel(['t  [',opt(o,{'xunit','1'}),']']);
      ylabel('output y');
      subplot(o);                      % subplot complete
   end
end

%==========================================================================
% Step Plot Functions
%==========================================================================

function o = Step(o)                   % Plot Step Response            
   o = with(o,'simu');                 % unpack simulation options
   
   switch type(o)
      case 'css'                       % continuous state space system
         StepCss(o);
      case 'dss'                       % discrete state space system
         StepDss(o);
      case 'strf'                      % s-transfer function
         o = system(o);                % cast strf to css
         StepCss(o);
      case 'modal'                     % modal system
         o = system(o);                % cast strf to css
         StepCss(o);
      case 'ztrf'                      % z-transfer function
         o = system(o);                % cast ztrf into dss
         StepDss(o);
      otherwise
         o = [];  return
   end
   return
   
   function o = StepCss(o)             % Step Plot for Continuous SS   
      tmax = MaxTime(o);               % find best max time
      tmax = opt(o,{'tmax',tmax});
      dt = opt(o,{'dt',tmax/100});
      
      [~,m] = size(o);                 % number of inputs
      I = eye(m);
      t = 0:dt:tmax;
      u = I(:,m)*ones(size(t));

      oo = sim(o,u,[],t);
      plot(oo);
   end
   function o = StepDss(o)             % Step Plot for Discrete SS     
      tmax = MaxTime(o);               % find best max time      
      [~,~,~,~,T] = system(o);
      N = floor(tmax/T);
      
      [~,m] = size(o);                 % number of inputs
      I = eye(m);
      u = I(:,m)*ones(1,N+1);

      oo = sim(o,u);
      plot(oo);
   end
end

%==========================================================================
% Bode Plot
%==========================================================================

function o = Bode(o)                   % Bode Plot                     
   o = with(o,'bode');                 % unwrap bode options
   bode(o);                            % plot bode diagram   
end

%==========================================================================
% Root Locus Plot
%==========================================================================

function o = Rloc(o)                   % Plot Root Locus               
   o = with(o,'rloc');                 % unwrap rloc options
   o = with(o,'style');                % unwrap style options
   rloc(o);                            % plot root locus diagram   
end

%==========================================================================
% Motion Profile
%==========================================================================

function o = Motion(o)                 % Plot Motion Profile           
   if ~type(o,{'motion'})
      plot(o,'About');
      return
   end
 
   [smax,vmax,amax,tj] = data(o,'smax,vmax,amax,tj');
   
   motion(o,smax*1000,1000*vmax,amax*1000,tj); 
   
   heading(o);
end

%==========================================================================
% Helper
%==========================================================================

function tmax = MaxTime(o)             % Find Best Maximum Time        
   if ~type(o,{'css','dss'})
      o = system(o);                   % cast to state space system
   end
   
   
   if type(o,{'dss'})
      [~,~,~,~,Ts] = system(o);
      Tmax = 100*Ts;
   else

      [A,~,~,~,T] = system(o);
      s = eig(A);
      smax = max(abs(s));

      if (smax == 0)
         Tmax = 10;
      else
         Tmax = 10/smax;                  % initial guess for tmax
      end
   end
   
      % we need to find a rounded value for tmax ...
      
   base = 10^floor(log10(Tmax));
   tmax = 10*base;                     % in case we are not successful

      % now find proper interval 

   if (Tmax/base < 1.25)
      tmax = 1*base;
   elseif (Tmax/base < 1.75)
      tmax = 1.5*base;
   else
      for (i=2:9)
         if (Tmax/base < i+0.5)
            tmax = i*base;
            break;
         end
      end
   end
end

 