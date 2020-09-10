function oo = shell(o,varargin)        % ESPRESSO shell                
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@PlotCb,@Analysis);
   oo = gamma(o);                     % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = menu(o,'Select');              % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = provide(o,'par.title','Espresso Shell');
   o = provide(o,'par.comment',{'Playing around with ESPRESSO objects'});
   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = refresh(o,{'menu','About'});    % provide refresh callback function
   o = opt(o,'control.autoclc',false); % no auto clc
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
   types = {'weird'};                  % supported object types
   oo = cast(o,'carabao');             % cast to carabao object
   oo = shell(oo,'New',types);         % add New menu items @ Carbao shell
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   %ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@carabao});
   ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'LogData','.log',@espresso});
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
   %ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'TextFile','.txt',@carabao});
   ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'LogData','.log',@espresso});
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
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   setting(o,{'plot.bullets'},true);   % provide bullets default
   setting(o,{'plot.linewidth'},3);    % provide linewidth default
   
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Scatter',{@PlotCb,'Scatter'});
   ooo = mitem(oo,'X-Stream',{@PlotCb,'Xstream'});
   ooo = mitem(oo,'Y-Stream',{@PlotCb,'Ystream'});
end
function oo = PlotCb(o)
   refresh(o,inf);
   oo = plot(o);                    % forward to espresso.plot method
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                     
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Ensemble',{@PlotCb,'Ensemble'});   
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Espresso Class: Version ',version(espresso)]);
   oooo = mitem(ooo,'Edit Release Notes','edit espresso/version');
end
