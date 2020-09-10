function oo = kefalon(o,varargin)      % Kefalon Project Plugin                 
%
% KEFALON   Kefalon Project plugin
%
%              project(cordoba)        % register plugin
%
%              oo = project(o,func)    % call local project function
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORDOBA, PLUGIN, SAMPLE, BASIS, BMC
%
   if (nargin == 0)
      o = pull(corazon);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Plugin,...
                       @Root,@Test,@NewRun);
   oo = gamma(oo);
end

%==========================================================================
% Plugin Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   o = pull(o);                        % non-empty if any open shell
   if ~isempty(o)                      % any open shell?
      rebuild(o);                      % rebuild menu
   end
end
function o = Register(o)               % Plugin Registration           
   if o.is(class(o),'babasim')
      name = 'babasim';
      plugin(o,[name,'/shell/Root'],{mfilename,'Root'});
      plugin(o,[name,'/shell/Test'],{mfilename,'Test'});
   else
      name = class(o);
      plugin(o,[name,'/shell/Plugin'],{mfilename,'Plugin'});
   end
end

%==========================================================================
% Plugin Menu Plugins
%==========================================================================

function o = Plugin(o)                 % Plugin Menu Item Setup        
   oo = Root(o);
   oo = Test(o);
end
function o = Root(o)
   oo = mitem(o,'Log Root',{@LogRoot});
end
function o = Test(o)
   event(o,'rebuild.test',o);          % register on 'rebuild.test' event
   oo = Project(o);                    % add Project sub menu
   oo = Package(o);                    % add Package sub menu
   oo = Run(o);                        % add Run sub menu
end
function o = Project(o)                % add Project Menu              
   logroot = Get(o,'logroot');
   enable = o.iif(isempty(logroot),'off','on'); 

   oo = mhead(o,'Project',{},[],'enable',enable);
   ooo = mitem(oo,'New Project',{@NewProject});
   ooo = mitem(oo,'Open Project',{@OpenProject});
   ooo = mitem(oo,'Close Project',{@CloseProject});
end
function o = Package(o)                % add Package Menu              
   logroot = Get(o,'logroot');
   kind = Get(o,'kind');
   enable = o.iif(isempty(logroot)||isempty(kind),'off','on'); 

   oo = mhead(o,'Package',{},[],'enable',enable);
   ooo = mitem(oo,'New Package',{@NewPackage});
end
function o = Run(o)                    % add Run Menu                  
   logroot = Get(o,'logroot');
   enable = o.iif(isempty(logroot),'off','on'); 

   oo = mhead(o,'Run',{},[],'enable',enable);
   ooo = mitem(oo,'Plain Test',{@invoke,@kefalon,@NewRun,'pln','Plain'});
   ooo = mitem(oo,'Simple Test',{@invoke,@kefalon,@NewRun,'smp','Simple'});
   ooo = mitem(oo,'Vibration Test',{@invoke,@kefalon,@NewRun,'vib','Vibration'});
   ooo = mitem(oo,'BMC Test',{@invoke,@kefalon,@NewRun,'bmc','BMC'});
end

   % callback functions
   
function o = LogRoot(o)                % Select Log Root               
   path = fselect(o,'d','*.*','Choose Log Root Folder ''[log]''!');
   if isempty(path)
      return
   end
   
   [dir,file] = fileparts(path);
   path = o.upath(path);
   
   if ~isequal(file,'[log]')
      message(o,'Error: log root folder name must be ''[log]''!');
      return
   end
   
   machine = context(o,'Machine',path);
   if isempty(machine)
      machine = new(o,'Machine');      % phantasy machine number
   end

   o = Change(o,'logroot',path);       % set log root path
   o = Change(o,'machine',machine);    % set log root path
   o = Change(o,'project','');         % no open project
   o = Change(o,'kind','');            % reset test type
   o = Change(o,'test','');            % reset last test
   o = Change(o,'path','');            % reset log path
   o = Change(o,'run',0);              % reset run number
   
   Discover(o);                        % discover highest run number
   o = Rebuild(o);                     % rebuild plugin menus
   Refresh(o);
