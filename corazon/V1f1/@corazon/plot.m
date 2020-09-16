function oo = plot(o,varargin)         % Corazon Plot Method           
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
%        forwarded calling syntax
%
%           hdl = plot(corazon,o,{hax,x1,y1,'r',x2,y2,'b|o',...})
%           hdl = plot(corazon,o,arglist);
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
%           'grid'                     % set grid on/off
%           'hold'                     % hold on/off
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
%        Options:
%
%           title:           plot title  (default: '' - no title)
%           xlabel:          plot xlabel (default: '' - no xlabel)
%           ylabel:          plot ylabel (default: '' - no ylabel)
%           xscale:          x-scaling factor (default: 1)
%           yscale:          y-scaling factor (default: 1)
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON, LABEL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithSho,@WithCuo,@WithBsk,...
                       @Show,@Animation,@Draw,@Overview);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   setting(o,{'plot.handles'},[]);     % provide empty plot handles default
   
   oo = mitem(o,'Show',{@WithBsk,'Show'});
        enable(oo,basket(oo),{'shell','weird','ball','cube','txy'});

   oo = mitem(o,'Animation',{@Animation});
        enable(oo,basket(oo),{'shell','weird','ball','cube'});

   oo = mitem(o,'-');
   plugin(o,'corazon/shell/Plot');     % plug point
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
  
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Default Plot Function
%==========================================================================

function oo = Plot(o)                  % Default Plot Function         
   oo = arg(o,1);
   if isobject(oo)                     % forward calling syntax?
      ilist = arg(oo);
      if ~iscell(ilist) || length(ilist) < 2 || ...
         ~isa(ilist{1},'double') || isempty(ilist{1})
         oo = [];  return              % then no arglist for corazon/plot
      end
      o = inherit(o,oo);               % inherit opts from arg2 object
   else
      ilist = arg(o);                  % the normal way of getting args
   end
   
   sub = opt(o,'subplot');
   
      % invert all 'K' or 'w' color specifiers
      
   if (dark(o))
      for (i=1:length(ilist))
         argi = ilist{i};
         if ischar(argi)
            ixk = find(argi=='k');
            ixw = find(argi=='w');
            
            if ~isempty(ixk)           % is there black color spec 
               argi(ixk) = setstr(0*ixk+'w');
            end
            if ~isempty(ixw)           % is there white color spec
               argi(ixw) = setstr(0*ixw+'k');
            end
            ilist{i} = argi;
         end
      end
   end
   
      % optional subplot selection
      
   if ~isempty(sub)
      %if (isa(sub,'double') && length(sub) == 1 && sub > 100)
      %   sub = [floor(sub/100),rem(floor(sub/10),10),rem(sub,10)];
      %end
      %
      %if (length(sub) ~= 3)
      %   error('subplot option must be 3-vector!');
      %end
      %hax = subplot(sub(1),sub(2),sub(3));
      hax = subplot(o,sub);
      set(hax,'color',o.iif(dark(o),0,1)*[1 1 1]);
   else                                % manage canvas color
      hax = gca;
      axcol = get(hax,'color');
      if (dark(o) && all(axcol==[1 1 1]))
         axcol = [0 0 0];
         set(hax,'color',axcol);
      end
   end
   
      % actual plotting
      
   bullets = opt(o,'bullets');
   o = opt(o,'dark',dark(o));          % provide 'dark' option
   
      % add object with options to ilist
      
   ilist =  [{o},ilist];
   
      % preparations complete - plot now ...
      
   if ~isempty(bullets)
      if isequal(bullets,1)
         if dark(o)
            bullets = 'w.';
         else
            bullets = 'k.';
         end
      end
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
   
      % optional hold on/off control
      
   if opt(o,{'hold',ishold})
      hold on;
   else
      hold off;
   end

      % set grid
      
   onoff = opt(o,'grid');
   if isempty(onoff)
      grid(o);
   elseif onoff
      grid on;
   else
      grid off
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
% Specific Plot Function (Published)
%==========================================================================

function o = Show(o)                   % show Overview or 3D Scene     
   switch o.type
      case 'txy'
         o = Overview(o);
         return
      case 'shell'
         comment = {'plot overlay of all objects of the',...
                    'shell''s container object'};
         what(o,'All objects of the shell',comment);
      otherwise
         Draw(o);                      % call specific plot function
         light('color',[1 1 1]);       % setup light for 3D graphics
   end
