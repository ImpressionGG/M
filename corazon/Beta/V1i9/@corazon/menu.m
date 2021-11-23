function oo = menu(o,varargin)         % Corazon Menu Building Blocks  
% 
% MENU   Package to provides building blocks for shell menu
%      
%           menu(o,locfunc)            % call local function 
%
%        Basic Menu Setup
%           oo = menu(o,'Begin');      % begin menu setup
%           oo = menu(o,'End');        % end menu setup
%           oo = menu(o,'Bar',list)    % define menu bar for fast build
%
%        Edit Menu
%           oo = menu(o,'Edit')        % add Edit menu
%
%        View Menu
%           oo = menu(o,'Grid')
%           oo = menu(o,'Dark')
%           oo = menu(o,'Style')
%           oo = menu(o,'Scale')
%
%        Select Menu
%           oo = menu(o,'Select')      % add Select menu
%           oo = menu(o,'Objects')     % add Objects menu
%           oo = menu(o,'Organize')    % add Organize menu
%           oo = menu(o,'Basket')      % add Basket menu
%           oo = menu(o,'Class')       % add Class menu
%           oo = menu(o,'Type')        % add Type menu
%           oo = menu(o,'Current',idx) % update current index
%
%        Gallery Menu
%           oo = menu(o,'Gallery')     % add Gallery menu
%
%        Info Menu
%           oo = menu(o,'Info')        % add Info menu
%           oo = menu(o,'Profiler')    % add Profiler menu
%           oo = menu(o,'Version')     % add Version menu
%           oo = menu(o,'Debug')       % add Debug menu
%
%        Figure Menu
%           oo = menu(o,'Figure')      % add Figure menu
%           menu(o,'Size',0.75,[-1,1]) % add Figure menu
%
%        Extras Menu
%           oo = menu(o,'Extras')      % add Extras menu
%
%        Plugin Menu
%           oo = menu(o,'Plugin')      % add Plugin menu
%
%        Display Functions
%           oo = menu(o,'Home')        % display home info (shell or obj.)
%           oo = menu(o,'About')       % display object info ('about me')
%           oo = menu(o,'What')        % display plot info ('what we see')
%           oo = menu(o,'Page')        % display gallery page info
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, SHELL, MITEM, CHECK, CHOICE, CHARM
%
   [gamma,o] = manage(o,varargin,@Begin,@End,@Dynamic,@Bar,@File,@Open,...
                     @New,@Save,@Edit,@LaunchCb,@CopyCb,@CutCb,@PasteCb,...
                     @ClearCb,@View,@Grid,@Dark,@Style,@Scale,...
                     @Select,@Objects,@Organize,@Basket,@Class,@Type,...
                     @Plot,@Title,@Home,@About,@What,@Page,@Gallery,...
                     @Info,@Parameter,@Dialog,@Property,@Profiler,...
                     @Version,@Debug,@Figure,@Size,@Extras,@Refresh,...
                     @Plugin);
   oo = gamma(o);
end

%==========================================================================      
% Begin/End Menu
%==========================================================================      

function oo = Begin(o)                 % Begin Menu Build (Overloaded) 
   o = control(o,{'debug'},1);         % provide debug flag
   o = control(o,{'verbose'},1);       % provide verbose level
   o = control(o,{'dynamic'},false);   % provide no dynamic menu control
   o = control(o,{'current'},0);       % provide current object index
   o = control(o,{'options'},1);       % inherit options from container
   o = control(o,{'launch'},'');       % provide launch function name
   o = control(o,{'what'},{'',''});    % provide 'what info'
   o = control(o,{'seed'},3);          % provide random seed
   o = control(o,'events',{});         % reset all events

   o = control(o,{'dark'},0);          % provide debug flag
   col = o.iif(control(o,'dark'),.15,.9)*[1 1 1];   
   o = control(o,{'color'},col);       % background color of shell   
   
   control(o,'plugin',{});             % unconditionally init setting
   oo = cast(o,'corazita');            % cast to Corazita object
   oo = menu(oo,'Begin');              % call menu@corazita>Begin

      % set screen dark if dark mode provided (avoid white flickers)
      
   cls(oo);
   
      % prepare menu headers if list provided
      
   list = control(oo,{'menu',{}});
   for (i=1:length(list))
      ooo = mhead(oo,list{i});
   end
   
%  Inherit(o);                         % inherit figure handle to children
   Inherit(oo);                        % inherit figure handle to children
   
   function Inherit(o)                 % Inherit Figure Handles        
   %
   % INHERIT   Inherit figure handle of shell object to all children of
   %           shell. This is important for the clone process and to
   %           maintain data integrity. Also update object ID
   %   
      o = pull(o);                     % refresh shell object
      assert(container(o));
   
      fig = figure(o);
      o = objid(o,0);                  % set shell object's object ID
      
      for (i=1:length(o.data))         % inherit figure handle to children
         oi = o.data{i};
         oi = figure(oi,fig);
         oi = objid(oi,i);             % set child's object ID
         o.data{i} = oi;
      end
      push(o);                         % refresh shell object
   end
end
function oo = End(o)                   % End Menu Build (Overloaded)   
   oo = corazita(o);                   % cast to Corazita object
   oo = menu(oo,'End');                % call menu@corazita>End
   plugin(oo,[o.tag,'/menu/End']);     % plug point
   Fix(oo);                            % eventually fix windows position
end
function oo = Bar(o)                   % Define Menu Bar for Fast Build
   list = arg(o,1);
   oo = control(o,'menu',list);        % store in control setting
   oo = arg(oo,{});                    % clear argument
