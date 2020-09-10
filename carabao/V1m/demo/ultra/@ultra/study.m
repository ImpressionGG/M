function oo = study(o,varargin)         % Study Menu                   
%
% SIMU   Manage simulation menu
%
%           study(o,'Setup');          %  Setup STUDY menu
%
%           study(o,'DeadBeatInfo');   %  Info about Dead Beat Positioning
%           study(o,'DeadBeatStudy');  %  Dead Beat noiseless positioning
%
%           study(o,'Signal');         %  Setup STUDY specific Signal menu
%
%        See also: ULTRA1, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Study1,@Study2,@Study3,@Study4,...
       @Signal,@Config,...
       @DeadBeatInfo,@DeadBeatStudy,@AsymptoticInfo,@AsymptoticStudy,...
       @TiFilterInfo,@TiFilterStudy,@GrowingCombInfo,@GrowingCombStudy,...
       @GrowingCombAlternative);
   oo = gamma(oo);
end

%==========================================================================
% Setup Simu Menu
%==========================================================================

function o = Setup(o)                  % Setup Simulation Menu         
   Register(o);
   
   setting(o,{'study.control.repeats'},100);

   oo = mhead(o,'Study');
   ooo = mitem(oo,'Repeated Runs',{},'study.control.repeats');
         choice(ooo,[1 100 1000],{});
   ooo = mitem(oo,'-');
   ooo = MenuDeadBeat(oo);
   ooo = MenuAsymptotic(oo);
   ooo = MenuTiFilter(oo);
   ooo = MenuGrowingComb(oo);
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Config(o)                 % Install a Configuration       
   o = ConfigBasis(o);
   colx = 'r';  coly = 'b';
   
   switch arg(o,1)
      case {'ConfigX'}
         o = subplot(o,'layout',2);    % layout with 2 subplot columns   
         o = config(o,'x', {1,'r',1}); % configure 'x' for 1st subplot
         o = config(o,'yx',{2,'m',1}); % configure 'yx' for 2nd subplot
         o = config(o,'ux',{3,'b',1}); % configure 'ux' for 2nd subplot
         o = config(o,'fx',{4,'g',1}); % configure 'fx' for 2nd subplot
         o = config(o,'wx',{5,'n',1}); % configure 'ux' for 2nd subplot
         o = config(o,'V', {6,'a',2}); % configure 'V'  for 6th subplot
         o = config(o,'a', {6,'k',2}); % configure 'a'  for 6th subplot
      case {'ConfigY'}
         o = subplot(o,'layout',2);    % layout with 2 subplot columns   
         o = config(o,'y', {1,'r',1}); % configure 'x' for 1st subplot
         o = config(o,'yy',{2,'m',1}); % configure 'yx' for 2nd subplot
         o = config(o,'uy',{3,'b',1}); % configure 'ux' for 2nd subplot
         o = config(o,'fy',{4,'g',1}); % configure 'fx' for 2nd subplot
         o = config(o,'wy',{5,'n',1}); % configure 'wy' for 5th subplot
         o = config(o,'V', {6,'a',2}); % configure 'V'  for 6th subplot
         o = config(o,'a', {6,'k',2}); % configure 'a'  for 6th subplot
      case {'Position'}
         o = config(o,'x',{1,'r'});    % configure 'wx' for 1st subplot
         o = config(o,'y',{2,'m'});    % configure 'wy' for 2nd subplot
      case {'Measurement'}
         o = config(o,'yx',{1,'n'});   % configure 'yx' for 1st subplot
         o = config(o,'yy',{2,'a'});   % configure 'yy' for 2nd subplot
      case {'Control'}
         o = config(o,'ux',{1,'b'});   % configure 'wx' for 1st subplot
         o = config(o,'uy',{2,'u'});   % configure 'wy' for 2nd subplot
      case {'Noise'}
         o = config(o,'wx',{1,'g'});   % configure 'wx' for 1st subplot
         o = config(o,'wy',{2,'d'});   % configure 'wy' for 2nd subplot
      case {'Final','final'}
         o = subplot(o,'layout',2);    % layout with 2 subplot columns   
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{3,coly});   % configure 'y' for 2nd subplot
      case {'study'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
         o = config(o,'yx',{0,colx});  % configure 'yx' for 0th subplot
         o = config(o,'yy',{0,coly});  % configure 'yy' for 0th subplot
      otherwise
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
   end
   
   change(o,'bias','absolute');        % change bias mode, update menu
   change(o,'config',o);               % change config, rebuild & refresh
   return
   
   function o = ConfigBasis(o)         % Basis Configuration
      o = config(o,[]);                % set all sublots to zero
      o = opt(o,'config',[]);
      o = config(o,'');                % configure defaults for time
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = category(o,1,[-200 200],[-350 350],'nm'); % setup category 1
      o = category(o,2,[0 0],[-0.5 1.5],'1');     % setup category 2
   end
end
function o = Signal(o)                 % Signal Menu                   
%
% SIGNAL   The Signal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   active(o,{'study'},{mfilename,'Config','Position'}); % 'study' default
   active(o,{'final'},{mfilename,'Config','Final'});    % 'final' default

   switch active(o);                   % depending on active type
      case {'study'}
         oo = mitem(o,'Position',{@Config},'Position');
         oo = mitem(o,'Measurement',{@Config},'Measurement');
         oo = mitem(o,'Filter',{@Config},'Filter');
         oo = mitem(o,'Control',{@Config},'Control');
         oo = mitem(o,'Noise',{@Config},'Noise');
         oo = mitem(o,'-');
         oo = mitem(o,'X Variables',{@Config},'ConfigX');
         oo = mitem(o,'Y Variables',{@Config},'ConfigY');
      case {'final'}
         oo = mitem(o,'X&Y (Final)',{@Config},'Final');
   end
   change(o,'signal');                 % update active signal menu item
end

%==========================================================================
% Dead Beat Position Control
%==========================================================================

function oo = MenuDeadBeat(o)          % Dead Beat Sub Menu            
   oo = mitem(o,'Dead Beat Positioning');
   ooo = mitem(oo,'Info',{@DeadBeatInfo});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'No Noise',  {@invoke,mfilename,@DeadBeatStudy,0.0});
   ooo = mitem(oo,'Low Noise', {@invoke,mfilename,@DeadBeatStudy,0.1});
   ooo = mitem(oo,'High Noise',{@invoke,mfilename,@DeadBeatStudy,1.0});
