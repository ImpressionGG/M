function oo = shell(o,varargin)        % MESH shell
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@View,@Select,...
                                 @Plot,@PlotCb,@Analysis,@Study);
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
   oo = View(o);                       % add View menu
   oo = Select(o);              % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analyse(o);                    % add Analyse menu
   oo = Study(o);                      % add Study menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Tiny(o)                   % Tiny Shell Setup
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = control(o,{'dark'},1);          % run in non dark mode

   o = provide(o,'par.title','Mesh Shell');
   o = provide(o,'par.comment',{'Playing around with MESH objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus
   list = {'View','Select','Plot','Analyse','Study'};
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
   oo = mseek(o,{'New'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stuff');
   oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   ooo = mitem(oo,'Mesh');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Mesh');
   oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@mesh});
   return

   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % import driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Mesh');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@mesh});
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
   oo = mhead(o,'View');               % add roll down header item
   dynamic(oo);                        % make this a dynamic menu

   ooo = menu(oo,'Grid');              % add Grid menu item
   ooo = menu(oo,'Dark');              % add Dark mode menu item
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Style');             % add plot style sub menu

   plugin(o,'mesh/shell/View');       % plug point
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu
   setting(o,{'traffic.Tobs'},1000);
   setting(o,{'traffic.Tpack'},500);
   setting(o,{'traffic.N'},1000);
   setting(o,{'traffic.repeats'},6);

   oo = menu(o,'Select');              % add standard Select menu
   dynamic(oo);
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Number of Transmissions [ms]',{},'traffic.N');
         choice(ooo,[10,100,1000],{});
   ooo = mitem(oo,'Transmission Repeats',{},'traffic.repeats');
         choice(ooo,[1:10],{});
   ooo = mitem(oo,'Observe Time [ms]',{},'traffic.Tobs');
         choice(ooo,[10,100,1000,1e4],{});
   ooo = mitem(oo,'Packet Duration [us]',{},'traffic.Tobs');
         choice(ooo,[500 1000],{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu

   plugin(o,'mesh/shell/Plot');       % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'mesh/shell/Analyse');    % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'mesh/shell/Study');      % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Mesh Class: Version ',version(mesh)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit mesh/version');

   plugin(o,'mesh/shell/Info');       % plug point
end