end

%==========================================================================      
% File Menu
%==========================================================================      

function oo = File(o)                  % File Menu                     
   o.profiler('File',1);
   oo = mhead(o,'File');               % add roll down header item
   ooo = menu(oo,'New');               % add new menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Open');              % add Open menu item
   ooo = menu(oo,'Save');              % add Save menu item
   ooo = mitem(oo,'-');                % separator
%  ooo = mitem(oo,'Import','','','visible','off');  % add Import menu item
%  ooo = mitem(oo,'Export','','','visible','off');  % add Export menu item
   ooo = mhead(oo,'Import','','');     % add Import menu header
   ooo = mhead(oo,'Export','','');     % add Export menu header
   ooo = mitem(oo,'-');                % separator
%  ooo = mhead(oo,'Tools','','','visible','off');   % add Tools menu item
%  ooo = mhead(oo,'Extras','','','visible','off');  % add Export menu item
   ooo = mhead(oo,'Tools');            % add Tools menu header
   ooo = mhead(oo,'Extras');           % add Extras menu header
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Clone');             % add Clone menu item
   ooo = menu(oo,'Rebuild');           % add Rebuild menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'CloseOther');        % add CloseOther menu item
   ooo = menu(oo,'Close');             % add Close menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Exit');              % add Exit menu item
   o.profiler('File',0);
end
function oo = New(o)                   % Add New Menu                  
   oo = mhead(o,'New');                % Add New Menu item head
%  oo = mitem(o,'New');                % Add New Menu item head
   ooo = mitem(oo,'Shell',{@ShellCb}); % open another corazon shell
   return
   
   function oo = ShellCb(o)            % Shell Callback                
      tag = class(o);
      oo = eval(tag);                  % new empty container object
      oo.type = o.type;                % copy type
      launch(oo);                      % launch a new shell
   end
end
function oo = Open(o)                  % Add Open Menu Item
   oo = mitem(o,'Open ...',{@OpenCallback});
   return
   
   function o = OpenCallback(o)        % Open Callback                 
      try
         bag = load(corazita);          % load an object, using CORAZITA load
         launch(o,bag);                % launch a proper shell
      catch err
         message(o,err,'Error during Open ...');
      end
   end
end
function oo = Save(o)                  % Add Save Menu Item            
   oo = mitem(o,'Save ...',{@SaveCallback});
   return
   
   function o = SaveCallback(o)        % Save Callback                 
      o = clean(o);                    % clean object before saving
      try
%         save(corazita,pack(o));      % save object, using CORAZITA save
          save(o,pack(o));             % save object
      catch err
         message(o,err,'Error during Save ...');
      end
   end
end

%==========================================================================      
% Edit Menu
%==========================================================================      

function oo = Edit(o)                  % Edit Menu                     
%
% EDIT   Edit menu setup & handling
%
   if container(o)
      oo = mhead(o,'Edit');
      ooo = mitem(oo,'Property',{@Edit});
      ooo = mitem(oo,'Launch',{@menu,'LaunchCb'});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Copy',{@menu,'CopyCb'});
      ooo = mitem(oo,'Cut',{@menu,'CutCb'});
      ooo = mitem(oo,'Paste',{@menu 'PasteCb'});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Clear Objects',{@menu,'ClearCb'});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Copy Figure',{@CopyFigCb});
   else
      oo = mhead(o,'Edit');
      ooo = mitem(oo,'Copy',{@CopyCb});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Copy Figure',{@CopyFigCb});
   end
   return

   function o = Edit(o)                % Edit Property                 
      edit(o);                         % edit current object
   end
   function oo = CopyFigCb(o)          % Copy Figure Into Clipboard    
      editmenufcn(figure(o),'EditCopyFigure');
      oo = o;                          % copy input arg to output
   end
end
function oo = LaunchCb(o)              % Launch Object                 
   oo = current(o);                    % get current object
   launch(oo);                         % launch object's shell
end
function oo = CopyCb(o)                % Copy Object                   
   oo = current(o);
   
   if (container(oo))
      list = o.data;
   elseif type(oo,{'pkg'})
      list = PackageList(o,oo);        % all objects of a package
   else
      list = {oo};
   end
   
      % enclose object list into an object
      
   oo = data(corazon,list);
   clip(o,oo);                         % put list into clip board
end
function oo = CutCb(o)                 % Cut Object                    
   oo = current(o);
   
   if (container(oo))
      list = o.data;
   elseif type(oo,{'pkg'})
      list = PackageList(o,oo);        % all objects of a package
   else
      list = {oo};
   end
   
      % enclose object list into an object
      
   oo = data(corazon,list);
   clip(o,oo);                         % put list into clip board
   
      % save current object index and get list of object IDs to be
      % removed from shell object
   
   %[~,cidx] = current(o);              % get current index
   
   ids = {};
   for (i=1:length(list))
      ids{i} = id(list{i});
   end
      
      % remove all objects in list from shell object

   rest = {};                          % rest of objects
   for (i=1:length(o.data))
      oi = o.data{i};
      idoi = id(oi);
      if ~o.is(idoi,ids)
         rest{end+1} = oi;
      end
   end
   
      % push shell object with reduced object list
      
   o.data = rest;
   o = push(o);                        % push object back to figure 

   %cidx = min(cidx,data(o,inf));       % update current index
   cidx = 0;                           % select shell object
   current(o,cidx);                    % update current selection
   refresh(pull(o));