end
function o = DeadBeatInfo(o)           % Info About Dead Beat          
   o = set(ultra,'title','Deadbeat Positioning');
   o = set(o,'comment',{
      'A Dead Beat positioning system corrects exactly the full extent of'
      'the measured alignment error.'
      ''
      'Deadbeat positioning means:',
      ' - measure an actual misalignment y(k) = x(k) + w(k)'
      ' - determine the correction: e(k) = -y(k)'
      ' - apply full correction to the positioning system: u(k) = e(k)'
      ' - transition of the positioning system: x(k+1) = x(k) + u(k)'
      ''
      'The actual alignment error will be "dead beated" in one cycle!'});
   message(opt(o,'halign','left'));         
end
function o = DeadBeatStudy(o)          % Actual Dead Beat Study        
   title = 'Dead Beat Positioning';    % plot object's title
   oo = Log(o,'study',title);          % create a 'study' typed log object
   
      % setup parameters and system matrix
      
   o = with(o,{'study.initial','study.noise','study.control'});
   sigw = arg(o,1) * opt(o,{'sigw',50});
   V = 1;  a = 0;  T = 0.01;
   A = eye(2);  B = eye(2);            % system matrices

      % manage brute force simulation

   if IsMode(o,'brute')
      o = opt(o,'sigw',sigw);
      o = opt(o,'Vk',1);
      o = opt(o,'ak',0);
      BruteForce(o,'DeadBeat',caption);
      return
   end

   repeats = opt(o,'repeats');         % number of repeats
   iterations = opt(o,'iterations');   % number of iterations
   steps = opt(o,'steps');             % number of iterations
   m = o.iif(repeats==1,iterations,steps);% actual number of iterations
   
   t = 0;
   for  i = 1:repeats                  % repeated system runs
      oo = Log(oo);                    % next repeat
      x = [opt(o,'x0'),opt(o,'y0')]';  % init position state
      xf = 0;                          % init filter state
      for k = 0:m;
         w = sigw*randn(size(x));      % gaussian noise
         y = x + w;                    % system output
      
         f = a*xf + (1-a)*y;           % filtered measurement
      
            % positining error and control signal

         e = -f;                       % positioning error
         u = V*e;                      % control signal
      
            % log everything before state transitions
       
         oo = Log(oo,t,x,y,e,u,w,f,V,a);
      
            % state transitions
         
         x = A*x + B*u;                % state update (positioning)
         xf = a*xf + (1-a)*y;          % filter state transition
         t = t + T;                    % time transition
      end
   end
  
   Graph(oo);                          % plot graphics & put in clip board
