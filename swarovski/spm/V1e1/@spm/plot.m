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
                   @Stability,@GijPrecision,@L0Precision,...
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
   
   oo = mitem(o,'-');
   oo = mitem(o,'Stability Margin',{@WithCuo,'Stability'});
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

function o = TrfDisp(o)                % Display Transfer Function     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   idx = opt(o,{'select.channel',[1 1]});
   i = idx(1);  j = idx(2);
   
   G = cook(o,'G');
   Gij = peek(G,i,j);
   
%  sym = sprintf('G%g%g(s)',i,j);
   Gij = set(Gij,'name',sym);  

   Gij = opt(Gij,'detail',true);
   if (control(o,'verbose') > 0)
      display(Gij);
   end

   diagram(o,'Trf',sym,Gij,1111);      
   heading(o);
end
function o = TrfRloc(o)                % Pole/Zero Plot                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   list = GijSelect(o);   
   Gij = list{1};                   
   
   diagram(o,'Rloc','',Gij,1111);
   heading(o);
end
function o = TrfStep(o)                % Step Response Plot            
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   list = GijSelect(o);   
   Gij = list{1};                   
   diagram(o,'Step','',Gij,2111);
   
   o = opt(o,'simu.tmax',1);
   diagram(o,'Step','',Gij,2112);
   heading(o);
end
function o = TrfBode(o)                % Bode Plot                     
   if ~type(o,{'spm','shell'})
      plot(o,'About');
      return
   end
   
   colors = {'g','gy','gk','gb','gww','gkk','gbb','gbw','gbk'};
   
   if opt(o,{'view.critical',1});
      o = cache(o,o,'loop');           % hard refresh loop cache segment
   end
   
   [list,objs,head] = GijSelect(o);
   for (i=1:length(list))
      Gij = list{i};
      col = colors{1+rem(i-1,length(colors))};

      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      
      diagram(o,'Bode','',Gij,2111); 
      o = opt(o,'bode.magnitude.enable',0,'bode.phase.enable',1);
      diagram(o,'Bode','',Gij,2121);   
   end
   
      % plot legend if more than 1 plots
      
   if (length(list) > 1)
      Legend(o,2111,objs);
      Legend(o,2121,objs);
   end
   
      % plot critical frequencies
      
   CriticalFrequency(o,objs,211);
   CriticalFrequency(o,objs,212);

      % plot heading if not shell object
      
   heading(o,head);
end
function o = OldTrfMagni(o)            % Magnitude Plot                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   list = GijSelect(o);   
   Gij = list{1};                   
   o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
   diagram(o,'Bode','',Gij,1111);      
   heading(o);
end
function o = TrfMagni(o)               % Magnitude Plot                
   if ~type(o,{'spm','shell'})
      plot(o,'About');
      return
   end
   
   colors = {'g','gy','gk','gb','gww','gkk','gbb','gbw','gbk'};
   
   [list,objs,head] = GijSelect(o);
   for (i=1:length(list))
      Gij = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      diagram(o,'Bode','',Gij,1111);
   end
   
      % plot legend if more than 1 plots
      
   if (length(list) > 1)
      Legend(o,1111,objs);
   end
   
      % plot critical frequencies
      
   CriticalFrequency(o,objs,111);

      % plot heading if not shell object

   heading(o,head);
end
function o = TrfNyq(o)                 % Nyquist Plot                  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   list = GijSelect(o);   
   Gij = list{1};                   
   diagram(o,'Nyq','',Gij,1111);      
   heading(o);
end
function o = TrfWeight(o)              % Plot Modal Weights            
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   [wij,w0,sym] = WeightSelect(o);
   o = opt(o,'weight.nominal',w0);
   wij = wij/w0;
   
   diagram(o,'Weight',sym,wij,1111);      
   heading(o);

   function [wij,w0,sym] = WeightSelect(o) % Select Transfer Function      
      idx = opt(o,{'select.channel',[1 1]});
      i = idx(1);  j = idx(2);

      W = cook(o,'W');
      wij = W{i,j};
      sym = sprintf('w%g%g',i,j);
      
      if opt(o,{'weight.equalize',0})
         w0 = NominalWeight(o,W);
      else
         w0 = NominalWeight(o,wij);
      end
   end
end
function o = TrfNumeric(o)             % Numeric FQR Check             
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   idx = opt(o,{'select.channel',[1 1]});
   i = idx(1);  j = idx(2);

   [G,psi,W] = cook(o,'G,psi,W');      % G(s), modal param's, weights

   Gij = peek(G,i,j);
   wij = W{i,j};
   diagram(o,'Numeric',{psi,wij},Gij,111);
   heading(o);
end
function o = GijPrecision(o)           % Zero/Pole Precision           
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
      
   o = cache(o,o,'trf');               % hard refresh trf cache segment
   
   mode = opt(o,{'view.precision',1});
   if (mode == 1)                   % current settings
      [list,objs,head] = GijSelect(o);
      for (i=1:length(list))
         Gij = list{i};
         diagram(o,'Precision','',Gij,1111);
      end
   elseif (mode == 2)               % comparison
      o = opt(o,'precision.Gcook',1);
      [list,~,~] = GijSelect(o);
      for (i=1:length(list))
         Gij = list{i};
         diagram(o,'Precision','',Gij,2111);
      end
      
      o = opt(o,'precision.Gcook',0);
      [list,~,~] = GijSelect(o);
      for (i=1:length(list))
         Gij = list{i};
         diagram(o,'Precision','',Gij,2121);
      end
   end
   
      
   heading(o);
end

