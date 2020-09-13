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
                       @ForceRamp,@AnalyseRamp,@NormRamp);
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

   ooo = mitem(oo,'-');
   ooo = StepResponse(o);              % step response sub-menu
   ooo = RampResponse(o);              % ramp response sub-menu
end
function oo = StepResponse(o)          % Step Response Menu            
   oo = mitem(o,'Step Response');
   oo = mitem(oo,'F1 Excitation',{@WithCuo,'Step'},1);
   oo = mitem(oo,'F2 Excitation',{@WithCuo,'Step'},2);
   oo = mitem(oo,'F3 Excitation',{@WithCuo,'Step'},3);
end
function oo = RampResponse(o)          % Ramp Response Menu            
   oo = mitem(o,'Ramp Response');
   ooo = mitem(oo,'F1 Excitation',{@WithCuo,'Ramp'},1);
   ooo = mitem(oo,'F2 Excitation',{@WithCuo,'Ramp'},2);
   ooo = mitem(oo,'F3 Excitation',{@WithCuo,'Ramp'},3);
 
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Force Ramp @ F1',{@WithCuo,'ForceRamp'},1);
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'ForceRamp'},2);
   ooo = mitem(oo,'Force Ramp @ F3',{@WithCuo,'ForceRamp'},3);   
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
% Helper
%==========================================================================