end
function o = NewProject(o)             % Create New Project            
   oo = dialog(o,'Project');           % 'New Project' dialog
   if isempty(oo)
      return                           % dialog cancel
   end
   
   logroot = Get(o,'logroot');
   project = get(oo,'project');
   directory = [logroot,'/[',project,']'];
   
   if exist(directory) == 7
      message(o,['Error: project ''',project,''' exists already!'],...
                ['Path: ',directory]);
      return
   end
   
   ok = mkdir(directory);
   if ~ok
      message(o,['Error: cannot create project folder [',project,']!'],...
                ['Path: ',directory]);
      return
   end
   
   Set(o,'project',project);
   Set(o,'kind','');                   % reset kind
   Set(o,'directory',directory);       % set project directory
   Set(o,'package','');                % reset package
   Set(o,'path','');                   % reset path
   Refresh(o);
   Rebuild(o);
end
function o = OpenProject(o)            % Open Project                  
   directory = fselect(o,'d','*.*','Choose Project Folder ''[...]''!');
   directory = o.upath(directory);
   if isempty(directory)
      return                           % dialog cancel
   end
   
      % extract project from path context
      
   project = context(o,'Project',directory);
   if isempty(project)
      msg1 = 'Error: selected path does not contain a project folder!';
      msg2 = 'project folders must be enclosed by [...]';
      message(o,msg1,msg2,['folder: ',o.upath(path)]);
      return
   end
   if isequal(project,'log')
      message(o,'Error: log root [log] cannot be selected as project folder!');
      return
   end

      % check project target folder

   [~,file,ext] = fileparts(directory);
   folder = [file,ext];
   if length(folder) > 0 && folder(1) == '#'
      message(o,'Error: folder selection not allowed!',...
                'machine folder (#...) not allowed for project folder selection!',...
                ['Path: ',directory]);
      return
   end
   if length(folder) > 0 && folder(1) == '@'
      message(o,'Error: folder selection not allowed!',...
                'package folder (@...) not allowed for project folder selection!',...
                ['Path: ',directory]);
      return
   end
   
      % everything is ok - change settings
      
   Set(o,'project',project);
   Set(o,'kind','');                   % reset kind
   Set(o,'directory',directory);       % set project directory
   Set(o,'package','');                % reset package
   Set(o,'path','');                   % reset path
   Refresh(o);
   Rebuild(o);
end
function o = CloseProject(o)           % Close Project                 
   Set(o,'project','');                % empty project
   Set(o,'kind','');                   % reset kind
   Set(o,'directory','');              % reset project directory
   Set(o,'package','');                % reset package
   Set(o,'path','');                   % reset path
   Refresh(o);
end
function o = NewPackage(o)             % Create New Package            
   logroot = Get(o,'logroot');
   if isempty(logroot)
      Error(o,'log root not defined!');
      o = [];
      return
   end

   run = Get(o,{'run',0}) + 1;         % new run number
   Set(o,'run',run);                   % store updated run number
   kind = Get(o,{'kind','any'});
   
      % copy machine, project and run parametewrs to parent object
      % which is used to inherit parameters for package creation

   machine = Get(o,'machine');
   project = Get(o,'project');
   run = Get(o,'run');
   
   po = set(o,'machine',machine,'project',project,'run',run);

      
      % create new package
   
   [title,comment] = carashit.lorem;
   po = opt(po,'title',title);
   po = opt(po,'comment',comment);
   
   oo = new(po,'Package',kind);
   if isempty(oo)
      o = [];
      return
   end
   
      % store package and name of new package
   
   [package,~,name] = split(oo);
   Set(o,'name',name);
   Set(o,'package',package);
   
   if isempty(oo)
      o = Error(o,'cannot create folder!',fullpath);
      return
   end      

      % check for existing package folder, otherwise need to create folder
      
   [~,~,path] = Folder(oo);         % get log directory path

      % check if folder to write package info exists already
      % otherwise we need to create

   if exist(path) ~= 7                 % folder does not exist
      ok = mkdir(path);                % create folder
      if ~ok
         o = Error(o,'cannot create folder!',path);
         return
      end
   end

      % write package file

   filepath = [path,'/',File(oo),'.pkg'];
   
   oo = WritePackage(oo,filepath);     % write package
   if isempty(oo)
      o = Error(o,'could not write package file!',filepath);
      o = [];
      return
   end

      % update administrative information

%   oo.tag = o.tag;                     % inherit tag from parent
%   oo = balance(oo);                   % balance object
%   paste(o,{oo});                      % paste new object into shell

   o = Change(o,'run',run);            % update run number
   o = Change(o,'path',path);
   
   o = var(o,'title',name);
   o = var(o,'comment',get(oo,'comment'));
   Refresh(o);
end
function o = NewRun(o)                 % Run Plain Test                
   kind = arg(o,1);                    % kind of test
   name = arg(o,2);                    % name of test
   
   o = opt(o,'caption',[name,' Test Description (Type ',upper(kind),')' ]);

   oldkind = Get(o,{'kind',''});       % get old kind parameter
   if ~isequal(kind,oldkind)           % if kind has changed
      o = Change(o,'kind',kind);       % mind kind parameter
      oo = NewPackage(o);              % create new package
      if isempty(oo)
         return                        % dialog cancelation
      end
      title = var(oo,'title');
      comment = var(oo,'comment');
   else
      [title,comment] = carashit.lorem;
      o = set(o,'title',title);
      o = set(o,'comment',comment);
      oo = dialog(o,'Simple');
      if isempty(oo)
         return                        % dialog cancelation
      end
      title = get(oo,'title');
      comment = get(oo,'comment');
   end

   path = Get(oo,'path');
   filepath = [path,'/',File(oo),'.dat'];

   machine = Get(oo,'machine');
   package  = Get(oo,'package');
   project = Get(oo,'project');
   
   oo = set(oo,'project',project,'machine',machine,'package',package);
   
   switch kind
      case 'pln'                 % plain type
         caption = 'Plain test';
         oo = Create(oo,'Plain',path,title,comment);
      case 'smp'                 % simple type
         caption = 'Simple test';
         oo = Create(oo,'Simple',path,title,comment);
      case 'bmc'                 % simple type
         caption = 'BMC  test left/right';

         oo = set(oo,'system','L');
         oo = Create(oo,'Bmc',path,[title,' - L'],comment);
         pause(1);               % otherwise same file name
         
         oo = set(oo,'system','R');
         oo = Create(oo,'Bmc',path,[title,' - R'],comment);
      case 'vib'                 % simple type
         caption = 'vibration test series';

         oo = set(oo,'system','L');
         oo = Create(oo,'Vuc',path,[title,' - UC/L'],comment);
         pause(1);               % otherwise same file name
         
         oo = set(oo,'system','R');
         oo = Create(oo,'Vuc',path,[title,' - UC/R'],comment);
         pause(1);               % otherwise same file name
         
         oo = set(oo,'system','L');
         oo = Create(oo,'Vsc',path,[title,' - SC/L'],comment);
         pause(1);               % otherwise same file name
         
         oo = set(oo,'system','R');
         oo = Create(oo,'Vsc',path,[title,' - SC/R'],comment);
   end
   
   [dir,file,ext] = fileparts(filepath);
   test = [file,ext];
   Set(o,'test',test);
   
   o = Rebuild(o);               % rebuild plugin menus
   o = Refresh(o);
   
   Completed(oo,caption);
   return
   
   function oo = Create(o,mode,path,title,comment)
      oo = new(o,mode);
      oo = set(oo,'title',title,'comment',comment);

      fpath = [path,'/',File(oo),'.dat'];
      oo = write(oo,'WriteGenDat',fpath);
      oo = var(oo,'path',fpath);
   end
   function o = Completed(o,text)      % Show 'Completed' Message      
      [~,fname,fext] = fileparts(var(o,'path'));
      o = opt(o,'style.background','gray');
      message(o,[o.capital(text),' completed!'],...
              ['Package: ',get(o,'package'),'.',upper(o.type)],...
              ['File: ',fname,fext]);
   end
end

%==========================================================================
% Deal with Folders and File Name
%==========================================================================

function [folder,pkg,path] = Folder(o) % Get Package Folder Name       
   machine = Get(o,'machine');
   kind = Get(o,'kind');
   run = Get(o,{'run',0});
   name = Get(o,{'name',''});
   name = Allowed(name);               % make an allowed name
   
   pkg = '';  folder = '';
   if ~isempty(machine) && run > 0 && ~isempty(kind)
      machine = ['0000',machine];
      pkg = sprintf('@%s.%g',machine(end-3:end),run);
      if isempty(name) && ~isempty(kind)
         folder = [pkg,'.',upper(kind)];
      elseif ~isempty(kind)
         folder = [pkg,'.',upper(kind),' ',name];
      end
   end
   
   project = Get(o,{'project',''});
   path = '';
   if isempty(project)
      logroot = Get(o,{'logroot','.'});
      if ~isempty(folder)
         path = [logroot,'/',upper(kind),'/',folder];
      end
   else
      directory = Get(o,{'directory',''});
      if ~isempty(directory) && ~isempty(folder)
         path = [directory,'/',folder];
      end
   end
end
function file = File(o)                % Compose File Name             
   [date,time] = o.now;
   kind = Get(o,{'kind','any'});
   date = Get(o,{'date',date});
   time = Get(o,{'time',time});
   file = [upper(kind),date([1:2,4:6,8:11]),'-',time([1:2,4:5,7:8])];
   %file = o.now(date,time);
   
   if isequal(o.type,'pkg')
      [~,package] = Folder(o);
      file = o.either(package,file);
      if ~isempty(kind)
         file = [file,'.',upper(kind)];
      end
   end
   file = Allowed(file);
end
function name = Allowed(name)          % Convert to Allowed File Name  
%
% ALLOWED   Substitute characters in order to have an allowed file name
%
   allowed = '!$%&()=?+-.,#@�����ܰ''" ';
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

%==========================================================================
% Deal With Settings
%==========================================================================

function value = Get(o,tag)            % Get a KEFALON parameter       
%
% GET   Get KEFALON setting
%
%          value = Get(o,tag)
%          value = Get(o,{tag,default})
%
   if iscell(tag)
      value = setting(o,{['kefalon.',tag{1}],tag{2}});
   else
      value = setting(o,['kefalon.',tag]);
   end
end
function Set(o,tag,value)              % Set a KEFALON parameter       
%
% SET   Set KEFALON setting
%
%          oo = Set(o,tag,value)
%          oo = Set(o,{tag},default)
%
   if iscell(tag)
      setting(o,{['kefalon.',tag{1}]},value);
   else
      setting(o,['kefalon.',tag],value);
   end
end
function o = Change(o,tag,value)       % Change Shell Object Parameter 
   Set(o,tag,value);                   % change parameter value
end

%==========================================================================
% Refresh Screen & Rebuild Plugin Menu
%==========================================================================

function o = Refresh(o)                % Refresh Shell Info            
%
% STATUS   Refresh title and comment of shell object in order to display
%          current status.
%
   iif = @o.iif;                       % short hand
   o = set(o,'title','Log File Management');
   
   logroot = Get(o,'logroot');
   machine = Get(o,'machine');
   run = Get(o,{'run',0});
   project = Get(o,'project');
   directory = Get(o,{'directory',''});
   kind = Get(o,'kind');
   test = Get(o,'test');

   [folder,package,path] = Folder(o);

   com = {};
   com{end+1} = iif(logroot,['Log root: ',logroot],'No log root defined!');
   com{end+1} = iif(machine,['Machine: ',machine],'No machine ID defined!');
   if (logroot)
      com{end+1} = ['Current Number: ',sprintf('%g',run)];
   end

   com{end+1} = '';
   com{end+1} = iif(project,['Current project: ',project],'No open project!');
   if ~isempty(project)
      com{end+1} = ['Project Directory: ',directory];
   end
   
   com{end+1} = '';
   com{end+1} = iif(package,['Current package: ',package],'Undefined package!');
   
   com{end+1} = '';
   com{end+1} = iif(kind,['Current type: ',kind],'Undefined type!');
   com{end+1} = iif(folder,['Package folder: ',folder],'Undefined folder!');
   
   if ~isempty(path)
      com{end+1} = ['Logged to path: ',path];
   end
   if ~isempty(test)
      com{end+1} = ['Last test: ',test];
   end
   
   o = set(o,'comment',com);
   push(o);                            % update shell object
   menu(o,'Home');                     % refresh home screen
end
function o = Rebuild(o)                % Rebuild Plugin Menus          
   event(o,'rebuild.test');            % invoke 'rebuild.test' event
%    Project(o);                       % rebuild Project menu
%    Package(o);                       % rebuild Package menu
%    Run(o);                           % rebuild Run menu
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Error(o,msg1,msg2)        % Report Error Message          
   if (nargin <= 1)
      message(o,['Error: ',msg1]);
   else
      message(o,['Error: ',msg1],msg2);
   end
   o = [];
end
function oo = WritePackage(o,path)     % Write Package                 
   oo = o;

      % now write package
      
   oo = write(oo,'WritePkgPkg',path);
end
function o = Discover(o)               % Discover Run Number           
   logroot = Get(o,'logroot');
   if isempty(logroot)
      error('empty logroot - cannot continue!');
   end
   run = Highest(o,logroot,0);
   Set(o,'run',run);
end
function run = Highest(o,path,run)     % Find Highest Run Number       
   [directory,file,ext] = fileparts(path);
   title = [file,ext];

   if length(title) > 0 && title(1) == '@'
      [package,typ,name,r] = split(o,title);
      run = max(run,r);
      return
   end

      % otherwise go into the depth

   list = dir(path);
   for (i=1:length(list))
      file = list(i).name;
      if isequal(file,'.') || isequal(file,'..')
         continue
      end
      subpath = [path,'/',file];
      if exist(subpath) == 7
         r = Highest(o,subpath,run);
         run = max(run,r);
      end
   end
end
