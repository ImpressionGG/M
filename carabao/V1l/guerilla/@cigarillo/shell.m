function oo = shell(o,varargin)        % CIGARILLO shell
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@PlotCb,...
                        @New,@Import,@Export,@Collect,...
                        @Signal,@PLot,@PlotCb,@Analysis,@Info);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = shell(o,'Edit');               % add Edit menu
   oo = shell(o,'View');               % add View menu
   oo = shell(o,'Select');             % add Select menu
   oo = wrap(o,'Plot');                % add Plot menu (wrapped)
   oo = wrap(o,'Analysis');            % add Analysis menu (wrapped)
   oo = shell(o,'Plugin');             % add Plugin menu
   oo = shell(o,'Gallery');            % add Gallery menu
   oo = shell(o,'Info');               % add Info menu
   oo = shell(o,'Figure');             % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = set(o,{'title'},'Cigarillo Shell');
   o = set(o,{'comment'},{'Playing around with CIGARILLO objects'});
   o = opt(o,{'mode.bias'},'drift');
   
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
function oo = New(o)                   % New Menu Items                
   oo = menu(o,'New');                 % add CARAMEL New menu
   ooo = mitem(oo,'Stuff');
   oooo = shell(ooo,'Stuff','weird');
   oooo = shell(ooo,'Stuff','ball');
   oooo = shell(ooo,'Stuff','cube');
   plugin(oo,'cigarillo/shell/New');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Package',{@CollectCb});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@carabao});
   plugin(oo,'cigarillo/shell/Import');  % plug point
   return

   function o = ImportCb(o)            % Import Log Data Callback      
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
   function o = CollectCb(o)           % Collect All Files of Folder   
      list = collect(o);               % collect files in directory
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
%    ooo = mitem(oo,'Log Data');         % Log Data category
%    oooo = mitem(ooo,'Plain or Simple (.log)',{@ExportCb,'LogData','.log',@cigarillo});
%    oooo = mitem(ooo,'-');
%    oooo = mitem(ooo,'Separator',{},'export.separator');
%    choice(oooo,{{'None',''},{'"|"','|'},{'";"',';'}});
   
   plugin(oo,'cigarillo/shell/Export');
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
function oo = Collect(o)               % Configure Collection          
   co = cast(o,'caramel');
   oo = shell(co,'Collect');           % delegate to caramel/shell/Collect
   plugin(o,'cigarillo/shell/Collect');% plug point
end

%==========================================================================
% View Menu
%==========================================================================

function oo = Signal(o)                % Signal Menu                   
   co = cast(o,'caramel');
   oo = shell(co,'Signal');
   plugin(oo,'cigarillo/shell/Signal');% plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = menu(oo,'Plot');
   plugin(oo,'cigarillo/shell/Plot');
end
function oo = PlotCb(o)                % Plot Callback                 
   refresh(o,inf);                     % use this callback for refresh
   oo = plot(o);                       % forward to cigarillo.plot method
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = menu(oo,'Geometry');
   %ooo = RawReading(oo);
   plugin(oo,'cigarillo/shell/Analysis');
end

%==========================================================================
% Raw Reading Menu
%==========================================================================

