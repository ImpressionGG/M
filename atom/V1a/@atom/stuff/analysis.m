function oo = analysis(o,varargin)     % Graphical Analysis            
%
% ANALYSIS   Graphical analysis
%
%    Plenty of graphical analysis functions
%
%       analysis(o)               % analysis @ opt(o,'mode.analysis')
%
%       oo = analysis(o,'Path')   % display matrix path
%       oo = analysis(o,'Surf')   % surface plot
%
%    Options: the following options influence the graphical behavior of
%    the analysis functions
% 
%       'mode'                    % analysis mode ('mode.analysis')
%       'style'                   % plot style (line width, bullets,labels)
%       'view'                    % view options
%       'grid'                    % grid on/off
%       'scope'                   % scope of data stream (matrix indices)
%
%    Remark: the work property var(oo,'hdl') of the returned object
%    contains all collected graphics handles for graphics objects gene-
%    rated during the plot process.

%    See also: CARAMEL, CONFIG, PLOT
%
   [gamma,o] = manage(o,varargin,@Surf,@Residual,@Fitted,...
                      @SurfPlot,@Zigzag,@Path,@Arrow);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Matrix Path & Zigzag Path
%==========================================================================

function oo = Surf(o)                  % Surf Plot                     
%
   oo = o;                             % save initial object
   o = with(o,'analysis.geometry');    % close-up option scope
   
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw surface plot!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw surface plot!','check dimensions!');
      return
   end

   x = cook(o,symbols{1},'ensemble');  % get x data in proper format
   y = cook(o,symbols{2},'ensemble');  % get y data in proper format
   
   if opt(o,{'averaging',0})
      x = mean([x';x'])';   y = mean([y';y'])';
      [m,n] = sizes(o);
      o.par.sizes = [m,n,1];           % adopt sizes
   elseif opt(o,{'centering',0})
      for (j=1:size(x,2))
         xj = x(:,j) - mean(x(:,j));
         yj = y(:,j) - mean(y(:,j));
         x(:,j ) = xj;  y(:,j) = yj;
      end
   end
   
   o = SurfPlot(o,x,y);
   oo = var(oo,'hdl',var(o,'hdl'));    % update plot handles
end
function oo = Residual(o)              % Residual                      
%
   oo = o;                             % save initial object
   o = with(o,'analysis.geometry');    % close-up option scope
   
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw residual plot!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw residual plot!','check dimensions!');
      return
   end

   x = cook(o,symbols{1},'residual1'); % get x data in proper format
   y = cook(o,symbols{2},'residual1'); % get y data in proper format
   
   o = SurfPlot(o,x,y);
   oo = var(oo,'hdl',var(o,'hdl'));    % update plot handles
end
function oo = Fitted(o)                % Fitted plot                   
%
   oo = o;                             % save initial object
   o = with(o,'analysis.geometry');    % close-up option scope
   
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw fitted plot!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw fitted plot!','check dimensions!');
      return
   end

   x = cook(o,symbols{1},'ensemble');  % get x data in proper format
   y = cook(o,symbols{2},'ensemble');  % get y data in proper format

   xr = cook(o,symbols{1},'residual1'); % get x residual in proper format
   yr = cook(o,symbols{2},'residual1'); % get y residual in proper format
   
   xf = x-xr;  yf = y-yr;
   o = SurfPlot(o,xf,yf);
   oo = var(oo,'hdl',var(o,'hdl'));    % update plot handles
end
function oo = SurfPlot(o,x,y)          % Surface Plot                  
%
   oo = o;                             % save initial object
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   if (length(x(:)) ~= m*n*r || length(y(:)) ~= m*n*r)
      message(o,'Unable to draw surface plot!',...
                'Consider change of settings!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw surface plot!','check dimensions!');
      return
   end

   meth = get(o,'method');
   if isempty(meth)
      message(o,'Unable to draw Surface Plot!',...
             'object does not provide processing method');
      return
   end

   [idx,Idx] = method(o,meth,m,n);
   for (i=1:r)
      xi = x(:,i);  yi = y(:,i);
      X = xi(Idx);  Y = yi(Idx);

      hax = gca(figure(o));            % axes handles via object fig hdl
      switch arg(o,1)
         case 'X'
            h = surf(hax,X);
         case 'Y'
            h = surf(hax,Y);
         otherwise
            h = [];
      end
      hdl = [hdl; h(:)];
      hold on;
   end