end
function oo = ClearCb(o)               % Clear All Objects             
   oo = pull(o);

   [list,~] = gallery(oo);             % get gallery list
   if ~isempty(list)
      msgbox('Clearing all objects is only possible with empty gallery!');
      return
   end

   if container(oo)
      button = questdlg('Do you want to clear all objects?',...
                        'Clear All Objects', 'Yes','No','No');  
      if strcmp(button,'Yes')
         oo = data(oo,{});             % clear objects
         oo = push(oo);                % update figure object

         setting(o,'basket.type','*'); % all types selected by default

         current(o,0);                 % update current selection
         %refresh(oo);                 % and refresh screen
         cls(o);
         menu(o,'About');
      end
   end
end
function oo = PasteCb(o)               % Paste Object                  
   oo = clip(o);                       % put object into clip board
   paste(o,oo.data);
end

function list = PackageList(o,oo)      % All Objects of a Package      
   assert(type(oo,{'pkg'}));
   
   package = get(oo,{'package','??'}); % package ID
   list = {};
   
   for (i=1:length(o.data))
      oi = o.data{i};
      if isequal(get(oi,'package'),package)
         list{end+1} = oi;
      end
   end
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
   oo = mhead(o,'View');               % add roll down header item
   dynamic(oo);                        % make this a dynamic menu

   ooo = menu(oo,'Grid');              % add Grid menu item
   ooo = menu(oo,'Dark');              % add Dark mode menu item
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Clear Screen',{@Cls});
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Style');             % add plot style sub menu

   plugin(o,'corazon/shell/View');     % plug point
   
   function o = Cls(o)
      cls(o);
   end
end
function oo = Grid(o)                  % Grid Menu                     
%
% GRID   Add grid menu items
%
   setting(o,{'view.grid'},0);

   oo = mitem(o,'Grid',{},'view.grid');
   check(oo,{});
end
function oo = Dark(o)                  % Add Dark Mode Menu Item       
   setting(o,{'control.dark'},0);      % provide dark mode default
  
   oo = mitem(o,'Dark Mode','','control.dark');
   check(oo,{@DarkCb});
   
   function o = DarkCb(o)
      mode = opt(o,'control.dark');
      dark(o,mode);
      refresh(o);
   end
end
function oo = Style(o)                 % Add Style Menu Items          
   setting(o,{'style.bullets'},1);     % provide bullets default
   setting(o,{'style.linewidth'},1);   % provide linewidth default
   setting(o,{'style.scatter'},'ryy'); % provide scatter color default

   oo = mitem(o,'Style');
   ooo = mitem(oo,'Bullets','','style.bullets');
   check(ooo,{});
   ooo = mitem(oo,'Line Width','','style.linewidth');
   choice(ooo,[1:5],{});
   ooo = mitem(oo,'Scatter Color','','style.scatter');
   charm(ooo,{});
end
function oo = Scale(o)                 % Add Scale Menu Items          
   setting(o,{'view.xunit'},'ms');     % time scaling unit
   setting(o,{'view.xscale'},1e3);     % time scaling factor
   setting(o,{'view.yunit'},'um');     % elongation scaling unit
   setting(o,{'view.yscale'},1e6);     % elongation scaling factor

   oo = mitem(o,'Scale');
   ooo = mitem(oo,'Time Scale',{},'view.xunit');
   choice(ooo,{{'s','s'},{'ms','ms'}},{@XscaleCb});
   ooo = mitem(oo,'Elongation Scale',{},'view.yunit');
   choice(ooo,{{'m','m'},{'mm','mm'},{'um','um'}},{@YscaleCb});
   
   function o = XscaleCb(o)
      unit = setting(o,'view.xunit');
      switch unit
         case 's'
            setting(o,'view.xscale',1);
         case 'ms'
            setting(o,'view.xscale',1e3);
      end
      refresh(o);
   end
   function o = YscaleCb(o)
      unit = setting(o,'view.yunit');
      switch unit
         case 'm'
            setting(o,'view.yscale',1);
         case 'mm'
            setting(o,'view.yscale',1e3);
         case 'um'
            setting(o,'view.yscale',1e6);
      end
      refresh(o);
   end
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   event(o,'select',o);                % call Select on 'select' event

   oo = [];                            % empty by default
%  if container(o)                     % only in case of container object
o = pull(o);                           % make sure we have shell object
      oo = mhead(o,'Select');          % add roll down header menu item
      ooo = menu(oo,'Objects');        % add Open menu item
      ooo = menu(oo,'Basket');         % add Basket menu
%  end
   
   if isempty(oo)
      Title(o);
   else
      Title(oo);                       % refresh title in figure bar
   end
end
function oo = Objects(o)               % Objects Menu                  
%
% OBJECTS   Setup Objects menu
%
   [iif,either] = util(o,'iif','either');   % need some utils
   packages = isequal(opt(o,'mode.organized'),'packages'); 
   