end
function o = Animation(o)              % Animation Callback            
   refresh(o,o);                       % come back here for refresh
   list = basket(o);

      % check whether there are objects in basket to animate
      
   if isempty(list)
      message(o,'No objects!',{'(import object or create a new one)'});
      return
   end
   
      % first show static scene. mind that Show() updates the refresh
      % function, so we have to redefine the refresh function after calling
      
   persistent time
   
   Stop();
   %pause(0.2);                        % wait for running task terminating                  
   
   time = 0;  hdl = [];
   
   cls(o);
   setting(o,'plot.handles',[]);       % init plot handles
   for (i=1:length(list))
      Show(list{i});                   % mind: will update refresh callback
   end
   
   set(gcf,'WindowButtonDownFcn',@Stop);
   hax = gca;
   set(hax,'dataaspect',[1 1 1],'visible','off');

   va = get(hax,'CameraViewAngle');    % initial camera view angle
   d = norm(get(hax,'CameraPosition'));% initial camera distance
  
      % if some (non-corazon) selects a no n-corazon object the according
      % callback might just delete the current axis object. In such cases
      % an unforseen error happens which need to be catched in the ani-
      % mation loop
      
   try
      while(time >= 0)
         for (i=1:length(list))
            oo = list{i};
            if isequal(oo.type,'weird')
               ooo = Draw(oo,time,i);
               hold on;
            end
         end

         view(hax,20*time,50);            % change view azimuth angle
         set(hax,'CameraViewAngle',va);   % restore camera view angle
         pos = get(hax,'CameraPosition'); % camera position
         set(hax,'CameraPosition',pos/norm(pos)*d);

         time = time + 0.1;               % increment time
         shg(o);  pause(0.05);            % show graphics & pause
      end
   catch
      'catched';
   end
   return
   
   function Stop(varargin)             % Stop Animation Callback       
      time = -1;                       % stop animation
   end
end
function o = Draw(o,t,idx)             % Draw an Object                
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
         if (nargin < 2)
            t = 0;  idx = opt(o,'index');
         end
         Weird(o,t,idx);            % plot weird object
         what(o,'A weird Corazon object',{'(try animation)'});
      case 'txy'
         oo = Overview(o);
      otherwise
         o = [];
         return
   end
end   

%==========================================================================
% Txy Plot Functions
%==========================================================================

function oo = Overview(o)              % Plot Overview                 
   if ~o.is(o.type,{'txy'})
      oo = []; return                  % no idea how to plot this type
   end

   oo = opt(o,'subplot',[2 2 1]);
   PlotX(oo);

   oo = opt(oo,'subplot',[2 2 3]);
   oo = opt(oo,'title',' ');           % prevent from drawing a title
   PlotY(oo);

   oo = opt(oo,'subplot',[1 2 2]);
   oo = opt(oo,'title','X/Y-Orbit');   % override title
   PlotXY(oo);

   closeup(o);
   heading(o);
end
function oo = PlotX(o)                 % Stream Plot X                 
   if ~o.is(o.type,{'txy'})
      oo = []; return                  % no idea how to plot this type
   end

   oo = Stream(o,'x','r');
   heading(o);
end
function oo = PlotY(o)                 % Stream Plot Y                 
   if ~o.is(o.type,{'txy'})
      oo = []; return                  % no idea how to plot this type
   end

   oo = Stream(o,'y','bc');
   heading(o);
end
function oo = PlotXY(o)                % Scatter Plot                  
   if ~o.is(o.type,{'txy'})
      oo = []; return                  % no idea how to plot this type
   end

   x = cook(o,'x');
   y = cook(o,'y');
   
   col = [opt(o,{'style.scatter','ryy'}),'o'];
   plot(corazon(o),x,y,col);

   title('Scatter Plot');
   xlabel('x');  ylabel('y');

   shelf(o,gca,'closeup',false);       % prevents closeup control
   heading(o);
end
function oo = Stream(o,sym,col)        % Stream Plot                   
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

   title([upper(sym),'-Plot']);
   xlabel('t');  ylabel(sym);
end

%==========================================================================
% Helper Plot Functions
%==========================================================================

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
   
   [w,x,y,z] = data(o,'w,x,y,z');      % get x/y/z data from object

      % 4D animation if nargin >= 2
      
   om = 0.1;
   x = x*cos(om*t) + w*sin(om*t);   % rotate in 4D
   
      % actual plotting (3D)
      
   hax = gca(figure(o));               % get current axis handle
   hdl = plot3(hax,x,y,z);             % plot x/y/z graph
   set(hdl,'color',co,'linewidth',wd); % set color & line width property
   
   hbu = [];  hold on;                 % hold plot
   if opt(o,{'style.bullets',1})
      bull = o.iif(dark(o),'w.','k.');
      hbu = plot3(hax,x,y,z,bull);     % plot x/y graph with black bullets
   end
   title(hax,o.par.title);             % set axis title
   
      % update handles
      
   handles = setting(o,'plot.handles');% get handles from settings
   eval('delete(handles{idx});','');   % error safe evaluation
   
   idx = o.either(idx,1);              % as idx might be empty
   handles{idx} = [hdl, hbu];          % store for next time to delete
   setting(o,'plot.handles',handles);  % update settings
end

