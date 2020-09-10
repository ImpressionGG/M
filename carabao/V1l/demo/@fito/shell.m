function oo = shell(o,varargin)        % FITO Shell                    
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
                  @Collect,@Config,@Import,@Export,@Signal,...
                  @Plot,@PlotCb,@Analysis,@Study,...
                  @ReadFitoDat,@WriteFitoDat);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = shell(o,'File');               % add File menu
   oo = shell(o,'Edit');               % add Edit menu
   oo = shell(o,'View');               % add View menu
   oo = shell(o,'Select');             % add Select menu
   oo = wrap(o,'Plot');                % add Plot menu (wrapped)
   oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
   oo = Study(o);                      % add Study menus   
   oo = shell(o,'Plugin');             % add Plugin menu
   oo = shell(o,'Gallery');            % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = shell(o,'Figure');             % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   title = 'Filter Simulation';
   comment = {'We study several filters, such as'
              '1) Ordinary Order 1 Filters (PT1)'
              '2) Twin Filters (TWIN)'
              '3) Enhanced Twin Filters (XTWIN)'
              '4) Kalman Filters (KAFI)'
              '5) Regression Filters (REFI)'
             };

   o = set(o,{'title'},title);
   o = set(o,{'comment'},comment);
   
   o = opt(o,'mode.bias','absolute');
   o = opt(o,'style.overlays','time');
   o = refresh(o,{'shell','Register'});% provide refresh callback function
