function oo = plug3(o,varargin)        % SPM Plugins                   
%
% PLUG3    SPM plugin
%
%             plug1(sho)               % plugin registration
%
%             oo = plug1(o,func)       % call local simple function
%
%          Read Driver for Simple & Plain Objects
%
%             oo = plug1(o,'New');
%             oo = plug1(o,'Simu');
%             oo = plug1(o,'Plot');
%
%          powered by Bluenetics @ 2020
%
%          See also: SPM, PLUGIN, SAMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,@Basket,...
                       @Callback,@New,@Simu,@Plot,@Stream,@Step,@Ramp,...
                       @ForceRamp,@AnalyseRamp,@NormRamp,...
                       @PhiDouble,@PhiRational,@TrfmDouble,@TrfmRational);
   oo = gamma(oo);
end              

%==========================================================================
% Plugin Setup & Registration, General Callback Invocation
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   tag = class(o);
   plugin(o,[tag,'/menu/End'],{mfilename,'Menu'});
   plugin(o,[tag,'/current/Select'],{mfilename,'Menu'});
end
function oo = Callback(o)              % General Callback              
%
% CALLBACK   A general callback with refresh function redefinition, 
%            screen clearing, current object pulling and forwarding
%            to the executing local function
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
   
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
   
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
end

%==========================================================================
% Plugin Definitions
%==========================================================================

function o = Menu(o)                   % General Plugin Definitions    
%
% PLUG   General Plugins can be used to plug-in menus at any menu locat-
%        ion. All it needs to be done is to locate a menu item by path and
%        to insert a new menu item at this location.
%
   oo = mseek(o,{'#','Select'});       % find Select rolldown menu
   if ~isempty(oo)
      ooo = Simu(oo);                  % add Simu parameter menu items
      ooo = Grid(oo);                  % add Grid menu items
      
      ooo = mitem(oo,'-');
      ooo = Constrain(oo);             % add Constrain menu items
      ooo = Brew(oo);                  % add Brew menu items
   end
   
   oo = Plot(o);                       % add Plot menu items
   oo = Analyse(o);                    % add Analyse menu items
   oo = Study(o);                      % add Study menu items
end

%==========================================================================
% Select Menu Plugins
%==========================================================================

function oo = Simu(o)                  % Simulation Parameter Menu     
%
% SIMU   Add simulation parameter menu items
%
   setting(o,{'simu.tmax'},0.01);
   setting(o,{'simu.Fmax'},100);
   setting(o,{'simu.dt'},0.00005);

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Max Time (tmax)',{},'simu.tmax');
          choice(ooo,[0.001,0.002,0.005,0.01,0.02,0.05,0.1],{});
   ooo = mitem(oo,'Time Increment (dt)',{},'simu.dt');
          choice(ooo,[1e-6,2e-6,5e-6, 1e-5,2e-5,5e-5, 1e-4,2e-4,5e-4],{});
          
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Max Force [N]',{},'simu.Fmax');
          choice(ooo,[1 2 5 10 20 50 100 200 500 1000],{});
end
function oo = Grid(o)                  % Grid Menu                     
%
% GRID   Add grid menu items
%
   setting(o,{'view.grid'},0);

   oo = mitem(o,'Grid',{},'view.grid');
         choice(oo,{{'Off',0},{'On',1}},{});
end
function oo = Constrain(o)             % Choose Constraint Output #    
   setting(o,{'constrain.index'},0);

   A  = get(current(o),'system.A');
   n = floor(length(A)/2);
   
   oo = mitem(o,'Constrain',{},'constrain.index');
         choice(oo,{{'None',0},{},1:n},{@ConstrainCb});
         
   function o = ConstrainCb(o)         % Constrain Callback            
      index = setting(o,{'constrain.index',0});
      oo = current(o);
      [A,B,C] = get(oo,'system','A,B,C');
       
      i1 = 1:n;  i2 = n+1:2*n;
      A11 = A(i1,i1);  A12 = A(i1,i2);  B1 = B(i1,:);  C1 = C(:,i1);
      A21 = A(i2,i1);  A22 = A(i2,i2);  B2 = B(i2,:);  C2 = C(:,i2);
      
      j1 = 1:size(B,2);  j1(index) = [];  j2 = index;
      B21 = B2(:,j1);  B22 = B2(:,j2);
      C11 = C1(j1,:);  C21 = C1(j2,:);
      
      oo = set(oo,'partial','A11,A12,A21,A22',A11,A12,A21,A22);
      oo = set(oo,'partial','B1,B2,C1,C2',B1,B2,C1,C2);
      oo = set(oo,'partial','B21,B22,C11,C21',B21,B22,C11,C21);
      
      current(o,oo);                    % refresh current object
      
      err = 0;  I = eye(size(A11));
      err = err || any(any(A11~=0*I));
      err = err || any(any(A12~=I));
      err = err || any(any(B1~=0));
      err = err || any(any(C2~=0));
      
      if (err)
         message(o,'Error: matrix invariants violated!',{'cannot proceed'});
      end
   end
