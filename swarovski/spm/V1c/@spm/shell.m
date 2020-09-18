function oo = shell(o,varargin)        % SPM Shell                     
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
   o = control(o,{'dark'},1);          % run in dark mode

   o = provide(o,'par.title','SPM Toolbox');
   o = provide(o,'par.comment',{'Playing around with SPM objects'});
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
   ooo = Tools(oo);
   ooo = Extras(oo);
end
function oo = New(o)                   % New Menu                      
   oo = mseek(o,{'New'});
   ooo = mitem(oo,'-');
   %ooo = mitem(oo,'Stuff');
   %oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   %ooo = mitem(oo,'Spmx');
   ooo = new(oo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'SPM Data (.spm)',{@ImportCb,'ReadSpmSpm','.spm',@spm});
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
   enable(ooo,0);

   oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Spmx');
   enable(ooo,0);

   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@spm});
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
function oo = Tools(o)                 % Tools Menu Items              
   oo = mseek(o,{'Tools'});
   ooo = mitem(oo,'Cache Reset',{@CacheReset});
   
   function o = CacheReset(o)
      o = pull(o);
      for (i=1:length(o.data))
         oo = o.data{i};
         cache(oo,oo,[]);              % cache hard reset
      end
      message(o,'All Caches Cleared!');
   end
end
function oo = Extras(o)                % Extras Menu Items             
   oo = mseek(o,{'Extras'});
   enable(oo,0);                       % disable Extras menu
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
   ooo = Scale(oo);                    % add Scale sub-menu

   plugin(o,'spm/shell/View');         % plug point
end
function oo = Scale(o)                 % Scale Sub-Menu                
   setting(o,{'view.xunit'},'ms');     % time scaling unit
   setting(o,{'view.xscale'},1e3);     % time scaling factor
   setting(o,{'view.yunit'},'um');     % elongation scaling unit
   setting(o,{'view.yscale'},1e6);     % elongation scaling factor

   oo = mitem(o,'Scale');
   ooo = mitem(oo,'Time Scale',{},'view.xunit');
   choice(ooo,{{'s','s'},{'ms','ms'}},{@XscaleCb});
   ooo = mitem(oo,'Elongation Scale',{},'view.yunit');
   choice(ooo,{{'m','m'},{'mm','mm'},{'um','um'}},{@YscaleCb});
   
   function o = XscaleCb(o)
      unit = setting(o,'view.xunit');
      switch unit
         case 's'
            setting(o,'view.xscale',1);
         case 'ms'
            setting(o,'view.xscale',1e3);
      end
      refresh(o);
   end
   function o = YscaleCb(o)
      unit = setting(o,'view.yunit');
      switch unit
         case 'm'
            setting(o,'view.yscale',1);
         case 'mm'
            setting(o,'view.yscale',1e3);
         case 'um'
            setting(o,'view.yscale',1e6);
      end
      refresh(o);
   end
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   
      % Select event registration must be after above menu(o,'Select')
      % statement, since menu(o,'Select') also registers event, and we
      % must keep the order !!!
      
   event(o,'Select',o);                % call Objects on 'Select' event

   ooo = mitem(oo,'-');
   ooo = Simu(oo);                     % add Simu sub menu
   ooo = Filter(oo);                   % add Filter sub menu
end
function oo = Simu(o)                  % Simulation Parameter Menu     
%
% SIMU   Add simulation parameter menu items
%
   setting(o,{'simu.tmax'},0.01);
   setting(o,{'simu.Fmax'},100);
   setting(o,{'simu.dt'},5e-6);
   setting(o,{'simu.plot'},inf);      % number of points to plot

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Max Time (tmax)',{},'simu.tmax');
          choice(ooo,[1000,2000,5000, 100,200,500,10,20,50, 1,2,5,...
                      0.1,0.2,0.5, 0.01,0.02,0.05, 0.001,0.002,0.005],{});
   ooo = mitem(oo,'Time Increment (dt)',{},'simu.dt');
          choice(ooo,[1e-6,2e-6,5e-6, 1e-5,2e-5,5e-5, 1e-4,2e-4,5e-4,...
                      1e-3,2e-3,5e-3, 1e-2,2e-2,5e-2, 1e-2,2e-2,5e-2],{});
   ooo = mitem(oo,'Number of Points to Plot',{},'simu.plot');
          choice(ooo,[50 100 200 500 1000 inf],{});
          
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Max Force [N]',{},'simu.Fmax');
          choice(ooo,[1 2 5 10 20 50 100 200 500 1000 inf],{});
end
function oo = Filter(o)                % Add Filter Menu Items         
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mhead(o,'Filter');
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

   plugin(o,'spm/shell/Plot');         % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu                  
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'spm/shell/Analyse');      % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'spm/shell/Study');        % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Spmx Class: Version ',version(spm)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit spm/version');

   plugin(o,'spm/shell/Info');         % plug point
end
