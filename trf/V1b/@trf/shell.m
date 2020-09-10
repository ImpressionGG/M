function oo = shell(o,varargin)        % TRF Shell                     
   [gamma,o] = manage(o,varargin,@Shell,@Register,@Dynamic,@New,...
                      @Import,@Export,@View,@Signal,@Config,...
                      @Plot,@Description,@Disp,@Bode,@Step,@Analysis,...
                      @Integrity,@CbIntegrity,@ReadTrfTrf,@WriteTrfTrf);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = shell(o,'Edit');               % add Edit menu
   oo = shell(o,'View');               % add View menu
   oo = shell(o,'Select');             % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = Study(o);                      % add Study menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
%
% INIT   When a transfer function object is initialized for the shell
%        a CARAMEL shell object is created with the TRF object contained
%        as a single child.
%
   if ~container(o)
      title = get(o,{'title','Transfer Function'});
      comment = get(o,{'comment',{}});
      oo = update(o,title,comment);    % update title & comments
      if ~isempty(comment)
         oo.par.comment = comment;
      end
      o = trf('shell');                % create another TRF shell object
      o.data = {oo};                   % add children list with TRF
      o = control(o,{'current'},1);    % select current object
   end
   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   
   o = provide(o,'par.title','Transfer Function Shell');
   o = provide(o,'par.comment',{'analysis of transfer functions',...
                 'create transfer function using File>New menu'});
   o = refresh(o,{@shell,'Register'}); % provide refresh callback function
   
      % setup filter window
      
   o = opt(o,{'filter.window'},100);      
end
function o = Register(o)               % Register Plugins              
   refresh(o,{'menu','About'});        % provide refresh callback function
   message(o,'Register Plugins ...');  % progress message
   motion(o,'Register');               % register MOTION plugin
   
   plugin(o,['caramel/motion/Analysis'],{mfilename,'Integrity'});
   
   plugin(o,'trf/shell/Register');     % plug point
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
   ooo = shell(oo,'Import');           % add Import menu items
   ooo = wrap(oo,'Export');            % add Export menu items (wrapped)
end
function oo = New(o)                   % New Menu Items                
   oo = new(o);                        % add New menu items
   plugin(oo,'trf/shell/New');         % plug point
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'TRF');
   oooo = mitem(ooo,'Transfer Function (.trf)',{@ImportCb,'ReadTrfTrf','.trf',@trf});
   plugin(oo,'trf/shell/Import');      % plug point
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      read = eval(['@',mfilename]);    % reader method

      co = cast(o);                    % casted object
      list = import(co,drv,ext,read);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'TRF');
   set(mitem(ooo,inf),'enable',onoff(o,{'strf','ztrf','qtrf'}));
   oooo = mitem(ooo,'Transfer Function (.trf)',{@ExportCb,'WriteTrfTrf','.trf',@trf});
   plugin(oo,'trf/shell/Export');      % plug point
   return
   
   function oo = ExportCb(o)           % Export Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         write = eval(['@',mfilename]);% writer method

         co = cast(oo);                % casted object
         export(co,drv,ext,write);     % export object to file
      end
   end
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
   co = cast(o,'caramel');             % casted object
   oo = shell(co,'View');              % add CARAMEL View menu
   ooo = Style(oo);                    % add Style menu
   ooo = mseek(oo,{'Scale','Time Scale'});
   oooo = ScaleTime(ooo);              % add Scale/Time menu
   ooo = mseek(oo,{'Scale'});
   oooo = ScaleBode(ooo);              % add Scale/Bode menu
end
function o = Signal(o)                 % Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
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
   plugin(oo,'trf/shell/Signal');      % plug point
end
function o = Config(o)                 % Signal Callback               
   o = config(o,[],active(o));         % set all subplots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[],'µ');    % setup category 1
   o = category(o,2,[-2 2],[],'µ');    % setup category 2

      % get mode and provide a proper default if empty
      % (empty mode is provided during registration phase)
      
   mode = o.either(arg(o,1),o.type);  
   switch mode
      case 'PlainXYP'
         o = config(o,'x',1);
         o = config(o,'y',1);
         o = config(o,'p',2);
      case {'PlainXY','pln'}
         o = config(o,'x',1);
         o = config(o,'y',2);
         mode = 'PlainXY';
      case {'SimpleAll','smp'}
         o = config(o,'x',1);
         o = config(o,'y',1);
         o = config(o,'p',2);
         o = config(o,'ux',3);
         o = config(o,'uy',3);
         mode = 'SimpleAll';
      case 'SimpleXYP'
         o = config(o,'x',1);
         o = config(o,'y',1);
         o = config(o,'p',2);
      case 'SimpleU'
         o = config(o,'ux',1);
         o = config(o,'uy',2);
   end
   o = subplot(o,'Signal',mode);    % set signal mode   

   change(o,'Bias','drift');        % change bias mode, update menu
   change(o,'Config');              % change config, rebuild & refresh
