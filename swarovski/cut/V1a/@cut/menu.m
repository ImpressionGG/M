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
%       menu(o,'Geometry');            % add Geometry menu
%       menu(o,'Geometry',{'pln',...});% conditional adding Geometry menu
%
%    2) Define rolldown menu bar foe quick build
%
%       menu(o,{'File','Edit','View',...,'Figure'})   % for quick build
%
%    See also: CARALOG, SHELL, ADVANCED
%
   [gamma,oo] = manage(o,varargin,@Error,@Default,@Begin,@End,@File,...
                 @New,@NewShell,@NewSimple,@NewPlain,@Tools,@Extras,...
                 @View,@Control,@Signal,@Config,@Types,@Category,...
                 @Stream,@Subplot,@Select,@Organized,@Objects,@Activate,...
                 @Basket,@Kind,@Overlays,@Bias,@Rotate,@Toolbar,@Filter,...
                 @Scope,@Ignore,@Style,@Variation,@Scale,@Camera,@CamCb,...
                 @Grid,@Plot,@PlotCb,@Analysis,@Geometry,@GeoCb,@Surf,...
                 @Capability,@CapaCb,@Parameter,@Dialog,@Title);
   oo = gamma(oo);                    % invoke callback
end

%==========================================================================
% Menu Setup
%==========================================================================

function o = Error(o)                  % Error                         
   error('menu method must be called with a local function arg!');
end
function o = Default(o)                % Provide Defaults              
%
   o = set(o,{'title'},'Cut Shell');
   o = set(o,{'comment'},{'Cutting Data Analysis'});

   %o = default(o,{'gallery'});                  % use defaults from file
   o = opt(o,{'mode.bias'},'drift');             % bias mode: 'drift'
   o = opt(o,{'mode.config.opts'},1);            % shell provides options
   o = opt(o,{'style.labels'},'statistics');     % statistics by default
   
%    if (category(o,inf) == 0) && (container(o) || trace(o))
%       o = category(o,1,[-3 3],[0 0],'�');        % category 1 for x,y
%       o = category(o,2,[-30 30],[0 0],'m�');     % category 2 for th
%    end
%    
%    if (config(o,inf) == 0)  && (container(o) || trace(o))
%       o = config(o,'x',{1,'r',1});
%       o = config(o,'y',{1,'b',1});
%       o = config(o,'p',{2,'g',2});
%       o = config(o,'sys',{0,'y',0});
%       o = config(o,'i',{0,'a',0});
%       o = config(o,'j',{0,'k',0});
%    end
   
   control(o,{'color'},[1 1 1]);       % provide background color
end
function oo = Begin(o)                 % Begin Menu Build (Overloaded) 
   o = control(o,{'active'},'');       % provide 'active' default setting
   co = cast(o,'corazon');
   oo = menu(co,'Begin');              % call corazon/menu/Begin
   busy(oo,'Building menu ...');
end
function oo = End(o)                   % End Menu Build (Overloaded)   
   co = cast(o,'corazon');
   oo = menu(co,'End');                % call corazon/menu/Begin
   ready(oo);
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
   ooo = mitem(oo,'Import','','','visible','off');  % add Import menu item
   ooo = mitem(oo,'Export','','','visible','off');  % add Export menu item
   ooo = menu(oo,'Tools');             % add Tools menu
   ooo = menu(oo,'Extras');            % add Extras menu
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
function oo = New(o)                   % New Menu                      
   oo = mhead(o,'New');
   ooo = menu(oo,'NewShell');          % add New Shell menu
   ooo = mitem(oo,'Package',{@PackageCb});
   ooo = mitem(oo,'-');
   %ooo = mitem(oo,'Plain Trace',{@NewPlain});
   %ooo = mitem(oo,'Simple Trace',{@NewSimple});
   %ooo = mitem(oo,'Cut');
   %oooo = mitem(ooo,'Cut Log',{@NewCutlog});
   return
   
   function oo = PackageCb(o)          % New Package Callback           
      run = 0;                         % init run number
      mach = '';
      for (i=1:length(o.data))
         oo = o.data{i};
         if o.is(get(oo,'kind'),'pkg')
            package = get(oo,{'package','0000.0'});
            idx = findstr('.',package);
            if ~isempty(idx)
               pnum = sscanf(package(idx+1:end),'%f');
               mach = package(2:idx-1);
               run = max(run,pnum);
            end
         end
      end
      
      if ~isempty(mach)
         machine = ['LPC',mach];
         run = run + 1;                % run number
         o = set(o,'machine',machine,'run',run);
      end
      
      oo = new(o,'Package','pkg');
      
         % paste package object into shell

      if ~isempty(oo)
         oo.tag = o.tag;               % inherit tag from parent
         oo = balance(oo);             % balance object
         paste(o,{oo});                % paste new object into shell
      end
   end
