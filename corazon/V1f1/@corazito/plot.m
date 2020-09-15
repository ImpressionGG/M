function out = plot(varargin)          % Corazita Plot Method          
%
% PLOT   CORAZITO PLOT method. Extension of MATLAB plot function by
%        extended color strings denoting color, line width and line type
%
%           hdl = corazito.plot(hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = corazito.plot(x1,y1,'r',x2,y2,'b|o',...)
%
%           corazito.plot(x,y,'r')     % same as plot(x,y,'r')
%           corazito.plot(x,y,'r2')    % plot(x,y) in red, line width 2
%           corazito.plot(x,y,'r2.-')  % red, line width 2, solid and dot
%           corazito.plot(x,y,'r|o')   % red stems and balls
%
%        Forward argument list
%
%           corazito.plot(ilist)
%           corazito.plot(ilist,'k.')  % draw 'k.' styled bullets
%
%        Multiple argument tupels:
%
%           cbplot = @corazito.plot    % short hand
%           cbplot(x1,y1,'r|o',x2,y2,x3,y3,'b2')
%           cbplot(t,x,'r|o',t,y,'g-.',t,z,'b2')
%
%        Attribute list: instead of a character string plot attributes
%        can also be provided by list.
%
%           corazito.plot(x1,y1,{rgb,lwid,ltyp},...)
%
%           corazito.plot(x,y,{[1 0 0],1,'-'})    % solid red line, width 2
%           corazito.plot(x,y,{[1 0 0],2,'-'})    % solid red line, width 2
%           corazito.plot(x,y,{[1 0 0],2,'.-'})   % dashed/dotted red line
%           corazito.plot(x,y,{[1 0 0],'1','|o'}) % red stems and balls
%
%        The attribute string can be a combination of color codes, line
%        type and line width. For the color codes and line type all the
%        characters of the MATLAB/plot function are supported:
%
%           b     blue          .     point              -     solid
%           g     green         o     circle             :     dotted
%           r     red           x     x-mark             -.    dashdot 
%           c     cyan          +     plus               --    dashed   
%           m     magenta       *     star             (none)  no line
%           y     yellow        s     square
%           k     black         d     diamond
%           w     white         v     triangle (down)
%                                ^     triangle (up)
%                                <     triangle (left)
%                                >     triangle (right)
%                                p     pentagram
%                                h     hexagram
%
%        In addition addition '|' and '~' characters are supported which
%        stand for stem plot ('|') and sequential color change ('~').
%
%           corazito.plot(x,y,'|')     % plot stems
%           corazito.plot(x,y,'|o')    % plot stems with balls on top
%
%        Color characters can be provided in multiple occurance, which
%        means averaging of the RGB values. Thus foe example the follwing
%        color codes may be used:
%
%           kw    gray
%           ryk   brown
%           rb    purple
%           ck    dark cyan
%           bk    dark blue
%           gk    dark green
%           yk    dark yellow
%           ry    orange
%           ryy   Gold
%
%        Options: An additional object can be provided as first argument
%                 to pass options
%
%           xscale:          x-scaling factor (default: 1)
%           yscale:          y-scaling factor (default: 1)
%
%        Example:
%
%           o = opt(corazita,'xscale',10,'yscale',0.1);
%           hdl = corazito.plot(o,hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = corazito.plot(o,x1,y1,'r',x2,y2,'b|o',...)
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITO, CORAZITO.COLOR
%      
   color = @corazito.color;            % short hand
   bullets = [];                       % no bullet plotting
   
   if (nargin == 2 && iscell(varargin{2}))
      ilist = varargin{2};
   elseif (nargin == 3 && iscell(varargin{2}))
      ilist = varargin{2};
      bullets = varargin{3};
      if isequal(bullets,0)
         bullets = [];
      elseif ~ischar(bullets)
         bullets = 'k.';
      end

      if ~isempty(bullets)
         [bull.rgb,bull.lwid,bull.ltyp] = color(bullets); % plot attributes
      end
   else
      ilist = varargin;
   end
   
      % if first arg of ilist is an object we pick object and delete
      % first element of ilist. object is used to pass options. Use 
      % default settings if no object is passed.
      
   if isobject(ilist{1})               % object with options provided? 
      o = ilist{1};                    % pick object
      ilist(1) = [];                   % delete ilist head 
      xscale = opt(o,{'xscale',1});    % x-scaling factor
      yscale = opt(o,{'yscale',1});    % y-scaling factor
   else                                % no object!
      xscale = 1;  yscale = 1;         % go with default values
   end
   
      % check if first arg of ilist is an axes handle
   
   hax = gca;
   if isa(ilist{1},'matlab.graphics.axis.Axes')
      hax = ilist{1};
      ilist(1) = [];
   end
   
   list = Chunks(ilist);               % check args and group by chunks
   
   held = ishold;                      % save initial hold status
   
   hdl = [];
         
      % let's going to plot ...
      
   for (i=1:length(list))
      entry = list{i};
      x = entry{1};  y = entry{2};  col = entry{3};
      x = x*xscale;  y = y*yscale;
      
      [rgb,lwid,ltyp] = color(col);    % get line attributes
      
      idx = find(ltyp=='~');
      if isempty(idx)
         h = Plot(hax,x,y,rgb,lwid,ltyp);
         if ~isempty(bullets)
            hbul = Plot(hax,x,y,bull.rgb,bull.lwid,bull.ltyp);
            h = [h(:);hbul(:)];
         end
      else
         ltyp(idx) = [];               % remove all '~'
         h = MultiColorPlot(hax,x,y,lwid,ltyp);
         if ~isempty(bullets)
            hbul = Plot(hax,x,y,bull.rgb,bull.lwid,bull.ltyp);
            h = [h(:);hbul(:)];
         end
      end
         %set(h,'color',rgb,'linewidth',lwid);
      hdl = [hdl;h];                   % collect handles
   end
      
      % final actions: preserve hold status and care about out args
      
   if ~held
      hold off;                        % restore initial hold status
   end
   if (nargout > 0)
      out = hdl;
   end
end

function list = Chunks(ilist)          % Access Arg List Chunks        
%
% CHUNKS   Get the particular list of parameter chunks and make sure
%          the args have proper type.
%
   nin = length(ilist);
   
   i = 0;  list = {};
   while (i < nin)
      if (i+3 <= nin) && ischar(ilist{i+3})
         x = ilist{i+1};  y = ilist{i+2};  col = ilist{i+3};
         if ~isa(x,'double') || ~isa(y,'double')
            error(sprintf('arg%g and arg%g must be double!',i+1,i+2))
         end
         i = i+3;
      elseif (i+3 <= nin) && iscell(ilist{i+3})
         entry = ilist{i+3};
         if (length(entry) < 2)
            entry{2} = 1;
         end
         if (length(entry) < 3)
            entry{3} = '-';
         end
         if length(entry) ~= 3
            error('attribute list must have 3 elements!');
         end
         x = ilist{i+1};  y = ilist{i+2};  col = ilist{i+3};
         if ~isa(x,'double') || ~isa(y,'double')
            error(sprintf('arg%g and arg%g must be double!',i+1,i+2))
         end
         i = i+3;
      elseif (i+2 <= nin)
         x = ilist{i+1};  y = ilist{i+2};  col = 'k';
         if ~isa(x,'double') || ~isa(y,'double')
            error(sprintf('arg%g and arg%g must be double!',i+1,i+2))
         end
         i = i+2;
      else
         error('bad number of input args (at least one additional arg expected!')
      end

      list{end+1} = {x,y,col};
   end
end

function hdl = Plot(hax,x,y,rgb,lwid,ltyp) % Plot graph and hold       
%
   if isempty(ltyp)
      ltyp = '-';                      % solid by default
   end
   
   i = 1;
   while (i <= length(ltyp))
      c = ltyp(i);  i = i+1;
      axcol = get(hax,'color');
      switch c
         case '|'
            if ~all(size(x)==size(y))
               error('sizes of arg1 and arg2 do not match!');
            end
            hdl = plot(hax,[x(:),x(:)]',[0*y(:),y(:)]','k-');
            hold on
            set(hdl,'color',rgb,'linewidth',lwid);
         case '-'
            if (i <= length(ltyp) && ltyp(i) == '.')
               hdl = plot(hax,x,y,'-.');
               i = i+1;  hold on
               set(hdl,'color',rgb,'linewidth',lwid);
            elseif (i <= length(ltyp) && ltyp(i) == '-') 
               hdl = plot(hax,x,y,'--');
               i = i+1;  hold on
               set(hdl,'color',rgb,'linewidth',lwid);
            else
               hdl = plot(hax,x,y,'-');
               hold on
               set(hdl,'color',rgb,'linewidth',lwid);
            end
         case {'.','o','x','+','*','s','d','v','^','<','>','p','h',':'}
            hdl = plot(hax,x,y,c);
            hold on
            set(hdl,'color',rgb);
         otherwise
            'ignore!';
      end
   
         % plot may change axis color! if so we have to restore axis
         % color, otherwise we get irritating flashes in dark mode
      
      if any(get(hax,'color')~=axcol)
         set(hax,'color',axcol);
      end
   end
end
function hdl = MultiColorPlot(hax,x,y,lwid,ltyp)                       
   color = @corazito.color;            % short hand
   if isempty(ltyp)
      ltyp = '-';
   end
   [mx,nx] = size(x);  [my,ny] = size(y);
   
   hdl = [];
   if min(mx,nx) == 1
      x = x(:);  [mx,nx] = size(x);
      if (mx ~= my)
         y = y';  [my,ny] = size(y);
      end
      if (mx ~= my)
         error('length of x and y plot vectors must match!');
      end
      for (i=1:ny)
         col = color(i);
         rgb = color(col);
         h = Plot(hax,x,y(:,i),rgb,lwid,ltyp);
         hdl = [hdl;h];
      end
   elseif min(my,ny) == 1
      y = y(:);  [my,ny] = size(y);
      if (mx ~= my)
         x = x';  [mx,nx] = size(x);
      end
      if (mx ~= my)
         error('length of x and y plot vectors must match!');
      end
      for (i=1:nx)
         col = color(i);
         rgb = color(col);
         h = Plot(hax,x(:,i),y,rgb,lwid,ltyp);
         hdl = [hdl;h];
      end
   else
      if any(size(x) ~= size(y))
         error('incompatible sizes of x and y plot vectors!');
      end
      for (i=1:nx)
         col = color(i);
         rgb = color(col);
         h = Plot(hax,x(:,i),y(:,i),rgb,lwid,ltyp);
         hdl = [hdl;h];
      end
   end
end