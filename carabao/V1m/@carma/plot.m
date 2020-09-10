function oo = plot(o,varargin)    % Plot a Trace Object           
%
% PLOT    Plot a CARALOG trace object
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
%       plot(o);                        % single axis; same as plot(o,gca)
% 
%    Example 2:
% 
%       t = 0:pi/50:4*pi;  x = sin(t); ý = cos(t);
%       o = trace(t,'x',x,'y',y);
% 
%       str.x = struct('sub',1,'col','r');
%       str.y = struct('sub',2,'col','b');
% 
%       plot(config(o,'stream',str,'axes',1xn'));
%
%    See also: CARALOG, CONFIG
%
   [gamma,oo] = manage(o,varargin,@Stream,@Fictive,@Overlay,...
        @Offsets,@Repeatability,@Residual1,@Residual2,@Residual3,...
        @Ensemble,@Average,@Spread,@Deviation,...
        @Condensate1,@Condensate2,@Condensate3);
   oo = gamma(oo);
end

%==========================================================================
% Local Functions to be Dispatched
%==========================================================================

function oo = Stream(o)                                                
   oo = PlotTrace(o,'Stream');
end
function oo = Fictive(o)                                               
   oo = PlotTrace(o,'Fictive');
end

function oo = Overlay(o)                                               
   oo = PlotTrace(o,'Overlay');
end
function oo = Offsets(o)                                               
   oo = PlotTrace(o,'Offsets');
end
function oo = Repeatability(o)                                         
   oo = PlotTrace(o,'Repeatability');
end
function oo = Residual1(o)                                             
   oo = PlotTrace(o,'Residual1');
end
function oo = Residual2(o)                                             
   oo = PlotTrace(o,'Residual2');
end
function oo = Residual3(o)                                             
   oo = PlotTrace(o,'Residual3');
end

function oo = Ensemble(o)                                             
   oo = PlotTrace(o,'Ensemble');
end
function oo = Average(o)                                             
   oo = PlotTrace(o,'Average');
end
function oo = Spread(o)                                             
   oo = PlotTrace(o,'Spread');
end
function oo = Deviation(o)                                             
   oo = PlotTrace(o,'Deviation');
end

function oo = Condensate1(o)                                             
   oo = PlotTrace(o,'Condensate1');
end
function oo = Condensate2(o)                                             
   oo = PlotTrace(o,'Condensate2');
end
function oo = Condensate3(o)                                             
   oo = PlotTrace(o,'Condensate3');
end

%==========================================================================
% Plot Trace Object
%==========================================================================

function hdl = PlotTrace(o,varargin)        % Plot a Trace Object           
   if (nargin == 2)
      arg1 = varargin{1};
      if ~ischar(arg1)
         error('string expected for mode (arg2)!');
      end
      switch arg1
         case {'Labels','Variation','Specs','Grid'}
            o = arg(o,opt(o,{'mode.plot',{'',''}}));
            cmd = [arg1,'(o)'];
            hdl = eval(cmd);
            return
         otherwise
            o = arg(o,varargin);       % redefine argument list
      end
   end
%
% get the basket of traces which have to be plotted.
% For debug you can try 'basket(o)' to see traces in the basket
%
   hdl = [];                           % init plot handles
   list = basket(o);                   % get basket of trace objects
   if isempty(list)
      comment = {'The basket of selected traces is empty.',...
                 'Change selection or condider to add traces!'};
      message(o,'Empty Basket!',comment);
      return
   end
%
% plot all (stream typed) traces in the basket
%
   for (i=1:length(list))
      oo = list{i};                 % get i-th basket object
      if trace(oo)
         %oo = config(oo,'');       % provide default config if no cfg.
         h = Plot(oo);
         hold on
         hdl = [hdl; h(:)];
      end
   end
end   

%==========================================================================
% General Plot Dispatch Function
%==========================================================================

function hdl = Plot(o)                 % General Plot Dispatcher       
%
   assert(trace(o));
%
% Now it gets a bit tricky: check if a plot mode is provided in arg(o,1).
% If not we fetch the whole arg list from option 'mode.plot'. If also this
% option is empty, we provide arglist {'Stream'} as the default.

   if isempty(arg(o,1))
      arg1 = opt(o,'mode.plot');
      arg1 = o.either(arg1,'Stream');  % use 'stream' mode as default  
      o = arg(o,{arg1});               % overwrite arg list
   end
   setting(o,'mode.plot',arg(o,1));    % store back arg1 to settings
   o = opt(o,'mode.plot',arg(o,1));    % store plot mode in options
%
% The tricky part is done, dispatch plot mode
%
   plotmode = PlotMode(o);             % get plot mode
   switch plotmode
      case {'stream','fictive','overlay','offsets','repeatability',...
            'residual1','residual2','residual3',...
            'ensemble','average','spread','deviation',...
            'condensate1','condensate2','condensate3'}
         h1 = PlotData(o);             % plot data
         h2 = Variation(o);            % plot variation
         h3 = Specs(o);                % plot spec lines & set limits
         labels(o);                    % provide labels
         Grid(o);                      % grid management
         hdl = [h1(:); h2(:); h3(:)];

      case {'surf','arrow','path','zigzag'}
         list = arg(o,0);              % get arg list
         o = arg(o,[{Capital(plotmode)},list(2:end)]);
         hdl = analysis(o);
         labels(o);
      otherwise
         error('bad plot mode')
   end
   return
end

%==========================================================================
% Actual Plotting
%==========================================================================

function hdl = PlotData(o)             % Plot Data Traces              
%
% PLOT-DATA   Plot xy-data, controlled by object's config options
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
   [either,iif,is,color] = util(o,'either','iif','is','color'); 
   
   bullets = opt(o,{'bullets',0});             % option bullets
   lwid = opt(o,{'linewidth',1});              % option line width
   
   xscale = opt(o,{'xscale',1});               % x-scaling factor
   yscale = opt(o,{'yscale',1});               % y-scaling: drift,deviation
   ascale = opt(o,{'ascale',1});               % y-scaling: absolute
   bias = opt(o,{'mode.bias',''});             % bias mode
%
% plot mode always comes with the arg list
%
   plotmode = PlotMode(o);                     % plot mode
   o = opt(o,'bias',bias);                     % provide bias mode
%
% determine the proper y scaling factor
%
   if o.is(bias,'abs1000')                     % conversion to mm?
      yscale = ascale;
   end
%   
% Let's go: unpack plot option and fetch the x vector
%
   switch plotmode
      case {'overlay','offsets','repeatability','residual1','residual2',...
            'residual3','ensemble','average',...
            'spread','deviation','condensate1','condensate2','condensate3'}
         x = cook(o,':',plotmode);             % get x-vector
      case {'stream','fictive'}
         x = xscale * cook(o,':',plotmode);    % get scaled x-vector
      otherwise
         error(['bad mode: ',plotmode]);
   end
%
% clear screen if current plots are not held
%
   held = ishold;                              % current graphics held?
   if ~ishold
      cls(o);                                  % clear screen
   end
%   
% plot all y vectors into proper subplots
%   
   hdl = [];
   nmax = subplot(o,inf);
   for (k = 1:nmax)                            % do with all subplots  
      subplot(o,k);                            % select k-th subplot
      for (i=1:config(o,inf))
         [sym,sub,col] = config(o,i);
         if (sub == k)
            [y,yf] = cook(o,i,plotmode);      % data to be plotted
            
            if isempty(y)
               y = 0*x;  yf = 0*x;
            else
               y = yscale*y;  yf = yscale*yf;
            end
            
            x = either(x,1:length(y));         % if empty x

            special = {'ensemble','condensate','deviation'};
            if is(plotmode,special) && size(y,1) > 1
               col = '';                       % no special color
            end
            
            if isempty(yf)
               h = color(plot(x,y),col,lwid); % plot & hold on
            else
               h = color(plot(x,y),col,lwid); % plot & hold on
               hdl = [hdl;h(:)];              % collect handles
               h = color(plot(x,yf),'k',lwid+1);  % plot & hold on
            end
            hdl = [hdl;h(:)];                 % collect handles
            
            if (bullets)
               bcol = iif(bullets>0,col,'k');
               h = color(plot(x,y,'k.'),bcol,lwid);  
               hdl = [hdl;h(:)];              % collect handles
            end
            if (bullets && ~isempty(yf))
               bcol = iif(bullets<0,col,'k');
               h = color(plot(x,yf,'k.'),bcol,lwid);  
               hdl = [hdl;h(:)];              % collect handles
            end
         end
         
         xlim = [min(x(:)),max(x(:))];
         if (diff(xlim) == 0) 
            xlim = [xlim(1)-1,xlim(2)+1];
         end
         if is(xlim)
            set(gca,'xlim',xlim,'box','on');
         end
      end
   end
%
% Restore graphics hold state
%
   hold(iif(held,'on','off'));
   return
end

function hdl = Variation(o)            % Plot Variation                
%
   [iif,is] = util(o,'iif','is');      % need some utils

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
      [sym,sub] = config(o,i);         % get symbol and subplot
      if (sub == 0)
         continue                      % ignore trace if zero subplot index 
      end
      
      subplot(o,sub);                  % select configured subplot
      
      t = cook(o,0,'offsets');            % index 0 means 'time'
      avg = cook(o,i,'offsets');          % data stream i
      if is(plotmode,'repeatability')
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
   
   hold(iif(held,'on','off'));
   return
end
 
function hdl = Specs(o)                % Plot Spec Lines & Set Limits  
%
   iif = @o.iif;                       % need some utils

   nmax = subplot(o,inf);
   plotmode = PlotMode(o);
   
   held = ishold;  hold on;            % mind plotting hold state 
   specs = opt(o,'category.specs');
   limits = opt(o,'category.limits');

   hdl = [];
   for (k = 1:nmax)                    % go through all subplots
      subplot(o,k);                    % select k-th subplot
      spec = [inf,-inf];               % init for k-th run
      limit = [inf,-inf];              % init for k-th run
      
      for (i=1:config(o,inf))
         [sym,sub,col,cat] = config(o,i);
         
         if (cat == 0)
            continue;
         end
         
         if (sub == k)
            s = specs(cat,:);          % pick proper spec
            if any(s~=0)
               spec(1) = min(spec(1),s(1));
               spec(2) = max(spec(2),s(2));
            end
            
            l = limits(cat,:);         % pick proper limit
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
   
   hold(iif(held,'on','off'));         % restore hold state
   return
end

function hdl = Grid(o)                 % Switch Grid On/Off            
%
% GRID  Switch grid on/off
%
%    Option Settings:
%       segments:     segmentation lines on/off (1/0)
%
   either = @o.either;                 % need some utility
   
   nmax = subplot(o,inf);
   grd = either(opt(o,'grid'),0);
   plotmode = PlotMode(o);
   
   if (grd == 0)
      for (k = 1:nmax)                         % go through all subplots
         subplot(o,k);                         % select k-th subplot
         grid off
      end
      return
   end
%
% We need to dispatch on plotmode. For normal 'stream' mode there is
% a bit more todo since the vertical grid lines have to match with
% the segment boundaries
%
   xscale = either(opt(o,'xscale'),1);         % x-scaling factor
   
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
            set(gca,'xtick',rd(x,1));          % vertical segment lines
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
   return
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

function [mode,arg2] = PlotMode(o)     % Extract Plot Mode             
   mode = lower(arg(o,1));
end

function txt = Capital(txt)
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

