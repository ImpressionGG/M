function out = plot(obj,hax)
%
% PLOT    Plot a CORE object. First argument can either be a single CORE
%         object or a list (cell array) of CORE objects. In case of a list
%         argument plot is recursively called for each list element.
%
%            plot(obj,hax)            % plot into single 'gca' axis object
%            plot(obj,[ax1,ax2])      % plot to dual axis objects
%            plot({obj1, obj2, obj3})
%
%         Plot function behaves on the data structure itself and on the
%         option settings, which might be defined by a call:
%
%         Example 1:
%            t = 0:pi/50:4*pi;  xy = [sin(t); cos(t)];
%            obj = core({t,xy});
%            figure(1); 
%            plot(obj);                % single axis; same as plot(obj,gca)
%            figure(2);
%            plot(obj,[subplot(211),subplot(212)]);   % dual axes
%
%         Example 2:
%            obj = core(gfo);          % create core object with options
%                                      % derived from menu/figure
%            obj = set(obj,'color',{'r','g'});
%            plot(obj,[subplot(211),subplot(212)]);
%
%         See also: CORE
%
   hdl = [];                                % init
   if (nargin < 2) hax = gca;  end

   if (iscell(obj))                         % if argument is a list
       held = ishold;
       for (i=1:length(obj))
          hdl(i) = plot(obj{i});            % recursively call the plot function
          hold on;
       end
       if (held)
          hold on;
       else
          hold off;
       end
       if (nargout > 0) out = hdl; end
       return    % done!
   end
   
% Otherwise we have a single object which we go now to plot

   fmt = eval('obj.data.format','???');
   switch fmt
       case '#DOUBLE'
          hdl = PlotXY(obj,hax,obj.data.x,obj.data.y);
          if (isfield(obj.data,'yf'))
             bullets = option(obj,'bullets');
             %obj = option(obj,'color',iif(bullets,{'y'},{'y'}));
             %obj = set(obj,'color',{[0.8 0.8 0]});
             obj = set(obj,'color',{'p'});
