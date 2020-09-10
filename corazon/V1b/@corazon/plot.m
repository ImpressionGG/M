function oo = plot(o,varargin)
%
% PLOT   CORAZON plot method. Extension of MATLAB plot function by
%        extended color strings denoting color, line width and line type
%
%           hdl = plot(o,hax,x1,y1,'r',x2,y2,'b|o',...)
%           hdl = plot(o,x1,y1,'r',x2,y2,'b|o',...)
%
%           plot(o,x,y,'r')     % same as plot(x,y,'r')
%           plot(o,x,y,'r2')    % plot(x,y) in red, line width 2
%           plot(o,x,y,'r2.-')  % red, line width 2, solid and dot
%           plot(o,x,y,'r|o')   % red stems and balls
% 
%        Multiple argument tupels:
% 
%           cbplot = @plot(o)   % short hand
%           cbplot(x1,y1,'r|o',x2,y2,x3,y3,'b2')
%           cbplot(t,x,'r|o',t,y,'g-.',t,z,'b2')
% 
%        Attribute list: instead of a character string plot attributes
%        can also be provided by list.
% 
%           plot(o,x1,y1,{rgb,lwid,ltyp},...)
% 
%           plot(o,x,y,{[1 0 0],1,'-'})    % solid red line, width 2
%           plot(o,x,y,{[1 0 0],2,'-'})    % solid red line, width 2
%           plot(o,x,y,{[1 0 0],2,'.-'})   % dashed/dotted red line
%           plot(o,x,y,{[1 0 0],'1','|o'}) % red stems and balls
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
%           plot(o,x,y,'|')     % plot stems
%           plot(o,x,y,'|o')    % plot stems with balls on top
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
%           ryy   gold
%
%        Provided options:
%           'color'                    % use as color argument
%           'linewidth'                % use as linewidth
%           'title'                    % provide title
%           'xlabel'                   % provide xlabel
%           'ylabel'                   % provide ylabel
%           'subplpot'                 % subplot index vector
%
%        Example:
%           oo = opt(o,'linewidth',3, 'color', 'ryy');
%           oo = opt(o,'xlabel','X', 'ylabel','Y', 'title','X/Y Scatter');
%           oo = opt(oo,'subplot',[2 2 1]);
%           plot(o,x,y);
%
%        Special plot modes
%
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%           plot(o,'Basket')           % plot all objects of basket
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON, LABEL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Show,@Menu,@Callback,@Basket,...
                                  @StreamX,@StreamY,@Scatter,@Animation);
   if isequal(char(gamma),'Error')
      Plot(o,varargin);
   else
      oo = gamma(oo);
   end
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   setting(o,{'plot.handles'},[]);     % provide empty plot handles default

   oo = mitem(o,'Show',{@Callback,'Show'});
   oo = mitem(o,'Animation',{@Callback,'Animation'});

   plugin(o,'corazon/shell/Plot');     % plug point

   Style(o);                           % provide some plot Style menu items
end
function oo = Style(o)                 % Add Style Menu to Select Menu 
   setting(o,{'style.linewidth'},3);   % provide line width default
   setting(o,{'style.bullets'},1);     % provide bullets default

   oo = mseek(o,{'#','Select'});
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Style');
   oooo = mitem(ooo,'Line Width','','style.linewidth');
   choice(oooo,[1:5],'');              % line width choice
   oooo = mitem(ooo,'Bullets','','style.bullets');
   check(oooo,'');
end
function oo = Callback(o)              % Common Plot Menu Callback     
   oo = plot(o);
end

%==========================================================================
% Default Plot Function
%==========================================================================

function oo = Plot(o)                  % Default Plot Function         
   ilist = arg(o);
   sub = opt(o,'subplot');
   
      % optional subplot selection
      
   if ~isempty(sub)
      if (length(sub) ~= 3)
         error('subplot option must be 3-vector!');
      end
      subplot(sub(1),sub(2),sub(3));
   end
   
      % actual plotting
      
   bullets = opt(o,'bullets');
   if ~isempty(bullets)
      hdl = corazito.plot(o,ilist,bullets);
   else
      hdl = corazito.plot(o,ilist);
   end
   
      % optional color attribute setting
      
   col = opt(o,'color');
   if ~isempty(col)
      o.color(hdl,col);
   end
   
      % optional line width setting
      
   lw = opt(o,'linewidth');
   if ~isempty(lw)
      set(hdl,'linewidth',lw);
   end
   
      % optional title setting
      
   tit = opt(o,'title');
   if ~isempty(tit)
      title(tit);
   end
   
      % optional xlabel setting
      
   xlab = opt(o,'xlabel');
   if ~isempty(xlab)
      xlabel(xlab);
   end
   
      % optional ylabel setting
      
   ylab = opt(o,'ylabel');
   if ~isempty(ylab)
      ylabel(ylab);
   end
   
   oo = hdl;