end

%==========================================================================
% Asymptotic Positioning
%==========================================================================

function oo = MenuAsymptotic(o)        % Dead Beat Sub Menu            
   oo = mitem(o,'Asymptotic Positioning');
   ooo = mitem(oo,'Info',{@AsymptoticInfo});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Asymptotic Positioning - V(k) = 0.9',{@AsymptoticStudy,0.9});
   ooo = mitem(oo,'Asymptotic Positioning - V(k) = 0.7',{@AsymptoticStudy,0.7});
   ooo = mitem(oo,'Asymptotic Positioning - V(k) = 0.5',{@AsymptoticStudy,0.5});
   ooo = mitem(oo,'Asymptotic Positioning - V(k) = 0.2',{@AsymptoticStudy,0.2});
end
function o = AsymptoticInfo(o)         % Info About Dead Beat          
   o = set(ultra,'title','Asymptotic Positioning');
   o = set(o,'comment',{
      'An asymptotic positioning system corrects only a (usually major)'
      'fraction of the measured alignment error.'
      ''
      'Asymptotic positioning means:',
      ' - measure an actual misalignment y(k) = x(k) + w(k)'
      ' - determine the correction: e(k) = -y(k)'
      ' - apply major correction to the positioning system: u(k) = V(k)*e(k)'
      ' - transition of the positioning system: x(k+1) = x(k) + u(k)'
      ''
      'The (time variant) parameter V(k) is the actual alignment error will be "dead beated" in one cycle!'});
   message(opt(o,'halign','left'));         
end
function o = AsymptoticStudy(o)        % Actual Asymptotic Study       
   refresh(o,o);                       % come here to refresh
   o = with(o,{'study.initial','study.noise'});
   T = 0.01;  fk = 0;  
   xk = [opt(o,'x0'),opt(o,'y0')]';  
   Vk = arg(o,1);  sigw = opt(o,{'sigw',50});
   ak = 0;
   
   caption = sprintf('Asymptotic Positioning - Noise: %gnm@1s, V(k): %g',sigw,Vk);
   if IsMode(o,'brute')
      o = opt(o,'Vk',Vk);
      o = opt(o,'ak',0);
      BruteForce(o,'Asymptotic',caption);
      return
   end
   
   for i = 0:100;
      k = i+1;
      t(k) = i*T;

      x(:,k) = xk;                     % assign new state
      w(:,k) = sigw*randn(size(xk));   % gaussian noise (here: zero)
      y(:,k) = x(:,k) + w(:,k);        % map state to output
      
      a(:,k) = ak;
      f(:,k) = a(:,k)*fk + [1-a(:,k)]*y(:,k);  % filtered measurement
      
      e(:,k) = -f(:,k);
      V(:,k) = Vk;                     % gain
      u(:,k) = V(:,k) * e(:,k);
      xk = x(:,k) + u(:,k);            % state update (positioning)
   end

   oo = Trace(caption,t,x,y,e,u,w,f,V,a);% create trace object
   graph(oo);                          % plot graphics & put in clip board
