function oo = shell(o,varargin)        % JUNK shell
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
   oo = Select(o);                     % add Select menu
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
   o = control(o,{'dark'},0);          % run in non dark mode

   o = provide(o,'par.title','Junk Shell');
   o = provide(o,'par.comment',{'Playing around with JUNK objects'});
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
   ooo = mitem(oo,'Junk');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Junk');
   oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@junk});
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
   ooo = mitem(oo,'Junk');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@junk});
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

   plugin(o,'junk/shell/View');       % plug point
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu
   oo = menu(o,'Select');              % add Select menu
   dynamic(oo);                        % make this a dynamic menu
   ooo = Filter(oo);                   % add Filter sub menu
end
function oo = Filter(o)                % Add Filter Menu Items
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mitem(o,'-');

   oo = mitem(o,'Filter');
   ooo = mitem(oo,'Mode','','filter.mode');
   choice(ooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
               {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Type',{},'filter.type');
   choice(ooo,{{'Order 2 Low Pass','LowPass2'},...
               {'Order 2 High Pass','HighPass2'},...
               {'Order 4 Low Pass','LowPass4'},...
               {'Order 4 High Pass','HighPass4'}},{});
   ooo = mitem(oo,'Bandwidth',{},'filter.bandwidth');
   charm(ooo,{});
   ooo = mitem(oo,'Zeta',{},'filter.zeta');
   charm(ooo,{});
   ooo = mitem(oo,'Method',{},'filter.method');
   choice(ooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu

   plugin(o,'junk/shell/Plot');       % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'junk/shell/Analyse');    % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'junk/shell/Study');      % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Junk Class: Version ',version(junk)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit junk/version');

   plugin(o,'junk/shell/Info');       % plug point
end
