function oo = shell(o,varargin)        % ANTENNA shell                 
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

   o = provide(o,'par.title','Antenna Toolbox');
   o = provide(o,'par.comment',{'Antenna Data Analysis'});
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
   %ooo = mitem(oo,'Stuff');
   %oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   %ooo = mitem(oo,'Antenna');
   ooo = new(oo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Antenna Data',{@ImportCb,'ReadAntDir','',@antenna});
   return

   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % import driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = ImportDir(cast(o),drv);   % import object from directory
      paste(o,list);
   end
   function list = ImportDir(o,driver) % Import Object From Dir       
   %
   % IMPORTDIR   Import object(s) from directory
   %
   %             list = import(o,'ReadAntDir','')
   %
      caption = 'Import Antenna Object from Directory';
      path = fselect(o,'d','',caption);

      list = {};                    % init: empty object list
      if ~isempty(path)
         gamma = eval(['@',driver]);   % function handle for import driver
         oo = read(o,driver,path);     % read data file into object
         oo = launch(oo,launch(o));    % inherit launch function
         list{end+1} = oo;             % add imported object to list
      end
   end

end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   enable(oo,0);                       % disabled so far

   ooo = mitem(oo,'Stuff');
   oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Antenna');
   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@antenna});
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

   ooo = Dark(oo);                     % add Dark mode menu item

   ooo = Polar(oo);                    % add Polar Diagram settings menu
   ooo = Mapping(oo);                  % add Mapping menu item
   ooo = WireFrame(oo);                % Wire Frame plot mode
   
   ooo = mitem(oo,'-');
end
function oo = Dark(o)                  % Add Dark Mode Menu Item       
   setting(o,{'view.dark'},0);         % provide dark mode default
   
   oo = mitem(o,'Dark Mode','','view.dark');
   check(oo,{});
end
function oo = Polar(o)                 % Add Polar Diagram Settings    
   setting(o,{'diagram.step'},10);     % provide polar grid step default
   setting(o,{'diagram.min'},[]);      % provide polar grid step default
   setting(o,{'diagram.max'},[]);      % provide polar grid step default
   setting(o,{'diagram.sectors'},12);  % provide polar grid step default
   setting(o,{'diagram.gain'},'r');    % polar grid gain color
   setting(o,{'diagram.zero'},'bc');   % polar grid zero dB color
    
   oo = mitem(o,'-');
   oo = mitem(o,'Polar Grid');
   ooo = mitem(oo,'Min [dB]',{},'diagram.min');
   choice(ooo,{{'Auto',[]},{},[-100:10:-10]},{});
   ooo = mitem(oo,'Max [dB]',{},'diagram.max');
   choice(ooo,{{'Auto',[]},{},[10:10:100]},{});
   ooo = mitem(oo,'Step [dB]',{},'diagram.step');
   choice(ooo,[5,10,20],{});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Sectors',{},'diagram.sectors');
   choice(ooo,[8,12,18],{});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Gain Color',{},'diagram.gain');
   choice(ooo,{{'Red','r'},{'Green','ggk'},...
               {'Blue','bc'},{'Yellow','yyr'}},{});
   ooo = mitem(oo,'Zero dB Color',{},'diagram.zero');
   choice(ooo,{{'Off',''},{'Red','r'},{'Green','ggk'},...
               {'Blue','bc'},{'Yellow','yyr'}},{});
  
end
function oo = Mapping(o)               % Add Mapping Menu Item         
   setting(o,{'style.mapping'},1);     % provide mapping default
   
   oo = mitem(o,'-');

   oo = mitem(o,'Mapping','','style.mapping');
   check(oo,{});
end
function oo = WireFrame(o)             % Add Wire Frame Menu Item      
   setting(o,{'view.wireframe'},0);    % provide dark mode default
   
   oo = mitem(o,'Wire Frame','','view.wireframe');
   check(oo,{});
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
   oo = o;
   return                              % not supported so far
   
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = o;
   return                              % not supported so far

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
   oooo = mitem(ooo,['Antenna Class: Version ',version(antenna)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit antenna/version');
end
