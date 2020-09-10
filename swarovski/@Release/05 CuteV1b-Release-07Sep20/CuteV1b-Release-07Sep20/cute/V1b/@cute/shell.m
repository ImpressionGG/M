function oo = shell(o,varargin)        % CUTE shell                    
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@Export,@View,...
                      @Bias,@Plot,@PlotCb,@Analysis,@Study);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = View(o);                       % add View menu
   oo = Select(o);                     % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analyse(o);                    % add Analyse menu
   oo = Study(o);                      % add Study menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Tiny(o)                   % Tiny Shell Setup              
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = control(o,{'dark'},1);          % run in non dark mode

   o = provide(o,'par.title','Cute Toolbox');
   o = provide(o,'par.comment',{'Cutting Process Data Analysis'});
   
   o = opt(o,{'fontsize.title'},20);
   o = opt(o,{'fontsize.comment'},12);
   
      % provide a dirty counter to support cache control of brewed data
      % incrementing this dirty counter causes updating re-brewed data 
      
   o = opt(o,{'brew.dirty'},0);        % init dirty counter for brewed data
   
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'View','Plot','Analyse','Study'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = New(oo);                      % add New menu
   ooo = Import(oo);                   % add Import menu
   ooo = wrap(oo,'Export');            % add (wrapped) Export menu
   ooo = Tools(oo);
   ooo = Extras(oo);
end
function oo = New(o)                   % New Menu                      
   oo = mseek(o,{'New'});
   %ooo = mitem(oo,'-');
   %ooo = mitem(oo,'Stuff');
   %oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   %ooo = mitem(oo,'Cute');
   %oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Package',{@CollectCb});
   ooo = mitem(oo,'-');

%  ooo = mitem(oo,'Measurement Plan (.xlsx)',{@ImportCb,'ReadMplXlsx','.xlsx',@cute});
   ooo = mitem(oo,'Package Info (.xlsx)',{@ImportCb,'ReadPkgXlsx','.xlsx',@cute});
   ooo = mitem(oo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@cute});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Cutting Process Data (.csv)',{@ImportCb,'ReadCutCsv','.csv',@cute});
   ooo = mitem(oo,'Cutting Scope Data (.csv)',{@ImportCb,'ReadScpCsv','.csv',@cute});
         enable(ooo,false);
   ooo = mitem(oo,'Article (.art)',{@ImportCb,'ReadArtArt','.art',@cute});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Measurement Plan (.xlsx)',{@ImportCb,'ReadMplXlsx','.xlsx',@cute});
   
   %ooo = mitem(oo,'General');
   %oooo = mitem(ooo,'General Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@cute});
   %oooo = mitem(ooo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@cute});

   %ooo = mitem(oo,'Stuff');
   %oooo = mitem(ooo,'Text File (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   
   plugin(oo,'cute/shell/Import');     % plug point
   return

   function o = ImportCb(o)            % Import Log Data Callback      
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      
      [ok,duplicate] = integrity(o);
      if ~ok
         message(o,'Object import denied',...
            [{'reason: duplicate packages or objects (fix first):'},...
             duplicate]);
         oo = o;
         return
      end
    
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
   function o = CollectCb(o)           % Collect All Files of Folder   
      collect(o,{})                    % reset collection config
      table0 = {{@read,'cute','ReadPkgPkg','.pkg'},...
                {@read,'cute','ReadCutCsv', '.csv'}};
      collect(o,{},table0);            % only default table

      list = collect(o);               % collect files in directory
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   
   %ooo = mitem(oo,'Stuff');
   %oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   %ooo = mitem(oo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@cute});
   ooo = mitem(oo,'Package Info (.pkg)',{@ExportCb,'WritePkgPkg','.pkg',@cute});
   enable(ooo,type(current(o),{'pkg'}));
   return

   function oo = ExportCb(o)           % Export Log Data Callback      
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         co = cast(oo);                % casted object
         oo = export(co,drv,ext);      % export object to file
         
         if ~isempty(oo) && type(oo,{'pkg'})
            comment = {['file: ',get(oo,{'file',''})],...
                       ['dir: ',get(oo,{'dir',''})]};
            message(o,'Package export completed!',comment);
         end
      end
   end
end
function oo = Tools(o)                 % Add Tools Menu                
   setting(o,{'tools.sizes'},[1 1]);
   setting(o,{'tools.method'},'');
   setting(o,{'tools.pitch'},'');
   setting(o,{'tools.system'},'');
   setting(o,{'tools.creator'},user(o,'name'));

   oo = mseek(o,{'Tools'});
   %ooo = mitem(oo,'Provide Package Info File',{@PackageInfo});
   %ooo = mitem(oo,'-');
   ooo = ClearCache(oo);               % add ClearCache menu Item
end
function oo = Extras(o)                % Extras Menu Items             
   setting(o,{'study.menu'},false);    % provide setting
   
   oo = mseek(o,{'Extras'});
   ooo = mitem(oo,'Study Menu',{},'study.menu');
         check(ooo,{@StudyMenu});
   return
   function o = StudyMenu(o)
      menu = opt(o,'study.menu');
      if (menu)
         rebuild(o);
      else
         rebuild(o);
      end
   end
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
   
   [date,time] = filedate(o,path);
   project = context(o,'Project',path);     % extract project from path
   
      % create a package object and set package parameters
      
   oo = cute('pkg');
   oo.data = [];                       % make a non-container object
   oo.par.title = title;
   oo.par.comment = '(package)';
   oo.par.date = date;
   oo.par.time = time;
   oo.par.kind = typ;
   oo.par.project = project;
   oo.par.machine = mach;
   
   oo.par.station = station;
   oo.par.kappl = kappl;
   oo.par.vcut = vcut;
   oo.par.vseek = vseek;

   oo.par.package = package;
   oo.par.creator = opt(o,{'tools.creator',user(o,'name')});
   oo.par.version = [upper(class(o)),' ',version(o)];
   
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
function oo = ClearCache(o)            % Clear All Caches              
   oo = mitem(o,'Clear All Caches',{@ClearCacheCb});
end
function o = ClearCacheCb(o)           % Clear Cache Calback           
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      o.data{i} = cache(oo,[]);     % clear cache (soft)
   end
   push(o);
   refresh(o,{});
   message(o,'Caches of all objects have been cleared!');
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
   ooo = Heading(oo);
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Style');             % add plot style sub menu
   ooo = Ellipse(oo);                  % add Ellipse menu items
   
   plugin(o,'cute/shell/View');        % plug point
end
function oo = Heading(o)               % Set Heading Text              
   setting(o,{'view.heading'},'');
   
   oo = mitem(o,'Heading',{},'view.heading');
   charm(oo,{});
end
function oo = Ellipse(o)
   setting(o,{'view.ellipse'},1);      % plot ellipse visualization
   
   oo = mitem(o,'Ellipse',{},'view.ellipse');
   choice(oo,{{'Off',0},{'On',1}},{});
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu

   plugin(o,'cute/shell/Select');      % plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu

   plugin(o,'cute/shell/Plot');       % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu                  
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'cute/shell/Analyse');    % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'cute/shell/Study');      % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Cute Class: Version ',version(cute)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit cute/version');

   plugin(o,'cute/shell/Info');       % plug point
end

