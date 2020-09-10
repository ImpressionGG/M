function oo = rapid(o,varargin)        % Rapid Prototyping Shell       
%
% RAPID  Launch a rapid prototyping shell for creation of a derived
%        Carabao class.
%
%           rapid(carabao)             % launch shell
%           rapid(carabao,'espresso')  % new class name 'espresso'
%           rapid(espresso,'machiato') % derive 'machiato' from espresso
%
%        See also: CARABAO
%
   if (nargin >= 2 && ischar(varargin{1}))
      name = varargin{1};
      if length(name) > 0 && name(1) == lower(name(1))
         Shell(arg(o,varargin));
         return
      end
   end
   
   [func,o] = manage(o,varargin,@Shell);
   oo = func(o);                       % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init shell

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Option(o);                     % add Option menu
   oo = Class(o);                      % add Class menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Shell                    
   if arg(o,inf) > 0
      name = arg(o,1);
      if ~ischar(name)
         error('char expected for class name (arg2)!');
      end
      o = opt(o,'classname',name);
   end
   
   o = provide(o,'par.title','Rapid Prototyping');
   comment = {'Create a new class derived from Carabao class'};
   o = provide(o,'par.comment',comment);
   
   o = refresh(o,{'menu','About'});    % provide refresh callback function
   o = launch(o,mfilename);
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
end

%==========================================================================
% Option Menu
%==========================================================================

function oo = Option(o)                % Option Menu                   
   setting(o,{'rapid.shell'},true);
   setting(o,{'rapid.version'},true);
   setting(o,{'rapid.simple'},false);
   setting(o,{'rapid.tiny'},false);
   
   oo = mhead(o,'Option' );            % add Option menu header
   ooo = mitem(oo,'Standard Shell, Import/Export/Read/Write/Plot Method','','rapid.shell');
   check(ooo);
   ooo = mitem(oo,'Version Method','','rapid.version');
   check(ooo);

   ooo = mitem(oo,'-');
   
   ooo = mitem(oo,'Simple Shell Method','','rapid.simple');
   check(ooo);
   ooo = mitem(oo,'Tiny Shell Method','','rapid.tiny');
   check(ooo);
end

%==========================================================================
% Class Menu
%==========================================================================

function oo = Class(o)                 % Class Menu                    
   setting(o,{'classname'},'play');
   setting(o,{'baseclass'},o.tag);
   
   oo = mhead(o,'Class');              % add roll down header menu item
   ooo = mitem(oo,'Class Name','','classname');
   charm(ooo);                         % add charm functionality
   ooo = mitem(oo,'Base Class','','baseclass');
   charm(ooo);                         % add charm functionality
   ooo = mitem(oo,'-');                % separator
   ooo = mitem(oo,'Create New Class',{@CreateCb});
end
function oo = CreateCb(o)              % Create Callback               
   [is] = util(o,'is');                % need some utility
   AddComment(o);                      % reset comment list
   oo = SelectPath(o);
   if isempty(oo)
      oo = [];                         % dialog canceled
      return
   end
   
      % get final confirmation to proceed

   name = lower(opt(oo,{'classname',''}));
   oo = opt(oo,'classname',name); 
   oo = var(oo,'classpath',upath(o,var(oo,'path'),['@',name]));

   if ~(is(oo) && is(name))
      return
   end
   
   ok = FinalConfirmation(oo);
   if ~ok
      oo = [];                         % callback canceled
      return
   end

   oo.par.title = ['Creating new class: @',name];
   oo.par.comment = {['Class directory: ',var(oo,'classpath')]};
   message(oo);
   oo = CreateDirectory(oo,['@',name]);
   
   if isempty(oo)
      return
   end
   
   oo = CreateConstructor(oo);
   
   if opt(o,'rapid.shell');
      oo = CreateShell(oo);
   end
   
   if opt(o,'rapid.version')
      oo = CreateVersion(oo);
   end

   if opt(o,'rapid.simple');
      oo = CreateSimple(oo);
   end
   
   if opt(o,'rapid.tiny');
      oo = CreateTiny(oo);
   end
   
   oo = pull(o);
   oo = set(oo,'title',['Class @',name,' creation completed!']);
   message(oo);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function ok = FinalConfirmation(o)     % Prompt for Final Confirmation 
   iif = util(o,'iif');                % need some utility
   
   name = opt(o,'classname');
   base = opt(o,'baseclass');
   path = var(o,'classpath');

   list = {'Create class directory and method files?',''};
   list{end+1} = ['   Class name: ',name];
   list{end+1} = ['   Base class: ',base];
   list{end+1} = ['   Class directory: ',path];   
   list{end+1} = '';
   list{end+1} = 'Methods:';
   list{end+1} = ['   constructor: ',name,'.m'];
   if opt(o,'rapid.tiny')
      list{end+1} = ['   tiny shell: tiny.m'];
   end
   if opt(o,'rapid.shell')
      list{end+1} = ['   standard shell: shell.m'];
      list{end+1} = ['   import method: import.m'];
      list{end+1} = ['   export method: export.m'];
      list{end+1} = ['   read method: read.m'];
      list{end+1} = ['   write method: write.m'];
      list{end+1} = ['   plot method: plot.m'];
   end
   if opt(o,'rapid.version')
      list{end+1} = ['   version method: version.m'];
   end   
   
   button = questdlg(list,'Create New Class', 'Yes','No','Yes');  
   ok = strcmp(button,'Yes');
