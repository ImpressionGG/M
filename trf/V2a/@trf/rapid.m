function oo = rapid(o,varargin)        % Rapid Prototyping Shell       
%
% RAPID  Launch a rapid prototyping shell for creation of a derived
%        Carma class.
%
%           rapid(trf)                 % launch shell
%           rapid(trf,'pidstudy')      % new class name 'pidstudy'
%
%        See also: TRF, CORDOBA, CORAZON
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
   comment = {'Create a new class derived from TRF class'};
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
   ooo = mitem(oo,'Standard Shell, Plot/Study Method','','rapid.shell');
   check(ooo);
   ooo = mitem(oo,'Version Method','','rapid.version');
   check(ooo);

%  ooo = mitem(oo,'-');
%    
%  ooo = mitem(oo,'Simple Shell Method','','rapid.simple');
%  check(ooo);
%  ooo = mitem(oo,'Tiny Shell Method','','rapid.tiny');
%  check(ooo);
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
%  oo = CreateNew(oo);
   oo = CreatePlant(oo);
   oo = CreateController(oo);
   
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
      list{end+1} = ['   shell method: shell.m'];
%     list{end+1} = ['   new method: new.m'];
      list{end+1} = ['   plant method: plant.m'];
      list{end+1} = ['   controller method: controller.m'];
%     list{end+1} = ['   import method: import.m'];
%     list{end+1} = ['   export method: export.m'];
%     list{end+1} = ['   read method: read.m'];
%     list{end+1} = ['   write method: write.m'];
%     list{end+1} = ['   plot method: plot.m'];
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
   
   path = which('corazon');
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
   AddComment(o,['shell method @',name,'/shell.m created']);
%  oo = CreateMethod(o,'import','% % Import Template');
%  AddComment(o,['import method @',name,'/import.m created']);
%  oo = CreateMethod(o,'export','% % Export Template');
%  AddComment(o,['export method @',name,'/export.m created']);
%  oo = CreateMethod(o,'read','% % Read Template');
%  AddComment(o,['read method @',name,'/read.m created']);
%  oo = CreateMethod(o,'write','% % Write Template');
%  AddComment(o,['write method @',name,'/write.m created']);
%  oo = CreateMethod(o,'plot','% % Plot Template');
%  AddComment(o,['plot method @',name,'/plot.m created']);
   oo = CreateMethod(o,'study','% % Simu Template');
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
function oo = CreateNew(o)             % Create New Method             
   oo = CreateMethod(o,'new','% % New Template');
   name = opt(o,'classname');
   AddComment(o,['new method @',name,'/new.m created']);
end
function oo = CreatePlant(o)           % Create Plant Method           
   oo = CreateMethod(o,'plant','% % Plant Template');
   name = opt(o,'classname');
   AddComment(o,['plant method @',name,'/plant.m created']);
end
function oo = CreateController(o)      % Create Controller Method      
   oo = CreateMethod(o,'controller','% % Controller Template');
   name = opt(o,'classname');
   AddComment(o,['controller method @',name,'/controller.m created']);