end

%==========================================================================
% Special Plot Functions
%==========================================================================

function o = Show(o)                   % Show Object                   
   refresh(o,{'plot','Show'});         % update refresh callback
   
   if (data(o,inf) == 0) && dynamic(o)
      comment = {'(consider to create/import an object)'};
      oo = message(o,'Select an object!',comment);
      return
   end
   
   cls(o);                             % clear screen
   set(figure(o),'color',[1 1 1]);     % white background
   
   setting(o,'plot.handles',[]);       % clear handles
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      Draw(oo,0,i);
      hold on;                         % hold drawings
   end
   set(figure(o),'color',[1 1 1]);     % white back ground
   light('color',[1 1 1]);             % setup light for 3D graphics
   
   if container(current(o))
      comment = {'plot overlay of all objects of the','shell''s container object'};
      what(o,'All objects of the shell',comment);
   end
end
function o = Animation(o)              % Animation Callback            
   refresh(o,{'plot','Animation'});    % update refresh callback
   if (data(o,inf) == 0) && dynamic(o)
      comment = {'(consider to create/import an object)'};
      oo = message(o,'Select an object!',comment);
      return
   end
   
   Show(o);                            % mind: will update refresh callback
   refresh(o,{'plot','Animation'});    % again update refresh callback
   
   set(gcf,'WindowButtonDownFcn',@Stop);
   hax = gca;
   set(hax,'dataaspect',[1 1 1],'visible','off');

   persistent time
   time = 0;  hdl = [];

   va = get(hax,'CameraViewAngle');    % initial camera view angle
   d = norm(get(hax,'CameraPosition'));% initial camera distance
   while(time >= 0)
      list = basket(o);
      for (i=1:length(list))
         oo = list{i};
         if isequal(oo.type,'weird')
            Draw(oo,time,i);
         end
      end

      view(hax,20*time,50);            % change view azimuth angle
      set(hax,'CameraViewAngle',va);   % restore camera view angle
      pos = get(hax,'CameraPosition'); % camera position
      set(hax,'CameraPosition',pos/norm(pos)*d);

      time = time + 0.1;               % increment time
      shg(o);  pause(0.05);            % show graphics & pause
   end
   return
   
   function Stop(varargin)             % Stop Animation Callback       
      time = -1;                       % stop animation
   end
end
function o = Basket(o)                 % Plot All Objects of Basket    
   if ~container(o)
      error('object must be a container!');
   end
   args = arg(o,1);
   if iscell(args) && arg(o,inf) == 1
      o = arg(o,args);                 % special handling of args
   end
   
%  refresh(o,{'plot','Show'});         % update refresh callback
   
   if (data(o,inf) == 0) && dynamic(o)
      comment = {'(consider to create/import an object)'};
      oo = message(o,'Select an object!',comment);
      return
   end
   
   cls(o);                             % clear screen
%  set(figure(o),'color',[1 1 1]);     % white background
   
   setting(o,'plot.handles',[]);       % clear handles
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      oo = arg(oo,args);               % hand over args
      plot(oo);
      hold on;                         % hold drawings
   end
%  set(figure(o),'color',[1 1 1]);     % white back ground
%  light('color',[1 1 1]);             % setup light for 3D graphics
   
   if container(current(o))
      comment = {'plot overlay of all objects of the','shell''s container object'};
      what(o,'All objects of the shell',comment);
   end
end

function o = StreamX(o)                % Plot X-Stream                 
   cls(o);                                       % clear screen
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      hdl = StreamPlot(oo.data.x,'x','r',oo.par);
      width = opt(o,{'style.linewidth',1});      % use this as default
      width = opt(o,{'plot.linewidth',width});   % overwrite if provided
      set(hdl,'linewidth',width);
      
      bullets = opt(o,{'style.bullets',1});      % use this as default
      if opt(o,{'plot.bullets',bullets})         % overwrite if provided
         hold on
         StreamPlot(oo.data.x,'x','k.',oo.par);
      end
      hold on;                                   % hold drawings
   end
   if length(list) > 1
      title('Stream Plot X');
   end
   hold off
