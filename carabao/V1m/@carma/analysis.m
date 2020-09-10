function oo = analysis(o,varargin)     % Graphical Analysis            
% ANALYSIS   Graphical analysis
%
%
%    Plenty of graphical analysis functions
%
%       analysis(o)               % analysis @ opt(o,'mode.analysis')
%
%       analysis(o,'Path')        % display matrix path
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
%    See also: CARALOG, CONFIG, PLOT
%
   [func,o] = manage(o,varargin,@Surf,@Residual,@SurfPlot,@ZigZag,...
                                @Path,@Arrow);
   oo = func(o);                  % invoke local function
end

%==========================================================================
% Matrix Path & Zigzag Path
%==========================================================================

function hdl = Surf(o)                 % Surf Plot                     
%
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw surface plot!','check stream configuration!');
      return
   end

   x = cook(o,symbols{1},'ensemble');  % get x data in proper format
   y = cook(o,symbols{2},'ensemble');  % get y data in proper format
   
   SurfPlot(o,x,y);
end
function hdl = Residual(o)             % Residual                      
%
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw surface plot!','check stream configuration!');
      return
   end

   x = cook(o,symbols{1},'residual1');  % get x data in proper format
   y = cook(o,symbols{2},'residual1');  % get y data in proper format
   
   SurfPlot(o,x,y);
end
function hdl = SurfPlot(o,x,y)         % Surface Plot                  
%
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   if (length(x(:)) ~= m*n*r || length(y(:)) ~= m*n*r)
      message(o,'Unable to draw surface plot!',...
                'Consider change of settings!');
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
            surf(hax,X);
         case 'Y'
            surf(hax,Y);
      end
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

   tit = sprintf('%s (%s)',get(o,{'title'},''),arg(o,1));
   title(hax,underscore(o,tit));
   
%       M = [x;y];                       % vector set
%       if is(mode,{'pcorrx','pcorry','fpcorrx','fpcorry','offsetx','offsety'})
%          NormalLegend('Deviations:',M)
%       elseif is(mode,{'rcorrx','rcorry','frcorrx','frcorry'})
%          ResidualLegend(o,M,T{i})
%       elseif is(mode,{'rnoisex','rnoisey','anoisex','anoisey'})
%          NormalLegend('Noise:',M)
%       end
   
   plotinfo(o,['Surface Plot ',arg(o,1)]);
end
function hdl = Zigzag(o)               % Display ZigZag Path           
%
   hdl = [];                           % init by default

   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw Matrix Path!','check stream configuration!');
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
   raster = opt(o,{'analysis.geometry.raster'},[5 5]);
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
   clist = colorlist(util,seed,5);     % length 5 is far big enough
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
         clist = colorlist(u,seed,N);  % make a longer colorlist
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
            shg;                                % show periodically
         end
         if (stop(o)) 
            return
         end
      end
   end   
end
function hdl = Path(o)                 % Display Matrix Path           
%
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   
   symbols = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw Matrix Path!','check stream configuration!');
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
   clist = colorlist(util,seed,5);     % length 5 is far big enough
%
% ball plot of matrix locations
%
   hdl = [];
   for (j=1:r)
      system = sy(:,j);                % pick system
      n = 0;                           % init system index
      ro = [];                         % init old values
      so = nan;                        % old system
      
      while is(system)
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
            color(h,clist{n});         % set cyclical color
            
            hdl = [hdl; h(:)];
            if isnan(ro(n,1))
               h = plot(rk(1),rk(2),'k.');  hold on;     
               color(h,clist{n});      % set cyclical color
               hdl = [hdl; h(:)];
            else
               h = plot([ro(n,1) rk(1)],[ro(n,2) rk(2)],'r');  hold on;     
               color(h,clist{n});      % set cyclical color
               hdl = [hdl; h(:)];
            end
            
            ro(n,:) = rk;              % next time old value (ro)
         end
      end % while is(sys)
   end   
