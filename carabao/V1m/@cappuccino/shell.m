function oo = shell(o,varargin)        % CAPPUCCINO shell
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@Analysis);
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
   oo = menu(o,'Select');              % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = provide(o,'par.title','Cappuccino Shell');
   o = provide(o,'par.comment',{'Playing around with CAPPUCCINO objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
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
function oo = New(o)                   % New Menu                      
   oo = menu(o,'New');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');
   ooo = mitem(oo,'Cappuccino');
   oooo = mitem(ooo,'Log Data',{@NewCb});
   return

   function oo = NewCb(o)
      log = ones(1000,1)*randn(1,2) + randn(1000,2)*randn(2,2);

      oo = cappuccino('log');
      oo.par.title = ['Log Data @ ',datestr(now)];
      oo.data.x = log(:,1);
      oo.data.y = log(:,2);

      oo = launch(oo,launch(o));       % inherit launch function
      paste(o,{oo});                   % paste object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@cappuccino});
   ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'ReadLogLog','.log',@cappuccino});
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
   ooo = mitem(oo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@cappuccino});
   ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'WriteLogLog','.log',@cappuccino});
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
   setting(o,{'plot.color'},'k');      % provide linewidth default
   
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Stream Plot X',{@PlotCb,'StreamX'});
   ooo = mitem(oo,'Stream Plot Y',{@PlotCb,'StreamY'});
   ooo = mitem(oo,'Scatter Plot',{@PlotCb,'Scatter'});
   ooo = mitem(oo,'-');                % separator
   ooo = mitem(oo,'Bullets','','plot.bullets');
   check(ooo,{});
   ooo = mitem(oo,'Line Width','','plot.linewidth');
   choice(ooo,[1:3],{});
   ooo = mitem(oo,'Scatter Color','','plot.color');
   charm(ooo,{});
   return

   function oo = PlotCb(o)
      refresh(o,o);                    % use this callback for refresh
      oo = plot(o);                    % forward to capuchino.plot method
   end
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                     
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                   
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Cappuccino Class: Version ',version(cappuccino)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit cappuccino/version');
end