%            PlotXY(obj,hax,obj.data.x,obj.data.yf/factor);   % no handle
             PlotXY(obj,hax,obj.data.x,obj.data.yf);         % no handle
          end
       case '#IMAGE'
          ydir = get(hax,'ydir');
          hdl = image(obj.data.image);
          if ~isempty(obj.data.cmap)
             colormap(obj.data.cmap);
          end
          set(hax,'ydir',ydir);
          
          position = eval('obj.parameter.position','[0;0]');
          xdata = eval('obj.parameter.xdata','[]');
          ydata = eval('obj.parameter.ydata','[]');
          
          xdata = iif(isempty(xdata),get(hdl,'xdata'),xdata);
          ydata = iif(isempty(ydata),get(hdl,'ydata'),ydata);
          
          set(hdl,'xdata',xdata+position(1),'ydata',ydata+position(2));

       otherwise
          error(['core::plot(): bad data kind ''',kind,'''!']);
   end

   if (nargout > 0) out = hdl; end
   return
end   

%==========================================================================
% PLOTXY
%==========================================================================

function hdl = PlotXY(obj,hax,x,y)
%
% PLOT-XY   Plot xy-data, controlled by object's parameter settings
%
%           Parameter Settings:
%              color:    character string or list of character strings 
%                        defining sequence of colors to be used for plots
%              bullets:  flag 0/1 indicating to draw also black bullets
%              ylim:     y-limits
%                        
   profiler('PlotXY',1);
   
   xscale = either(option(obj,'xscale'),1);     % get x-scaling factor
   yscale = either(option(obj,'yscale'),1);     % get y-scaling factor (drift,devi.)
   ascale = either(option(obj,'ascale'),1);     % get y-scaling factor (absolute)
   biasmode = either(option(obj,'biasmode'),0); % get bias mode
   
   if (isempty(x))
      x = get(obj,'time');
   end

   x = x * xscale;                    % scale x data
   if strcmp(biasmode,'absmm')
      y = y * ascale;                 % scale y data (absolute mode)
   else
      y = y * yscale;                 % scale y data (drift, deviation)
   end
   
   if (isempty(x))
      x = 1:length(y);
   end

   if isempty(y)
      set(gca,'visible','off','xlim',[-1 1],'ylim',[-1 1]);
      hdl = text(0,0,'No coordinate selected!');
      set(hdl,'HorizontalAlignment','center');
   end
   
      % the AlignXY function aligns x and y in a feasible way for 
      % the following plot loops, examines the number of plots and
      % checks also whether x and y match exactly by dimension.
      
   [x,y,n,match] = AlignXY(x,y);      % align x and y matrices for plotting
   clist = colorlist(obj,n);          % get proper color list
   xlim = cyclist(obj,'xlim',n);      % x-limits
   ylim = cyclist(obj,'limits',n);    % y/z-limits
   linw = cyclist(obj,'linewidth',n); % line width
   
      % depending on the size of hax (handle to axes object) we have to
      % plot either to one or multiple axes. Alternatively we also have to
      % handle the case with multiple axes handles (vector of handles).
      % Be noted that in this case the iterative plots will be placed into
      % the axes object modulus the number of axes handles.

   idx = 0;  % init: preliminary index to axes handle
      
   held = ishold;                     % save hold status
   hold on;
   
   if (length(hax) == 1)
      axes(hax);                      % select axes(hax(idx)) as current
   end
   
   hdl = [];
   for (i=1:n)                        % run through all plots
      idx = 1 + rem(idx,length(hax)); % next axes index
      if (length(hax) > 1)
         axes(hax(idx));              % select axes(hax(idx)) as current
      end
      
      if (min(size(x)) <= 1)          % if x is a vector
         xx = x;  yy = y(:,i);
      elseif (min(size(y)) <= 1)      % if y is a vector
         xx = x(:,i);  yy = y;
      elseif (match)                  % if same number of columns x & y
         xx = x(:,i);  yy = y(:,i);
      else                            % dimension mismatch => cannot deal
         error('smart::plot(): unproper dimensions for x,y!');
      end
      
      hdl(i) = plot(xx,yy,'color',color(clist{i}));
      hold on;
      if (option(obj,'bullets'))      % plot also black bullets?
         plot(xx,yy,'k.');
      end
      
      if (~isempty(xlim)) 
          set(gca,'xlim',xlim{i});
      else
          if (max(x) > min(x))       % avoid crash
             set(gca,'xlim',[min(x),max(x)]);
          end
      end
      if (~isempty(ylim)) set(gca,'ylim',ylim{i});  end
      if (~isempty(linw)) set(hdl(i),'linewidth',linw{i});  end
      
      set(gca,'box','on');
   end

   HandleGrid(obj,hax);               % handle grid option
   Labeling(obj,hax,y);               % provide title, x/y-label

   if (~held) hold off; end
   
   profiler('PlotXY',0);
   return
end

%==========================================================================
% Handle Grid
%==========================================================================

function HandleGrid(obj,hax)  % set grid on/off for all specified axes handles
%
% HANDLE-GRID
%
   spec = option(obj,'spec');
   grd = option(obj,'grid');
   
   for (i=1:length(hax))
      grid(hax(i),iif(grd,'on','off'));
      if (spec)
         xlim = get(hax(i),'xlim');
         ylim = get(hax(i),'ylim');
         axes(hax(i));
         hdl = plot(xlim,spec(1)*[1 1],'b-.', xlim,spec(2)*[1 1],'b-.');
         set(hdl,'linewidth',2);
         ylim(1) = min(ylim(1),spec(1)-(spec(2)-spec(1))*0.05);
         ylim(2) = max(ylim(2),spec(2)+(spec(2)-spec(1))*0.05);
         set(hax(i),'ylim',ylim);
      end
   end
   return
end

%==========================================================================
% Labeling
%==========================================================================
   
function Labeling(obj,hax,y) %  % provide title, x/y-label
%
% LABELING
%
   statistic = option(obj,'statistic');
   prefixes = option(obj,'prefix');
   suffixes = option(obj,'suffix');
   yunit = option(obj,'yunit');             % y-unit (drift,deviation)
   aunit = option(obj,'aunit');             % y-unit (absolute bias mode)
   yscale = option(obj,'yscale');           % y-scale for drift & deviation
   ascale = option(obj,'ascale');           % y-scale for absmm mode
   biasmode = option(obj,'biasmode');      
   spec = option(obj,'spec');               % specification limits
   
   scale = iif(strcmp(biasmode,'absmm'),ascale,yscale);
   unit = iif(strcmp(biasmode,'absmm'),aunit,yunit);
   
   dispmode = option(obj,'dispmode');
   sel = option(obj,'select');
   if (~strcmp(dispmode,'substream'))
      %sel = 0;                              % overwrite
   end
   
   symbols = get(obj,'symbol');
   titles  = get(obj,'title');
   xlabels = get(obj,'xlabel');
   ylabels = get(obj,'ylabel');
   
   n = length(hax);                 % number of axes
   prefix = Examine(prefixes,n);    % n-th prefix list
   suffix = Examine(suffixes,n);    % n-th suffix list
   
   for (i=1:n)
      
         % Examine i-th title, xlabel, ylabel from tables/lists
         
      titl = Examine(titles,i);     % examine titles("i")
      xlab = Examine(xlabels,i);    % examine xlabels("i")
      ylab = Examine(ylabels,i);    % examine ylabels("i")

      if (~isempty(xlab) && ~isempty(sel))
          xlab = [sprintf('Selection: %g - ',sel),xlab,];
      end
      
         % examine i-th symbol and compose symbol information
      
      pref = Examine(prefix,i);
      suff = Examine(suffix,i);
      symb = Examine(symbols,i);    % examine symbol("i")
      if (~isempty(symb))
         symb = [pref,symb,suff];
      end

         % prepare statistic information
      
      stats = '';                                 % init statistic string
      if (statistic)
         %idx = 1:size(y,2);                      % dim = column number
         %idx = find((rem(idx-1,n) == i-1));
         idx = ModIndex(size(y,2),n,i);             % modulus index vector
         
         yi = y(:,idx);
         yi = iif(isempty(yi),NaN,yi(:));
         
         avg = mean(yi); 
         sigma = std(yi/scale);
         range = max(yi/scale) - min(yi/scale);
         
         if spec
            lsl = spec(1);  usl = spec(2);
            cpk = min(usl-avg,avg-lsl)/(3*sigma);
            cp = (usl-lsl)/(6*sigma);
            capa = sprintf([', Cpk: %g, Cp: %g'],rd(cpk),rd(cp));
         else
            capa = '';
         end

            % Unit and Yunit can be either string or cell arrays.
            % In case of cell array we have to index
            
         Yunit = eval('yunit{min(i,n)}','yunit');
         Unit = eval('unit{min(i,n)}','unit');
         
         fmt = [' (M%s: %g',Unit,', S%s: %g',Yunit,', R%s: %g',Yunit,capa,')'];
         stats = sprintf(fmt,suff,rd(avg),suff,rd(sigma),suff,rd(range));
      end
      
      if (isempty(symb))
         ctitle = [titl,stats];                  % construct complete title
      else
         ctitle = [symb,': ',titl,stats];        % construct complete title
      end
      
      axes(hax(i));
      title(ctitle);
      xlabel(xlab);
      ylabel(ylab);
   end
   return
end

%==========================================================================
% Modulo Index
%==========================================================================

function idx = ModIndex(dim,modulus,i)
%
% MOD-INDEX Calculate modulo index vector for loop run number 'i'.
%
%              dim = 10;                 % 10 data columns
%              data = rand(100,dim);     % 100xdim data matrix
%              n = 3;                    % n: modulus
%              for (i=1:n)              
%                 idx = ModIndex(dim,n,i)% calculate modulo indices
%                  :        :
%              end
%
%           In this example MINDEX results the following results:
%
%              i = 1  ->  idx = [1 4 7 10]
%              i = 2  ->  idx = [2 5 8]
%              i = 3  ->  idx = [3 6 9]
%
%
   idx = 1:dim; 
   idx = find((rem(idx-1,modulus) == i-1));
   return
end
         
function j = xmod(i,modulus)
%
% XMOD    Extended modulus: From an index range 1:n and a given index i 
%         calculate an index j which fits into the range 1:n.
%
%            j = xmod(,modulus)
%
%         Example
%
%            idx = xmod(1:10,3)  ->  idx = [1 2 3 1 2 3 1 2 3 1]
%            
   j = rem(i-1,modulus)+1;
   return
end

%==========================================================================
% Examine
%==========================================================================

function entry = Examine(collection,i)
%
% EXAMINE    Examine "i-th" entry of a collection. The argument
%            'collection' can be either a string, a character matrix or
%            a list.
%
%               entry = Examine(collection,i)  % get "i-th" entry
%
%            Examples:
%               entry = Examine('Noise',i)   => examine = 'Noise' (any i!)
%              
%               table = [['red  ';'blue ';'green'];
%               entry = Examine(table,1)   => examine = 'red  '
%               entry = Examine(table,2)   => examine = 'blue '
%               entry = Examine(table,3)   => examine = 'green'
%               entry = Examine(table,4)   => examine = ''
%               entry = Examine(table,5)   => examine = ''
%
%               list = {'absolute','drift','deviation'};
%               entry = Examine(list,1)    => examine = 'absolute'
%               entry = Examine(list,2)    => examine = 'drift'
%               entry = Examine(list,3)    => examine = 'deviation'
%               entry = Examine(list,4)    => examine = ''
%               entry = Examine(list,5)    => examine = ''
%
   entry = '';
   if (isempty(collection))
      return
   elseif (isstr(collection))
      if (size(collection,1) == 1)
         entry = collection;                   % plain string
      else
         n = size(collection,1);
         if (i <= n)
            entry = collection(i,:);      
         end
      end
   elseif (iscell(collection))
      n = length(collection(:));
      if (i <= n)
         entry = collection{i};
      end
   else
      error('Examine(): string, string matrix or list expected for arg1!');
   end
   return
end

%==========================================================================
% Plot Frame
%==========================================================================

function PlotFrame
%
% PLOTFRAME   Plot a frame for current axes
%
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');   
   
   x = [xlim(1) xlim(2)*[1 1] xlim(1)*[1 1]];
   y = [ylim(1)*[1 1] ylim(2)*[1 1] ylim(1)];   
   
   hdl = plot(x,y,'color',[1 1 1]*0);
   set(hdl,'linewidth',1);
   return
end

function [x,y,nplots,match] = AlignXY(x,y)
%
% ALIGNXY    Align x and y matrices for plotting. Check for compatible
%            dimensions of x and y vector (matrices) and return number of
%            plots to be made (nplots), and a flag (match) indicating
%            the special case whether x and y dimensions are matching
%
%               [x,y,nplots,match] = AlignXY(x,y);   % align
%
%            Note what is working! Consider two 'high' rectangular matrices
%            x and y of dimension 10 x 2 (per default use 'high' matrices:
%
%               x = sort(rand(10,3));
%               y = sort(rand(10,3));
%
%            The following cases work:
%
%               a) plot(x,y)             % same dimensions x & y
%               b) plot(x(:,1),y)        % proper column vector x
%               c) plot(x(:,1)',y)       % proper row vector x
%               d) plot(x(:,1),y')       % proper column vector x
%               e) plot(x(:,1)',y')      % proper row vector x
%               f) plot(x,y(:,1))        % proper column vector y
%               g) plot(x,y(:,1)')       % proper row vector y
%               h) plot(x(:,1),y(:,1))   % column x, column y 
%               i) plot(x(:,1),y(:,1)')  % column x, row y
%               j) plot(x(:,1)',y(:,1))  % row x, column y
%               k) plot(x(:,1)',y(:,1)') % row x, row y
%               l) plot([],[])           % empty x, y
%             
%            And this will fail:
%
%               1) plot(x',y)            % swapped dimensions x & y
%               2) plot(x,y')            % swapped dimensions x & y
%               3) plot([],y)            % empty x
%               4) plot(x,[])            % empty y
%
   mindimx = min(size(x));          % the smaller dimension of x
   if (mindimx == 1)                % is x a vector ?
      x = x(:);                     % align x => now column vector
   end
   
   mindimy = min(size(y));          % the smaller dimension of y
   if (mindimy == 1)
      y = y(:);                     % align y => now column vector
   end
   
   x = iif(isempty(x),[],x);        % tricky: empty can be 0x0, 0x1, 1x0
   y = iif(isempty(y),[],y);        % tricky: empty can be 0x0, 0x1, 1x0
   
      % our first pre-alignment has been done. If x or y is a vector
      % then we have made sure that it is a column vector
      
   [mx,nx] = size(x);               % get dimensions of x
   [my,ny] = size(y);               % get dimensions of y
      
   match = all(size(x)==size(y));   % same dimensions?

      % since all matrices are now aligned it now easy
      % to determine the number of plots
     
   if (~match)                      % if dimensions do not match
      if (nx == 1)                  % ultimate chance for x-vectors            
         if (mx == ny)              % could x column number match y rows?
            y = y';                 % yes, works!  go with the transposed y
         end
      elseif (ny == 1)              % ultimate chance for y-vectors            
         if (my == nx)              % could y column number match x rows?
            x = x';                 % yes, works!  go with the transposed x
         end
      end
   end
   
   [mx,nx] = size(x);               % update dimensions of x
   [my,ny] = size(y);               % update dimensions of y

   if (mx ~= my)                    % final check
       error('dimensions of x and y incompatible!');
   end

   nplots = max(nx,ny);             % take the bigger number of columns!
   
   return
end
