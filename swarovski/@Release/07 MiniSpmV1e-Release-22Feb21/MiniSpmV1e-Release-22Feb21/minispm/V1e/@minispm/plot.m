function oo = plot(o,varargin)         % SPM Plot Method               
%
% PLOT   SPM plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'Overview')         % Overview about eigenvalues of SPM
%
%           plot(o,'Step')             % force step response
%           plot(o,'Ramp')             % force ramp response
%
%        See also: SPM, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                   @WithSpm,@Overview,@About,@Image,@Real,@Imag,@Complex,...
                   @TrfDisp,@TrfRloc,@TrfStep,@TrfBode,@TrfMagni,...
                   @TrfNyq,@TrfWeight,@TrfNumeric,... 
                   @Gs,@Trfr,@GsRloc,@GsStep,@GsBode,@GsWeight,...
                   @Hs,@Consr,@HsRloc,@HsStep,@HsBode,@PsQs,...
                   @PsQsRloc,@PsQsStep,@PsQsBode,@PsQsNyq,@PsQsBodeNyq,...
                   @PsQsOverview,@PsQsNormalizing,@Critical,@T0S0,...
                   @G31G33L0,@L0Shell,@MagniPhase,...
                   @Ls,@LsStep,@LsBode,@Ts,@TsStep,@TsBode,@Step,...
                   @Ramp,@ForceRamp,@ForceStep,@MotionRsp,@NoiseRsp,...
                   @StabilityMargin,@StabilityRange,@GijPrecision,@L0Precision,...
                   @AnalyseRamp,@NormRamp);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
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
   oo = mitem(o,'About',{@WithCuo,'About'});
return   
   oo = mitem(o,'-');
   oo = mitem(o,'Transfer Function');
   ooo = mitem(oo,'Bode Plot',{@WithCuo,'TrfBode'});
   ooo = mitem(oo,'Magnitude Plot',{@WithCuo,'TrfMagni'});
   oo = mitem(o,'Principal Transfer Functions');
   ooo = mitem(oo,'L0(s)',{@WithCuo,'L0Shell'});
   ooo = mitem(oo,'L0(s) = G31(s)/G33(s)',{@WithCuo,'G31G33L0'});
end
function oo = SpmMenu(o)               % Setup Plot Menu @ SPM-Type    
%
% MENU  Setup plot menu. Note that plot functions are best invoked via
%       Callback or Basket functions, which do some common tasks
%
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'Overview',{@WithCuo,'Plot'});
return   
   oo = mitem(o,'-');
   oo = ModeShapes(o);
   oo = TransferFunction(o);           % Transfer Function menu
   
   oo = mitem(o,'-');
   oo = TransferMatrix(o);             % G(s)
   oo = ConstrainMatrix(o);            % H(s)

   oo = mitem(o,'-');
   oo = Principal(o);                  % P(s)/Q(s)
   oo = CriticalLoop(o);               % K0, S0(s), T0(s)
   
   oo = mitem(o,'-');
   oo = StepResponse(o);               % step response sub-menu
   oo = RampResponse(o);               % ramp response sub-menu
   oo = MotionResponse(o);             % motion response sub menu
   oo = NoiseResponse(o);              % noise response sub menu
end
function oo = PkgMenu(o)               % Setup Plot Menu @ PKG-Type    
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'Image',{@WithCuo,'Image'});
   enable(oo,~isempty(get(current(o),'image')));
return   
   oo = mitem(o,'-');
   oo = mitem(o,'Stability Range',{@WithCuo,'StabilityRange'});
   oo = mitem(o,'Stability Margin',{@WithCuo,'StabilityMargin'});
end

