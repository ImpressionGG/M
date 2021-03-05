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
                      @WithSpm,@Numeric,@Trf,@TfOverview,...
                      @Principal,...
                      @Critical,...
                      @StabilitySummary,@StabilityMargin,@NyquistStability,...
                      @LmuDisp,@LmuRloc,@LmuStep,@LmuBode,@LmuNyq,...
                      @LmuBodeNyq,@Overview,...
                      @Margin,@Rloc,@StabilityOverview,@OpenLoop,@Calc,...
                      @Damping,@Contribution,@NumericCheck,...
                      @SensitivityW,@SensitivityF,@SensitivityD,...
                      @AnalyseRamp,@NormRamp,@SimpleCalc,...
                      @BodePlots,@StepPlots,@PolesZeros,...
                      @L0Magni,@LambdaMagni,@LambdaBode,...
                      @SetupAnalysis,...
                      @EigenvalueCheck);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Analyse Menu            
   switch type(current(o))
      case 'shell'
         oo = ShellMenu(o);
      case 'spm'
         oo = SpmMenu(o);
      case 'pkg'
         oo = PkgMenu(o);
      otherwise
         oo = mitem(o,'About',{@WithCuo,'About'});
   end
end
function oo = ShellMenu(o)             % Setup Plot Menu for SHELL Type
   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Overview',{@WithCuo,'StabilityOverview'});
end
function oo = PkgMenu(o)               % Setup Plot Menu for Pkg Type  
   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Stability Margin',{@WithCuo,'StabilityMargin'});

   oo = SetupMenu(o);
end
function oo = SpmMenu(o)               % Setup SPM Analyse Menu        
   oo = PrincipalMenu(o);              % Add Principal menu
   oo = CriticalMenu(o);               % Add Critical menu

   oo = mitem(o,'-');
   oo = StabilityMenu(o);              % add Stability menu
   oo = SetupMenu(o);                  % add Setup menu
   
   oo = mitem(o,'-'); 
o = mitem(o,'Legacy');
   
   oo = NumericMenu(o);                % add Numeric menu

   oo = mitem(o,'-'); 
   oo = OpenLoopMenu(o);               % add Open Loop menu
   oo = ClosedLoopMenu(o);             % add Closed Loop menu

   oo = mitem(o,'-'); 
   oo = Sensitivity(o);                % add Sensitivity menu
   
   oo = mitem(o,'-'); 
   oo = Spectrum(o);                   % add Spectrum menu
   
   oo = mitem(o,'-'); 
   oo = Force(o);                      % add Force menu
   oo = Acceleration(o);               % add Acceleration menu
   oo = Velocity(o);                   % add Velocity menu
   oo = Elongation(o);                 % add Elongation menu
   
   oo = mitem(o,'-');
   %oo = CriticalMenu(o);
   oo = mitem(o,'Normalized System');
   %enable(ooo,type(current(o),types));
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'NormRamp'},2);
   
   oo = Precision(o);
end