end

function oo = Style(o)                 % Style Menu                    
%
% STYLE   Style menu setup & handling (for plotting)
%
   setting(o,{'style.bullets'},0);
   setting(o,{'style.linewidth'},1);
   setting(o,{'style.labels'},'plain');
   setting(o,{'style.title'},'package');
   setting(o,{'style.digits'},2);
   setting(o,{'style.legend'},false);
   setting(o,{'style.background'},'white');
   setting(o,{'style.canvas'},'color');

   oo = mhead(o,'Style');
   
   ooo = mitem(oo,'Bullets',{},'style.bullets');
   choice(ooo,{{'Off',0},{'Black',-1},{'Colored',1}},{});
   
   ooo = mitem(oo,'Line Width',{},'style.linewidth');
   choice(ooo,1:7,{});
   
   ooo = mitem(oo,'Labels',{},'style.labels');
   choice(ooo,{{'Plain','plain'},{'Statistics','statistics'}},{});
 
   ooo = mitem(oo,'Legend',{},'style.legend');
   choice(ooo,{{'Off',0},{'On',1}},{});

   ooo = mitem(oo,'Title',{},'style.title');
   choice(ooo,{{'Original','original'},{'Package','package'}},{});

   ooo = mitem(oo,'Background',{},'style.background');
   choice(ooo,{{'White','white'},{'Gray','gray'},{'Color','color'}},{@refresh});
   ooo = mitem(oo,'Canvas',{},'style.canvas');
   choice(ooo,{{'White','white'},{'Black','black'},{'Color','color'}},{@refresh});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Digits',{},'style.digits');
   choice(ooo,[1:4],{});