end
function oo = NewShell(o)              % Open a New Shell              
   oo = mitem(o,'Shell',{@ShellCb});   % open another shell
   return
   
   function oo = ShellCb(o)            % Shell Callback                
      tag = class(o);
      oo = eval(tag);                  % new empty shell object
      oo.type = o.type;                % copy type
      func = launch(o);
      oo = launch(oo,func);            % set launch function
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

   oo = cordoba('plain');           % construct CORDOBA object
   oo = trace(oo,t,'x',x,'y',y,'p',p); % make a trace with t, x & y

   oo = set(oo,'sizes',[m,n,r]);    % set data sizes
   oo = set(oo,'method','blcs');    % set processing method

      % provide title & comments for the caracook object

   [date,time] = o.now;
   oo = set(oo,'title',[date,' @ ',time,' Plain Trace Data']);
   oo = set(oo,'comment',{'sin/cos data (random frequency & magnitude)'});
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
   oo = set(oo,'project','Sample Project');

      % provide plot defaults

   oo = category(oo,1,[-5 5],[0 0],'�');      % category 1 for x,y
   oo = category(oo,2,[-50 50],[0 0],'m�');   % category 2 for p

   oo = config(oo,'x',{1,'r',1});
   oo = config(oo,'y',{1,'b',1});
   oo = config(oo,'p',{2,'g',2});

      % paste object into shell and display cordoba info on screen

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

   oo = cordoba('simple');             % construct CORDOBA object
   oo = trace(oo,t,'x',x,'y',y,'p',p,'ux',ux,'uy',uy); 

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   oo = set(oo,'method','blrm');       % set processing method

      % provide title & comments for the caracook object

   [date,time] = o.now;
   oo = set(oo,'title',[date,' @ ',time,' Simple Trace Data']);
   oo = set(oo,'comment',{'sin/cos data (random frequency & magnitude)'});
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
   oo = set(oo,'project','Sample Project');

      % provide plot defaults

   oo = category(oo,1,[-5 5],[0 0],'�');      % category 1 for x,y
   oo = category(oo,2,[-50 50],[0 0],'m�');   % category 2 for p
   oo = category(oo,3,[-0.5 0.5],[0 0],'�');  % category 3 for ux,uy

   oo = config(oo,'x',{1,'r',1});
   oo = config(oo,'y',{1,'b',1});
   oo = config(oo,'p',{2,'g',2});
   oo = config(oo,'ux',{3,'m',3});
   oo = config(oo,'uy',{3,'c',3});

      % paste object into shell and display cordoba info on screen

   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
   paste(o,{oo});                      % paste new object into shell
