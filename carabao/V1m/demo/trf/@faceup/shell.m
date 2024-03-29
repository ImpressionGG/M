function oo = shell(o,varargin)        % FACEUP shell
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
                  @Collect,@Config,@Import,@Export,@Signal,...
                  @Plot,@PlotCb,@Analysis,@Simulation,...
                  @ReadFaceupDat,@WriteFaceupDat);
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
   oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
   oo = shell(o,'Simulation');         % add Simulation menu
   oo = shell(o,'Plugin');             % add Plugin menu
   oo = shell(o,'Gallery');            % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = shell(o,'Figure');             % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = set(o,{'title'},'Faceup Shell');
   o = set(o,{'comment'},{'Playing around with FACEUP objects'});
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
   oo = menu(o,'New');                 % add CARAMEL New menu
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');

   ooo = mitem(oo,'Faceup');
   oooo = mitem(ooo,'New Plain Faceup',{@NewCb,'Plain','pln'});
   oooo = mitem(ooo,'New Simple Faceup',{@NewCb,'Simple','smp'});
   plugin(oo,'faceup/shell/New');
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

   ooo = mitem(oo,'Faceup');
   oooo = mitem(ooo,'Faceup Data (.log)',{@ImportCb,'ReadFaceupLog','.log',@faceup});
   oooo = mitem(ooo,'Faceup Data (.dat)',{@ImportCb,'ReadFaceupDat','.dat',@faceup});
   plugin(oo,'faceup/shell/Import');
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

   ooo = mitem(oo,'Faceup');
   set(mitem(ooo,inf),'enable',onoff(o,{'log','pln','smp'},'faceup'));
   oooo = mitem(ooo,'Faceup Log Data (.log)',{@ExportCb,'WriteFaceupLog','.log',@faceup});
   set(mitem(oooo,inf),'enable',onoff(o,'log','faceup'));
   oooo = mitem(ooo,'Plain Faceup (.dat)',{@ExportCb,'WriteFaceupDat','.dat',@faceup});
   set(mitem(oooo,inf),'enable',onoff(o,'pln','faceup'));
   oooo = mitem(ooo,'Simple Faceup (.dat)',{@ExportCb,'WriteFaceupDat','.dat',@faceup});
   set(mitem(oooo,inf),'enable',onoff(o,'smp','faceup'));
   
   plugin(oo,'faceup/shell/Export');  % plug point
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
   plugin(o,'faceup/shell/Collect');   % plug point
   
   if isequal(class(o),'caramel')
      table = {{@read,'carabao','ReadStuffTxt','.txt'}};
      collect(o,{'weird','ball','cube'},table); 
   end
   if isequal(class(o),'faceup')
      table = {{@read,'faceup','ReadFaceupDat','.dat'}};
      collect(o,{'pln','smp'},table); 
   end
   if isequal(class(o),'faceup')
      table = {{@read,'faceup','ReadFaceupLog','.log'}};
      collect(o,{'log'},table); 
   end
   if isequal(class(o),'faceup')
      table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
               {@read,'faceup','ReadFaceupDat','.dat'}};
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
   switch active(o);
      case {'pln'}
         ooo = mitem(oo,'X/Y and P',{@SignalCb,'PlainXYP'});
         ooo = mitem(oo,'X and Y',{@SignalCb,'PlainXY'});
      case {'smp'}
         ooo = mitem(oo,'All',{@SignalCb,'SimpleAll'});
         ooo = mitem(oo,'X/Y and P',{@SignalCb,'SimpleXYP'});
         ooo = mitem(oo,'UX and UY',{@SignalCb,'SimpleU'});
   end
   plugin(oo,'faceup/shell/Signal');   % plug point
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
   ooo = mitem(oo,'Basic');
   oooo = menu(ooo,'Plot');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot',{@PlotCb,'Stream'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot X',{@PlotCb,'StreamX'});
   ooo = mitem(oo,'Stream Plot Y',{@PlotCb,'StreamY'});
   ooo = mitem(oo,'Scatter Plot',{@PlotCb,'Scatter'});
   plugin(oo,'faceup/shell/Plot');
end
function oo = PlotCb(o)                % Plot Callback                 
   args = arg(o,0);                    % get arg list
   oo = arg(o,[{'PlotCb'},args]);      % add 'PlotCb' header to arg list
   oo = menu(oo);                      % call menu(o,'PlotCb')
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
   plugin(oo,'faceup/shell/Analysis');
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
% Simulation Menu
%==========================================================================

function oo = Simulation(o)            % Simulation Menu                 
   oo = simu(o,'Setup');               % add simulation menu
   plugin(oo,'faceup/shell/Simulation');
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                   
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Faceup Class: Version ',version(faceup)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit faceup/version');
   plugin(oo,'faceup/shell/Info');
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadFaceupDat(o)          % Read Driver for faceup .dat  
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteFaceupDat(o)         % Read Driver for faceup .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

function oo = Config(o)                % Configure Plotting            
   oo = read(o,'Config');
end