function [list,objs,head] = GijSelect(o) % Select Transfer Function    
   list = {};                          % empty by default
   objs = {};
   head = heading(o);                  % default heading
   
   idx = opt(o,{'select.channel',[1 1]});
   i = idx(1);  j = idx(2);

   if type(o,{'spm'})
      G = cook(o,'G');
      Gij = peek(G,i,j);
      list = {Gij};
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
            G = cook(ok,'G');
            Gij = peek(G,i,j);
            list{end+1} = Gij;
            objs{end+1} = ok;
         end
      end
      head = sprintf('Pivot: %g°',pivot);
   end
end
function [list,objs,head] = L0Select(o)% Select Transfer Function      
   list = {};                          % empty by default
   objs = {};
   head = heading(o);                  % default heading
   
   if type(o,{'spm'})
      L0 = cook(o,'L0');
      list = {L0};
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
            L0 = cook(ok,'L0');
            list{end+1} = L0;
            objs{end+1} = ok;
         end
      end
      head = sprintf('Pivot: %g°',pivot);
   end
end
function CriticalFrequency(o,objs,sub) % Plot Critical Frequencies     
   critical = opt(o,{'view.critical',1});
   if ~critical
      return                           % don't show critical frequency
   end
   
   subplot(o,sub);
   ylim = get(gca,'ylim');
   hold on;
   
   for (i=1:length(objs))
      oo = objs{i};
      f0 = cook(oo,'f0');
      hdl = semilogx(2*pi*f0*[1 1],ylim,'r-.');
      set(hdl,'linewidth',o.iif(i==1,1,2));
   end
end

%==========================================================================
% Plot Transfer Matrix G(s)
%==========================================================================

function o = Gs(o)                     % Double Transfer Function      
   o = with(o,'simu');
   i = arg(o,1);
   j = arg(o,2);

   G = cook(o,'G');
   W = cook(o,'W');
   
   if opt(o,{'weight.equalize',0})
      w0 = NominalWeight(o,W);
   end

   
   if (i == 0 || j == 0)
      G = opt(G,'maxlen',200);
      str = display(G);
      sym = 'G';

      [m,n] = size(G);
      for (i=1:n)
         for (j=1:m)
            Gij = peek(G,i,j);
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
            display(Gij);
            fprintf('\n');
         end
      end
      diagram(o,'Trf',sym,G,111);
   else
      Gij = peek(G,i,j);
      sym = [get(Gij,{'name','?'}),'(s)'];
      symw = sprintf('w%g%g',i,j);
      Gij = set(Gij,'name',sym);  
      
      Gij = opt(Gij,'detail',true);
      if (control(o,'verbose') > 0)
         display(Gij);
      end
      
      diagram(o,'Trf',sym,Gij,3111);      
      diagram(o,'Rloc',sym,Gij,3222);

      if ~isempty(W)
         wij = W{i,j};
         if ~opt(o,{'weight.equalize',0})
            w0 = NominalWeight(o,wij);
         end
         if opt(o,{'weight.db',1})
            wij = wij / w0;
         end
         diagram(o,'Weight',symw,wij,3232);
      end

      o = opt(o,'color','g');
      
      if isempty(W)
         diagram(o,'Step',sym,Gij,3131);
      else
         diagram(o,'Step',sym,Gij,3231);
      end
      diagram(o,'Bode',sym,Gij,3221);
   end
   heading(o);