%
% setup view angles
%
   view(opt(o,{'view.camera.azel',[-40 30]}));
%
% labeling
%
   pts = size(X);                           % points(o);
   dst = [max(xi)-min(xi),max(yi)-min(yi)]; % distance(o);
   dst = o.rd(dst ./ (pts-1),1);
   
   set(hax,'ydir','reverse');
   set(hax,'fontsize',8)
   
   dx = max(x(:))-min(x(:))/(n-1);
   dy = max(y(:))-min(y(:))/(m-1);
   
   xtick = [min(x(:)) + (0:n-1)*dx] / 1000;
   ytick = [min(y(:)) + (0:m-1)*dy] / 1000;
   
   xtick = 1:pts(1);
   ytick = 1:pts(2);
   
   if ( pts(1) <= 10 ), set(hax,'xtick',xtick); end
   if ( pts(2) <= 10 ), set(hax,'ytick',ytick); end
   xlabel(hax,sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
   ylabel(hax,sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));

   if opt(o,{'averaging',0})
      tit = sprintf('%s (averaged %s)',get(o,{'title',''}),arg(o,1));
   else
      tit = sprintf('%s (%s)',get(o,{'title',''}),arg(o,1));
   end
   title(hax,underscore(o,tit));
   
%       M = [x;y];                       % vector set
%       if is(mode,{'pcorrx','pcorry','fpcorrx','fpcorry','offsetx','offsety'})
%          NormalLegend('Deviations:',M)
%       elseif is(mode,{'rcorrx','rcorry','frcorrx','frcorry'})
%          ResidualLegend(o,M,T{i})
%       elseif is(mode,{'rnoisex','rnoisey','anoisex','anoisey'})
%          NormalLegend('Noise:',M)
%       end
   
   if opt(o,{'averaging',0})
      what(o,['Averaged Surface Plot ',arg(o,1)]);
   else
      what(o,['Surface Plot ',arg(o,1)]);
   end
   
   oo = var(oo,'hdl',hdl);             % return plot handles
end
function oo = Zigzag(o)                % Display ZigZag Path           
%
   oo = o;                             % save initial object
   color = @o.color;                   % need a utility
   hdl = [];                           % init by default

   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw matrix path!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw matrix path!','check dimensions!');
      return
   end

   x = cook(o,symbols{1},'ensemble');  % get x data in proper format
   y = cook(o,symbols{2},'ensemble');  % get y data in proper format
   
   if (length(x(:)) ~= m*n*r || length(y(:)) ~= m*n*r)
      message(o,'Unable to construct matrix path!',...
                'Consider change of settings!');
      return
   end
   
   meth = get(o,'method');
   if isempty(meth)
      message(o,'Cannot draw Matrix Path!',...
             'object does not provide processing method');
      return
   end
   
   rx = cook(o,'$x','ensemble','absolute');   % refrence x-coordinates
   ry = cook(o,'$y','ensemble','absolute');   % refrence y-coordinates
   sy = cook(o,'#','ensemble','absolute');    % system number
%
% scale up reference coordinates, according to options
%
   raster = opt(o,{'analysis.geometry.raster',[5 5]});
   rx = rx * raster(1);   
   ry = ry * raster(2);   
%
% at positions
%
   px = rx + x;
   py = ry + y;
%
% setup plotting area
%
   xmin = min(rx(:));  xmax = max(rx(:));  dx = xmax - xmin;
   ymin = min(ry(:));  ymax = max(ry(:));  dy = ymax - ymin;
   
   fac = 0.2;
   xlim = [xmin-fac*dx, xmax+fac*dx];
   ylim = [ymin-fac*dy, ymax+fac*dy];
   
   plot(xlim(1),ylim(1),'k', xlim(2),ylim(2),'k');  hold on
   set(gca,'xlim',xlim,'ylim',ylim);
   daspect([1 1 1]);

   seed = {'m','d','r','b','c'};       % color seed
   clist = ColorList(o,seed,5);        % length 5 is far big enough