end
function oo = SelectPath(o)            % Select Path for Class Dir     
   name = opt(o,'classname');
   oo = [];                            % empty path by default
   
   caption = ['Select a parent folder for new class folder @',name];
   
   path = which('carabao');
   [path,~] = fileparts(path);
   [path,~] = fileparts(path);         % two folders back

   
   current = directory(o);             % save current directory
   directory(o,path);                  % set default creation path
   dir = fselect(o,'d','',caption);    % select creation directory
   directory(o,current);               % restore current directory

   if ~isempty(dir)                    % if dialog not canceled
      oo = var(o,'path',dir);
   end
end
function oo = CreateDirectory(o,name)  % Create Class Directory        
   oo = [];                            % empty out arg by default
   path = var(o,'path');
   classpath = var(o,'classpath');
   
   if exist(classpath) == 7
      comment = {['Delete first the class folder: ',name],...
                 ['Path: ',classpath]};
      message(o,'Error: class folder already exists!',comment);
      return
   end
   
   assert(~isempty(path));   

   success = mkdir(path,name);
   if ~success
      comment = {['path: ',classpath]};
      message(o,'Error: could not create class directory',comment);
      return;
   end
   oo = o;                             % copy object by default 
end
function oo = CreateConstructor(o)     % Create Constructor            
   name = opt(o,'classname');
   base = opt(o,'baseclass');
   list = {{'$base',base}};
   oo = CreateMethod(o,name,'% % Class Constructor Template',list);
   AddComment(o,['constructor method @',name,'/',name,'.m created']);
end
function oo = CreateShell(o)           % Create Normal Shell Method    
   iif = util(o,'iif');                % need some utility
   
%  dynamic = opt(o,'rapid.dynamic');
%  dynamic = iif(dynamic,'true','false');
%  list = {{'$DYN',dynamic}};
   list = {};
   
   name = opt(o,'classname');
   oo = CreateMethod(o,'shell','% % Standard Shell Template',list);
   AddComment(o,['standard shell method @',name,'/shell.m created']);
   oo = CreateMethod(o,'import','% % Import Template');
   AddComment(o,['import method @',name,'/import.m created']);
   oo = CreateMethod(o,'export','% % Export Template');
   AddComment(o,['export method @',name,'/export.m created']);
   oo = CreateMethod(o,'read','% % Read Template');
   AddComment(o,['read method @',name,'/read.m created']);
   oo = CreateMethod(o,'write','% % Write Template');
   AddComment(o,['write method @',name,'/write.m created']);
   oo = CreateMethod(o,'plot','% % Plot Template');
   AddComment(o,['plot method @',name,'/plot.m created']);
end
function oo = CreateSimple(o)          % Create Simple Shell Method    
   oo = CreateMethod(o,'simple','% % Simple Shell Template');
   name = opt(o,'classname');
   AddComment(o,['simple shell method @',name,'/simple.m created']);