end
function o = GsRloc(o)                 % G(s) Poles/Zeros Overview     
   G = cook(o,'G');                    % G(s)
   [m,n] = size(G);
   
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         diagram(o,'Rloc','',Gij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = GsStep(o)                 % G(s) Step Response Overview   
   o = with(o,'simu');
   G = cook(o,'G');                    % G(s)
   [m,n] = size(G);
   
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         diagram(o,'Step','',Gij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = GsBode(o)                 % G(s) Bode Plot Overview       
   G = cook(o,'G');                    % G(s)
   [m,n] = size(G);
   
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         diagram(o,'Bode','',Gij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = GsWeight(o)               % G(s) Weight Overview          
   W = cook(o,'W');                    % weight matrix
   [m,n] = size(W);

   if opt(o,{'weight.equalize',0})
      w0 = NominalWeight(o,W);
   end
   
   for (i=1:m)
      for (j=1:n)
         if ~isempty(W)
            wij = W{i,j};
            if ~opt(o,{'weight.equalize',0})
               w0 = NominalWeight(o,wij);
            end
            if opt(o,{'weight.db',1})
               wij = wij / w0;
            end
            sym = sprintf('w%g%g',i,j);
            o = opt(o,'weight.nominal',w0);
            diagram(o,'Weight',sym,wij,[m,n,i,j]);
         end
      end
   end
   Equalize(o);                        % equalize diagrams
   
   heading(o);
   
   function Equalize(o)                % Equalize Diagrams             
      if ~opt(o,{'weight.equalize',0})
         return                        % bye if equalizing is desabled
      end
      
      ylim = [0 0];                    % asses y-limits
      for (i=1:m)
         for (j=1:n)
            subplot(o,[m,n,i,j]);
            lim = get(gca,'Ylim');
            ylim(1) = min(ylim(1),lim(1));
            ylim(2) = max(ylim(2),lim(2));
         end
      end
      ymax = max(abs(ylim));
      
      if ~opt(o,{'weight.db',1})        % show weight in dB
         ylim = 1.2*[-ymax ymax];
      else
         ylim(2) = ylim(2)*1.2;
      end
      
         % now apply y-limit to all diagrams

      for (i=1:m)
         for (j=1:n)
            subplot(o,[m,n,i,j]);
            set(gca,'Ylim',ylim);
         end
      end
   end
end
function o = OldGsNumeric(o)           % G(s) Numeric FQR Check        
   [G,psi,W] = cook(o,'G,psi,W');      % G(s), modal param's, weights
   [m,n] = size(G);

   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         wij = W{i,j};
%        sym = [get(Gij,{'name','?'}),'(s)'];
         diagram(o,'Numeric',{psi,wij},Gij,[m,n,i,j]);
      end
   end
   heading(o);
end

%==========================================================================
% Plot Constraint Transfer Matrix H(s)
%==========================================================================

function o = Hs(o)                     % Double Constrained Trf Fct    
   o = with(o,'simu');

   i = arg(o,1);
   j = arg(o,2);

   G = cook(o,'G');                    % G(s)
   H = cook(o,'H');                    % H(s)
   
   if (i == 0 || j == 0)
      H = opt(H,'maxlen',200);
      str = display(H);
      sym = 'H(s)';
      
      [m,n] = size(H);
      for (i=1:n)
         for (j=1:m)
            Hij = peek(H,i,j);
            Hij = set(Hij,'name',sprintf('H%g%g(s)',i,j));
            disp(Hij);
            fprintf('\n');
         end
      end
      diagram(o,'Trf',sym,H,111);
   else
      Gij = peek(G,i,j);
      Hij = peek(H,i,j);
      
      Hij = set(Hij,'name',sprintf('H%g%g(s)',i,j));
      disp(Hij);

      Hij = opt(Hij,'maxlen',200);
      str = display(Hij);
      [num,den] = peek(Hij);
      
      Hsym = sprintf('H%g%g(s)',i,j);
      Gsym = sprintf('G%g%g(s)',i,j);

      diagram(o,'Trf', Hsym,Hij,3111);
      if length(num) <= length(den)    % proper Hij(s) ?
         diagram(o,'Step',Hsym,Hij,3131); 
      end
      
      diagram(o,'Rloc',Hsym,Hij,3222);
      
      o = opt(o,'color','yyyr');
      diagram(o,'Bode',Hsym,Hij,3221);
   end
   heading(o);
end
function o = HsRloc(o)                 % H(s) Poles/Zeros Overview     
   H = cook(o,'H');                    % G(s)
   [m,n] = size(H);
   
   for (i=1:m)
      for (j=1:n)
         Hij = peek(H,i,j);
         diagram(o,'Rloc','',Hij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = HsStep(o)                 % H(s) Step Response Overview   
   o = with(o,'simu');

   H = cache(o,'consd.H');             % H(s)
   [m,n] = size(H);
   
   for (i=1:m)
      for (j=1:n)
         sym = sprintf('H%g%g(s)',i,j);
         Hij = peek(H,i,j);
         o = opt(o,'color','yyyr');
         if (i == 3 && j == 3)
            Hij = system(Hij,{0,1});   % some dummy
         end
         diagram(o,'Step',sym,Hij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = HsBode(o)                 % L(s) Bode Plot Overview       
   G = cook(o,'G');                    % G(s)
   H = cook(o,'H');                    % H(s)
   [m,n] = size(H);
   
   for (i=1:m)
      for (j=1:n)
         Gsym = sprintf('G%g%g(s)',i,j);
         Hsym = sprintf('H%g%g(s)',i,j);
         Gij = peek(G,i,j);
         Hij = peek(H,i,j);
         
         o = opt(o,'color','g3');
         %diagram(o,'Bode',Gsym,Gij,[m,n,i,j]);
         %hold on
         o = opt(o,'color',o.iif(i==3&&j==3,'r','m'));
         diagram(o,'Bode',Hsym,Hij,[m,n,i,j]);
      end
   end
   heading(o);
end
function o = Consr(o)                  % Rational Constrained Trf Funct
   assert(0);
   message(o,'Rational Constrained Transfer Matrix Not Yet Implemented!');
   return
   
   i = arg(o,1);
   j = arg(o,2);

   H = cache(o,'consr.H');
   if (i == 0 || j == 0)
      H = opt(H,'maxlen',200);
      str = display(H);
      sym = 'H(s)';
   else
      Hij = peek(H,i,j);
      Hij = opt(Hij,'maxlen',200);
      str = display(Hij);
      sym = sprintf('H(%g,%g)',i,j);
   end

   comment = {get(o,{'title',''}),' '};
   for (k=1:size(str,1))
      comment{end+1} = str(k,:);
   end
   message(o,sprintf('Constrained Transfer Function %s (Rational)',sym),...
                     comment);
end

%==========================================================================
% Plot Transfer Matrix G(s)
%==========================================================================

function o = PsQsOverview(o)           % P(s)/Q(s) Bode Plot Overview  
   [P,Q,L0] = cook(o,'P,Q,L0');
   o = opt(o,'critical',1);            % plot critical frequency line
   om0 = round(cook(o,'f0')*2*pi);
   
   diagram(o,'Bode','',P,3211);
   diagram(o,'Bode','',Q,3221);
   diagram(o,'Bode','',L0,3231);   
   xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));
   
   diagram(o,'Nyq','',L0,122);
   
   heading(o);
end
function o = PsQsNormalizing(o)        % P(s)/Q(s) Bode Plot Overview  
   [G31,G33,F0,P,Q,L0] = cook(o,'G31,G33,F0,P,Q,L0');
   o = opt(o,'critical',1);            % plot critical frequency line
   om0 = round(cook(o,'f0')*2*pi);
   
   diagram(o,'Bode','',G31,3211);
   diagram(o,'Bode','',G33,3221);
   diagram(o,'Bode','',F0,3231);
   xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));

   diagram(o,'Bode','',P,3212);
   diagram(o,'Bode','',Q,3222);
   diagram(o,'Bode','',L0,3232);
   xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));
   
   heading(o);
end
function o = L0Shell(o)                % L0(s) @ Shell Object                  
   if ~type(o,{'spm','shell'})
      plot(o,'About');
      return
   end
   
      % increase performance by cache pre-refreshing 