end
function o = StreamY(o)                % Plot Y-Stream                 
   cls(o);                                       % clear screen
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      hdl = StreamPlot(oo.data.y,'y','b',oo.par);
      width = opt(o,{'style.linewidth',1});      % use this as default
      width = opt(o,{'plot.linewidth',width});   % overwrite if provided
      set(hdl,'linewidth',width);
      
      bullets = opt(o,{'style.bullets',1});      % use this as default
      if opt(o,{'plot.bullets',bullets})         % overwrite if provided
         hold on
         StreamPlot(oo.data.y,'y','k.',oo.par);
      end
      hold on;                                   % hold drawings
   end
   if length(list) > 1
      title('Stream Plot Y');
   end
   hold off
end                  
function o = Scatter(o)                % Scatter Plot                  
   cls(o);                                  % clear screen
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      
      color = opt(o,{'plot.color','k'});    % use this as the default
      color = opt(o,{'plot.color',color});  % overwrite if provided
      if length(color) > 0 && any(color(1)=='rgbymck')
         oo.par.color = color;
      end
      
      ScatterPlot(oo.data.x,oo.data.y,oo.par);
      hold on;                              % hold drawings
   end
   if length(list) > 1
      title('Scatter Plot');
   end
   hold off
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Draw(o,t,idx)                 % Draw an Object                
   color = get(o,{'color',[0 0 0]});   % get color (default [0 0 0])
   switch o.type
      case 'ball'
         r = o.data.radius;
         v = o.data.offset;
         [X,Y,Z] = sphere(50);
         Surf(o,v(1)+r*X,v(2)+r*Y,v(3)+r*Z,color);
         what(o,'A Corazon object of type ''ball''',{'(try animation)'});
      case 'cube'
         r = o.data.radius;
         v = o.data.offset;
         [X,Y,Z] = cylinder([0 1 1 0],4);
         Z(2,:) = Z(1,:);  Z(3,:) = Z(4,:);  Z = (Z-0.5)*sqrt(2);
         Surf(o,v(1)+r*X,v(2)+r*Y,v(3)+r*Z,color);
         what(o,'A Corazon object of type ''cube''',{'(try animation)'});
      case 'weird'
         Weird(o,t,idx);               % plot weird object
         what(o,'A weird Corazon object',{'(try animation)'});
      otherwise
         menu(o,'About');
         return
   end
end   
function o = Surf(o,X,Y,Z,color)       % Surf Plot of Ball/Cube        
   hax = gca(figure(o));
   hdl = surf(hax,X,Y,Z,'FaceColor',color,'LineStyle','none');   
   set(hax,'dataaspect',[1 1 1],'visible','off');
   set(hax,'xlim',[-2 2],'ylim',[-2 2],'zlim',[-2 2],'CameraViewAngle',3.5);
end
function o = Weird(o,t,idx)            % Plot Weird Object             
   either = @o.either;                 % short hand
   
   wd = opt(o,{'style.linewidth',3});  % get line width option
   co = get(o,{'color',[0 0 0]});      % get color (default [0 0 0])
   
   w = o.data.w;                       % get x/y/z data from object
   x = o.data.x;
   y = o.data.y;
   z = o.data.z;

   om = 0.1;
   x = x*cos(om*t) + w*sin(om*t);      % rotate in 4D
   
   hax = gca(figure(o));               % get current axis handle
   hdl = plot3(hax,x,y,z);             % plot x/y/z graph
   set(hdl,'color',co,'linewidth',wd); % set color & line width property

   hbu = [];  hold on;                 % hold plot
   if opt(o,{'style.bullets',1})
      hbu = plot3(hax,x,y,z,'k.');     % plot x/y graph with black bullets
   end
   title(hax,o.par.title);             % set axis title
   
   handles = setting(o,'plot.handles');% get handles from settings
   eval('delete(handles{idx});','');   % error safe evaluation
   handles{idx} = [hdl, hbu];          % store for next time to delete
   setting(o,'plot.handles',handles);  % update settings
end

function hdl = StreamPlot(x,sym,col,par) % stream plot                 
%
% STREAMPLOT   Plot data stream: streamplot(x,'x','r',par)
%
   hdl = plot(x,col);              % stream plot
   m = mean(x);                    % mean value
   s = std(x);                     % standard deviation (sigma)
    
   xlabel('data index');  
   ylabel([sym,' data']);
   format = '%s: %s-stream: mean %g, sigma %g';
   text = sprintf(format,par.title,sym,m,s);
   title(text);
end
function ScatterPlot(x,y,par) % black scatter plot                     
%
% SCATTERPLOT   Draw a black scatter plot: scatterplot(x,y,par)
%
   scatter(x,y,par.color);    % black scatter plot
   c = corrcoef(x,y);         % correlation coefficients
   
   xlabel('x data');  
   ylabel('y data');
   title(sprintf('%s: correlation coefficient %g',par.title,c(1,2)));
end

