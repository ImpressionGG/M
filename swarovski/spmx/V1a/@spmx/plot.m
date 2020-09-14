function oo = plot(o,varargin)         % SPMX Plot Method              
%
% PLOT   SPMX plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'Overview')         % Overview about eigenvalues of SPM
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: SPMX, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @Overview,@About,@Real,@Imag,@Complex,...
                       @Step,@Ramp,@ForceRamp,@ForceStep,...
                       @AnalyseRamp,@NormRamp);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
%
% MENU  Setup plot menu. Note that plot functions are best invoked via
%       Callback or Basket functions, which do some common tasks
%
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'Overview',{@WithCuo,'Plot'});
   oo = mitem(o,'-');
   oo = mitem(o,'Eigenvalues');
   ooo = mitem(oo,'Complex', {@WithCuo,'Complex'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Real Part',{@WithCuo,'Real'});
   ooo = mitem(oo,'Imaginary Part',{@WithCuo,'Imag'});

   oo = mitem(o,'-');
   oo = StepResponse(o);               % step response sub-menu
   oo = RampResponse(o);               % ramp response sub-menu
end
function oo = StepResponse(o)          % Step Response Menu            
   oo = mitem(o,'Step Response');
   
   ooo = mitem(oo,'Force Step @ F1',{@WithCuo,'ForceStep'},1);
   ooo = mitem(oo,'Force Step @ F2',{@WithCuo,'ForceStep'},2);
   ooo = mitem(oo,'Force Step @ F3',{@WithCuo,'ForceStep'},3);    
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F1 Excitation',{@WithCuo,'Step'},1);
   ooo = mitem(oo,'F2 Excitation',{@WithCuo,'Step'},2);
   ooo = mitem(oo,'F3 Excitation',{@WithCuo,'Step'},3);
end
function oo = RampResponse(o)          % Ramp Response Menu            
   oo = mitem(o,'Ramp Response');

   ooo = mitem(oo,'Force Ramp @ F1',{@WithCuo,'ForceRamp'},1);
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'ForceRamp'},2);
   ooo = mitem(oo,'Force Ramp @ F3',{@WithCuo,'ForceRamp'},3);   

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'F1 Excitation',{@WithCuo,'Ramp'},1);
   ooo = mitem(oo,'F2 Excitation',{@WithCuo,'Ramp'},2);
   ooo = mitem(oo,'F3 Excitation',{@WithCuo,'Ramp'},3);
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
function oo = About(o)                 % About Object                  
   oo = menu(o,'About');               % keep it simple
end

%==========================================================================
% Plot Eigenvalues
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

   plot(o,real,imag,'yyyrx');
   hold on;
   plot(o,real,imag,'yyyro');

   title('Eigenvalues in Complex Plane');
   xlabel('real part');  ylabel('imaginary part');

%  set(gca,'DataAspectRatio',[1 1 1]);
   heading(o);
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function o = Step(o)                   % Step Response                 
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
      
   oo = Corasim(o);                    % convert to corasim object      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = StepInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = data(oo,'t,u,y,x');
   
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
      
   oo = Corasim(o);                    % convert to corasim object      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   [t,u,y,x] = data(oo,'t,u,y,x');
   
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
function o = OldForceRamp(o)           % Force Ramp Response           
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   oo = Corasim(o);                    % convert to corasim object      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});
   t = Time(o);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Ramp Response: F%g->y - %s',index,Title(o)));
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