end

%==========================================================================
% Time Invariant Filter Based Positioning
%==========================================================================

function oo = MenuTiFilter(o)          % Dead Beat Sub Menu            
   oo = mitem(o,'Time Invariant Filter Based');
   ooo = mitem(oo,'Info',{@TiFilterInfo});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 1.00',{@TiFilterStudy,1.00});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.95',{@TiFilterStudy,0.95});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.9',{@TiFilterStudy,0.9});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.7',{@TiFilterStudy,0.7});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.5',{@TiFilterStudy,0.5});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.2',{@TiFilterStudy,0.2});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.1',{@TiFilterStudy,0.1});
   ooo = mitem(oo,'Time Invariant Filter - a(k) = 0.0',{@TiFilterStudy,0.0});
end
function o = TiFilterInfo(o)           % Info About Dead Beat          
   o = set(ultra,'title','Asymptotic Positioning');
   o = set(o,'comment',{
      'An asymptotic positioning system corrects only a (usually major)'
      'fraction of the measured alignment error.'
      ''
      'Asymptotic positioning means:',
      ' - measure an actual misalignment y(k) = x(k) + w(k)'
      ' - determine the correction: e(k) = -y(k)'
      ' - apply major correction to the positioning system: u(k) = V(k)*e(k)'
      ' - transition of the positioning system: x(k+1) = x(k) + u(k)'
      ''
      'The (time variant) parameter V(k) is the actual alignment error will be "dead beated" in one cycle!'});
   message(opt(o,'halign','left'));         
end
function o = TiFilterStudy(o)          % Actual Asymptotic Positioning Study        
   refresh(o,o);                       % come here to refresh
   o = with(o,{'study.initial','study.noise'});
   T = 0.01;  xk = [opt(o,'x0'),opt(o,'y0')]';  fk = 0;
   ak = arg(o,1);  sigw = opt(o,{'sigw',50});
   
   caption = sprintf('Time Variant Filter');
   if IsMode(o,'brute')
      o = opt(o,'Vk',1);
      o = opt(o,'ak',ak);
      BruteForce(o,'TiFilter',caption);
      return
   end
   
   for i = 0:100;
      k = i+1;
      t(k) = i*T;
      
      x(:,k) = xk;
      w(:,k) = sigw*randn(size(xk));   % gaussian noise (here: zero)
      y(:,k) = xk + w(k);              % map state to output
      
      fk = ak*fk + (1-ak)*y(:,k);
      f(:,k) = fk;
      
      e(:,k) = -f(:,k);
      u(:,k) = e(:,k);
      
      xk = x(:,k) + u(:,k);            % state update (positioning)
      fk = f(:,k) + u(:,k);            % filter state update
   end

   caption = sprintf('Asymptotic Positioning - Noise: %gnm@1s, a(k): %g',sigw,ak);
   oo = Trace(caption,t,x,y,e,u,w,f,V);% create trace object
   graph(oo);                          % plot graphics & put in clip board
end

%==========================================================================
% Growing Comb Filter Study
%==========================================================================

function oo = MenuGrowingComb(o)       % Dead Beat Sub Menu            
   oo = mitem(o,'Growing Comb Filter Based');
   ooo = mitem(oo,'Info',{@GrowingCombInfo});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Growing Comb Filter Study',{@GrowingCombStudy});
   ooo = mitem(oo,'Growing Comb Filter Alternative',{@GrowingCombAlternative});
