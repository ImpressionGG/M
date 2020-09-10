function oo = shell(o,varargin)        % HAR shell                    
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@View,@Plot,@Analysis);
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
   oo = shell(o,'Plot');               % add Plot menu
   oo = shell(o,'Analysis');           % add Analysis menu
   oo = study(o);                      % add Study menu
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
      oo = provide(o,'par.title','Transfer Function');
   
      o = trf('shell');                % create another TRF shell object
      o.data = {oo};                   % add children list with TRF
      o = control(o,{'current'},1);    % select current object
   end
   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   
   o = provide(o,'par.title','HAR Shell');
   o = provide(o,'par.comment',{'study & analysis of transfer functions'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
   
      % setup filter window
      
   o = opt(o,{'filter.window'},100);      
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
function oo = New(o)                   % New Menu Items                
   oo = mseek(o,{'New'});
   ooo = mitem(oo,'-');
   ooo = plant(oo);                    % add New/Plant sub menu
   ooo = controller(oo);               % add New/Controller sub menu
   ooo = new(oo,'System');             % add New/System sub menu
   ooo = mitem(oo,'-');
   ooo = new(oo,'Stuff');              % add New/Stuff sub menu
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@trf});
   ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'LogData','.log',@trf});
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
   ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'TextFile','.txt',@trf});
   ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'LogData','.log',@trf});
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

function oo = View(o)                  % View Menu                     
   co = cast(o,'caramel');             % casted object
   oo = shell(co,'View');              % add CARAMEL View menu
   ooo = mseek(oo,{'Scale','Time Scale'});
   oooo = ScaleTime(ooo);              % add Scale/Time menu
   ooo = mseek(oo,{'Scale'});
   oooo = ScaleBode(ooo);              % add Scale/Bode menu
end
function oo = ScaleBode(o)             % Scale/Bode Menu               
   setting(o,{'scale.omega.low'},1e-2);
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
         choice(ooo,[1e-5,1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Amplitude',{},'scale.amplitude.low');
         choice(ooo,[-100:10:-20],{});
   ooo = mitem(oo,'Upper Amplitude',{},'scale.amplitude.high');
         choice(ooo,[20:10:100],{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   co = cast(o,'trf');
   oo = shell(co,'Plot');              % delegate to trf/shell/Plot
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   co = cast(o,'trf');
   oo = shell(co,'Analysis');          % delegate to trf/shell/Plot
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Trf Class: Version ',version(har)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit har/version');
end
