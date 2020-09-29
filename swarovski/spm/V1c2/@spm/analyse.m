function oo = analyse(o,varargin)      % Graphical Analysis            
%
% ANALYSE   Graphical analysis
%
%    Plenty of graphical analysis functions
%
%       analyse(o)                % analyse @ opt(o,'mode.analyse')
%
%       oo = analyse(o,'menu')    % setup Analyse menu
%       oo = analyse(o,'Surf')    % surface plot
%       oo = analyse(o,'Histo')   % display histogram
%
%    See also: SPM, PLOT, STUDY
%
   [gamma,o] = manage(o,varargin,@Err,@Menu,@WithCuo,@WithSho,@WithBsk,...
                      @Overview,@Rloc,@AnalyseRamp,@NormRamp,...
                      @TsBode,@TsStep,@Ts);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Analyse Menu            
   oo = CriticalMenu(o);
   oo = mitem(o,'Root Locus',{@WithCuo,'Rloc'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Closed Loop');
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'TsBode'});
   ooo = mitem(oo,'Step Plot',{@WithCuo,'TsStep'});
%   ooo = mitem(oo,'T(s)',{@WithCuo,'Ts'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Normalized System');
   %enable(ooo,type(current(o),types));
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'NormRamp'},2);
end
function o = Err(o)                    % Error Handler                 
   error('bad mode');
end
function o = CriticalMenu(o)           % Critical Path Menu            
   oo = mitem(o,'Critical Path');
   ooo = mitem(oo,'Overview',{@Overview});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F3 -> y3:  G33(s)',{@plot,'WithCuo','Gs',3,3});
   ooo = mitem(oo,'y3 -> F3:  H33(s)',{@plot,'WithCuo','Hs',3,3});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F1 -> y3:  G31(s)',{@plot,'WithCuo','Gs',3,1});
   ooo = mitem(oo,'F1 -> y3:  H31(s) = -G31(s)*H33(s)',...
                                      {@plot,'WithCuo','Hs',3,1});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F1 -> y3:  L51(s) = H31(s)',{@plot,'WithCuo','Ls',5,1});
   ooo = mitem(oo,'-');
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
% Root Locus
%==========================================================================

function o = Rloc(o)                   % Root Locus                    
   o = with(o,'rloc');
   o = with(o,'style');
   
   L = cache(o,'consd.L');
   
   L51 = peek(L,5,1);
   [num,den] = peek(L51);
   
   mu = opt(o,{'process.mu',0.1});
   
%  oo = system(inherit(corasim,o),{-mu*num,den});
   oo = system(inherit(corasim,o),{mu*num,den});
   
   subplot(o,111);
   rloc(oo);
   title(sprintf('Root Locus - mu = %g',mu));
   
   heading(o);
end

%==========================================================================
% Closed Loop
%==========================================================================

function o = TsBode(o)                 % Closed Loop Bode Plots        
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   
   o = opt(o,'color','yyr');
   diagram(o,'Bode','Tf1(s)',Tf1,[4 2 1 1]);
   diagram(o,'Bode','Tf2(s)',Tf2,[4 2 1 2]);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   
   o = opt(o,'color','g');
   diagram(o,'Bode','Ts1(s)',Ts1,[4 2 2 1]);
   diagram(o,'Bode','Ts2(s)',Ts2,[4 2 2 2]);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   
   o = opt(o,'color','bc');
   diagram(o,'Bode','Tv1(s)',Tv1,[4 2 3 1]);
   diagram(o,'Bode','Tv2(s)',Tv2,[4 2 3 2]);

   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   
   o = opt(o,'color','r');
   diagram(o,'Bode','Ta1(s)',Ta1,[4 2 4 1]);
   diagram(o,'Bode','Ta2(s)',Ta2,[4 2 4 2]);
   
   heading(o);
end
function o = TsStep(o)                 % Closed Loop Step Plots        
   o = with(o,'simu');
   
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   o = opt(o,'color','yyr');
   diagram(o,'Fstep','Tf1(s)',Tf1,4211);
   diagram(o,'Fstep','Tf2(s)',Tf2,4212);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   o = opt(o,'color','g');
   diagram(o,'Step','Ts1(s)',Ts1,4221);
   diagram(o,'Step','Ts2(s)',Ts2,4222);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   o = opt(o,'color','bc');
   diagram(o,'Step','Tv1(s)',Tv1,4231);
   diagram(o,'Step','Tv2(s)',Tv2,4232);
   
   
   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   o = opt(o,'color','r');
   diagram(o,'Step','Ta1(s)',Ta1,4241);
   diagram(o,'Step','Ta2(s)',Ta2,4242);
   
   heading(o);
end
function o = Ts(o)                                                     
%
% TS   Closed Loop
%
%      Open loop:
%
%         Fd(s) = -mu*R*Fn(s)
%         Fn(s) = Ln(s)*Fd(s) + F0(s)  with Ln(s) = [L31(s) L32(s)]
%
%         F1(s) = -mu*r1*F3(s)    (r1 = 1)
%         F2(s) = -mu*r2*F3(s)    (r2 = 0)
%
%         F3(s) = L31(s)*F1(s) + L32(s)*F2(s) + F0(s)
%
%      Note: F2(s) = 0 since r2 = 0
%
%         F3(s) = F0(s) + L31(s)*F1(s) =
%               = F0(s) - mu*L31(s)*F3(s)
%
%         (1 + mu*L31(s))*F3(s) = F0(s)
%         F3(s)/F0(s) = 1 / (1+mu*L31(s)) =: T(s)
%
%                        1
%         T(s) := -----------------
%                   1 + mu*L31(s)
%
   L = cache(o,'consd.L');
   L31 = peek(L,3,1);
end

%==========================================================================
% Analyse Menu Plugins
%==========================================================================

function o = NormRamp(o)               % Normalized System's Force Ramp
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
      % fetch some simulation parameters
      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});

      % transform system
      
   o = brew(o,'Normalize');
   [A,B,C,D]=get(o,'system','A,B,C,D');% for debug

   oo = type(corasim(o),'css');        % cast and change type
   t = Time(oo);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Analyse Force Ramp: F%g->y - %s',index,Title(o)));
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
function oo = Corasim(o)               % Convert To Corasim Object     
   oo = type(cast(o,'corasim'),'css');
   [A,B,C,D] = data(o,'A,B,C,D');
   oo = system(oo,A,B,C,D);
end
function u = StepInput(o,t,index,Fmax) % Get Step Input Vector         
%
% STEPINPUT   Get step input vector (and optional time vector)
%
%                u = StepInput(o,t,index)
%                u = StepInput(o,t,index,Fmax)
%
   if (nargin < 4)
      Fmax = 1;
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
   u = Fmax * I(:,index)*ones(size(t));
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
