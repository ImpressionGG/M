function oo = shell(o,varargin)        % CORASIM shell                 
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@View,@Select,...
                      @Plot,@PlotCb,@Analysis,@Study,@Simu,@Brew);
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
%  oo = Analysis(o);                   % add Analysis menu
%  oo = Study(o);                      % add Study menu
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

   o = provide(o,'par.title','Corasim Shell');
   o = provide(o,'par.comment',{'Playing around with CORASIM objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'View','Select','Plot','Analysis','Study'};
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
   ooo = mitem(oo,'Corasim');
   oooo = new(ooo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Corasim');
   oooo = mitem(ooo,'Log Data (.dat)',{@ImportCb,'ReadGenDat','.dat',@corasim});
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
   ooo = mitem(oo,'Corasim');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@corasim});
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
   
   oo = menu(o,'View');
   ooo = menu(oo,'Filter');            % add Filter menu items
   
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Scale');             % add Scale menu items
   ooo = menu(oo,'Bode');              % add Bode setting menu items
   ooo = menu(oo,'Nyquist');           % add Nyquist setting menu items
   ooo = menu(oo,'Rloc');              % add Root Locus menu items
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = mhead(o,'Select');             % add roll down header item
   dynamic(oo);                        % make this a dynamic menu
   event(o,'Select',o);                % rebuild menu on 'Select' event
   
   ooo = menu(oo,'Objects');           % add Open menu item
   ooo = menu(oo,'Basket');            % add Basket menu
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Simu');              % add simulation parameter menu
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
   
%  ooo = analysis(oo,'Menu');          % setup analysis menu
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
   oooo = mitem(ooo,['Corasim Class: Version ',version(corasim)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit corasim/version');
end