end
function o = GrowingCombInfo(o)        % Info About Dead Beat          
   o = set(ultra,'title','*** Growing Comb Dead Beat');
   o = set(o,'comment',{
      'An asymptotic positioning system corrects only a (usually major)'
      'fraction of the measured alignment error.'
      ''
      'Growing Comb Filtered Dead Beat positioning means:',
      ' - measure an actual misalignment y(k) = x(k) + w(k)'
      ' - determine the correction: e(k) = -y(k)'
      ' - apply major correction to the positioning system: u(k) = V(k)*e(k)'
      ' - transition of the positioning system: x(k+1) = x(k) + u(k)'
      ''
      'The (time variant) parameter V(k) is the actual alignment error will be "dead beated" in one cycle!'});
   message(opt(o,'halign','left'));         
end
function o = GrowingCombStudy(o)       % Actual Growing Comb Study     
   refresh(o,o);                       % come here to refresh
   o = with(o,{'study.initial','study.noise'});
   T = 0.01;  xk = [opt(o,'x0'),opt(o,'y0')]';  
   fk = 0; n = 0;
   sigw = opt(o,{'sigw',50});
   
   caption = sprintf('Growing Comb Filter based Dead Beat - Noise: %gnm@1s',sigw);
   if IsMode(o,'brute')
      o = opt(o,'sigw',sigw);
      o = opt(o,'Vk',1);
      o = opt(o,'ak',0);
      BruteForce(o,'Comb',caption);
      return
   end
   
   for i = 0:100;
      k = i+1;
      t(k) = i*T;
      
      x(:,k) = xk;
      w(:,k) = sigw*randn(size(xk));   % gaussian noise (here: zero)
      y(:,k) = x(:,k) + w(:,k);        % map state to output
      
      if (k == 1)
         fk = y(:,k);
      else
         fk = [fk*(k-1) + y(:,k)]/k;
      end
      f(:,k) = fk;
      
      e(:,k) = -f(:,k);
      u(:,k) = e(:,k);
      
      xk = x(:,k) + u(:,k);            % state update (positioning)
      fk = f(:,k) + u(:,k);
   end

   oo = Trace(caption,t,x,y,e,u,w,f);  % create trace object
   graph(oo);                          % plot graphics & put in clip board
end
function o = GrowingCombAlternative(o) % Alternative Growing Comb Study
   o = with(o,{'study.initial','study.noise'});
   T = 0.01;  xk = [opt(o,'x0'),opt(o,'y0')]';  
   sigw = opt(o,{'sigw',50});
   
   for i = 0:100;
      k = i+1;
      t(k) = i*T;
      
      x(:,k) = xk;
      w(:,k) = sigw*randn(size(xk));   % gaussian noise (here: zero)
      y(:,k) = x(:,k) + w(:,k);        % map state to output
      
      f(:,k) = y(:,k)/k;
      e(:,k) = -f(:,k);
      u(:,k) = e(:,k);
      
      xk = x(:,k) + u(:,k);            % state update (positioning)
   end

   caption = sprintf('Growing Comb Filter based Dead Beat - Noise: %gnm@1s',sigw);
   oo = Trace(caption,t,x,y,e,u,w,f);  % create trace object
   graph(oo);                          % plot graphics & put in clip board
   refresh(o,o);                       % come here to refresh
end

%==========================================================================
% Brute Force Run
%==========================================================================

function ok = IsMode(o,value)          % Ask for Proper  Study Mode    
   mode = opt(o,'mode.study');
   ok = isequal(mode,value);