end
function oo = CreateStudy(o)           % Create Study Method           
   oo = CreateMethod(o,'study','% % Study Template');
   name = opt(o,'classname');
   AddComment(o,['study method @',name,'/study.m created']);
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
%       end
%    end
% end
% $eof
end
function StandardShellTemplate         % Standard Shell Template       
% %==========================================================================
% % Standard Shell Template
% %==========================================================================
%
% function oo = shell(o,varargin)        % $NAME shell                    
%    [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@View,@Signal,...
%                                  @Plot,@Analysis);
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
%    oo = shell(o,'Edit');               % add Edit menu
%    oo = shell(o,'View');               % add View menu
%    oo = shell(o,'Select');             % add Select menu
%    oo = wrap(o,'Plot');                % add Plot menu (wrapped)
%    oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
%    oo = study(o);                      % add Study menu
%    oo = menu(o,'Gallery');             % add Gallery menu
%    oo = Info(o);                       % add Info menu
%    oo = menu(o,'Figure');              % add Figure menu
%    o = menu(o,'End');                  % end menu setup (will refresh)
% end
% function o = Init(o)                   % Init Object                   
% %
% % INIT   When a transfer function object is initialized for the shell
% %        a CORDOBA shell object is created with the TRF object contained
% %        as a single child.
% %
%    if ~container(o)
%       oo = provide(o,'par.title','Transfer Function');
%    
%       o = trf('shell');                % create another TRF shell object
%       o.data = {oo};                   % add children list with TRF
%       o = control(o,{'current'},1);    % select current object
%    end
%    
%    o = dynamic(o,true);                % setup as a dynamic shell
%    o = launch(o,mfilename);            % setup launch function
%    
%    o = provide(o,'par.title','$NAME Shell');
%    o = provide(o,'par.comment',{'study & analysis of transfer functions'});
%    o = refresh(o,{'menu','About'});    % provide refresh callback function
%    
%       % setup filter window
%       
%    o = opt(o,{'filter.window'},100);      
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
% function oo = New(o)                   % New Menu Items                
%    oo = mseek(o,{'New'});
%    ooo = mitem(oo,'-');
%    ooo = plant(oo);                    % add New/Plant sub menu
%    ooo = controller(oo);               % add New/Controller sub menu
%    ooo = new(oo,'System');             % add New/System sub menu
%    ooo = mitem(oo,'-');
%    ooo = new(oo,'Stuff');              % add New/Stuff sub menu
% end
% function oo = Import(o)                % Import Menu Items             
%    oo = mhead(o,'Import');             % locate Import menu header
%    ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@trf});
%    ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'LogData','.log',@trf});
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
%    ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'TextFile','.txt',@trf});
%    ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'LogData','.log',@trf});
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
%    co = cast(o,'cordoba');             % casted object
%    oo = shell(co,'View');              % add CORDOBA View menu
%    ooo = mseek(oo,{'Scale','Time Scale'});
%    oooo = ScaleTime(ooo);              % add Scale/Time menu
%    ooo = mseek(oo,{'Scale'});
%    oooo = ScaleBode(ooo);              % add Scale/Bode menu
% end
% function o = Signal(o)                 % Signal Menu                   
% %
% % SIGNAL   The Sinal function is responsible for both setting up the 
% %          'Signal' menu head and the subitems which are dynamically 
% %          depending on the type of the current object
% %
%    oo = mhead(o,'Signal',{},'mode.signal');  % must provide Signal header!!  
%    plugin(oo,'$name/shell/Signal');    % plug point
% end
% function oo = ScaleBode(o)             % Scale/Bode Menu               
%    setting(o,{'scale.omega.low'},1e-2);
%    setting(o,{'scale.omega.high'},1e5);
%    setting(o,{'scale.magnitude.low'},-80);
%    setting(o,{'scale.magnitude.high'},80);
%    setting(o,{'scale.phase.low'},-270);
%    setting(o,{'scale.phase.high'},90);
%    
%    oo = mitem(o,'Bode Scale');
%    ooo = mitem(oo,'Lower Frequency',{},'scale.omega.low');
%          choice(ooo,[1e-2,1e-1,1e0,1e1,1e2,1e3],{});
%    ooo = mitem(oo,'Upper Frequency',{},'scale.omega.high');
%          choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8],{});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Lower Magnitude',{},'scale.magnitude.low');
%          choice(ooo,[-100:10:-20],{});
%    ooo = mitem(oo,'Upper Magnitude',{},'scale.magnitude.high');
%          choice(ooo,[20:10:100],{});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Lower Phase',{},'scale.phase.low');
%          choice(ooo,[-270:45:-90],{});
%    ooo = mitem(oo,'Upper Phase',{},'scale.phase.high');
%          choice(ooo,[-90:45:135],{});
% end
% function oo = ScaleTime(o)             % Scale/Time Menu               
%    setting(o,{'scale.time.low'},0);
%    setting(o,{'scale.time.high'},10);
%    setting(o,{'scale.amplitude.low'},-0.2);
%    setting(o,{'scale.amplitude.high'},1.6);
%    
%    oo = o;
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Maximum Time',{},'scale.time.high');
%          choice(ooo,[1e-5,1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3],{});
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'Lower Amplitude',{},'scale.amplitude.low');
%          choice(ooo,[-100:10:-20],{});
%    ooo = mitem(oo,'Upper Amplitude',{},'scale.amplitude.high');
%          choice(ooo,[20:10:100],{});
% end
% 
% %==========================================================================
% % Plot Menu
% %==========================================================================
% 
% function oo = Plot(o)                  % Plot Menu                     
%    co = cast(o,'trf');
%    oo = shell(co,'Plot');              % delegate to trf/shell/Plot
% end
% 
% %==========================================================================
% % Analysis Menu
% %==========================================================================
% 
% function oo = Analysis(o)              % Analysis Menu                 
%    co = cast(o,'trf');
%    oo = shell(co,'Analysis');          % delegate to trf/shell/Plot
% end
% 
% %==========================================================================
% % Info Menu
% %==========================================================================
% 
% function oo = Info(o)                  % Info Menu                     
%    oo = menu(o,'Info');                % add Info menu
%    ooo = mseek(oo,{'Version'});
%    oooo = mitem(ooo,['Trf Class: Version ',version($name)]);
%    ooooo = mitem(oooo,'Edit Release Notes','edit $name/version');
% end
% $eof
end
function NewTemplate                   % New Template                  
% %==========================================================================
% % New Template
% %==========================================================================
% 
% function oo = new(o,varargin)          % $Name Plot Method
% %
% % NEW   $Name new method
% %
% %           new(o,'Setup')             % setup menu
% %           new(o,'PT1')               % PT1 Transfer Function
% %
%    [gamma,oo] = manage(o,varargin,@New,@PT1);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Menu Setup
% %==========================================================================
% 
% function oo = New(o)                   % New Menu Items                
%    oo = mseek(o,{'New'});
%    ooo = mitem(oo,'-');
%    ooo = Stuff(oo);                    % add New/Stuff sub menu
%    ooo = Systems(oo);                  % add New/Systems sub menu
% end
% function o = Stuff(o)
%    oo = mitem(o,'Stuff');
%    ooo = shell(oo,'Stuff','weird');
%    ooo = shell(oo,'Stuff','ball');
%    ooo = shell(oo,'Stuff','cube');
% end
%
% %==========================================================================
% % System Creation
% %==========================================================================
% 
% function o = Systems(o)                % add New/Systems menu          
%    oo = mitem(o,'Systems');
%    ooo = mitem(oo,'Integrator',{@INT});
%    ooo = mitem(oo,'PT1 System',{@PT1});
%    ooo = mitem(oo,'PT2 System',{@PT2});
% end
% function oo = INT(o)                   % New Integrator                 
% %
% % INT   Create a system with transfer function 
% %                      1    
% %          G(s) = ------------    % T = 1
% %                   1 + s*Ti
% %
%    if o.is(type(o),'INT')
%       oo = o;
%       Ti = get(oo,'Ti');
%    else
%       Ti = 1;                          % integration time constant
%
%       oo = trf(1,[Ti 0]);              % transfer function
%       oo = set(oo,'init','INT');
%       oo = set(oo,'Ti',Ti);
%    end
%    
%    head = 'I(s) = 1 / (s*Ti)';
%    params = sprintf('Ti = %g',Ti);
%
%    oo = update(oo,'Integrator',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% function oo = PT1(o)                   % New PT1 System                 
% %
% % PT1   Create a system with transfer function 
% %                      V
% %          G(s) = -----------          % V = 1, T = 5
% %                   1 + s*T
% %
%    if o.is(type(o),'PT1')
%       oo = o;
%       [V,T] = get(oo,'V','T');
%    else
%       V = 1;                           % gain
%       T = 5;                           % time constant
%
%       oo = trf(1,[T 1]);               % transfer function
%       oo = set(oo,'init','PT1');
%       oo = set(oo,'V',V,'T',T);
%    end
%
%    head = 'PT1(s) = V / (1 + s*T)';
%    params = sprintf('V = %g, T = %g',V,T);
%
%    oo = update(oo,'PT1 System',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% function oo = PT2(o)                   % New PT2 System                 
% %
% % PT2   Create a system with transfer function 
% %                            V
% %          G(s) = -------------------------    % V = 1, T = 5, D = 0.7 
% %                   1 + 2*D*(s*T) + (s*T)^2
% %
%    if o.is(type(o),'PT2')
%       oo = o;
%       [V,T,D] = get(oo,'V','T','D');
%    else
%       V = 1;                           % gain
%       T = 5;                           % time constant
%       D = 0.7;                         % damping
%
%       oo = trf(V,{},{[1/T,D]});        % transfer function
%       oo = set(oo,'init','PT2');
%       oo = set(oo,'V',V,'T',T,'D',D);
%    end
%    
%    head = 'PT2(s) = V / (1 + 2*D*(s*T) + (s*T)^2)';
%    params = sprintf('V = %g, T = %g, D = %g',V,T,D);
%
%    oo = update(oo,'PT2 System',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% $eof
end
function PlantTemplate                 % Plant Template                
% %==========================================================================
% % Plant Template
% %==========================================================================
% 
% function oo = plant(o,varargin)      % $Name Plant Method
% %
% % PLANT   Create a new plant pbject
% %
% %           plant(o,'IPT1')            % create I-PT1 plant model
% %           plant(o,'AXIS')            % create simple axis model
% %           plant(o,'GANTRY')          % create gantry model 
% %
%    [gamma,oo] = manage(o,varargin,@Plant,@IPT1,@AXIS,@GANTRY);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Menu Setup
% %==========================================================================
% 
% function oo = Plant(o)                 % Plant Menu Setup              
%    oo = mitem(o,'Plant');
%    ooo = mitem(oo,'I-PT1 Plant',{@IPT1});
%    ooo = mitem(oo,'Axis on Base',{@AXIS});
%    ooo = mitem(oo,'Gantry on Base',{@GANTRY});
% end
% 
% %==========================================================================
% % Actual Plant Model Creation
% %==========================================================================
% 
% function oo = IPT1(o)                  % New I-PT1 Plant Model         
% %
% % IPT1   Create an I-PT1 plant model with transfer function 
% %                         V    
% %          G(s) = -----------------    % V = 1, T = 1
% %                   s * (1 + s*T)
% %
%    if o.is(type(o),'IPT1')
%       oo = o;
%       [V,T] = get(oo,'V','T');
%    else
%       V = 1;                           % gain factor
%       T = 1;                           % dominant time constant
% 
%       oo = trf(V,[T 1 0]);             % transfer function
%       oo = set(oo,'init','IPT1');
%       oo = set(oo,'V',V,'T',T);
%    end
%    
%    head = 'IPT1(s) = V / [s * (s*T + 1)]';
%    params = sprintf('V = %g, T = %g',V,T);
% 
%    oo = update(oo,'I-PT1 Plant',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% function oo = AXIS(o)                  % New Axis on Base Plant Model  
% %
% % AXIS   Create a system with transfer function 
% %                      V
% %          G(s) = -----------          % V = 1, T = 5
% %                   1 + s*T
% %
%    if o.is(type(o),'PT1')
%       oo = o;
%       [V,T] = get(oo,'V','T');
%    else
%       V = 1;                           % gain
%       T = 5;                           % time constant
% 
%       oo = trf(1,[T 1]);               % transfer function
%       oo = set(oo,'init','PT1');
%       oo = set(oo,'V',V,'T',T);
%    end
% 
%    head = 'PT1(s) = V / (1 + s*T)';
%    params = sprintf('V = %g, T = %g',V,T);
% 
%    oo = update(oo,'PT1 System',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% function oo = GANTRY(o)                % New Gantry on Base Plant Model
% %
% % PT2   Create a system with transfer function 
% %                            V
% %          G(s) = -------------------------    % V = 1, T = 5, D = 0.7 
% %                   1 + 2*D*(s*T) + (s*T)^2
% %
%    if o.is(type(o),'PT2')
%       oo = o;
%       [V,T,D] = get(oo,'V','T','D');
%    else
%       V = 1;                           % gain
%       T = 5;                           % time constant
%       D = 0.7;                         % damping
% 
%       oo = trf(V,{},{[1/T,D]});        % transfer function
%       oo = set(oo,'init','PT2');
%       oo = set(oo,'V',V,'T',T,'D',D);
%    end
%    
%    head = 'PT2(s) = V / (1 + 2*D*(s*T) + (s*T)^2)';
%    params = sprintf('V = %g, T = %g, D = %g',V,T,D);
% 
%    oo = update(oo,'PT2 System',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
% $eof
end
function ControllerTemplate            % Controller Template           
% %==========================================================================
% % Controller Template
% %==========================================================================
% 
% function oo = controller(o,varargin)   % $Name Controller Method
% %
% % CONTROLLER   Create a new controller pbject
% %
% %           controller(o,'R1')         % create R1 controller
% %           controller(o,'R2')         % create R2 controller
% %
%    [gamma,oo] = manage(o,varargin,@Controller,@R1,@R2);
%    oo = gamma(oo);
% end
% 
% %==========================================================================
% % Menu Setup
% %==========================================================================
% 
% function oo = Controller(o)            % Controller Menu Setup
%    co = cast(o,'trf');                 % cast to TRF object
%    oo = controller(co);                % add New/Controller menu
%    ooo = mitem(oo,'-');
%    ooo = mitem(oo,'R1 Controller',{@R1});
%    ooo = mitem(oo,'R2 Controller',{@R2});
% end
% 
% %==========================================================================
% % Actual Controller Creation
% %==========================================================================
% 
% function oo = R1(o)                    % New R1 Controller         
% %
% % R1   Create a lead type controller with transfer function 
% %
% %                       1 + s/(om/sqrt(N))    
% %          R1(s) = V * --------------------   % V = 1, om = 1, N = 10
% %                       1 + s/(om*sqrt(N))
% %
%    if o.is(type(o),'R1')
%       oo = o;
%       [V,om,N] = get(oo,'V','om','N');
%    else
%       V = 1;                           % gain factor
%       om = 1;                          % design frequency
%       N = 10;                          % working range
%
%       oo = trf(V*[1/(om/sqrt(N)) 1],[1/(om*sqrt(N)) 1]);
%       oo = set(oo,'init','R1');
%       oo = set(oo,'V',V,'om',om,'N',N);
%    end
%    
%    head = 'R1(s) = V * [1 + s/(om/sqrt(N))] / [1 + s/(om*sqrt(N))]';
%    params = sprintf('V = %g, om = %g, N = %g',V,om,N);
% 
%    oo = update(oo,'R1 Controller',{head,params});
%    paste(o,{oo});                      % paste transfer function
% end
%
% function oo = R2(o)                    % New R2 Controller         
% %
% % R2   Create a lag type controller with transfer function
% %
% %                       1 + s/(om*sqrt(N))    
% %          R2(s) = V * --------------------   % V = 1, om = 1, N = 10
% %                       1 + s/(om/sqrt(N))
% %
%    if o.is(type(o),'R2')
%       oo = o;
%       [V,om,N] = get(oo,'V','om','N');
%    else
%       V = 1;                           % gain factor
%       om = 1;                          % design frequency
%       N = 10;                          % working range
%
%       oo = trf(V*[1/(om*sqrt(N)) 1],[1/(om/sqrt(N)) 1]);
%       oo = set(oo,'init','R2');
%       oo = set(oo,'V',V,'om',om,'N',N);
%    end
%    
%    head = 'R2(s) = V * [1 + s/(om*sqrt(N))] / [1 + s/(om/sqrt(N))]';
%    params = sprintf('V = %g, om = %g, N = %g',V,om,N);
% 
%    oo = update(oo,'R2 Controller',{head,params});
%    paste(o,{oo});                      % paste transfer function
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
% function oo = Default(o)               % Default Plot Entry Point
%    co = cast(o,'cordoba');             % cast to CORDOBA
%    oo = plot(co,'Default');            % delegate to cordoba/plot
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
%    [idx,~] = config(oo,'x');         % is 'x' symbol supported?
%    [idy,~] = config(oo,'y');         % is 'y' symbol supported?
%    if ~isempty(idx) && ~isempty(idy) % if both 'x' & 'y' symbol supported
%       co = cast(o,'corazon');
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
% function oo = study(o,varargin)         % Study Menu                   
% %
% % STUDY  Manage simulation menu
% %
% %           study(o,'Setup');           %  Setup Study menu
% %
% %           study(o,'Study1');          %  Study 1
% %           study(o,'Study2');          %  Study 2
% %           study(o,'Study3');          %  Study 3
% %           study(o,'Study4');          %  Study 4
% %
% %           study(o,'Signal');          %  Setup STUDY specific Signal menu
% %
% %        See also: $NAME, SHELL, PLOT
% %
%    [gamma,oo] = manage(o,varargin,@Setup,@Signal,@Analyse,...
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
% function o = Signal(o)                 % Simu Specific Signal Menu                   
% %
% % SIGNAL   The Sinal function is responsible for both setting up the 
% %          'Signal' menu head and the subitems which are dynamically 
% %          depending on the type of the current object
% %
%    switch active(o);                   % depending on active type
%       case {'trigo','expo'}
%          oo = mitem(o,'X',{@Config},'X');
%          oo = mitem(o,'Y',{@Config},'Y');
%          oo = mitem(o,'X/Y',{@Config},'XY');
%          oo = mitem(o,'X and Y',{@Config},'X_Y');
%    end
% end
% function o = Config(o)                 % Install a Configuration       
%    mode = o.either(arg(o,1),'X_Y');
%    
%    o = config(o,[],active(o));         % set all sublots to zero
%    o = subplot(o,'Layout',1);          % layout with 1 subplot column   
%    o = subplot(o,'Signal',mode);       % set signal mode   
%    o = category(o,1,[-2 2],[0 0],'�'); % setup category 1
%    
%    switch type(o)
%       case 'expo'
%          colx = 'm';  coly = 'c';
%       otherwise
%          colx = 'r';  coly = 'b';
%    end
%    switch mode
%       case {'X'}
%          o = config(o,'x',{1,colx,1}); % configure 'x' for 1st subplot
%       case {'Y'}
%          o = config(o,'y',{1,coly,1}); % configure 'y' for 2nd subplot
%       case {'XY'}
%          o = config(o,'x',{1,colx,1}); % configure 'x' for 1st subplot
%          o = config(o,'y',{1,coly,1}); % configure 'y' for 2nd subplot
%       case {'X_Y'}
%          o = config(o,'x',{1,colx,1}); % configure 'x' for 1st subplot
%          o = config(o,'y',{2,coly,1}); % configure 'y' for 2nd subplot
%    end
%    change(o,'Bias','absolute');
%    change(o,'Config');                 % change config, rebuild & refresh
% end
%
% %==========================================================================
% % Simulations
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
%    title('Sinc Function');  shg
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
%    oo = cordoba('trigo');              % create a 'trigo' typed object
%    oo = log(oo,'t,x,y');               % setup a data log object
% 
%       % setup parameters and system matrix
%       
%    om = opt(o,'study.omega');  T = opt(o,'study.T');  % some parameters
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
%       % provide title and plot graphics
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
%    oo = cordoba('expo');               % create an 'expo' typed object
%    oo = log(oo,'t,x,y');               % setup a data log object
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
%       % provide title and plot graphics
%       
%    oo = set(oo,'title',['Exponential @ ',o.now]);
%    plot(oo);                           % plot graphics & put in clip board
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
%    oo = cordoba('trigo');              % create an 'trigo' typed object
%    oo = log(oo,'t,x,y');               % setup a data log object
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
%       x = [1.5 -0.5]';                 % init system state
%       for k = 0:100;
%          y = x + 0.1*randn(2,1);       % system output
%       
%          oo = log(oo,t,y(1),y(2));     % record log data
%          x = A*x;                      % state transition
%          t = t + T;                    % time transition
%       end
%    end
% 
%       % provide title and plot graphics
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
%    ooo = mitem(oo,'Omega',{},'study.omega'); 
%          charm(ooo,{});
%    ooo = mitem(oo,'Damping 1',{},'study.damping1'); 
%          charm(ooo,{});
%    ooo = mitem(oo,'Damping 2',{},'study.damping2'); 
%          charm(ooo,{});
% end
% 
% $eof
end
function VersionTemplate                 % Version Template              
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
