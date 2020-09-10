function oo = menu(o,varargin)         % TRACE Class Menu Management   
% 
% MENU   Build functions for TRACE menu.
%
%    1) Menu build-up functions
%
%       menu(o,'New');                 % add New menu for plain *.txt
%
%       menu(o,'Import','*.txt');      % add Import menu for plain *.txt
%       menu(o,'Import','*.trace');    % add Import menu for TCB *.trace
%
%       menu(o,'Export','*.txt');      % add Export menu for plain *.txt
%       menu(o,'Export','*.trace');    % add Export menu for TCB *.trace
%
%       menu(o,'View');                % add View menu
%       menu(o,'Toolbar');             % add Toolbar submenu
%       menu(o,'Config');              % add Config menu
%       menu(o,'Style');               % add Style menu
%       menu(o,'Variation');           % add Variation menu
%
%    See also: CARALOG, SHELL, ADVANCED
%
   [gamma,oo] = manage(o,varargin,@Error,@Default,@New,@NewSimple,...
                 @NewPlain,@View,@Control,@Config,@Subplot,@Category,...
                 @Stream,@Current,@Select,@Bias,@Toolbar,@Filter,@Scope,...
                 @Ignore,@Style,@Variation,@Camera,@Grid,@Plot,@PlotCb);
   oo = gamma(oo);                    % invoke callback
end

%==========================================================================
% Menu Setup
%==========================================================================

function o = Error(o)                  % Error Generation              
   error('calling CARMA menu method without args!');
end
function o = Default(o)                % Provide Defaults              
%
   o = set(o,{'title'},'Carma Shell');
   o = set(o,{'comment'},{'Log Data Analysis'});

   %o = default(o,{'gallery'});                  % use defaults from file
   o = opt(o,{'mode.bias'},'drift');             % bias mode: 'drift'
   o = opt(o,{'mode.config.opts'},1);            % container provides options
   o = opt(o,{'style.labels'},'statistics');     % statistics by default
   
   if (category(o,inf) == 0) && (container(o) || trace(o))
      o = opt(o,'category.specs',[-3 3; -30 30]);
      o = opt(o,'category.limits',[0 0;   0  0]);
      o = opt(o,'category.units',{'µ','m°'});
      
      o = category(o,1,[-3 3],[0 0],'µ');        % category 1 for x,y
      o = category(o,2,[-30 30],[0 0],'m°');     % category 2 for th
   end
   
   if (config(o,inf) == 0)  && (container(o) || trace(o))
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'p',{2,'g',2});
      o = config(o,'sys',{0,'y',0});
      o = config(o,'i',{0,'a',0});
      o = config(o,'j',{0,'k',0});
   end
   
   control(o,{'color'},[1 1 1]);       % provide background color
end

%==========================================================================
% File Menu
%==========================================================================

function oo = New(o)                   % New Menu                      
   oo = mhead(o,'New');
   ooo = mitem(oo,'Shell',{@ShellCb}); % open another shell
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Plain Trace',{@NewPlain});
   ooo = mitem(oo,'Simple Trace',{@NewSimple});
   return
   
   function oo = ShellCb(o)            % Shell Callback                
      tag = class(o);
      oo = eval(tag);                  % new empty container object
      oo.type = o.type;                % copy type
      launch(oo);                      % launch a new shell
   end
