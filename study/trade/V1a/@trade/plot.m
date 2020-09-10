function oo = plot(o,varargin)         % TRADE Plot Method
%
% PLOT   TRADE plot method
%
%           plot(o,'Chart')            % plot chart
%           plot(o,'Haikin')           % plot Haikin-Ashi chart
%
%           plot(o,'Top')              % plot top line
%           plot(o,'Bottom')           % plot bottom line
%
%           plot(o,'Long1')            % plot Long1 trading strategy
%           plot(o,'Short1')           % plot Short1 trading strategy
%
%        See also: TRADE, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@Callback,...
                       @Chart,@Haikin,@Ashi,@Top,@Bottom,@Long1,@Short1,...
                       @Long2,@Short2);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   oo = mitem(o,'Chart',{@Callback,'Chart'});
   oo = mitem(o,'Haikin Ashi',{@Callback,'Haikin'});
   oo = mitem(o,'Chart++',{@Callback,'Ashi'});
end
function oo = Callback(o)              % Common Plot Callback          
   refresh(o,o);                       % use this callback for refresh
   list = basket(o);

   oo = o;                             % provide in case of empty basket
   if isempty(list)
      message(o,'No objects!',{'(import object or create a new one)'});
      return
   end

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
% Standard Plot Function
%==========================================================================

function o = Plot(o)                   % Default Plot                  
   switch type(o)
      case 'chd'
         Chart(o);                     % Plot Chart
      case 'long1'
         Long1(o);                     % Plot Long1
      case 'short1'
         Short1(o);                    % Plot Short1
      case 'long2'
         Long2(o);                     % Plot Long2
      case 'short2'
         Short2(o);                    % Plot Short2
   end
end

%==========================================================================
% Plot Functions
%==========================================================================

function o = Chart(o)                  % Plot Chart                    
   oo = corazon(with(o,'style'));   
   
   [t,open,low,high,close] = Cook(o,'t,open,low,high,close');
   oo = data(oo,'t,open,low,high,close',t,open,low,high,close);
   
   oo = Inner(oo);                     % calculate inner bars
   inner = data(oo,'inner');

   mode = opt(oo,{'view.chart','candle'});
   switch mode
      case 'line'
         hdl = plot(oo,t,open,'r',  t,close,'g');
         set(hdl,'LineWidth',3);
      case 'candle'
         for (i=1:length(t))
            candle = [open(i),high(i),low(i),close(i)];
            Candle(oo,t(i),candle,inner(i));
         end
         Top(oo);                       % plot top
         Bottom(oo);                    % plot bottom
      case 'bar'
         for (i=1:length(t))
            candle = [open(i),high(i),low(i),close(i)];
            Bar(oo,t(i),candle,inner(i));
         end
   end
   
   Strategy(oo);                       % plot selected trade strategiess
 
      % set scope
      
   o = Scope(o);
   
   title(get(o,'title'));
   dark(o);
end
function o = Haikin(o)                 % Haikin-Ashi Chart             
   o = opt(o,'mode.haikin',1);         % set Haikin-Ashi cook option
   o = Chart(o);
end
function o = Ashi(o)                   % Chart with Haikin-Ashi Bgrd.  
   oo = corazon(with(o,'style'));   
   oo = opt(oo,'mode.haikin',1);       % set Haikin-Ashi cook option
   [t,open,low,high,close,haikin] = Cook(oo,'t,open,low,high,close,haikin');

   oo = Inner(oo);                     % calculate inner bars
   inner = data(oo,'inner');

   oo = opt(oo,'alpha',0.8);
   
   from = 1;  to = 1;                  % init
   
   for (i=1:length(t))
      candle = [open(i),high(i),low(i),close(i)];
      Patch(oo,t(i),candle,inner(i));
      
      if (i==1 || haikin(i) == haikin(from))
         to = i;                       % enlarge interval
      else
         if (haikin(from) ~= 0)
            col = o.color(o.iif(haikin(from)>0,'ggk','r'));
            idx = from:to;
            a = min(min([open(idx);close(idx);high(idx);low(idx)]));
            b = max(max([open(idx);close(idx);high(idx);low(idx)]));
            
            ff = from-0.5;  tt = to+0.5;
            hdl = patch([tt ff ff tt tt],[a a b b a],col);
            set(hdl,'FaceAlpha',0.1,'EdgeAlpha',0);

            hdl = plot([tt ff ff tt tt],[a a b b a],'-');
            set(hdl,'Color',col,'LineWidth',0.5);
         end
         from = i;  to = i;
      end
   end
   
      % draw chart overlay
      
   o = data(o,'haikin',haikin);
   Chart(o);

   o = Scope(o);                       % set scope
   
   title(get(o,'title'));
   dark(o);
