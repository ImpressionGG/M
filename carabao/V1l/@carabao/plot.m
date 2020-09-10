function oo = plot(o,varargin)
%
% PLOT   Carabao plot method
%
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%           plot(o,'Basket')           % plot all objects of basket
%
   [gamma,oo] = manage(o,varargin,@Error,@Show,@Animation,@Basket,...
                       @StreamX,@StreamY,@Scatter);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Error(o)                 % report an error               
   error('no plot mode provided!');
end

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

function o = StreamX(o)
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
function o = StreamY(o)
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
function o = Scatter(o)
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
         what(o,'A Carabao object of type ''ball''',{'(try animation)'});
      case 'cube'
         r = o.data.radius;
         v = o.data.offset;
         [X,Y,Z] = cylinder([0 1 1 0],4);
         Z(2,:) = Z(1,:);  Z(3,:) = Z(4,:);  Z = (Z-0.5)*sqrt(2);
         Surf(o,v(1)+r*X,v(2)+r*Y,v(3)+r*Z,color);
         what(o,'A Carabao object of type ''cube''',{'(try animation)'});
      case 'weird'
         Weird(o,t,idx);               % plot weird object
         what(o,'A weird Carabao object',{'(try animation)'});
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
   
   wd = opt(o,{'plot.linewidth',3});   % get line width option
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
   if opt(o,{'plot.bullets',1})
      hbu = plot3(hax,x,y,z,'k.');     % plot x/y graph with black bullets
   end
   title(hax,o.par.title);             % set axis title
   
   handles = setting(o,'plot.handles');% get handles from settings
   eval('delete(handles{idx});','');   % error safe evaluation
   handles{idx} = [hdl, hbu];          % store for next time to delete
   setting(o,'plot.handles',handles);  % update settings
end

function hdl = StreamPlot(x,sym,col,par) % stream plot (v1a/streamplot.m)
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
function ScatterPlot(x,y,par) % black scatter plot (v1a/scatterplot.m)
%
% SCATTERPLOT   Draw a black scatter plot: scatterplot(x,y,par)
%
   scatter(x,y,par.color);    % black scatter plot
   c = corrcoef(x,y);         % correlation coefficients
   
   xlabel('x data');  
   ylabel('y data');
   title(sprintf('%s: correlation coefficient %g',par.title,c(1,2)));
end