function oo = PrincipalMenu(o)         % Principal Menu                
   oo = mitem(o,'Principal');
   ooo = mitem(oo,'Genesis',{@WithSpm,'Principal','Genesis'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'G31 Spectrum',{@WithSpm,'Principal','G31'});
   ooo = mitem(oo,'G33 Spectrum',{@WithSpm,'Principal','G33'});
end
function oo = CriticalMenu(o)          % Critical Menu                 
   oo = mitem(o,'Critical');
   ooo = mitem(oo,'Overview',{@WithSpm,'Critical','Overview'});
   ooo = mitem(oo,'Bode & Damping',{@WithSpm,'Critical','Combi'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Critical Gain',{@WithSpm,'Critical','Damping'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bode',{@WithSpm,'Critical','Bode'});
   ooo = mitem(oo,'Magnitude',{@WithSpm,'Critical','Magni'});
   ooo = mitem(oo,'Phase',{@WithSpm,'Critical','Phase'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Nyquist',{@WithSpm,'Critical','Nyquist'});
   ooo = mitem(oo,'Critical',{@WithSpm,'Critical','Critical'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Simple Calculation', {@WithSpm,'SimpleCalc'});
end
function oo = StabilityMenu(o)         % Stability Menu                
   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Overview',{@WithCuo,'StabilitySummary'});
   ooo = mitem(oo,'-');   
   ooo = mitem(oo,'Stability Margin',{@WithCuo,'StabilityMargin'});
   ooo = mitem(oo,'Nyquist',{@WithCuo,'NyquistStability'});
   
   ooo = mitem(oo,'-');   
   ooo = mitem(oo,'Legacy');
   oooo = mitem(ooo,'Overview',{@WithCuo,'StabilityOverview'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Stability Margin',{@WithCuo,'Margin'});
   oooo = mitem(ooo,'Damping',{@WithCuo,'Damping'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Root Locus',{@WithCuo,'Rloc'});
end
function oo = SetupMenu(o)             % Setup Menu                    
   oo = mitem(o,'Setup');
   ooo = mitem(oo,'Basic Study',{@WithCuo,'SetupAnalysis','basic'});
   ooo = mitem(oo,'Symmetry Study',{@WithCuo,'SetupAnalysis','symmetry'});
   ooo = mitem(oo,'Sample Study',{@WithCuo,'SetupAnalysis','sample'});
end

function oo = NumericMenu(o)           % Numeric Menu                  
   oo = mitem(o,'Numeric');
   ooo = mitem(oo,'Numeric Quality of G(s)',{@WithSpm,'Numeric'});
end
function oo = OpenLoopMenu(o)          % Open Loop Menu                
   oo = mitem(o,'Open Loop');
   ooo = mitem(oo,'Overview',{@WithCuo,'OpenLoop','Lmu',1,'bcc'});
   ooo = mitem(oo,'Lmu(s)',{@WithCuo,'LmuDisp'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'LmuRloc'});
   ooo = mitem(oo,'Step Response',{@WithCuo,'LmuStep'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bode Plot',{@WithCuo,'LmuBode'});
   ooo = mitem(oo,'Nyquist Plot',{@WithCuo,'LmuNyq'});
   ooo = mitem(oo,'Bode/Nyquist',{@WithCuo,'LmuBodeNyq'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Calculation',{@WithCuo,'Calc','L0',1,'bcc'});
end
function oo = ClosedLoopMenu(o)        % Closed Loop Menu              
   oo = mitem(o,'Closed Loop');
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'BodePlots'});
   ooo = mitem(oo,'Step Responses',{@WithCuo,'StepPlots'});
   ooo = mitem(oo,'Poles & Zeros',{@WithCuo,'PolesZeros'});
end
function oo = Sensitivity(o)           % Sensitivity Menu              
   oo = mitem(o,'Sensitivity');
   ooo = mitem(oo,'Weight Sensitivity',{@WithSpm,'SensitivityW'});
   ooo = mitem(oo,'Frequency Sensitivity',{@WithSpm,'SensitivityF'});
   ooo = mitem(oo,'Damping Sensitivit',{@WithSpm,'SensitivityD'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Modal Contribution',{@WithSpm,'Contribution'});
   ooo = mitem(oo,'Numerical Check',{@WithSpm,'NumericCheck'});
end
function oo = Spectrum(o)              % Spectrum Menu                 
   oo = mitem(o,'Spectrum');
   ooo = mitem(oo,'L0 Magnitude Plots',{@WithSpm,'L0Magni'});
   ooo = mitem(oo,'Lambda Magnitude Plots',{@WithSpm,'LambdaMagni'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lambda Bode Plot',{@WithSpm,'LambdaBode'});
end
function oo = Force(o)                 % Closed Loop Force Menu        
   oo = mitem(o,'Force');
   sym = 'Tf';  sym1 = 'Tf1';  sym2 = 'Tf2';  col = 'yyyr';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tf(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tf1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Tf2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Acceleration(o)          % Closed Loop Acceleration Menu 
   oo = mitem(o,'Acceleration');
   sym = 'Ta';  sym1 = 'Ta1';  sym2 = 'Ta2';  col = 'r';

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ta(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ta1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Ta2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Velocity(o)              % Closed Loop Velocity Menu     
   oo = mitem(o,'Velocity');
   sym = 'Tv';  sym1 = 'Tv1';  sym2 = 'Tv2';  col = 'bc';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tv(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tv1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Tv2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Elongation(o)            % Closed Loop Elongation Menu   
   oo = mitem(o,'Elongation');
   sym = 'Ts';  sym1 = 'Ts1';  sym2 = 'Ts2';  col = 'g';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ts(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ts1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Ts2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Precision(o)             % Precision Menu                
   oo = mitem(o,'Precision');
   ooo = mitem(oo,'Eigenvalues',{@WithCuo,'EigenvalueCheck'});
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
   if ~type(oo,{'spm','shell','pkg'})
      plot(oo,'About');
      return
   end
   
      % refresh caches
      
%  [oo,bag,rfr] = cache(oo,oo,'trf');  % transfer function cache segment
%  [oo,bag,rfr] = cache(oo,oo,'consd');% constrained trf cache segment
%  [oo,bag,rfr] = cache(oo,oo,'process'); % process cache segment
   
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   else
      dark(oo);                        % do dark mode actions
   end
end
function oo = WithSpm(o)               % 'With Current Spm Callback    
%
% WITHSPM Same as WithCuo but checking if current object is an spm object,
%         otherwise calling plot(o,'About')
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   if ~type(oo,{'spm'})
      plot(oo,'About');
      return
   end
   
      % refresh caches
      
%  [oo,bag,rfr] = cache(oo,oo,'trf');  % transfer function cache segment
%  [oo,bag,rfr] = cache(oo,oo,'consd');% constrained trf cache segment
%  [oo,bag,rfr] = cache(oo,oo,'process'); % process cache segment
   
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   else
      dark(oo);                        % do dark mode actions
   end
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

function o = Err(o)                    % Error Handler                 
   error('bad mode');
end

%==========================================================================
% Principal
%==========================================================================

function o = Principal(o)              % Pricipal Menu Callbacks       
   if type(o,{'spm'})
      o = cache(o,o,'critical');
      o = cache(o,o,'spectral');
   else
      plot(o,'About');
      return
   end
   
   Heading(o);
   
   mode = arg(o,1);
   switch mode
      case 'Genesis'
         PrincipalGenesis(o);
      case 'G31'
         PrincipalSpectrum(o,'g31');
      case 'G33'
         PrincipalSpectrum(o,'g33');
   end
end
function o = PrincipalGenesis(o)
   [l0,g31,g33,g0] = cook(o,'lambda0,g31,g33,g0');
   
   [~,no,~] = size(l0);
   l0 = peek(l0,1);
   g31 = peek(g31,1);
   g33 = peek(g33,no);
   
   MagniChart(o,411,g31);
   MagniChart(o,412,g33);
   MagniChart(o,413,g0);
   MagniChart(o,414,l0);
end
function o = PrincipalSpectrum(o,tag)
   g = cook(o,tag);
   no = prod(size(g.data.matrix));
   sub = [211,212];
   name = get(g,{'name',''});
   idx = o.iif(isequal(name,'g33(s)'),no,1);
   
      % draw magnitudes
      
   for (i=1:no)
      gi = peek(g,i);
      col = Colors(o,gi,i);
      gi = set(gi,'color',col);
      MagniChart(o,sub(1),gi,0);
   end
   gi = peek(g,idx);
   col = [get(gi,'color'),'2'];
   gi = set(gi,'color',col);
   MagniChart(o,sub(1),gi,1);
   
      % draw phases
      
   for (i=1:no)
      gi = peek(g,i);
      col = Colors(o,gi,i);
      gi = set(gi,'color',col);
      PhaseChart(o,sub(2),gi,0);
   end
   gi = peek(g,idx);
   col = [get(gi,'color'),'2'];
   gi = set(gi,'color',col);
   PhaseChart(o,sub(2),gi,1);
end


function oldPlotNyquist(o,sub,critical)
   o = cache(o,o,'spectral');       % hard refresh 'spectral' segment

   o = with(o,'nyq');

   subplot(o,sub);
   l0 = cook(o,'lambda0');
   K = o.iif(critical,K0,1);

   if (dark(o))
      colors = {'rk','gk','b','ck','mk','yk','wk'};
   else
      colors = {'rwww','gwww','bwww','cwww','mwww','yw','wk'};
   end
   colors = get(l0,{'colors',colors});

   for (i=1:length(l0.data.matrix(:)))
      l0i = peek(l0,i);
      l0jwi = l0i.data.matrix{1,1};

      col = colors{1+rem(i,length(colors))};
      nyq(K*l0i,col);
   end

   if (critical)
      col = 'r2';
   else
      col = [get(l0,'color'),'2'];
   end

   l00 = peek(l0,1);
   nyq(K*l00,col);

   if (critical)
      title(sprintf('Critical Loci K0*lambda0(jw) - K0: %g @ f0: %g Hz',K0,f0));
   else
      title(sprintf('Spectrum lambda0(jw) - K0: %g @ f0: %g Hz',K0,f0));
   end
end

%==========================================================================
% Critical
%==========================================================================

function o = Critical(o)               % Calculate Critical Quantities 
   if type(o,{'spm'})
      o = cache(o,o,'critical');
   else
      plot(o,'About');
      return
   end
   
   Heading(o);
   o = with(o,{'bode','stability'});
   
   points = opt(o,{'omega.points',10000});
   closeup = opt(o,{'bode.closeup',0});

   [f0,K0] = cook(o,'f0,K0');
   
   if (closeup)
       points = max(points,500);
       o = opt(o,'omega.low',2*pi*f0/(1+closeup));
       o = opt(o,'omega.high',2*pi*f0*(1+closeup));
       o = opt(o,'omega.points',points);
   end
   
   mode = arg(o,1);
   switch mode
      case 'Overview'
         critical(o,'Overview',[3211,3221,0]);
         subplot(o,3211);

         PlotNyquist(o,2212,0);   
         PlotNyquist(o,2222,1);   
         critical(o,'Overview',[0,0,3231]);
      case 'Combi'
         critical(o,'Overview',[3111,3121,3131]);
      case 'Damping'
         critical(o,'Damping',[211,212]);
      case 'Bode'
         critical(o,'Bode',[211,212]);
         subplot(o,211);
      case 'Magni'
         critical(o,'Magni',111);
      case 'Phase'
         critical(o,'Phase',111);
         
      case 'Nyquist'
         PlotNyquist(o,111,0);
      case 'Critical'
         PlotNyquist(o,111,1);   
   end
   Heading(o);
         
   function PlotNyquist(o,sub,critical)
      o = cache(o,o,'spectral');       % hard refresh 'spectral' segment
      
      o = with(o,'nyq');
      
      subplot(o,sub);
      l0 = cook(o,'lambda0');
      K = o.iif(critical,K0,1);
      
      if (dark(o))
         colors = {'rk','gk','b','ck','mk','yk','wk'};
      else
         colors = {'rwww','gwww','bwww','cwww','mwww','yw','wk'};
      end
      colors = get(l0,{'colors',colors});
      
      no = length(l0.data.matrix(:));
      for (i=no)
         l0i = peek(l0,i);
         l0jwi = l0i.data.matrix{1,1};

         col = colors{1+rem(i,length(colors))};
         nyq(K*l0i,col);
      end
            
      if (critical)
         col = 'r2';
      else
         col = [get(l0,'color'),'2'];
      end
      
      if (critical)
         l00 = peek(l0,1);
         l00jw = l00.data.matrix{1};
         
         for (i=1:no)
            ljw(i,:) = l0.data.matrix{i};
         end
         
         for (j=1:size(ljw,2))
            [~ ,idx] = sort(abs(ljw(:,j)));
            l00jw(j) = ljw(idx(no),j);
         end
         
         nyq(K*l00,col);

         l00.data.matrix{1} = l00jw;   
         nyq(K*l00,'r1');
         
         title(sprintf('Critical Loci K0*lambda0(jw) - K0: %g @ f0: %g Hz',K0,f0));
      else
         l00 = peek(l0,1);
         nyq(K*l00,col);
         limits(o,'Nyq');                 % plot nyquist limits
         title(sprintf('Spectrum lambda0(jw) - K0: %g @ f0: %g Hz',K0,f0));
      end
   end
end

%==========================================================================
% Stability
%==========================================================================

function o = StabilitySummary(o)       % Plot Stability Overview       
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   mu = opt(o,{'process.mu',0.1});

   Heading(o);
   NyquistChart(o,1211,mu);
   MarginChart(o,[2212,2222]);
end
function o = StabilityMargin(o)        % Plot Stability Margins        
   switch o.type
      case 'pkg'
         o = PkgStabilityMargin(o);
      case 'spm'
         o = SpmStabilityMargin(o);
      otherwise
         plot(o,'About');
   end
end

function o = NyquistStability(o)       % Plot Stability Margins        
   if type(o,{'spm'})
      o = cache(o,o,'critical');
   else
      plot(o,'About');
      return
   end
   
   Heading(o);
   
   mu = opt(o,{'process.mu',0.1});
   NyquistChart(o,111,mu);
end

function o = SpmStabilityMargin(o)  % Plot SPM Stability Margin
   o = cache(o,o,'critical');
   Heading(o);
   MarginChart(o,[211,212]);
end
function o = PkgStabilityMargin(o)     % Plot PKG Stability Margin     
   if ~type(o,{'pkg'})
      plot(o,'About');
      return
   end
   
   package = get(o,'package');
   if isempty(package)
      error('no package ID provided');
   end

   Heading(o);                         % start with heading
   
      % get object list of package
      % note that first list element is the package object, which has 
      % to been deleted. calculate stability margin for all data objects
      

   o = with(o,{'style','process','stability'});
   [list,n] = children(o);

   mu = opt(o,{'process.mu',0.1});
   kmu = opt(o,{'process.kmu',1});
   
   x = Axes(o,4211,mu,'LogMargin');    % get variation range and plot axes
   x = Axes(o,4221,mu,'Critical');     % get variation range and plot axes
   x = Axes(o,4231,mu,'Margin');       % get variation range and plot axes
   x = Axes(o,4241,mu,'Frequency');    % get variation range and plot axes
   
   x = Axes(o,4212,-mu,'LogMargin');   % get variation range and plot axes
   x = Axes(o,4222,-mu,'Critical');    % get variation range and plot axes
   x = Axes(o,4232,-mu,'Margin');      % get variation range and plot axes
   x = Axes(o,4242,-mu,'Frequency');   % get variation range and plot axes
  
      % calculate stability margin and plot
   
   
   infgreen = o.iif(dark(o),'g|p3','ggk|p3');
   green = o.iif(dark(o),'g|o3','ggk|o3');
   yellow = 'yyyr|o3'
   red = 'r|o3';
   
   stop(o,'Enable');
   for (i=1:n)                         % calc & plot stability margin  
      txt = sprintf('calculate stability range of %s',get(o,'title'));
      progress(o,txt,i/n*100);
      
      oo = list{i};
      oo = inherit(oo,o);
      
      [K0,f0,K180,f180] = cook(oo,'K0,f0,K180,f180');

%     Mu0(i) = mu/K0;
      M0(i) = K0/mu;
      PlotLogMargin(x(i),M0(i),4211);
      PlotMucrit(x(i),K0,4221);
      PlotMargin(x(i),M0(i),4231);
      PlotFrequency(x(i),f0,4241);
      
%     Mu180(i) = mu/K180;
      M180(i) = K180/mu;
      PlotLogMargin(x(i),M180(i),4212);
      PlotMucrit(x(i),K180,4222);
      PlotMargin(x(i),M180(i),4232);
      PlotFrequency(x(i),f180,4242);
      
      idle(o);                         % show graphics
      if stop(o)
         break;
      end
   end
   stop(o,'Enable');
   
   progress(o);                        % progress completed
   Heading(o);                         % add heading
   
   function PlotMucrit(xi,mu0,sub)     % Critical Friction Coefficient
      subplot(o,sub);
      if (mu0 > mu*kmu)
         plot(o,xi,mu0,green);
      elseif (mu0 < mu)
         plot(o,xi,mu0,red);
      else
         plot(o,xi,mu0,yellow);
      end
   end
   function PlotMargin(xi,marg,sub)
      subplot(o,sub);
      if isinf(marg)
         plot(o,xi,0,infgreen);
      elseif (marg > kmu)
         plot(o,xi,marg,green);
      elseif (marg < 1)
         plot(o,xi,marg,red);
      else
         plot(o,xi,marg,yellow);
      end
   end
   function PlotLogMargin(xi,marg,sub)
      subplot(o,sub);
      if isinf(marg)
         marg = 0;
         col = infgreen;
      elseif (marg > kmu)
         col = green;
      elseif (marg < 1)
         col = red;
      else
         col = yellow;
      end
      plot(o,xi,20*log10(marg),col);
   end
   function PlotFrequency(xi,f,sub)
      subplot(o,sub);
      plot(o,xi,f,'Ko|');
   end
    
   function x = Axes(o,sub,mu,tit)     % Plot Axes 
      subplot(o,sub);

      variation = get(o,'variation');
      for (ii=1:n)
         oi = list{ii};

         if ~isempty(variation)
            x(ii) = get(oi,{variation,ii});
         else
            x(ii) = ii;
         end
      end   
      
      [lim,col] = limits(o);
      plot(o,x,0*x,'K.');
      if o.is(lim)
         kmu = lim(1)/lim(2);
         if isequal(tit,'Critical')
            plot(o,get(gca,'xlim'),[1 1]/lim(1),col);
            plot(o,get(gca,'xlim'),[1 1]/lim(2),col);
         elseif isequal(tit,'Margin') 
            plot(o,get(gca,'xlim'),[1 1],col);
            plot(o,get(gca,'xlim'),[1 1]*kmu,col);
         elseif isequal(tit,'LogMargin')
            plot(o,get(gca,'xlim'),20*log10([1 1]),col);
            plot(o,get(gca,'xlim'),20*log10([1 1]*kmu),col);
         end
      end

      dir = o.iif(mu>0,'Forward','Backward');
      if isequal(tit,'Frequency')
         title(sprintf('Critical Frequency (%s Cutting)',dir));
         ylabel('Frequency [Hz]');
      elseif isequal(tit,'Critical')
         title(sprintf('Critical Friction (%s Cutting)',dir));
         ylabel(o.iif(mu>0,'mu0 = K0','mu180 = K180'));
      elseif isequal(tit,'LogMargin')
         title(sprintf('Stability Margin [dB] (%s Cutting, mu: %g)',dir,abs(mu)));
         ylabel('Stability margin [dB]');
      else
         title(sprintf('Stability Margin [dB] (%s Cutting, mu: %g)',dir,abs(mu)));
         ylabel(sprintf('Stability %s',tit));
      end


      if ~isempty(variation)
         xlabel(sprintf('Variation Parameter: %s',variation));
      else
         xlabel('Variation Parameter');
      end

      subplot(o);                         % subplot complete
   end
end

   % legacy
   
function o = Margin(o)                 % Stability Margin              
   if type(o,{'spm'})
      o = cache(o,o,'multi');          % hard refresh multi cache segment
   end
   oo = with(o,{'process','stability'});
   L0 = cook(o,'Sys0');
   mu = opt(o,{'process.mu',0.1});
   
   subplot(o,211);
   stable(oo,L0,mu);
   
   subplot(o,212);
   stable(oo,L0,-mu);

   Heading(o);
end
function o = Damping(o)                % Closed Loop Damping           
   if type(o,{'spm'})
      o = cache(o,o,'multi');          % hard refresh cache segment
   end
   
   o = with(o,'rloc');
   o = with(o,'style');
   
   [L0,K0,f0,K180,f180] = cook(o,'Sys0,K0,f0,K180,f180');
   mu = opt(o,{'process.mu',0.1});
   L0 = inherit(L0,o);

   glim = [0 0.1; 0.1 1; 1 10; 10 inf];
   Klab = {'0.001->0.01->0.1', '0.1->0.2->0.5->1',...
           '1->2->5->10','10->100->1000'};
   m = size(glim,1);
   
   fmin = opt(o,{'fmin',1});
   fmax = opt(o,{'fmax',1e6});
   
   for (i=1:m)
      subplot(o,[m 2 i 1],'semilogx');
      rlocus(o,L0,-mu,glim(i,:));
      ylim = get(gca,'ylim');
      set(gca,'ylim',[min(-2,max(ylim(1),-20)),0]);
      set(gca,'xlim',[fmin,fmax]);
      
      title(sprintf('K: %s (mu: %g)',Klab{i},-mu));
      ylabel('damping [%]');
   end
   xlabel(sprintf('frequency [Hz] (K0: %g @ %g Hz)',K180/mu,f180));
   
   for (i=1:m)
      subplot(o,[m 2 i 2],'semilogx');
      rlocus(o,L0,mu,glim(i,:));
      ylim = get(gca,'ylim');
      set(gca,'ylim',[min(-2,max(ylim(1),-20)),0]);
      set(gca,'xlim',[fmin,fmax]);
      
      title(sprintf('K: %s (mu: %g)',Klab{i},+mu));
      ylabel('damping [%]');
   end
   xlabel(sprintf('frequency [Hz] (K0: %g @ %g Hz)',K0/mu,f0));
   
   Heading(o);
end
function o = OldDamping(o)             % Closed Loop Damping           
   o = with(o,'rloc');
   o = with(o,'style');
      
   subplot(o,111);

   L0 = cook(o,'Sys0');
   mu = opt(o,{'process.mu',0.1});
   L0 = inherit(L0,o);

   rlocus(o,L0,mu);
endfunction o = Rloc(o)                   % Root Locus                    
   o = with(o,'rloc');
   o = with(o,'style');
   
   sym = 'Sys0';
   oo = cook(o,sym);   
   
   mu = opt(o,{'process.mu',0.1});
   B0 = data(oo,'B');
   oo = data(oo,'B',B0*mu);
   
   oo = inherit(oo,o);
   
   subplot(o,111);
   rloc(oo);
   title(sprintf('Root Locus %s(s) - mu = %g',sym,mu));
   
   heading(o);
end
function o = OldRloc(o)                % Root Locus                    
   o = with(o,'rloc');
   o = with(o,'style');
   
   sym = 'L1';
   L1 = cook(o,sym);   
   [num,den] = peek(L1);
   
   mu = opt(o,{'process.mu',0.1});
   
   oo = system(inherit(corasim,o),{-mu*num,den});
   
   subplot(o,111);
   rloc(oo);
   title(sprintf('Root Locus %s(s) - mu = %g',sym,mu));
   
   heading(o);
end
function oo = StabilityOverview(o)     % Stability Overview            
   o = with(o,{'style','bode','nyq'});
   
   if type(o,{'spm'})
      o = cache(o,o,'multi');          % hard refresh multi segment
   end

   mu = opt(o,{'process.mu',0.1});
   colors = {'bcc','b','c','bw','cd'};
   
   [list,objs,head] = LmuSelect(o);
   for (i=1:length(list))
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);

      oo = inherit(objs{i},o);
      oo = opt(oo,'color',col);        % for bode plot
      if (i==length(list))
         oo = opt(oo,'critical',1);    % for bode plot
      end

      Lmu = list{i};
      Sys0 = var(Lmu,'Sys0');
      
      diagram(oo,'Magni','',Lmu,4211);
      xlabel('omega [1/s]');

      diagram(oo,'Phase','',Lmu,4221);
      xlabel('omega [1/s]');
      
      diagram(o,'Stability',+mu,Sys0,4231);
      diagram(o,'Stability',-mu,Sys0,4241);

      oo = diagram(o,'Nyq','',Lmu,1212);
   end
   
      % plot legend if more than 1 plots
      
   if (length(list) > 1)
      Legend(o,4211,objs);
   end
   
   Verbose(o,Lmu);   
   Heading(o,head);
end
function o = SimpleCalc(o)             % Simple Calculation            
   idx = contact(o,nan);
   if (length(idx) > 1)
      cls(o);
      message(o,'Simple Calculation works only for single contact!');
      return
   end

   message(o,'Simple Calculation of Stability Margin',{'see console ...'});
   idle(o);
   
   Cmd('[A,B_1,B_3,C_3]=cook(cuo,''A,B_1,B_3,C_3'');');
   Cmd('f=0.8:1e-4:1.1;   % search frequency between 0.8 and 1.1kHz');
   Cmd('jw=sqrt(-1)*2*pi*f;');
   Cmd('');
   Cmd('    % calculate G31(jw) and G33(jw)');
   Cmd('');
   Cmd('I=eye(size(A));   % unit matrix');
   Cmd('for(k=1:length(jw)) G31jw(k)=C_3*inv(jw(k)*I-A)*B_1; end');
   Cmd('for(k=1:length(jw)) G33jw(k)=C_3*inv(jw(k)*I-A)*B_3; end');
   Cmd('');
   Cmd('    % calculate phases phi31,phi33 and phi=phi31-phi33');
   Cmd('');
   Cmd('phi31=angle(G31jw);');
   Cmd('phi33=angle(G33jw);');
   Cmd('phi=mod(phi31-phi33,2*pi)-2*pi;');
   Cmd('');
   Cmd('    % find f0 where phi = -pi');
   Cmd('');
   Cmd('idx=min(find(phi<=-pi));');
   Cmd('f0=f(idx)             % critical frequency [kHz]');
   Cmd('M31=abs(G31jw(idx))   % coupling gain');
   Cmd('M33=abs(G33jw(idx))   % direct gain');
   Cmd('');
   Cmd('    % calculate critical friction coefficient mu');
   Cmd('');
   Cmd('K0=M33/M31');
   
   function Cmd(cmd)
      fprintf('%s\n',cmd);
      evalin('base',cmd);
   end
end
function [list,objs,head] = LmuSelect(o) % Select Transfer Function    
   list = {};                          % empty by default
   objs = {};
   head = heading(o);                  % default heading
   
   if type(o,{'spm'})
      list = {GetLmu(o)};
      objs = {o};
   elseif type(o,{'shell'})
      pivot = opt(o,'basket.pivot');
      if isempty(pivot)
         return
      end
      
      o = pull(o);                     % refresh shell object
      for (k=1:length(o.data))
         ok = o.data{k};
         ok = inherit(ok,o);
         if (type(ok,{'spm'}) && isequal(get(ok,'pivot'),pivot))
            list{end+1} = GetLmu(ok);
            objs{end+1} = ok;
         end
      end
      head = sprintf('Pivot: %g°',pivot);
   end
   
   function Lmu = GetLmu(o)
      [Lmu,Sys0,K0,K180,f0,f180] = cook(o,'Lmu,Sys0,K0,K180,f0,f180');
      Sys0 = var(Sys0,'f0,f180,K0,K180',f0,f180,K0,K180);
      Lmu = var(Lmu,'Sys0',Sys0);
   end
end

%==========================================================================
% Sensitivity
%==========================================================================

function o = SensitivityW(o)           % Weight Sensitivity            
%
% Idea:
%    - let L0(jw) be the nominal frequency response
%    - vary w(k) such that L0(jw) -> Lk(jw)
%    - build dL := L0(jw)-Lk(jw)
%    - Sensitivity S := |dL(jw)| / |L0(jw)|
%
   s = [];  modes = [];                % initialize 
   watch = false;                      % don't watch (try to set true!)

   col = o.iif(dark(o),'w.','k.');
   [L0,f0,W,psi,Lmu] = cook(o,'L0,f0,W,psi,Lmu');
   
   [om0,w0] = Omega(o);                % omega range and center frequency
   [~,~,dB0] = fqr(L0,om0);
   
      % get phi(om) next to om0
      
   phi0 = psion(L0,psi,om0);           % use L0 to provide oscale option!

   o = opt(o,'critical',1);
   diagram(o,'Bode','',L0,3211);
   semilogx(om0,dB0,o.iif(dark(o),'w.','k.'));
   title(sprintf('om0: %g 1/s (f: %g Hz)',w0,w0/2/pi));
   
      % sensitivity study
      
   m = size(psi,1);                    % number of modes
   [~,om] = fqr(with(L0,'bode'));      % get full omega range
   
      % get full range phi(om)
      
   phi = psion(L0,psi,om);             % use L0 to provide oscale option!

      % plot psion calculated frequency response

   L0jw = [W{3,1}*phi] ./ [W{3,3}*phi];
   L0jw0 = [W{3,1}*phi0] ./ [W{3,3}*phi0];

   PlotL0(o,3221);
   PlotV(o,3221);                      % plot variation
   PlotS(o,3231);
   
   [~,idx] = sort(-s);                 % sort from largest to smallest
   for (k=1:5)
      PlotL0(o,[5,3,k,3]);
      PlotE(o,[5,3,k,3],idx(k));
      diagram(o,'Nyq','',Lmu,[5,6,k,4]);
   end
   
   heading(o);
   
   function PlotL0(o,sub)              % Plot L0 (Psion Based)         
      subplot(o,sub);
      hdl = semilogx(om,20*log10(abs(L0jw)),'b');
      o.color(hdl,'ryyyyy');
      set(hdl,'linewidth',1);
      semilogx(om0,20*log10(abs(L0jw0)),col);
      hold on;
      subplot(o);
   end
   function PlotS(o,sub)               % Plot Sensitivity              
      subplot(o,sub);
      plot(o,1:m,s,[col,'|'], 1:m,s,'ro');
      title('Weight Sensitivity');
      title('Weight Sensitivity @ Mode Number');
      xlabel('omega [1/s]');
      subplot(o);
   end
   function PlotV(o,sub)               % plot Variation                
      subplot(o,sub);
      for (i=1:m)
         w31 = W{3,1};  w31(i) = 0;
         w33 = W{3,3};  w33(i) = 0;

         Gjw = [w31*phi] ./ [w33*phi];    % full omega range
         Gjw0 = [w31*phi0] ./ [w33*phi0]; % omega range next to om0

            % sensitivity function

         Sjw0 = (Gjw0./L0jw0) - 1;
         S(i) = max(20*log10(abs(Sjw0))); % store max dB value of sensitivity
         mode = sqrt(psi(i,3))/oscale(o); % mode omega
         modes(i) = mode;

         if (watch)
            hdl0 = semilogx(om0,20*log10(abs(Gjw0)),'r.');
            hdl1 = semilogx(om,20*log10(abs(Gjw)),'r');
            hdl2 = semilogx(om,20*log10(abs(Gjw./L0jw)),'c');
            hdl3 = semilogx(om0,20*log10(abs(Sjw0)),col);
            hdl4 = semilogx([mode mode],get(gca,'ylim'),'c');
            title(sprintf('mode #%g',i));
            idle(o);
            delete([hdl0 hdl1,hdl2,hdl3,hdl4]);
         end
         
         if (rem(i-1,10) == 0)
            progress(o,'analysing sensitivity',(i-1)/m*100);
         end
      end
      progress(o);
      
      S0 = max(S) - 20;
      s = S - S0;                    % delta sensitivity [dB]
      
      idx = find(s >= -20);
      plot(o,modes(idx),s(idx),[col,'|'], modes(idx),s(idx),'ro');
      for (k=1:length(idx))
         hdl = text(modes(idx(k)),s(idx(k)),sprintf('#%g',idx(k)));
         set(hdl,'horizontal','center','vertical','top');
         set(hdl,'color',o.iif(dark(o),1,0)*[1 1 1]);
      end

      h = semilogx([w0 w0],get(gca,'ylim'),'r-.');
      set(h,'linewidth',1);
      title('Weight Sensitivity @ Frequency');
      subplot(o);
   end
   function PlotE(o,sub,i)             % plot Example                  
      subplot(o,sub);
      w31 = W{3,1};  w31(i) = 0;
      w33 = W{3,3};  w33(i) = 0;

      Gjw = [w31*phi] ./ [w33*phi];    % full omega range
      Gjw0 = [w31*phi0] ./ [w33*phi0]; % omega range next to om0

         % sensitivity function

      Sjw0 = 1 - (Gjw0./L0jw0);
      mode = modes(i);                 % mode omega

      hdl = semilogx(om,20*log10(abs(Gjw)),'r');
      hold on
      hdl = semilogx(om,20*log10(abs(Gjw./L0jw)),'c');
      set(hdl,'linewidth',1);
      title(sprintf('Mode #%g, Omega: %g 1/s (%g Hz), Sensitivity: %g dB',...
                i,o.rd(modes(i),0),o.rd(modes(i)/2/pi,0),o.rd(s(i),1)));

      subplot(o);
      h = semilogx([w0 w0],get(gca,'ylim'),'r-.');
      set(h,'linewidth',1);
      h = semilogx([modes(i),modes(i)],get(gca,'ylim'),'c-.');
      set(h,'linewidth',1);
   end
end

function o = Contribution(o)           % Modal Contribution            
%
% Idea: 
%    - let L0(jw) be the nominal frequency response
%    - vary w(k) such that L0(jw) -> Lk(jw)
%    - build dL := L0(jw)-Lk(jw)
%    - Sensitivity S := |dL(jw)| / |L0(jw)|

   if ~type(o,{'spm'})
      plot(o,'About');
      return;
   end
      
   [L0,f0] = cook(o,'L0,f0');
   
   oscale = opt(L0,{'oscale',1});
   om0 = 2*pi*f0;
   
   Ljw = fqr(L0,om0);
   dB = 20*log10(abs(Ljw));
   
   o = opt(o,'critical',1);
   diagram(o,'Bode','',L0,211);
   semilogx(om0,dB,o.iif(dark(o),'wo','ko'));
   
   title(sprintf('om0: %g',om0));
   
   Vary(o);
   heading(o);
   
   function dB = Calculate(o)
   %
   % Calculation to perform is:
   %
   %    L0(jw0) = G31(jw0)/G33(jw0)
   %
   % with psii(s) := s^2 + a1_i*s + a0_i*s
   %
   %    G31(s) = w31(1)/psi1(s) + w31(2)/psi2(s) + ... + w31(n)*psin(s)
   %    G33(s) = w33(1)/psi1(s) + w33(2)/psi2(s) + ... + w33(n)*psin(s)
   %
   % let
   %
   %    phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
   %
   % then
   %
   %                w31' * phi(jw0)
   %    L0(jw0) = -------------------
   %                w33' * phi(jw0)
   %
      [W,psi] = cook(o,'W,psi');       % weights and modal parameters
      w31T = W{3,1};
      w33T = W{3,3};
      
%L0 = opt(L0,'omega.points',opt(L0,'bode.omega.points'));
[Ljw,omega]=fqr(L0); 
Om0=omega*oscale;

      phi = psion(L0,psi,om0);         % modal frequency response
      L0jw0 = (w31T*phi) ./ (w33T*phi); % L0(jw0)
      
      dB = 20*log10(abs(L0jw0));
      
%hold on;
%semilogx(omega,dB,'r'); 
   end
   function Vary(o)
   %
   % Calculation to perform is:
   %
   %    L0(jw0) = G31(jw0)/G33(jw0)
   %
   % with psii(s) := s^2 + a1_i*s + a0_i*s
   %
   %    G31(s) = w31(1)/psi1(s) + w31(2)/psi2(s) + ... + w31(n)*psin(s)
   %    G33(s) = w33(1)/psi1(s) + w33(2)/psi2(s) + ... + w33(n)*psin(s)
   %
   % let
   %
   %    phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
   %
   % then
   %
   %                w31' * phi(jw0)
   %    L0(jw0) = -------------------
   %                w33' * phi(jw0)
   %
      [W,psi] = cook(o,'W,psi');            % weights and modal parameters
      w31T = W{3,1};
      w33T = W{3,3};
      m = length(w31T);
      dB0 = zeros(1,m);
      
      [Ljw,om]=fqr(L0); 

      phi = psion(L0,psi,om);               % modal frequency response
      phi0 = psion(L0,psi,om0);             % modal frequency response

      L0jw = (w31T*phi) ./ (w33T*phi);      % L0(jw)
      L0jw0 = (w31T*phi0) ./ (w33T*phi0);   % L0(jw0)
      
      hold on;
      for (k=1:m)
         w31kT = w31T;  w31kT(k) = 0.5*w31kT(k);  
         w33kT = w33T;  w33kT(k) = 2*w33kT(k);  
         
         L0jwk = (w31kT*phi) ./ (w33kT*phi); 
         ratio = ((w31kT*phi0) ./ (w33kT*phi0)) ./ L0jw0; 
         
         
         dB = 20*log10(abs(L0jwk));
         dB0(k) = 20*log10(abs(ratio));

         subplot(o,211);
         hdl = semilogx(om,dB,'r');
         
         subplot(o,212);
         plot(o,1:k,dB0(1:k),'ro|');
         set(gca,'xlim',[0 m]);
         subplot(o);

         delete(hdl);
      end
   end
end
function o = NumericCheck(o)           % Numerical Check               
   if ~type(o,{'spm'})
      plot(o,'About');
      return;
   end
      
   [L0,f0] = cook(o,'L0,f0');
   
   oscale = opt(L0,{'oscale',1});
   om0 = 2*pi*f0;
   Om0 = om0*oscale;                   % scaled omega
   
   Ljw = fqr(L0,Om0);
   dB = 20*log10(abs(Ljw));
   
   o = opt(o,'critical',1);
   diagram(o,'Bode','',L0,1111);
   semilogx(om0,dB,o.iif(dark(o),'wo','ko'));
   
   title(sprintf('om0: %g',om0));
   
   dB = Calculate(o);
   heading(o);
   
   function dB = Calculate(o)
   %
   % Calculation to perform is:
   %
   %    L0(jw0) = G31(jw0)/G33(jw0)
   %
   % with psii(s) := s^2 + a1_i*s + a0_i*s
   %
   %    G31(s) = w31(1)/psi1(s) + w31(2)/psi2(s) + ... + w31(n)*psin(s)
   %    G33(s) = w33(1)/psi1(s) + w33(2)/psi2(s) + ... + w33(n)*psin(s)
   %
   % let
   %
   %    phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
   %
   % then
   %
   %                w31' * phi(jw0)
   %    L0(jw0) = -------------------
   %                w33' * phi(jw0)
   %
      [W,psi] = cook(o,'W,psi');       % weights and modal parameters
      w31T = W{3,1};
      w33T = W{3,3};
      
%     L0 = opt(L0,'omega.points',opt(L0,'bode.omega.points'));
      [Ljw,omega]=fqr(L0); 
      Om0=omega*oscale;

      phi = psion(L0,psi,omega);       % modal frequency response
      L0jw0 = (w31T*phi) ./ (w33T*phi); % L0(jw0)
      
      dB = 20*log10(abs(L0jw0));
      
      hold on;
      semilogx(omega,dB,'r'); 
   end
end

%==========================================================================
% Open Loop
%==========================================================================

function o = OpenLoop(o)               % L(s) Open Loop                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   o = with(o,{'bode','simu','rloc'});

   sym = arg(o,1);
   idx = arg(o,2);
   
   oo = cook(o,sym);
   
   if (idx == 0)
      diagram(o,'Trf','',oo,111);
   else
      title = [sym,': Open Loop Transfer Function'];
      diagram(o,'Trf', '',oo,3111,title);
      diagram(o,'Step','',oo,3221);
      diagram(o,'Rloc','',oo,3222);
      diagram(o,'Bode','',oo,3231);
      diagram(o,'Nyq','',oo,3232);
   end
   
   Verbose(o,oo);   
   heading(o);
end
function o = Calc(o)                   % Calculation of L(s)           
   sym = arg(o,1);
   idx = arg(o,2);
   col = arg(o,3);
   
   G31 = cook(o,'G31');
   G33 = cook(o,'G33');
   L0 = cook(o,'L0');
   
   diagram(o,'Calc','L0(s)',L0,4312);

   diagram(o,'Bode','',G31,4321);
   diagram(o,'Step','',G31,4322);
   diagram(o,'Rloc','',G31,4323);

   diagram(o,'Bode','',G33,4331);
   diagram(o,'Step','',G33,4332);
   diagram(o,'Rloc','',G33,4333);
   
   diagram(o,'Bode','',L0,4441);
   diagram(o,'Step','',L0,4342);
   diagram(o,'Rloc','',L0,4343);
           
   heading(o);
end

function o = LmuDisp(o)                % Display Transfer Function     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');   
   diagram(o,'Trf','',Lmu,1111);      
   
   Verbose(o,Lmu);
   heading(o);
end
function o = LmuRloc(o)                % Poles/Zeros of Lmu(s)         
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Rloc','',Lmu,1111);  
   
   heading(o);
end
function o = LmuStep(o)                % Step Response Plot            
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Step','',Lmu,1111);  
   
   heading(o);
end
function o = LmuBode(o)                % Bode Plot                     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Magni','',Lmu,2111);      
   diagram(o,'Phase','',Lmu,2121);      
   
   heading(o);
end
function o = LmuNyq(o)                 % Nyquist Plot                  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Nyq','',Lmu,1111);      

   heading(o);
end
function o = LmuBodeNyq(o)             % Bode/Nyquist Plot             
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Bode','',Lmu,1211);      
   diagram(o,'Nyq','',Lmu,1212);      


   heading(o);
end

%==========================================================================
% Closed Loop
%==========================================================================

function o = BodePlots(o)              % Closed Loop Bode Plots        
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
function o = StepPlots(o)              % Closed Loop Step Plots        
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
   diagram(o,'Vstep','Tv1(s)',Tv1,4231);
   diagram(o,'Vstep','Tv2(s)',Tv2,4232);
   
   
   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   o = opt(o,'color','r');
   diagram(o,'Astep','Ta1(s)',Ta1,4241);
   diagram(o,'Astep','Ta2(s)',Ta2,4242);
   
   heading(o);
end
function o = PolesZeros(o)             % Closed Loop Poles & Zeros     
   o = with(o,'simu');
   
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   o = opt(o,'color','yyr');
   diagram(o,'Rloc','Tf1(s)',Tf1,4211);
   diagram(o,'Rloc','Tf2(s)',Tf2,4212);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   o = opt(o,'color','g');
   diagram(o,'Rloc','Ts1(s)',Ts1,4221);
   diagram(o,'Rloc','Ts2(s)',Ts2,4222);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   o = opt(o,'color','bc');
   diagram(o,'Rloc','Tv1(s)',Tv1,4231);
   diagram(o,'Rloc','Tv2(s)',Tv2,4232);
   
   
   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   o = opt(o,'color','r');
   diagram(o,'Rloc','Ta1(s)',Ta1,4241);
   diagram(o,'Rloc','Ta2(s)',Ta2,4242);
   
   heading(o);
end

%==========================================================================
% Closed Loop Force
%==========================================================================

function o = Overview(o)               % Closed Loop Overview          
   o = with(o,'bode');
   o = with(o,'simu');
   o = with(o,'rloc');
   
   sym1 = arg(o,1)
   sym2 = arg(o,2)
   col = arg(o,3);

   o = opt(o,'color',col);
   o1 = cook(o,sym1);
   o2 = cook(o,sym2);
   
   sym1 = [sym1,'(s)'];
   sym2 = [sym2,'(s)'];
   
   diagram(o,'Bode',sym1,o1,3211);
   diagram(o,'Bode',sym2,o2,3212);

   diagram(o,'Fstep',sym1,o1,3221);
   diagram(o,'Fstep',sym2,o2,3222);

   diagram(o,'Rloc',sym1,o1,3231);
   diagram(o,'Rloc',sym2,o2,3232);

   heading(o);
end
function o = Trf(o)                    % Transfer Function             
   o = with(o,'bode');
   o = with(o,'simu');
   o = with(o,'rloc');

   sym = arg(o,1);
   idx = arg(o,2);
   col = arg(o,3);
   
   oo = cook(o,sym);
   o = opt(o,'color',col);
   sym = [sym,'(s)'];
   oo = set(oo,'name',sym);
   
   if (idx == 0)
      diagram(o,'Trf',sym,oo,111);
   else
      diagram(o,'Trf', sym,oo,3111);
      diagram(o,'Bode',sym,oo,3221);
      diagram(o,'Rloc',sym,oo,3222);
      diagram(o,'Step',sym,oo,3131);
   end
   
   display(oo);
   heading(o);
end

%==========================================================================
% Normalized System
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
% Spectrum
%==========================================================================

function o = L0Magni(o)                % L0(i,j) Magnitude Plots       
   if type(o,{'spm'})
      o = cache(o,o,'multi');
      o = cache(o,o,'spectral');
   end
   o = with(o,'bode');
   %o = opt(o,'critical',1);
   
   L0jw = cook(o,'L0jw');
   [~,m,n] = size(L0jw);
   
   Ylim = [+inf,-inf];
   for (i=1:m)
      for(j=1:n)
         Lij = peek(L0jw,i,j);
         Lij = set(Lij,'name',sprintf('L0[%g,%g](s)',i,j));
         diagram(o,'Magni','',Lij,[m,n,i,j]);
         ylim = get(gca,'ylim');
         Ylim(1) = min(Ylim(1),ylim(1));
         Ylim(2) = max(Ylim(2),ylim(2));
      end
   end
   
      % set same y-limits for all plots
      
   [K0,f0,K180,f180] = cook(o,'K0,f0,K180,f180');
   for (i=1:m)
      for(j=1:n)
         subplot(o,[m,n,i,j]);
         set(gca,'ylim',Ylim);
         hdl1 = semilogx(2*pi*f0*[1 1],Ylim,'r-.');
         hdl2 = semilogx(2*pi*f180*[1 1],Ylim,'m-.');
         set([hdl1,hdl2],'linewidth',1);
      end
   end
   
   heading(o);
end
function o = LambdaMagni(o)
   if type(o,{'spm'})
      o = cache(o,o,'spectral');
   end
   o = with(o,'bode');
   
   lambda = cook(o,'lambda');
   [~,m,n] = size(lambda);
   m = m*n;
   
   for (i=1:m)
      lambdai = peek(lambda,i);
      lambdai = set(lambdai,'name',sprintf('lambda[%g](s)',i));
      if (i==1)
         lambdai = set(lambdai,'name',sprintf('Lambda[%g](s)',i));
      end
      diagram(o,'Magni','',lambdai,111);
      hold on
   end
   
   heading(o);
end
function o = LambdaMagni2(o)
   if type(o,{'spm'})
      o = cache(o,o,'spectral');
   end
   o = with(o,'bode');
   
   lambda = cook(o,'lambda');
   [~,m,n] = size(lambda);
   m = m*n;
   
   for (i=1:m)
      lambdai = peek(lambda,i);
      lambdai = set(lambdai,'name',sprintf('lambda[%g](s)',i));
      diagram(o,'Magni','',lambdai,[m,1,i,1]);
   end
   
   heading(o);
end
function o = LambdaBode(o)
   if type(o,{'spm'})
      o = cache(o,o,'spectral');
   end
   o = with(o,'bode');
   o = opt(o,'critical',1);
   
   lambda = cook(o,'lambda');
   [~,m,n] = size(lambda);
   m = 1;
   
   for (i=1:m)
      lambdai = peek(lambda,i);
      lambdai = set(lambdai,'name',sprintf('lambda[%g](s)',i));
      if (i==1)
         lambdai = set(lambdai,'name',sprintf('Lambda[%g](s)',i));
      end
      lambdai = opt(lambdai,'color','ry');
      diagram(o,'Magni','',lambdai,211);
      
      [K0,f0,K180,f180] = cook(o,'K0,f0,K180,f180');
      col = o.iif(dark(o),'wo','ko');
      hdl = semilogx(2*pi*f0,20*log10([1/K0]),col);
      xlabel(sprintf('K0: %g @ omega: %g 1/s (f: %g Hz)',o.rd(K0,4),...
             o.rd(2*pi*f0,0),o.rd(f0,1)));
      
      diagram(o,'Phase','',lambdai,212);
      xlabel('omega [1/s]');
      hold on
   end
   
   heading(o);
end

%==========================================================================
% Setup
%==========================================================================

function o = SetupAnalysis(o)          % Setup Margin Analysis          
   switch o.type
      case 'shell'
         o = plot(o,'About');
      case 'pkg'
         o = PkgSetupAnalysis(o);
      case 'spm'
         o = SpmSetupAnalysis(o);
   end
end
function o = PkgSetupAnalysis(o)       % Setup Specific Stability Margin
   if ~type(o,{'pkg'})
      plot(o,'About');
      return
   end
   
   flip = 1;
   
   package = get(o,'package');
   if isempty(package)
      error('no package ID provided');
   end
   variation = get(o,'variation');
      
      % get object list of package
      % note that first list element is the package object, which has 
      % to been deleted. calculate stability margin for all data objects
    
%  olist = tree(o);                    % get list of package objects
%  list = olist{1};                    % pick object list
%  list(1) = [];                       % delete package object from list

   o = with(o,{'style','process','stability','critical'});

   [list,m] = children(o);             % get list of package's data objects
   if (m == 0)
      message(o,'No SPM object in selected package');
      return
   end

      % ...
      
   mode = arg(o,1);
   
   C = cook(list{1},'C');
   no = size(C,1)/3;
   n = 2^no-1;
   
   id = Order(no,mode);
   N = length(id);
   x = 1:N;
   
   %[K0K180,f0f180] = cook(o,'K0K180,f0f180');

   height = [];                         % let calculate by Axes
   mu = opt(o,{'process.mu',0.1});
   
   if (flip)
      Axes2(o,1311,mu,'Stability Margin'); % get variation range and plot axes
      Axes2(o,1714,[],'Setup');
      Axes2(o,1313,-mu,'Stability Margin'); % get variation range and plot axes
   else
      Axes1(o,3111,mu,'Stability Margin'); % get variation range and plot axes
      Axes1(o,3121,[],'Setup');
      Axes1(o,3131,-mu,'Stability Margin'); % get variation range and plot axes
   end

      % calculate stability margin and plot
   
   infgreen = o.iif(dark(o),'g|p3','ggk|p3');
   green = o.iif(dark(o),'g|o3','ggk|o3');
   red = 'r|o2';

      % plot configurations
      
   for (j=1:N)                         % calc & plot stability margin  
      i = id(j); 
      cfg = Config(i);
      PlotConfig(o,x(j),cfg,id(j),o.iif(flip,1714,3121));
   end
   
   stop(o,'Enable');                   % enable stop button down function
   for (ii=1:length(list))
      oi = list{ii};
      vi = get(oi,variation);
      [K0K180,f0f180] = cook(oi,'K0K180,f0f180');
      
      fmin = inf;                      % init
      progress(o,N,'calculate stability range');
      for (j=1:N)                      % calc & plot stability margin  
         txt = sprintf('calculate stability range of %s',get(o,'title'));
         progress(o,j);

         i = id(j); 
         cfg = Config(i);
         if isnan(K0K180(i,1))
            [oo,L0,K0,f0,K180,f180] = contact(oi,cfg);
            K0K180(i,:) = [K0,K180];
            f0f180(i,:) = [f0,f180];

            oi = cache(oi,'setup.K0K180',K0K180);
            oi = cache(oi,'setup.f0f180',f0f180);
            cache(oi,oi);
         else
            K0 = K0K180(i,1);  K180 = K0K180(i,2);
            f0 = f0f180(i,1);  f180 = f0f180(i,2);
         end

         Mu0 = mu/K0;  Mu180 = mu/K180;
         if (flip)
            PlotMargin(o,x(j),vi,1/Mu0,1311);      
            PlotMargin(o,x(j),vi,1/Mu180,1313);  
         else
            PlotMargin(o,x(j),vi,1/Mu0,3111);      
            PlotMargin(o,x(j),vi,1/Mu180,3131);  
         end

         idle(o);                         % show graphics
         if stop(o)
            break;
         end
      end
      if stop(o)
         break;
      end
   end
   stop(o,'Disable');                  % enable stop button down function
   
   if (flip)
      subplot(o,1311);
      pos = get(gca,'position');
      width = pos(3);
      set(gca,'position',[pos(1:2) 1.45*width pos(4)]);

      subplot(o,1313);
      pos = get(gca,'position');
      width = pos(3);
      set(gca,'position',[pos(1)-0.45*width pos(2) 1.45*width pos(4)]);
   end
   
   progress(o);                        % progress completed
   Heading(o);                         % add heading
   
   function idx = Config(N)            % Return Configuration Indices
      kmax = log(n+1)/log(2);
      idx = [];
      for (k=1:kmax)
         if (rem(N,2) == 1)
            idx(end+1) = k;
         end
         N = floor(N/2);
      end
   end
   function PlotMargin(o,xi,yi,marg,sub)
      subplot(o,sub);
      [fcol,bcol,ratio] = Colors(o,marg);
      X = 0.4*[1 1 -1 -1 1];
      Y = 0.4*height*[1 -1 -1 1 1];
      
      if isinf(marg)
         if (flip)
%           plot(o,0,xi,infgreen);
            patch(yi+Y,xi+X,o.color('gw'));
            plot(o,yi,xi,'kp');
         else
%           plot(o,xi,0,infgreen);
            patch(xi+X,yi+Y,o.color('gw'));
            plot(o,xi,yi,'kp');
         end
      else
         if (flip)
            patch(yi+Y,xi+X,o.color(fcol));
            patch(yi+ratio*Y,xi+ratio*X,o.color(bcol));
         else
            patch(xi+X,yi+Y,o.color(fcol));
            patch(xi+ratio*X,yi+ratio*Y,o.color(bcol));
         end
      end
   end   
   function PlotConfig(o,xi,cfg,id,sub)
      col = o.iif(dark(o),'w','k');
      
      subplot(o,sub);
      for (k=1:no)
         if (flip)
            plot(o,[1 no],[xi xi],[col,'1']);
         else
            plot(o,[xi xi],[1 no],[col,'1']);
         end
         
         if any(cfg==k)
            if (flip)
               plot(o,k,xi,[col,'o']);
            else
               plot(o,xi,k,[col,'o']);
            end
         end
         hold on
      end
      if (flip)
         hdl = text(no+0.6,xi,sprintf('%g',id));
         set(hdl,'Vertical','mid','Horizontal','center','fontsize',6);
      else
         hdl = text(xi,no+0.3,sprintf('%g',id));
         set(hdl,'Vertical','bottom','Horizontal','center','fontsize',6);
      end
   end
   function Axes1(o,sub,mu,tit)        % Plot Axes                     
      subplot(o,sub);
      
      if isempty(mu)
         for (k=1:no)
            plot(o,x,k*ones(size(x)),'K.');
            hold on;
         end
         set(gca,'ylim',[0 no+0.9]);
      else
         v = [];
         for (k=1:length(list))
            v(k) = get(list{k},variation);
         end
         
         plot(o,x,0*x,'K.');
         hold on;
         
         height = (max(v)-min(v)) / max(1,length(list)-1);
         set(gca,'ylim',[min(v)-2*height,max(v)+2*height]);
      end
      
      title(sprintf('%s%s',tit,More(o,mu)));

      if ~isempty(mu)
         ylabel(sprintf('%s @ mu: %g',tit,mu));
      elseif isempty(mu)
         ylabel('configuration')
      end
      xlabel('Setup ID');
      set(gca,'xlim',[0.1 length(x)+0.9]);
      subplot(o);                      % subplot complete
   end
   function Axes2(o,sub,mu,tit)        % Plot Axes                     
      subplot(o,sub);
      
      if isempty(mu)
         for (k=1:no)
            plot(o,k*ones(size(x)),x,'K.');
            hold on;
         end
         
         set(gca,'xlim',[0 no+0.9]);
      else
         v = [];
         for (k=1:length(list))
            v(k) = get(list{k},variation);
         end
         
         plot(o,0*x,x,'K.');
         hold on;
         
         height = (max(v)-min(v)) / max(1,length(list)-1);
         set(gca,'xlim',[min(v)-2*height,max(v)+2*height]);
      end
      
      title(sprintf('%s%s',tit,More(o,mu)));

      if ~isempty(mu)
         xlabel(sprintf('variation: %s',variation));
      elseif isempty(mu)
         xlabel('configuration')
      end
      ylabel('Setup ID');
      set(gca,'ylim',[0.1 length(x)+0.9]);
      subplot(o);                      % subplot complete
   end
   function txt = More(o,mu)           % More Title Text               
      txt = '';  sep = '';

      if isempty(mu)
         return
      else
         txt = sprintf('mu: %g',mu);  
         sep = ', ';
      end
      
      vomega = opt(o,{'variation.omega',1});
      if ~isequal(vomega,1)
         txt = [txt,sep,sprintf('vomega: %g',vomega)]; 
         sep = ', ';
      end
      
      vzeta = opt(o,{'variation.zeta',1});
      if ~isequal(vzeta,1)
         txt = [txt,sep,sprintf('vzeta: %g',vzeta)];
         sep = ', ';
      end
      
      if ~isempty(txt)
         txt = [' (',txt,')'];
      end
   end
   function id = OldOrder(no,mode)
      if (no == 5 && isequal(mode,'symmetry'))
         id = [31 27 23 15 [7 [13 11 19 21 14] 5 3 [6 1 2 [9 17] 10 4 10 ...
              [17 18] 8 16 12] 24 20 [14 21 25 26  22] 28] 30 29 27 31];
      else
         id = 1:(2^no-1);
      end
   end
end
function o = SpmSetupAnalysis(o)       % Setup Specific Stability Margin
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Heading(o);                         % stat with heading

   o = with(o,{'style','process','stability','critical'});
   mode = arg(o,1);
   
   C = cook(o,'C');
   no = size(C,1)/3;
   n = 2^no-1;
   
   id = Order(no,mode);
   N = length(id);
   x = 1:N;
   
   [K0K180,f0f180] = cook(o,'K0K180,f0f180');

   mu = opt(o,{'process.mu',0.1});
   Axes(o,4211,mu,'Stability Range');  % get variation range and plot axes
   Axes(o,4221,[],'Setup');
   Axes(o,4231,mu,'Stability Margin'); % get variation range and plot axes
   Axes(o,4241,nan,'Critical Frequency');

   Axes(o,4212,-mu,'Stability Range'); % get variation range and plot axes
   Axes(o,4222,[],'Setup');
   Axes(o,4232,-mu,'Stability Margin');% get variation range and plot axes
   Axes(o,4242,nan,'Critical Frequency');
  
      % calculate stability margin and plot
   
   infgreen = o.iif(dark(o),'g|p3','ggk|p3');
   green = o.iif(dark(o),'g|o3','ggk|o3');
   red = 'r|o2';
   
   stop(o,'Enable');                % enable button down function for stop
   fmin = inf;                      % init
   
   for (j=1:N)                      % calc & plot stability margin  
      txt = sprintf('calculate stability range of %s',get(o,'title'));
      progress(o,txt,j/N*100);
      
      i = id(j); 
      cfg = Config(i);
      if isnan(K0K180(i,1))
         [oo,L0,K0,f0,K180,f180] = contact(o,cfg);
         K0K180(i,:) = [K0,K180];
         f0f180(i,:) = [f0,f180];
         
         o = cache(o,'setup.K0K180',K0K180);
         o = cache(o,'setup.f0f180',f0f180);
         cache(o,o);
      else
         K0 = K0K180(i,1);  K180 = K0K180(i,2);
         f0 = f0f180(i,1);  f180 = f0f180(i,2);
      end
      
      Mu0 = mu/K0;
      PlotMu(o,x(j),Mu0,4211);
      PlotConfig(o,x(j),cfg,id(j),4221);
      PlotMargin(o,x(j),1/Mu0,4231);      
      PlotFrequency(o,x(j),f0,4241);      
      

      Mu180 = mu/K180;
      PlotMu(o,x(j),Mu180,4212);
      PlotConfig(o,x(j),cfg,id(j),4222);
      PlotMargin(o,x(j),1/Mu180,4232);
      PlotFrequency(o,x(j),f180,4242);      
      
      idle(o);                         % show graphics
      if stop(o)
         break;
      end
   end
   stop(o,'Disable');                  % disable button down func. for stop

   progress(o);                        % progress completed
   Heading(o);                         % add heading
   
   function idx = Config(N)            % Return Configuration Indices
      kmax = log(n+1)/log(2);
      idx = [];
      for (k=1:kmax)
         if (rem(N,2) == 1)
            idx(end+1) = k;
         end
         N = floor(N/2);
      end
   end
   function PlotMu(o,xi,mu,sub)
      subplot(o,sub);
      [fcol,bcol,ratio] = Colors(o,1/mu);
      X =  0.4*[1 1 -1 -1 1];
      Y = mu/2*[1 -1 -1 1 1];
      
      hdl = patch(xi+X,mu/2+Y,o.color(fcol));
      hdl = patch(xi+ratio*X,mu/2+Y,o.color(bcol));
   end
   function PlotMargin(o,xi,marg,sub)
      subplot(o,sub);
      [fcol,bcol,ratio] = Colors(o,marg);
      X =  0.4*[1 1 -1 -1 1];
      Y = marg/2*[1 -1 -1 1 1];
      
      if isinf(marg)
         plot(o,xi,0,infgreen);
      else
         patch(xi+X,marg/2+Y,o.color(fcol));
         patch(xi+ratio*X,marg/2+Y,o.color(bcol));
%        plot(o,xi,marg,green);
      end
   end   
   function PlotFrequency(o,xi,f0,sub)
      col = o.iif(dark(o),'w|o','k|o');
      subplot(o,sub);
      plot(o,xi,f0,col);
      hold on
      fmin = min(fmin,f0);
      set(gca,'xlim',[0.1 length(x)+0.9],'ylim',[fmin*0.95,inf]);
   end   
   function PlotConfig(o,xi,cfg,id,sub)
      col = o.iif(dark(o),'w','k');
      
      subplot(o,sub);
      for (k=1:no)
         plot(o,[xi xi],[1 no],[col,'1']);
         if any(cfg==k)
            plot(o,xi,k,[col,'o']);
         end
         hold on
      end
      hdl = text(xi,no+0.3,sprintf('%g',id));
      set(hdl,'Vertical','bottom','Horizontal','center','fontsize',6);
   end
   function Axes(o,sub,mu,tit)         % Plot Axes                     
      subplot(o,sub);
      
      if isempty(mu)
         for (k=1:no)
            plot(o,x,k*ones(size(x)),'K.');
            hold on;
         end
         set(gca,'ylim',[0 no+0.9]);
      elseif isnan(mu)
         %plot(o,x,0*x,'K.');
         set(gca,'ylim',[0 no+0.9]);
      else
         plot(o,x,0*x,'K.');
         hold on;
         plot(o,get(gca,'xlim'),[1 1],'K-.2');
      end
      
      title(sprintf('%s%s',tit,More(o,mu)));

      if ~isempty(mu) && ~isnan(mu)
         ylabel(sprintf('%s @ mu: %g',tit,mu));
      elseif isempty(mu)
         ylabel('configuration')
      else
         ylabel('frequency [Hz]');
      end
      xlabel('Setup ID');
      set(gca,'xlim',[0.1 length(x)+0.9]);
      subplot(o);                      % subplot complete
   end
   function txt = More(o,mu)           % More Title Text               
      txt = '';  sep = '';

      if isempty(mu)
         return
      else
         txt = sprintf('mu: %g',mu);  
         sep = ', ';
      end
      
      vomega = opt(o,{'variation.omega',1});
      if ~isequal(vomega,1)
         txt = [txt,sep,sprintf('vomega: %g',vomega)]; 
         sep = ', ';
      end
      
      vzeta = opt(o,{'variation.zeta',1});
      if ~isequal(vzeta,1)
         txt = [txt,sep,sprintf('vzeta: %g',vzeta)];
         sep = ', ';
      end
      
      if ~isempty(txt)
         txt = [' (',txt,')'];
      end
   end
end

   % local helper
   
function id = Order(no,mode)
   if (no == 5 && isequal(mode,'symmetry'))
      id = [31 27 23 15 [7 [13 11 19 21 14] 5 3 [6 1 2 [9 17] 10 4 10 ...
           [17 18] 8 16 12] 24 20 [14 21 25 26  22] 28] 30 29 27 31];
   elseif (no == 7 && isequal(mode,'symmetry'))
      id = [127 107 73 63 [31 15  [7 14 28],[12 6 3]  [1 2 [] 4 8 16 [] 32 64]  [96 48 24],[28 56 112] 120 124] 126 73 107 127];

   elseif (no == 5 && isequal(mode,'sample'))
      id = [31 [7 [14] [1 2 []  4  [] 8 16] [14] 28] 31];
   elseif (no == 7 && isequal(mode,'sample'))
      id = [127 107 63 [15 [14 28] [1 2 []  8  [] 32 64] [28 56] 120] 126 107 127];
   else
      id = 1:(2^no-1);
   end
end

%==========================================================================
% Numeric Quality
%==========================================================================

function o = Numeric(o)                % G(s) Numeric FQR Quality Check
   [G,psi,W] = cook(o,'G,psi,W');      % G(s), modal param's, weights
   [m,n] = size(G);

   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         wij = W{i,j};
         diagram(o,'Numeric',{psi,wij},Gij,[m,n,i,j]);
      end
   end
   heading(o);
end

%==========================================================================
% Checks
%==========================================================================

function o = EigenvalueCheck(o)        % Check Numeric Quality of EVs  
   [a0,a1,A] = cook(o,'a0,a1,A');
      
   if Vpa(o)                           % use variable precision arithmetic?
      a1 = vpa(a1);  a0 = vpa(a0);
      
      s1 = -a1/2 + sqrt(a1.*a1-a0);
      s2 = -a1/2 - sqrt(a1.*a1-a0);
      sm = [s1(:);s2(:)];                 % EVs from modal form
      
      A = vpa(A);                      % convert matrix to MPA
      eps = 1e-30;
      s = eig(A);
      
      sm = double(sm);
      s = double(s);                   % convert back to double precision
   else
      s1 = -a1/2 + sqrt(a1.*a1-a0);
      s2 = -a1/2 - sqrt(a1.*a1-a0);
      sm = [s1(:);s2(:)];                 % EVs from modal form

      s = eig(A);
   end
   
      % calculate differences
      
   n = length(s);
   [sm,s] = Sort(o,sm,s);              % sort eigenvalues
   ds = sm - s;
   
   dr = abs(ds);  dx = real(ds);  dy = imag(ds);
   
   PlotE(o,2211);
   PlotS(o,2221);

   PlotR(o,3212);
   PlotX(o,3222);
   PlotY(o,3232);
   
   heading(o);
   
   function PlotS(o,sub)               % Plot Radial (Absolute) Devi.  
      subplot(o,sub);
      plot(o,real(s),imag(s),'yyyyyro');
      hold on
      plot(o,real(sm),imag(sm),'rx');
      title(sprintf('Eigenvalues in Complex Plane'));
      ylabel('imag(s)');
      xlabel('real(s)');
      subplot(o);                      % subplot complete
   end
   function PlotE(o,sub)               % Plot Relative Error
      subplot(o,sub);
      e = abs(ds) ./ abs(s);
      maxe = max(e);
      plot(o,1:n,e,'r', 1:n,e,'Ko');
      title(sprintf('Relative Error: max %g',maxe));
      ylabel('e = abs(ds) / abs(s)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotR(o,sub)               % Plot Radial (Absolute) Devi.
      subplot(o,sub);
      maxr = max(abs(dr));
      plot(o,1:n,dr,'yyyyyr', 1:n,dr,'Ko');
      title(sprintf('Absolute Deviation: max %g',maxr));
      ylabel('abs(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotX(o,sub)               % Plot Real Deviation           
      subplot(o,sub);
      maxx = max(abs(dx));
      plot(o,1:n,dx,'bc', 1:n,dx,'Ko');
      title(sprintf('Real Deviation: max %g',maxx));
      ylabel('real(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotY(o,sub)               % Plot Imaginary Deviation      
      subplot(o,sub);
      
      maxy = max(abs(dy));
      plot(o,1:n,dy,'g', 1:n,dy,'Ko');
      title(sprintf('Imaginary Deviation: max %g',maxy));
      ylabel('imag(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function [sm,s] = Sort(o,sm,s)      % Sort Eigenvalues              

         % first sort by real value

      [~,idx] = sort(real(sm));
      sm = sm(idx);

      [~,idx] = sort(real(s));
      s = s(idx);

         % finally bubble sort on the imaginary part

      dirty = 1;                          % init to start loop
      while (dirty)
         dirty = 0;
         for (i=1:n-1)
            same = real(sm(i)) == real(sm(i+1));
            if (same && imag(sm(i)) > imag(sm(i+1)))
               tmp = sm(i);  sm(i) = sm(i+1);  sm(i+1) = tmp;   % swap
               dirty = 1;
            end

            same = real(s(i)) <= real(s(i+1));
            if (same && imag(s(i)) > imag(s(i+1)))
               tmp = s(i);  s(i) = s(i+1);  s(i+1) = tmp;       % swap
               dirty = 1;
            end
         end
      end
      
         % finally sort step by step
         
      for (i=1:n)
         smi = sm(i);
         delta = abs(s-smi);
         
         idx = find(delta == min(delta));
         idx = idx(1);
         err(i) = delta(idx);
         
         ss(i,1) = s(idx);             % sorted s
         s(idx) = [];
      end
      s = ss;                          % copy back
   end
end
function ok = Vpa(o)                   % use var precision arithmetics?
assert(o);  % might be obsoleted!
   digs = opt(o,'precision.G');
   if isempty(digs)
      ok = false;
   else
      digits(digs);
      ok = true;
   end
end

%==========================================================================
% Charts
%==========================================================================

function BodeChart(o,sub,G)            % Bode Chart                    
   o = with(o,'bode');
end
function MagniChart(o,sub,G,critical)  % Magnitude Chart               
   o = with(o,'bode');
   if (nargin < 4)
      critical = 1;
   end

   subplot(o,sub,'semilogx');
   col = get(G,'color');
   magni(G,col);
   
   name = get(G,{'name',''});
   
   if (critical && opt(o,{'view.critical',0}))
      [K0,f0] = cook(o,'K0,f0');
      plot(o,2*pi*[f0 f0],get(gca,'ylim'),'r-.');
      
      if isequal(name,'lambda0(s)')
         plot(o,2*pi*f0,-20*log10(K0),'Ko');
      end
      
      title(sprintf('%s: Magnitude Plot (K0: %g @ %g Hz)',name,K0,f0));
   else
      title(sprintf('%s: Magnitude Plot',name));
   end
   ylabel(sprintf('|%s|  [dB]',name));
end
function PhaseChart(o,sub,G,critical)  % Phase Chart                   
   o = with(o,'bode');
   if (nargin < 4)
      critical = 1;
   end

   subplot(o,sub,'semilogx');
   col = get(G,'color');
   phase(G,col);
   
   name = get(G,{'name',''});
   
   if (critical && opt(o,{'view.critical',0}))
      [K0,f0] = cook(o,'K0,f0');
      plot(o,2*pi*[f0 f0],get(gca,'ylim'),'r-.');
            
      title(sprintf('%s: Phase Plot (K0: %g @ %g Hz)',name,K0,f0));
   else
      title(sprintf('%s: Phase Plot',name));
   end
   ylabel(sprintf('|%s|  [dB]',name));
end

function NyquistChart(o,sub,mu)        % Nyquist Chart                 
   o = cache(o,o,'critical');       % hard refresh 'spectral' segment
   o = cache(o,o,'spectral');       % hard refresh 'spectral' segment
   o = with(o,'nyq');

   subplot(o,sub);
   l0 = cook(o,'lambda0');

   if (dark(o))
      colors = {'rk','gk','b','ck','mk','yk','wk'};
   else
      colors = {'rwww','gwww','bwww','cwww','mwww','yw','wk'};
   end
   colors = get(l0,{'colors',colors});

   for (i=1:length(l0.data.matrix(:)))
      l0i = peek(l0,i);
      l0jwi = l0i.data.matrix{1,1};

      col = colors{1+rem(i,length(colors))};
      nyq(mu*l0i,col);
   end

   col = 'bcw2';

   l00 = peek(l0,1);
   nyq(mu*l00,col);

   [K0,f0] = cook(o,'K0,f0');
   title(sprintf('Nyquist Loci mu*lambda0(jw) - K0: %g @ f0: %g Hz (mu: %g)',K0,f0,mu));
end
function MarginChart(o,sub)            % Margin Chart                  
   if length(sub) < 2
      error('two subplot IDs expected');
   end
   
   o = with(o,{'bode','stability'});
   
   points = opt(o,{'omega.points',10000});
   closeup = opt(o,{'bode.closeup',0});

   [f0,K0] = cook(o,'f0,K0');
   
   if (closeup)
       points = max(points,500);
       o = opt(o,'omega.low',2*pi*f0/(1+closeup));
       o = opt(o,'omega.high',2*pi*f0*(1+closeup));
       o = opt(o,'omega.points',points);
   end
   
   mu = opt(o,{'process.mu',0.1});
   o = opt(o,'mu',mu);
   critical(o,'Damping',sub);
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
function Verbose(o,G)                  % Verbose Tracing of TFF        
   if (control(o,'verbose') > 0)
      G = opt(G,'detail',true);
      display(G);
   end
end
function Legend(o,sub,objects)         % Plot Legend                   
   subplot(o,sub);
   list = {''};                        % ignore 1st, as some dots plotted 
   for (i=1:length(objects))
      list{end+1} = get(objects{i},{'package',''});
   end
   hdl = legend(list);
   set(hdl,'color','w');
end
function [om,om0] = Omega(o,f0,k,n)    % Omega range near f0           
%
% OMEGA  Omega range near f0
%       
%           om = Omega(o,f0,1.05,50)   % om = f0/1.02,..,f0*1.02, 50 points
%           om = Omega(o,f0)           % same as above
%           om = Omega(o)              % cook f0
%         
%           [om,om0] = Omega(o)        % also return center frequency
%
   if (nargin < 4)
      n = 50;
   end
   if (nargin < 3)
      k = 1.05;
   end
   k1 = 1/k;  k2 = k;
   
   if (nargin < 2)
      [f0,L0] = cook(o,'f0,L0');
   end
   
   om0 = 2*pi*f0;
   om = logspace(log10(om0*k1),log10(om0*k2),n);
end
function Heading(o,head)  
   txt = Contact(o);
   [~,phitxt] = getphi(o);
   if (nargin == 1)
      msg = [get(o,{'title',''}),' (',id(o),') ',txt,', ',phitxt];
   else
      msg = [head,' ',txt,', ',phitxt];
   end
   heading(o,msg);
end
function txt = Contact(o)                                              
   contact = opt(o,'process.contact');
   if isempty(contact)
      txt = '';
   elseif iscell(contact)
      txt = 'contact: -';  sep = '';
      for (i=1:length(contact(:)))
         txt = [txt,sep,sprintf('%g',contact{i})];  sep = '-';
      end
      txt = [txt,'-'];   elseif (contact == 0)
      txt = 'contact: center';
   elseif isequal(contact,-1)
      txt = 'contact: leading';
   elseif isequal(contact,-2)
      txt = 'contact: trailing';
   elseif isequal(contact,-3)
      txt = 'contact: triple';
   elseif isinf(contact)
      txt = 'contact: all';
   elseif (length(contact) == 1)
      txt = sprintf('contact: %g',contact);
   else
      txt = 'contact: [';  sep = '';
      for (i=1:length(contact(:)))
         txt = [txt,sep,sprintf('%g',contact(i))];  sep = ',';
      end
      txt = [txt,']'];
   end
end
function [fcol,bcol,ratio] = Colors(o,K,i)                               
%
% COLORS   Return colors and color ratio of a critical value, where output
%          arg is the ratio of foreground (fcol) to background (bcol9 color 
%
%             colors = Colors(o,l0);
%
%             [fcol,bcol,ratio] = Colors(o,K)
%
%          Method
%             K = 0:0.5     green/yellow, ratio = 1-K
%             K = 0.5:1     green/yellow, ratio = 1-K
%             K = 1:2       red/yellow,   ratio = 1-1/K
%             K = 2:inf     red/yellow,   ratio = 1-1/K
%
%          Examples:
%             K = 0.1:      90% green @ 10% yellow
%             K = 0.2:      80% green @ 20% yellow
%             K = 0.5:      50% green @ 50% yellow
%             K = 0.8:      20% green @ 80% yellow
%             K = 1.0:       0% green @ 100% yellow
%             K = 1.5:      33% red   @ 67% yellow
%             K = 2:        50% red   @ 50% yellow
%             K = 5:        80% red   @ 20% yellow
%             K = 10:       90% red   @ 10% yellow
%
   if isobject(K)
      if dark(o)
         colors = {'rk','gk','b','ck','mk','yk','wkk'};
      else
         colors = {'rwww','gwww','bwww','cwww','mwww','yw','wwk'};
      end
      if (nargin < 3)
         fcol = colors;                   % set out arg
      else
         fcol = colors{1+rem(i,length(colors))};
      end
   else
      n = 2;                              % exponent
      K = abs(K);
      if (K > 1.0)
         fcol = 'ggk';  bcol = 'yyyr';
         ratio = 1 - (1/K)^n;
      else
         fcol = 'r';  bcol = 'yyyr';
         ratio = 1 - K^n;
      end

      ratio = 1-ratio;
   end
end
    