%  if ~container(o)
%     oo = o;
%     return                           % no Objects menu if no container!
%  end

   n = data(o,inf);                    % number of objects
   control(o,{'current'},iif(n,1,0));  % provide a default value

      % Locate Traces header and get the number of children. If not found
      % we create the Traces menu header   

   oo = mhead(o,'Objects','','Objects');

      % add object entries to the Objects menu

   [~,cidx] = current(o);

      % start with container selection menu item
      
   label = either(get(oo,'title'),'Package');
   chk = iif(cidx==0,'on','off');
   ooo = mitem(oo,label,{@Activate,0},0,'check',chk);
   
   if (n > 0)
      ooo = mitem(oo,'-');
   end
   
      % continue with child objects. It is important that MITEM
      % is called with the child object, since the object class
      % must be stored as a tag in the callback!
      
   orga = {};                          % init organizer structure 
   for (i=1:n)        
      oi = data(oo,i);                 % get i-th trace object
      oi.work.mitem = oo.work.mitem;   % transfer handle
      pid = get(oi,'package');         % get package ID

      label = either(get(oi,'title'),sprintf('Object #%g',i));
      chk = iif(i==cidx,'on','off');
      
         % organize by packages if enabled and proper
      
      if packages && ~isempty(pid) && ischar(pid)
         hdl = o.assoc(pid,orga);
         if isempty(hdl)
            if isequal(oi.type,'pkg')
               name = get(oi,{'title',pid});
            else
               name = pid;
            end
            ooo = mitem(oo,name);      % add menu item for package
            hdl = ooo.work.mitem;      % get menu item handle
            orga{end+1} = {pid,hdl};   % add assoc pair to organizer
         end
         oi.work.mitem = hdl;          % store menu item handle
      end
      
         % add object menu item
         
      if type(oi,{'pkg'})
         mitem(oi,'-');                      % separator before package object
      end
      ooo = mitem(oi,label,{@Activate,i},i,'check',chk);
      if type(oi,{'pkg'})
         ooo = mitem(oi,'-');          % separator after package object
      end
   end
end
function oo = Organize(o)              % Add Organize Menu             
   setting(o,{'mode.organized'},'packages');
   oo = mitem(o,'Organize',{},'mode.organized');
   choice(oo,{{'Plain','plain'},{'Packages','packages'}},{@Rebuild});
   return
   
   function o = Rebuild(o)
      [~,po] = mseek(o,{'#','Select','Objects'});
      menu(po,'Objects');              % rebuild Objects menu
   end
end
function oo = Basket(o)                % Basket Menu                   
   setting(o,{'basket.collect'},'selected');  % collection of objects
   %setting(o,{'basket.groups'},'*');  % choice of groups

   oo = mhead(o,'Basket');             % add Basket header
   
   ooo = mhead(oo,'Collect','','basket.collect'); % add Objects menu header
   choices = {{'All Objects','*'},{},{'Selected Object','selected'},...
              {'Marked Objects','marked'},{'Unmarked Objects','unmarked'}};
   choices = {{'All Objects','*'},{},{'Selected Object','selected'}};
   choice(ooo,choices,'');
   
%  ooo = mitem(oo,'-');                % add separator
%  ooo = mhead(oo,'Groups','','basket.groups');   % add Groups menu header
%  choices = {{'All Groups','*'},{},...
%             {'Marked Groups','marked'},{'Unmarked Groups','unmarked'}};
%  choice(ooo,choices,'');
%  set(mitem(ooo,inf),'visible','off');% make invisible
   
   ooo = menu(oo,'Type');              % add Type menu
end
function oo = Class(o)                 % Add Class Menu                
oo=o;
% %
% % CLASS   Setup class selection menu
% %
%    setting(o,{'basket.class'},'*');    % all classes selected by default
%    
%       % for each different class add a menu item
%       
%    choices = {{'All Classes','*'}};
%    list = Classes(o);
%    if ~isempty(list)
%       choices{end+1} = {};
%       for (i=1:length(list))
%          name = list{i};
%          choices{end+1} = {[upper(name(1)),name(2:end)],name};
%       end
%    end
%    
%    oo = mhead(o,'Class','','basket.class');
%    choice(oo,choices,{@ClassCb});
%    return
%    
%    function o = ClassCb(o)
%       oo = current(o);                 % get current object
%       dynamic(o,oo);                   % update all dynamic menu items
%       refresh(o);
%    end
%    function list = Classes(o)          % Get List of Classes           
%       list = {};
%       if container(o)
%          for (i=1:length(o.data))
%             name = class(o.data{i});
%             if ~corazon.is(name,list)
%                list{end+1} = name;
%             end
%          end
%       end
%    end
end
function oo = Type(o)                  % Add Type Menu                 
%
% TYPE   Setup type selection menu
%
   setting(o,{'basket.type'},'*');     % all types selected by default
   
      % for each different type add a menu item
      
   choices = {{'All Types','*'}};
   list = Types(o);
   if ~isempty(list)
      choices{end+1} = {};
      for (i=1:length(list))
         name = list{i};
         choices{end+1} = {name,name};
      end
   end
   oo = mhead(o,'Type','','basket.type');
   choice(oo,choices,{@TypeCb});
   return
   
   function o = TypeCb(o)
      oo = current(o);                 % get current object
      dynamic(o,oo);                   % update all dynamic menu items
      refresh(o);
   end
   function list = Types(o)            % Get List of Types             
      list = {};
      if container(o)
         for (i=1:length(o.data))
            oo = o.data{i};
            if ~corazon.is(oo.type,list)
               list{end+1} = oo.type;
            end
         end
      end
   end
end
function oo = Activate(o)              % Object Activation             
%
   o.profiler('Activate',1);           % begin profiling
   
   idx = arg(o,1);
   oo = current(o,idx);
   
   o.profiler('Activate',0);           % end profiling
   if control(o,'profiling') > 1
      o.profiler
   end
   
   refresh(o);
   
   if (idx == 0)
      title = 'Package';
   else
      title = sprintf('Object #%g',idx);
   end
   
   title = get(oo,{'title',title});
   set(figure(o),'name',title);        % update figure title