try    
   o = cache(o,o,'trf');               % hard refresh of trf segment
   o = cache(o,o,'principal');         % hard refresh of trf segment
catch
   fprintf('plot/L0Shell(): exception catched\n');
end

     % magnitude of L0(s)
      
   colors = {'yyyyyr','yk','yyyr','y','yyr'};
   
   [list,objs,head] = L0Select(o);
   for (i=1:length(list))
      L0 = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      diagram(o,'Bode','',L0,2211);
   end
   
   for (i=1:length(list))
      L0 = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',0,'bode.phase.enable',1);
      diagram(o,'Bode','',L0,2221);
   end
   
      % plot legend if more than 1 plots
      
   if (length(list) > 1)
      Legend(o,2211,objs);
      Legend(o,2221,objs);
   end
      
      % plot critical frequencies
      
   CriticalFrequency(o,objs,2211);
   CriticalFrequency(o,objs,2221);
   xlabel('omega [1/s]');
   
   for (i=1:length(list))
      L0 = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      diagram(o,'Nyq','',L0,1212);
   end
   
      % plot heading if not shell object
      
   heading(o,head);
end
function o = G31G33L0(o)               % G31(s), G33(s) & L0(s)        
   if ~type(o,{'spm','shell'})
      plot(o,'About');
      return
   end
   
      % increase performance by cache pre-refreshing 
try    
   o = cache(o,o,'trf');               % hard refresh of trf segment
   o = cache(o,o,'principal');         % hard refresh of trf segment
   if opt(o,{'view.critical',1});
      o = cache(o,o,'loop');           % hard refresh loop cache segment
   end
catch
   fprintf('plot/G31G33L0(): exception catched\n');
end

   colors = {'g','gbb','gy','gk','gb','gww','gkk','gbw','gbk'};
   
      % magnitude of G31(s)
      
   o = opt(o,'select.channel',[3 1]);  % select G31(s)
   [list,objs,head] = GijSelect(o);
   for (i=1:length(list))
      Gij = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      diagram(o,'Bode','',Gij,3111);
   end
   
      % magnitude of G33(s)
      
   o = opt(o,'select.channel',[3 3]);  % select G31(s)
   [list,objs,head] = GijSelect(o);
   for (i=1:length(list))
      Gij = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      diagram(o,'Bode','',Gij,3121);
   end
   
      % magnitude of L0(s)
      
   colors = {'yyyyyr','yk','yyyr','y','yyr'};
   
   [list,objs,head] = L0Select(o);
   for (i=1:length(list))
      L0 = list{i};
      col = colors{1+rem(i-1,length(colors))};
      o = opt(o,'color',col);
      o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
      diagram(o,'Bode','',L0,3131);
   end
   
      % plot legend if more than 1 plots
      
   if (length(list) > 1)
      Legend(o,3111,objs);
      Legend(o,3121,objs);
      Legend(o,3131,objs);
   end
   
      % plot critical frequencies
      
   CriticalFrequency(o,objs,3111);
   CriticalFrequency(o,objs,3121);
   CriticalFrequency(o,objs,3131);

   xlabel('omega [1/s]');
   
      % plot heading if not shell object

   heading(o,head);
end
function o = PsQs(o)                   % Principal Transfer Function   
   o = with(o,'simu');
   i = arg(o,1);
   j = arg(o,2);

   [P,Q,F0,L0] = cook(o,'P,Q,F0,L0');

   switch i
      case 0
         G = L0;
      case 1
         G = P;
      case 2
         G = Q;
      case 3
         G = F0;
      otherwise
         assert(0);
   end
         
   if (control(o,'verbose') > 0)
      G = opt(G,'detail',true);
      display(G);
   end
      
   diagram(o,'Trf', '',G,3111);      
   diagram(o,'Step','',G,3221);
   diagram(o,'Rloc','',G,3222);
   diagram(o,'Bode','',G,3231);
   diagram(o,'Nyq', '',G,3232);
   
   heading(o);
end
function o = PsQsRloc(o)               % Ps/Qs(s) Poles/Zeros Overview 
   [P,Q,L0] = cook(o,'P,Q,L0');        % G(s)
   
   diagram(o,'Rloc','',P,2211);
   diagram(o,'Rloc','',Q,2221);
   diagram(o,'Rloc','',L0,1212);
   
   heading(o);
end
function o = PsQsStep(o)               % P(s)/Q(s)) Step Resp. Overview
   [P,Q,L0] = cook(o,'P,Q,L0');        % G(s)
   
   diagram(o,'Step','',P,311);
   diagram(o,'Step','',Q,312);
   diagram(o,'Step','',L0,313);
   
   heading(o);
end
function o = PsQsBode(o)               % P(s)/Q(s) Bode Plot Overview  
   [P,Q,L0] = cook(o,'P,Q,L0');        % G(s)
   
   diagram(o,'Bode','',P,311);
   diagram(o,'Bode','',Q,312);
   diagram(o,'Bode','',L0,313);
   
   heading(o);
end
function o = PsQsNyq(o)                % P(s)/Q(s) Bode Plot Overview  
   [P,Q,L0] = cook(o,'P,Q,L0');        % G(s)
   
   diagram(o,'Nyq','',P,2211);
   diagram(o,'Nyq','',Q,2221);
   diagram(o,'Nyq','',L0,1212);
   
   heading(o);