%
% ball plot of matrix locations
%
   hdl = [];
   for (j=1:r)                                                         
      sys = sy(:,j);                   % system indices (current repeat)
      [idx,Idx] = method(o,meth,m,n,sys);

      v = [];  v(sys) = sys*nan;       % auxillary - build from system idx
      po = [v;v]';                     % old reference values
      so = nan;                        % old system
      
      while length(so) > length(clist) % color list big enough ?       
         u = util;  N = length(so);
         clist = ColorList(o,seed,N);  % make a longer colorlist
         break
      end
      
      for (i = 1:length(idx))
         ri = [rx(i,j),ry(i,j)];                 % actual value
         pi = [px(i,j),py(i,j)];                 % actual value
         s = sy(i,j);
         
         h = plot(ri(1),ri(2),'k+');             % target position
         hdl = [hdl; h(:)];
         %h = plot(pi(1),pi(2),'ko');
         h = plot(pi(1),pi(2),'.');
         color(h,clist{s});                      % set cyclical color
         hdl = [hdl; h(:)];
         
         o = Deltoid(o,ri',(pi-ri)',spec);
         hdl = [hdl; var(o,'hdl')];
         
         if (so ~= s) && ~isnan(so)              % a zigzag skip ?
            h = plot([po(so,1) pi(1)],[po(so,2) pi(2)],'k');
            col = color(clist{so});
            color(h,1-0.1*(1-col));              % set cyclical color
            hdl = [hdl; h(:)];
         end
         
         if isnan(po(s,1))
            h = plot(pi(1),pi(2),'k.');
            color(h,clist{s});                   % set cyclical color
            hdl = [hdl; h(:)];
         else
            h = plot([po(s,1) pi(1)],[po(s,2) pi(2)],'k');
            color(h,clist{s});                   % set cyclical color
            hdl = [hdl; h(:)];
         end

         so = s;  po(s,:) = pi;        % next time old value (so & po)

            % shg figure from time to time & handle stop

         if (rem(i,10) == 0)
            shg;                       % show periodically
         end
         if (stop(o)) 
            oo = var(oo,'hdl',hdl);    % return plot handles
            return
         end
      end
   end   
   oo = var(oo,'hdl',hdl);             % return plot handles
end
function oo = Path(o)                  % Display Matrix Path           
%
   oo = o;                             % save initial object
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   
   symbols = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw matrix path!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw matrix path!','check dimensions!');
      return
   end
   
   rx = cook(o,'$x','ensemble','absolute');   % refrence x-coordinates
   ry = cook(o,'$y','ensemble','absolute');   % refrence y-coordinates
   sy = cook(o,'#','ensemble','absolute');    % system number
   
%    x = cook(o,symbols{1},'ensemble');  % get x data in proper format
%    y = cook(o,symbols{2},'ensemble');  % get y data in proper format
%    
%    if (length(x(:)) ~= mnr || length(y(:)) ~= mnr)
%       message(o,'Unable to construct matrix path!',...
%                 'Consider change of settings!');
%       return
%    end
%

%
% setup plotting area
%
   xmin = min(rx(:));  xmax = max(rx(:));  dx = xmax - xmin;
   ymin = min(ry(:));  ymax = max(ry(:));  dy = ymax - ymin;
   
   xlim = [xmin-0.1*dx, xmax+0.1*dx];
   ylim = [ymin-0.1*dy, ymax+0.1*dy];
   
   plot(xlim(1),ylim(1),'k', xlim(2),ylim(2),'k');  hold on
   set(gca,'xlim',xlim,'ylim',ylim);
   
   seed = {'m','d','r','b','c'};       % color seed
   clist = ColorList(o,seed,5);        % length 5 is far big enough