function oo = ModeShapes(o)            % Mode Shapes Menu              
   oo = mitem(o,'Mode Shapes');   
   ooo = mitem(oo,'Complex', {@WithCuo,'Complex'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Real Part',{@WithCuo,'Real'});
   ooo = mitem(oo,'Imaginary Part',{@WithCuo,'Imag'});
end
function oo = TransferFunction(o)      % Transfer Function Menu        
   oo = mitem(o,'Transfer Function');
   ooo = mitem(oo,'Display',{@WithCuo,'TrfDisp'});
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'TrfRloc'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Step Response',{@WithCuo,'TrfStep'});
   ooo = mitem(oo,'Bode Plot',{@WithCuo,'TrfBode'});
   ooo = mitem(oo,'Magnitude Plot',{@WithCuo,'TrfMagni'});
   ooo = mitem(oo,'Nyquist Plot',{@WithCuo,'TrfNyq'});   
   ooo = mitem(oo,'Modal Weights',{@WithCuo,'TrfWeight'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Numeric Quality',{@WithSpm,'TrfNumeric'});
   ooo = mitem(oo,'ZPK Precision',{@WithSpm,'GijPrecision'});
end
function oo = TransferMatrix(o)        % Transfer Matrix Menu          
   oo = current(o);
   [B2,C1] = cook(oo,'B2,C1');
   [~,m] = size(B2);
   [l,~] = size(C1);
   
   oo = mhead(o,'Free System');
   ooo = mitem(oo,'Poles/Zeros',{@WithSpm,'GsRloc'});
   ooo = mitem(oo,'Step Responses',{@WithSpm,'GsStep'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bode Plots',{@WithSpm,'GsBode'});
   ooo = mitem(oo,'Modal Weights',{@WithSpm,'GsWeight'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('G(s)'),{@WithSpm,'Gs',0,0});
   %ooo = Rational(oo);                % Rational submenu
   
   ooo = mitem(oo,'-');
   for (i=1:l)
      for (j=1:m)
         ooo = mitem(oo,sprintf('G%g%g(s)',i,j),{@WithCuo,'Gs',i,j});
      end
      if (i < l)
         ooo = mitem(oo,'-');
      end
   end
   
   function oo = Rational(o)           % Rational Sub Menu               
      oo = mitem(o,'Rational');
      ooo = mitem(oo,sprintf('G(s)'),{@WithCuo,'Trfr',0,0});
      ooo = mitem(oo,'-');
      for (i=1:l)
         for (j=1:m)
            ooo = mitem(oo,sprintf('G(%g,%g)',i,j),{@WithCuo,'Trfr',i,j});
         end
         if (i < l)
            ooo = mitem(oo,'-');
         end
      end
   end   
end
function oo = ConstrainMatrix(o)       % Transfer Matrix Menu          
   oo = current(o);
   [B,C] = data(oo,'B,C');
   [~,m] = size(B);
   [l,~] = size(C);
   
   oo = mhead(o,'Constrained System');
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'HsRloc'});
   ooo = mitem(oo,'Step Responses',{@WithCuo,'HsStep'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'HsBode'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('H(s)'),{@WithCuo,'Hs',0,0});
   
   ooo = mitem(oo,'-');
   for (i=1:l)
      for (j=1:m)
         ooo = mitem(oo,sprintf('H%g%g(s)',i,j),{@WithCuo,'Hs',i,j});
      end
      if (i < l)
         ooo = mitem(oo,'-');
      end
   end
   
   
   function oo = Rational(o)           % Rational Submenu              
      oo = mitem(o,'Rational');
      enable(oo,false);
      ooo = mitem(oo,sprintf('H(s)'),{@WithCuo,'Consr',0,0});
      ooo = mitem(oo,'-');
      for (i=1:l)
         for (j=1:m)
            ooo = mitem(oo,sprintf('H(%g,%g)',i,j),{@WithCuo,'Consr',i,j});
         end
         if (i < l)
            ooo = mitem(oo,'-');
         end
      end
   end
end
function oo = Principal(o)             % Pricipal Menu                 
   oo = current(o);
   oo = mhead(o,'Principal System');
   ooo = mitem(oo,'Overview',{@WithSpm,'PsQsOverview'});
   ooo = mitem(oo,'Normalizing',{@WithSpm,'PsQsNormalizing'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Poles/Zeros',{@WithSpm,'PsQsRloc'});
   ooo = mitem(oo,'Step Responses',{@WithSpm,'PsQsStep'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Magnitude Plots',{@WithSpm,'PsQsBode'});
   ooo = mitem(oo,'Nyquist Plots',{@WithSpm,'PsQsNyq'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'P(s)');
   oooo = mitem(ooo,'Overview',{@WithSpm,'PsQs',1,0});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Bode Plot',{@WithSpm,'MagniPhase','P'});
   
   ooo = mitem(oo,'Q(s)');
   oooo = mitem(ooo,'Overview',{@WithSpm,'PsQs',2,0});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Bode Plot',{@WithSpm,'MagniPhase','Q'});

   ooo = mitem(oo,'F0(s)');
   oooo = mitem(ooo,'Overview',{@WithSpm,'PsQs',3,0});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Bode Plot',{@WithSpm,'MagniPhase','F0'});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'L0(s)');
   oooo = mitem(ooo,'L0(s) = P(s)/Q(s)',{@WithSpm,'PsQs',0,0});
   oooo = mitem(ooo,'L0(s) = G31(s)/G33(s)',{@WithSpm,'G31G33L0'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Bode Plot',{@WithSpm,'MagniPhase','L0'});
   oooo = mitem(ooo,'ZPK Precision',{@WithSpm,'L0Precision'});
end
function oo = CriticalLoop(o)          % Critical Loop Menu            
   oo = mitem(o,'Critical Loop');
   ooo = mitem(oo,'Critical Gain',{@WithCuo,'Critical','K0'});
   ooo = mitem(oo,'Open Loop Lc(s)');
   oooo = mitem(ooo,'Bode Plot',{@WithCuo,'Critical','LcBode'});
   oooo = mitem(ooo,'Magnitude Plot',{@WithCuo,'Critical','LcMagni'});
   oooo = mitem(ooo,'Nyquist Plot',{@WithCuo,'Critical','LcNyq'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Closed Loop Tc(s)',{@WithCuo,'Critical','T0'});   
   ooo = mitem(oo,'Sensitivity Sc(s)',{@WithCuo,'Critical','S0'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('Tc(s)'),{@WithCuo,'T0S0','T0'});
   ooo = mitem(oo,sprintf('Sc(s)'),{@WithCuo,'T0S0','S0'});
end
function oo = OpenLoopSystem(o)        % Open Loop System Menu         
   oo = mhead(o,'L(s): Open Loop');

   oo = current(o);
   if container(oo)
      return                           % done for container objects
   end
   
   [oo,bag,rfr] = cache(oo,oo,'consd');
   
   L = cache(oo,'consd.L');
   [m,n] = size(L);

      % add mhead again !!!
      
   oo = mhead(o,'L(s): Open Loop');
   ooo = mitem(oo,'Step Responses',{@WithCuo,'LsStep'});
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'LsBode'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('L(s)'),{@WithCuo,'Ls',0,0});
   
   ooo = mitem(oo,'-');
   for (i=1:m)
      for (j=1:n)
         ooo = mitem(oo,sprintf('L%g%g(s)',i,j),{@WithCuo,'Ls',i,j});
      end
      if (i < m)
         ooo = mitem(oo,'-');
      end
   end
 end
function oo = ClosedLoopSystem(o)      % Closed Loop System Menu       
   oo = mhead(o,'T(s): Closed Loop');

   oo = current(o);
   if container(oo)
      return                           % done for container objects
   end
   
   [oo,bag,rfr] = cache(oo,oo,'process');
   
   T = cache(oo,'process.T');
   [m,n] = size(T);

      % add mhead again !!!
      
   oo = mhead(o,'T(s): Closed Loop');
   ooo = mitem(oo,'Step Responses',{@WithCuo,'TsStep'});
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'TsBode'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('T(s)'),{@WithCuo,'Ts',0,0});
   
   ooo = mitem(oo,'-');
   for (i=1:m)
      for (j=1:n)
         ooo = mitem(oo,sprintf('T%g%g(s)',i,j),{@WithCuo,'Ts',i,j});
      end
      if (i < m)
         ooo = mitem(oo,'-');
      end
   end
 end
   
function oo = StepResponse(o)          % Step Response Menu            
   oo = mitem(o,'Step Response');
   ooo = mitem(oo,'Force Step Overview',{@WithCuo,'ForceStep'},0);

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Force Step @ F1',{@WithCuo,'ForceStep'},1);
   ooo = mitem(oo,'Force Step @ F2',{@WithCuo,'ForceStep'},2);
   ooo = mitem(oo,'Force Step @ F3',{@WithCuo,'ForceStep'},3);    

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F-Step Orbit @ F1',{@WithCuo,'ForceStep'},10);
   ooo = mitem(oo,'F-Step Orbit @ F2',{@WithCuo,'ForceStep'},20);
   ooo = mitem(oo,'F-Step Orbit @ F3',{@WithCuo,'ForceStep'},30);    
end
function oo = RampResponse(o)          % Ramp Response Menu            
   oo = mitem(o,'Ramp Response');
   ooo = mitem(oo,'Force Ramp Overview',{@WithCuo,'ForceRamp'},0);

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Force Ramp @ F1',{@WithCuo,'ForceRamp'},1);
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'ForceRamp'},2);
   ooo = mitem(oo,'Force Ramp @ F3',{@WithCuo,'ForceRamp'},3);   

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F-Ramp Orbit @ F1',{@WithCuo,'ForceRamp'},10);
   ooo = mitem(oo,'F-Ramp Orbit @ F2',{@WithCuo,'ForceRamp'},20);
   ooo = mitem(oo,'F-Ramp Orbit @ F3',{@WithCuo,'ForceRamp'},30);    
end
function oo = MotionResponse(o)        % Motion Response Menu          
   oo = mitem(o,'Motion Response');
   enable(oo,false);
   ooo = mitem(oo,'y3 -> y1',{@WithCuo,'MotionRsp',31});
   ooo = mitem(oo,'y3 -> y2',{@WithCuo,'MotionRsp',32});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'y3 -> F3',{@WithCuo,'MotionRsp',33});
end
function oo = NoiseResponse(o)         % Noise Response Menu           
   oo = mitem(o,'Noise Response');
   ooo = mitem(oo,'Acceleration',{@WithCuo,'NoiseRsp'});
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
function oo = WithSpm(o)               % 'With Current SPM Object'     
%
% WITHSPM Same as WithCuo but don't invoke callback if not SPM object
%         but plot(o,'About')
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   if ~type(oo,{'spm'})
      plot(oo,'About');
      return;
   end
   
      % SPM object: invoke callback
      
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
% Default Plot Functions
%==========================================================================

function oo = Plot(o)                  % Default Plot                  
%
% PLOT The default Plot function shows how to deal with different object
%      types. Depending on type a different local plot function is invoked
%
   oo = plot(corazon,o);               % if arg list is for corazon/plot
   if ~isempty(oo)                     % is oo an array of graph handles?
      oo = []; return                  % in such case we are done - bye!
   end

   cls(o);                             % clear screen
   switch o.type
      case 'spm'
         oo = Overview(o);
      otherwise
         oo = plot(o,'About');         % no idea how to plot
   end
end

%==========================================================================
% Plot Overview and About Object
%==========================================================================

function o = Overview(o)               % Plot Overview                 
   if ~type(o,{'spm'})
      plot(o,'About');
      return                           % no idea how to plot this type
   end

   Real(o,[2 2 1]);
   Imag(o,[2 2 3]);
   Complex(o,[1 2 2]);

   heading(o);
end
function o = About(o)                  % About Object                  
   switch type(current(o))
      case 'pkg'
         o = AboutPkg(o);
      otherwise
         o = menu(o,'About');          % keep it simple
   end
end

%==========================================================================
% Package Objects
%==========================================================================

function o = AboutPkg(o)               % About Package                 
   if ~type(o,{'pkg'})
      o = plot(o,'About');
      return
   end
   
   oo = opt(o,'subplot',211,'pitch',2);
   message(oo);
   axis off
   
   subplot(o,2322);
   Image(o);
   
     % increase axis width
     
   pos = get(gca,'position');
   w = pos(3);  k = 1.5;               % k: stretch factor
   pos = [pos(1)-(k-1)/2*w, pos(2), w*k, pos(4)];
   set(gca,'position',pos);
   set(gca,'ydir','reverse')
end
function o = Image(o)                  % Plot Image                    
   path = [get(o,'dir'),'/',get(o,'image')];
   try
      im = imread(path);
   catch
      im = [];
   end
   
   if ~isempty(im)
      hdl = image(im);
      axis off
   else
      message(o,'cannot display image',{['path: ',path]});
   end
end

%==========================================================================
% Mode Shapes
%==========================================================================

function o = Real(o,sub)               % Plot Real Part of Eigenvalues 
   if ~type(o,{'spm'})
      plot(o,'About');
      return                           % no idea how to plot this type
   end

   if (nargin < 2)
      sub = [1 1 1];                   % default subplot full canvas
   end
   subplot(o,sub);
   
      % inspect variation - if differing from 1 then make a first plot
      % with nominal system parameters
      
   vomega = opt(o,{'variation.omega',1});
   vzeta = opt(o,{'variation.zeta',1});
   
   if (vomega ~= 1 || vzeta ~= 1)
      oo = opt(o,'variation.omega',1);
      oo = opt(oo,'variation.zeta',1);
      oo = Eigen(oo);                  % nominal system eigenvalues
      [index,real] = var(oo,'index,real');   
      plot(o,index,real,'K1');
      hold on
      plot(o,index,real,'K.');
   end
   
   oo = Eigen(o);                      % calc eigenvalues
   [index,real] = var(oo,'index,real');   
   plot(o,index,real,'r2');

   title('Real Part of System Eigenvalues');
   xlabel('index');  ylabel('real part');
   
   heading(o);
end
function o = Imag(o,sub)               % Plot Imag Part of Eigenvalues 
   if ~type(o,{'spm'})
      plot(o,'About');
      return                           % no idea how to plot this type
   end

   if (nargin < 2)
      sub = [1 1 1];                   % default subplot full canvas
   end
   subplot(o,sub);
   
      % inspect variation - if differing from 1 then make a first plot
      % with nominal system parameters
      
   vomega = opt(o,{'variation.omega',1});
   vzeta = opt(o,{'variation.zeta',1});
   
   if (vomega ~= 1 || vzeta ~= 1)
      oo = opt(o,'variation.omega',1);
      oo = opt(oo,'variation.zeta',1);
      oo = Eigen(oo);                  % nominal system eigenvalues
      [index,imag] = var(oo,'index,imag');   
      plot(o,index,imag,'K1');
      hold on
      plot(o,index,imag,'K.');
   end
   
   oo = Eigen(o);                      % calc eigenvalues
   [index,imag] = var(oo,'index,imag');
   
   plot(o,index,imag,'g2');

   title('Imaginary Part of System Eigenvalues');
   xlabel('index');  ylabel('real part');
  
   heading(o);
end
function o = Complex(o,sub)            % Eigenvalues in Complex Plane  
   if ~type(o,{'spm'})
      oo = plot(o,'About');
      return                           % no idea how to plot this type
   end

   if (nargin < 2)
      sub = [1 1 1];                   % default subplot full canvas
   end
   subplot(o,sub);
   
      % inspect variation - if differing from 1 then make a first plot
      % with nominal system parameters
      
   vomega = opt(o,{'variation.omega',1});
   vzeta = opt(o,{'variation.zeta',1});
   
   if (vomega ~= 1 || vzeta ~= 1)
      oo = opt(o,'variation.omega',1);
      oo = opt(oo,'variation.zeta',1);
      oo = Eigen(oo);                  % nominal system eigenvalues
      [re,im] = var(oo,'real,imag');   
      plot(o,re,im,'Ko');
      hold on
      plot(o,re,im,'K.');
   end
   
   oo = Eigen(o);                      % calc eigenvalues
   [lambda,re,im] = var(oo,'lambda,real,imag');

   plot(o,re,im,'Ko');
   hold on;
   plot(o,re,im,'rp');
   plot(o,re,im,'rh');
   plot(o,re,im,'r.');

   title('Eigenvalues in Complex Plane');
   xlabel('real part');  ylabel('imaginary part');

   [~,idx] = sort(abs(lambda));
   lambda = lambda(idx);
   
      % for an eigen value pair we have:
      % (s-s1)*(s+s1) = (s-re+i*im)*(s-re-i*im) = (s-re)^2 + im^2
      % (s-s1)*(s+s1) = s^2 -2*re*s + (re^2+im^2) = s^2 + 2*zeta*om*s +om^2
      % => om = sqrt(re^2+im^2) = abs(s1) = abs(s2)
      % => zeta = -re/om
      
   for (i=1:length(lambda)/2)
      s = lambda(2*i);
      om = abs(s);
      f = om/2/pi;
      zeta = -real(s)/om;
      percent = zeta*100;
      
      if (i < 10)
         num = '  #';
      elseif (i < 100)
         num = ' #';
      else
         num = '#';
      end
      
      fprintf('   %s%g: f = %g Hz, omega = %g 1/s, zeta = %g  (%g%%)\n',...
              num,i,  f,om, zeta,o.rd(percent,2));
   end
   
%  set(gca,'DataAspectRatio',[1 1 1]);
   heading(o);
end

%==========================================================================
% Transfer Function
%==========================================================================


%==========================================================================
% Plot Transfer Matrix G(s)
%==========================================================================


%==========================================================================
% Plot Constraint Transfer Matrix H(s)
%==========================================================================


%==========================================================================
% Plot Transfer Matrix G(s)
%==========================================================================


%==========================================================================
% Plot Open Loop Transfer Matrix L(s)
%==========================================================================


%==========================================================================
% Plot Closed Loop Transfer Matrix T(s)
%==========================================================================


%==========================================================================
% Force Step & Ramp Responses
%==========================================================================


%==========================================================================
% Plot Output Signals
%==========================================================================


%==========================================================================
% Stability
%==========================================================================


%==========================================================================
% Helper
%==========================================================================

function oo = Eigen(o)                 % Calc System Eigenvalues       
%
% EIGEN  Apply system variation and calulate system eigenvalues of the
%        varyied system and sort. Note that no normalization is applied.
%
%           oo = Eigen(o)
%           [idx,re,im] = var(oo,'index,real,imag');
%
   oo = brew(o,'Variation');           % apply system variation
   A = data(oo,'A');
   
   s = eig(A);                         % eigenvalues (EV)
   i = 1:length(s);                    % EV index 
   x = real(s);                        % real value
   y = imag(s);                        % imag value
   [~,idx] = sort(abs(imag(s)));
   
      % store calculated stuff in var space
      
   oo = var(oo,'lambda,index,real,imag',s,i,x(idx),y(idx));
end
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
function w0 = NominalWeight(o,W)       % Return Nominal Weight         
%
% NOMINALWEIGHT
%
%    w0 = NominalWeight(o,W)           % nominal weight of a matrix
%    w0 = NominalWeight(o,wij)         % nominal weight of a weight vector
%
   small = opt(o,{'weight.small',1e-3});
   
   if isa(W,'double')
      w0 = max(abs(W))*small;
   elseif iscell(W)
      [m,n] = size(W);
      for (i=1:m)
         for (j=1:n)
            w0(i,j) = max(abs(W{i,j}))*small;
         end
      end
      w0 = max(w0(:));
   else
      error('bad arg');
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
function txt = Contact(o)
   contact = opt(o,'process.contact');
   if isempty(contact)
      txt = '';
   elseif (contact == 0)
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