end
function o = Critical(o)               % Critical TRFs                 
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   [L0,K0,S0,T0] = cook(o,'L0,K0,S0,T0');
   o = opt(o,'critical',1);            % plot critical frequency line
   om0 = round(cook(o,'f0')*2*pi);
   mode = arg(o,1);

   f0 = cook(o,'f0');
   om0 = round(2*pi*f0);
    
   switch mode
      case 'K0'
         Lc = set(K0*L0,'name','Lc(s)');
         o = opt(o,'color','c1');
         o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
         diagram(o,'Bode','',Lc,2211);
         
         o = opt(o,'bode.magnitude.enable',0,'bode.phase.enable',1);
         diagram(o,'Bode','',Lc,2221);
         xlabel('omega [1/s]'); 
         subplot(o,2212);
         stable(o,K0*L0);
         title(sprintf('Critical Gain: %g @ omega: %g 1/s, f: %g Hz',...
               o.rd(K0,4),om0,o.rd(om0/2/pi,1)));

         Lc = set(K0*L0,'name','Lc(s)');
         o = opt(o,'color','c1');
         o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
         diagram(o,'Nyq','',Lc,2222);
         title(sprintf('Critical Open Loop Lc(jw) - Gain: %g @ omega: %g 1/s, f: %g Hz',...
               o.rd(K0,4),om0,o.rd(om0/2/pi,1)));

      case 'LcBode'
         Lc = set(K0*L0,'name','Lc(s)');
         o = opt(o,'color','c1');
         o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
         diagram(o,'Bode','',Lc,2111);
         o = opt(o,'bode.magnitude.enable',0,'bode.phase.enable',1);
         diagram(o,'Bode','',Lc,2121);

      case 'LcMagni'
         Lc = set(K0*L0,'name','Lc(s)');
         o = opt(o,'color','c1');
         o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
         diagram(o,'Bode','',Lc,111);
         title(sprintf('Critical Open Loop Lc(jw) - Gain: %g @ omega: %g 1/s, f: %g Hz',...
               o.rd(K0,4),om0,o.rd(om0/2/pi,1)));
         
      case 'LcNyq'
         Lc = set(K0*L0,'name','Lc(s)');
         o = opt(o,'color','c1');
         o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
         diagram(o,'Nyq','',Lc,111);
         title(sprintf('Critical Open Loop Lc(jw) - Gain: %g @ omega: %g 1/s, f: %g Hz',...
               o.rd(K0,4),om0,o.rd(om0/2/pi,1)));
      case 'S0'
         diagram(o,'Bode','',S0,2111);
         xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));
         diagram(o,'Step','',S0,2121);
      case 'T0'
         diagram(o,'Bode','',T0,2111);
         xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));
         diagram(o,'Step','',T0,2121);
   end
   
   heading(o);
end
function o = T0S0(o)                   % T0(s), S0(s)                  
   o = opt(o,'critical',1);            % plot critical frequency line
   om0 = round(cook(o,'f0')*2*pi);
   sym = arg(o,1);
   G = cook(o,sym);

   diagram(o,'Trf', '',G,3111);      
   diagram(o,'Step','',G,3221);
   diagram(o,'Rloc','',G,3222);
   diagram(o,'Bode','',G,3231);
   xlabel(sprintf('omega [1/s]   (omega_0: %g/s)',om0));
   diagram(o,'Nyq', '',G,3232);
    
   heading(o);
end
function o = MagniPhase(o)             % Magnitude/Phase Plot               
   sym = arg(o,1);
   G = cook(o,sym);
   
   diagram(o,'Magni','',G,211);
   diagram(o,'Phase','',G,212);
   
   if opt(o,{'view.critical',1});
      o = cache(o,o,'loop');           % hard refresh loop cache segment
   end
   
   CriticalFrequency(o,{o},211);
   CriticalFrequency(o,{o},212);
   
   heading(o);
end
function o = PsBode(o)                 % L0(s) Bode Plot               
   L0 = cook(o,'L0');
   
   diagram(o,'Magni','',L0,211);
   diagram(o,'Phase','',L0,212);
   
   CriticalFrequency(o,{o},211);
   CriticalFrequency(o,{o},212);
   
   heading(o);
end
function o = L0Bode(o)                 % L0(s) Bode Plot               
   L0 = cook(o,'L0');
   
   diagram(o,'Magni','',L0,211);
   diagram(o,'Phase','',L0,212);
   
   CriticalFrequency(o,{o},211);
   CriticalFrequency(o,{o},212);
   
   heading(o);
end
function o = L0Precision(o)            % Zero/Pole Precision           
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
      
   o = cache(o,o,'principal');         % hard refresh principal cache segment
   L0 = cook(o,'L0');
   diagram(o,'Precision','',L0,1111);
      
   heading(o);
end

%==========================================================================
% Plot Open Loop Transfer Matrix L(s)
%==========================================================================

function o = Ls(o)                     % Linear System Trf Matrix      
   o = with(o,'simu');

   i = arg(o,1);
   j = arg(o,2);

   L = cache(o,'consd.L');
   
   if (i == 0 || j == 0)
      L = opt(L,'maxlen',200);
      str = display(L);
      sym = 'L(s)';
      
      [m,n] = size(L);
      for (i=1:m)
         for (j=1:n)
            Lij = peek(L,i,j);
            Lij = set(Lij,'name',sprintf('L%g%g(s)',i,j));
            disp(Lij);
            fprintf('\n');
         end
      end
      diagram(o,'Trf',sym,L,111);
   else
      Lij = peek(L,i,j);
      
      Lij = set(Lij,'name',sprintf('L%g%g(s)',i,j));
      disp(Lij);

      Lij = opt(Lij,'maxlen',200);
      str = display(Lij);
      
      Lsym = sprintf('L%g%g(s)',i,j);
      mode = o.iif(i<=2,'Vstep','Step');

      diagram(o,'Trf', Lsym,Lij,3111);
      diagram(o,'Rloc',Lsym,Lij,3222);
      diagram(o,mode,Lsym,Lij,3131);  

      o = opt(o,'color','bc');
      diagram(o,'Bode',Lsym,Lij,3221);
   end
   heading(o);