%
% ball plot of matrix locations
%
   hdl = [];
   for (j=1:r)
      system = sy(:,j);                % pick system
      n = 0;                           % init system index
      ro = [];                         % init old values
      so = nan;                        % old system
      
      while o.is(system)
         s = min(system);              % system number
         n = n+1;                      % count systems
         ro(n,1:2) = [nan,nan];        % init old values for n-th system
         
         if n > length(clist)
            clist = colorlist(util,seed,n); % make a longer colorlist
         end
         
         sdx = find(system == s);      % index of system to consider
         system(sdx) = [];             % clear (prepare for next loop)
         
         idx = find(sy(:,j) == s);     % index of system to consider
         for (k = 1:length(idx))
            i = idx(k);
            rk = [rx(i,j),ry(i,j)];    % actual value
            h = plot(rk(1),rk(2),'ko');  hold on;  
            o.color(h,clist{n});       % set cyclical color
            
            hdl = [hdl; h(:)];
            if isnan(ro(n,1))
               h = plot(rk(1),rk(2),'k.');  hold on;     
               o.color(h,clist{n});    % set cyclical color
               hdl = [hdl; h(:)];
            else
               h = plot([ro(n,1) rk(1)],[ro(n,2) rk(2)],'r');  hold on;     
               o.color(h,clist{n});    % set cyclical color
               hdl = [hdl; h(:)];
            end
            
            ro(n,:) = rk;              % next time old value (ro)
         end
      end % while is(sys)

         % shg figure from time to time & handle stop

      if (rem(j,1) == 0)
         shg;                          % show periodically
      end
      if (stop(o)) 
         oo = var(oo,'hdl',hdl);       % return plot handles
         return
      end
   end   
   oo = var(oo,'hdl',hdl);             % return plot handles
end
function oo = Arrow(o)                 % Display Arrows                
%
   oo = o;                             % save initial object
   o = with(o,'analysis.geometry');

   color = @o.color;                   % need a utility
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw arrow plot!','check stream configuration!');
      return
   end
   if (m <= 1) || (n <= 1)
      message(o,'Cannot draw arrow plot!','check dimensions!');
      return
   end

   x = cook(o,symbols{1},'ensemble');  % get x data in proper format
   y = cook(o,symbols{2},'ensemble');  % get y data in proper format
   
   if 0 && (length(x(:)) ~= m*n*r || length(y(:)) ~= m*n*r) % ignore
      message(o,'Unable to run Arrow Plot!',...
                'Consider change of settings!');
      return
   end
   
   meth = get(o,'method');
   if isempty(meth)
      message(o,'Unable to run Arrow Plot!',...
             'object does not provide processing method');
      return
   end
   
   rx = cook(o,'$x','ensemble','absolute');   % refrence x-coordinates
   ry = cook(o,'$y','ensemble','absolute');   % refrence y-coordinates
   sy = cook(o,'#','ensemble','absolute');    % system number
%
% perform averaging if enabled
%
   if opt(o,{'averaging',0})
      x = mean([x';x'])';      y = mean([y';y'])';
      rx = mean([rx';rx'])';   ry = mean([ry';ry'])';
      [m,n] = sizes(o);
      o.par.sizes = [m,n,1];           % adopt sizes
      sy = mean([sy';sy'])';           % give it a trial
      if any(round(sy)~=sy)            % can only deal with integer values
         message(o,'Cannot Perform Averaging for Dual System!');
         return
      end
   end
%
% scale up reference coordinates, according to options
%
   path = opt(o,{'path',0.1});
   zigzag = opt(o,{'zigzag',0.1});
   raster = opt(o,{'raster',[5 5]});
   
   rx = rx * raster(1);   
   ry = ry * raster(2);   
%
% at positions
%
   px = rx + x;
   py = ry + y;
%
% setup plotting area
%
   xmin = min(rx(:));  xmax = max(rx(:));  dx = xmax - xmin;
   ymin = min(ry(:));  ymax = max(ry(:));  dy = ymax - ymin;

   dx = o.iif(dx==0,dy,dx);
   dy = o.iif(dy==0,dx,dy);
   
   fac = 0.2;
   xlim = [xmin-fac*dx, xmax+fac*dx];
   ylim = [ymin-fac*dy, ymax+fac*dy];
   
   plot(xlim(1),ylim(1),'k', xlim(2),ylim(2),'k');  hold on
   set(gca,'xlim',xlim,'ylim',ylim);
   daspect([1 1 1]);

   seed = {'m','b','d','c','r'};       % color seed
   clist = ColorList(o,seed,5);        % length 5 is far big enough