end
function oo = Title(o)                 % Set Title in Figure Bar       
   oo = o;   %oo = current(o);         % get current object
   title = get(o,{'title','Shell'});   % get container object's title
   title = get(oo,{'title',title});    % get current object's title
   set(figure(o),'name',title);        % update figure bar
end

%==========================================================================      
% Gallery Menu
%==========================================================================      

function oo = Gallery(o)               % Refresh Gallery Menu          
%
% GALLERY   Refresh Gallery menu
%
   iif = @corazito.iif;                % need some utility

   setting(o,{'gallery.template'},0);  % execute as a template

   [list,cur] = gallery(o);            % get gallery list & current index
   n = length(list);

   oo = mhead(o,'Gallery');            % seek menu head
   ooo = mitem(oo,'Organize');
   oooo = mitem(ooo,'Add to Gallery',{@AddCb});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Add a Gallery Page',{@PageCb});
   oooo = mitem(ooo,'Gallery Info');
   ooooo = mitem(oooo,'Display',{@DispCb});
   ooooo = mitem(oooo,'-');
   ooooo = mitem(oooo,'Edit ...',{@EditCb});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Execute as Template','','gallery.template');
          check(oooo);
   oooo = mitem(ooo,'Create Word Report',{@ReportCb});
   set(work(oooo,'mitem'),'enable',iif(n==0,'off','on'));
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Move Up',{@UpCb});
   set(work(oooo,'mitem'),'enable',iif(n==0||cur==1,'off','on'));
   oooo = mitem(ooo,'Move Down',{@DownCb});
   set(work(oooo,'mitem'),'enable',iif(n==0||cur==n,'off','on'));
   oooo = mitem(ooo,'Delete Entry',{@DeleteCb});
   set(work(oooo,'mitem'),'enable',iif(n==0,'off','on'));
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Clear Gallery',{@ClearCb});
   set(work(oooo,'mitem'),'enable',iif(n==0,'off','on'));
   ooo = mitem(oo,'-');

   for (i=1:n)
      entry = list{i};
      ooo = mitem(oo,entry.title,{@ActivateCb,i});
      if (cur == i)
         set(work(ooo,'mitem'),'check','on');
      end
   end
   return

   function o = AddCb(o)               % Add to Gallery With Dialog    
      gallery(pull(o));                % add to gallery with dialog
   end
   function o = PageCb(o)              % Add Gallery Page With Dialog  
      pair = what(o);                  % load oo with 'what info'
      oo = construct(o,o.tag);         % construct empty object
      oo = set(oo,'title',pair{1});
      oo = set(oo,'comment',pair{2});
      oo = Property(oo);               % edit properties
      if ~isempty(oo)
         title = get(oo,{'title',''});
         comment = get(oo,{'comment',{}});
         what(o,title,comment);        % setup 'what info'
         o = pull(o);                  % pull to update control options
         Page(o);                      % display page info
         o = pull(o);                  % pull to update refresh options
         oo = opt(oo,opt(o));          % copy options
         gallery(o,oo);                % add to gallery, no dialog
      end
   end
   function o = DispCb(o)              % Display Gallery Entry         
      gallery(pull(o),'Display');      % display gallery entry
   end
   function o = EditCb(o)              % Edit Gallery Entry with dialog
      gallery(pull(o),'Edit');         % edit gallery entry with dialog
   end
   function o = ReportCb(o)            % Make a Word Report            
      oo = word(o,'Begin');            % begin word document
      shg(o);
      for (i=1:gallery(o,inf))
         gallery(o,i);                 % activate i-th gallery entry
         oo = word(oo,'Add');
      end
      oo = word(oo,'End');             % end word document
   end         
   function o = UpCb(o)                % Move Gallery Item Up          
      gallery(pull(o),'Up');           % move gallery item up
   end
   function o = DownCb(o)              % Move Gallery Item Down        
      gallery(pull(o),'Down');         % move gallery item down
   end
   function o = DeleteCb(o)            % Delete Gallery Entry          
      button = questdlg('Delete gallery entry?',...
                        'Delete Gallery Entry', 'Yes','No','No');  
      if strcmp(button,'Yes')
         gallery(pull(o),'Delete');    % delete gallery entry
      end
   end   
   function o = ClearCb(o)             % Clear Gallery                 
      button = questdlg('Do you want to clear entire gallery?',...
                        'Clear Gallery', 'Yes','No','No');  
      if strcmp(button,'Yes')
         gallery(o,[]);                % clear gallery
      end
   end
   function o = ActivateCb(o)          % Activate i-th Gallery Entry   
      idx = arg(o,1);                  % index of gallery entry
      gallery(o,idx);                  % invoke gallery entry
   end
end

%==========================================================================      
% Info Menu
%==========================================================================      