end
function oo = NewCutlog(o)             % Create Cutlog sample trace    
   m = 1;  n = 1;  r = 1;              % rows x columns x repeats
   t = 0:1000;                         % crate a time vector
   sz = size(t);
   om = r*2*pi/max(t);                 % random circular frequency

   ax = (1+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
   ay = (1+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector

   ax = 10 + ax.*(1+0.2*t/max(t));     % biased & time variant
   ay = 8 + ay.*(1+0.2*t/max(t));      % biased & time variant

      % make a carma object with t,x,y,p, ux & uy

   oo = cut('cutlog');                 % construct CUT object
   oo = trace(oo,t,'ax',ax,'ay',ay); 

   oo = set(oo,'sizes',[m,n,r]);       % set data sizes

      % provide title & comments for the caralog object

   [date,time] = o.now;
   oo = set(oo,'title',[date,' @ ',time,'Cut Log Data']);
   oo = set(oo,'comment',{'phantasy data'});
   oo = set(oo,'date',date,'time',time);
   oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
   oo = set(oo,'project','LPC');

      % provide plot defaults

   oo = category(oo,1,[-5 5],[0 0],'mm/s2');  % category 1 for ax,ay

   oo = config(oo,'ax',{1,'r',1});
   oo = config(oo,'ay',{1,'b',1});

      % paste object into shell and display cordoba info on screen

   oo.tag = o.tag;                     % inherit tag from parent
   oo = balance(oo);                   % balance object
   paste(o,{oo});                      % paste new object into shell
end

function oo = Tools(o)                 % Add Tools Menu                
   setting(o,{'tools.sizes'},[1 1]);
   setting(o,{'tools.method'},'blcs');
   setting(o,{'tools.pitch'},'');
   setting(o,{'tools.system'},'');
   setting(o,{'tools.creator'},user(o,'name'));

   oo = mitem(o,'Tools');
   ooo = mitem(oo,'Provide Package Info File',{@PackageInfo});
end
function oo = Extras(o)                % Add Extras Menu               
   oo = mhead(o,'Extras',{},[],'visible','off');
end
function oo = PackageInfo(o)           % Provide Package Info File     
   caption = 'Provide Package Info File (.pkg)';
   path = fselect(o,'d','*.*',caption);
   if isempty(path)
      return
   end
   
   [dir,file,ext] = fileparts(path);
   title = [file,ext];              % recombine file&extension to name
   
      % extract package type
      
   station= '';  kappl = '';  vc = [];  vs = [];  
   try
      [package,typ,name,run,mach,station,kappl,vcut,vseek] = split(o,title);
   catch
      typ = '';                        % initiate an error
   end
      
   if isempty(package) || isempty(typ) || isempty(run) || isempty(mach)
      message(o,'Error: something wrong with package folder syntax!',...
                '(cannot import files)');
      return
   end
   
   [date,time] = o.filedate(path);
   project = context(o,'Project',path);     % extract project from path
   
      % create a package object and set package parameters
      
   oo = cut('pkg');
   oo.data = [];                       % make a non-container object
   oo.par.title = title;
   oo.par.comment = '(package)';
   oo.par.date = date;
   oo.par.time = time;
   oo.par.kind = typ;
   oo.par.project = project;
   oo.par.machine = mach;
   %oo.par.sizes = opt(o,{'tools.sizes',[1 1]});
   %oo.par.method = opt(o,{'tools.method','blcs'});
   %oo.par.pitch = opt(o,{'tools.pitch',''});
   %oo.par.system = opt(o,{'tools.system',''});
   
   oo.par.station = station;
   oo.par.kappl = kappl;
   oo.par.vcut = vcut;
   oo.par.vseek = vseek;

   oo.par.package = package;
   oo.par.creator = opt(o,{'tools.creator',user(o,'name')});
   oo.par.version = ['ATOM ',version(o)];
   
      % open a dialog for parameter editing
      
   oo = opt(oo,'caption',['Package Object: ',package]);
   oo = menu(oo,'Dialog');             % dialog for editing key parameters
   
   if isempty(oo)
      return
   end

      % update some settings
      
   setting(o,'tools.creator',get(oo,'creator'));
   
      % now write package file (.pkg)
      
   file = [FileName(oo,typ,date,time,package),'.pkg'];
   filepath = [path,'/',file];
   filepath = o.upath(filepath);
   
   oo = write(oo,'WritePkgPkg',filepath);
   if isempty(oo)
      o = Error(o,'could not write package file!');
      o = [];
      return
   end
   
   folder = o.either(context(o,'Path',path),title);
   [dir,fname,ext] = fileparts(folder);
   
   message(o,'Package info successfully written!',...
      ['Package: ',package],['Path: ',dir],['Folder: ',title],['File: ',file]);
   return
   
   function file = FileName(o,typ,date,time,pkg)  % Compose File Name             
      file = [upper(typ),date([1:2,4:6,8:11]),'-',time([1:2,4:5,7:8])];

      if isequal(o.type,'pkg')
         file = o.either(pkg,file);
         if ~isempty(typ)
            file = [file,'.',upper(typ)];
         end
      end
      file = Allowed(file);
   end
   function name = Allowed(name)       % Convert to Allowed File Name  
   %
   % ALLOWED   Substitute characters in order to have an allowed file name
   %
      allowed = '!$%&()=?+-.,#@������ ';
      for (i=1:length(name))
         c = name(i);
         if ('0' <= c && c <= '9')
            'ok';
         elseif ('A' <= c && c <= 'Z')
            'ok';
         elseif ('a' <= c && c <= 'z')
            'ok';
         elseif ~isempty(find(c==allowed))
            'ok';
         else
            name(i) = '-';                % substitute character with '-'
         end
      end
   end
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu Setup               
%
% VIEW   View menu setup
%
   setting(o,{'mode.signal'},'');      % init signal mode
   
   oo = mhead(o,'View');               % empty view menu header
   ooo = wrap(oo,'Signal');            % add Signal menu (wrapped)
   ooo = Overlay(oo);                  % add Overlay menu
   ooo = wrap(oo,'Config');            % add Config menu (wrapped)
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Grid');              % add Config menu
   ooo = wrap(oo,'Style');             % add Style menu (wrapped)
   ooo = menu(oo,'Variation');         % add Style menu
   ooo = wrap(oo,'Scale');             % add Scale menu (wrapped)
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Camera');            % add Camera menu
   ooo = menu(oo,'Toolbar');           % add Toolbar menu
end
function oo = Signal(o)                % Signal Menu Setup             
   oo = mhead(o,'Signal',{},'mode.signal');  % add header for Signal menu
end
function oo = Overlay(o)               % Overlay Setting               
   setting(o,{'mode.overlay'},0);      % init overlay mode
   oo = mitem(o,'Overlay',{},'mode.overlay');
   choice(oo,{{'Different Plots',0},{'Single Plot',1}},{});
end
function oo = Config(o)                % Config Menu Setup             
%
% CONFIG   Config menu setup
%
   o.profiler('Config',1);             % begin profiling
   
   setting(o,{'mode.config.show'},0);  % do not show all by default
   o = UpdateSettings(o);              % update settings and object options
   
   oo = mhead(o,'Config',{},'Config'); % empty header Config
%
% Rebuild the Config menu items
%
   ooo = menu(oo,'Types');             % add Types menu
   ooo = menu(oo,'Stream');            % add Stream configuration menu
   ooo = menu(oo,'Subplot');           % add Subplot configuration menu
   ooo = mitem(oo,'-');
   %ooo = Pick(oo);                    % obsoleted: add Pick menu
   ooo = mitem(oo,'Mode');
   oooo = mitem(ooo,'Show',{},'mode.config.show');
   choice(oooo,{{'Relevant',0},{'All',1}},{@RebuildCb});
   oooo = Control(ooo);
   
%  oooo = mitem(ooo,'Options',{},'control.options');
%  choice(oooo,{{'Package',1},{'Object',0}},{@RebuildCb});
   
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Category');          % add Category entries

   o.profiler('Config',0);             % end profiling
   return
   
   function oo = RebuildCb(o)          % Rebuild Callback              
      [~,po] = mseek(o,'Config');      % seek parent
      oo = Config(po);                 % rebuild Config menu
   end
end
function oo = Pick(o)                  % Pick Object's Config Options  
   oo = mitem(o,'Pick');
   ooo = mitem(oo,'Current Object''s Config',{@PickCb}); 
   return
   
   function o = PickCb(o)              % Pick Config from Current Object
      [~,cidx] = current(o);           % get current index
      co = data(o,cidx);               % current object with original opts
      
      bag = config(co);                % get current object's configuration
      o = config(o,bag);               % store configuration
      
      bag = category(co);              % get current object's categories
      o = category(o,bag);             % store categories
      
      bag = subplot(co);               % get current object's subplot
      o = subplot(o,bag);              % store subplot
      
      o = config(o,o);                 % refresh menu, rebuild & redraw
   end
end

function oo = Control(o)               % Control Option Mode           
   setting(o,{'control.options'},0);   % use children's options
   oo = mhead(o,'Control',{},'control.options');
   choice(oo,{{'by Shell',1},{'by Selected Object',0}},{});
end
function oo = Types(o)                 % Types Menu                    
   oo = mhead(o,'Type');
   bag = opt(o,{'config',struct('')});
   types = fields(bag);
   atype = active(o);
   for (i=1:length(types))
      typ = types{i};
      check = o.iif(o.is(typ,atype),'on','off');
      ooo = mitem(oo,typ,{@TypeCb typ},[],'check',check);
   end
   return
   
   function o = TypeCb(o)
      typ = arg(o,1);
      oo = type(o,typ);                % change object type
      active(o,oo);                    % make sure acxtive type = oo.type
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
         %setting(o,{'subplot.layout'},1);    % default 1 subplot coloumn layout
      end
      
         % As we have a valid configuration now let's do the actual work:
         % For each configured symbol create a menu entry for configuration
      
      atype = active(o);
      if isempty(atype)
         return
      end
      o = type(o,atype);               % change to active type
         
      for (j=1:config(o,inf))          % number of configured symbols
         sym = config(o,j);
         label = Label(o,sym);        % construct label
         [sub,col,cat] = config(o,sym);
         
            % entries are added if either category is non-zero, or
            % config mode enables all entries to be added
            
         if (cat || setting(o,'mode.config.show'))
            args = {sym,sub,col,cat};
            chk = o.iif(~isnan(sub)&&(sub > 0),'on','off');
            ooo = mitem(oo,label,{@Input,sym,sub,col,cat},[],'check',chk);
         end
      end
         
      %setting(o,'config',config(o));   % update settings
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
          oo = type(o,active(o));      % change type
          args = o.cons(sym,pars);     % construct updated args
          oo = config(oo,sym,pars);    % update parameters in config
          oo = subplot(oo,'Signal','');% invalidate
          o = config(o,oo);            % update settings
          
             % next we uncheck any signal menu item
             
          %o = active(o,{});           % empty signal selection
          change(o,'Signal');          % uncheck any Signal menu item
          refresh(o);
       catch
          msgbox('Bad parameters - ignore!');
       end
   end
end
function oo = Subplot(o)               % Subplot Menu                  
%
% SUBPLOT   Subplot menu setup
%
   atype = active(o);
   if ~isempty(atype)
      o = type(o,atype);
%     tag = ['subplot.',atype,'.layout'];
%     setting(o,{tag},1);              % default 1 subplot coloumn layout
      oo = subplot(o,'Layout',1);      % change subplot setting      

      subplot(o,{oo});                 % upload to settings
      tag = ['config.',atype,'.subplot.layout'];
      oo = mitem(o,'Subplot',{},tag);
      choice(oo,{{'n x 1',1},{'n x 2',2},{'n x 3',3}},{@SubplotCb});
   else
      oo = mitem(o,'Subplot',{},'');
   end
   return
   
   function o = SubplotCb(o)                                           
      oo = type(o,active(o));          % change to active typed object
      oo = subplot(oo,'Signal','');    % invalidate
      config(oo,oo);                   % change shell provided settings
      event(oo,'signal');              % update Signal menu
      refresh(o);                      % refresh screen
   end
end
function oo = Category(o)              % Category Menu                 
%
   %%%oo = pull(o);                    % pull actual shell object
   %%%typ = type(current(oo));         % current object's type
   %typ = CurrentType(o);
   atype = active(o);                  % get active type
   if isempty(atype)
      oo = o;                          % set out arg
      return
   end
   o = type(o,atype);
   [specs,limits,units]=category(o);   % get category parameters

   oo = o;                             % just in case if empty
   
   m = size(specs,1);
   for (i=1:m)
      if length(units) < i
         units{i} = '';
      end
      
      idx = sprintf('%g',i);
      oo = mitem(o,['Category ',idx,' [',units{i},']']);

%     tag = ['category.',atype,'.spec',idx];
      tag = ['config.',atype,'.category.spec',idx];
      spec = specs(i,:);
      setting(o,tag,spec);

%     ooo = mitem(oo,'Spec',{@CatCb},tag);
      ooo = mitem(oo,'Spec',{},tag);
      choice(ooo,{{'None',[0 0]},{'+/- 0.1',[-0.1 0.1]},...
         {'+/- 25',[-20 20]},{'+/- 25',[-25 25]},...
         {'+/- 100',[-100 100]},{'+/- 100',[-100 100]}},{@CatCb});

%     tag = ['category.',atype,'.limit',idx];
      tag = ['config.',atype,'.category.limit',idx];
      limit = limits(i,:);
      setting(o,tag,limit);

%     ooo = mitem(oo,'Limit',{@CatCb},tag);
      ooo = mitem(oo,'Limit',{},tag);
      choice(ooo,{{'None',[0 0]},{'+/- 30',[-30 30]},...
         {'+/- 50',[-50 50]},{'+/- 75',[-75 75]},...
         {'+/- 100',[-100 100]},{'+/- 150',[-150 150]},...
         {'+/- 200',[-200 200]},{'+/- 300',[-300 300]},...
         {'+/- 500',[-500 500]},{'+/- 800',[-800 800]},...
         {'+/- 1000',[-1000 1000]}},{@CatCb});

      ooo = mitem(oo,'Unit');
      oooo = mitem(ooo,['[',units{i},']']);
   end
   return
   
   function oo = CatCb(o)              % Category Callback             
      oo = current(o);       
      typ = type(oo);
      
      pid = get(gcbo,'parent');           % parent menu item ID
      tag = get(pid,'userdata');          % get parent's tag
      label = get(pid,'label');           % get label
      value = get(gcbo,'userdata');       % get value

      switch label
         case 'Spec'
%           l = length(['category.',typ,'.spec']);
            l = length(['config.',typ,'.category.spec']);
            idx = sscanf(tag(l+1:end),'%f');
%           specs = setting(o,['category.',typ,'.specs']);
            specs = setting(o,['config.',typ,'.category.specs']);
            specs(idx,:) = value;
%           setting(o,['category.',typ,'.specs'],specs);
            setting(o,['config.',typ,'.category.specs'],specs);

         case 'Limit'
%           l = length(['category.',typ,'.limit']);
            l = length(['config.',typ,'.category.limit']);
            idx = sscanf(tag(l+1:end),'%f');
%           limits = setting(o,['category.',typ,'.limits']);
            limits = setting(o,['config.',typ,'.category.limits']);
            limits(idx,:) = value;
%           setting(o,['category.',typ,'.limits'],limits);
            setting(o,['config.',typ,'.category.limits'],limits);
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
function oo = Style(o)                 % Style Menu                    
%
% STYLE   Style menu setup & handling (for plotting)
%
   setting(o,{'style.bullets'},0);
   setting(o,{'style.linewidth'},1);
   setting(o,{'style.labels'},'plain');
   setting(o,{'style.overlays'},'index');
   setting(o,{'style.title'},'package');
   setting(o,{'style.digits'},2);
   setting(o,{'style.legend'},false);
   setting(o,{'style.background'},'white');

   oo = mhead(o,'Style');
   
   ooo = mitem(oo,'Bullets',{},'style.bullets');
   choice(ooo,{{'Off',0},{'Black',-1},{'Colored',1}},{});
   
   ooo = mitem(oo,'Line Width',{},'style.linewidth');
   choice(ooo,1:7,{});
   
   ooo = mitem(oo,'Labels',{},'style.labels');
   choice(ooo,{{'Plain','plain'},{'Statistics','statistics'}},{});

   ooo = mitem(oo,'Overlays','','style.overlays');
   choice(ooo,{{'Index','index'},{'Time','time'}},{});

   ooo = mitem(oo,'Legend',{},'style.legend');
   choice(ooo,{{'Off',0},{'On',1}},{});

   ooo = mitem(oo,'Title',{},'style.title');
   choice(ooo,{{'Original','original'},{'Package','package'}},{});

   ooo = mitem(oo,'Background',{},'style.background');
   choice(ooo,{{'White','white'},{'Gray','gray'},{'Color','color'}},{@refresh});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Digits',{},'style.digits');
   choice(ooo,[0:4],{});
end
function oo = Variation(o)             % Variation Menu                
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
function oo = Scale(o)                 % Scale Menu                    
   setting(o,{'scale.xscale'},1);      % x-scaling factor
   oo = mhead(o,'Scale');
   ooo = mitem(oo,'Time Scale',{},'scale.xscale');
   choice(ooo,{{'Nanoseconds',1e9},{'Microseconds',1e6},...
               {'Miliseconds',1e3},{'Seconds',1},...
               {'Minutes',1/60},{'Hours',1/3600}},{});
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
   ooo = mitem(oo,'Spin',{@CamCb,'Spin'},'','enable','off');
end
function oo = CamCb(o)                 % Camera Callback               
   refresh(o,o);                       % refresh here
   
   oo = o;                             % init by default
   azel = opt(o,{'view.camera.azel',[-40 30]});
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
   setting(o,'view.camera.azel',azel);

   if o.is(arg(o,1),{'Left','Right','Up','Down'})
      refresh(o,o);                    % come back here for refresh
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

   % Auxillary Functions

function [typ,oo] = CurrentType(o)     % Get Current Type              
   oo = o;
   if container(o)
      curidx = control(o,'current');
      if (curidx ~= 0)
         oo = data(o,curidx);
      end
   end
   
   %typ = oo.type;
   typ = active(o);
end
function [o,typ] = UpdateSettings(o)   % Update Configuration Settings 
%
% UPDATE-SETTINGS   Update settings to support specific configuration
%                   category and subplot options
%
   [typ,oo] = CurrentType(o);
   
      % we got now the type of the current object. check if type specific
      % settings are nonempty, otherwise change settings and options

   options = control(o,'options');     % who controls options?
   list = {'config','category','subplot'};

   for (i=1:length(list))
      tag = [list{i},'.',typ];

      if (options)                     % if container determines config
         bag = setting(o,tag);
      else
         bag = [];                     % force fetch from kid object
      end
      
      if isempty(bag)
         bag = opt(oo,tag);
         if ~isempty(bag)
            setting(o,tag,bag);        % change setting
            o = opt(o,tag,bag);        % change option
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
   ooo = wrap(oo,'Objects');           % add Objects menu (wrapped)
   ooo = menu(oo,'Organized');         % add Organized menu
   ooo = mitem(oo,'-');
   ooo = wrap(oo,'Basket');            % add Basket menu (wrapped)
   %set(mitem(ooo,inf),'visible','off');
   ooo = mitem(oo,'-');
   ooo = wrap(oo,'Bias');              % add Bias menu (wrapped)
   ooo = menu(oo,'Filter');            % add Filter menu
   %ooo = menu(oo,'Scope');             % add Scope menu   
   %ooo = menu(oo,'Ignore');            % add Ignore menu
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Rotate');            % add Filter menu

   Title(o);                           % refresh title in figure bar
end
function oo = Organized(o)             % Add Organized Menu            
   setting(o,{'mode.organized'},'packages');
   oo = mitem(o,'Organized',{},'mode.organized');
   choice(oo,{{'Plain','plain'},{'Packages','packages'}},{@Rebuild});
   return
   
   function o = Rebuild(o)
      [~,po] = mseek(o,{'#','Select','Objects'});
      menu(po,'Objects');              % rebuild Objects menu
   end
end
function oo = Objects(o)               % Objects Menu                  
%
% OBJECTS   Setup Objects menu
%
   [iif,either] = util(o,'iif','either');   % need some utils
   packages = isequal(opt(o,'mode.organized'),'packages'); 
   
   if ~container(o)
      oo = o;
      return                           % no Traces menu if no container!
   end

   n = data(o,inf);                    % number of objects
   control(o,{'current'},iif(n,1,0));  % provide a default value
%
% Locate Traces header and get the number of children. If not found
% we create the Traces menu header   
%
   oo = mhead(o,'Objects','','Objects');
%
% add object entries to the Objects menu
%
   [~,cidx] = current(o);

      % start with container selection menu item
      
   label = either(get(oo,'title'),'Package');
   chk = iif(cidx==0,'on','off');
   ooo = mitem(oo,label,{@Activate,0},0,'check',chk);
   ooo = mitem(oo,'-');
   
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
         
      ooo = mitem(oi,label,{@Activate,i},i,'check',chk);
      if isequal(oi.type,'pkg')
         ooo = mitem(oi,'-');          % separator after package object
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
   
   title = get(o,{'title',title});
   set(figure(o),'name',title);        % update figure title
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
   ooo = menu(oo,'Kind');              % add Kind menu
end
function oo = Kind(o)                  % Add Kind Menu                 
%
% KIND   Setup kind selection menu
%
   setting(o,{'basket.kind'},'*');     % all kinds selected by default
   
      % for each different kind add a menu item
      
   choices = {{'All Kinds','*'}};
   list = Kinds(o);
   if ~isempty(list)
      choices{end+1} = {};
      for (i=1:length(list))
         name = list{i};
         choices{end+1} = {name,name};
      end
   end
   oo = mhead(o,'Kind','','basket.kind');
   choice(oo,choices,{@KindCb});
   return
   
   function o = KindCb(o)
      oo = current(o);                 % get current object
      dynamic(o,oo);                   % update all dynamic menu items
      refresh(o);
   end
   function list = Kinds(o)            % Get List of Kinds             
      list = {};
      if container(o)
         for (i=1:length(o.data))
            oo = o.data{i};
            kind = get(oo,'kind');
            if ~isempty(kind) && ~corazon.is(kind,list)
               list{end+1} = kind;
            end
         end
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
   setting(o,{'mode.bias'},'absolute');% default bias mode is 'drift'

   oo = mhead(o,'Bias','','mode.bias');
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
function oo = Rotate(o)                % Rotate Menu                   
   setting(o,{'select.rotate'},1);     % rotation on by default
   
   oo = mitem(o,'Rotate',{},'select.rotate');
   ooo = choice(oo,{{'Off',0},{'Compensate Facette Rotation',1}},{@Invalidate});
   
   function o = Invalidate(o)
      oo = current(o);
      oo.data.a_x = [];
      oo.data.a_y = [];
      oo.data.v_x = [];
      oo.data.v_y = [];
      oo.data.s_x = [];
      oo.data.s_y = [];
      current(o,oo);                 % store back
   end
end
%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu Management          
%
% PLOT   Setup & handle Plot menu items
%
   oo = mitem(o,'Stream',{@plot,'Stream'});
   oo = mitem(o,'-');
   oo = mitem(o,'FFT Linear',{@plot,'FftLin'});
   oo = mitem(o,'FFT Logarithmic',{@plot,'FftLog'});
   
%  oo = mitem(o,'Special');
%  oc = cast(oo,'cordoba');            % cast to cordoba object
%  ooo = plot(oc,'Setup');             % setup Plot menu
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
%  ooo = Geometry(oo);                 % add Geometry menu
   ooo = analyse(oo,'Setup');          % add analyse menu
   plugin(oo,'cordoba/menu/Analysis'); % plug point
end
function o = Geometry(o)               % Geometry Menu                 
   types = arg(o,1);
   if ~isempty(types) && ~o.is(type(current(o)),types)
      return                           % Geometry disabled for current type
   end
   
   setting(o,{'analysis.geometry.raster'},[5 5]);
   setting(o,{'analysis.geometry.deltoid'},0.4);
   setting(o,{'analysis.geometry.path'},0.1);
   setting(o,{'analysis.geometry.zigzag'},0.1);
   setting(o,{'analysis.geometry.averaging'},0);
   setting(o,{'analysis.geometry.centering'},0);

   oo = mhead(o,'Geometry');
   ooo = mitem(oo,'Surface Plot');
   oooo = mitem(ooo,'X',{@invoke,'menu','GeoCb','Surf','X'});
   oooo = mitem(ooo,'Y',{@invoke,'menu','GeoCb','Surf','Y'});
   ooo = mitem(oo,'Residual Plot');
   oooo = mitem(ooo,'X',{@invoke,'menu','GeoCb','Residual','X'});
   oooo = mitem(ooo,'Y',{@invoke,'menu','GeoCb','Residual','Y'});
   ooo = mitem(oo,'Fitted Plot');
   oooo = mitem(ooo,'X',{@invoke,'menu','GeoCb','Fitted','X'});
   oooo = mitem(ooo,'Y',{@invoke,'menu','GeoCb','Fitted','Y'});
   ooo = mitem(oo,'Arrow Plot',{@invoke,'menu','GeoCb','Arrow'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Matrix Path',{@invoke,'menu','GeoCb','Path'});
   ooo = mitem(oo,'Zigzag Path',{@invoke,'menu','GeoCb','Zigzag'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Averaging','','analysis.geometry.averaging');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Centering','','analysis.geometry.centering');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Raster','','analysis.geometry.raster');
   choice(ooo,{{'[1 1]',[1 1]},{'[2 2]',[2 2]},{'[3 3]',[3 3]},...
     {'[4 4]',[4 4]},{'[5 5]',[5 5]},{'[10 10]',[10 10]},...
     {'[20 20]',[20 20]},{'[50 50]',[50 50]}},'');
   ooo = mitem(oo,'Arrow Style','','analysis.geometry.deltoid');
   choice(ooo,[0.2:0.1:1]);
   ooo = mitem(oo,'Path Visibility','','analysis.geometry.path');
   choice(ooo,[0:0.1:0.2,0.5,1]);
   ooo = mitem(oo,'Zig-Zag Visibility','','analysis.geometry.zigzag');
   choice(ooo,[0:0.1:0.2,0.5,1]);
end
function oo = GeoCb(o)                 % Geometry Callback             
   oo = o;                             % copy  o to out arg before change
   o = with(o,{'style','view','select'});      % unpack some options
   
   cls(o);                             % clear screen
   plot(o);                            % analyse object
end
function o = Capability(o)             % Overview of Capability Values 
   types = arg(o,1);
   if ~isempty(types) && ~o.is(type(current(o)),types)
      return                           % Geometry disabled for current type
   end
   
   oo = mitem(o,'Capability');
   %set(mitem(oo,inf),'enable',onoff(o,{'pln','smp'}));
   ooo = mitem(oo,'Actual Cpk',{@CapaCb,'stream','Actual'});
   ooo = mitem(oo,'Fictive Cpk',{@CapaCb,'fictive','Fictive'});
   return
end
function o = CapaCb(o)                 % Capability Callback           
   mode = arg(o,1);
   label = arg(o,2);

   refresh(o,o);                       % use this function for refresh

   typ = type(current(o));
   if ~o.is(typ,{'pln','smp'})
      menu(current(o),'About');
      return
   end
   
   o = opt(o,'basket.type',typ);
   o = opt(o,'basket.collect','*'); % all traces in basket
   o = opt(o,'basket.kind','*');    % all kinds in basket
   list = basket(o);
   if (isempty(list))
      message(o,'No plain or simple objects in basket!');
   else
      hax = cls(o);
      n = length(list);
      for (i=1:n)
         oo = list{i};
         oo = opt(oo,'mode.cook',mode);  % cooking mode
         oo = opt(oo,'bias','absolute'); % in absolute mode

         [sub,col,cat] = config(oo,'x');
         [spec,limit,unit] = category(oo,cat);

         x = cook(oo,'x');
         y = cook(oo,'y');

         [Cpk,Cp,sig,avg,mini,maxi] = capa(oo,x(:)',spec);
         Cpkx(i) = Cpk;
         [Cpk,Cp,sig,avg,mini,maxi] = capa(oo,y(:)',spec);
         Cpky(i) = Cpk;
      end

      kind = o.assoc(oo.type,{{'pln','Plain'},{'smp','Simple'}});
      subplot(211);
      plot(1:n,Cpkx,'r',  1:n,Cpkx,'k.');
      title(['Overview: ',label,' Cpk(x) of ',kind,' Objects']);
      ylabel('Cpk(x)');
      set(gca,'xtick',1:n);

      subplot(212);
      plot(1:n,Cpky,'b',  1:n,Cpky,'k.');
      title(['Overview: ',label,' Cpk(y) of ',kind,' Objects']);
      ylabel('Cpk(y)');
      set(gca,'xtick',1:n);
   end
end

%==========================================================================
% Info Menu
%==========================================================================

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
   
      % get other key parameters
   
   machine = get(oo,{'machine','[]'});
   system = get(oo,{'system','[]'});
   sizes = get(oo,{'sizes',''});
   if length(sizes) < 1
      sizes = '[1 1]';
   elseif length(sizes) < 2
      sizes = sprintf('[%g 1]',sizes(1));
   elseif length(sizes) == 2
      sizes = sprintf('[%g,%g]',sizes(1),sizes(2));
   elseif length(sizes) >= 3
      sizes = sprintf('[%g,%g,%g]',sizes(1),sizes(2),sizes(3));
   end
   method = get(oo,{'method',''});
   pitch = get(oo,{'pitch',''});
   if length(pitch) < 1
      pitch = '';
   elseif length(pitch) < 2
      pitch = sprintf('[%g %g]',pitch(1),pitch(1));
   elseif length(pitch) >= 2
      pitch = sprintf('[%g,%g]',pitch(1),pitch(2));
   end
   
      % setup virtual comment for message display
      
   comment = {};
   if ischar(text)
      text = {text};                   % embed text in a list
   end
   
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
   comment{end+1} = ['Project: ',project,', Package: ',package,', Kind: ',kind];
   comment{end+1} = '';
   comment{end+1} = ['Machine: ',machine,', System: ',system];
   comment{end+1} = ['Sizes: ',sizes,', Method: ',method,', Pitch: ',pitch];
   comment{end+1} = '';
   comment{end+1} = ['Version: ',version,', Creator: ',creator];

   message(oo,title,comment);
   refresh(o,o);                       % come back here for refresh
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
   kind = either(get(o,'kind'),'');
   date = either(get(o,'date'),'');
   time = either(get(o,'time'),'');
   project = either(get(o,'project'),'');
   package = either(get(o,'package'),'');
   version = either(get(o,'version'),'');
   creator = either(get(o,'creator'),'');

   station = either(get(o,'station'),'');
   kappl = either(get(o,'kappl'),'');
   vc = sprintf('%g',either(get(o,'vcut'),0));
   vs = sprintf('%g',either(get(o,'vseek'),0));
   
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
   prompts = {'Title','Comment','Date','Time','Project','Package','Kind',...
              'Station','Kappl','Vcut [m/s]','Vseek [mm/s]','Version','Creator'};
   values = {title,text,date,time,project,package,kind,...
             station,kappl,vc,vs,version,creator};
   dims = ones(length(values),1)*[1 50];  dims(2,1) = 2;
   
   values = inputdlg(prompts,caption,dims,values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
      % set object parameters
      
   oo = o;
   
   date = values{3};  time = values{4};
   oo = set(oo,'date',date,'time',time);
   
   project = values{5};  package = values{6};  kind = values{7};  
   oo = set(oo,'project',project,'package',package,'kind',kind);
   
   station = values{8};  
   oo = set(oo,'station',station);

   kappl = values{9};  
   oo = set(oo,'kappl',kappl);
   
   vcut = values{10};  
   vcut = sscanf(vcut,'%f');
   oo = set(oo,'vcut',vcut);

   vseek = values{11};  
   vseek = sscanf(vseek,'%f');
   oo = set(oo,'vseek',vseek);

      % set ttle and comment
      
   title = either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);   % right trim
   end

   comment{end+1} = sprintf('Station: %s, Kappl: %s',station,kappl);
   comment{end+1} = sprintf('Vcut = %g m/s, Vseek = %g mm/s',vcut,vseek);

   oo = set(oo,'title',title,'comment',comment);
   
   version = values{12};  creator = values{13};
   oo = set(oo,'version',version,'creator',creator);
end
