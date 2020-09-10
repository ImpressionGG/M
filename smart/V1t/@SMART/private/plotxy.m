function hdl = plotxy(obj,hax,x,y)
%
% PLOTXY    Plot xy-data, controlled by object's parameter settings
%
%           Parameter Settings:
%              color:    character string or list of character strings 
%                        defining sequence of colors to be used for plots
%              bullets:  flag 0/1 indicating to draw also black bullets
%              ylim:     y-limits
%                        
   profiler('plotxy',1);
   
   xscale = option(obj,'xscale');     % get x-scaling factor
   yscale = option(obj,'yscale');     % get y-scaling factor (drift,devi.)
   ascale = option(obj,'ascale');     % get y-scaling factor (absolute)
   biasmode = option(obj,'biasmode'); % get bias mode
   
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
   
      % the alignxy function aligns x and y in a feasible way for 
      % the following plot loops, examines the number of plots and
      % checks also whether x and y match exactly by dimension.
      
   [x,y,n,match] = alignxy(x,y);      % align x and y matrices for plotting
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
   
   hdl = [];
   for (i=1:n)                        % run through all plots
      idx = 1 + rem(idx,length(hax)); % next axes index
      axes(hax(idx));                 % select axes(hax(idx)) as current

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

   handlegrid(obj,hax);               % handle grid option
   labeling(obj,hax,y);               % provide title, x/y-label

   if (~held) hold off; end
   
   profiler('plotxy',0);
   return
   
%==========================================================================

function handlegrid(obj,hax)  % set grid on/off for all specified axes handles

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

   
function labeling(obj,hax,y) %  % provide title, x/y-label

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
   if (~strcmp(dispmode,'substream')) sel = 0; end   % overwrite
   
   symbols = get(obj,'symbol');
   titles  = get(obj,'title');
   xlabels = get(obj,'xlabel');
   ylabels = get(obj,'ylabel');
   
   n = length(hax);                 % number of axes
   prefix = examine(prefixes,n);    % n-th prefix list
   suffix = examine(suffixes,n);    % n-th suffix list
   
   for (i=1:n)
      
         % examine i-th title, xlabel, ylabel from tables/lists
         
      titl = examine(titles,i);     % examine titles("i")
      xlab = examine(xlabels,i);    % examine xlabels("i")
      ylab = examine(ylabels,i);    % examine ylabels("i")

      if (~isempty(xlab) && sel)
          xlab = [sprintf('Selection: %g - ',sel),xlab,];
      end
      
         % examine i-th symbol and compose symbol information
      
      pref = examine(prefix,i);
      suff = examine(suffix,i);
      symb = examine(symbols,i);    % examine symbol("i")
      if (~isempty(symb))
         symb = [pref,symb,suff];
      end

         % prepare statistic information
      
      stats = '';                                 % init statistic string
      if (statistic)
         %idx = 1:size(y,2);                      % dim = column number
         %idx = find((rem(idx-1,n) == i-1));
         idx = mindex(size(y,2),n,i);             % modulus index vector
         
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

%==========================================================================

function idx = mindex(dim,modulus,i)
%
% MINDEX    Calculate modulo index vector for loop run number 'i'.
%
%              dim = 10;                 % 10 data columns
%              data = rand(100,dim);     % 100xdim data matrix
%              n = 3;                    % n: modulus
%              for (i=1:n)              
%                 idx = mindex(dim,n,i)  % calculate modulo indices
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
       
function entry = examine(collection,i)
%
% EXAMINE    Examine "i-th" entry of a collection. The argument
%            'collection' can be either a string, a character matrix or
%            a list.
%
%               entry = examine(collection,i)  % get "i-th" entry
%
%            Examples:
%               entry = examine('Noise',i)   => examine = 'Noise' (any i!)
%              
%               table = [['red  ';'blue ';'green'];
%               entry = examine(table,1)   => examine = 'red  '
%               entry = examine(table,2)   => examine = 'blue '
%               entry = examine(table,3)   => examine = 'green'
%               entry = examine(table,4)   => examine = ''
%               entry = examine(table,5)   => examine = ''
%
%               list = {'absolute','drift','deviation'};
%               entry = examine(list,1)    => examine = 'absolute'
%               entry = examine(list,2)    => examine = 'drift'
%               entry = examine(list,3)    => examine = 'deviation'
%               entry = examine(list,4)    => examine = ''
%               entry = examine(list,5)    => examine = ''
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
      error('examine(): string, string matrix or list expected for arg1!');
   end
   return

%==========================================================================

function plotframe
%
% PLOTFRAME   Plot a frame for current axes
%
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');   
   
   x = [xlim(1) xlim(2)*[1 1] xlim(1)*[1 1]];
   y = [ylim(1)*[1 1] ylim(2)*[1 1] ylim(1)];   
   
   hdl = plot(x,y,'color',[1 1 1]*0);
   set(hdl,'linewidth',1);
   
%eof