function oo = Info(o)                  % Info Menu                     
%
   oo = mhead(o,'Info');               % add sub menu header

   ooo = mitem(oo,'Shell Info');
   oooo = mitem(ooo,'Display',{@Disp,'Shell'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'Shell'});
   ooo = mitem(oo,'-');
   
   ooo = mitem(oo,'About Object');
   oooo = mitem(ooo,'Display',{@Disp,'About'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'About'});
   
   EN = 'enable';                      % short hand
   ooo = mitem(oo,'Parameters   ');
   oooo = mitem(ooo,'Display',{@Disp,'Parameter'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'Parameter'});

   ooo = mitem(oo,'-');
   ooo = menu(oo,'Version');           % add Version menu
   ooo = mitem(oo,'Tutorial','','','visible','off');
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Debug');             % add Debug menu
   return
   
   function oo = Disp(o)               % Display Info                  
      mode = arg(o,1);
      switch mode
         case 'Shell'
            oo = menu(o,'Home');
         case 'About'
            oo = menu(o,'About');      % about the current object
         case 'Parameter'
            oo = menu(o,'Parameter');  % key parameter info
      end
   end
   function oo = Edit(o)               % Edit Info                     
      mode = arg(o,1);
      switch mode
         case 'Shell'
            oo = opt(o,'caption','Edit Shell Info');
            oo = Property(oo);         % edit object properties
            if ~isempty(oo)
               o = set(o,'title',get(oo,'title'));
               o = set(o,'comment',get(oo,'comment'));
               push(o);            % push modified object into shell

               title = get(o,{'title','Shell'}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(o,{mode}));
            end      
         case 'About'
            oo = current(o);           % get current object
            oo = opt(oo,'caption','Edit Object Info (About ...)');
            oo = Property(oo);         % edit object properties
            if ~isempty(oo)
               current(corazon,oo);    % update current object

               title = get(o,{'title','Shell'}); 
               title = get(oo,{'title',title}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(oo,{mode}));
            end      
         case 'Parameter'
            oo = current(o);           % get current object
            oo = opt(oo,'caption','Edit Key Parameters');
            oo = menu(oo,'Dialog');    % dialog for editing key parameters
            if ~isempty(oo)
               current(corazon,oo);    % update current object

               title = get(o,{'title','Shell'}); 
               title = get(oo,{'title',title}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(oo,{mode}));
            end      
      end
   end
end
function oo = Debug(o)                 % Debug Menu Items              
%
% DEBUG   Debug menu setup
%
   setting(o,{'control.autoclc'},1);
   
   oo = mhead(o,'Debug');              % find Debug menu item
   ooo = mitem(oo,'Verbose','','control.verbose');
         choice(ooo,0:4);
   ooo = menu(oo,'Profiler');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Debug Mode','','control.debug');
         choice(ooo,{{'Off',0},{'On',1}});
   ooo = mitem(oo,'Auto CLC','','control.autoclc');
         choice(ooo,{{'Off',0},{'On',1}});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Plugin');
   oooo = mitem(ooo,'Show Plugin Info',{@PluginInfo});
   oooo = mitem(ooo,'Clear Plugin Registry',{@ClearRegistry});
   return
   
   function o = PluginInfo(o)          % Plugin Info Callback          
      plugin(o);                       % show plugin info
      message(o,'Plugin info printed to MATLAB console!');
   end
   function o = ClearRegistry(o)       % Clear Registry Callback       
      plugin(o,{});                    % clear plugin registry
      rebuild(o);                      % rebuild menu bar
   end
end
function oo = Profiler(o)              % Profiler Menu                 
   setting(o,{'control.profiling'},0);

   oo = mhead(o,'Profiler');
   ooo = mitem(oo,'Profiling',{},'control.profiling');
   choice(ooo,{{'Off',0},{'On',1},{},{'Auto',2}},{@ProfilingControl});
   ooo = mitem(oo,'Print Profiling Info',{@Print});
   return
   
   function o = ProfilingControl(o)    % Profiling Control Callback    
      if control(o,'profiling')
         o.profiler('on');
      else
         o.profiler('off');
      end
   end
   function o = Print(o)               % Print Profiling Info          
      o.profiler;
   end
end
function oo = Version(o)               % Version Menu Management       
%
% VERSION   Add Version menu items
%
   oo = mhead(o,'Version');
   ooo = mitem(oo,['Corazon Toolbox: Version ',version(corazon)]);
   oooo = mitem(ooo,'Edit Release Notes','edit corazon/version');
end
function oo = Parameter(o)             % Display Key Parameter Info    
%
% prepare comments for message
%
   oo = current(o);
   typ = oo.type;
   title = get(oo,{'title','[]'});
   text = get(oo,{'comment',{}});
   kind = get(oo,{'kind','[]'});
   date = get(oo,{'date','[]'});
   time = get(oo,{'time','[]'});
   project = get(oo,{'project','[]'});
   package = get(oo,{'package','[]'});
   version = get(oo,{'version','[]'});
   creator = get(oo,{'creator','[]'});
   
   comment = {};
   if ~isempty(text)
      if length(text) >= 1
         comment{end+1} = text{1};
      end
      if length(text) >= 2
         comment{end+1} = text{2};
      end
      if length(text) >= 3
         comment{end+1} = text{3};
      end
      if length(text) >= 4
         comment{end+1} = '...';
      end
   end
      
   comment{end+1} = '';
   comment{end+1} = ['Class: ',class(oo),', Type: ',typ];
   comment{end+1} = ['Date: ',date,', Time: ',time];
   comment{end+1} = ['Project: ',project];
   comment{end+1} = ['Version: ',version,', Creator: ',creator];

   message(oo,title,comment);
   refresh(o,o);                       % come back here for refresh
end
function oo = Query(o)                 % Display Query Info            
   info = opt(o,'corona');
   if isempty(info)
      if exist('corona') == 2
         qo = query(o);
         info = query(qo);
      else
         message(o,'No Query Information Available');
         return
      end
   end
%
% corona info provided
%
   q = info.query;
   if ischar(q.machine)
      machines = q.machine;
   elseif iscell(q.machine)
      machines = ''; sep = '';
      for (i=1:length(q.machine))
         machines = [machines,sep,q.machine{i}];
         sep = ', ';
      end
   else
      machines = '';
   end
