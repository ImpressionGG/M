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
                   @Overview,@About,@Image,@Real,@Imag,@Complex,...
                   @TrfDisp,@TrfRloc,@TrfStep,@TrfBode,@TrfMagni,...
                   @TrfNyq,@TrfWeight,... 
                   @Gs,@Trfr,@GsRloc,@GsStep,@GsBode,@GsWeight,@GsFqr,...
                   @Hs,@Consr,@HsRloc,@HsStep,@HsBode,...
                   @Ls,@LsStep,@LsBode,@Ts,@TsStep,@TsBode,...
                   @Step,@Ramp,@ForceRamp,@ForceStep,@MotionRsp,@NoiseRsp,...
                   @Stability,...
                   @AnalyseRamp,@NormRamp);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                   % Setup Plot Menu              
   switch type(current(o))
      case 'spm'
         oo = SpmMenu(o);
      case 'pkg'
         oo = PkgMenu(o);
      otherwise
         oo = mitem(o,'About',{@WithCuo,'About'});
   end
end
function oo = SpmMenu(o)                % Setup Plot Menu @ SPM-Type   
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
   oo = mitem(o,'-');
   oo = TransferMatrix(o);             % G(s)
   oo = ConstrainMatrix(o);            % H(s)
   
   %oo = mitem(o,'-');
   %oo = OpenLoopSystem(o);            % L(s)
   %oo = ClosedLoopSystem(o);          % T(s)

   oo = mitem(o,'-');
   oo = StepResponse(o);               % step response sub-menu
   oo = RampResponse(o);               % ramp response sub-menu
   oo = MotionResponse(o);             % motion response sub menu
   oo = NoiseResponse(o);              % noise response sub menu
end
function oo = PkgMenu(o)                % Setup Plot Menu @ PKG-Type   
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
end
function oo = TransferMatrix(o)        % Transfer Matrix Menu          
   oo = current(o);
   [B,C] = data(oo,'B,C');
   [~,m] = size(B);
   [l,~] = size(C);
   
   oo = mhead(o,'G(s): Transfer Matrix');
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'GsRloc'});
   ooo = mitem(oo,'Step Responses',{@WithCuo,'GsStep'});
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'GsBode'});
   ooo = mitem(oo,'Modal Weights',{@WithCuo,'GsWeight'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Frequency Response',{@WithCuo,'GsFqr'});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,sprintf('G(s)'),{@WithCuo,'Gs',0,0});
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
   
   oo = mhead(o,'H(s): Constrained Matrix');
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'HsRloc'});
   ooo = mitem(oo,'Step Responses',{@WithCuo,'HsStep'});
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

   o = cache(o,o,'eigen');             % hard refresh 'eigen' cache segment
   
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
   im = imread(path);
   if ~isempty(im)
      hdl = image(im);
      axis off
   else
      message('cannot display image',{['path: ',path]});
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
   
   index = cache(o,'eigen.index');
   real = cache(o,'eigen.real');
   
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
   
   index = cache(o,'eigen.index');
   imag = cache(o,'eigen.imag');
   
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
   
   real = cache(o,'eigen.real');
   imag = cache(o,'eigen.imag');

   plot(o,real,imag,'Ko');
   hold on;
   plot(o,real,imag,'rp');
   plot(o,real,imag,'rh');
   plot(o,real,imag,'r.');

   title('Eigenvalues in Complex Plane');
   xlabel('real part');  ylabel('imaginary part');

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
   
   sym = sprintf('G%g%g(s)',i,j);
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
   
   Gij = TrfSelect(o);   
   diagram(o,'Rloc','',Gij,1111);      
   heading(o);
end
function o = TrfStep(o)                % Step Response Plot            
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Gij = TrfSelect(o);
   diagram(o,'Step','',Gij,2111);
   
   o = opt(o,'simu.tmax',1);
   diagram(o,'Step','',Gij,2112);
   heading(o);
end
function o = TrfBode(o)                % Bode Plot                     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Gij = TrfSelect(o);
   o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
   diagram(o,'Bode','',Gij,2111);      
   o = opt(o,'bode.magnitude.enable',0,'bode.phase.enable',1);
   diagram(o,'Bode','',Gij,2112);      
   heading(o);
end
function o = TrfMagni(o)               % Magnitude Plot                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Gij = TrfSelect(o);
   o = opt(o,'bode.magnitude.enable',1,'bode.phase.enable',0);
   diagram(o,'Bode','',Gij,1111);      
   heading(o);
end
function o = TrfNyq(o)                 % Nyquist Plot                  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Gij = TrfSelect(o);
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

function Gij = TrfSelect(o)            % Select Transfer Function      
   idx = opt(o,{'select.channel',[1 1]});
   i = idx(1);  j = idx(2);
   
   G = cook(o,'G');
   Gij = peek(G,i,j);
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
function o = GsFqr(o)                  % G(s) Frequency Response Error 
   G = cook(o,'G');                    % G(s)
   [m,n] = size(G);
   
   for (i=1:m)
      for (j=1:n)
         sym = [get(Gij,{'name','?'}),'(s)'];
         Gij = peek(G,i,j);
         diagram(o,'Numeric',sym,Gij,[m,n,i,j]);
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
% Plot Menu Plugins
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
      
      % note that first list element was the package object, which has 
      % been deleted. calculate stability margin for all data objects
      
if(0)
   o = pull(o);                        % get shell object
   [oo,idx] = current(o);              % save index of current object

   for (i=1:length(o.data))
      oo = o.data{i};
      if ~isequal(get(oo,'package'),package) || ~type(oo,{'spm'})
         continue;
      end
      
      current(o,i);
      [oo,~,rfr] = cache(oo,oo,'trf');
      [oo,~,rfr] = cache(oo,oo,'consd');
      [oo,~,rfr] = cache(oo,oo,'process');
      
      idle(o);
   end
   current(o,idx);                     % restore current object index
end   
      % get object list of package
      
   olist = tree(o);                    % get list of package objects
   list = olist{1};                    % pick object list
   list(1) = [];                       % delete package object from list

   o = with(o,'style');

   n = length(list);

      % get variation range and plot axes
      
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
   subplot(o);                         % refresh graphics

      % calculate stability margin and plot
      
   for (i=1:n)      
      txt = sprintf('calculate stability margin of %s',get(oo,'title'));
      progress(o,txt,i/n*100);
      
      oo = list{i};
      try
         margin(i) = stable(oo); 
         if (margin(i) > 1)
            plot(o,x(i),margin(i),'g|o2');
         else
            plot(o,x(i),margin(i),'r|o2');
         end
         idle(o);                      % show graphics
      catch
         margin(i) = NaN;
      end
   end
   
   progress(o);                        % progress completed
   
   mu = opt(o,'process.mu');
   if isempty(mu)
      title('Stability Margin @ Parameter Variation');
   else
      title(sprintf('Stability Margin @ Parameter Variation (mu = %g)',mu));
   end
   
   ylabel('Stability Margin');
   
   if ~isempty(variation)
      xlabel(sprintf('Variation Parameter: %s',variation));
   else
      xlabel('Variation Parameter');
   end
   
   subplot(o);                         % subplot complete
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