end
function oo = BruteForce(o,mode,caption)% Brute Force Simulation       
   o = with(o,{'study.control'});
   T = 0.01;
   n = opt(o,{'steps',5});             % number of control steps
   sigw = opt(o,{'sigw',50});
   Vk = opt(o,{'Vk',1});
   ak = opt(o,{'ak',0});
   repeats = 100;
   
   X = [];
   for j = 1:repeats
      xk = [opt(o,'x0'),opt(o,'y0')]';
      fk = 0;
      for i = 0:n;
         k = i+1;
         t(k) = i*T;

         x(:,k) = xk;
         w(:,k) = sigw*randn(size(xk));% gaussian noise (here: zero)
         y(:,k) = x(:,k) + w(:,k);     % map state to output

         if isequal(mode,'Comb')
            if (k == 1)
               fk = y(:,k);
            else
               fk = [fk*(k-1) + y(:,k)]/k;
            end
         else
            fk = ak*fk + (1-ak)*y(:,k);
         end
         f(:,k) = fk;
         a(:,k) = ak;
         
         e(:,k) = -f(:,k);
         u(:,k) = Vk*e(:,k);           % control law
         V(:,k) = Vk;
         
         xk = x(:,k) + u(:,k);         % state update (positioning)
         fk = f(:,k) + u(:,k);         % state update (positioning)
      end
      xn(:,j) = x(:,n+1);
      X = [X,x];
   end
   
   oo = trace(ultra('final'),'x',X(1,:),'y',X(2,:));
   oo = set(oo,'title',caption);
   oo = set(oo,'sizes',[1,n+1,repeats]);
   oo = set(oo,'method','blcs');
   graph(oo,'Scatter');                % plot graphics & put in clip board
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'study.control.iterations'},100); % number of iterations
   setting(o,{'study.control.steps'},5);    % number of control steps
   setting(o,{'study.noise.sigw'},50);
   setting(o,{'study.initial.x0'},300);
   setting(o,{'study.initial.y0'},250);

   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Number of Iterations','','study.control.iterations'); 
         charm(ooo,{});
   ooo = mitem(oo,'Number of Control Steps','','study.control.steps'); 
         charm(ooo,{});
   ooo = mitem(oo,'Measurement Noise (sigma [nm])','','study.noise.sigw'); 
         charm(ooo,{});
   ooo = mitem(oo,'Initial x0 [nm]','','study.initial.x0'); 
         charm(ooo,{});
   ooo = mitem(oo,'Initial y0 [nm]','','study.initial.y0'); 
         charm(ooo,{});
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Trace(caption,t,x,y,e,u,w,f,V,a)  % Create Trace Object  
   oo = trace(ultra('study'),t,'x',x(1,:),'y',x(2,:),...
          'yx',y(1,:),'yy',y(2,:),'ex',e(1,:),'ey',e(2,:),...
          'ux',u(1,:),'uy',u(2,:),'wx',w(1,:),'wy',w(2,:),...
          'fx',f(1,:),'fy',f(2,:),'V',V,'a',a);
   oo = set(oo,'title',caption);
end
function oo = Log(o,varargin)          % Setup a Data Log Object       
%
% LOG   Setup a data log object of given type and provide title
%
%          oo = Log(o,'study','Dead Beat Positioning'
%          oo = Log(oo,t,x,y,e,u,w,f)     % actual data logging
%
   if (length(varargin) >= 1 && ischar(varargin{1}))  % log object init
      type = varargin{1};
      title = varargin{2};
      oo = ultra(type);
      switch type
         case 'study'
            oo = log(oo,'t','x','y','yx','yy','ex','ey',...
                        'ux','uy','wx','wy','fx','fy','V','a');
         case 'final'
            oo = log(oo,'t','x','y');
          otherwise
            error(['type ',type,' is not supported!']);
      end
      oo = set(oo,'title',title);
      return
   end
%
% Update repeat index
%
   if (length(varargin) == 0)
      oo = log(o);                     % update repeat index
      return
   end
%
% otherwise actual data logging
%
   switch o.type
      case 'study'
         t = varargin{1};
         x = varargin{2};
         y = varargin{3};
         e = varargin{4};
         u = varargin{5};
         w = varargin{6};
         f = varargin{7};
         V = varargin{8};
         a = varargin{9};
         
         oo = log(o,t,x(1),x(2),y(1),y(2),e(1),e(2),...
                  u(1),u(2),w(1),w(2),f(1),f(2),V,a);
      
      case 'final'
         t = varargin{1};
         x = varargin{2};
         oo = log(o,t,x(1),x(2));
         
      otherwise
         error(['type ',o.type,' is not supported!']);
   end
end
function oo = Graph(o)                 % Plot Graph, Put in Clipboard  
   oo = graph(o);                      % delegate to method
end