end
function oo = Brew(o)                  % Brew Menu                     
%
% BREW   Add Brew menu items
%
   setting(o,{'brew.T0'},1);           % normalizing time constant

   oo = mitem(o,'Brew');
   ooo = mitem(oo,'Normalizing Time',{},'brew.T0');
         choice(ooo,[1 0.1 0.01 0.001 0.0001],{});
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Plot(o)                  % Plot Menu Setup               
%
% PLOT   Add Plot menu items
%
   oo = mseek(o,{'#','Plot'});         % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   types = {'shell','spm'};            % supported types
   
   oo = mitem(oo,'Response');
        enable(oo,basket(o,types));
        
   ooo = mitem(oo,'Step Response');
   oooo = mitem(ooo,'F1 Excitation',{@Callback,'Step'},1);
   oooo = mitem(ooo,'F2 Excitation',{@Callback,'Step'},2);
   oooo = mitem(ooo,'F3 Excitation',{@Callback,'Step'},3);

   ooo = mitem(oo,'Ramp Response');
   oooo = mitem(ooo,'F1 Excitation',{@Callback,'Ramp'},1);
   oooo = mitem(ooo,'F2 Excitation',{@Callback,'Ramp'},2);
   oooo = mitem(ooo,'F3 Excitation',{@Callback,'Ramp'},3);
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Force Ramp @ F1',{@Callback,'ForceRamp'},1);
   ooo = mitem(oo,'Force Ramp @ F2',{@Callback,'ForceRamp'},2);
   ooo = mitem(oo,'Force Ramp @ F3',{@Callback,'ForceRamp'},3);   
end

function o = Step(o)                   % Step Response                 
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   index = arg(o,1);
   t = Time(o);
   u = StepInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   heading(o,sprintf('Step Response: F%g->y (%s)',index,Title(o)));
end
function o = Ramp(o)                   % Ramp Response                 
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   index = arg(o,1);
   t = Time(o);
   u = RampInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   
   heading(o,sprintf('Ramp Response: F%g->y (%s)',index,Title(o)));
end

function o = ForceRamp(o)              % Force Ramp Response           
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(cast(o,'corasim'),'css');
   
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Ramp Response: F%g->y - %s',index,Title(o)));
end

%==========================================================================
% Analyse Menu Plugins
%==========================================================================

function oo = Analyse(o)               % Analyse Menu Setup            
%
% ANALYSE   Add Analyse menu items
%
   oo = mseek(o,{'#','Analysis'});     % find Select rolldown menu
   if isempty(oo)
      return
   end
   
      % delete some Study menu items

   for (label={'Surface','Histogram'})
      ooo = mseek(oo,label);
      if ~isempty(ooo)
         delete(mitem(ooo,inf));
      end
   end
      
      % add new items
   
   types = {'spm'};            % supported types
   
   ooo = mitem(oo,'Ramp Analysis');
   enable(ooo,type(current(o),types));
   oooo = mitem(ooo,'Force Ramp @ F2',{@Callback,'AnalyseRamp'},2);

   ooo = mitem(oo,'Normalized System');
   enable(ooo,type(current(o),types));
   oooo = mitem(ooo,'Force Ramp @ F2',{@Callback,'NormRamp'},2);
end
function o = AnalyseRamp(o)            % Analyse Force Ramp            
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = type(corasim(o),'css');
   
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Analyse Force Ramp: F%g->y - %s',index,Title(o)));
end
function o = NormRamp(o)               % Normalized System's Force Ramp
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
      % fetch some simulation parameters
      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});

      % transform system
      
   o = brew(o,'Normalize',1e-3);
   
   oo = type(corasim(o),'css');        % cast and change type
   t = Time(oo);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Analyse Force Ramp: F%g->y - %s',index,Title(o)));
end

%==========================================================================
% Analyse Menu Plugins
%==========================================================================

function oo = Study(o)                 % Study Menu Plugin            
%
% STUDY   Add Study menu items
%
   oo = mseek(o,{'#','Study'});        % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   kids = get(mitem(oo,inf),'Children');
   delete(kids);                       % delete existing Study menu items

      % start building up new study menu
      
   ooo = mitem(oo,'Transition Matrix');
   oooo = mitem(ooo,'Double',{@Callback,'PhiDouble'});
   oooo = mitem(ooo,'Rational',{@Callback,'PhiRational'});
   
   ooo = mitem(oo,'Transfer Matrix');
   oooo = mitem(ooo,'Double',{@Callback,'TrfmDouble'});
   oooo = mitem(ooo,'Rational',{@Callback,'TrfmRational'});   
