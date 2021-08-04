function oo = plot(o,varargin)         % CTRL Plot Method
%
% PLOT   CTRL plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: CTRL, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @Overview,@Bode,@Step,@Impulse);
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
   oo = mitem(o,'Overview',{@WithCuo,'Plot'});
   oo = mitem(o,'-');
   oo = mitem(o,'Bode Plot',{@WithCuo,'Bode'});
   oo = mitem(o,'Step Response',{@WithCuo,'Step'});
   oo = mitem(o,'Impulse Response',{@WithCuo,'Impulse'});
end
function oo = Filter(o)                % Add Filter Menu Items
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mseek(o,{'#','Select'});
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Filter');
   oooo = mitem(ooo,'Mode','','filter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'filter.type');
   choice(oooo,{{'Order 2 Low Pass','LowPass2'},...
                {'Order 2 High Pass','HighPass2'},...
                {'Order 4 Low Pass','LowPass4'},...
                {'Order 4 High Pass','HighPass4'}},{});
   oooo = mitem(ooo,'Bandwidth',{},'filter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'filter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'filter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
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
      case 'smp'
         oo = Overview(o);
      case 'alt'
         oo = PlotXY(o);
      otherwise
         oo = [];  return              % no idea how to plot
   end
end

%==========================================================================
% Local Plot Functions (are checking type)
%==========================================================================

function oo = Overview(o)              % Plot Overview                 
   if ~type(o,{'smp','alt'})
      oo = []; return                  % no idea how to plot this type
   end

   oo = opt(o,'subplot',[2 2 1]);
   PlotX(oo);

   oo = opt(oo,'subplot',[2 2 3]);
   oo = opt(oo,'title',' ');           % prevent from drawing a title
   PlotY(oo);

   oo = opt(oo,'subplot',[1 2 2]);
   oo = opt(oo,'title','X/Y-Orbit');   % override title
   PlotXY(oo);

   heading(o);
end
function o = Bode(o)                   % Bode Plot    
   bode(o.data.sys);
   subplot(o);
end
function o = Step(o)                   % Step Response
   step(o.data.sys);
   subplot(o);
end
function o = Impulse(o)                % Impulse Response              
   impulse(o.data.sys);
   subplot(o);
end

%==========================================================================
% Plot Helpers (no more type check)
%==========================================================================

function BodePlot(o,sub)
   subplot(o,sub);
   bode(o.data.sys);
   subplot(o);
end
function StepPlot(o,sub)
   subplot(o,sub);
   bode(o.data.sys);
   subplot(o);
end