end
function o = LsStep(o)                 % L(s) Step Response Overview   
   o = with(o,'simu');

   L = cache(o,'consd.L');             % L(s)
   [m,n] = size(L);
   
   for (i=1:2)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         diagram(o,'Step',sym,Lij,[4,3,i,j]);
         ylabel(sprintf('F%g -> y%g [%s]',j,i,opt(o,{'scale.yunit',''})))
      end
   end
   
   for (i=3:4)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         o = opt(o,'color','bc');
         diagram(o,'Vstep',sym,Lij,[4,3,i,j]);
         ylabel(sprintf('F%g -> dy%g/dt [%s]',j,i-2,opt(o,{'scale.vunit',''})))
      end
   end

   for (i=5:5)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         o = opt(o,'color','r');
         diagram(o,'Fstep',sym,Lij,[2,3,j,3]);
         ylabel(sprintf('F%g -> F3 [%s]',j,opt(o,{'scale.funit',''})))
      end
   end
   
   heading(o);
end
function o = LsBode(o)                 % L(s) Bode Plot Overview       
   L = cache(o,'consd.L');             % L(s)
   [m,n] = size(L);
   
   for (i=1:2)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         o = opt(o,'color','yyyr');
         diagram(o,'Bode',sym,Lij,[4,3,i,j]);
         ylabel(sprintf('F%g -> y%g',j,i))
      end
   end
   
   for (i=3:4)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         o = opt(o,'color','bc');
         diagram(o,'Bode',sym,Lij,[4,3,i,j]);
         ylabel(sprintf('F%g -> dy%g/dt',j,i-2))
      end
   end

   for (i=5:5)
      for (j=1:n)
         sym = sprintf('L%g%g(s)',i,j);
         Lij = peek(L,i,j);
         o = opt(o,'color','r');
         diagram(o,'Bode',sym,Lij,[2,3,j,3]);
         ylabel(sprintf('F%g -> F3',j))
      end
   end
   
   heading(o);
end

%==========================================================================
% Plot Closed Loop Transfer Matrix T(s)
%==========================================================================

function o = Ts(o)                     % T(s): Closed Loop Trf Matrix  
   o = with(o,'simu');

   i = arg(o,1);
   j = arg(o,2);

   T = cache(o,'process.T');
   
   if (i == 0 || j == 0)
      T = opt(T,'maxlen',200);
      str = display(T);
      sym = 'T(s)';
      
      [m,n] = size(T);
      for (i=1:m)
         for (j=1:n)
            Tij = peek(T,i,j);
            Tij = set(Tij,'name',sprintf('T%g%g(s)',i,j));
            disp(Tij);
            fprintf('\n');
         end
      end
      diagram(o,'Trf',sym,T,111);
   else
      Tij = peek(T,i,j);
      
      Tij = set(Tij,'name',sprintf('T%g%g(s)',i,j));
      disp(Tij);

      Tij = opt(Tij,'maxlen',200);
      str = display(Tij);
      
      Tsym = sprintf('T%g%g(s)',i,j);
      mode = o.iif(i<=2,'Vstep','Step');

      diagram(o,'Trf', Tsym,Tij,3111);
      diagram(o,'Rloc',Tsym,Tij,3222);
      
      o = opt(o,'color',o.iif(i<=2,'r','bc'));
      diagram(o,mode,Tsym,Tij,3131);  

      o = opt(o,'color','r');
      diagram(o,'Bode',Tsym,Tij,3221);
   end
   heading(o);
end
function o = TsStep(o)                 % T(s) Step Response Overview   
   o = with(o,'simu');

   T = cache(o,'process.T');           % T(s)
   [m,n] = size(T);
   
   for (i=1:2)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','rk');
         diagram(o,'Step',sym,Tij,[4,3,i,j]);
         ylabel(sprintf('F%g -> y%g [%s]',j,i,opt(o,{'scale.yunit',''})))
      end
   end
   
   for (i=3:4)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','bc');
         diagram(o,'Vstep',sym,Tij,[4,3,i,j]);
         ylabel(sprintf('F%g -> dy%g/dt [%s]',j,i-2,opt(o,{'scale.vunit',''})))
      end
   end

   for (i=5:5)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','r');
         diagram(o,'Fstep',sym,Tij,[2,3,j,3]);
         ylabel(sprintf('F%g -> F3 [%s]',j,opt(o,{'scale.funit',''})))
      end
   end
   
   heading(o);
end
function o = TsBode(o)                 % T(s) Bode Plot Overview       
   T = cache(o,'process.T');           % T(s)
   [m,n] = size(T);
   
   for (i=1:2)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','g');
         diagram(o,'Bode',sym,Tij,[4,2,i,j]);
         ylabel(sprintf('F%g -> y%g',j,i))
      end
   end
   
   for (i=3:4)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','bc');
         diagram(o,'Bode',sym,Tij,[4,2,2,j]);
         ylabel(sprintf('F%g -> dy%g/dt',j,i-2))
      end
   end

   for (i=5:6)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','r');
         diagram(o,'Bode',sym,Tij,[4,2,3,j]);
         ylabel(sprintf('F%g -> d2y%g/dt2',j,i-4))
      end
   end
   
   for (i=7:7)
      for (j=1:n)
         sym = sprintf('T%g%g(s)',i,j);
         Tij = peek(T,i,j);
         o = opt(o,'color','yyyr');
         diagram(o,'Bode',sym,Tij,[4,2,4,j]);
         ylabel(sprintf('F%g -> F3',j))
      end
   end
   
   heading(o);
end

%==========================================================================
% Force Step & Ramp Responses
%==========================================================================

