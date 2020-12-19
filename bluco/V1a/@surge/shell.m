function oo = shell(o,varargin)        % SURGE shell
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@Plot,@PlotCb,...
                                 @Analysis,@Study);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
%  oo = menu(o,'Edit');                % add Edit menu
%  oo = View(o);                       % add View menu
%  oo = menu(o,'Select');              % add Select menu
%  oo = Plot(o);                       % add Plot menu
%  oo = Analysis(o);                   % add Analysis menu
   oo = Select(o);                     % add Select menu
   oo = Simu(o);                       % add Simu menu
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

   o = provide(o,'par.title','Surge Shell');
   o = provide(o,'par.comment',{'Playing around with SURGE objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus
   list = {'Plot','Analysis','Study'};
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
   ooo = mitem(oo,'Surge');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Surge');
   oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@surge});
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
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Surge');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@surge});
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
   oo = mhead(o,'View',{},[],'visible','off'); % add roll down header item
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu
   setting(o,{'simu.dt'},2);

   oo = mhead(o,'Select',{},[]);       % add roll down header item
   ooo = mitem(oo,'Simu');
   oooo = mitem(ooo,'Simulation Interval [ns]',{},'simu.dt');
   choice(oooo,[0.1 0.2 0.5 1 2 5 10],{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analysis(oo,'Menu');          % setup analysis menu
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu
end

%==========================================================================
% Simu Menu
%==========================================================================

function oo = Simu(o)                  % Simu Menu
   oo = mhead(o,'Simu');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = simu(oo,'Menu');              % setup Simu menu
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Surge Class: Version ',version(surge)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit surge/version');
end
