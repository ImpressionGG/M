function oo = plot(o,varargin)         % Plot a Caramel Object         
%
% PLOT    Plot a CARAMEL trace object
%
%    Streams of a trace are plotted according to config option settings.
%
%       plot(o)                   % plot according opt(o,'mode.plot')
% 
%       plot(o,'Stream')          % plot in stream mode
%       plot(o,'Overlay')         % plot in overlay mode
%       plot(o,'Offset')          % plot individual offsets
% 
%       plot(o,'Repeatability')   % plot repeatability stream
%       plot(o,'Fictive Stream')  % plot repeatability stream
% 
%       plot(o,'Ensemble')        % plot ensemble of data lines
%       plot(o,'Averages')        % plot individual offsets
%       plot(o,'Spread')          % plot sigma values of ensemble
%       plot(o,'Deviation')       % plot deviation of an ensemble
%
%    Special call
%
%       plot(o,'Clip');           % plot with putting object into clipboard
%
%    Enhanced analysis
%
%       plot(o,'Path');           % plot matrix path
%
%    Options: the following options influence the plotting behavior
% 
%      'mode'        % plot mode ('mode.plot')
%      'style'       % plot style (line width, bullets,labels)
%      'view'        % view options
%      'grid'        % grid on/off
%      'scope'       % scope of data stream (matrix indices)
%
%    Example 1:
% 
%       t = 0:pi/50:4*pi;  x = sin(t); ý = cos(t);
%       o = trace(t,'x',x,'y',y);
% 
%       o = config(o,'x',{1,'r'});      % plot x in subplot 1
%       o = config(o,'y',{2,'b'});      % plot y in subplot 2
%       oo = plot(o);                   % single axis; same as plot(o,gca)
%       hdl = var(oo,'hdl');            % collected plot handles
% 
%    Example 2:
% 
%       t = 0:pi/50:4*pi;  x = sin(t); ý = cos(t);
%       o = trace(t,'x',x,'y',y);
% 
%       str.x = struct('sub',1,'col','r');
%       str.y = struct('sub',2,'col','b');
% 
%       oo = plot(config(o,'stream',str,'axes',1xn'));
%       hdl = var(oo,'hdl');            % collected plot handles
%
%    Remark: the work property var(oo,'hdl') of the returned object
%    contains all collected graphics handles for graphics objects gene-
%    rated during the plot process.
%
%    See also: CARAMEL, CONFIG
%
   [gamma,oo] = manage(o,varargin,@Default,@Setup,@Plot,@Put,...
        @Stream,@Fictive,@Overlay,...
        @Offsets,@Repeatability,@Residual1,@Residual2,@Residual3,...
        @Ensemble,@Average,@Spread,@Deviation,...
        @Condensate1,@Condensate2,@Condensate3,...
        @Surf,@Residual,@Fitted,@Arrow,@Path,@Zigzag);
   oo = gamma(oo);
end

%==========================================================================
% Default & Put Plot Function
%==========================================================================

function oo = Setup(o)                 % Setup Plot Menu               
%
% SETUP   Setup & handle Plot menu items
%
   oo = mitem(o,'Stream',{@Plot,'Stream'});
   oo = mitem(o,'Fictive Stream',{@Plot,'Fictive'});
   oo = mitem(o,'-');
   oo = mitem(o,'Overlay',{@Plot,'Overlay'});
   oo = mitem(o,'Offsets',{@Plot,'Offsets'});
   oo = mitem(o,'Repeatability',{@Plot,'Repeatability'});
   oo = mitem(o,'Residual');
   ooo = mitem(oo,'Order 1',{@Plot,'Residual1'});
   ooo = mitem(oo,'Order 2',{@Plot,'Residual2'});
   ooo = mitem(oo,'Order 3',{@Plot,'Residual3'});
   oo = mitem(o,'-');
   oo = mitem(o,'Ensemble',{@Plot,'Ensemble'});
   oo = mitem(o,'Average',{@Plot,'Average'});
   oo = mitem(o,'Spread',{@Plot,'Spread'});
   oo = mitem(o,'Deviation',{@Plot,'Deviation'});
   oo = mitem(o,'-');
   oo = mitem(o,'Condensate');
   ooo = mitem(oo,'Order 1',{@Plot,'Condensate1'});
   ooo = mitem(oo,'Order 2',{@Plot,'Condensate2'});
   ooo = mitem(oo,'Order 3',{@Plot,'Condensate3'});
end
function o = Plot(o)                   % Plot Callback                 
   refresh(o,o);                       % setup callback for refresh
   if isa(o,'caramel')
      args = arg(o,0);                 % save args
      o = arg(pull(caramel),args);     % restore args to pulled object
   end
   
   if isequal(type(current(o)),'pkg')
      menu(o,'About');
      refresh(o,o);
   else                                % this is for true trace objects
      %change(o,'Active');             % update active type
      oo = current(o);                 % get current object
      active(o,oo);                    % make sure oo is active
      %o = subplot(o,'color',[1 1 1]); % white background
      cls(o);                          % clear screen
      
      mode = arg(o,1);                 % get plot mode
      if ~isempty(mode)
         setting(o,'mode.plot',mode);  % update plot mode in settings
      end
      
      o = cast(o,current(o));          % make derived plot methods working
      plot(o,mode);                    % plot object
   end
end
function o = Default(o)                % Plot in Default Mode          
   working(o);                         % provide as working object
   o = pull(o);
   mode = o.either(setting(o,'mode.plot'),'Stream'); 
   oo = current(o);                    % get current object
   active(o,oo);                       % make sure oo is active
   cls(o);                             % clear screen
%  plot(o,mode);   % ???               % actual plot object
   plot(oo,mode);                      % actual plot object
end
function o = Put(o)                    % Put into shell's children list
   working(o);                         % provide as working object
end

%==========================================================================
% Local Functions to be Dispatched
%==========================================================================

function oo = Stream(o)                % Stream Plot                   
   oo = PlotBasket(o,'Stream');
end
function oo = Fictive(o)               % Fictive Stream Plot           
   oo = PlotBasket(o,'Fictive');
end

function oo = Overlay(o)                                               
   oo = PlotBasket(o,'Overlay');
end
function oo = Offsets(o)                                               
   oo = PlotBasket(o,'Offsets');
end
function oo = Repeatability(o)                                         
   oo = PlotBasket(o,'Repeatability');
end
function oo = Residual1(o)                                             
   oo = PlotBasket(o,'Residual1');
end
function oo = Residual2(o)                                             
   oo = PlotBasket(o,'Residual2');
end
function oo = Residual3(o)                                             
   oo = PlotBasket(o,'Residual3');
end

function oo = Ensemble(o)                                              
   oo = PlotBasket(o,'Ensemble');
end
function oo = Average(o)                                               
   oo = PlotBasket(o,'Average');
end
function oo = Spread(o)                                                
   oo = PlotBasket(o,'Spread');
end
function oo = Deviation(o)                                             
   oo = PlotBasket(o,'Deviation');
end

function oo = Condensate1(o)           % Condensate1 Plot              
   oo = PlotBasket(o,'Condensate1');
end
function oo = Condensate2(o)           % Condensate2 Plot              
   oo = PlotBasket(o,'Condensate2');
end
function oo = Condensate3(o)           % Condensate3 Plot              
   oo = PlotBasket(o,'Condensate3');
end

function oo = Surf(o)                  % Surf Plot                     
   oo = Analyse(o,'Surf',arg(o,1));
end
function oo = Residual(o)              % Residual Plot                 
   oo = Analyse(o,'Residual',arg(o,1));
end
function oo = Fitted(o)                % Fitted Plot                   
   oo = Analyse(o,'Fitted',arg(o,1));
end
function oo = Arrow(o)                 % Arrow Plot                    
   oo = Analyse(o,'Arrow');
end
function oo = Path(o)                  % Path Plot                     
   oo = Analyse(o,'Path');
end
function oo = Zigzag(o)                % ZigZag Plot                   
   oo = Analyse(o,'Zigzag');
end

%==========================================================================
% PloBasket of Objects
%==========================================================================

function o = PlotBasket(o,varargin)    % Plot Basket of Objects        
   o.profiler('Plot',1);               % begin profiling
   o = ManageMode(o,varargin);         % manage plot mode
%
% get the basket of traces which have to be plotted.
% For debug you can try 'basket(o)' to see traces in the basket
%
   if trace(o)                         % if we have a trace object
      list = {o};                      % list contains exactly this trace
   else
      list = basket(o);                % get basket of trace objects
   end
   
   while isempty(list)                 % error reporting (WHILE-IF)    
      comment = {'The basket of selected traces is empty.',...
                 'Change selection or consider to add traces!'};
      message(o,'Empty Basket!',comment);
      o.profiler('Plot',0); % end profiling
      return
   end
%
% plot all (stream typed) traces in the basket
%
   hdl = [];                           % init collection of plot handles
   for (i=1:length(list))              % with all objects in basket    
      oo = list{i};                    % get i-th basket object
      if trace(oo)
         oo = var(oo,'hdl',[]);        % init collection of plot handles
         
         oo = CorePlot(oo);            % core plotting of data
         oo = Variation(oo);           % plot variation, if enabled
         oo = Specs(oo);               % plot spec lines & set limits
         labels(oo);                   % provide labels
         Grid(oo);                     % grid management
         
         hold on
         hdl = [hdl; var(oo,'hdl')];   % update collected plot handles
      end
   end
   
   o.work.var.hdl = hdl;               % updated collected plot handles
   o.profiler('Plot',0);               % end profiling
end   
function o = CorePlot(o)               % Core Plotting                 
%
% COREPLOT   Plot xy-data, controlled by object's config options
%
%    Option Settings:
%       bullets:  flag 0/1 indicating to draw also black bullets
%       limits:   y-limits
%       xscale:   x scale factor
%       yscale:   y scale factor for drift deviation
%       ascale:   y scale factor for absolute plots
%       biasmode: bias mode (defines bias yes/no)
%      
%    Config Settings
%       sub:      subplot number
%       color:    color setting
%
   o = modes(o);                       % provide plotting modes

   hold off;                           % to clear screen
   color = @o.color;                   % shorthand
   
   bullets = opt(o,'bullets');         % option bullets
   lwid = opt(o,'linewidth');          % option line width
   
   xscale = opt(o,{'scale.xscale',1}); % x-scaling factor
   yscale = opt(o,{'yscale',1});       % y-scaling: drift,deviation
   ascale = opt(o,{'ascale',1});       % y-scaling: absolute

   [overlays,bias] = opt(o,'overlays','bias');
%
% plot mode always comes with the arg list
%
   plotmode = PlotMode(o);             % plot mode
%
% determine the proper y scaling factor
%
   if isequal(bias,'abs1000')          % conversion to mm?
      yscale = ascale;
   end
%   
% Let's go: unpack plot option and fetch the x vector
%
   switch plotmode
      case {'overlay','offsets','repeatability','residual1','residual2',...
            'residual3'}
         x = cook(o,':',plotmode);     % get x-vector
         if isequal(overlays,'time')
            x = xscale * x;            % only if time x-scales
         end
      case {'ensemble','average','spread','deviation',...
            'condensate1','condensate2','condensate3'}
         x = cook(o,':',plotmode);     % get x-vector
      case {'stream','fictive'}
         x = cook(o,':',plotmode);     % get x-vector
         x = xscale * x;               % and get x scaled
      otherwise
         error(['bad mode: ',plotmode]);
   end
%
% clear screen if current plots are not held
%
   held = ishold;                      % current graphics held?
   if ~ishold
      cls(o);                          % clear screen
   end
%   
% plot all y vectors into proper subplots
%
   caraplot = @carabull.plot;          % short hand
   
   hdl = var(o,'hdl');                 % add to collected plot handles
   nmax = subplot(o,inf);
   if (nmax == 0)
      message(o,'No plots are configured!','Select signals (View>Signal)!');
      return
   end
   
   for (k = 1:nmax)                    % do with all subplots          
      subplot(o,k);                    % select k-th subplot
      tokens = config(o,{k});          % get tokens for k-th subplot
      for (i=1:length(tokens))
         [sym,sub,col] = config(o,tokens{i});
         [y,yf] = cook(o,sym,plotmode);% data to be plotted

         if isempty(y)
            y = 0*x;  yf = 0*x;
         else
            y = yscale*y;  yf = yscale*yf;
         end

         if isempty(x)
            x = 1:length(y);           % if empty x
         end

         special = {'ensemble','condensate','deviation'};
         if isequal(plotmode,special) && size(y,1) > 1
            col = '';                  % no special color
         end

         [col,width,ltyp] = color(col);
         lwid = lwid + (width-1);
         
         if isempty(yf)
            h = caraplot(x',y',{col,lwid,ltyp});
         else
            h = caraplot(x',y',{col,lwid,ltyp}); 
            hold on;
            hdl = [hdl;h(:)];          % collect handles
            h = caraplot(x',yf',{col,lwid,ltyp});
         end
         hold on;
         hdl = [hdl;h(:)];             % collect handles

         if (bullets)
            if (bullets > 0) 
               bcol = col;
            else
               bcol = 'k';
            end
%           h = caraplot(x',y',{col,lwid,ltyp});
            h = caraplot(x',y',{bcol,lwid,['.']});
            hdl = [hdl;h(:)];          % collect handles
         end
         if (bullets && ~isempty(yf))
            if (bullets < 0) bcol = col; else bcol = 'k'; end
            h = caraplot(x',yf',{bcol,lwid,[ltyp,'.']});
            hdl = [hdl;h(:)];          % collect handles
         end
      end
      
      xlim = [min(x(:)),max(x(:))];
      if (diff(xlim) == 0) 
         xlim = [xlim(1)-1,xlim(2)+1];
      end
      if ~isempty(xlim)
         set(gca,'xlim',xlim,'box','on');
      end
   end
%
% Restore graphics hold state
%
   if (held)
      hold on
   else
      hold off
   end
   
   o.work.var.hdl = hdl;               % refresh plot handles
end

%==========================================================================
% General Analysis Dispatch Function
%==========================================================================

function o = Analyse(o,varargin)       % Analyse Basket of Objects     
   o.profiler('Analyse',1);         % begin profiling
   o = ManageMode(o,varargin);         % manage plot mode
%
% get the basket of traces which have to be plotted.
% For debug you can try 'basket(o)' to see traces in the basket
%
   list = basket(o);                   % get basket of trace objects
   while isempty(list)                 % error reporting (WHILE-IF)    
      comment = {'The basket of selected traces is empty.',...
                 'Change selection or consider to add traces!'};
      message(o,'Empty Basket!',comment);
      o.profiler('Analyse',0); % end profiling
      return
   end
%
% plot all trace objects in the basket
%
   hdl = var(o,'hdl');                 % add to collected plot handles
   for (i=1:length(list))              % with all objects in the basket
      oo = list{i};                    % get i-th basket object
      if trace(oo)
         oo = analysis(oo);            % add a further analysis  plot
         hold on
         labels(oo);
         hdl = [hdl; var(oo,'hdl')];
      end
   end
   
   o = var(o,'hdl',hdl);               % refresh plot handles
   o.profiler('Analyse',0);         % end profiling
end   

%==========================================================================
% Shared Functions
%==========================================================================

function o = Variation(o)              % Plot Variation                
%
   plotmode = PlotMode(o);
   vari = opt(o,'variation');

   hdl = [];
   if isempty(vari)
      return
   end
%
% check for the supported plot modes! all other plot modes will be 
% ignored.
%
   switch plotmode
      case {'overlay','repeatability'}
         'ok!';
      otherwise
         return                        % other plot modes not supported!
   end
   
   held = ishold;
   hold on;
%
% now loop for all supported traces
%
   hdl = [];
   nmax = config(o,inf);
   for (i=1:nmax)
      [sym,sub,col] = config(o,i);     % get symbol and subplot
      if (sub == 0 || isempty(col) || isnan(sub))
         continue                      % ignore trace if zero subplot index 
      end
      
      subplot(o,sub);                  % select configured subplot
      
      t = cook(o,0,'offsets');            % index 0 means 'time'
      avg = cook(o,i,'offsets');          % data stream i
      if isequal(plotmode,'repeatability')
         avg = 0*avg;                  % zero average for repeatability analysis
      end
      
      if vari.center
         h = plot(t,avg);              % plot in solid black
         h = color(h,'k',vari.center); % set color & line width
         hdl = [hdl;h(:)];
      end
      
      if vari.bullets
         h = plot(t,avg,'k.');         % plot with black bullets
         hdl = [hdl;h(:)];
      end
      
      if vari.range
         sig = cook(o,i,'sigma');      % data stream i
         h = plot(t,avg+3*sig);        % plot in solid line
         h = color(h,'k',vari.range);  % set color & line width
         hdl = [hdl;h(:)];
         h = plot(t,avg-3*sig);        % plot in solid line
         h = color(h,'k',vari.range);  % set color & line width
         hdl = [hdl;h(:)];
      end
   end
   
   if (held) hold on; else hold off; end

   hdl = [var(o,'hdl');hdl(:)];        % collect plot handles handles
   o = var(o,'hdl',hdl);               % refresh plot handles
end
function o = Specs(o)                  % Plot Spec Lines & Set Limits  
%
   o.profiler('Specs',1);              % begin profiling

   nmax = subplot(o,inf);
   plotmode = PlotMode(o);
   
   held = ishold;  hold on;            % mind plotting hold state 
   [specs,limits,units] = category(o);

   hdl = var(o,'hdl');                 % collect plot handles handles
   for (k = 1:nmax)                    % go through all subplots
      subplot(o,k);                    % select k-th subplot
      tokens = config(o,{k});          % get tokens for k-th subplot
      
      spec = [inf,-inf];               % init for k-th run
      limit = [inf,-inf];              % init for k-th run
      
      for (i=1:length(tokens))
         [sym,sub,col,cat] = config(o,tokens{i});
         
         if (cat == 0 || isempty(col))
            continue;
         end
         
         if (sub == k)
            if size(specs,1) < cat
               s = [0 0];
            else
               s = specs(cat,:);          % pick proper spec
            end
            if any(s~=0)
               spec(1) = min(spec(1),s(1));
               spec(2) = max(spec(2),s(2));
            end
            
            if size(limits,1) < cat
               l = [0 0];
            else
               l = limits(cat,:);         % pick proper limit
            end
            if any(l~=0)
               limit(1) = min(limit(1),l(1));
               limit(2) = max(limit(2),l(2));
            end
         end         
      end % for(i)
      
      xlim = get(gca,'xlim');  
      col = 'b';  lwid = 1;
      
      if (diff(spec) > 0)
         h1 = o.color(plot(xlim,spec(1)*[1 1],'-.'),col,lwid); 
         h2 = o.color(plot(xlim,spec(2)*[1 1],'-.'),col,lwid); 
         hdl = [hdl;h1(:);h2(:)];      % collect handles
         
            % set limits a bit bigger than spec limits 
            
         ds = diff(spec);
         ylim = [spec(1)-ds/6,spec(2)+ds/6];
         set(gca,'ylim',ylim);
      end

      if (diff(limit) > 0)
         set(gca,'ylim',limit);
      end
   end % for(k)
   
   if (held) hold on;  else  hold off;  end

   o.work.var.hdl = hdl;               % refresh plot handles
   o.profiler('Specs',0);              % end profiling
end
function o = Grid(o)                   % Switch Grid On/Off            
%
% GRID  Switch grid on/off
%
%    Option Settings:
%       segments:     segmentation lines on/off (1/0)
%
   nmax = subplot(o,inf);
   grd = opt(o,{'grid',0});
   plotmode = PlotMode(o);
   
   if (grd == 0)
      for (k = 1:nmax)                 % go through all subplots       
         subplot(o,k);                 % select k-th subplot
         grid off
      end
      return
   end
%
% We need to dispatch on plotmode. For normal 'stream' mode there is
% a bit more todo since the vertical grid lines have to match with
% the segment boundaries
%
   xscale = opt(o,{'xscale',1});       % x-scaling factor
   
   switch plotmode
      case 'stream'
         x = xscale * cook(o,0,'segment');     % get scaled x-vector
         x = Reduce(x);                        % reduce to proper set

         for (k = 1:nmax)                      % go through all subplots
            subplot(o,k);                      % select k-th subplot
            grid on;
            %set(gca,'xtick',rd(x,1));          % vertical segment lines
            %set(gca,'ytick',get(gca,'ylim')); % no horizontal lines
         end

      case {'overlay','offsets','sigma','repeatability',...
            'residual1','residual2','residual3'}
         x = cook(o,0,'piece');                % get scaled x-vector
         for (k = 1:nmax)                      % go through all subplots
            subplot(o,k);                      % select k-th subplot
            grid on;
            set(gca,'xtick',o.rd(x,1));        % vertical segment lines
            %set(gca,'ytick',get(gca,'ylim')); % no horizontal lines
         end

      case {'ensemble','average','spread'}
         x = cook(o,0,'average');              % get scaled x-vector
         x = Reduce(x);                        % reduce to proper set
         
         for (k = 1:nmax)                      % go through all subplots
            subplot(o,k);                      % select k-th subplot
            grid on;
            set(gca,'xtick',x);                % vertical segment lines
            %set(gca,'ytick',get(gca,'ylim')); % no horizontal lines
         end
         
      otherwise
         for (k = 1:nmax)                      % go through all subplots
            subplot(o,k);                      % select k-th subplot
            grid on
         end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function y = Monotonic(x)              % Make a Monotonic Function     
%
% MONOTONIC   Make a monotonic function. Drop some values if necessarry
%
   [y,idx] = sort(x);
   
   i = 1;
   while (i <= length(y))
      idx = find(y == y(i));
      n = length(idx);
      if (n > 1)
         y(i+1:i+n-1) = [];
      end
      i = i+1;
   end
   return
end
function x = Reduce(x)                 % Reduce Vector for Grid        
%
% REDUCE   Reduce number of data vector items to a proper number
%          This function is an auxillary for grid in order to get a
%          reduced number of grid lines
%
   factor = [1 2 5 10 20 50 100 200 500 1000 2000 5000 10000];

   if (length(x) > 15)
      for (i=1:length(factor))      
         fac = factor(i);
         if (length(x) / fac <= 15)
            idx = [1 find(rem((1:length(x)),fac)==0)];
            idx = [1 idx length(x)];
            x = x(idx);
            break
         end
      end
   end
   x = Monotonic(x);
   return
end
% function [mode,arg2] = PlotMode(o)   % Extract Plot Mode             
%    mode = lower(arg(o,1));
% end
function mode = PlotMode(o)            % Extract Plot Mode             
   mode = lower(arg(o,1));
end
function o = ManageMode(o,args)        % Manage Plot Mode              
%
% MANAGEMODE   Manage plot mode. The function is quite tricky:
%              First check if a plot mode is provided in arg(o,1).
%              If not we fetch the whole arg list from option 'mode.plot'.
%              If also this option is empty, we provide arglist {'Stream'}
%              as the default.
%
   o = arg(o,args);                    % redefine argument list
   if isempty(arg(o,1))
      %arg1 = opt(o,'mode.plot');
      %arg1 = o.either(arg1,'Stream'); % use 'stream' mode as default  
      arg1 = opt(o,{'mode.plot','Stream'});
      o = arg(o,{arg1});               % overwrite arg list
   end
   setting(o,'mode.plot',arg(o,1));    % store back arg1 to settings
   o = opt(o,'mode.plot',arg(o,1));    % store plot mode in options
end
function txt = Capital(txt)            % Start Text with Capital Letter
%
% CAPITAL   Raise first character of a text to a capital character.
%
%    If first character of a text is a letter then this letter will be
%    replaced by a capital letter. Otherwise no change to the text.
%
%       txt = Capital('plot')        % => txt = 'Plot' 
%       txt = Capital('Plot')        % => txt = 'Plot' 
%       txt = Capital(' plot')       % => txt = ' plot' 
%       txt = Capital('123')         % => txt = '123' 
%
   if ~ischar(txt)
      error('string expected for arg1!');
   end
   
   if ~isempty(txt)
      txt(1) = upper(txt(1));
   end
end

