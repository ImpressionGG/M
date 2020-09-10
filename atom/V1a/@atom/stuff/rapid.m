function oo = rapid(o,varargin)        % Rapid Prototyping Shell       
%
% RAPID  Launch a rapid prototyping shell for creation of a derived
%        Carma class.
%
%           rapid(caramel)             % launch shell
%           rapid(caramel,'tornado')   % new class name 'espresso'
%           rapid(tornado,'taifun')    % derive 'machiato' from espresso
%
%        See also: CARAMEL
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
   comment = {'Create a new class derived from Caramel class'};
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
   
   oo = mhead(o,'Option' );            % add Option menu header
   ooo = mitem(oo,'Standard Shell, Read/Write/Plot Method','','rapid.shell');
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
   is = @o.is;                         % short hand
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
%     list{end+1} = ['   import method: import.m'];
%     list{end+1} = ['   export method: export.m'];
      list{end+1} = ['   read method: read.m'];
      list{end+1} = ['   write method: write.m'];
      list{end+1} = ['   plot method: plot.m'];
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
%  oo = CreateMethod(o,'import','% % Import Template');
%  AddComment(o,['import method @',name,'/import.m created']);
%  oo = CreateMethod(o,'export','% % Export Template');
%  AddComment(o,['export method @',name,'/export.m created']);
   oo = CreateMethod(o,'read','% % Read Template');
   AddComment(o,['read method @',name,'/read.m created']);
   oo = CreateMethod(o,'write','% % Write Template');
   AddComment(o,['write method @',name,'/write.m created']);
   oo = CreateMethod(o,'plot','% % Plot Template');
   AddComment(o,['plot method @',name,'/plot.m created']);
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
%    [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
%                   @Collect,@Config,@Import,@Export,@Signal,...
%                   @Plot,@PlotCb,@Analysis,@Study,...
%                   @Read$NameDat,@Write$NameDat);
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
%    oo = shell(o,'File');               % add File menu
%    oo = shell(o,'Edit');               % add Edit menu
%    oo = shell(o,'View');               % add View menu
%    oo = shell(o,'Select');             % add Select menu
%    oo = wrap(o,'Plot');                % add Plot menu (wrapped)
%    oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
%    oo = shell(o,'Study');              % add Study menu
%    oo = shell(o,'Plugin');             % add Plugin menu
%    oo = shell(o,'Gallery');            % add Gallery menu
%    oo = Info(o);                       % add Info menu
%    oo = shell(o,'Figure');             % add Figure menu
%    o = menu(o,'End');                  % end menu setup (will refresh)
% end
% function o = Init(o)                   % Init Object                   
%    o = dynamic(o,true);                % setup as a dynamic shell
%    o = launch(o,mfilename);            % setup launch function
%
%    o = set(o,{'title'},'$Name Shell');
%    o = set(o,{'comment'},{'Playing around with $NAME objects'});
%    o = refresh(o,{'shell','Register'});% provide refresh callback function
%    o = opt(o,{'mode.bias'},'absolute');
% end
% function o = Register(o)               % Register Plugins              
%    o = Config(type(o,'smp'));          % register 'smp' configuration
%    o = Config(type(o,'pln'));          % register 'pln' configuration
%    refresh(o,{'menu','About'});        % provide refresh callback function
%    message(o,'Installing plugins ...');
%    %sample(o,'Register');              % register SAMPLE plugin
%    %basis(o,'Register');               % register BASIS plugin
%    %pbi(o,'Register');                 % register PBI plugin
%    rebuild(o);
% end
% function list = Dynamic(o)             % List of Dynamic Menus         
%    list = {'Plot','Analysis'};
% end
% 
% %==========================================================================
% % File Menu
% %==========================================================================
% 
% function oo = New(o)                   % New Menu Items                
%    oo = menu(o,'New');                 % add CARAMEL New menu
%    ooo = mitem(oo,'Stuff');
%    oooo = shell(ooo,'Stuff','weird');
%    oooo = shell(ooo,'Stuff','ball');
%    oooo = shell(ooo,'Stuff','cube');
% 
%    ooo = mitem(oo,'$Name');
%    oooo = mitem(ooo,'New Plain $Name',{@NewCb,'Plain','pln'});
%    oooo = mitem(ooo,'New Simple $Name',{@NewCb,'Simple','smp'});
%    plugin(oo,'$name/shell/New');
%    return
% 
%    function oo = NewCb(o)              % Create New Object       
%       mode = arg(o,1);
%       typ = arg(o,2);
%       oo = new(o,mode,typ);
%       paste(o,{oo});
%    end
% end
% function oo = Import(o)                % Import Menu Items             
%    oo = mhead(o,'Import');             % locate Import menu header
%    ooo = mitem(oo,'Package',{@CollectCb});
%    ooo = mitem(oo,'-');
%
%    ooo = mitem(oo,'General');
%    oooo = mitem(ooo,'General Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@caramel});
%    oooo = mitem(ooo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@caramel});
% 
%    ooo = mitem(oo,'Stuff');
%    oooo = mitem(ooo,'Text File (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@carabao});
%
%    ooo = mitem(oo,'$Name');
%    oooo = mitem(ooo,'$Name Data (.log)',{@ImportCb,'Read$NameLog','.log',@$name});
%    oooo = mitem(ooo,'$Name Data (.dat)',{@ImportCb,'Read$NameDat','.dat',@$name});
%    plugin(oo,'$name/shell/Import');
%    return
% 
%    function o = ImportCb(o)            % Import Log Data Callback      
%       drv = arg(o,1);                  % export driver
%       ext = arg(o,2);                  % file extension
%       cast = arg(o,3);                 % cast method
% 
%       co = cast(o);                    % casted object
%       list = import(co,drv,ext);       % import object from file
%       paste(o,list);
%    end
%    function o = CollectCb(o)           % Collect All Files of Folder   
%       list = collect(o);               % collect files in directory
%       paste(o,list);
%    end
% end
% function oo = Export(o)                % Export Menu Items             
%    oo = mhead(o,'Export');             % locate Export menu header
%    ooo = mitem(oo,'Package');
%    oooo = mitem(ooo,'Package Info (.pkg)',{@ExportCb,'WritePkgPkg','.pkg',@caramel});
%    set(mitem(ooo,inf),'enable',onoff(o,'pkg'));
%    ooo = mitem(oo,'-');
%
%    ooo = mitem(oo,'Stuff');
%    set(mitem(ooo,inf),'enable',onoff(o,{'weird','ball','cube'},'carabao'));
%    oooo = mitem(ooo,'Text File (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@carabao});
%    set(mitem(oooo,inf),'enable',onoff(o,{'pln','smp'},'carabao'));
%
%    ooo = mitem(oo,'$Name');
%    set(mitem(ooo,inf),'enable',onoff(o,{'log','pln','smp'},'$name'));
%    oooo = mitem(ooo,'$Name Log Data (.log)',{@ExportCb,'Write$NameLog','.log',@$name});
%    set(mitem(oooo,inf),'enable',onoff(o,'log','$name'));
%    oooo = mitem(ooo,'Plain $Name (.dat)',{@ExportCb,'Write$NameDat','.dat',@$name});
%    set(mitem(oooo,inf),'enable',onoff(o,'pln','$name'));
%    oooo = mitem(ooo,'Simple $Name (.dat)',{@ExportCb,'Write$NameDat','.dat',@$name});
%    set(mitem(oooo,inf),'enable',onoff(o,'smp','$name'));
%    
%    plugin(oo,'$name/shell/Export');  % plug point
%    return
%    
%    function oo = ExportCb(o)           % Export Callback
%       oo = current(o);
%       if container(oo)
%          message(oo,'Select an object for export!');
%       else
%          drv = arg(o,1);               % export driver
%          ext = arg(o,2);               % file extension
%          cast = arg(o,3);              % cast method
% 
%          co = cast(oo);                % casted object
%          export(co,drv,ext);           % export object to file
%       end
%    end
% end
% function oo = Collect(o)               % Configure Collection          
%    collect(o,{});                      % reset collection config
%    plugin(o,'$name/shell/Collect');   % plug point
%    
%    if isequal(class(o),'caramel')
%       table = {{@read,'carabao','ReadStuffTxt','.txt'}};
%       collect(o,{'weird','ball','cube'},table); 
%    end
%    if isequal(class(o),'$name')
%       table = {{@read,'$name','Read$NameDat','.dat'}};
%       collect(o,{'pln','smp'},table); 
%    end
%    if isequal(class(o),'$name')
%       table = {{@read,'$name','Read$NameLog','.log'}};
%       collect(o,{'log'},table); 
%    end
%    if isequal(class(o),'$name')
%       table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
%                {@read,'$name','Read$NameDat','.dat'}};
%       collect(o,{'pln','smp'},table); 
%    end
%    oo = o;
% end
% 
% %==========================================================================
% % View Menu
% %==========================================================================
% 
% function o = Signal(o)                 % Signal Menu                   
% %
% % SIGNAL   The Signal function is setting up type specific Signal menu 
% %          items which allow to change the configuration.
% %
%    oo = mhead(o,'Signal',{},'mode.signal');  % must provide Signal header!!  
%    switch active(o);
%       case {'pln'}
%          ooo = mitem(oo,'X/Y and P',{@Config},'PlainXYP');
%          ooo = mitem(oo,'X and Y',{@Config},'PlainXY');
%       case {'smp'}
%          ooo = mitem(oo,'All',{@Config},'SimpleAll');
%          ooo = mitem(oo,'X/Y and P',{@Config},'SimpleXYP');
%          ooo = mitem(oo,'UX and UY',{@Config},'SimpleU');
%    end
%    plugin(oo,'$name/shell/Signal');   % plug point
% end
% function o = Config(o)                 % Setup a Configuration         
% %
% %     Config(type(o,'mytype'))         % register a type specific config
% %     oo = Config(arg(o,{'XY'})        % change configuration
% %          
%    o = config(o,[],active(o));         % set all sublots to zero
%    o = subplot(o,'layout',1);          % layout with 1 subplot column   
%    o = category(o,1,[-2 2],[],'µ');    % setup category 1
%    o = category(o,2,[-2 2],[],'µ');    % setup category 2
%    
%       % get mode and provide a proper type default if empty
%       % (empty mode is provided during registration phase)
%       
%    mode = o.either(arg(o,1),o.type);  
%    switch mode
%       case 'PlainXYP'
%          o = config(o,'x',{1,'r'});
%          o = config(o,'y',{1,'b'});
%          o = config(o,'p',{2,'g'});
%       case {'PlainXY','pln'}
%          o = config(o,'x',{1,'r'});
%          o = config(o,'y',{2,'b'});
%          mode = 'PlainXY';             % resolve default for type 'pln' 
%       case {'SimpleAll','smp'}
%          o = config(o,'x',{1,'r'});
%          o = config(o,'y',{1,'b'});
%          o = config(o,'p',{2,'g'});
%          o = config(o,'ux',{3,'m'});
%          o = config(o,'uy',{3,'c'});
%          mode = 'SimpleAll';           % resolve default for type 'smp' 
%       case 'SimpleXYP'
%          o = config(o,'x',{1,'r'});
%          o = config(o,'y',{1,'b'});
%          o = config(o,'p',{2,'g'});
%       case 'SimpleU'
%          o = config(o,'ux',{1,'m'});
%          o = config(o,'uy',{2,'c'});
%       otherwise
%          error('bad mode!');
%    end
%    o  = subplot(o,'Signal',mode);      % set signal mode
%
%    change(o,'Bias','drift');           % change bias mode, update menu
%    change(o,'Config');                 % change config, rebuild & refresh
% end
%
% %==========================================================================
% % Plot Menu
% %==========================================================================
% 
% function oo = Plot(o)                  % Plot Menu                     
%    oo = plot(o,'Setup');               % setup Plot menu
%    plugin(oo,'$name/shell/Plot');
% end
%
% %==========================================================================
% % Analysis Menu
% %==========================================================================
% 
% function oo = Analysis(o)              % Analysis Menu                 
%    types = {'pln','smp'};              % supported types
%
%    oo = mhead(o,'Analysis');           % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = menu(oo,'Geometry',types);    % add Geometry menu
%    ooo = menu(oo,'Capability',types);  % capability number overview
%    plugin(oo,'$name/shell/Analysis');
% end
% function o = Overview(o)               % Overview About Cpk Values     
%    oo = mitem(o,'Cpk Overview');
%    set(mitem(oo,inf),'enable',onoff(o,{'pln','smp'}));
%    ooo = mitem(oo,'Actual Cpk',{@CpkCb,'stream','Actual'});
%    ooo = mitem(oo,'Fictive Cpk',{@CpkCb,'fictive','Fictive'});
%    return
% end
% function o = CpkCb(o)                  % Cpk Callbak                   
%    mode = arg(o,1);
%    label = arg(o,2);
% 
%    refresh(o,o);                    % use this function for refresh
% 
%    typ = type(current(o));
%    if ~o.is(typ,{'pln','smp'})
%       menu(current(o),'About');
%       return
%    end
%    
%    o = opt(o,'basket.type',typ);
%    o = opt(o,'basket.collect','*'); % all traces in basket
%    o = opt(o,'basket.kind','*');    % all kinds in basket
%    list = basket(o);
%    if (isempty(list))
%       message(o,'No plain or simple objects in basket!');
%    else
%       hax = cls(o);
%       n = length(list);
%       for (i=1:n)
%          oo = list{i};
%          oo = opt(oo,'mode.cook',mode);  % cooking mode
%          oo = opt(oo,'bias','absolute'); % in absolute mode
% 
%          [sub,col,cat] = config(o,'x');
%          [spec,limit,unit] = category(o,cat);
% 
%          x = cook(oo,'x');
%          y = cook(oo,'y');
% 
%          [Cpk,Cp,sig,avg,mini,maxi] = capa(oo,x(:)',spec);
%          Cpkx(i) = Cpk;
%          [Cpk,Cp,sig,avg,mini,maxi] = capa(oo,y(:)',spec);
%          Cpky(i) = Cpk;
%       end
% 
%       kind = o.assoc(oo.type,{{'pln','Plain'},{'smp','Simple'}});
%       subplot(211);
%       plot(1:n,Cpkx,'r',  1:n,Cpkx,'k.');
%       title(['Overview: ',label,' Cpk(x) of ',kind,' Objects']);
%       ylabel('Cpk(x)');
%       set(gca,'xtick',1:n);
% 
%       subplot(212);
%       plot(1:n,Cpky,'b',  1:n,Cpky,'k.');
%       title(['Overview: ',label,' Cpk(y) of ',kind,' Objects']);
%       ylabel('Cpk(y)');
%       set(gca,'xtick',1:n);
%    end
% end
%
% %==========================================================================
% % Study Menu
% %==========================================================================
% 
% function oo = Study(o)                 % Study Menu                  
%    oo = study(o,'Setup');               % add study menu
%    plugin(oo,'$name/shell/Study');
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
%    plugin(oo,'$name/shell/Info');
% end
%
% %==========================================================================
% % Read/Write Driver & Plot Configuration
% %==========================================================================
% 
% function oo = Read$NameDat(o)          % Read Driver for $name .dat  
%    path = arg(o,1);
%    oo = read(o,'ReadGenDat',path);
%    oo = Config(oo);                    % overwrite configuration
% end
% function oo = Write$NameDat(o)         % Read Driver for $name .dat  
%    path = arg(o,1);
%    oo = write(o,'WriteGenDat',path);
% end
% 
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
% function list = import(o,driver,ext)   % Import $NAME Object From File       
% %
% % IMPORT   Import $NAME object(s) from file
% %
% %             list = import(o,'LogData','.log')
% %
% %          See also: $NAME, IMPORT, EXPORT, READ, WRITE
% %
%    caption = sprintf('Import object from %s file',ext);
%    [files, dir] = fselect(o,'i',ext,caption);
%    
%    list = {};                          % init: empty object list
%    for (i=1:length(files))
%       path = [dir,files{i}];           % construct path
%       oo = read(o,driver,path);        % call read driver function
%       list{end+1} = oo;                % add imported object to list
%    end
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
% %             oo = export(o,'LogData','.log')
% %
% %          See also: $NAME, IMPORT, EXPORT, READ, WRITE
% %
%    name = get(o,{'title',''});
%    caption = sprintf('Export CARAMEL object to %s file',ext);
%    [file, dir] = fselect(o,'e',[lower(name),ext],caption);
%    
%    oo = [];                            % empty return value if fails
%    if ~isempty(file)
%       path = [dir,file];               % construct path
%       write(o,driver,path);            % write data to file
%       oo = o;                          % successful export
%    end
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
% %             oo = read(o,driver,path)
% %
% %             oo = read(o,'Read$NameLog',path)   % read .log data
% %             oo = read(o,'Read$NameDat',path)   % read .dat data
% %
% %          See also: $NAME, IMPORT, EXPORT, WRITE
% %
%    [gamma,oo] = manage(o,varargin,@Error,@Read$NameLog,@Read$NameDat);
%    oo = gamma(oo);
%    oo = launch(oo,launch(o));          % inherit launch function
% end
% 
% function o = Error(o)                  % Default Error Method
%    error('two input args expected!');
% end
% 
% %==========================================================================
% % Read Driver for $Name Data
% %==========================================================================
% 
% function oo = Read$NameLog(o)         % Read Driver for $Name .log   
%    path = arg(o,1);
%    [x,y,par] = Read(path);             % read data into variables x,y,par
%    
%    oo = $name('log');                  % create 'log' typed $NAME object
%    oo.par = par;                       % store parameters in object
%    oo.data.x = x';                     % store x-data in object
%    oo.data.y = y';                     % store y-data in object
%    oo = Config(oo);                    % overwrite configuration
%    return
%    
%    function [x,y,par] = Read(path)     % read log data (v1a/read.m)
%       fid = fopen(path,'r');
%       if (fid < 0)
%          error('cannot open log file!');
%       end
%       par.title = fscanf(fid,'$title=%[^\n]');
%       log = fscanf(fid,'%f',[2 inf])'; % transpose after fscanf!
%       x = log(:,1); y = log(:,2);
%    end
% end
% 
% function oo = Read$NameDat(o)         % Read Driver for $Name .dat   
%    path = arg(o,1);
%    oo = read(o,'ReadGenDat',path);
%    oo = Config(oo);                    % configure plotting
% end
% 
% %==========================================================================
% % Configuration of Plotting
% %==========================================================================
% 
% function o = Config(o)
%    o = subplot(o,'layout',1);       % layout with 1 subplot column   
%    o = subplot(o,'color',[1 1 1]);  % background color
%    o = config(o,[]);                % set all sublots to zero
% 
%    switch o.type
%       case 'log'
%          o = category(o,1,[-5 5],[0 0],'1');
%          o = config(o,'x',{1,'r',1});
%          o = config(o,'y',{2,'b',1});
%       case 'pln'
%          o = category(o,1,[-5 5],[0 0],'µ');
%          o = category(o,2,[-50 50],[0 0],'m°');
%          o = config(o,'x',{1,'r',1});
%          o = config(o,'y',{1,'b',1});
%          o = config(o,'p',{2,'g',2});
%       case 'smp'
%          o = category(o,1,[-5 5],[0 0],'µ');
%          o = category(o,2,[-50 50],[0 0],'m°');
%          o = category(o,3,[-0.5 0.5],[0 0],'µ');
%          o = config(o,'x',{1,'r',1});
%          o = config(o,'y',{1,'b',1});
%          o = config(o,'p',{2,'g',2});
%          o = config(o,'ux',{3,'m',3});
%          o = config(o,'uy',{3,'c',3});
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
% % WRITE   Write a $NAME object to file.
% %
% %             oo = write(o,driver,path) % return non-empty if successful
% %
% %             oo = write(o,'Write$NameLog',path)   % write .log file
% %             oo = write(o,'Write$NameDat',path)   % write .dat file
% %
% %          See also: $NAME, IMPORT, EXPORT, READ, WRITE
% %
%    [gamma,oo] = manage(o,varargin,@Error,@Write$NameLog,@Write$NameDat);
%    oo = gamma(oo);
%    oo = launch(oo,launch(o));          % inherit launch function
% end
% 
% function o = Error(o)                  % Default Error Method
%    error('two input args expected!');
% end
% 
% %==========================================================================
% % Write Driver for Log Data
% %==========================================================================
% 
% function oo = Write$NameLog(o)        % Write Driver for $Name .log  
%    path = arg(o,1);
%    oo = write(o,'WriteLogLog',path);
% end
% 
% %==========================================================================
% % Write Driver for $Name Data
% %==========================================================================
% 
% function oo = Write$NameDat(o)        % Write Driver for $Name .dat  
%    path = arg(o,1);
%    oo = write(o,'WriteGenDat',path);
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
% % PLOT   Cappuccino plot method
% %
% %           plot(o,'StreamX')          % stream plot X
% %           plot(o,'StreamY')          % stream plot Y
% %           plot(o,'Scatter')          % scatter plot
% %           plot(o,'Show')             % show object
% %           plot(o,'Animation')        % animation of object
% %
%    [gamma,oo] = manage(o,varargin,@Default,@Setup,@Plot,...
%                                   @StreamX,@StreamY,@Scatter);
%    oo = gamma(oo);
% end
% 
% function oo = Setup(o)                 % Setup Plot Menu               
%    oo = mhead(o,'Plot');               % add roll down header menu item
%    dynamic(oo);                        % make this a dynamic menu
%    ooo = mitem(oo,'Basic');
%    oooo = menu(ooo,'Plot');
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Stream Plot',{@Plot,'Stream'});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Stream Plot X',{@Plot,'StreamX'});
%    ooo = mitem(oo,'Stream Plot Y',{@Plot,'StreamY'});
%    ooo = mitem(oo,'Scatter Plot',{@Plot,'Scatter'});
% end
% function oo = Plot(o)                  % Plot Callback                 
%    args = arg(o,0);                    % get arg list
%    oo = arg(o,[{'Plot'},args]);        % add 'Plot' header to arg list
%    oo = cast(oo,'caramel');            % cast to caramel object
%    oo = plot(oo);                      % call plot(oo,'Plot')
% end
% function oo = Default(o)               % Default Plot Entry Point
%    co = cast(o,'caramel');             % cast to CARAMEL
%    oo = plot(co,'Default');            % delegate to caramel/plot
% end
%
% %==========================================================================
% % Local Plot Functions
% %==========================================================================
% 
% function oo = StreamX(o)               % Stream Plot X                 
%    oo = DoPlot(o,'StreamX');
% end
% function oo = StreamY(o)               % Stream Plot Y                 
%    oo = DoPlot(o,'StreamY');
% end
% function o = Scatter(o)                % Scatter Plot
%    oo = DoPlot(o,'Scatter');
% end
% 
% %==========================================================================
% % Auxillary Functions
% %==========================================================================
% 
% function oo = DoPlot(o,mode)           % actually do plotting
%    oo = current(o);
%    [idx,~] = config(oo,'x');           % is 'x' symbol supported?
%    [idy,~] = config(oo,'y');           % is 'y' symbol supported?
%    if ~isempty(idx) && ~isempty(idy)   % if both 'x' & 'y' symbol supported
%       co = cast(o,'carabao');
%       plot(co,mode);
%    else
%       menu(oo,'About');
%    end
% end
% $eof
end
function StudyTemplate                 % Study Template                
% %==========================================================================
% % Study Template
% %==========================================================================
%
% function oo = study(o,varargin)        % Study Menu                    
% %
% % STUDY   Manage Study menu
% %
% %           study(o,'Setup');          %  Setup STUDY menu
% %
% %           study(o,'Study1');         %  Study 1
% %           study(o,'Study2');         %  Study 2
% %           study(o,'Study3');         %  Study 3
% %           study(o,'Study4');         %  Study 4
% %
% %           study(o,'Signal');         %  Setup STUDY specific Signal menu
% %
% %        See also: $NAME, SHELL, PLOT
% %
%    [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,...
%                                   @Study1,@Study2,@Study3,@Study4);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Setup Study Menu
% %==========================================================================
% 
% function o = Setup(o)                  % Setup Study Menu              
%    Register(o);
%    
%    oo = mhead(o,'Study');
%    ooo = mitem(oo,'Sinc',{@invoke,mfilename,@Study1});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Trigonometric',{@Study2});
%    ooo = mitem(oo,'Exponential',{@Study3});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Damped Oscillation',{@Study4});
%    ooo = mitem(oo,'-');
%    ooo = Parameters(oo);
% end
% function o = Register(o)               % Register Some Stuff           
%    Config(type(o,'trigo'));            % register 'trigo' configuration
%    Config(type(o,'expo'));             % register 'expo' configuration
%    name = class(o);
%    plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
% end
%
% %==========================================================================
% % Configuration
% %==========================================================================
%
% function o = Signal(o)                 % Study Specific Signal Menu    
% %
% % SIGNAL   The Signal function is setting up type specific Signal menu 
% %          items which allow to change the configuration.
% %
%    switch active(o);                   % depending on active type
%       case {'trigo','expo'}
%          oo = mitem(o,'X',{@Config},'X');
%          oo = mitem(o,'Y',{@Config},'Y');
%          oo = mitem(o,'X/Y',{@Config},'XY');
%          oo = mitem(o,'X and Y',{@Config},'XandY');
%    end
% end
% function o = Config(o)                 % Install a Configuration
% %
% % CONFIG Setup a configuration
% %
% %           Config(type(o,'mytype'))   % register a type specific config
% %           oo = Config(arg(o,{'XY'})  % change configuration
% %
%    mode = o.either(arg(o,1),'XandY');  % get mode or provide default
%
%    o = config(o,[],active(o));         % set all sublots to zero
%    o = subplot(o,'Layout',1);          % layout with 1 subplot column   
%    o = subplot(o,'Signal',mode);       % set signal mode   
%    o = category(o,1,[-2 2],[],'µ');    % setup category 1
%    o = category(o,2,[-2 2],[],'µ');    % setup category 2
%    
%    switch type(o)                      % depending on active type
%       case 'expo'
%          colx = 'm';  coly = 'c';
%       otherwise
%          colx = 'r';  coly = 'b';
%    end
%       
%    switch mode
%       case {'X'}
%          o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
%       case {'Y'}
%          o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
%       case {'XY'}
%          o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
%          o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
%       otherwise
%          o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
%          o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
%    end
%    change(o,'Config');
% end
%
% %==========================================================================
% % Study
% %==========================================================================
% 
% function o = Study1(o)                 % Study 1                       
% %
% % STUDY1  Uses standard MATLAB functions. Plots cannot be configured
% %
%    om = 3*opt(o,'study.omega');        % omega
% 
%       % run the system
%       
%    t = 0:0.01:1;   
%    x = sin(om*t)./(om*t);  x(1) = 1;
%    
%       % plot graphics and provide title
%       
%    cls(o);  plot(t,x,'g'); 
%    title('Sinc Function');  shg;
% end
% function o = Study2(o)                 % Study 2                       
% %
% % STUDY2 Simulation data is stored in a $NAME object of type 'trigo',
% %        stored into clipboard for potential paste and plotted. If
% %        pasted (with Edit>Paste) object can be further analyzed using
% %        'Plot>Stream Plot'.
% %        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
% %        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
% %        while switching signal configurations in View/Signal menu.
% %
%    oo = $name('trigo');                % create a 'trigo' typed object
%    oo = log(oo,'t','x','y');           % setup a data log object
% 
%       % setup parameters and system matrix
%       
%    om = opt(o,'study.omega');  T = opt(o,'study.T');    % some parameters
%    A = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % system matrix
%    
%       % run the system
%       
%    x = [0 1]';                         % init system state  
%    for k = 1:100;
%       t = k*T;                         % actual time stamp
%       y = x + 0.1*randn(2,1);          % system output
%       
%       oo = log(oo,t,y(1),y(2));        % record log data
%       x = A*x;                         % state transition
%    end
%    
%       % define as working object, provide title and plot graphics
%       
%    oo = set(oo,'title',['Trigonometric @',o.now]);
%    plot(oo);                           % plot graphics
% end
% function o = Study3(o)                 % Study 3                       
% %
% % STUDY3 Simulation data is stored in a $NAME object of type 'expo',
% %        stored into clipboard for potential paste and plotted. If
% %        pasted (with Edit>Paste) object can be further analyzed using
% %        'Plot>Stream Plot'.
% %        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
% %        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
% %        while switching signal configurations in View/Signal menu.
% %
%    oo = $name('expo');                 % create an 'expo' typed object
%    oo = log(oo,'t','x','y');           % setup a data log object
% 
%          % setup parameters and system matrix
%       
%    T = opt(o,'study.T');
%    d = exp([opt(o,'study.damping1'), opt(o,'study.damping2')] * T);
%    A = diag(d);                        % system matrix
%    
%       % run the system
%    
%    x = [1.5 -0.5]';                    % init system state
%    for k = 0:100;
%       t = k*T;                         % actual time stamp
%       y = x + 0.1*randn(2,1);          % system output
%       
%       oo = log(oo,t,y(1),y(2));        % record log data
%       x = A*x;                         % state transition
%    end
% 
%       % define as working object, provide title and plot graphics
%       
%    oo = set(oo,'title',['Exponential @ ',o.now]);
%    plot(oo);                           % plot graphics
% end
% function o = Study4(o)                 % Study 4                       
% %
% % STUDY4 Repeated simulation data is stored in a $NAME object of type
% %        'trigo', stored into clipboard for potential paste and plotted.
% %        If pasted (with Edit>Paste) object can be further analyzed using
% %        'Plot>Stream Plot'.
% %        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
% %        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
% %        while switching signal configurations in View/Signal menu.
% %
%    oo = $name('trigo');                % create an 'trigo' typed object
%    oo = log(oo,'t','x','y');           % setup a data log object
% 
%          % setup parameters and system matrix
%       
%    T = opt(o,'study.T');
%    om = opt(o,'study.omega');
%    d = exp(opt(o,'study.damping1')*T);
%    S = [cos(om*T) sin(om*T); -sin(om*T) cos(om*T)];   % oscillation
%    A = S*diag([d d]);                  % system matrix
%    
%       % run the system
%    
%    t = 0;
%    for i = 1:10                        % 10 repeats
%       oo = log(oo);                    % next repeat
%       x = [1.5 -0.5]';                 % init time & system state
%       for k = 0:100;
%          y = x + 0.1*randn(2,1);       % system output
%       
%          oo = log(oo,t,y(1),y(2));     % record log data
%          x = A*x;                      % state transition
%          t = t + T;                    % time transition
%       end
%    end
% 
%       % define as working object, provide title and plot graphics
%       
%    oo = set(oo,'title',['Damped Oscillation @ ',o.now]);
%    plot(oo);                           % plot graphics
% end
% 
% %==========================================================================
% % Parameters
% %==========================================================================
% 
% function oo = Parameters(o)            % Parameters Sub Menu           
%    setting(o,{'study.T'},1/100);
%    setting(o,{'study.omega'},2*pi);
%    setting(o,{'study.damping1'},-2);
%    setting(o,{'study.damping2'},1);
%    
%    oo = mitem(o,'Parameters');
%    ooo = mitem(oo,'Omega','','study.omega'); 
%          charm(ooo,{});
%    ooo = mitem(oo,'Damping 1','','study.damping1'); 
%          charm(ooo,{});
%    ooo = mitem(oo,'Damping 2','','study.damping2'); 
%          charm(ooo,{});
% end
% 
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