function o = Step(o)                   % Step Response                 
   o = with(o,'simu');

   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   oo = Corasim(o);                    % convert to corasim object
   
   index = arg(o,1);
   t = Time(o);
   u = StepInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   heading(o,sprintf('Step Response: F%g->y (%s)',index,Title(o)));
end
function o = ForceStep(o)              % Force Step Response           
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end

   index = arg(o,1);                   % get force component index
   if (index == 0)
      ForceStepOverview(o);
      return
   elseif (index >= 10)
      ForceStepOrbit(o,index/10);
      return
   end
   
   oo = Corasim(o);                    % convert to corasim object      
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = StepInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot input signals (forces)
      
   m = size(u,1);
   for (i=1:m)
      sym = sprintf('F%g',i);
      diagram(o,'Force',sym,t,u(i,:),[m 3 3*i-2]);
      set(gca,'Ylim',[0 1.2*Fmax]);
   end

      % plot modes (internal state variables)
   
   modes = opt(o,{'view.modes',5});
   n = size(x,1);
   nx = min(modes,n/2);
   
   if (n/2 <= modes)
      for (i=1:nx)
         sym = sprintf('x%g',i);
         diagram(o,'Mode',sym,t,x(i,:),[nx 3 3*i-1]);
      end
   else
      diagram(o,'Mode','x',t,x,[1 3 2]);
   end
      
      % plot output signals (elongations)
      
   l = size(y,1);
   for (i=1:l)
      sym = sprintf('y%g',i);
      diagram(o,'Elongation',sym,t,y(i,:),[m 3 3*i]);
   end   
   
   heading(o,sprintf('Step Response: F%g->y - %s',index,Title(o)));
end
function o = ForceStepOverview(o)      % Force Step Response Overview  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
      
   B = data(o,'B');
   m = size(B,2);                      % number of inputs
   
   for (index=1:m)   
      oo = Corasim(o);                 % convert to corasim object      
      Fmax = opt(o,{'Fmax',100});
      t = Time(o);
      u = StepInput(oo,t,index,Fmax);

      oo = sim(oo,u,[],t);
      [t,u,y,x] = var(oo,'t,u,y,x');

         % plot output signals (elongations)

      l = size(y,1);
      for (i=1:l)
         sym = sprintf('y%g',i);
         diagram(o,'Elongation',sym,t,y(i,:),[l m i index]);
         title(sprintf('Elongation y%g (F%g)',i,index));
      end   
   end

   heading(o,sprintf('Step Response: F%g->y - %s',index,Title(o)));
end
function o = ForceStepOrbit(o,index)   % Force Step Orbit              
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end

   oo = Corasim(o);                    % convert to corasim object      
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = StepInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot input signals (forces)
      
   m = size(u,1);
   for (i=1:m)
      sym = sprintf('F%g',i);
      diagram(o,'Force',sym,t,u(i,:),[m 3 3*(i-1)+1]);
      set(gca,'Ylim',[0 1.2*Fmax]);
   end
      
      % plot output signals (elongations)
      
   l = size(y,1);
   for (i=1:l)
      sym = sprintf('y%g',i);
      diagram(o,'Elongation',sym,t,y(i,:),[m 3 3*(i-1)+2]);
   end
   
      % plot output orbits (elongations)
      
   diagram(o,'Orbit','y3(y1)',y(1,:),y(3,:),[2 3 3]);
   diagram(o,'Orbit','y2(y1)',y(1,:),y(2,:),[2 3 6]);
   
   heading(o,sprintf('Step Response/Orbit: F%g->y - %s',index,Title(o)));
end

function o = Ramp(o)                   % Ramp Response                 
   if ~o.is(type(o),{'spm'})
      o = [];  return
   end
   
   oo = Corasim(o);                    % convert to corasim object   
   index = arg(o,1);
   t = Time(o);
   u = RampInput(oo,t,index);

   oo = sim(oo,u,[],t);
   plot(oo);
   
   heading(o,sprintf('Ramp Response: F%g->y (%s)',index,Title(o)));
end
function o = ForceRamp(o)              % Force Ramp Response           
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end

   index = arg(o,1);                   % get force component index
   if (index == 0)
      ForceRampOverview(o);
      return
   elseif (index >= 10)
      ForceRampOrbit(o,index/10);
      return
   end
   
   oo = Corasim(o);                    % convert to corasim object      
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot input signals (forces)
      
   m = size(u,1);
   for (i=1:m)
      sym = sprintf('F%g',i);
      diagram(o,'Force',sym,t,u(i,:),[m 3 3*i-2]);
      set(gca,'Ylim',[0 1.2*Fmax]);
   end

      % plot modes (internal state variables)
   
   modes = opt(o,{'view.modes',5});
   n = size(x,1);
   nx = min(modes,n/2);
   
   if (n/2 <= modes)
      for (i=1:nx)
         sym = sprintf('x%g',i);
         diagram(o,'Mode',sym,t,x(i,:),[nx 3 3*i-1]);
      end
   else
      diagram(o,'Mode','x',t,x,[1 3 2]);
   end
      
      % plot output signals (elongations)
      
   l = size(y,1);
   for (i=1:l)
      sym = sprintf('y%g',i);
      diagram(o,'Elongation',sym,t,y(i,:),[m 3 3*i]);
   end   
   
   heading(o,sprintf('Step Response: F%g->y - %s',index,Title(o)));
end
function o = ForceRampOverview(o)      % Force Ramp Response Overview  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
      
   B = data(o,'B');
   m = size(B,2);                      % number of inputs
   
   for (index=1:m)   
      oo = Corasim(o);                 % convert to corasim object      
      Fmax = opt(o,{'Fmax',100});
      t = Time(o);
      u = RampInput(oo,t,index,Fmax);

      oo = sim(oo,u,[],t);
      [t,u,y,x] = var(oo,'t,u,y,x');

         % plot output signals (elongations)

      l = size(y,1);
      for (i=1:l)
         sym = sprintf('y%g',i);
         diagram(o,'Elongation',sym,t,y(i,:),[l m (i-1)*m+index]);
         title(sprintf('Elongation y%g (F%g)',i,index));
      end   
   end

   heading(o,sprintf('Step Response: F%g->y - %s',index,Title(o)));