end


function o = Top(o,buy,sell)           % Plot Top                      
   if ~opt(o,{'view.top',0})
      return
   end
   
   [t,low,high,top] = data(o,'t,low,high,top');
   
   if (nargin == 1)
      idx = 1:length(t);  w = 1;  type = ':';
   else
      idx = buy:sell-1;  w = 1;  type = '-';
   end
   
   delta = 0.01*(max(high)-min(low));
   [tt,yy] = Stair(o,t(idx),top(idx));

   hdl = plot(tt,yy+delta,type);
   
   col = o.color('ryy');
   set(hdl,'Color',col,'LineWidth',w);
   o = var(o,'color',col);
end
function o = Bottom(o,buy,sell)        % Plot Bottom                   
   if ~opt(o,{'view.bottom',0})
      return
   end
   
   [t,low,high,bottom] = data(o,'t,low,high,bottom');
   
   if (nargin == 1)
      idx = 1:length(t);  w = 1;  type = ':';
   else
      idx = buy:sell-1;   w = 1;  type = '-';
   end
   
   delta = 0.01*(max(high)-min(low));
   [tt,bb] = Stair(o,t(idx),bottom(idx));
   
   hdl = plot(tt,bb-delta,type);

   col = o.color('bc');
   set(hdl,'Color',col,'LineWidth',w);
   o = var(o,'color',col);
end
function o = Strategy(o)               % Plot Selected Strategies      
   o = trade(o);                       % cast to trade object

   switch opt(o,{'strategy.trade',0})  % trade1 strategy
      case 1
         Trade1(o);                    % plot Trade 1 strategy
      case 2
         Trade2(o);                    % plot Trade 1 strategy
   end
end

%==========================================================================
% Trading Strategies
%==========================================================================

function o = Trade1(o)                 % Plot Trade1 Strategy          
   N = length(data(o,'t'));
   
   if opt(o,{'view.bottom',0})
      buy = 1;                         % buy index
      while (~isempty(buy) && buy < N)
         oo = action(o,'Long1',buy);   % 'Long1' trade at first position
         plot(oo);
         buy = var(oo,'sell') + 1;
      end
   end
 
   if opt(o,{'view.top',0})
      sell = 1;                           % sell index
      while (~isempty(sell) && sell < N)
         oo = action(o,'Short1',sell);    % 'Short1' trade at first position
         plot(oo);
         sell = var(oo,'buy') + 1;
      end
   end
end
function o = Trade2(o)                 % Plot Trade2 Strategy          
   N = length(data(o,'t'));
   if isempty(data(o,'haikin'))
      return
   end
   
   buy = 1;
   while (~isempty(buy) && buy < N)
      oo = action(o,'Long2',buy);      % 'Long1' trade at first position
      plot(oo);
      buy = var(oo,'sell') + 1;
%sbreak;      
   end
end
function o = Long1(o)                  % Long Trade 1                  
   [buy,sell] = var(o,'buy,sell'); 
   [t,open,low,high,close,bottom] = data(o,'t,open,low,high,close,bottom');
   delta = 0.01*(max(high)-min(low));

   [t,bottom] = data(o,'t,bottom');
   
    o = Bottom(o,buy,sell);
    Diamond(o,t(buy)-0.5,bottom(buy)-delta,o.color('w'));
    Diamond(o,t(sell-1)+0.5,bottom(sell-1)-delta,o.color('kkkkw'));
end
function o = Short1(o)                 % Short Trade 1                 
   [buy,sell] = var(o,'buy,sell'); 
   [t,open,low,high,close,top] = data(o,'t,open,low,high,close,top');
   delta = 0.01*(max(high)-min(low));

   [t,top] = data(o,'t,top');
   
    o = Top(o,sell,buy);
    Diamond(o,t(sell)-0.5,top(sell)+delta,o.color('w'));
    Diamond(o,t(buy-1)+0.5,top(buy-1)+delta,o.color('kkkkw'));
end

function o = Long2(o)                  % Long Trade 2                  
   [buy,sell] = var(o,'buy,sell'); 
   [t,open,low,high,close,bottom] = data(o,'t,open,low,high,close,bottom');
   N = length(t);
   
   delta = 0.01*(max(high)-min(low));

   [t,bottom] = data(o,'t,bottom');
   
    o = Bottom(o,buy,sell);
    
    sell = min(N,sell+1);
    
    hdl = plot([buy sell],open([buy,sell]),'wo');
    hdl = plot([buy sell],open([buy,sell]),'g');
    set(hdl,'LineWidth',3);
    
    Diamond(o,t(buy)-0.5,bottom(buy)-delta,o.color('w'));
    Diamond(o,t(sell-1)+0.5,bottom(sell-1)-delta,o.color('kkkkw'));