%
% prepare comments for message
%
   [date,time] = now(o,q.datenum);
   
   comment{1} = ['Title: ',q.title];
   comment{2} = sprintf('Comment: %g lines',length(get(o,'comment')));
   comment{3} = ['Project: ',q.project];
   comment{4} = ['Machines: ',machines];
   comment{5} = ['Date: ',date,', Time: ',time];
   comment{6} = ['Kind: ',q.kind];
   comment{7} = ['Class: ',q.class];
   
   message(o,'Query Information',comment);
   refresh(o,o);                       % come back here for refresh
   oo = o;
end
function oo = Property(o)              % Edit Object Properties        
%
% PROPERTIES  A dialog box is opened to edit object properties
%             With opt(o,'caption') the default caption of the dialog box
%             can be redefined.
%
   either = @corazito.either;          % short hand
   is = @corazito.is;                  % short hand
   trim = @corazito.trim;              % short hand
   
   caption = opt(o,{'caption','Edit Object Properties'});
   tit = either(get(o,'title'),'');
   comment = either(get(o,'comment'),{});
   if ischar(comment)
      comment = {comment};
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment'};
   values = {tit,text};
   
   values = inputdlg(prompts,caption,[1 50;10 50],values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   tit = either(values{1},tit);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);   % right trim
   end
   
   oo = set(o,'title',tit,'comment',comment);
end
function oo = Dialog(o)                % Edit Key Parameters           
%
% Dialog  A dialog box is opened to edit key parameters
%         With opt(o,'caption') the default caption of the dialog box
%         can be redefined.
%
   either = @corazito.either;          % short hand
   is = @corazito.is;                  % short hand
   trim = @corazito.trim;              % short hand
   
   caption = opt(o,{'caption','Edit Key Parameters'});
   title = either(get(o,'title'),'');
   comment = either(get(o,'comment'),{});
   if ischar(comment)
      comment = {comment};
   end
   date = either(get(o,'date'),'');
   time = either(get(o,'time'),'');
   project = either(get(o,'project'),'');
   version = either(get(o,'version'),'');
   creator = either(get(o,'creator'),'');
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment','Date','Time',...
              'Project','Version','Creator'};
   values = {title,text,date,time,project,version,creator};
   dims = ones(length(values),1)*[1 50];  dims(2,1) = 3;
   
   values = inputdlg(prompts,caption,dims,values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   title = either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);   % right trim
   end
   oo = set(o,'title,comment',title,comment);
   
   date = values{3};  time = values{4};
   oo = set(oo,'date',date,'time',time);
   
   project = values{5};  version = values{6};  creator = values{7};
   oo = set(oo,'project',project,'version',version,'creator',creator);
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = Figure(o)                % Figure Menu                   
%
   mode = Fix(o);                      % get status of window fixing
   setting(o,{'control.fix'},mode);

   oo = mhead(o,'Figure');             % add sub menu header
   ooo = mitem(oo,'What We See');
   oooo = mitem(ooo,'Display',{@Disp,'What'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'What'});

   ooo = mitem(oo,'Refresh',{@menu 'Refresh'});
   ooo = SizeMenu(oo);                 % add figure size sub menu
   ooo = mitem(oo,'Fix Figure','','control.fix');
         choice(ooo,{{'Off',0},{'On',1}},{@FixFigure});
   ooo = mitem(oo,'-');                % separator
   ooo = CopyMenu(oo);                 % copy figure menu
   return
   
   function o = Disp(o)                % Display What Text             
      What(o);                         % what we see
   end
   function o = Edit(o)                % Edit What Text                
      pair = what(o);                  % load oo with 'what info'
      ol = set(o,'title',pair{1});
      ol = set(ol,'comment',pair{2});
      ol = Property(ol);               % edit properties
      if ~isempty(ol)
         what(ol,ol);                  % store 'what info' in settings
         What(pull(o));                % display 'what info'
      end
   end
   function o = CopyMenu(o,hdl)        % Copy Figure Menu              
      while (nargin == 1)
         fig = figure;                 % open a new figure
         set(fig,'visible','off');     % make figure invisible
         CopyMenu(o,fig);              % copy Figure menu tree
         delete(fig);                  % close figure
         return
      end
      
      kids = findall(hdl,'parent',hdl); % get all hidden children
      for (i=length(kids):-1:1)
         kid = kids(i);
         type = get(kid,'Type');
         if isequal(type,'uimenu')
            label = get(kid,'label');
            if (label(1) == '&')
               label(1) = '';
            end
            callback = get(kid,'Callback');
            userdata = get(kid,'UserData');
            separator = get(kid,'Separator');
            if isequal(label,'File')
               separator = 'on';
            end
            ol = mitem(o,label,callback,userdata,'separator',separator);
            ol = CopyMenu(ol,kid);
         end
      end
   end
end
function o = Refresh(o)                % Refresh Figure                
   refresh(o);                         % invoke refresh callback
