function oo = shell(o,varargin)        % PLL shell                     
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
   oo = Scenario(o);                   % add Scenario menu
   oo = Kalman(o);                     % add Kalman menu
   oo = Pll(o);                        % add PLL menu
   oo = Mcu(o);                        % add MCU menu
   oo = Qnd(o);                        % add QnD menu
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

   o = provide(o,'par.title','Pll Shell');
   o = provide(o,'par.comment',{'Playing around with PLL objects'});
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
   ooo = mitem(oo,'Pll');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Pll');
   oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@pll});
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
   ooo = mitem(oo,'Pll');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@pll});
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
% Parameter Menu
%==========================================================================

function oo = Scenario(o)              % Scenario Menu                 
   oo = mhead(o,'Scenario');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'ScenarioMenu');     % setup Parameter menu
end

%==========================================================================
% Kalman Menu
%==========================================================================

function oo = Kalman(o)                % PLL Menu                      
   oo = mhead(o,'Kalman');             % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'KalmanMenu');       % setup Kalman menu
end

%==========================================================================
% Pll Menu
%==========================================================================

function oo = Pll(o)                   % PLL Menu                      
   oo = mhead(o,'PLL');                % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'PllMenu');          % setup PLL menu
end

%==========================================================================
% MCU & QnD Menu
%==========================================================================

function oo = Mcu(o)                   % PLL Menu                      
   oo = mhead(o,'MCU');                % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mcu(oo,'Menu');               % setup MCU menu
end
function oo = Qnd(o)                   % QnS Menu                      
   oo = mhead(o,'QnD');                % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = qnd(oo,'Menu');               % setup QnD menu
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
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Pll Class: Version ',version(pll)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit pll/version');
end
