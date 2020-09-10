function oo = rapid(o,varargin)        % Rapid Prototyping Shell       
%
% RAPID  Launch a rapid prototyping shell for creation of a derived
%        Corazon class.
%
%           rapid(corazon)             % launch shell
%           rapid(corazon,'espresso')  % new class name 'espresso'
%           rapid(espresso,'machiato') % derive 'machiato' from espresso
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON
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
   comment = {'Create a new class derived from Corazon class'};
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
      list{end+1} = ['   new method: new.m'];
      list{end+1} = ['   read method: read.m'];
      list{end+1} = ['   write method: write.m'];
      list{end+1} = ['   plot method: plot.m'];
      list{end+1} = ['   analysis method: analysis.m'];
      list{end+1} = ['   study method: study.m'];
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

%  path = which('corazon');
%  [path,~] = fileparts(path);
%  [path,~] = fileparts(path);         % two folders back
   path = pwd;

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
   oo = CreateMethod(o,'new','% % New Template');
   AddComment(o,['new method @',name,'/new.m created']);
   oo = CreateMethod(o,'read','% % Read Template');
   AddComment(o,['read method @',name,'/read.m created']);
   oo = CreateMethod(o,'write','% % Write Template');
   AddComment(o,['write method @',name,'/write.m created']);
   oo = CreateMethod(o,'plot','% % Plot Template');
   AddComment(o,['plot method @',name,'/plot.m created']);
   oo = CreateMethod(o,'analysis','% % Analysis Template');
   AddComment(o,['analysis method @',name,'/analysis.m created']);
   oo = CreateMethod(o,'study','% % Study Template');
   AddComment(o,['study method @',name,'/study.m created']);
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
   either = @corazito.either;

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
   srcpath = which([class(o),'/',mfilename]);

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
%
%          if (nargout == 0)
%             launch(o);
%             clear o;
%          end
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
%    [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@Plot,@PlotCb,...
%                                  @Analysis,@Study);
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
%    oo = View(o);                       % add View menu
%    oo = menu(o,'Select');              % add Select menu
%    oo = Plot(o);                       % add Plot menu
%    oo = Analysis(o);                   % add Analysis menu
%    oo = Study(o);                      % add Study menu
%    oo = menu(o,'Gallery');             % add Gallery menu
%    oo = Info(o);                       % add Info menu
%    oo = menu(o,'Figure');              % add Figure menu
%    o = menu(o,'End');                  % end menu setup (will refresh)
% end
% function o = Tiny(o)                   % Tiny Shell Setup
%    o = Init(o);                        % init object
%
%    o = menu(o,'Begin');                % begin menu setup
%    oo = File(o);                       % add File menu
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
%    list = {'Plot','Analysis','Study'};
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
%    oo = mseek(o,{'New'});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Stuff');
%    oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
%    ooo = mitem(oo,'$Name');
%    oooo = new(ooo,'Menu');
% end
% function oo = Import(o)                % Import Menu Items
%    oo = mhead(o,'Import');             % locate Import menu header
%    ooo = mitem(oo,'Stuff');
%    oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
%    ooo = mitem(oo,'$Name');
%    oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@$name});
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
%    ooo = mitem(oo,'Stuff');
%    oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
%    ooo = mitem(oo,'$Name');
%    oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@$name});
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
% % View Menu
% %==========================================================================
% 
% function oo = View(o)                  % View Menu
%    oo = mhead(o,'View',{},[],'visible','off'); % add roll down header item
% end
% 
% %==========================================================================
% % Plot Menu
% %==========================================================================
%
% function oo = Plot(o)                  % Plot Menu
%    oo = mhead(o,'Plot');               % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = plot(oo,'Menu');              % setup plot menu
% end
%
% %==========================================================================
% % Analysis Menu
% %==========================================================================
%
% function oo = Analysis(o)              % Analysis Menu
%    oo = mhead(o,'Analysis');           % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = analysis(oo,'Menu');          % setup analysis menu
% end
%
% %==========================================================================
% % Study Menu
% %==========================================================================
%
% function oo = Study(o)                 % Study Menu
%    oo = mhead(o,'Study');              % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = study(oo,'Menu');             % setup study menu
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
function ReadTemplate                  % Read Template                 
% %==========================================================================
% % Read Template
% %==========================================================================
%
% function oo = read(o,varargin)         % Read $NAME Object From File
% %
% % READ   Read a $NAME object from file.
% %
% %             oo = read(o,'ReadLogLog',path) % .log data read driver
% %
% %          See also: $NAME, IMPORT
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
% function oo = write(o,varargin)        % Write $NAME Object To File
% %
% % WRITE   Write driver to write a $NAME object to file.
% %
% %             oo = write(o,'WriteStuffTxt',path)
% %
% %          See also: $NAME, EXPORT
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
function PlotTemplate                  % Plot Template                 
% %==========================================================================
% % Plot Template
% %==========================================================================
%
% function oo = plot(o,varargin)         % $NAME Plot Method
% %
% % PLOT   $NAME plot method
% %
% %           plot(o,'PlotX')            % stream plot X
% %           plot(o,'PlotY')            % stream plot Y
% %           plot(o,'PlotXY')           % scatter plot
% %
% %        See also: $NAME, SHELL
% %
%    [gamma,oo] = manage(o,varargin,@PlotDefault,@Menu,@Callback,...
%                        @PlotOverview,@PlotX,@PlotY,@PlotXY);
%    oo = gamma(oo);
% end
%
% %==========================================================================
% % Plot Menu
% %==========================================================================
%
% function oo = Menu(o)                 % Setup Plot Menu
%    oo = mitem(o,'Overview',{@Callback,'PlotOverview'});
%    oo = mitem(o,'-');
%    oo = mitem(o,'X',{@Callback,'PlotX'});
%    oo = mitem(o,'Y',{@Callback,'PlotY'});
%    oo = mitem(o,'XY', {@Callback,'PlotXY'});
%
%    oo = Style(o);                      % add Style menu to Select menu
% end
% function oo = Style(o)                 % Add Style Menu Items
%    setting(o,{'style.bullets'},1);     % provide bullets default
%    setting(o,{'style.linewidth'},1);   % provide linewidth default
%    setting(o,{'style.scatter'},'k');   % provide scatter color default
%
%       % filter settings
%      
%    setting(o,{'filter.mode'},'raw');   % filter mode off
%    setting(o,{'filter.type'},'LowPass2');
%    setting(o,{'filter.bandwidth'},5);
%    setting(o,{'filter.zeta'},0.6);
%    setting(o,{'filter.method'},1);
%
%    oo = mseek(o,{'#','Select'});
%
%    ooo = mitem(oo,'-');
%
%    ooo = mitem(oo,'Style');
%    oooo = mitem(ooo,'Bullets','','style.bullets');
%    check(oooo,{});
%    oooo = mitem(ooo,'Line Width','','style.linewidth');
%    choice(oooo,[1:3],{});
%    oooo = mitem(ooo,'Scatter Color','','style.scatter');
%    charm(oooo,{});
%
%    ooo = mitem(oo,'Filter');
%    oooo = mitem(ooo,'Mode','','filter.mode');
%    choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
%                 {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
%    oooo = mitem(ooo,'-');
%    oooo = mitem(ooo,'Type',{},'filter.type');
%    choice(oooo,{{'Order 2 Low Pass','LowPass2'},{'Order 2 High Pass','HighPass2'},...
%                {'Order 4 Low Pass','LowPass4'},{'Order 4 High Pass','HighPass4'}},{});
%    oooo = mitem(ooo,'Bandwidth',{},'filter.bandwidth');
%    charm(oooo,{});
%    oooo = mitem(ooo,'Zeta',{},'filter.zeta');
%    charm(oooo,{});
%    oooo = mitem(ooo,'Method',{},'filter.method');
%    choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
% end
% function oo = Callback(o)              % Common Plot Callback
%    refresh(o,o);                       % use this callback for refresh
%    list = basket(o);
%
%    oo = o;                             % provide in case of empty basket
%    if isempty(list)
%       message(o,'No objects!',{'(import object or create a new one)'});
%       return
%    end
%
%    cls(o);
%    for (i=1:length(list))
%       oo = list{i};
%       if container(oo)
%          message(oo);
%       else
%          plot(oo);                     % forward to capuchino.plot method
%          hold on;
%       end
%    end
% end
%
% %==========================================================================
% % Plot Functions
% %==========================================================================
%
% function o = PlotDefault(o)            % Default Plot
%    cls(o);                             % clear screen
%    PlotOverview(o);
% end
% function o = PlotOverview(o)           % Plot Overview
%    oo = opt(o,'subplot',[2 2 1]);
%    PlotX(oo);
%
%    oo = opt(oo,'subplot',[2 2 3]);
%    oo = opt(oo,'title',' ');           % prevent from drawing a title
%    PlotY(oo);
%
%    oo = opt(oo,'subplot',[1 2 2]);
%    oo = opt(oo,'title','X/Y-Orbit');   % override title
%    PlotXY(oo);
% end
% function o = PlotX(o)                  % Stream Plot X
%    Stream(o,'x','r');
% end
% function o = PlotY(o)                  % Stream Plot Y
%    Stream(o,'y','b');
% end
% function o = Stream(o,sym,col)
%    t = cook(o,':');
%    [d,df] = cook(o,sym);
%    oo = with(corazon(o),'style');
%
%    switch opt(o,{'filter.mode','raw'})
%       case 'raw'
%          plot(oo,t,d,col);
%       case 'filter'
%          plot(oo,t,df,col);
%       case 'both'
%          plot(opt(oo,'bullets',0),t,d,col);
%          hold on;
%          plot(oo,t,df,'k');
%       case 'noise'
%          plot(oo,t,d-df,col);
%    end
% 
%    title(get(o,'title'));
%    ylabel(sym);
% end
% function o = PlotXY(o)                 % Scatter Plot
%    x = cook(o,'x');
%    y = cook(o,'y');
%    oo = corazon(o);
%    oo = opt(oo,'color',opt(o,'style.scatter'));
%    plot(oo,x,y,'ko');
% %  set(gca,'DataAspectRatio',[1 1 1]);
%    title(get(o,'title'));
% end
% $eof
end
function AnalysisTemplate              % Analysis Template             
% %==========================================================================
% % Analysis Template
% %==========================================================================
%
% function oo = analysis(o,varargin)     % Graphical Analysis
% %
% % ANALYSIS   Graphical analysis
% %
% %    Plenty of graphical analysis functions
% %
% %       analysis(o)               % analysis @ opt(o,'mode.analysis')
% %
% %       oo = analysis(o,'menu')   % setiup analysis menu
% %       oo = analysis(o,'Surf')   % surface plot
% %       oo = analysis(o,'Histo')  % display hostogram
% %
% %    See also: $NAME, PLOT, STUDY
% %
%    [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,@Surf,@Histo);
%    oo = gamma(o);                 % invoke local function
% end
%
% %==========================================================================
% % Menu Setup & Common Menu Callback
% %==========================================================================
%
% function oo = Menu(o)
%    oo = mitem(o,'Surface',{@Callback,'Surf'},[]);
%    oo = mitem(o,'Histogram',{@Callback,'Histo'},[]);
% end
% function oo = Callback(o)
%    refresh(o,o);                       % remember to refresh here
%    oo = current(o);                    % get current object
%    cls(o);
%
%    if container(oo)
%       message(oo);
%    else
%       analysis(oo,arg(o,1));
%    end
% end
%
% %==========================================================================
% % Actual Analysis
% %==========================================================================
%
% function o = Surf(o)                  % Surf Plot
%    x = cook(o,'x');
%    y = cook(o,'y');
%
%    idx = 1:ceil(length(x)/50):length(x);
%    idy = 1:ceil(length(y)/50):length(y);
%    z = x(idx)'.*y(idy);
%    surf(x(idx),y(idy),z);
% end
% function o = Histo(o)                 % Histogram
%    t = cook(o,':');
%    x = cook(o,'x');
%    y = cook(o,'y');
%
%    subplot(211);
%    plot(with(corazon(o),'style'),t,sort(x),'r');
%    subplot(212);
%    plot(with(corazon(o),'style'),t,sort(y),'b');
% end
% $eof
end
function StudyTemplate                 % Study Template                
% %==========================================================================
% % Study Template
% %==========================================================================
%
% function oo = study(o,varargin)     % Do Some Studies
% %
% % STUDY   Several studies
% %
% %       oo = study(o,'Menu')     % setup study menu
% %
% %       oo = study(o,'Study1')   % raw signal
% %       oo = study(o,'Study2')   % raw & filtered signal
% %       oo = study(o,'Study3')   % filtered
% %       oo = study(o,'Study4')   % signal noise
% %
% %    See also: $NAME, PLOT, ANALYSIS
% %
%    [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
%                         @Study1,@Study2,@Study3,@Study4,@Study5,...
%                         @Study6,@Study7,@Study8,@Study9,@Study10);
%    oo = gamma(o);                   % invoke local function
% end
%
% %==========================================================================
% % Menu Setup & Common Menu Callback
% %==========================================================================
%
% function oo = Menu(o)
%    oo = mitem(o,'Raw',{@Callback,'Study1'},[]);
%    oo = mitem(o,'Raw & Filtered',{@Callback,'Study2'},[]);
%    oo = mitem(o,'Filtered',{@Callback,'Study3'},[]);
%    oo = mitem(o,'Noise',{@Callback,'Study4'},[]);
%    oo = mitem(o,'-');
%    oo = mitem(o,'Study5',{@Callback,'Study5'},[]);
%    oo = mitem(o,'Study6',{@Callback,'Study6'},[]);
%    oo = mitem(o,'Study7',{@Callback,'Study7'},[]);
%    oo = mitem(o,'Study8',{@Callback,'Study8'},[]);
%    oo = mitem(o,'Study9',{@Callback,'Study9'},[]);
%    oo = mitem(o,'Study10',{@Callback,'Study10'},[]);
% end
% function oo = Callback(o)
%    refresh(o,o);                       % remember to refresh here
%    oo = current(o);                    % get current object
%    cls(o);                             % clear screen
%    study(oo);
% end
%
% %==========================================================================
% % Studies
% %==========================================================================
%
% function o = Study1(o)                 % Study 1: Raw Signal
%    t = cook(o,':');
%    x = cook(o,'x');
%    y = cook(o,'y');
%
%    subplot(211);
%    plot(with(corazon(o),'style'),t,x,'r');
%    title('Raw Signal X');
%    xlabel('t');
%
%    subplot(212);
%    plot(with(corazon(o),'style'),t,y,'b');
%    title('Raw Signal Y');
%    xlabel('t');
% end
% function o = Study2(o)                 % Study 2: Raw & Filtered Signal
%    t = cook(o,':');
%    [x,xf] = cook(o,'x');
%    [y,yf] = cook(o,'y');
%
%    subplot(211);
%    plot(t,x,'r');  hold on;
%    plot(with(corazon(o),'style'),t,xf,'k');
%    title('Raw & Filtered Signal X');
%    xlabel('t');
%
%    subplot(212);
%    plot(t,y,'r');  hold on;
%    plot(with(corazon(o),'style'),t,yf,'k');
%    title('Raw & Filtered Signal Y');
%    xlabel('t');
% end
% function o = Study3(o)                 % Study 3: Filtered Signal
%    t = cook(o,':');
%    [~,xf] = cook(o,'x');
%    [~,yf] = cook(o,'y');
%
%    subplot(211);
%    plot(with(corazon(o),'style'),t,xf,'r');
%    title('Filtered Signal X');
%    xlabel('t');
%
%    subplot(212);
%    plot(with(corazon(o),'style'),t,yf,'b');
%    title('Filtered Signal Y');
%    xlabel('t');
% end
% function o = Study4(o)                 % Study 4: Noise
%    t = cook(o,':');
%    [x,xf] = cook(o,'x');
%    [y,yf] = cook(o,'y');
%
%    subplot(211);
%    plot(with(corazon(o),'style'),t,x-xf,'r');
%    title('Noise Signal X');
%    xlabel('t');
%
%    subplot(212);
%    plot(with(corazon(o),'style'),t,y-yf,'b');
%    title('Noise Signal Y');
%    xlabel('t');
% end
% function o = Study5(o)                 % Study 5
%    message(o,'Study 5');
% end
% function o = Study6(o)                 % Study 6
%    message(o,'Study 6');
% end
% function o = Study7(o)                 % Study 7
%    message(o,'Study 7');
% end
% function o = Study8(o)                 % Study 8
%    message(o,'Study 8');
% end
% function o = Study9(o)                 % Study 9
%    message(o,'Study 9');
% end
% function o = Study10(o)                % Study 10
%    message(o,'Study 10');
% end
% $eof
end
function NewTemplate                   % New Template                  
% %==========================================================================
% % New Template
% %==========================================================================
%
% function oo = new(o,varargin)          % JUNK7 New Method
% %
% % NEW   New $NAME object
% %
% %           oo = new(o,'Menu')         % menu setup
% %
% %           o = new($name,'Simple')    % some simple data
% %           o = new($name,'Wave')      % some wave data
% %           o = new($name,'Beat')      % some beat data
% %
% %       See also: $NAME, PLOT, ANALYSIS, STUDY
% %
%    [gamma,oo] = manage(o,varargin,@Simple,@Wave,@Beat,@Menu);
%    oo = gamma(oo);
% end
%
% %==========================================================================
% % Menu Setup
% %==========================================================================
%
% function oo = Menu(o)                  % Setup Menu
%    oo = mitem(o,'Simple (SMP)',{@Callback,'Simple'},[]);
%    oo = mitem(o,'-');
%    oo = mitem(o,'Wave (ALT)',{@Callback,'Wave'},[]);
%    oo = mitem(o,'Beat (ALT)',{@Callback,'Beat'},[]);
% end
% function oo = Callback(o)
%    mode = arg(o,1);
%    oo = new(o,mode);
%    oo = launch(oo,launch(o));          % inherit launch function
%    paste(o,{oo});                      % paste object into shell
% end
%
% %==========================================================================
% % New Simple Object
% %==========================================================================
%
% function oo = Simple(o)                % New wave object
%    om = 2*pi*0.5;                      % 2*pi * (0.5 Hz)
%
%    t = 0:0.01:10;                      % time vector
%    x = (2+rand)*sin(om*t) + (1+rand)*sin(3*om*t+randn);
%    y = (1.5+rand)*cos(om*t) + (0.5+rand)*cos(2*om*t+randn);
%
%       % pack into object
%
%    oo = $name('smp');                  % simple type
%    oo.par.title = sprintf('Some Simple Function (%s)',datestr(now));
%    oo.data.t = t;
%    oo.data.x = randn + x + 0.1*randn(size(t));
%    oo.data.y = randn + y + 0.12*randn(size(t));
% end
%
% %==========================================================================
% % New Wave Object
% %==========================================================================
%
% function oo = Wave(o)                  % New wave object
%    f = 1000+pi;                        % 1003.14 Hz
%
%    t = 0:0.0001:5;                     % time vector
%    x = 3*cos(2*pi*f*t);                % x data
%    y = 2*sin(2*pi*f*t);                % y data
%
%    shape = 3*exp(-4*(t-1.2).^2/0.5) + 2*exp(-4*(t-3.8).^2/0.5);
%
%       % pack into object
%
%    oo = $name('alt');                  % alternative type
%    oo.par.title = sprintf('A Stupid Wave (%s)',datestr(now));
%    oo.data.t = t;
%    oo.data.x = x .* shape + 0.02*randn(size(t));
%    oo.data.y = y .* shape + 0.03*randn(size(t));
% end
%
% %==========================================================================
% % New Beat Object
% %==========================================================================
%
% function oo = Beat(o)                  % New beat object
%    f1 = 950;  f2 = 1050;               % close to 1000 Hz
%    df = 50;                            % 50 Hz frequency deviation
%
%    t = 0:0.0001:5;
%    x = 0.9*cos(2*pi*f1*t) + 1.1*cos(2*pi*f2*t);
%    y = 1.1*sin(2*pi*f1*t) + 1.4*sin(2*pi*f2*t);
%
%    shape = 2*exp(-4*(t-1.5).^2/0.5) + 3*exp(-4*(t-3.5).^2/0.5);
%
%       % pack into object
%
%    oo = $name('alt');                  % alternative type
%    oo.par.title = sprintf('A Stupid Beat (%s)',datestr(now));
%    oo.data.t = t;
%    oo.data.x = x .* shape + 0.02*randn(size(t));
%    oo.data.y = y .* shape + 0.03*randn(size(t));
% end
% $eof
end
function VersionTemplate               % Version Template              
% %==========================================================================
% % Version Template
% %==========================================================================
%
% function vers = version(o,arg)       % $NAME Class Version
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
%    path = upath(o,path);
%    idx = max(findstr(path,'@$NAME'));
%    vers = path(idx-4:idx-2);
% end
% $eof
end