end
function o = SizeMenu(o)               % Figure Size Submenu           
   oo = mitem(o,'Size');
   ooo = mitem(oo,'Full',{@Size,1},[0,0]);
   ooo = mitem(oo,'3/4 Center',{@Size,0.75},[0,0]);
   ooo = mitem(oo,'2/3 Center',{@Size,2/3},[0,0]);
   ooo = mitem(oo,'1/2 Center',{@Size,0.5},[0,0]);
   ooo = mitem(o,'-');
   ooo = mitem(oo,'3/4 Top Left',{@Size,0.75},[-1,+1]);
   ooo = mitem(oo,'3/4 Top Right',{@Size,0.75},[+1,+1]);
   ooo = mitem(oo,'3/4 Bottom Left',{@Size,0.75},[-1,-1]);
   ooo = mitem(oo,'3/4 Bottom Right',{@Size,0.75},[+1,-1]);
   ooo = mitem(o,'-');
   ooo = mitem(oo,'1/2 Top Left',{@Size,0.5},[-1,+1]);
   ooo = mitem(oo,'1/2 Top Right',{@Size,0.5},[+1,+1]);
   ooo = mitem(oo,'1/2 Bottom Left',{@Size,0.5},[-1,-1]);
   ooo = mitem(oo,'1/2 Bottom Right',{@Size,0.5},[+1,-1]);
end   
function o = Size(o)                   % Change Figure Size & Position 
      size = arg(o,1);
      where = arg(o,2);
      
      if (size == 1)
         size = [0.99 0.95];    % otherwise some crazy effect ???s
      end
      
      pos = get(0,'ScreenSize');     
      wh = size.*pos(3:4);  
      off = (1+where)/2 .* (pos(3:4).*(1-size));  
      set(figure(o),'OuterPosition',[off wh]);
      refresh(o);
end
function mode = Fix(o,mode)            % Fix Windows Position          
%
% FIX   Fix windows position if activated
%
%          Fix(o,true)                 % activate fixed windows position
%          Fix(o,false)                % deactivate fixed windows position
%
%          Fix(o)                      % condtionally fix windows position
%          mode = Fix(o)               % get fixed status
%
   persistent position                 % persistent windows position
 
   if (nargin == 1)
      if nargout >= 1
         mode = ~isempty(position);
      elseif ~isempty(position)
         fig = figure(o);
         set(fig,'position',position); % update new figure position
      end
   elseif (nargin == 2 && mode)        % activate fixed windows position
      fig = figure(o);
      position = get(fig,'position');  % store current window position
   elseif (nargin == 2 && ~mode)       % deactivate fixed windows position
      position = [];                   % deactivate by assigning []
   else
      error('bad calling syntax!');
   end
   
   if isempty(position)
      %position = [0 500 800 500];
      %fig = figure(o);
      %set(fig,'position',position);    % update new figure position
   end
end
function o = FixFigure(o)              % Fix Figure Callback           
   mode = setting(o,'control.fix');
   Fix(o,mode);
end

%==========================================================================
% Extras Menu
%==========================================================================

function oo = Extras(o)                % Extras Menu                   
   oo = mhead(o,'Extras');             % add Extras menu header
   ooo = menu(oo,'Edit');              % add Edit menu
   ooo = menu(oo,'Select');            % add Select menu
   ooo = menu(oo,'Gallery');           % add Gallery menu
   ooo = menu(oo,'Info');              % add Info menu
   ooo = menu(oo,'Figure');            % add Figure menu
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu                   
   oo = mhead(o,'Plugin');
   set(mitem(oo,inf),'visible','off');
end

%==========================================================================      
% Auxillary Functions
%==========================================================================      

function oo = Home(o)                  % Display Shell Home Info       
   oo = o;                             % copy to output by default
   o = pull(o);                        % pull container object
   cls(o);
   message(o);                         % display shell info
   refresh(o,{'menu','Home'});         % update refresh callback
   comment = {'The shell info is represented by the title',...
              'and comment of the shell''s container object'};
   what(o,'Shell Info',comment);
   
   color = corazito.either(control(o,'color'),0.9*[1 1 1]);
   set(figure(o),'color',color);
end
function oo = About(o)                 % Display Object Info           
%
% ABOUT   About the current object (object info)
%
   cls(o);
   
   oo = current(o);
   oo = inherit(oo,o);                 % get options
   
   if container(oo)
      list = Classes(oo);
      if length(list) > 1
         comment = get(oo,{'comment',{}});
         comment{end+1} = '';
         comment{end+1} = 'There are multiple classes in current selection.';
         comment{end+1} = 'In order to get dynamic menus avoid multiple';
         comment{end+1} = 'class selection (e.g. select a class)!';
         oo.par.comment = comment;
      end
      message(oo);                     % display message
      %set(figure(oo),'color',[1 1 1]); % white color for containers
   else
      message(oo);                     % display message
   end
   
   refresh(o,{'menu','About'});        % update refresh callback
   
   comment = {'The object info is represented by the title',...
              'and comment of the current object'};
   what(o,'Object Info',comment);
   return
end
function oo = What(o)                  % Display Plot Info             
%
% WHAT   What does the current plot show (plot info)
%
   oo = o;                             % copy by default
   what(o);                            % nothing more than that
   %set(figure(o),'color',0.9*[1 1 1]); % set special background color
end
function oo = Page(o)                  % Display Gallery Page Info     
%
% PAGE   Gallery page info; like plot info (What) but with updated
%        refresh callback.
%
   oo = o;                             % copy to output by default
   what(o);                            % Display 'what info' (plot info)
   set(figure(o),'color',[1 1 1]);     % white background for pages
   refresh(o,{'menu','Page'});         % update refresh callback
end
function list = Classes(o)             % Get List of Classes           
   objects = basket(o);                % get list of objects in basket
   list = {};
   classes = {};
   for (i=1:length(objects))
      oo = objects{i};
      name = class(oo);
      if ~corazon.is(name,classes)
         list{end+1} = oo;
         classes{end+1} = name;
      end
   end
end
