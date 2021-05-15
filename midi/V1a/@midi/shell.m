function oo = shell(o,varargin)        % MIDI shell
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@View,...
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
   oo = menu(o,'Select');              % add Select menu
   oo = Sound(o);                      % add Sound menu
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

   o = provide(o,'par.title','Midi Shell');
   o = provide(o,'par.comment',{'Playing around with MIDI objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus
   list = {'View','Plot','Analyse','Study'};
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
   ooo = mitem(oo,'Midi');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'MIDI (.mid)',{@ImportCb,'ReadMidMid','.mid',@midi});
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
   ooo = mitem(oo,'Midi');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@midi});
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

   plugin(o,'midi/shell/View');       % plug point
end

%==========================================================================
% Play Menu
%==========================================================================

function oo = Sound(o)                 % Sound Menu
   oo = mhead(o,'Sound');              % add roll down header menu item
   ooo = mitem(oo,'Play',{@PlayCb});   % setup plot menu

   function o = PlayCb(o)
      oo = current(o);
      if type(oo,{'mid'})
         nmat = data(oo,'nmat');
         playsound(nmat);
      end
   end
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu

   plugin(o,'midi/shell/Plot');       % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'midi/shell/Analyse');    % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'midi/shell/Study');      % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Midi Class: Version ',version(midi)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit midi/version');

   plugin(o,'midi/shell/Info');       % plug point
end