end
function o = ForceRampOrbit(o,index)   % Force Ramp Orbit              
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end

   oo = Corasim(o);                    % convert to corasim object      
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot input signals (forces)
      
   m = size(u,1);
   for (i=1:m)
      sym = sprintf('F%g',i);
      diagram(o,'Force',sym,t,u(i,:),[m 3 3*(i-1)+1]);
      set(gca,'Ylim',[0 1.2*Fmax]);
   end
      
      % plot output signals (elongations)
      
   l = size(y,1);
   for (i=1:l)
      sym = sprintf('y%g',i);
      diagram(o,'Elongation',sym,t,y(i,:),[m 3 3*(i-1)+2]);
   end
   
      % plot output orbits (elongations)
      
   diagram(o,'Orbit','y3(y1)',y(1,:),y(3,:),[2 3 3]);
   diagram(o,'Orbit','y2(y1)',y(1,:),y(2,:),[2 3 6]);
   
   heading(o,sprintf('Ramp Response/Orbit: F%g->y - %s',index,Title(o)));
end

function o = MotionRsp(o)              % Motion Response               
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   index = arg(o,1);                   % get force component index
   switch index
      case 31
      case 32
      case 33
         Hij = cache(o,'consd.H33');
   end
   
   [num,den] = peek(Hij);
   den = [den 0 0];
   
   oo = system(inherit(corasim,o),{num,den});
   display(oo);
   
      % get motion as input signal
      
   [t,u] = MotionInput(o);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot results
      
   diagram(o,'Elongation','a3',t,u,2211);
   diagram(o,'Force','F3',t,y,2212);
end
function [t,u] = MotionInput(o)        % Motion Input                  
   [smax,vmax,amax,tj] = opt(with(o,'motion'),'smax,vmax,amax,tj');
   oo = inherit(corasim,o);
   
   oo = data(oo,'smax,vmax,amax,tj',smax,vmax,amax,tj);
   oo = data(oo,'tunit,sunit','s','mm');
   oo.par.title = 'Motion Input';
   
   oo = with(oo,'simu');
   oo = motion(oo,'Brew');
   
   [t,u] = var(oo,'t,a');
end

function o = NoiseRsp(o)               % Noise Response                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Ta1 = cook(o,'Ta1');
   display(Ta1);
   
   [num,den] = peek(Ta1);
   oo = system(inherit(corasim,o),{num,den});
   
      % get noise as input signal
      
   [t,u] = NoiseInput(oo);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = var(oo,'t,u,y,x');
   
      % plot results
      
   diagram(o,'Force','Fc',t,u,2211);
   diagram(o,'Acceleration','a1',t,y,2221);
   
      % Bode diagram
      
   diagram(o,'Astep','Ta1(s)',Ta1,2212);
   diagram(o,'Bode','Ta1(s)',Ta1,2222);
end
function [t,u] = NoiseInput(o)         % Noise Input                   
   Nmax = opt(o,{'simu.Nmax',1});
   t = Time(o);
   u = Nmax*randn(size(t));
end

%==========================================================================
% Plot Output Signals
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
% Stability
%==========================================================================

function o = Stability(o)              % Plot Stability Margin         
   if ~type(o,{'pkg'})
      plot(o,'About');
      return
   end
   
   package = get(o,'package');
   if isempty(package)
      error('no package ID provided');
   end
      
      % get object list of package
      % note that first list element is the package object, which has 
      % to been deleted. calculate stability margin for all data objects
      
   olist = tree(o);                    % get list of package objects
   list = olist{1};                    % pick object list
   list(1) = [];                       % delete package object from list

   o = with(o,{'style','process','stability'});
   n = length(list);

   x = Axes(o);                        % get variation range and plot axes
   
      % calculate stability margin and plot
   
   mu = opt(o,{'process.mu',0.1});
   
   for (i=1:n)                         % calc & plot stability margin  
      txt = sprintf('calculate stability margin of %s',get(oo,'title'));
      progress(o,txt,i/n*100);
      
      oo = list{i};
      oo = inherit(oo,o);
      
      if (opt(o,'process.contact') == 0)
%        margin(i) = stable(oo);
         margin(i) = cook(oo,'K0') / mu;
      else
         margin(i) = cook(oo,'K0') / mu;
      end
      
      
      if (margin(i) > 1)
         plot(o,x(i),margin(i),'g|o2');
      else
         plot(o,x(i),margin(i),'r|o2');
      end
      idle(o);                         % show graphics
   end
   
   progress(o);                        % progress completed
   heading(o);                         % add heading
   
   function x = Axes(o)                % Plot Axes                     
      variation = get(o,'variation');
      for (i=1:n)
         oo = list{i};

         if ~isempty(variation)
            x(i) = get(oo,{variation,i});
         else
            x(i) = i;
         end
      end   
      plot(o,x,0*x,'K.');
      hold on;
      plot(o,get(gca,'xlim'),[1 1],'K-.2');

      title(sprintf('Stability Margin%s',More(o)));

      ylabel('Stability Margin');

      if ~isempty(variation)
         xlabel(sprintf('Variation Parameter: %s',variation));
      else
         xlabel('Variation Parameter');
      end

      subplot(o);                         % subplot complete
   end
   function txt = More(o)              % More Title Text               
      txt = '';  sep = '';
      
      mu = opt(o,'process.mu');
      if ~isempty(mu)
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
