function oo = shell(o,varargin)        % TRADE shell
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@Plot,@PlotCb,...
                                 @Select,@Analysis,@Study);
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
   %oo = Analyse(o);                    % add Analyse menu
   %oo = Study(o);                      % add Study menu
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

   o = provide(o,'par.title','Trade Shell');
   o = provide(o,'par.comment',{'Playing around with TRADE objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus
   list = {'Plot','Analyse','Study'};
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
   %ooo = mitem(oo,'-');
   %ooo = mitem(oo,'Stuff');
   %oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   %ooo = mitem(oo,'Trade');
   ooo = new(oo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   %ooo = mitem(oo,'Stuff');
   %oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   %ooo = mitem(oo,'Trade');
   ooo = mitem(oo,'Trading View (.csv)',{@ImportCb,'ReadTradeCsv','.csv',@trade});
   ooo = mitem(oo,'Chart Data (.csv)',{@ImportCb,'ReadChartCsv','.csv',@trade});
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
   ooo = mitem(oo,'Trade');
         enable(ooo,0);                % disable so far
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@trade});
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
   oo = mhead(o,'View',{},[],'visible','on'); % add roll down header item

   ooo = Chart(oo);                    % chart type selection
   ooo = Inner(oo);                    % inner bars display mode
   
   ooo = mitem(oo,'-');
   ooo = Boundary(oo);
   ooo = Strategy(oo);
   ooo = Style(oo);
   
   ooo = mitem(oo,'-');
   ooo = Grid(oo);
   ooo = Dark(oo);
end
function o = Chart(o)                  % Select Chart Menu             
   setting(o,{'view.chart'},'candle');
   oo = mitem(o,'Chart',{},'view.chart');
   choice(oo,{{'Line','line'},{'Candles','candle'},...
               {'Bars','bar'}},{});
end
function o = Inner(o)                  % Inner Bars                    
   setting(o,{'view.inner'},1);   
   
   oo = mitem(o,'Inner Bars',{},'view.inner');
   choice(oo,{{'Off',0},{'Highlight',1},{'Bullets',2}},{});
end
function oo = Boundary(o)              % Boundary Menu                 
   setting(o,{'view.top'},0);          % show top line
   setting(o,{'view.bottom'},0);       % show bottom line
   
   oo = mitem(o,'Boundary');
   ooo = mitem(oo,'Top Line',{},'view.top');
         check(ooo,{});
   ooo = mitem(oo,'Bottom Line',{},'view.bottom');
         check(ooo,{});
end
function o = Strategy(o)               % Strategy Menu                 
   setting(o,{'strategy.trade'},0);
   
   oo = mitem(o,'Strategy',{},'strategy.trade');
        choice(oo,{{'None',0},{'Trade1',1},{'Trade2',2}},{});
end
function oo = Style(o)                 % Add Style Menu Items          
   setting(o,{'style.bullets'},0);     % provide bullets default
   setting(o,{'style.linewidth'},1);   % provide linewidth default
   
     % add Select Style menu
      
   oo = mitem(o,'Style');
   ooo = mitem(oo,'Bullets','','style.bullets');
   check(ooo,{});
   ooo = mitem(oo,'Line Width','','style.linewidth');
   choice(ooo,[1:3],{});
end
function o = Grid(o)                   % Grid On/Off
   setting(o,{'plot.grid'},1);
   
   oo = mitem(o,'Grid',{},'plot.grid');
        check(oo,{});
end
function o = Dark(o)                   % Dark Mode On/Off
   setting(o,{'view.dark'},1);
   
   oo = mitem(o,'Dark Mode',{},'view.dark');
        check(oo,{});
end
%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu

   ooo = mitem(oo,'-');
   ooo = Scope(oo);                    % select scope
 end
function oo = Scope(o)                 % Scope Menu                    
   setting(o,{'select.scope'},inf);    % chart scope
   
   oo = mitem(o,'Scope',{},'select.scope');
   choice(oo,{{'All',inf},{},{'30 Units',30},...
              {'60 Units',60},{'90 Units',90},{'120 Units',120}},{});
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

function oo = Analyse(o)               % Analyse Menu                  
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu
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
   oooo = mitem(ooo,['Trade Class: Version ',version(trade)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit trade/version');
end
