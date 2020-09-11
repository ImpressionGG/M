function oo = shell(o,varargin)        % Tiny Shell for CORINTH Class  
% 
% SHELL   Open new figure and setup menu for a CORAZON object
%      
%            o = corinth     % create a CORINTH object
%            shell(o)        % open a CORINTH shell
%
%        See also: CORINTH, MENU, SHO, CUO
%
   [gamma,oo] = manage(o,varargin,@Shell,@Dynamic,@New,@Stuff,@Edit,...
                       @View,@Plot,@Show,@Animate,@Animation,@Analyse,...
                       @Study,@Test,@Tutorial,@Plugin,@Gallery,@Figure);
   oo = gamma(oo);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);   

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Edit(o);                       % add File menu
   %oo = View(o);                      % add Views menu
   oo = Select(o);                     % add Select menu
   %oo = Plot(o);                       % add Plot menu
   %oo = Analyse(o);                    % add Analyse menu
   oo = Study(o);                      % add Study menu
   %oo = Plugin(o);                     % add Plugin menu
   oo = Test(o);                       % add Test menu
   oo = Tutorial(o);                   % add Tutorial menu
   oo = Gallery(o);                    % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = Figure(o);                     % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o.type = 'shell';                   % convert to a 'shell' typed object
   o.data = {};                        % overwrite data
   o = set(o,{'base'},1e2);
   
   if isempty(get(o,'title')) && container(o)
      o = refresh(o,{'menu','About'}); % provide refresh callback
      o = set(o,'title','Corinth Shell');
      o = set(o,'comment',{'a dynamic shell for Corinth objects'});
      o = control(o,{'dark'},0);       % run in non dark mode
   end
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % use this mfile as launch function
end
function list = Dynamic(o)             % Get Dynamic Menu List         
   list = {'View','Plot','Analyse','Study','Test','Tutorial','Plugin'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = shell(oo,'New');              % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
end
function oo = New(o)                   % Add New Menu                  
   oo = mseek(o,{'New'});              
   ooo = mitem(oo,'-');
   ooo = new(oo,'Menu');
   plugin(oo,'corazon/shell/New');  % plug point
end
function oo = Stuff(o,typ)             % Create New Stuff              
   if (nargin < 2)
      typ = arg(o,1);
   end
   switch typ
      case 'weird'
         oo = mitem(o,'Weird',{@NewCb,'Weird'});
      case 'ball'
         oo = mitem(o,'Ball',{@NewCb,'Ball'});
      case 'cube'
         oo = mitem(o,'Cube',{@NewCb,'Cube'});
      case 'txy'
         oo = mitem(o,'Txy',{@NewCb,'Txy'});
   end
   return
   
   function oo = NewCb(o)              % Create New Stuff              
      oo = new(o);                     % create new (stuff) object
      paste(o,{oo});                   % paste object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % seek Import menu header item
   ooo = mitem(oo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt'});
   plugin(oo,'corazon/shell/Import');  % plug point
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      driver = arg(o,1);
      ext = arg(o,2);
      list = import(o,driver,ext);     % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % seek Export menu header item
   ooo = mitem(oo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt'});
   plugin(oo,'corazon/shell/Export');  % plug point
   return
   
   function oo = ExportCb(o)           % Export Log Data Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         driver = arg(o,1);
         ext = arg(o,2);
         export(oo,driver,ext);        % export object to file
      end
   end
end

%==========================================================================
% Edit Menu
%==========================================================================

function oo = Edit(o)                  % Edit Menu                     
   oo = menu(o,'Edit');                % add Edit menu
   plugin(oo,'corazon/shell/Edit');    % plug point
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

   plugin(o,'corazon/shell/View');     % plug point
end
function oo = Grid(o)                  % Grid Menu                    
%
% GRID   Add grid menu items
%
   setting(o,{'view.grid'},0);

   oo = mitem(o,'Grid',{},'view.grid');
   check(oo,{});
end
function oo = Style(o)                 % Add Style Menu Items
   setting(o,{'style.bullets'},1);     % provide bullets default
   setting(o,{'style.linewidth'},1);   % provide linewidth default
   setting(o,{'style.scatter'},'ryy'); % provide scatter color default

   oo = mitem(o,'Style');
   ooo = mitem(oo,'Bullets','','style.bullets');
   check(ooo,{});
   ooo = mitem(oo,'Line Width','','style.linewidth');
   choice(ooo,[1:3],{});
   ooo = mitem(oo,'Scatter Color','','style.scatter');
   charm(ooo,{});
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   if isempty(oo)
      return
   end
   plugin(oo,'corazon/shell/Select');  % plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu (Dynamic)           
   oo = mhead(o,'Plot');
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');
end

%==========================================================================
% Analyse Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu (Dynamic)        
   oo = mhead(o,'Analyse');
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu (Dynamic)          
   oo = mhead(o,'Study');
   dynamic(oo);                        % make this a dynamic menu
%  ooo = study(oo,'Menu');

   plugin(oo,'corazon/shell/Study');   % plug point
end

%==========================================================================
% Test Menu
%==========================================================================

function oo = Test(o)                  % Test Menu (Dynamic)           
   oo = mhead(o,'Test');
   dynamic(oo);                        % make this a dynamic menu
   ooo = test(oo,'Menu');

   plugin(oo,'corinth/shell/test');    % plug point
end

%==========================================================================
% Tutorial Menu
%==========================================================================

function oo = Tutorial(o)              % Tutorial Menu (Dynamic)       
   oo = mhead(o,'Tutorial');
   dynamic(oo);                        % make this a dynamic menu
%  ooo = tutorial(oo,'Menu');

   plugin(oo,'corazon/shell/Tutorial');% plug point
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu (Dynamic)         
   oo = menu(o,'Plugin');              % menu will be hidden
   dynamic(oo);                        % make this a dynamic menu
   oo = plugin(oo,'corazon/shell/Plugin');
end

%==========================================================================
% Gallery Menu
%==========================================================================

function oo = Gallery(o)               % Gallery Menu                  
   oo = menu(o,'Gallery');             % add Gallery menu
   plugin(oo,'corazon/shell/Gallery'); % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   %oo = mhead(o,'Info');               % add sub menu header
   oo = menu(o,'Info');
   plugin(oo,'corinth/shell/Info');    % plug point
   return
   
   ooo = mitem(oo,'Shell Info');
   oooo = mitem(ooo,'Display',{@Disp,'Shell'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'Shell'});
   ooo = mitem(oo,'-');
   
   ooo = mitem(oo,'About Object');
   oooo = mitem(ooo,'Display',{@Disp,'About'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'About'});
   
   EN = 'enable';                      % short hand
   ooo = mitem(oo,'Parameters   ');
   oooo = mitem(ooo,'Display',{@Disp,'Parameter'});
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Edit ...',{@Edit,'Parameter'});

   ooo = mitem(oo,'-');
   ooo = menu(oo,'Version');           % add Version menu
   ooo = mitem(oo,'Tutorial','','','visible','off');
   ooo = mitem(oo,'-');
   ooo = Debug(oo);                    % add Debug menu
   return
   
   function oo = Disp(o)               % Display Info                  
      mode = arg(o,1);
      switch mode
         case 'Shell'
            oo = Home(o);              % go directly
         case 'About'
            oo = About(o);             % about the current object
         case 'Parameter'
            oo = menu(o,'Parameter');  % key parameter info
      end
   end
   function oo = Edit(o)               % Edit Info                     
      mode = arg(o,1);
      switch mode
         case 'Shell'
            oo = opt(o,'caption','Edit Shell Info');
            oo = Property(oo);         % edit object properties
            if ~isempty(oo)
               o = set(o,'title',get(oo,'title'));
               o = set(o,'comment',get(oo,'comment'));
               push(o);            % push modified object into shell

               title = get(o,{'title','Shell'}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(o,{mode}));
            end      
         case 'About'
            oo = current(o);           % get current object
            oo = opt(oo,'caption','Edit Object Info (About ...)');
            oo = Property(oo);         % edit object properties
            if ~isempty(oo)
               current(corazon,oo);    % update current object

               title = get(o,{'title','Shell'}); 
               title = get(oo,{'title',title}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(oo,{mode}));
            end      
         case 'Parameter'
            oo = current(o);           % get current object
            oo = opt(oo,'caption','Edit Key Parameters');
            oo = menu(oo,'Dialog');    % dialog for editing key parameters
            if ~isempty(oo)
               current(corazon,oo);    % update current object

               title = get(o,{'title','Shell'}); 
               title = get(oo,{'title',title}); 
               set(figure(o),'name',title); % update title in figure header
               Disp(arg(oo,{mode}));
            end      
      end
   end
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = Figure(o)                % Figure Menu                   
   oo = menu(o,'Figure');              % add Figure menu
   plugin(oo,'corazon/shell/Figure');  % plug point
end

