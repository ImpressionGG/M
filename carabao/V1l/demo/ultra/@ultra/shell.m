function oo = shell(o,varargin)        % ULTRA shell
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
                      @Collect,@Import,@Export,@Signal,@Plot,@PlotCb,...
                      @Analysis,@Config,@ReadUltraDat,@WriteUltraDat);
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
   oo = shell(o,'Plot');               % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = simu(o,'Setup');               % add Simu menu
   oo = jumbo(o,'Setup');              % add Simu menu
   oo = study(o,'Setup');              % add Study menu
   oo = shell(o,'Plugin');             % add Plugin menu
   oo = shell(o,'Gallery');            % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = shell(o,'Figure');             % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = set(o,{'title'},'Ultra Shell');
   o = set(o,{'comment'},{'Playing around with ULTRA objects'});
   o = refresh(o,{'shell','Register'});% provide refresh callback function
   o = opt(o,{'mode.bias'},'absolute');
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
   o = mseek(o,{'#','File','New'});
   oo = mitem(o,'Ultra');
   ooo = mitem(oo,'New Ultra',{@NewCb});
   plugin(oo,'ultra/shell/New');
   return

   function oo = NewCb(o)              % Create New Object       
      oo = new(o);
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

   ooo = mitem(oo,'Ultra');
   oooo = mitem(ooo,'Ultra Data (.log)',{@ImportCb,'ReadUltraLog','.log',@ultra});
   oooo = mitem(ooo,'Ultra Data (.dat)',{@ImportCb,'ReadUltraDat','.dat',@ultra});
   plugin(oo,'ultra/shell/Import');
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

   ooo = mitem(oo,'Ultra');
   set(mitem(ooo,inf),'enable',onoff(o,{'log','pln','smp'},'ultra'));
   oooo = mitem(ooo,'Ultra Log Data (.log)',{@ExportCb,'WriteUltraLog','.log',@ultra});
   set(mitem(oooo,inf),'enable',onoff(o,'log','ultra'));
   oooo = mitem(ooo,'Plain Ultra (.dat)',{@ExportCb,'WriteUltraDat','.dat',@ultra});
   set(mitem(oooo,inf),'enable',onoff(o,'pln','ultra'));
   oooo = mitem(ooo,'Simple Ultra (.dat)',{@ExportCb,'WriteUltraDat','.dat',@ultra});
   set(mitem(oooo,inf),'enable',onoff(o,'smp','ultra'));
   
   plugin(oo,'ultra/shell/Export');  % plug point
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
   plugin(o,'ultra/shell/Collect');   % plug point
   
   if isequal(class(o),'caramel')
      table = {{@read,'carabao','ReadStuffTxt','.txt'}};
      collect(o,{'weird','ball','cube'},table); 
   end
   if isequal(class(o),'ultra')
      table = {{@read,'ultra','ReadUltraDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   if isequal(class(o),'ultra')
      table = {{@read,'ultra','ReadUltraLog','.log'}};
      collect(o,{'log'},table); 
   end
   if isequal(class(o),'ultra')
      table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
               {@read,'ultra','ReadUltraDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   oo = o;
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   oo = mhead(o,'Signal');             % definitely provide Signal header  
   switch type(current(o));
      case {'pln'}
         ooo = mitem(oo,'X/Y and P',{@SignalCb,'PlainXYP'});
         ooo = mitem(oo,'X and Y',{@SignalCb,'PlainXY'});
      case {'smp'}
         ooo = mitem(oo,'All',{@SignalCb,'SimpleAll'});
         ooo = mitem(oo,'X/Y and P',{@SignalCb,'SimpleXYP'});
         ooo = mitem(oo,'UX and UY',{@SignalCb,'SimpleU'});
   end
   plugin(oo,'ultra/shell/Signal');   % plug point
   return
   
   function o = SignalCb(o)            % Signal Callback               
      mode = arg(o,1);                 % get callback mode
      o = Config(current(o));          % default configuration
      switch mode
         case 'PlainXYP'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'x',1);
            o = config(o,'y',1);
            o = config(o,'p',2);
         case 'PlainXY'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'x',1);
            o = config(o,'y',2);
         case 'SimpleAll'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'x',1);
            o = config(o,'y',1);
            o = config(o,'p',2);
            o = config(o,'ux',3);
            o = config(o,'uy',3);
         case 'SimpleXYP'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'x',1);
            o = config(o,'y',1);
            o = config(o,'p',2);
         case 'SimpleU'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'ux',1);
            o = config(o,'uy',2);
      end

      change(o,'bias','drift');        % change bias mode, update menu
      change(o,'config',o);            % change config, rebuild & refresh
   end
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = menu(oo,'Plot');
   plugin(oo,'ultra/shell/Plot');
end
function oo = PlotCb(o)                % Plot Callback                 
   refresh(o,o);                       % use this callback for refresh
   oo = plot(o);                       % forward to ultra.plot method
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Scatter',{@PlotCb 'Scatter'});  % scatter analysis
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                   
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Ultra Class: Version ',version(ultra)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit ultra/version');
   plugin(oo,'ultra/shell/Info');
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadUltraDat(o)          % Read Driver for ultra .dat  
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteUltraDat(o)         % Read Driver for ultra .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

function oo = Config(o)                % Configure Plotting            
   switch o.type
      case 'ultra'
         o = subplot(o,'layout',1);    % layout with 1 subplot column   
         o = category(o,1,[-200 200],[0 0],'nm');
         o = config(o,[]);             % set all sublots to zero
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'b',1});
         oo = o;
      otherwise
         oo = read(o,'Config');
   end
end