%
% ball plot of matrix locations
%
   hdl = [];
   for (j=1:size(sy,2))
      sys = sy(:,j);                   % system indices (current repeat)
      [idx,Idx] = method(o,meth,m,n,sys);

      v = [];  v(sys) = sys*nan;       % auxillary - build from system idx
      po = [v;v]';                     % old reference values
      so = nan;                        % old system
      
      while length(so) > length(clist) % color list big enough ?       
         u = util;  N = length(so);
         clist = colorlist(u,seed,N);  % make a longer colorlist
         break
      end
      
      for (i = 1:length(idx))
         ri = [rx(i,j),ry(i,j)];       % actual value
         pi = [px(i,j),py(i,j)];       % actual value
         s = sy(i,j);
         
         h = plot(ri(1),ri(2),'k+');   % target position
         color(h,clist{s});            % set cyclical color
         hdl = [hdl; h(:)];

         %h = plot(pi(1),pi(2),'ko');
         h = plot(pi(1),pi(2),'.');
         color(h,clist{s});            % set cyclical color
         hdl = [hdl; h(:)];
         
         o = Deltoid(o,ri',(pi-ri)',spec);
         hdl = [hdl; var(o,'hdl')];
         
         if zigzag && (so ~= s) && ~isnan(so)    % a zigzag skip ?
            h = plot([po(so,1) pi(1)],[po(so,2) pi(2)],'k');
            col = color(clist{so});
            color(h,1-zigzag*(1-col)); % set cyclical color
            hdl = [hdl; h(:)];
         end

         while (path)                  % plot the path       
            if isnan(po(s,1))          % very first time
               h = plot(pi(1),pi(2),'k.');
               color(h,clist{s});      % set cyclical color
               if (path)
                  h = plot(pi(1),pi(2),'o');
                  color(h,clist{s});   % set cyclical color
               end
               hdl = [hdl; h(:)];
            else
               h = plot([po(s,1) pi(1)],[po(s,2) pi(2)],'k');
               col = color(clist{s});
               color(h,1-path*(1-col));% set cyclical color
               hdl = [hdl; h(:)];
            end
            break
         end
         
         so = s;  po(s,:) = pi;        % next time old value (so & po)
         if (rem(i,10) == 0)
            shg;                       % show periodically
         end
         if (stop(o)) 
            oo = var(oo,'hdl',hdl);    % return plot handles
            break
         end
      end
   end   
   oo = var(oo,'hdl',hdl);             % return plot handles
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [symbols,spec] = Symbols(o)                                   
   subidx = 0;                         % init subplot index 
   symbols = {};                       % construct symbols in this plot
   total = {};                         % total symbol list (active symbols)
   for (j=1:subplot(o,inf))
      symbols{j} = {};                 % initialize symbols (per subplot)
   end
   
   for (i=1:config(o,inf))
      [sym,sub,col,cat] = config(o,i);
      if (sub > 0)
%          if is(sym,symbol)
%             subidx = sub;            % mind subplot index
%          end
         list = symbols{sub};
         list{end+1} = sym;            % extend list of symbols
         symbols{sub} = list;
         total{end+1} = sym;           % add to total symbol list
      end
   end
%
% now extract the proper symbol list
%
   if length(total) == 2
      symbols = total;
   elseif 1 || (subidx > 0)            % ####### dirty fix ############
      list = symbols;  symbols = {};
      for  (i=1:length(list))
         if length(list{i}) == 2
            symbols = list{i};
            break;
         end
      end
   else
      symbols = {};
   end
%
% get spec
%
   spec = [];
   if length(symbols) > 0
      [sub,col,cat] = config(o,symbols{1});
      [spec,~,~] = category(o,cat);    % get category attributes
   end
