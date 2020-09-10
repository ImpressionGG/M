function oo = shell(o,varargin)        % BOOST shell                   
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
                  @Collect,@Config,@Import,@Export,@Signal,...
                  @Plot,@PlotCb,@Analysis,@Controller,@Study,...
                  @ReadBoostDat,@WriteBoostDat);
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
   oo = shell(o,'Controller');         % add Controller menu
   oo = shell(o,'Study');              % add Study menu
   oo = shell(o,'Plugin');             % add Plugin menu
   oo = shell(o,'Gallery');            % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = shell(o,'Figure');             % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = set(o,{'title'},'Boost Shell');
   o = set(o,{'comment'},{'Playing around with BOOST objects'});
   o = refresh(o,{'shell','Register'});% provide refresh callback function
   o = opt(o,{'mode.bias'},'absolute');
   o = opt(o,{'scale.xscale'},1000);
   o = opt(o,{'style.bullets'},1);
end
function o = Register(o)               % Register Plugins              
   o = Config(type(o,'smp'));          % register 'smp' configuration
   o = Config(type(o,'pln'));          % register 'pln' configuration
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Installing plugins ...');
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
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');

   ooo = mitem(oo,'Boost');
   oooo = mitem(ooo,'New Plain Boost',{@NewCb,'Plain','pln'});
   oooo = mitem(ooo,'New Simple Boost',{@NewCb,'Simple','smp'});
   plugin(oo,'boost/shell/New');
   return

   function oo = NewCb(o)              % Create New Object       
      mode = arg(o,1);
      typ = arg(o,2);
      oo = new(o,mode,typ);
      paste(o,{oo});
   end
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

   ooo = mitem(oo,'Boost');
   oooo = mitem(ooo,'Boost Data (.log)',{@ImportCb,'ReadBoostLog','.log',@boost});
   oooo = mitem(ooo,'Boost Data (.dat)',{@ImportCb,'ReadBoostDat','.dat',@boost});
   plugin(oo,'boost/shell/Import');
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

   ooo = mitem(oo,'Boost');
   %set(mitem(ooo,inf),'enable',onoff(o,{'log','pln','smp'},'boost'));
   oooo = mitem(ooo,'Boost Log Data (.log)',{@ExportCb,'WriteBoostLog','.log',@boost});
   %set(mitem(oooo,inf),'enable',onoff(o,'log','boost'));
   oooo = mitem(ooo,'Plain Boost (.dat)',{@ExportCb,'WriteBoostDat','.dat',@boost});
   %set(mitem(oooo,inf),'enable',onoff(o,'pln','boost'));
   oooo = mitem(ooo,'Simple Boost (.dat)',{@ExportCb,'WriteBoostDat','.dat',@boost});
   %set(mitem(oooo,inf),'enable',onoff(o,'smp','boost'));
   
   plugin(oo,'boost/shell/Export');  % plug point
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
   plugin(o,'boost/shell/Collect');   % plug point
   
   if isequal(class(o),'caramel')
      table = {{@read,'carabao','ReadStuffTxt','.txt'}};
      collect(o,{'weird','ball','cube'},table); 
   end
   if isequal(class(o),'boost')
      table = {{@read,'boost','ReadBoostDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   if isequal(class(o),'boost')
      table = {{@read,'boost','ReadBoostLog','.log'}};
      collect(o,{'log'},table); 
   end
   if isequal(class(o),'boost')
      table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
               {@read,'boost','ReadBoostDat','.dat'}};
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
   plugin(oo,'boost/shell/Signal');   % plug point
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

   change(o,'Bias','absolute');        % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = plot(o,'Setup');
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   types = {'pln','smp'};              % supported types

   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = menu(oo,'Geometry',types);    % add Geometry menu
   ooo = menu(oo,'Capability',types);  % capability number overview
   plugin(oo,'boost/shell/Analysis');
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
% Controller Menu
%==========================================================================

function oo = Controller(o)             % Study Menu                    
   oo = controller(o,'Setup');          % add controller menu
   plugin(oo,'boost/shell/Controller');
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = study(o,'Setup');               % add study menu
   plugin(oo,'boost/shell/Study');
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Boost Class: Version ',version(boost)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit boost/version');
   plugin(oo,'boost/shell/Info');
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadBoostDat(o)          % Read Driver for boost .dat    
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteBoostDat(o)         % Read Driver for boost .dat    
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