end

%==========================================================================
% Helper
%==========================================================================

function o = Inner(o)                  % Add Inner Status, Bottom & Top
   [open,low,high,close] = data(o,'open,low,high,close');
   outer = 0;
   
   for (i=1:length(open))
      if (outer)
         opening = (open(i) >= low(outer) && open(i) <= high(outer));
         closing = (close(i) >= low(outer) && close(i) <= high(outer));
         inner(i) = opening && closing;
      else
         inner(i) = 0;                 % no inner bars
      end
      
      if ~inner(i) || ~outer
         outer = i;    
      end
      
         % determine bottom
         
      bottom(i) = low(i);
      
         % bottom correction if first inner bar
         
      if inner(i) && (outer == i-1) && (outer > 1)
         bottom(i) = min([bottom(i),low(outer),low(outer-1)]);
      end
      
         % determine top
         
      top(i) = high(i);
      
         % top correction if first inner bar
         
      if inner(i) && (outer == i-1) && (outer > 1)
         top(i) = max([top(i),high(outer),high(outer-1)]);
      end
   end
   
   o = data(o,'inner,bottom,top',inner,bottom,top);
end
function o = Scope(o)                  % Set Scope                     
   scope = opt(o,{'select.scope',inf});
   
   t = data(o,'t');
   n = length(t);
   
   if ~isinf(scope)
      %xlim = [max(1,n-scope),n+1];
      %set(gca,'Xlim',xlim);
   end
end

%==========================================================================
% Cook
%==========================================================================

function [t,open,low,high,close,haikin] = Cook(o,tags)                        
   if opt(o,{'mode.haikin',0})
      o = HaikinAshi(o);
   end
   
   [t,open,low,high,close,haikin] = data(o,'t,open,low,high,close,haikin');
   
   scope = min(length(t),opt(o,{'select.scope',length(t)}));
   idx = 1:scope;
   t = t(idx);
   open = open(idx);
   low = low(idx);
   high = high(idx);
   close = close(idx);
   
   if ~isempty(haikin)
      haikin = haikin(idx);
   end
end
function oo = HaikinAshi(o)            % Haikin Ashi Pre-processing    
   [open,low,high,close,inner] = data(o,'open,low,high,close,inner');
   
   if isempty(inner)
      o = Inner(o);
      inner = data(o,'inner');
   end
   
      % set proper initial values
      
   hao(1) = open(1);  
   hac(1) = close(1);  
   hah(1) = max([open(1),close(1),high(1)]);
   hal(1) = min([open(1),close(1),low(1)]);
   haikin(1) = 0;
  
   for (i=2:length(open))
      hao(i) = (hao(i-1) + hac(i-1)) / 2;
      hac(i) = (open(i)+close(i)+high(i)+low(i)) / 4;
      hah(i) = max([open(i),close(i),high(i)]);
      hal(i) = min([open(i),close(i),low(i)]);
      
      if (hac(i) > hao(i))
         haikin(i) = +1;
      elseif (hac(i) < hao(i))
         haikin(i) = -1;
      else
         haikin(i) = haikin(i-1);
      end
   end
      
   oo = data(o,'open,low,high,close,inner,haikin',...
                hao,hal,hah,hac,inner,haikin);   
end

%==========================================================================
% Helper Functions
%==========================================================================

function [tt,ff] = Stair(o,t,f)        % Calculate Stair Coordinates   
   tt = [t;t(2:end) t(end)+1];  tt = tt(:)' - 0.5;
   ff = [f;f];  ff = ff(:)'; 