function o = RawReading(o)             % Raw Reading Menu Setup                   
   o = Default(o);
   oo = mitem(o,'Raw Reading');        % setup Raw Reading menu header
   ooo = mitem(oo,'Axis Data X',{@Gplot,'adatax'});
   ooo = mitem(oo,'Axis Data Y',{@Gplot,'adatay'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Filtered Axis Data X',{@Gplot,'fadatax'});
   ooo = mitem(oo,'Filtered Axis Data Y',{@Gplot,'fadatay'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Axis Noise X',{@Gplot,'anoisex'});
   ooo = mitem(oo,'Axis Noise Y',{@Gplot,'anoisey'});
   ooo = mitem(oo,'-');
%       uimenu(men,LB,'Calibration Points',CB,'menu(pull(core),''calib'')');
%       uimenu(men,LB,'Filtered Calibration Points',CB,'menu(pull(core),''fcalib'')');
%       uimenu(men,LB,'-------------');
%       uimenu(men,LB,'Drift Of Axis Data ',CB,'menu(pull(core),''daxis'')');
%       uimenu(men,LB,'Time Residual Of Axis Data ',CB,'menu(pull(core),''timres'')');
%       uimenu(men,LB,'Repeat Accuracy Eval.',CB,'menu(pull(core),''evrepeat'')');
%       itm = uimenu(men,LB,'Drift Evaluation');
%       uimenu(itm,LB,'Cyclic Drift',CB,'menu(pull(core),''cycdrift'')');
%       uimenu(itm,LB,'CyclicN Drift',CB,'menu(pull(core),''cycNdrift'')');
%       uimenu(itm,LB,'Cmk',CB,'menu(pull(core),''evdrift'')');
%       uimenu(itm,LB,'Mean Value',CB,'menu(pull(core),''evdriftmean'')');
%       uimenu(itm,LB,'Standard Deviation',CB,'menu(pull(core),''evdriftstd'')');
%       uimenu(men,LB,'-------------');
%       uimenu(men,LB,'Protocol Standard',CB,'menu(pull(core),''protstand'')');
%       uimenu(men,LB,'Protocol Repeatability',CB,'menu(pull(core),''protrep'')');
%       uimenu(men,LB,'Protocol Temperature Drift',CB,'menu(pull(core),''prottemp'')');
%       uimenu(men,LB,'Protocol Quality Run',CB,'menu(pull(core),''protquality'')');
%       uimenu(men,LB,'-------------');
%       uimenu(men,LB,'Show Quality Numbers',CB,'menu(pull(core),''protqual'')');
%       uimenu(men,LB,'File Quality Numbers',CB,'menu(pull(core),''filequal'')');      
end

function oo = Gplot(o)                 % General Plot Function        
%
% PLOT   General plot function
%
%    Supports the following modes (mode = arg(o,1))
%
%       'pcorrx'
%       'pcorry'
%       'pcorrxy'
%       'rcorrx'
%       'rcorry'
%       'rcorrxy'
%       'frcorrx'
%       'frcorry'
%       'rnoisex'
%       'rnoisey'
%       'adatax'                       % axis sata X 
%       'adatay'                       % axis data y
%       'fadatax'
%       'fadatay'
%       'anoisex'
%       'anoisey'
%       'calib'
%       'fcalib'
%       'daxis'
%       'cycdrift'
%       'cycNdrift'
%       'evrepeat'
%       'evdrift'
%       'evdriftmean'
%       'evdriftstd'
%       'linscalex'
%       'linscaley'
%       'linshear'
%       'nlinsx'
%       'nlinsy'
%       'nlinrx'
%       'nlinry'
%       'chdef'
%       'chcomp'
%       'vdriftxt'
%       'vdriftyt'
%       'vadriftxt'
%       'vadriftyt'
%       'timres'
%
   oo = o;                             % init out arg by default
   mode = arg(o,1);                  
                  
   cls(o);                          % clrscr(danaFigure('danaMenuFigure'));
   %if ( storecallback ), storecb(mode); end
      
   sel = opt(o,'dana.s2');             % getud(2);
   iref = opt(o,'dana.s8');            % getud(8);
   filter = opt(o,'dana.s8');          % getud(7);      % filter mode
   calc = opt(o,'dana.s10');           % getud(10);	  % calc mode
   
   gplot(o,mode,{sel(1),iref,filter,calc});
   
   switch mode
      case {'pcorrx','rcorrx','frcorrx','rnoisex','adatax',...
            'fadatax','anoisex'}
         setting(o,'dana.s4','s5');      % view parameter set is getud(5)
         tag = ['dana.',setting('dana.s4')];
         azel = setting(o,tag);
         view(azel);                   % set view parameters
         
      case {'pcorry','rcorry','frcorry','rnoisey','adatay',...
            'fadatay','anoisey'}
         setting(o,'dana.s4','s6');      % view parameter set is getud(5)
         tag = ['dana.',setting('dana.s4')];
         azel = setting(o,tag);
         view(azel);                   % set view parameters
   end
end
function oo = Default(o)               % Provide default settings      
%
% DEFAULT   Provide default settings
%
% As it was originally
%    setud(2,[1 1 count(obj)]);        % 3 vector: [selection minselection maxselection]
%    setud(3,'');                      % previous invoked callback
%    setud(4,'s5');                    % index of view parameter set
%    setud(5,[30,30]);                 % view parameters for Cx
%    setud(6,[30,30]);                 % view parameters for Cy
%    setud(7,[6 6]);                   % filter mode: 2nd order fit once, width 6
%    setud(8,1);                       % reference index
%    %setud(9,1);                      % series index (do not initialize within this function)
%    setud(10,1);                      % calculate mode (study)
%    setud(12,0);                      % control runs used for repeatabilty calculation
%    setud(13,10);                     % xy spec [um]
%    setud(14, false);                 % high accuracy gate on or off
%
   [m,n,r] = sizes(o);
   setting(o,'dana.s2',[1 1 r]);       % 3 vector: [selection, min, max]
   setting(o,'dana.s3','');            % previously invoked callback
   setting(o,'dana.s4','s5');          % index of view parameter set
   setting(o,'dana.s5',[30,30]);       % view parameters for Cx
   setting(o,'dana.s6',[30,30]);       % view parameters for Cy
   setting(o,'dana.s7',[6 6]);         % filter mode: 2nd order fit once, width 6
   setting(o,'dana.s8',1);             % reference index
   setting(o,'dana.s9',1);             % series index (do not init within this function)
   setting(o,'dana.s10',1);            % calculate mode (study)
   setting(o,'dana.s11',[]);           % ???
   setting(o,'dana.s12',0);            % control runs used for repeatabilty calculation
   setting(o,'dana.s13',10);           % xy spec [um]
   setting(o,'dana.s14', false);       % high accuracy gate on or off
   
   oo = opt(o,setting(o));             % refresh options (don't use GFO)
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                   
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Cigarillo Class: Version ',version(cigarillo)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit cigarillo/version');
   plugin(oo,'cigarillo/shell/Info');
end
