function oo = plot(o,varargin)         % TEST5 Plot Method
%
% PLOT   TEST5 plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'About')            % about object
%           plot(o,'Overview')         % plot object overview
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: TEST5, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @About,@Overview,@PlotX,@PlotY,@PlotXY);
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
   oo = mitem(o,'X',{@WithBsk,'PlotX'});
   oo = mitem(o,'Y',{@WithBsk,'PlotY'});
   oo = mitem(o,'XY', {@WithBsk,'PlotXY'});

   oo = Filter(o);                     % add Filter menu to Select menu
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
   if ~isa(oo,'corazon')               % did corazon/plot handle the call
      return                           % in such case we are done - bye!
   end

      % otherwise dispatch on object type

   cls(o);                             % clear screen
   switch o.type
      case 'smp'
         oo = Overview(o);
      case 'alt'
         oo = PlotXY(o);
      otherwise
         oo = About(o);                % no idea how to plot
   end
end

%==========================================================================
% Local Plot Functions (are checking type)
%==========================================================================

function oo = About(o)                 % About Object
   oo = plot(corazon(o),'About');
end
function oo = Overview(o)              % Plot Overview
   if ~type(o,{'smp','alt'})
      oo = About(o);            
      return
   end

   oo = subplot(o,2211);
   PlotX(oo);

   oo = subplot(o,2221);
   PlotY(oo);

   oo = subplot(o,1212);
   PlotXY(oo);
   title(axes(oo),'X/Y-Orbit');        % override title

   heading(o);
end
function oo = PlotX(o)                 % Stream Plot X
   if ~type(o,{'smp','alt'})
      oo = About(o);            
      return
   end

   oo = Stream(o,'x','r');
   heading(o);
end
function oo = PlotY(o)                 % Stream Plot Y%
   if ~type(o,{'smp','alt'})
      oo = About(o);            
      return
   end

   oo = Stream(o,'y','bc');
   heading(o);
end
function oo = PlotXY(o)                % Scatter Plot
   if ~type(o,{'smp','alt'})
      oo = About(o);            
      return
   end

   x = cook(o,'x');
   y = cook(o,'y');
   oo = corazon(o);
   oo = opt(oo,'color',opt(o,'style.scatter'));
   plot(oo,x,y,'ko');
   title('Scatter Plot');
   xlabel('x');  ylabel('y');

   heading(o);
end

%==========================================================================
% Plot Helpers (no more type check)
%==========================================================================

function oo = Stream(o,sym,col)
   t = cook(o,':');
   [d,df] = cook(o,sym);
   oo = with(corazon(o),'style');

   switch opt(o,{'filter.mode','raw'})
      case 'raw'
         plot(oo,t,d,col);
      case 'filter'
         plot(oo,t,df,col);
      case 'both'
         plot(opt(oo,'bullets',0),t,d,col);
         hold on;
         plot(oo,t,df,'k');
      case 'noise'
         plot(oo,t,d-df,col);
   end

   title([upper(sym),'-Plot']);
   xlabel('t');  ylabel(sym);
end