end
function o = Candle(o,t,candle,inner)  % Plot a Candle                 
   lw = opt(o,{'linewidth',3});   % line width
   w = opt(o,{'width',0.5});      % candle width
  
   highlight = o.color(o.iif(opt(o,{'view.dark',0}),'w','k'));
   haikin = opt(o,{'mode.haikin',0});

   if candle(1) <= candle(4)
      col = o.color(o.iif(haikin,'bc','ggk'));    % bullisch candle
   else
      col = o.color(o.iif(haikin,'m','r'));       % bearisch candle
   end
   
   if inner && opt(o,{'view.inner',0}) == 1
      col = o.color(o.iif(opt(o,{'view.dark',0}),'w','k'));
   end
   
      % plot wick
      
   hdl = plot([t t],candle(2:3));
   set(hdl,'LineWidth',lw, 'Color',col);
   hold on;
 
   hdl = patch(t+[w w -w -w w]/2,candle([1,4,4,1,1]),col);

      % highlight inner bars with a bullet
      
   if inner && opt(o,{'view.inner',0}) == 2
      price = mean(candle([1 4])); 
      hdl3 = plot(t,price,'.', t,price,'o');
      set(hdl3,'Color',highlight);
   end
   
end
function o = Bar(o,t,candle,inner)     % Plot a Bar                    
   lw = max(2,opt(o,{'linewidth',3})); % line width
   w = opt(o,{'width',0.5});           % bar width
   
   highlight = o.color(o.iif(opt(o,{'view.dark',0}),'w','k'));
   haikin = opt(o,{'mode.haikin',0});
   
   if inner && opt(o,{'view.inner',0}) == 1
      col = highlight;
   elseif candle(1) <= candle(4)
      col = o.color(o.iif(haikin,'bc','ggk'));    % bullisch bar
   else
      col = o.color(o.iif(haikin,'m','r'));       % bearisch bar
   end
   
   hdl0 = plot([t t],candle(2:3),'k');
   hold on
   hdl1 = plot(t-[w 0]/2,candle(1)*[1 1],'k');
   hdl2 = plot(t+[w 0]/2,candle(4)*[1 1],'k');
   
      % highlight inner bars with a bullet
      
   hdl3 = [];
   if inner && opt(o,{'view.inner',0}) == 2
      hdl3 = plot([t],candle([1 4]),'.');
      set(hdl3,'Color',highlight,'LineWidth',3);
   end

   set([hdl0,hdl1,hdl2,hdl3],'LineWidth',lw, 'Color',col);
end
function o = Patch(o,t,candle,inner)   % Plot a Patchs                 
   alpha = opt(o,{'alpha',0.5});
   wick = candle(2:3);
   lw = opt(o,{'linewidth',1});        % line width
   
   wp = 1.0;                           % patch width
   ww = 0.2;                           % wick width
  
   highlight = o.color(o.iif(opt(o,{'view.dark',0}),'w','k'));
   haikin = opt(o,{'mode.haikin',0});

   if candle(1) <= candle(4)
      col = o.color('ggk');           % bullisch patch
   else
      col = o.color('r');             % bearisch patch
   end
   
   if inner && opt(o,{'view.inner',0}) == 1
      col = o.color(o.iif(opt(o,{'view.dark',0}),'w','k'));
   end
   
      % to see axes we have to do a plot, which is delete immediately
      
   hdl = plot([t t],candle(2:3));
   delete(hdl);
   
   hdl = patch(t+wp*[1 1 -1 -1 1]/2,candle([1,4,4,1,1]),col);
   set(hdl,'FaceAlpha',alpha,'EdgeAlpha',0);   
   hold on;
 
   hdl = patch(t+ww*[1 1 -1 -1 1]/2,wick([1 2 2 1 1]),col);
   set(hdl,'FaceAlpha',alpha/4,'EdgeAlpha',0);
end
function Disk(o,t,y,fcol)              % Draw Disk with 1:1 Aspect     
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   pos = get(gca,'Position');
   aspect = get(gca,'PlotBoxAspectRatio');
   
   fac = 0.005;
   rx = 0.25;
   ry = fac*diff(ylim) * aspect(1)/aspect(2);
   phi = 0:pi/20:2*pi;
   x = t + rx*cos(phi);
   y = y + ry*sin(phi);
   
   hdl = patch(x,y,'y');
   ecol = var(o,{'color',o.color('k')});
   set(hdl,'FaceColor',o.color(fcol),'LineWidth',1,'EdgeColor',ecol);
   
end
function Diamond(o,t,y,fcol)           % Draw Diamond with 1:1 Aspect     
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   pos = get(gca,'Position');
   aspect = get(gca,'PlotBoxAspectRatio');
   
   fac = 0.005;
   rx = 0.25;
   ry = fac*diff(ylim) * aspect(1)/aspect(2);

   x = t + rx*[0 1 0 -1 0];
   y = y + ry*[1,0,-1,0,1];
   
   hdl = patch(x,y,'y');
   ecol = var(o,{'color',o.color('k')});
   set(hdl,'FaceColor',o.color(fcol),'LineWidth',1,'EdgeColor',ecol);
end
