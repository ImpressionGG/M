function oo = shell(o,varargin)        % CARMA shell                   
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Edit,@View,@Select,...
                     @Plot,@Analysis,@Info,@ConfigUpCam,@ConfigAB);
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
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = Plugin(o);                     % add Plugin menu
   oo = Gallery(o);                    % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = Figure(o);                     % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = menu(o,'Default');              % provide CARMA defaults

   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = refresh(o,{'menu','About'});    % provide refresh callback function
   o = control(o,{'options'},0);       % provide 'options' control option
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
   oo = menu(o,'New');                 % add New menu
   plugin(oo,'carma/shell/New');       % plug point
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@carabao});
   ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'LogData','.log',@carma});
   plugin(oo,'carma/shell/Import');    % plug point
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
   ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'TextFile','.txt',@carabao});
   ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'LogData','.log',@carma});
   plugin(oo,'carma/shell/Export');    % plug point
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
% Edit Menu
%==========================================================================

function oo = Edit(o)                  % Edit Menu                     
   oo = menu(o,'Edit');                % add Edit menu
   plugin(oo,'carma/shell/Edit');      % plug point
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
   oo = menu(o,'View');                % add View menu
   ooo = mseek(oo,{'Style'});          % seek View>Style menu entry
   plugin(ooo,'carma/shell/Style');    % plug point
   plugin(oo,'carma/shell/View');      % plug point
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   plugin(oo,'carma/shell/Select');    % plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   if isequal(o.type,'weird')
      o = carabao(o);
      oo = shell(o,'Plot');            % delegate to shell@carabao>Plot
   else
      oo = mhead(o,'Plot');
      dynamic(oo);                     % make this a dynamic menu
      ooo = menu(oo,'Plot');           % delegate to menu@carma>Plot
   end
   plugin(oo,'carma/shell/Plot');      % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   setting(o,{'analysis.geometry.raster'},[5 5]);
   setting(o,{'analysis.geometry.deltoid'},0.4);
   setting(o,{'analysis.geometry.path'},0.1);
   setting(o,{'analysis.geometry.zigzag'},0.1);

   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   
   ooo = mitem(oo,'Geometry');
   oooo = mitem(ooo,'Surface Plot');
   ooooo = mitem(oooo,'X',{@AnaCb,'Surf','X'});
   ooooo = mitem(oooo,'Y',{@AnaCb,'Surf','Y'});
   oooo = mitem(ooo,'Arrow Plot',{@AnaCb,'Arrow'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Matrix Path',{@AnaCb,'Path'});
   oooo = mitem(ooo,'Zigzag Path',{@AnaCb,'Zigzag'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Raster','','analysis.geometry.raster');
   choice(oooo,{{'[1 1]',[1 1]},{'[2 2]',[2 2]},{'[3 3]',[3 3]},...
     {'[4 4]',[4 4]},{'[5 5]',[5 5]},{'[10 10]',[10 10]},...
     {'[20 20]',[20 20]},{'[50 50]',[50 50]}},'');
   oooo = mitem(ooo,'Arrow Style','','analysis.geometry.deltoid');
   choice(oooo,[0.2:0.1:1]);
   oooo = mitem(ooo,'Path Visibility','','analysis.geometry.path');
   choice(oooo,[0:0.1:0.2,0.5,1]);
   oooo = mitem(ooo,'Zig-Zag Visibility','','analysis.geometry.zigzag');
   choice(oooo,[0:0.1:0.2,0.5,1]);
   plugin(oo,'carma/shell/Analysis');  % plug point
end
function oo = AnaCb(o)                 % Analyse Callback              
   oo = o;                             % copy  o to out arg before change
   o = with(o,{'style','view','select'});      % unpack some options
   
   cls(o);                             % clear screen
   plot(o);                            % plot object
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu                   
   oo = menu(o,'Plugin');              % menu will be hidden
   oo = plugin(oo,'carma/shell/Plugin');
end

%==========================================================================
% Gallery Menu
%==========================================================================

function oo = Gallery(o)               % Gallery Menu                  
   oo = menu(o,'Gallery');             % add Gallery menu
   plugin(oo,'carma/shell/Gallery'); % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Carma Class: Version ',version(carma)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit espresso/version');
   plugin(oo,'carma/shell/Info');      % plug point
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = Figure(o)                % Figure Menu                   
   oo = menu(o,'Figure');              % add Figure menu
   plugin(oo,'carma/shell/Figure');    % plug point
end
