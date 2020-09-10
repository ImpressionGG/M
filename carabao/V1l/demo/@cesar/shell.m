function oo = shell(o,varargin)        % CESAR Shell                   
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Register,@Config,...
                  @Signal,@Plot,@PlotCb,@Analysis,@Study1,@Study2,@Study3);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = menu(o,'View');                % add View menu
   oo = Select(o);                     % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
%  oo = Study(o);                      % add Study menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = provide(o,'par.title','Cesar Shell');
   o = provide(o,'par.comment',{'Image Position Analysis'});
   
   o = opt(o,{'mode.bias'},'absolute');
   o = opt(o,{'style.labels'},'statistics');
   o = opt(o,{'style.digits'},3);
   
   o = refresh(o,{@shell,'Register'}); % provide refresh callback function
end
function o = Register(o)               % Register Plugins              
   o = Config(type(o,'image'));        % register 'smp' configuration
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Installing plugins ...');
   rebuild(o);

   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'Plot','Analysis'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = New(oo);                      % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
end
function oo = New(o)                   % New Menu                      
   oo = menu(o,'New');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');
   ooo = mitem(oo,'Cesar');
   oooo = mitem(ooo,'Log Data',{@NewCb});
   return

   function oo = NewCb(o)
      log = ones(1000,1)*randn(1,2) + randn(1000,2)*randn(2,2);

      oo = cesar('log');
      oo.par.title = ['Log Data @ ',datestr(now)];
      oo.data.x = log(:,1);
      oo.data.y = log(:,2);

      oo = launch(oo,launch(o));       % inherit launch function
      paste(o,{oo});                   % paste object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
%  ooo = mitem(oo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@cesar});
   ooo = mitem(oo,'Image Data (.tif)',{@ImportCb,'ReadImgTif','.tif',@cesar});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
%  ooo = mitem(oo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@cesar});
   ooo = mitem(oo,'Image Data (.tif)',{@ExportCb,'WriteImgTif','.tif',@cesar},[],'enable','off');
   return
   
   function oo = ExportCb(o)           % Export Log Data Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         export(cast(oo),drv,ext);     % export object to file
      end
   end
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
      case {'image'}
         ooo = mitem(oo,'X/Y',{@Config},'X/Y');
         ooo = mitem(oo,'X',{@Config},'X');
         ooo = mitem(oo,'Y',{@Config},'Y');
         ooo = mitem(oo,'-');
         ooo = mitem(oo,'X1/Y1',{@Config},'X1/Y1');
         ooo = mitem(oo,'X2/Y2',{@Config},'X2/Y2');
   end
%  plugin(oo,'cesar/shell/Signal');    % plug point
end
function o = Config(o)                 % Setup a Configuration         
%
%     Config(type(o,'mytype'))         % register a type specific config
%     oo = Config(arg(o,{'XY'})        % change configuration
%          
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[],[],'1');        % setup category 1
   
      % get mode and provide a proper type default if empty
      % (empty mode is provided during registration phase)
      
   mode = o.either(arg(o,1),o.type);  
   switch mode
      case {'image','X/Y'}
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'g',1});
         mode = 'X/Y';
      case {'X'}
         o = config(o,'x',{1,'r',1});
      case {'Y'}
         o = config(o,'y',{1,'g',1});
      case {'image','X1/Y1'}
         o = config(o,'x1',{1,'rk',1});
         o = config(o,'y1',{2,'gk',1});
      case {'image','X2/Y2'}
         o = config(o,'x2',{1,'rk',1});
         o = config(o,'y2',{2,'gk',1});
      otherwise
         error('bad mode!');
   end
   o  = subplot(o,'Signal',mode);      % set signal mode

   change(o,'Bias','absolute');        % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   ooo = mitem(oo,'-');
   ooo = Fiducials(oo);
