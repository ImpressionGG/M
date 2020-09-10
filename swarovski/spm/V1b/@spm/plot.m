function oo = plot(o,varargin)         % SPM Plot Method
%
% PLOT   SPM plot method
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: SPM, SHELL
%
   [gamma,oo] = manage(o,varargin,@PlotDefault,@Menu,@Callback,...
                       @PlotOverview,@PlotX,@PlotY,@PlotXY);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                 % Setup Plot Menu
   oo = mitem(o,'Overview',{@Callback,'PlotOverview'});
   oo = mitem(o,'-');
   oo = mitem(o,'X',{@Callback,'PlotX'});
   oo = mitem(o,'Y',{@Callback,'PlotY'});
   oo = mitem(o,'XY', {@Callback,'PlotXY'});

   oo = Style(o);                      % add Style menu to Select menu
end
function oo = Style(o)                 % Add Style Menu Items
   setting(o,{'style.bullets'},1);     % provide bullets default
   setting(o,{'style.linewidth'},1);   % provide linewidth default
   setting(o,{'style.scatter'},'k');   % provide scatter color default

      % filter settings
     
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mseek(o,{'#','Select'});

   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Style');
   oooo = mitem(ooo,'Bullets','','style.bullets');
   check(oooo,{});
   oooo = mitem(ooo,'Line Width','','style.linewidth');
   choice(oooo,[1:3],{});
   oooo = mitem(ooo,'Scatter Color','','style.scatter');
   charm(oooo,{});

   ooo = mitem(oo,'Filter');
   oooo = mitem(ooo,'Mode','','filter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'filter.type');
   choice(oooo,{{'Order 2 Low Pass','LowPass2'},{'Order 2 High Pass','HighPass2'},...
               {'Order 4 Low Pass','LowPass4'},{'Order 4 High Pass','HighPass4'}},{});
   oooo = mitem(ooo,'Bandwidth',{},'filter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'filter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'filter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end
function oo = Callback(o)              % Common Plot Callback
   refresh(o,o);                       % use this callback for refresh
   list = basket(o);
   if isempty(list)
      message(o,'No objects!',{'(import object or create a new one)'});
      return
   end

   oo = o;                             % provide in case of empty basket
   cls(o);
   for (i=1:length(list))
      oo = list{i};
      if container(oo)
         message(oo);
      else
         plot(oo);                     % forward to capuchino.plot method
         hold on;
      end
   end
end

%==========================================================================
% Plot Functions
%==========================================================================

function o = PlotDefault(o)            % Default Plot
   cls(o);                             % clear screen
   PlotOverview(o);
end
function o = PlotOverview(o)           % Plot Overview
   oo = opt(o,'subplot',[2 2 1]);
   PlotX(oo);

   oo = opt(oo,'subplot',[2 2 3]);
   oo = opt(oo,'title',' ');           % prevent from drawing a title
   PlotY(oo);

   oo = opt(oo,'subplot',[1 2 2]);
   oo = opt(oo,'title','X/Y-Orbit');   % override title
   PlotXY(oo);
end
function o = PlotX(o)                  % Stream Plot X
   Stream(o,'x','r');
end
function o = PlotY(o)                  % Stream Plot Y
   Stream(o,'y','b');
end
function o = Stream(o,sym,col)
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

   title(get(o,'title'));
   ylabel(sym);
end
function o = PlotXY(o)                 % Scatter Plot
   x = cook(o,'x');
   y = cook(o,'y');
   oo = corazon(o);
   oo = opt(oo,'color',opt(o,'style.scatter'));
   plot(oo,x,y,'ko');
%  set(gca,'DataAspectRatio',[1 1 1]);
   title(get(o,'title'));
end