end
function oo = CreateTiny(o)            % Create Tiny Shell Method      
   oo = CreateMethod(o,'tiny','% % Tiny Shell Template');
   name = opt(o,'classname');
   AddComment(o,['tiny shell method @',name,'/tiny.m created']);
end
function oo = CreateVersion(o)         % Create Version Method         
   list = {{'$TIME',datestr(now)}};
   oo = CreateMethod(o,'version','% % Version Template',list);
   name = opt(o,'classname');
   AddComment(o,['version method @',name,'/version.m created']);
end
function oo = CreateMethod(o,name,tag,list)                            
   if (nargin < 4)
      list = {};
   end
   
   list = ReplaceList(o,list);
   directory = var(o,'classpath');
   path = upath(o,directory,[name,'.m']);
   
   fid = fopen(path,'w');
   if (fid == -1)
      oo = [];                         % error during operation
      return
   end
   
   WriteText(o,fid,tag,list);
   fclose(fid);
   oo = o;                             % success!
end
function list = ReplaceList(o,ilist)                                   
   name = opt(o,'classname');
   Name = [upper(name(1)),name(2:end)]; % capitalize
   NAME = upper(name);
   list = {{'$name',name},{'$Name',Name},{'$NAME',NAME}};
   
      % append items of ilist
      
   for (i=1:length(ilist))
      list{end+1} = ilist{i};
   end
end
function oo = WriteText(o,fid,tag,list)                                
   is = @isequal;                      % short hand
   either = @carabull.either;
   
   fsrc = SeekText(o,tag);
   if is(fsrc,-1)
      error('cannot open method template!');
   end
   
   while ~is(fsrc,-1)
      line = fgets(fsrc);
      if isequal(strfind(line,'% $eof'),1)
         break;
      end
      text = line(3:end);

      gap = 0;
      
      for (i=1:length(list))
         pair = list{i};
         formal = pair{1};
         while (1)
            idx = min(either(strfind(text,formal),0));
            if (idx == 0)
               break;
            end
            n = length(formal);
            actual = pair{2};
            
            jdx = min(either(strfind(text,'$#'),0));
            if (idx < jdx)
               gap = gap + length(formal) - length(actual);
            end
            text = [text(1:idx-1),actual,text(idx+n:end)];
         end
      end
      
         % substitute '$###...' string, regarding gap count
         
      jdx = min(either(strfind(text,'$#'),0));
      if (jdx > 0)
         n = 2;
         for (i=jdx+2:length(text))
            if (text(i) == '#')
               n = n+1;
            else
               break;
            end
         end
         actual = char(' '+zeros(1,n+gap));
         text = [text(1:jdx-1),actual,text(jdx+n:end)];
      end
      
      fprintf(fid,'%s',text);
   end
   fclose(fsrc);                       % close source file
end
function fid = SeekText(o,tag)                                         
   srcpath = which(mfilename);
   
   fid = fopen(srcpath,'r');
   line = fgets(fid);
   while ~isequal(line,-1)
      if isequal(strfind(line,tag),1)
         line = fgets(fid);
         line = fgets(fid);            % read 2 more lines
         return
      end
      line = fgets(fid);               % get next line
   end
   fclose(fid);
   fid = -1;
end
function oo = AddComment(o,msg)                                        
%
% ADD-COMMENT
%    AddComment(o,message)             % add a message to comment list
%    AddComment(o)                     % reset comment list
%
   oo = pull(o);
   if (nargin == 1)
      comment = {};
   else
      comment = get(oo,{'comment',{}});
      comment{end+1} = msg;
   end
   oo = set(oo,'comment',comment);
   oo = push(oo);
   message(oo);
end

%==========================================================================
% Templates
%==========================================================================