end
function oo = ScaleBode(o)             % Scale/Bode Menu               
   setting(o,{'scale.omega.low'},1e-1);
   setting(o,{'scale.omega.high'},1e5);
   setting(o,{'scale.magnitude.low'},-80);
   setting(o,{'scale.magnitude.high'},80);
   setting(o,{'scale.phase.low'},-270);
   setting(o,{'scale.phase.high'},90);
   
   oo = mitem(o,'Bode Scale');
   ooo = mitem(oo,'Lower Frequency',{},'scale.omega.low');
         choice(ooo,[1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'scale.omega.high');
         choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8],{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Magnitude',{},'scale.magnitude.low');
         choice(ooo,[-100:10:-20],{});
   ooo = mitem(oo,'Upper Magnitude',{},'scale.magnitude.high');
         choice(ooo,[20:10:100],{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Phase',{},'scale.phase.low');
         choice(ooo,[-270:45:-90],{});
   ooo = mitem(oo,'Upper Phase',{},'scale.phase.high');
         choice(ooo,[-90:45:135],{});
end
function oo = ScaleTime(o)             % Scale/Time Menu               
   setting(o,{'scale.time.low'},0);
   setting(o,{'scale.time.high'},10);
   setting(o,{'scale.amplitude.low'},-0.2);
   setting(o,{'scale.amplitude.high'},1.6);
   
   oo = o;
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Maximum Time',{},'scale.time.high');
         %choice(ooo,[1e-5,1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3],{});
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Amplitude',{},'scale.amplitude.low');
         %choice(ooo,[-0.3:0.1:-0.1,0,0:0.1:1],{});
         charm(ooo,{});
   ooo = mitem(oo,'Upper Amplitude',{},'scale.amplitude.high');
         %choice(ooo,[0.5:0.1:2],{});
         charm(ooo,{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Description',{@Description 'Single'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Step Response',{@Step 'Single'});
   ooo = mitem(oo,'Bode Plot',{@Bode 'Single'});
   plugin(oo,'trf/shell/Plot');        % plug point
end
function oo = Description(o)           % Description of Object         
   mode = arg(o,1);
   refresh(o,o);
   
   oo = current(o);
   list = Basket(o);                % basket list
   
   if (~isa(oo,'trf'))
      menu(oo,'About');
      return
   end
   
   if (isequal(oo.type,'pkg'))
       oo.data = list;
       oo = Product(oo);
       list = {oo};
   end
   
   cls(o);
   oo = [];
   for (i=1:length(list))
      oo = list{i};
      if isa(oo,'trf')
         switch mode
            case 'Single'              % open loop bode plot
               if ~istrf(oo)
                  menu(o,'About');
                  return
               end
               ooo = oo;               % proceed with original object
            case 'Open'                % open loop bode plot
               ooo = OpenLoop(oo);
            case 'Closed'
               ooo = ClosedLoop(oo);
            case 'Sensitivity'
               ooo = Sensitivity(oo);
         end
         ooo = update(ooo);            % update description comments
         message(ooo);
      end
   end
 
   if isempty(oo)
      oo = o;                          % provide dummy output arg
      message(o,'Description: No Objects!');
   end
end
function oo = Step(o)                  % Step Plot                     
   mode = arg(o,1);
   refresh(o,o);
   cls(o);
   o = with(o,'scale');
   oo = [];
   
   list = Basket(o);
   
   if (length(list) > 1)
      oo = current(o);
      oo.data = list;
      oo = Product(oo);
      list = {oo};
   end
   
   axes(o,'Time');
   for (i=1:length(list))
      oo = list{i};
      if isa(oo,'trf')
         switch mode
            case 'Single'              % open loop bode plot
               ooo = oo;               % proceed with original object
            case 'Open'                % open loop bode plot
               ooo = OpenLoop(oo);
            case 'Closed'
               ooo = ClosedLoop(oo);
            case 'Sensitivity'
               ooo = Sensitivity(oo);
         end
         stp(ooo);                     % step plot
      end
   end
 
   if isempty(oo)
      oo = o;                          % provide dummy output arg
      title('Step Response: No Objects!');
   end
end
function oo = Bode(o)                  % Bode Plot                     
   mode = arg(o,1);
   refresh(o,o);
   cls(o);
   o = with(o,'scale');
   oo = [];                            % init
   
   list = Basket(o);

   if (length(list) > 1)
      oo = current(o);
      oo.data = list;
      oo = Product(oo);
      list = {oo};
   end
   
   axes(o,'Bode');
   for (i=1:length(list))
      oo = list{i};
      if isa(oo,'trf')
         switch mode
            case 'Single'              % open loop bode plot
               ooo = oo;               % proceed with original object
            case 'Open'                % open loop bode plot
               ooo = OpenLoop(oo);
            case 'Closed'
               ooo = ClosedLoop(oo);
            case 'Sensitivity'
               ooo = Sensitivity(oo);
         end
         bode(ooo);                    % bode plot
      end
   end
   
   if isempty(oo)
      oo = o;                          % provide dummy output arg
      title('Bode Plot: No Objects!');
   end
end

function oo = Product(o)               % Product of Transfer Functions 
   if container(o) || o.is(get(o,'kind'),'pkg')
      oo = trf(1,1);
      for (ii = 1:length(o.data))
         oii = o.data{ii};
         oo = oo * oii;
      end
      oo = opt(oo,opt(o));
   else
      oo = o;
   end
end
function oo = OpenLoop(o)              % Create Open Loop TRF          
   oo = Product(o);
   oo = set(oo,'title','Open Loop');
   oo = set(oo,'color','y');
   oo = set(oo,'edit',{{'Color','color'}});
   clip(o,oo);                         % put in clip board
end
function oo = ClosedLoop(o)            % Create Closed Loop TRF        
   oo = Product(o);
   oo = loop(oo);                      % calculate closed loop TRF
   oo = set(oo,'title','Closed Loop');
   oo = set(oo,'color','m');
   oo = set(oo,'edit',{{'Color','color'}});
   clip(o,oo);                         % put in clip board
end
function oo = Sensitivity(o)           % Create Sensitivity TRF        
   oo = Product(o);
   [~,oo] = loop(oo);                  % calculate closed loop TRF
   oo = set(oo,'title','Sensitivity');
   oo = set(oo,'color','aw');
   oo = set(oo,'edit',{{'Color','color'}});
   clip(o,oo);                         % put in clip board
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu

   co = current(o);
   if isa(co,'trf')
      ooo = mitem(oo,'Open Loop');
      oooo = mitem(ooo,'Transfer Function',{@Description 'Open'});
      oooo = mitem(ooo,'Step Response',{@Step 'Open'});
      oooo = mitem(ooo,'Bode Plot',{@Bode 'Open'});
      ooo = mitem(oo,'Closed Loop');
      oooo = mitem(ooo,'Transfer Function',{@Description 'Closed'});
      oooo = mitem(ooo,'Step Response',{@Step 'Closed'});
      oooo = mitem(ooo,'Bode Plot',{@Bode 'Closed'});
      ooo = mitem(oo,'Sensitivity');
      oooo = mitem(ooo,'Transfer Function',{@Description 'Sensitivity'});
      oooo = mitem(ooo,'Step Response',{@Step 'Sensitivity'});
      oooo = mitem(ooo,'Bode Plot',{@Bode 'Sensitivity'});
   elseif isa(co,'caramel')
      'stop here!';
   end
   plugin(oo,'trf/shell/Analysis');    % plug point
end
function oo = Integrity(o)             % Motion Integrity              
   o = trf(o);                         % class change to TRF
   oo = mseek(o,{'Motion'});           % Analysis>Motion menu availlable?
   if ~isempty(oo)
      ooo = mitem(oo,'-');             
      ooo = mitem(oo,'Integrity',{@invoke, mfilename, 'CbIntegrity'});
   end
end
function oo = Disp(o)                  % Display Transfer Function     
%
%  DISP   Display transfer function
%
%            shell(o,'Disp','Open');   % Open loop transfer function
%            shell(o,'Disp','Closed'); % Closed loop transfer function
%
   mode = arg(o,1);
   refresh(o,o);
   cls(o);
   %o = with(o,'scale');

   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      if isa(oo,'trf')
         switch mode
            case 'Open'                % open loop bode plot
               ooo = oo;               % nothing to convert
               ooo = update(ooo,'Open Loop',{});
            case 'Closed'
               ooo = loop(oo);         % calculate closed loop TRF
               ooo = update(ooo,'Closed Loop',{});
         end
         message(ooo);                 % display transfer function
      end
   end
end
function oo = CbIntegrity(o)
   oo = current(o);
   if ~isequal(oo.type,'motion')
      message(o,'Integrity analysis only possible for motion objects!');
   end
   I = trf(1,[1 0]);                   % integrator trf
   o1 = I*oo; o2 = I*o1;  o3 = I*o2;   % 1x, 2x, 3x integrated signals

   [t,s] = data(oo,'t','s');           % reference for comparison                      

   s0 = oo.data.s;                     % 0 x integrated s                      
   v1 = o1.data.v;                     % 1 x integrated v
   a2 = o2.data.a;                     % 2 x integrated a
   j3 = o3.data.j;                     % 3 x integrated j
   
      % build deviations: s0-s, v1-s, a2-s, j3-s 
   
   oo = log(caramel('motion'),'t, s:g#1, v:b#2, a:r#3, j:yo#4');
   oo = log(oo,t, s0-s, v1-s, a2-s, j3-s);
   oo = set(oo,'title','Integrity Check');
   graph(oo,'Stream');
end
%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = study(o);                      % add Study menu
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Trf Class: Version ',version(trf)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit trf/version');
end

%==========================================================================
% Read/Write Driver
%==========================================================================

function oo = ReadTrfTrf(o)            % Read Driver for TRF .trf      
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~o.is(oo.type,{'strf','qtrf','ztrf'})
      message(o,'Error: no TRF data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
   bag = data(oo);
   Ts = bag.xden(1);
   num = bag.xnum(2:end);
   den = bag.xden(2:end);
   
   switch oo.type
      case 'strf'
         ooo = trf(num,den,'s',0); 
      case 'ztrf'
         ooo = trf(num,den,'z',Ts); 
      case 'qtrf'
         ooo = trf(num,den,'q',Ts); 
   end
   oo.data = ooo.data;                 % copy data only!
end
function oo = WriteTrfTrf(o)           % Write Driver for TRF .trf     
   path = arg(o,1);
   G = data(o);
   bag.xnum = G(1,:);
   bag.xden = G(2,:);
   
   update = get(o,{'update',{}});
   for (i=1:length(update))
      item = update{i};
      if isa(item,'function_handle')
         update{i} = char(item);       % substitute function handles
      end
   end
   o = set(o,'update',update);
   
   o = data(o,bag);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function list = Basket(o)              % Basket list                   
   oo = current(o);
   blist = basket(o);                  % get basket list

      % special treatment of packages
      
   pkg = '';                           % empty by default
   if o.is(oo.type,'pkg')
      pkg = get(oo,'package');
      blist = o.data;
   end
   
      % copy to list only true transfer functions!
      
   list = {};
   for (i=1:length(blist))
      oi = blist{i};
      if o.is(type(oi),{'strf','qtrf','ztrf'})
         if (isempty(pkg) || o.is(get(oi,'package'),pkg))
            list{end+1} = blist{i};
         end
      end
   end
end