end
function hdl = Arrow(o)                % Display Arrows                
%
   hdl = [];                           % init by default
   [m,n,r] = sizes(o);
   mnr = m*n*r;
   
   [symbols,spec] = Symbols(o);   
   if length(symbols) ~= 2
      message(o,'Cannot draw Matrix Path!','check stream configuration!');
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
% scale up reference coordinates, according to options
%
   o = with(o,'analysis.geometry');
   path = opt(o,{'path'},0.1);
   zigzag = opt(o,{'zigzag'},0.1);
   raster = opt(o,{'raster'},[5 5]);
   
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

   seed = {'m','b','d','c','r'};       % color seed
   clist = colorlist(util,seed,5);     % length 5 is far big enough
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
         ri = [rx(i,j),ry(i,j)];                 % actual value
         pi = [px(i,j),py(i,j)];                 % actual value
         s = sy(i,j);
         
         h = plot(ri(1),ri(2),'k+');             % target position
         color(h,clist{s});                      % set cyclical color
         hdl = [hdl; h(:)];

         %h = plot(pi(1),pi(2),'ko');
         h = plot(pi(1),pi(2),'.');
         color(h,clist{s});                      % set cyclical color
         hdl = [hdl; h(:)];
         
         o = Deltoid(o,ri',(pi-ri)',spec);
         
         if zigzag && (so ~= s) && ~isnan(so)    % a zigzag skip ?
            h = plot([po(so,1) pi(1)],[po(so,2) pi(2)],'k');
            col = color(clist{so});
            color(h,1-zigzag*(1-col));           % set cyclical color
            hdl = [hdl; h(:)];
         end

         while (path)                            % plot the path       
            if isnan(po(s,1))                    % very first time
               h = plot(pi(1),pi(2),'k.');
               color(h,clist{s});                % set cyclical color
               if (path)
                  h = plot(pi(1),pi(2),'o');
                  color(h,clist{s});             % set cyclical color
               end
               hdl = [hdl; h(:)];
            else
               h = plot([po(s,1) pi(1)],[po(s,2) pi(2)],'k');
               col = color(clist{s});
               color(h,1-path*(1-col));          % set cyclical color
               hdl = [hdl; h(:)];
            end
            break
         end
         
         so = s;  po(s,:) = pi;        % next time old value (so & po)
         if (rem(i,10) == 0)
            shg;                                % show periodically
         end
         if (stop(o)) 
            break
         end
      end
   end   
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
%             subidx = sub;              % mind subplot index
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
function o = Deltoid(o,targ,devi,spec)   % Plot a Deltoid              
%
% DELTOID   Plot a deltoid pointer symbol to display deviations
%
%    Given a 2D vset target and a 2D vset deviation for each j-th vector of
%    vector set a deltoid symbol is plotted with one corner at target(:,j)
%    and the other corner at (target(i,j) + devi(:,j)). The default color
%    is black.
%
%       o = Deltoid(o,targ,devi)            % plot deltoid symbols
%
%    If a spec argument (arg4) is provided, the color depends on the fact
%    whether the deviation values in x/y are 1.33 better than spec (green
%    color), between 1.0 and 1.33 of spec (yellow color) and out of spec 
%    (red color)
%
%       o = Deltoid(o,targ,devi,[-3,3])     % plot deltoid symbols
%
%    All graphic handles are added to the object variable var(o,'handles').
%
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
   style = opt(o,{'deltoid'},0.4);
   lwid = opt(o,{'linewidth'},2);
   
   xy0 = [0 0.5*style 1 0.5*style 0
          0 style/2 0 -style/2 0
         ];                            % vset for rhomb
%
% plot the actual rhomb for each vector of the vector set
%
   for (i=1:n)
      p = targ(:,i);  v = devi(:,i);
      r = norm(v,2);                   % norm of vector (like a radius)
      phi = atan2(v(2),v(1));
      
      T = norm(v)*[cos(phi) -sin(phi); sin(phi) cos(phi)];
      xy = p*ones(1,size(xy0,2)) + T*xy0;
      h = plot(xy(1,:),xy(2,:));  hold on;
      color(h,clist{i},lwid);
   end
   
end