end

function o = PhiDouble(o)              % Rational Transition Matrix
   refresh(o,{@menu,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partial');            % brew partial matrices
   
   %[A21,A22,B2,C1,D] = var(oo,'A21,A22,B2,C1,D');
   
   [A,B,C,D] = get(oo,'system','A,B,C,D');
   
   [n,m] = size(B);  [l,~] = size(C);

   O = base(inherit(corinth,o));       % need to access CORINTH methods
   G = matrix(O,zeros(l,m));

   for (j=1:m)                         % j indexes B(:,j) (columns of B)
      [num,den] = ss2tf(A,B,C,D,j);
      assert(l==size(num,1));
      for (i=1:l)
         numi = num(i,:);
         p = poly(O,numi);             % numerator polynomial
         q = poly(O,den);              % denominator polynomial
         
         Gij = ratio(O,1);
         Gij = poke(Gij,p,q);          % Gij not canceled and trimmed
         
         fprintf('G%g%g(s):\n',i,j)
         display(Gij);
         
         G = poke(G,Gij,i,j);
         
         numtag = sprintf('num_%g_%g',i,j);
         oo = cache(oo,['brew.',numtag],numi);

         dentag = sprintf('den_%g_%g',i,j);
         oo = cache(oo,['brew.',dentag],den);
      end
   end
   
   oo = cache(oo,'brew.G',G);          % store in cache
   cache(oo,oo);                       % cache store back to shell
   
   fprintf('Transfer Matrix (calculated using double)\n');
   display(var(oo,'G'));
end
function o = PhiRational(o)            % Double Transition Matrix
   message(o,'PhiRational: not yet implemented');
end

function o = TrfmDouble(o)             % Double Transfer Matrix        
   G = trfu(o,3,1);
   G
end
function o = TrfmRational(o)           % Rational Transfer Matrix      
   G = trfu(o,3,1);
   G
end

%==========================================================================
% Plotting
%==========================================================================

function o = PlotY(o)                  % Plot Output Signals           
   Kms = var(o,{'Kms',1});             % time scaling correction
   ms = Kms*0.001;                     % factor ms/s
   um = 1e-6;
   
   o = corazon(o);                     % use CORAZON plot method
   [t,u,y] = data(o,'t,u,y');
   
   Plot11(o);                          % Elongation 1
   Plot12(o);                          % Elongation 2
   Plot21(o);                          % Elongation 3
   Plot22(o);                          % Input
   
   function Plot11(o)                  % Elongation 1                                              
      subplot(221);
      plot(o,t/ms,y(1,:)/um,'g');
      title('Output (Elongation 1)');
      xlabel('t [ms]');  ylabel('y1 [um]');
      grid(o);
   end
   function Plot12(o)                  % Elongation 2                                              
      subplot(222);
      plot(o,t/ms,y(2,:)/um,'c');
      title('Output (Elongation 2)');
      xlabel('t [ms]');  ylabel('y2 [um]');
      grid(o);
   end
   function Plot21(o)                  % Elongation 3                                              
      subplot(223);
      plot(o,t/ms,y(3,:)/um,'r');
      title('Output (Elongation 3)');
      xlabel('t [ms]');  ylabel('y3 [um]');
      grid(o);
   end
   function Plot22(o)                                                  
      subplot(224);
      plot(o,t/ms,u,'b');
      title('Input (Force)');
      xlabel('t [ms]');  ylabel('F [N]');
      grid(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function title = Title(o)              % Get Object Title              
   title = get(o,{'title',[class(o),' object']});
   
   dir = get(o,'dir');   
   idx = strfind(dir,'@');
   if ~isempty(dir)
      [package,typ,name] = split(o,dir(idx(1):end));
      title = [title,' - [',package,']'];
   end
end
function t = Time(o)                   % Get Time Vector               
   T = opt(o,{'simu.dt',0.00005});
   tmax = opt(o,{'simu.tmax',0.01});
   t = 0:T:tmax;
end
function u = StepInput(o,t,index)      % Get Step Input Vector         
%
% STEPINPUT   Get step input vector (and optional time vector)
%
%                u = StepInput(o,t,index)
%
   [~,m] = size(o);                   % number of inputs
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*ones(size(t));
end
function u = RampInput(o,t,index,Fmax) % Get Ramp Input Vector         
%
% RAMPINPUT   Get ramp input vector (and optional time vector)
%
%                u = RampInput(o,t,index)
%                u = RampInput(o,t,index,Fmax)
%
   if (nargin < 4)
      Fmax = max(t);
   end
   
   [~,m] = size(o);                   % number of inputs
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*t * Fmax/max(t);
end
function ok = Trf                      % is TRF Class Supported?       
   try
      oo = trf([1 0],[1 2]);
      ok = true;
   catch
      ok = false;
   end
end
