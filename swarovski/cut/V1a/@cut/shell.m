function oo = shell(o,varargin)        % CUT shell                     
%
% SHELL   CUT Shell
%
%         See also: CUT, MENU
%
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Register,...
                        @File,@New,@Import,@Export,@Collect,@Extras,...
                        @Edit,@Property,@View,@Signal,@Select,@Plot,...
                        @Analysis,@Info,@ConfigUpCam,@ConfigAB);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Edit(o);                       % add Edit menu
   oo = View(o);                       % add View menu
   oo = Select(o);                     % add Select menu
   oo = wrap(o,'Plot');                % add Plot menu (wrapped)
   oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
   oo = Study(o);                      % add Study menu
   oo = Plugin(o);                     % add Plugin menu
   oo = Gallery(o);                    % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = Figure(o);                     % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = menu(o,'Default');              % provide CUT defaults

   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = opt(o,{'mode.bias'},'drift');
   o = refresh(o,{@shell,'Register'}); % provide refresh callback function
end
function o = Register(o)               % Register Plugins              
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Register Plugins ...');  % progress message
   cutlog(o,'Register');               % register CUTLOG plugin
   spm(o,'Register');                  % register SPM plugin
   sample(o,'Register');               % register SAMPLE plugin
   plugin(o,'cut/shell/Register');     % plug point
   rebuild(o);
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'Plot','Analysis'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = shell(oo,'New');              % add New menu
   ooo = shell(oo,'Collect');          % configure collection
   ooo = shell(oo,'Import');           % add Import menu items
   ooo = wrap(oo,'Export');            % add Export menu items (wrapped)
   ooo = shell(oo,'Extras');           % add Extra menu
   plugin(oo,'cut/shell/File');    % plug point
end
function oo = New(o)                   % New Menu Items                
   oo = menu(o,'New');                 % add cut New menu
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');
   plugin(oo,'cut/shell/New');     % plug point
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Package',{@CollectCb});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'General');
   oooo = mitem(ooo,'General Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@cut});
   oooo = mitem(ooo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@cut});

   ooo = mitem(oo,'Article');
   oooo = mitem(ooo,'Article (.art)',{@ImportCb,'ReadGenDat','.art',@cut});

   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Text File (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   plugin(oo,'cut/shell/Import');      % plug point
   return

   function o = ImportCb(o)            % Import Log Data Callback      
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
   function o = CollectCb(o)           % Collect All Files of Folder   
      collect(o,{})                    % reset collection config
      table0 = {{@read,'cordoba','ReadPkgPkg','.pkg'},...
                {@read,'cut','ReadCulCsv', '.csv'}};
      collect(o,{},table0);            % only default table

      list = collect(o);               % collect files in directory
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'Package');
   oooo = mitem(ooo,'Package Info (.pkg)',{@ExportCb,'WritePkgPkg','.pkg',@cut});
          set(mitem(ooo,inf),'enable',onoff(o,'pkg'));
   ooo = mitem(oo,'-');
   
   ooo = mitem(oo,'General');
   oooo = mitem(ooo,'General Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@cut});
   oooo = mitem(ooo,'Package Info (.pkg)',{@ExportCb,'WritePkgPkg','.pkg',@cut});

   ooo = mitem(oo,'Article');
   oooo = mitem(ooo,'Article (.art)',{@ExportCb,'WriteGenDat','.art',@cut});

   ooo = mitem(oo,'Stuff');
   set(mitem(ooo,inf),'enable',onoff(o,{'weird','ball','cube'}));
   oooo = mitem(ooo,'Text File (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   
   plugin(oo,'cut/shell/Export');  % plug point
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
         export(co,drv,ext);           % export object to file
      end
   end
end
function oo = Collect(o)               % Configure Collection          
   collect(o,{});                      % reset collection config
   plugin(o,'cut/shell/Collect');  % plug point
   
   if isequal(class(o),'cut')
      table = {{@read,'corazon','ReadStuffTxt','.txt'}};
      collect(o,{'weird','ball','cube'},table); 
   end
   oo = o;
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
%==========================================================================
% Edit Menu
%==========================================================================

function oo = Edit(o)                  % Edit Menu                     
   oo = menu(o,'Edit');                % add Edit menu
   plugin(oo,'cut/shell/Edit');    % plug point
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
   oo = menu(o,'View');                % add View menu
   ooo = mseek(oo,{'Style'});          % seek View>Style menu entry
   plugin(ooo,'cut/shell/Style');  % plug point
   ooo = wrap(oo,'Signal');            % Wrap Signal Menu
   plugin(oo,'cut/shell/View');    % plug point
end
function oo = Signal(o)                % Plotting Menu                 
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   atype = active(o);                  %  get active type
   if isempty(atype)
      mode = '';
   else
      oo = type(o,atype);              % make an object with active type
      mode = subplot(o,'Signal');
   end
   
   tag = 'mode.signal';
   setting(o,tag,mode);
   
   oo = mhead(o,'Signal',{},tag);      % definitely provide Signal header! 
   signal(oo,NaN);                     % refresh signal menu
   plugin(oo,'cut/shell/Signal');  % plug point
   %plugin(oo,[o.tag,'/shell/Signal']);% alternative plug point
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   plugin(oo,'cut/shell/Select');  % plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   if isequal(o.type,'weird')
      o = corazon(o);
      oo = shell(o,'Plot');            % delegate to shell@corazon>Plot
   else
      oo = mhead(o,'Plot');
      dynamic(oo);                     % make this a dynamic menu
      ooo = menu(oo,'Plot');           % delegate to menu@cut>Plot
   end
   plugin(oo,'cut/shell/Plot');    % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   types = {'pln','smp'};
   
   oo = menu(o,'Analysis');            % add Analysis menu
   ooo = menu(oo,'Capability',types);  % add Capability menu
   plugin(oo,'cut/shell/Analysis');% plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study',{},[],'visible','off');
   oo = study(o);                      % setup study menu
   plugin(oo,'cut/shell/Study');   % plug point
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu                   
   oo = menu(o,'Plugin',{},'','visible','off');     % menu will be hidden
   oo = plugin(oo,'cut/shell/Plugin');
end

%==========================================================================
% Gallery Menu
%==========================================================================

function oo = Gallery(o)               % Gallery Menu                  
   oo = menu(o,'Gallery');             % add Gallery menu
   plugin(oo,'cut/shell/Gallery'); % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['CUT Class: Version ',version(cut)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit cut/version');
   plugin(oo,'cut/shell/Info');    % plug point
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = Figure(o)                % Figure Menu                   
   oo = menu(o,'Figure');              % add Figure menu
   plugin(oo,'cut/shell/Figure');  % plug point
end