function ClassConstructorTemplate      % Class Constructor Template    
% %==========================================================================
% % Class Constructor Template
% %==========================================================================
% 
% classdef $name < $base           $#### % $Name Class Definition
%    methods                             % public methods                
%       function o = $name(arg)    $#### % $name constructor  
%          if (nargin == 0)
%             arg = 'shell';             % 'shell' type by default
%          end
%          o@$base(arg);           $#### % construct base object
%          o.tag = mfilename;            % tag must equal derived class name
%       end
%    end
% end
% $eof
end
function TinyShellTemplate             % Tiny Shell Template           
% %==========================================================================
% % Tiny Shell Template
% %==========================================================================
%
% function oo = $name(o,varargin) $####  % tiny shell
%    [gamma,o] = manage(o,varargin,@Shell,@SinCb,@CosCb);
%    oo = gamma(o);                      % invoke local function
% end
% 
% %==========================================================================
% % Shell Setup
% %==========================================================================
% 
% function o = Shell(o)                  % Shell Setup                   
%    o = Init(o);                        % init shell
% 
%    o = menu(o,'Begin');                % begin menu setup
%    oo = File(o);                       % add File menu
%    oo = Play(o);                       % add Play menu
%    o = menu(o,'End');                  % end menu setup (will refresh)
% end
% 
% function o = Init(o)                   % Init Shell                    
%    o = launch(o,mfilename);
%    o = provide(o,'par.title','Tiny $Name Shell');
%    o = refresh(o,{'menu','About'});    % provide refresh callback function
% end
% 
% %==========================================================================
% % File Menu
% %==========================================================================
% 
% function oo = File(o)                  % File Menu                     
%    oo = menu(o,'File');                % add File menu
% end
% 
% %==========================================================================
% % Play Menu
% %==========================================================================
% 
% function oo = Play(o)                  % Play Menu                     
%    oo = mhead(o,'Play');               % add roll down header menu item
%    ooo = mitem(oo,'Plot Sin',{@SinCb,'r'});
%    ooo = mitem(oo,'Plot Cos',{@CosCb,'b'});
% end
% 
% function o = SinCb(o)                  % Sin Callback                  
%    c = arg(o,1);                       % get color arg
%    refresh(o,{mfilename,'SinCb',c});   % new refresh callback
%    cls(o);                             % clear screen
%    plot(0:0.1:10,sin(0:0.1:10),c);     % plot sin function
% end
% 
% function o = CosCb(o)                  % Cos Callback                  
%    c = arg(o,1);                       % get color arg
%    refresh(o,{mfilename,'CosCb',c});   % new refresh callback
%    cls(o);                             % clear screen
%    plot(0:0.1:10,cos(0:0.1:10),c);     % plot cos function
% end
% $eof
end
function StandardShellTemplate         % Standard Shell Template       
% %==========================================================================
% % Standard Shell Template
% %==========================================================================
%
% function oo = shell(o,varargin)        % $NAME shell
%    [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@Analysis);
%    oo = gamma(o);                      % invoke local function
% end
% 
% %==========================================================================
% % Shell Setup
% %==========================================================================
% 
% function o = Shell(o)                  % Shell Setup                   
%    o = Init(o);                        % init object
% 
%    o = menu(o,'Begin');                % begin menu setup
%    oo = File(o);                       % add File menu
%    oo = menu(o,'Edit');                % add Edit menu
%    oo = menu(o,'Select');              % add Select menu
%    oo = Plot(o);                       % add Plot menu
%    oo = Analysis(o);                   % add Analysis menu
%    oo = menu(o,'Gallery');             % add Gallery menu
%    oo = Info(o);                       % add Info menu
%    oo = menu(o,'Figure');              % add Figure menu
%    o = menu(o,'End');                  % end menu setup (will refresh)
% end
% function o = Init(o)                   % Init Object                   
%    o = dynamic(o,true);                % setup as a dynamic shell
%    o = launch(o,mfilename);            % setup launch function
%
%    o = provide(o,'par.title','$Name Shell');
%    o = provide(o,'par.comment',{'Playing around with $NAME objects'});
%    o = refresh(o,{'menu','About'});    % provide refresh callback function
% end
% function list = Dynamic(o)             % List of Dynamic Menus             
%    list = {'Plot','Analysis'};
% end
% 
% %==========================================================================
% % File Menu
% %==========================================================================
% 
% function oo = File(o)                  % File Menu                     
%    oo = menu(o,'File');                % add File menu
%    ooo = New(oo);                      % add New menu
%    ooo = Import(oo);                   % add Import menu items
%    ooo = Export(oo);                   % add Export menu items
% end
% function oo = New(o)                   % New Menu                      
%    oo = menu(o,'New');
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Stuff');
%    oooo = shell(ooo,'Stuff','weird');
%    oooo = shell(ooo,'Stuff','ball');
%    oooo = shell(ooo,'Stuff','cube');
%    ooo = mitem(oo,'$Name');
%    oooo = mitem(ooo,'Log Data',{@NewCb});
%    return
%
%    function oo = NewCb(o)
%       log = ones(1000,1)*randn(1,2) + randn(1000,2)*randn(2,2);
% 
%       oo = $name('log');
%       oo.par.title = ['Log Data @ ',datestr(now)];
%       oo.data.x = log(:,1);
%       oo.data.y = log(:,2);
% 
%       oo = launch(oo,launch(o));       % inherit launch function
%       paste(o,{oo});                   % paste object into shell
%    end
% end
% function oo = Import(o)                % Import Menu Items             
%    oo = mhead(o,'Import');             % locate Import menu header
%    ooo = mitem(oo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@$name});
%    ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'ReadLogLog','.log',@$name});
%    return
%    
%    function o = ImportCb(o)            % Import Log Data Callback
%       drv = arg(o,1);                  % export driver
%       ext = arg(o,2);                  % file extension
%       cast = arg(o,3);                 % cast method
%       list = import(cast(o),drv,ext);  % import object from file
%       paste(o,list);
%    end
% end
% function oo = Export(o)                % Export Menu Items             
%    oo = mhead(o,'Export');             % locate Export menu header
%    ooo = mitem(oo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@$name});
%    ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'WriteLogLog','.log',@$name});
%    return
%    
%    function oo = ExportCb(o)           % Export Log Data Callback
%       oo = current(o);
%       if container(oo)
%          message(oo,'Select an object for export!');
%       else
%          drv = arg(o,1);               % export driver
%          ext = arg(o,2);               % file extension
%          cast = arg(o,3);              % cast method
%          export(cast(oo),drv,ext);     % export object to file
%       end
%    end
% end
% 
% %==========================================================================
% % Plot Menu
% %==========================================================================
% 
% function oo = Plot(o)                  % Plot Menu                     
%    setting(o,{'plot.bullets'},true);   % provide bullets default
%    setting(o,{'plot.linewidth'},3);    % provide linewidth default
%    setting(o,{'plot.color'},'k');      % provide linewidth default
%    
%    oo = mhead(o,'Plot');               % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = mitem(oo,'Stream Plot X',{@PlotCb,'StreamX'});
%    ooo = mitem(oo,'Stream Plot Y',{@PlotCb,'StreamY'});
%    ooo = mitem(oo,'Scatter Plot',{@PlotCb,'Scatter'});
%    ooo = mitem(oo,'-');                % separator
%    ooo = mitem(oo,'Bullets','','plot.bullets');
%    check(ooo,{});
%    ooo = mitem(oo,'Line Width','','plot.linewidth');
%    choice(ooo,[1:3],{});
%    ooo = mitem(oo,'Scatter Color','','plot.color');
%    charm(ooo,{});
%    return
% 
%    function oo = PlotCb(o)
%       refresh(o,o);                    % use this callback for refresh
%       oo = plot(o);                    % forward to capuchino.plot method
%    end
% end
%
% %==========================================================================
% % Analysis Menu
% %==========================================================================
% 
% function oo = Analysis(o)              % Analysis Menu                     
%    oo = mhead(o,'Analysis');           % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
% end
%
% %==========================================================================
% % Info Menu
% %==========================================================================
% 
% function oo = Info(o)                  % Info Menu                   
%    oo = menu(o,'Info');                % add Info menu
%    ooo = mseek(oo,{'Version'});
%    oooo = mitem(ooo,['$Name Class: Version ',version($name)]);
%    ooooo = mitem(oooo,'Edit Release Notes','edit $name/version');
% end
% $eof
end
function SimpleShellTemplate           % Simple Shell Template         
% %==========================================================================
% % Simple Shell Template
% %==========================================================================
%
% function oo = simple(o,varargin)       % Simple $NAME Shell
% %
% % SIMPLE   Simple shell for $NAME object
% %
% %             simple(o)                % shell setup
% %             simple(o,'Shell')        % same as above
% %             simple(o,'File')         % add File Menu
% %             simple(o,'Play')         % add/refresh Play Menu
% %             simple(o,'Plot')         % Plot callback
% %
% %          See also: $NAME, SHELL
% %
%    [gamma,oo] = manage(o,varargin,@Shell,@File,@Play,@Plot);
%    oo = gamma(oo);                     % dispatch to local function
% end
% 
% %==========================================================================
% % Shell Setup
% %==========================================================================
% 
% function o = Shell(o)                  % Shell Setup                   
%    o = Init(o);                        % initialize object
%    o = menu(o,'Begin');                % begin menu setup
%    oo = File(o);                       % add File menu
%    oo = Play(o);                       % add Play menu
%    o = menu(o,'End');                  % end menu setup
% end
% 
% function o = Init(o)                   % Object Initializing           
%    o = dynamic(o,false);               % setup as a static shell
%    o = launch(o,mfilename);            % setup launch function
%    o = provide(o,'par.title','Simple Shell');
%    o = provide(o,'par.comment',{'A simple shell to play'});
%    o = refresh(o,{'menu','About'});    % setup refresh callback
% end
% 
% %==========================================================================
% % File Menu
% %==========================================================================
% 
% function oo = File(o)                  % File Menu                     
%    oo = menu(o,'File');                % add File menu
% end
% 
% %==========================================================================
% % Play Menu
% %==========================================================================
% 
% function oo = Play(o)                  % Play Menu                     
%    setting(o,{'play.grid'},false);     % no grid by default
%    setting(o,{'play.color'},'r');      % default setting for color
%    
%    oo = mhead(o,'Play');               % add Plot menu header
%    ooo = mitem(oo,'Sin',{@Plot,'sin'});% add Sin menu item
%    ooo = mitem(oo,'Cos',{@Plot,'cos'});% add Cos menu item
%    ooo = mitem(oo,'-');                % add separator
%    ooo = mitem(oo,'Grid','','play.grid');
%    check(ooo,'');                      % add check functionality
%    ooo = mitem(oo,'Color','','play.color');
%    choice(ooo,{{'Red','r'},{'Green','g'},{'Blue','b'}},{});
% end
% 
% function o = Plot(o)                   % Plot Callback                 
%    mode = arg(o,1);                    % 1st arg: plot mode
%    refresh(o,{@Plot,mode});            % update refresh callback 
% 
%    col = opt(o,'play.color');
%    cls(o);                             % clear screen
%    fct = eval(['@',mode]);             % make function handle
%    plot(0:0.1:10,fct(0:0.1:10),col);   % plot sin or cos curve
%    if opt(o,'play.grid')
%       grid on;                         % show grid
%    end
% end
% $eof
end
function ImportTemplate                % Import Template               
% %==========================================================================
% % Import Template
% %==========================================================================
%
% function list = import(o,driver,ext)   % Import Objects From File      
% %
% % IMPORT   Import object(s) from file
% %
% %             list = import(o,'ReadStuffTxt','.txt')
% %
% %          See also: CARABAO, EXPORT, READ
% %
%    caption = sprintf('Import object from %s file',ext);
%    [files, dir] = fselect(o,'i',ext,caption);
%    
%    list = {};                          % init: empty object list
%    gamma = eval(['@',driver]);         % function handle for import driver
%    for (i=1:length(files))
%       path = [dir,files{i}];
%       oo = read(o,driver,path);        % read data file into object
%       oo = launch(oo,launch(o));       % inherit launch function
%       list{end+1} = oo;                % add imported object to list
%    end
% end
% $eof
end
function ReadTemplate                  % Read Template                 
% %==========================================================================
% % Read Template
% %==========================================================================
%
% function oo = read(o,varargin)         % Read CARABAO Object From File 
% %
% % READ   Read a CARABAO object from file.
% %
% %             oo = read(o,'ReadLogLog',path) % .log data read driver
% %
% %          See also: CARABAO, IMPORT
% %
%    [gamma,oo] = manage(o,varargin,@ReadLogLog);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Read Driver for Log Data
% %==========================================================================
%
% function oo = ReadLogLog(o)            % Read Driver for .log Data     
%    path = arg(o,1);
%    [x,y,par] = Read(path);
%    
%    oo = $name('log');
%    oo.data.x = x;
%    oo.data.y = y;
%    oo.par = par;
%    return
%    
%    function [x,y,par] = Read(path)        % read log data (v1a/read.m)
%       fid = fopen(path,'r');
%       if (fid < 0)
%          error('cannot open log file!');
%       end
%       par.title = fscanf(fid,'$title=%[^\n]');
%       log = fscanf(fid,'%f',[2 inf])';    % transpose after fscanf!
%       x = log(:,1); y = log(:,2);
%    end
% end
% $eof
end
function WriteTemplate                 % Write Template                
% %==========================================================================
% % Write Template
% %==========================================================================
%
% function oo = write(o,varargin)        % Write CARABAO Object To File  
% %
% % WRITE   Write driver to write a CARABAO object to file.
% %
% %             oo = write(o,'WriteStuffTxt',path)
% %
% %          See also: CARAMEL, EXPORT
% %
%    [gamma,oo] = manage(o,varargin,@WriteLogLog);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Data Write Driver for $Name Stuff
% %==========================================================================
%
% function o = WriteLogLog(o)            % Export Object to .log File
%    path = arg(o,1);                    % get path argument
%    log = [o.data.x(:),o.data.y(:)];
%    title = get(o,'title');
%    
%    fid = fopen(path,'w');                    % open log file for write
%    if (fid < 0)
%       error('cannot open log file');
%    end
%    
%    fprintf(fid,'$title=%s\n',title);
%    fprintf(fid,'%10f %10f\n',log');          % write x/y data
%    fclose(fid);                              % close log file
% end
% $eof
end
function ExportTemplate                % Export Template               
% %==========================================================================
% % Export Template
% %==========================================================================
%
% function o = export(o,driver,ext)      % Export $NAME Object To File
% %
% % EXPORT   Export a $NAME object to file.
% %
% %             oo = export(o,'WriteStuffLog','.log')
% %             oo = export(o,'LogData','.log')
% %
% %          See also: $NAME, IMPORT
% %
%    name = get(o,{'title',''});
%    caption = sprintf('Export $NAME object to %s file',ext);
%    [file, dir] = fselect(o,'e',[lower(name),ext],caption);
%    
%    oo = [];                            % empty by default
%    if ~isempty(file)
%       oo = write(o,driver,[dir,file]); % actual export to file
%    end
% end
% $eof
end
function PlotTemplate                  % Plot Template                 
% %==========================================================================
% % Plot Template
% %==========================================================================
% 
% function oo = plot(o,varargin)         % Capuchino Plot Method
% %
% % PLOT   $Name plot method
% %
% %           plot(o,'StreamX')          % stream plot X
% %           plot(o,'StreamY')          % stream plot Y
% %           plot(o,'Scatter')          % scatter plot
% %           plot(o,'Show')             % show object
% %           plot(o,'Animation')        % animation of object
% %
%    [gamma,oo] = manage(o,varargin,@StreamX,@StreamY,@Scatter);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Local Plot Functions
% %==========================================================================
% 
% function oo = StreamX(o)               % Stream Plot X                 
%    oo = Plot(o,'StreamX');
% end
% function oo = StreamY(o)               % Stream Plot Y                 
%    oo = Plot(o,'StreamY');
% end
% function o = Scatter(o)                % Scatter Plot
%    oo = Plot(o,'Scatter');
% end
% 
% %==========================================================================
% % Auxillary Functions
% %==========================================================================
% 
% function oo = Plot(o,mode)
%    oo = current(o);
%    if isequal(oo.type,'log')
%       co = cast(o,'carabao');
%       plot(co,mode);
%    else
%       menu(oo,'About');
%    end
% end
% $eof
end
function VersionTemplate               % Version Template              
% %==========================================================================
% % Version Template
% %==========================================================================
% 
% function vers = version(obj,arg)       % $NAME Class Version           
% %
% % VERSION   $NAME class version / release notes
% %
% %       vs = version($name);     $#### % get $NAME version string
% %
% %    See also: $NAME
% %
% %--------------------------------------------------------------------------
% %
% % Release Notes $NAME/V1A
% % =======================
% %
% % - created: $TIME
% %
% % Known bugs & wishlist
% % =========================
% % - none so far
% %
% %--------------------------------------------------------------------------
% %
%    path = upper(which('$name/version'));
%    idx = max(findstr(path,'@$NAME'));
%    vers = path(idx-4:idx-2);
% end   
% $eof
end
