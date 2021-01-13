function oo = plot(o,varargin)         % ECOS Plot Method
%
% PLOT   ECOS plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'Page')             % plot Page
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: ECOS, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @Page);
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
% Select Page
%==========================================================================

function list = Select(o,page)
   o = pull(o);
   list = {};
   
   mn = setting(o,{'ecos.size',[2 8]});
   N = prod(mn);
   
   for (i=1:N)
      list{i} = nan;
   end
   
   for (i=1:length(o.data))
      oo = o.data{i};
      if isequal(page,get(oo,'page'))
         index = get(oo,'index');
         if ~isempty(index) && index > 0 && index <= N
            list{index} = oo;
         end
      end
   end
end

%==========================================================================
% Plot Helpers
%==========================================================================

function PlotPanel(o)
   mn = opt(o,'ecos.size');
   m = mn(1);  n = mn(2);
   
   hdl = patch([0 n n 0 0],[0 0 m m 0],0.9*[1 1 1]);
   hold on;
   
   set(gca,'ydir','reverse');
   pos = get(gca,'position');
   pos(1:2) = [0.05 0.2];
   pos(3:4) = 1 - 2*pos(1:2);
   set(gca,'position',pos);
end
function PlotFrame(o,i,j)
   mn = opt(o,'ecos.size');
   m = mn(1);  n = mn(2);
   
   fx = 1;  fy = 1; df = 0.05;
   x = (j-1)*fx + df;  dx = fx - 2*df;  dh = dx/8;
   y = (i-1)*fy + df;  dy = fy - 2*df;
   
   hdl = plot(o,x+[0 dx dx 0 0],y+[0 0 dy dy 0],'k1');
   
   text0 = get(o,{'title',''});
   text1 = get(o,{'text1',''});
   text2 = get(o,{'text2',''});
   
   fs = 14;                            % font size
   hdl = text(x+dx/2,y+5*dh,text0);
   set(hdl,'horizontal','center', 'vertical','mid','fontsize',fs);

   hdl = text(x+dx/2,y+6*dh,text1);
   set(hdl,'horizontal','center', 'vertical','mid','fontsize',fs);
   
   hdl = text(x+dx/2,y+7*dh,text2);
   set(hdl,'horizontal','center', 'vertical','mid','fontsize',fs);   
end

%==========================================================================
% Page Display
%==========================================================================

function o = Page(o)                   % Plot Overview                 
   refresh(o,o);                       % refresh here
   
   page = arg(o,1);
   setting(o,'select.page',page);

   list = Select(o,page);
   
   cls(o);
   m = 2;  n = 8;  k = 0;
   PlotPanel(o);
   for (j=1:n)
      for (i=1:m)
         k = k+1;
         oo = list{k};
         if isa(oo,'ecos')
            oo = inherit(oo,o);
            PlotFrame(oo,i,j);
         end
      end
   end
   
   heading(o,sprintf('Page %g',page));
end