end
function oo = NewPlain(o)              % Create New plain trace        
   m = 5;  n = 8;  r = 10;          % rows x columns x repeats
   t = 0:1000/(m*n*r-1):1000;       % crate a time vector
   sz = size(t);
   om = r*2*pi/max(t);              % random circular frequency

   x = (2+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
   y = (2+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector
   p = 5*x + 5*y + 0.7*randn(sz);   % create a 'th' vector

   x = x.*(1+0.2*t/max(t));         % time variant
   y = y.*(1+0.2*t/max(t));         % time variant
   p = p.*(1+0.2*t/max(t));         % time variant

      % make a carma object with t,x,y & p

   oo = carma('plain');             % construct carma object
   oo = trace(oo,t,'x',x,'y',y,'p',p); % make a trace with t, x & y

   oo = set(oo,'sizes',[m,n,r]);    % set data sizes
   oo = set(oo,'method','blcs');    % set processing method

      % provide title & comments for the caracook object

   [date,time] = o.now;
   oo = set(oo,'title',[date,' @ ',time,' Plain Trace Data']);
   oo = set(oo,'comment','sin/cos data (random frequency & magnitude)');
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
   oo = set(oo,'project','Sample Project');

      % provide plot defaults

   oo = category(oo,1,[-5 5],[0 0],'µ');      % category 1 for x,y
   oo = category(oo,2,[-50 50],[0 0],'m°');   % category 2 for p

   oo = config(oo,'x',{1,'r',1});
   oo = config(oo,'y',{1,'b',1});
   oo = config(oo,'p',{2,'g',2});

      % paste object into shell and display caracook info on screen

   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
   paste(o,{oo});                      % paste new object into shell
end
function oo = NewSimple(o)             % Create New biased trace       
   m = 6;  n = 10;  r = 8;             % rows x columns x repeats
   t = 0:1000/(m*n*r-1):1000;          % crate a time vector
   sz = size(t);
   om = r*2*pi/max(t);                 % random circular frequency

   x = (1+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
   y = (1+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector
   p = 7*x + 7*y + 0.9*randn(sz);      % create a 'th' vector
   ux = 0.11*randn(size(x));           % create 'ux' data vector
   uy = 0.09*randn(size(y));           % create 'uy' data vector

   x = 10 + x.*(1+0.2*t/max(t));       % biased & time variant
   y = 8 + y.*(1+0.2*t/max(t));        % biased & time variant
   p = 70 + p.*(1+0.2*t/max(t));       % biased & time variant

      % make a carma object with t,x,y,p, ux & uy

   oo = carma('simple');               % construct carma object
   oo = trace(oo,t,'x',x,'y',y,'p',p,'ux',ux,'uy',uy); 

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   oo = set(oo,'method','blrm');       % set processing method

      % provide title & comments for the caracook object

   [date,time] = o.now;
   oo = set(oo,'title',[date,' @ ',time,' Simple Trace Data']);
   oo = set(oo,'comment','sin/cos data (random frequency & magnitude)');
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
   oo = set(oo,'project','Sample Project');

      % provide plot defaults

   oo = category(oo,1,[-5 5],[0 0],'µ');      % category 1 for x,y
   oo = category(oo,2,[-50 50],[0 0],'m°');   % category 2 for p
   oo = category(oo,3,[-0.5 0.5],[0 0],'µ');  % category 3 for ux,uy

   oo = config(oo,'x',{1,'r',1});
   oo = config(oo,'y',{1,'b',1});
   oo = config(oo,'p',{2,'g',2});
   oo = config(oo,'ux',{3,'m',3});
   oo = config(oo,'uy',{3,'c',3});

      % paste object into shell and display caracook info on screen

   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
   paste(o,{oo});                      % paste new object into shell
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu Setup               
%
% VIEW   View menu setup
%
   oo = mhead(o,'View');               % empty view menu header
   ooo = menu(oo,'Control');           % add Control menu
   ooo = menu(oo,'Config');            % add Config menu
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Grid');              % add Config menu
   ooo = menu(oo,'Style');             % add Style menu
   ooo = menu(oo,'Variation');         % add Style menu
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Camera');            % add Camera menu
   ooo = menu(oo,'Toolbar');           % add Toolbar menu
end
function oo = Control(o)
   setting(o,{'control.options'},0);   % use children's options
   oo = mhead(o,'Control',{},'control.options');
   choice(oo,{{'by Shell',1},{'by Selected Object',0}},{});
end
function oo = Config(o)                % Config Menu Setup             
%
% CONFIG   Config menu setup
%
      % First step, seek if we have already a Config memu. If not then
      % build-up the basic menu items of the Config menu

   setting(o,{'mode.config.show'},0);  % do not show all by default
   
   options = control(o,'options');     % who controls options?
   if (options)                        % if container determines config
      o = config(o,'');                % provide a default configuration
      cfg = opt(o,'config');           % get config options
      setting(o,{'config'},cfg);       % provide config default setting
   else                                % elseif object determines config
      oo = current(o);                 % get current object
      cfg = opt(oo,'config');          % get config options
      setting(o,'config',cfg);         % provide config default setting
      o = opt(o,'config',cfg);         % refresh object

      cat = opt(oo,'category');        % get category options
      setting(o,'category',cat);       % provide config default setting
      o = opt(o,'category',cat);       % refresh object
   end      

   oo = mhead(o,'Config',{},'Config'); % empty header Config
%
% Rebuild the Config menu items
%
   ooo = menu(oo,'Stream');            % add Stream configuration menu
   ooo = menu(oo,'Subplot');           % add Subplot configuration menu
   ooo = mitem(oo,'Mode');
   
   oooo = mitem(ooo,'Show',{},'mode.config.show');
   choice(oooo,{{'Relevant',0},{'All',1}},{@RebuildCb});
   
%  oooo = mitem(ooo,'Options',{},'control.options');
%  choice(oooo,{{'Package',1},{'Object',0}},{@RebuildCb});
   
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Category');          % add Category entries
   return
   
   function oo = RebuildCb(o)          % Rebuild Callback              
      [~,po] = mseek(o,'Config');      % seek parent
      oo = Config(po);                 % rebuild Config menu
   end
end
function oo = Stream(o)                % Stream Configuration Menu     
%
   oo = mhead(o,'Stream');             % submenu header item
   assert(o.is(oo));
   
      % now we continue to build-up the sub menu items for Config/Stream
   
   if container(o) || trace(o)           % for object with config options
      %cfg = config(o);
      %if isempty(cfg)
      if (config(o,inf) == 0)          % for empty configurations
         o = config(o,symbol(o));      % initialize configuration
         o = push(o);
      end
      
         % As we have a valid configuration now let's do the actual work:
         % For each configured symbol create a menu entry for configuration
      
      for (j=1:config(o,inf))          % number of configured symbols
         sym = config(o,j);
         label = Label(o,sym);         % construct label
         [sub,col,cat] = config(o,sym);
         
            % entries are added if either category is non-zero, or
            % config mode enables all entries to be added
            
         if (cat || setting(o,'mode.config.show'))
            args = {sym,sub,col,cat};
            chk = o.iif(sub,'on','off');
            ooo = mitem(oo,label,{@Input,sym,sub,col,cat},[],'check',chk);
         end
      end
         
      setting(o,'config',config(o));   % update settings
   end
   return
   
   function lab = Label(o,sym)         % Label for Config Menu         
   %
   % CONFIG-LABEL   Construct labew for Config menu
   %
      [sub,col,cat] = config(o,sym);
      format = '%s: subplot %g, color ''%s'', category %g';
      lab = sprintf(format,sym,sub,col,cat);
   end
   function oo = Input(o)              % Input Stream Configuration    
   %
   % INPUT   Edit stream configuration
   %
   %    The callback is directly called from a menu item click event. The
   %    menu item has to be setup with an arg list consisting of
   %    {color,subplot}.
   %
   %       oo = mitem(o,'x',call('Input'),{'r',111})
   %
       oo = [];                        % init by default
       args = arg(o,0);  sym = args{1};
       caption = ['Edit Configuration Parameters of ',sym];
       prompt = {'Subplot Index (use 0 for disable):','Color:','Category:'};

       pars = args(2:4);
       [sub,col,cat] = input(o,caption,prompt,pars);

       if isempty(sub)
          return                       % canceled by user
       end
       if ~isa(sub,'double')
          msgbox('bad input: subplot number must be an integer!');
       end

       if (sub > 10)
          msgbox('max 10 subplots configurable!');
          return
       end
       if (length(sub) > 1)
          msgbox('bad input: subplot number must be a scalar integer!');
          return
       end

       if (cat > 10)
          msgbox('max 10 categories configurable!');
          return
       end
       if (length(cat) > 1)
          msgbox('bad input: category number must be a scalar integer!');
          return
       end

       pars{1} = sub;  pars{2} = col;  pars{3} = cat;

          % update new settings in object's config parameters
          % as well as menu item args

       try
          args = o.cons(sym,pars);     % construct updated args
          o = config(o,sym,pars);      % update parameters in config
          cfg = config(o);             % get config options
          setting(o,'config',cfg);     % store config options to settings

          [~,po] = mseek(o,'Config');  % seek 'Config' user data
          oo = Config(po);             % update whole Config menu
          refresh(o);                  % refresh screen
       catch
          msgbox('Bad parameters - ignore!');
       end
   end
end
function oo = Subplot(o)               % Subplot Menu Management       
%
% SUBPLOT   Subplot menu setup
%
   setting(o,{'subplot.layout'},1);    % default 1 subplot coloumn layout
   setting(o,{'subplot.limits'},[]);   % default no limits

   oo = mitem(o,'Subplot',{},'subplot.layout');
   choice(oo,{{'n x 1',1},{'n x 2',2},{'n x 3',3}},{});
end
function oo = Category(o)              % Category Menu Management      
%
   [oo,m] = category(pull(o));         % actualize category options
   catopts = opt(oo,'category');       % get no actualize category options
   setting(o,'category',catopts);      % actualize proper settings

   specs = catopts.specs;              % get specs
   limits = catopts.limits;            % get limits
   units = catopts.units;              % get units

   oo = o;                             % just in case if empty
   for (i=1:m)
      idx = sprintf('%g',i);
      oo = mitem(o,['Category ',idx]);

      tag = ['category.spec',idx];
      spec = specs(i,:);
      setting(o,tag,spec);

%     ooo = mitem(oo,'Spec',{@CatCb},tag);
      ooo = mitem(oo,'Spec',{},tag);
      choice(ooo,{{'None',[0 0]},{'+/- 0.1',[-0.1 0.1]},...
         {'+/- 0.2',[-0.2 0.2]},{'+/- 0.5',[-0.5 0.5]},...
         {'+/- 1',[-1 1]},{'+/- 2',[-2 2]},...
         {'+/- 3',[-3 3]},{'+/- 5',[-5 5]},...
         {'+/- 10',[-10 10]},{'+/- 15',[-15 15]},...
         {'+/- 20',[-20 20]},{'+/- 25',[-25 25]},...
         {'+/- 30',[-30 30]},{'+/- 50',[-50 50]}},{@CatCb});

      tag = ['category.limit',idx];
      limit = limits(i,:);
      setting(o,tag,limit);

%     ooo = mitem(oo,'Limit',{@CatCb},tag);
      ooo = mitem(oo,'Limit',{},tag);
      choice(ooo,{{'None',[0 0]},{'+/- 0.1',[-0.1 0.1]},...
         {'+/- 0.2',[-0.2 0.2]},{'+/- 0.5',[-0.5 0.5]},...
         {'+/- 1',[-1 1]},{'+/- 2',[-2 2]},...
         {'+/- 3',[-3 3]},{'+/- 5',[-5 5]},...
         {'+/- 10',[-10 10]},{'+/- 15',[-15 15]},...
         {'+/- 20',[-20 20]},{'+/- 25',[-25 25]},...
         {'+/- 30',[-30 30]},{'+/- 50',[-50 50]}},{@CatCb});

      ooo = mitem(oo,'Unit');
      oooo = mitem(ooo,['[',units{i},']']);
   end
   return
   
   function oo = CatCb(o)              % Category Callback
      oo = [];
      pid = get(gcbo,'parent');           % parent menu item ID
      tag = get(pid,'userdata');          % get parent's tag
      label = get(pid,'label');           % get label
      value = get(gcbo,'userdata');       % get value

      switch label
         case 'Spec'
            l = length('category.spec');
            idx = sscanf(tag(l+1:end),'%f');
            specs = setting(o,'category.specs');
            specs(idx,:) = value;
            setting(o,'category.specs',specs);

         case 'Limit'
            l = length('category.limit');
            idx = sscanf(tag(l+1:end),'%f');
            limits = setting(o,'category.limits');
            limits(idx,:) = value;
            setting(o,'category.limits',limits);
      end
      refresh(o);
   end
end
function oo = Grid(o)                  % Grid Menu                     
%
   setting(o,{'view.grid'},0);         % no grid by default
   
   oo = mitem(o,'Grid',{},'view.grid');
   choice(oo,{{'Off',0},{'On',1}},{});
end
function oo = Style(o)                 % Style Menu Management         
%
% STYLE   Style menu setup & handling (for plotting)
%
   setting(o,{'style.bullets'},0);
   setting(o,{'style.linewidth'},1);
   setting(o,{'style.labels'},'plain');
   setting(o,{'style.digits'},2);

   oo = mhead(o,'Style');
   
   ooo = mitem(oo,'Bullets',{},'style.bullets');
   choice(ooo,{{'Off',0},{'Black',-1},{'Colored',1}},{});
   
   ooo = mitem(oo,'Line Width',{},'style.linewidth');
   choice(ooo,1:7,{});
   
   ooo = mitem(oo,'Labels',{},'style.labels');
   choice(ooo,{{'Plain','plain'},{'Statistics','statistics'}},{});
 
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Digits',{},'style.digits');
   choice(ooo,[1:4],{});
end
function oo = Variation(o)             % Variation Menu Management     
%
% VARIATION   Variation menu setup & handling (for plotting)
%
   setting(o,{'variation.bullets'},0);
   setting(o,{'variation.center'},0);
   setting(o,{'variation.range'},0);

   oo = mhead(o,'Variation');
   ooo = mitem(oo,'Center Line Width',{},'variation.center');
   choice(ooo,0:5,{});
   
   ooo = mitem(oo,'Center Bullets',{},'variation.bullets');
   choice(ooo,{{'Off',0},{'On',1}},{});
   
   ooo = mitem(oo,'Range Line Width',{},'variation.range');
   choice(ooo,0:5,{});
end
function oo = Camera(o)                % Camera Menu                   
%
   setting(o,{'view.camera.azel'},[-40,30]);

   oo = mhead(o,'Camera');             % add Camera menu header
   ooo = mitem(oo,'Default View',{@CamCb,'Dview'});
   ooo = mitem(oo,'X-View',{@CamCb,'Xview'});
   ooo = mitem(oo,'Y-View',{@CamCb,'Yview'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Rotate');
   oooo = mitem(ooo,'Left',{@CamCb,'Left'});
   oooo = mitem(ooo,'Right',{@CamCb,'Right'});
   oooo = mitem(ooo,'Up',{@CamCb,'Up'});
   oooo = mitem(ooo,'Down',{@CamCb,'Down'});
   ooo = mitem(oo,'Spin',{@CamCb,'Spin'});
   return

   function oo = CamCb(o)              % Camera Callback               
      oo = o;                          % init by default
      azel = opt(o,{'view.camera.azel'},[-40 30]);
      switch arg(o,1)
         case 'Dview'                     % default view
            azel = [30,30]; 
         case 'Xview'                     % x-view
            azel = [0,0]; 
         case 'Yview'                     % y-view
            azel = [-90,0]; 
         case 'Left'                      % rotate left
            azel(1) = azel(1)-10; 
         case 'Right'                     % rotate right
            azel(1) = azel(1)-10; 
         case 'Up'                        % rotate up
            azel(2) = azel(2)+5; 
         case 'Down'                      % rotate down
            azel(2) = azel(2)-5; 
         case 'Spin'                      % spinning camera
            camera(o,'spinning');
      end
      view(azel);         
      setting('view.camera.azel',azel);

      if is(arg(o,1),{'Left','Right','Up','Down'})
         refresh(o,o);                    % come back here for refresh
      end
   end
end
function oo = Toolbar(o)               % Toolbar Menu                  
%
   setting(o,{'view.toolbar'},'none');
   
   oo = mitem(o,'Toolbar','','view.toolbar'); 
   choice(oo,{{'Off','none'},{'On','figure'}},{@ToolbarCb});
   return
   
   function o = ToolbarCb(o)           % Toolbar Callback              
   %
   % ToolbarCb has two working modes: a basic working mode and an advanced
   % mode. In the basic working mode we make just change the 'menubar' 
   % property of the figure. In advanced mode we lookup the callback
   % function which is used by the MATLAB figure menu
   %
      mode = opt(o,'view.toolbar');
      oo = mseek(o,{'#' 'Figure' 'View' 'Figure Toolbar'});

      if isempty(oo)                   % basic working mode
         set(gcf,'menubar',mode);
      else                             % advanced working mode
         hdl = mitem(oo,inf);          % get menu item handle
         callback = get(hdl,'callback');
         if ischar(callback)
            eval(callback);
         else
            set(gcf,'menubar',mode);   % backup: basic working mode
         end
      end
   end
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Add Select Menu               
%
% SELECT   Add Select menu
%
   oo = mhead(o,'Select');             % menu header
   ooo = menu(oo,'Objects');           % add Objects menu
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Basket');            % add Multiple menu
   ooo = mhead(oo,'Signal');           % add (hidden) Signal menu
   set(mitem(ooo,inf),'visible','off');
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Bias');              % add Bias menu
   ooo = menu(oo,'Filter');            % add Filter menu
   ooo = menu(oo,'Scope');             % add Scope menu
   ooo = menu(oo,'Ignore');            % add Ignore menu
end
function oo = Current(o)               % Rebuild Menus @ Current       
%
% CURRENT   Update current selection of object list.
%
   TryRebuild(o,'View');               % try to rebuild View menu
   TryRebuild(o,'Select');             % try to rebuild Select menu
   Title(oo);                          % refresh title in figure bar
   return
   
   function TryRebuild(o,menu)         % Try to Rebuild Menu           
      oo = mitem(pull(o));             % set refreshed top menu level
      gamma = eval(['@',launch(oo)]);  % shell handle
      try
         gamma(oo,menu);               % rebuild menu
      catch                            
         'catched!';                   % unsuccessful trial to rebuild
      end
   end
end
function oo = Title(o)                 % Set Title in Figure Bar       
   oo = current(o);                    % get current object
   title = get(o,{'title','Shell'});   % get container object's title
   title = get(oo,{'title',title});    % get current object's title
   set(figure(o),'name',title);        % update figure bar
end
function oo = Bias(o)                  % Bias Mode Menu                
%
   setting(o,{'mode.bias'},'drift');   % default bias mode is 'drift'

   oo = mitem(o,'Bias','','mode.bias');
   choice(oo,{{'Absolute','absolute'},{'Absolute * 1000','abs1000'},...
              {'Drift','drift'},{'Deviation','deviation'}},{});

   ooo = mseek(oo,{'Absolute * 1000'});
   set(mitem(ooo,inf),'visible','off');        
end
function oo = Filter(o)                % Filter Menu Management        
%
% Filter   Add menu items for filter parameters
%
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.enable'},0);     % filter type = 9 (forward/backward o1) 
   setting(o,{'filter.type'},9);       % filter type = 9 (forward/backward o1) 
   setting(o,{'filter.window'},15);    % filter window width
   
   mlist = {{'Raw Signal','raw'},{'Filtered Signal','filter'},...
            {'Raw & Filtered','both'},{'Signal Noise','noise'}};
        
   tlist = {{'No Filter',0},{'Mean of 3x3 - once',1},...
            {'Mean of 3x3 - twice',2},{'Mean of 3x3 - three times',3},...
            {'2nd order fit - once',6},{'2nd order fit - twice',7},...
            {'2nd order fit - three times',8},...
            {'Back/forth order 1 filter',9}};

   oo = mitem(o,'Filter');
   ooo = mitem(oo,'Mode','','filter.mode');
         choice(ooo,mlist,'');
   %ooo = mitem(oo,'Enable','','filter.enable');
   %      check(ooo,'');
   ooo = mitem(oo,'Type','','filter.type');
         choice(ooo,tlist,'');
   ooo = mitem(oo,'Window','','filter.window');
         choice(ooo,[3:10 15 20 50 100 200 300 400 500],'');
end
function oo = Scope(o)                 % Scope Menu                    
   setting(o,{'select.scope'},[]);     % no scope restriction
   setting(o,{'select.from'},1);       % scope from
   setting(o,{'select.to'},inf);       % scope to
   
   oo = mitem(o,'Scope');
   ooo = mitem(oo,'From',{},'select.from');
   charm(ooo,{@ScopeCb,'from'});
   ooo = mitem(oo,'To',{},'select.to');
   charm(ooo,{@ScopeCb,'to'});
   return
   
   function o = ScopeCb(o)
      mode = arg(o,1);
      oo = current(o);
      sz = sizes(oo);
      switch mode
         case 'from'
         case 'to'
      end
      from = setting(o,'select.from');
      to = setting(o,'select.to');
      from = max(min(from,sz(3)),1);
      
      if isinf(to) && sz(3) == 1
         scope = [];
      else
         to = max(min(to,sz(3)),1);
         scope = from:to;              % default scope range
      end
      setting(o,'select.scope',scope);    
      refresh(o);
   end
end
function oo = Ignore(o)                % Ignore Menu                   
%
   setting(o,{'select.ignore'},0);     % no data to ignore by default
   oo = mitem(o,'Ignore','','select.ignore');
   choice(oo,[0:10,15:5:25,50,100],{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu Management          
%
% PLOT   Setup & handle Plot menu items
%
   oo = mitem(o,'Stream',{@PlotCb,'Stream'});
   oo = mitem(o,'Fictive Stream',{@PlotCb,'Fictive'});
   oo = mitem(o,'-');
   oo = mitem(o,'Overlay',{@PlotCb,'Overlay'});
   oo = mitem(o,'Offsets',{@PlotCb,'Offsets'});
   oo = mitem(o,'Repeatability',{@PlotCb,'Repeatability'});
   oo = mitem(o,'Residual');
   ooo = mitem(oo,'Order 1',{@PlotCb,'Residual1'});
   ooo = mitem(oo,'Order 2',{@PlotCb,'Residual2'});
   ooo = mitem(oo,'Order 3',{@PlotCb,'Residual3'});
   oo = mitem(o,'-');
   oo = mitem(o,'Ensemble',{@PlotCb,'Ensemble'});
   oo = mitem(o,'Average',{@PlotCb,'Average'});
   oo = mitem(o,'Spread',{@PlotCb,'Spread'});
   oo = mitem(o,'Deviation',{@PlotCb,'Deviation'});
   oo = mitem(o,'-');
   oo = mitem(o,'Condensate');
   ooo = mitem(oo,'Order 1',{@PlotCb,'Condensate1'});
   ooo = mitem(oo,'Order 2',{@PlotCb,'Condensate2'});
   ooo = mitem(oo,'Order 3',{@PlotCb,'Condensate3'});
end
function o = PlotCb(o)                 % Plot Callback                 
   refresh(o,inf);                     % setup callback for refresh
   if isa(o,'carma')
      args = arg(o,0);                 % save args
      o = arg(pull(carma),args);       % restore args to pulled object
   end
   
   o = with(o,'style');                % unpack 'style' options
   o = with(o,'view');                 % unpack 'view' options
   o = with(o,'select');               % unpack 'select' options

   cls(o);                             % clear screen
   plot(o);                            % plot object
end