end
function oo = Fiducials(o)             % Fiducial Parameter Menu       
   setting(o,{'fiducial.area.x'},1285);
   setting(o,{'fiducial.area.y'},2020);
   setting(o,{'fiducial.area.m'},5);
   setting(o,{'fiducial.area.n'},5);
   setting(o,{'fiducial.image.w'},62);
   setting(o,{'fiducial.image.h'},62);
   setting(o,{'fiducial.index.i'},4);
   setting(o,{'fiducial.index.j'},5);
   
   oo = mitem(o,'Fiducials');
   ooo = mitem(oo,'Area Offset X [px]',{},'fiducial.area.y');
         charm(ooo,{});
   ooo = mitem(oo,'Area Offset Y [px]',{},'fiducial.area.x');
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Area Width [#]',{},'fiducial.area.m');
         charm(ooo,{});
   ooo = mitem(oo,'Area Height [#]',{},'fiducial.area.n');
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Fiducial Width [px]',{},'fiducial.image.h');
         charm(ooo,{});
   ooo = mitem(oo,'Fiducial Height [px]',{},'fiducial.image.w');
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Row Index [#]',{},'fiducial.index.i');
         charm(ooo,{});
   ooo = mitem(oo,'Column Index [#]',{},'fiducial.index.j');
         charm(ooo,{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Image',{@PlotCb,'Image'});
   ooo = mitem(oo,'Area',{@PlotCb,'Area'});
   ooo = mitem(oo,'Fiducial',{@PlotCb,'Fiducial'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream',{@PlotCb,'Stream'});
   ooo = mitem(oo,'Overlay',{@PlotCb,'Overlay'});
   ooo = mitem(oo,'Offsets',{@PlotCb,'Offsets'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Data Object',{@PlotCb,'Data'});
end
function oo = PlotCb(o)                % Plot Callback                 
   refresh(o,o);                    % use this callback for refresh
   oo = plot(o);                    % forward to cesar/gplot method
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = analysis(o,'Setup');
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % add Study header
   ooo = mitem(oo,'Display Sample Fiducial',{@Study1});
   ooo = mitem(oo,'Image Data',{@Study2});
%  ooo = mitem(oo,'Study3',{@Study3});
end
function o = Study1(o)                 % Display Sample Fiducial       
   oo = ImageLoad(o,1);                % load first image

   img = oo.data.image(20:50,:)';
   oo = image(caravel,'Create',img);
   cls(o);
   image(oo,'Plot');
end
function o = Study2(o)                 % Display Sample Fiducial Data  
   oo = ImageLoad(o,1);                % load first image
   oo = ImageData(oo);                 % convert to image data object
   plot(oo);
end
function o = Study3(o)                 % Study 3                       
   dir = 'e:/Chameo Ultra/Cross Search/CrossSearch';
   i0 = 310;  j0 = 3700;  w = 330;  h = w;
   d = w/5;
   i0 = i0+2*d;     w = d;
   j0 = j0+4*d-10;  h = d;
   for (i=1:5)
      file = sprintf('SC_CrossSearchSnaps_%04d.tif',i);
      path = [dir,'/',file];
      img = imread(path);
      img = img(i0:i0+w,j0:j0+h); 
      oo = image(o,'Create',img);
      xy = img(20:50,:)';
      if (i==1)
         image(oo,'Plot');
         set(gca,'dataaspect',[1 1 1]);
      
         oo = image(o,'Create',xy);
         image(oo,'Plot');
      end
      
      oo = trace(caramel('image'),'t',1:prod(size(xy)),'d',double(xy(:)'));
      [m,n] = size(xy);
      oo.par.sizes = [1 m n];
      
      shell(caramel);
      plot(oo);
   end
end
function oo = ImageLoad(o,i)           % Load Image #i                 
   dir = 'e:/Chameo Ultra/Cross Search/CrossSearch';
   file = sprintf('SC_CrossSearchSnaps_%04d.tif',i);
   path = [dir,'/',file];

   i0 = 310;  j0 = 3700;  w = 330;  h = w;
   d = w/5;
   i0 = i0+2*d;     w = d;
   j0 = j0+4*d-10;  h = d;

   img = imread(path);
   img = img(i0:i0+w,j0:j0+h); 
   oo = image(caravel,'Create',img);
end
function oo = ImageData(o)             % Create an Image Data Object   
   xy = o.data.image(20:50,:)';
   oo = trace(caramel('image'),'t',1:prod(size(xy)),'d',double(xy(:)'));
   [n,r] = size(xy);
   oo.par.sizes = [1 n r];
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Cesar Class: Version ',version(cesar)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit cesar/version');
end

