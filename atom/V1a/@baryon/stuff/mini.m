function oo = mini(o,varargin)         % Mini Shell for CARABAO Class  
% 
% MINI   Open new figure and setup a mini menu for a CARABAO object
%      
%           o = carabao      % create a CARABAO object
%           mini(o)          % open a CARABAO mini shell
%
%        Creating sample objects
%           oo = mini(o,'Create','weird')   % create weird object
%           oo = mini(o,'Create','ball')    % create ball object
%           oo = mini(o,'Create','cube')    % create cube object
%
%        See also: CARABAO, SHELL
%
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,...
                                  @New,@Create,@Plot,@Show,@Animate);
   oo = gamma(o);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);   

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Extras');              % add Extras menu
   oo = Plot(o);                       % add Plot menu
   oo = shell(o,'Animation');          % add Animation menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end

function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title')) && container(o)
      o = refresh(o,{'menu','About'}); % provide refresh callback
      o = set(o,'title','Carabao Mini Shell');
      o = set(o,'comment',{'a mini shell for Carabao objects'});
   end
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % use this mfile as launch function
end

function list = Dynamic(o)             % Get Dynamic Menu List         
   list = {'Plot'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = New(oo);                      % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
end

function oo = New(o)                   % New Menu Items                
   types = {'weird','ball','cube'};    % supported object types
   oo = shell(carabao(o),'New',types); % add New menu items @ Carbao shell
end

function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % seek Import menu header item
   ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'.txt'});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      ext = arg(o,1);                  % file extension
      list = import(o,ext);            % import object from file
      paste(o,list);
   end
end

function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % seek Export menu header item
   ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'.txt'});
   return
   
   function oo = ExportCb(o)           % Export Log Data Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         ext = arg(o,1);               % file extension
         export(oo,ext);               % export object to file
      end
   end
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   setting(o,{'plot.linewidth'},3);    % provide line width default
   setting(o,{'plot.bullets'},true);   % provide bullets default
   setting(o,{'plot.handles'},[]);     % provide empty handles default
   
   oo = mhead(o,'Plot');
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Show',{@Show});
   ooo = mitem(oo,'Animation',{@Animate});
   ooo = mitem(oo,'-');                % separator
   ooo = mitem(oo,'Line Width','','plot.linewidth');
   choice(ooo,[1:5],'');               % line width choice
   ooo = mitem(oo,'Bullets','','plot.bullets');
   check(ooo,'');
end

function o = Show(o)                   % Show Object                   
   refresh(o,{'shell','Show'});        % update refresh callback
   
   cls(o);                             % clear screen
   setting(o,'plot.handles',[]);       % clear handles
   for (i=1:basket(o,inf))
      oo = basket(o,i);
      Draw(oo,0,i);
      hold on;                         % hold drawings
   end
   set(figure(o),'color',[1 1 1]);     % white back ground
   
   if container(current(o))
      comment = {'plot overlay of all objects of the','shell''s container object'};
      what(o,'All objects of the shell',comment);
   end
end

function oo = Animate(o)               % Animation Callback            
   refresh(o,{'shell','Animate'});     % update refresh callback
   if container(current(o)) && dynamic(o)
      comment = {'(consider to create/import an object)'};
      oo = message(o,'Select an object!',comment);
      return
   end
   
   Show(o);                            % mind: will update refresh callback
   refresh(o,{'shell','Animate'});     % again update refresh callback
   
   set(gcf,'WindowButtonDownFcn',@Stop);
   hax = gca;
   set(hax,'dataaspect',[1 1 1],'visible','off');

   persistent time
   time = 0;  hdl = [];

   va = get(hax,'CameraViewAngle');    % initial camera view angle
   d = norm(get(hax,'CameraPosition'));% initial camera distance
   while(time >= 0)
      for (i=1:basket(o,inf))
         oo = basket(o,i);
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

function Draw(o,t,idx)                 % Draw an Object                
   color = get(o,{'color',[0 0 0]});   % get color (default [0 0 0])
   switch o.type
      case 'ball'
         [X,Y,Z] = sphere(50);
         Surf(o,X,Y,Z,color);
         what(o,'A Carabao object of type ''ball''',{'(try animation)'});
      case 'cube'
         [X,Y,Z] = cylinder([0 1 1 0],4);
         Z(2,:) = Z(1,:);  Z(3,:) = Z(4,:);  Z = (Z-0.5)*sqrt(2);
         Surf(o,X,Y,Z,color);
         what(o,'A Carabao object of type ''cube''',{'(try animation)'});
      case 'weird'
         Weird(o,t,idx);               % plot weird object
         what(o,'A weird Carabao object',{'(try animation)'});
      otherwise
         menu(o,'Home');
         return
   end
end   

function o = Surf(o,X,Y,Z,color)       % Surf Plot of Ball/Cube        
   hax = gca(figure(o));
   hdl = surf(hax,X,Y,Z,'FaceColor',color,'LineStyle','none');   
   light('color',[1 1 1]);
   set(hax,'dataaspect',[1 1 1],'visible','off');
   set(hax,'xlim',[-2 2],'ylim',[-2 2],'zlim',[-2 2],'CameraViewAngle',3.5);
end

function o = Weird(o,t,idx)            % Plot Weird Object             
   either = @carabull.either;          % short hand
   
   wd = opt(o,'plot.linewidth');       % get line width option
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
   if opt(o,'plot.bullets')
      hbu = plot3(hax,x,y,z,'k.');     % plot x/y graph with black bullets
   end
   title(hax,o.par.title);             % set axis title
   
   handles = setting(o,'plot.handles');% get handles from settings
   eval('delete(handles{idx});','');   % error safe evaluation
   handles{idx} = [hdl, hbu];          % store for next time to delete
   setting(o,'plot.handles',handles);  % update settings
end