end
function oo = Deltoid(o,targ,devi,spec)% Plot a Deltoid                
%
% DELTOID   Plot a deltoid pointer symbol to display deviations
%
%    Given a 2D vset target and a 2D vset deviation for each j-th vector of
%    vector set a deltoid symbol is plotted with one corner at target(:,j)
%    and the other corner at (target(i,j) + devi(:,j)). The default color
%    is black.
%
%       o = Deltoid(o,targ,devi)       % plot deltoid symbols
%
%    If a spec argument (arg4) is provided, the color depends on the fact
%    whether the deviation values in x/y are 1.33 better than spec (green
%    color), between 1.0 and 1.33 of spec (yellow color) and out of spec 
%    (red color)
%
%       o = Deltoid(o,targ,devi,[-3,3])% plot deltoid symbols
%
%    All graphic handles are added to the object variable var(o,'handles').
%
   oo = o;                             % save initial object
   color = @o.color;                   % need utility
   [m,n] = size(targ);
   if (~all(size(devi) == [m,n]))
      error('incompatible sizes of target (arg2) and deviation (arg3)!');
   end
   
   if (nargin >= 4)
      if any(size(spec) ~= [1 2])
         error('spec (arg4) must be 1x2 row vector!');
      end
   end
%
% Calculate plot colors
%
   red = color('r');  yellow = color('z');  green = color('d');
   fac = 3;
   
   for (i=1:n)
      v = devi(:,i);
      if (nargin < 4)
         clist{i} = 'k';               % black by default
      elseif all(v > spec(1)/fac) && all(v < spec(2)/fac)
         clist{i} = green;          % perfect in spec
      elseif all(v >= spec(1)) && all(v <= spec(2))
         clist{i} = yellow;         % still in spec
      else
         clist{i} = red;            % out of spec
      end
   end      
%
% calculate the deltoid in nominal position (0°)
%
   style = opt(o,{'deltoid',0.4});
   lwid = opt(o,{'linewidth',2});
   
   xy0 = [0 0.5*style 1 0.5*style 0
          0 style/2 0 -style/2 0
         ];                            % vset for rhomb
%
% plot the actual rhomb for each vector of the vector set
%
   hdl = [];
   for (i=1:n)
      p = targ(:,i);  v = devi(:,i);
      r = norm(v,2);                   % norm of vector (like a radius)
      phi = atan2(v(2),v(1));
      
      T = norm(v)*[cos(phi) -sin(phi); sin(phi) cos(phi)];
      xy = p*ones(1,size(xy0,2)) + T*xy0;
      h = plot(xy(1,:),xy(2,:));  hold on;
      color(h,clist{i},lwid);
      hdl = [dl;h(:)];
   end
   oo = var(oo,'hdl',hdl);             % return plot handles
end
function clist = ColorList(o,varargin)                                 
%
% COLORLIST  Get color list for sequential plots
%
%    Get color list for sequential plots
%
%       clist = ColorList(o)           % default length
%       clist = ColorList(o,n)         % length n (cyclical)
%       clist = ColorList(o,[],n)      % same as colorlist(n)
%       clist = ColorList(o,clist,n)   % length n (cyclical)
%       clist = ColorList(o,o,n)       % based on object parameters
%
   [nin,arg1,arg2] = o.args(varargin);
   
   if (nin == 0)
      clist = { 
             'b'
             'g'
             'r'
             'c'
             'm'
             'y'
             'k'
             };
      return
   elseif (nin == 1)  % clist = colorlist(n)
      n = arg1;
      clist = colorlist(u,colorlist(u),n); 
      return
   elseif (nin == 2)  % clist = colorlist(clist,n)
      base = arg1;                            % base list
      n = arg2;                               % required length
      
         % in case of arg1 is a SMART object we fetch base color
         % list from the object parameters
         
      if (isobject(arg1)) 
         o = arg1;                            % CORE object as arg 1
         base = eval('get(o,''color'')','[]');
         if (isempty(base))
            base = eval('opt(o,''color'')','[]');
         end
         if isstr(base)
            base = {base};                    % always has to be a list!
         end
         if (~iscell(base))
            base = [];                        % empty if cannot be used!
         end
      end
      
         % if base is empty we go back to the default
         
      if (isempty(base))
         base = colorlist(u);
      end
      
         % now cyclically extend color list until we have n list items
         
      clist = [];
      for (i=1:n)
         clist{i} = base{1+rem(i-1,length(base))};  % extend list
      end
      return
   else
      error('less than 3 args expected!');
   end
end   