end
function o = Register(o)               % Register Plugins              
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Installing plugins ...');
   %sample(o,'Register');              % register SAMPLE plugin
   %basis(o,'Register');               % register BASIS plugin
   %pbi(o,'Register');                 % register PBI plugin
   rebuild(o);
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'Plot','Analysis'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = New(o)                   % New Menu Items                
   oo = menu(o,'New');                 % add CARAMEL New menu
   plugin(oo,'fito/shell/New');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Package',{@CollectCb});
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'General');
   oooo = mitem(ooo,'General Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@caramel});
   oooo = mitem(ooo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@caramel});

   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Text File (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@carabao});

   ooo = mitem(oo,'Fito');
   oooo = mitem(ooo,'Fito Data (.log)',{@ImportCb,'ReadFitoLog','.log',@fito});
   oooo = mitem(ooo,'Fito Data (.dat)',{@ImportCb,'ReadFitoDat','.dat',@fito});
   plugin(oo,'fito/shell/Import');
   return

   function o = ImportCb(o)            % Import Log Data Callback      
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method

      co = cast(o);                    % casted object
      list = import(co,drv,ext);       % import object from file
      paste(o,list);
   end
   function o = CollectCb(o)           % Collect All Files of Folder   
      list = collect(o);               % collect files in directory
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'Package');
   oooo = mitem(ooo,'Package Info (.pkg)',{@ExportCb,'WritePkgPkg','.pkg',@caramel});
   set(mitem(ooo,inf),'enable',onoff(o,'pkg'));
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Stuff');
   set(mitem(ooo,inf),'enable',onoff(o,{'weird','ball','cube'},'carabao'));
   oooo = mitem(ooo,'Text File (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@carabao});
   set(mitem(oooo,inf),'enable',onoff(o,{'pln','smp'},'carabao'));

   ooo = mitem(oo,'Fito');
   set(mitem(ooo,inf),'enable',onoff(o,{'log','pln','smp'},'fito'));
   oooo = mitem(ooo,'Fito Log Data (.log)',{@ExportCb,'WriteFitoLog','.log',@fito});
   set(mitem(oooo,inf),'enable',onoff(o,'log','fito'));
   oooo = mitem(ooo,'Plain Fito (.dat)',{@ExportCb,'WriteFitoDat','.dat',@fito});
   set(mitem(oooo,inf),'enable',onoff(o,'pln','fito'));
   oooo = mitem(ooo,'Simple Fito (.dat)',{@ExportCb,'WriteFitoDat','.dat',@fito});
   set(mitem(oooo,inf),'enable',onoff(o,'smp','fito'));
   
   plugin(oo,'fito/shell/Export');  % plug point
   return
   
   function oo = ExportCb(o)           % Export Callback
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
   plugin(o,'fito/shell/Collect');   % plug point
   
   if isequal(class(o),'caramel')
      table = {{@read,'carabao','ReadStuffTxt','.txt'}};
      collect(o,{'weird','ball','cube'},table); 
   end
   if isequal(class(o),'fito')
      table = {{@read,'fito','ReadFitoDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   if isequal(class(o),'fito')
      table = {{@read,'fito','ReadFitoLog','.log'}};
      collect(o,{'log'},table); 
   end
   if isequal(class(o),'fito')
      table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
               {@read,'fito','ReadFitoDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   oo = o;
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   oo = mhead(o,'Signal',{},'mode.signal');  % must provide Signal header!!  
   switch active(o);
      case {'pln'}
         ooo = mitem(oo,'X/Y and P',{@Config},'PlainXYP');
         ooo = mitem(oo,'X and Y',{@Config},'PlainXY');
      case {'smp'}
         ooo = mitem(oo,'All',{@Config},'SimpleAll');
         ooo = mitem(oo,'X/Y and P',{@Config},'SimpleXYP');
         ooo = mitem(oo,'UX and UY',{@Config},'SimpleU');
   end
   plugin(oo,'fito/shell/Signal');   % plug point
end
function o = Config(o)                 % Setup a Configuration         
%
%     Config(type(o,'mytype'))         % register a type specific config
%     oo = Config(arg(o,{'XY'})        % change configuration
%          
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[],'µ');    % setup category 1
   o = category(o,2,[-2 2],[],'µ');    % setup category 2
   
      % get mode and provide a proper type default if empty
      % (empty mode is provided during registration phase)
      
   mode = o.either(arg(o,1),o.type);  
   switch mode
      case 'PlainXYP'
         o = config(o,'x',{1,'r'});
         o = config(o,'y',{1,'b'});
         o = config(o,'p',{2,'g'});
      case {'PlainXY','pln'}
         o = config(o,'x',{1,'r'});
         o = config(o,'y',{2,'b'});
         mode = 'PlainXY';             % resolve default for type 'pln' 
      case {'SimpleAll','smp'}
         o = config(o,'x',{1,'r'});
         o = config(o,'y',{1,'b'});
         o = config(o,'p',{2,'g'});
         o = config(o,'ux',{3,'m'});
         o = config(o,'uy',{3,'c'});
         mode = 'SimpleAll';           % resolve default for type 'smp' 
      case 'SimpleXYP'
         o = config(o,'x',{1,'r'});
         o = config(o,'y',{1,'b'});
         o = config(o,'p',{2,'g'});
      case 'SimpleU'
         o = config(o,'ux',{1,'m'});
         o = config(o,'uy',{2,'c'});
      otherwise
         error('bad mode!');
   end
   o  = subplot(o,'Signal',mode);      % set signal mode

   change(o,'Bias','drift');           % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Basic');
   oooo = menu(ooo,'Plot');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot',{@menu 'PlotCb','Stream'});
   ooo = mitem(oo,'Overlay Plot',{@menu 'PlotCb','Overlay'});
   plugin(oo,'fito/shell/Plot');
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   types = {'fito'};                   % supported types

   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
%  ooo = menu(oo,'Geometry',types);    % add Geometry menu
%  ooo = menu(oo,'Capability',types);  % capability number overview
   ooo = study(oo,'Analysis');         % add study/Analysis menu items
   plugin(oo,'fito/shell/Analysis');
end
function o = Overview(o)               % Overview About Cpk Values     
   oo = mitem(o,'Cpk Overview');
   set(mitem(oo,inf),'enable',onoff(o,{'pln','smp'}));
   ooo = mitem(oo,'Actual Cpk',{@CpkCb,'stream','Actual'});
   ooo = mitem(oo,'Fictive Cpk',{@CpkCb,'fictive','Fictive'});
   return
end
function o = CpkCb(o)                  % Cpk Callbak                   
   mode = arg(o,1);
   label = arg(o,2);

   refresh(o,o);                    % use this function for refresh

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

         [sub,col,cat] = config(o,'x');
         [spec,limit,unit] = category(o,cat);

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
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = study(o,'Setup');              % register Study stuff
   oo = study(o,'Study');              % add Study menu
   oo = study(o,'Optimal');            % add Optimal menu
   oo = study(o,'Principles');         % add Principles menu
   plugin(oo,'fito/shell/Study');
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Fito Class: Version ',version(fito)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit fito/version');
   plugin(oo,'fito/shell/Info');
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadFitoDat(o)          % Read Driver for fito .dat      
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteFitoDat(o)         % Read Driver for fito .dat      
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end


