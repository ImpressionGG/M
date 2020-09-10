function menu(obj,func,cbo)
% 
% MENU   Open new figure and setup menu for a SHELL object
%      
%           obj = shell(fmt)               % create SHELL object
%           menu(obj)                      % open figure, setup menu
%
%        In addition to visible parts of the menu the menu method provides
%        several mounting points for menus which are provided  later on.
%        A mount point is specified by a mount point identifier:
%
%           <file>    one mount point for file menu
%           <tools>   several mount points for tools menus
%           <view>    one mount point for VIEW menu
%           <main>    several mount points for main menus
%           <window>  one mount point for windows menu
%           <demo>    one mount point for info menu
%           <addon>   several mount point for addon menus
%           <info>    one mount point for info menu
%           <help>    one mount point for help menu
%
%        Called with 1 argument menu setup depends on the format of the
%        SHELL object:
%
%           menu(shell)                    % setup basic menu
%           menu(shell('#GENERIC'));       % setup basic menu
%        
%        Internally the menu method is also used to dispatch callback
%        functions:
%
%           menu(obj,'open')      % call 'open' callback
%           menu(obj,'plot',cbo)  % optionally provide current callback obj
%
%        See also: SHELL CLRSCR ADDON GCFO GCBO CHECK CHOICE MOUNT

   if (nargin == 1)
      setup(obj,[]);                        % setup menu items
   else
      handle(obj,func,eval('cbo','gcbo'));  % handle callback
   end
   return
      
%==========================================================================
% 1) Some auxillary functions we need in the context of this file
%==========================================================================

function cb = call(func)       % create callback for local function call
   cb = [mfilename,'(gcfo,''',func,''');'];
   return

function handle(obj,func,cbo)  % handle callback
   if ~propagate(obj,func,cbo,which(func))        
      eval([func,'(obj,cbo);']); 
   end
   return

function keypress(func)                  % setup keypress function
   set(gcf,'WindowButtonDownFcn',call(eval('func','''CbKeyPress''')));
   return
  
%==========================================================================
% 2) User Defined Menu Setup
%==========================================================================

function setup(obj,parent)      % Setup all standard menus
%
% SETUP    Setup menu
%
   profiler('setup',1);         % begin profiling menu setup
   inifig(obj);                 % initialize figure & set defaults
   
      % Setup menu structure by providing mount points
   
   mountpoints = {'<file>','<xfile>',...
      '<tools>','<tools>','<tools>','<tools>','<tools>',...
      '<tools>','<tools>','<tools>','<tools>','<tools>',...
      '<view>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<window>','demo>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<info>','<help>'};      

   for (i=1:length(mountpoints))
      uimenu(gcf,'label',mountpoints{i},'visible','off');
   end
   
      % Now create shell menus as being advised
      
   menulist = get(obj,'menu');
   
   for (i=1:length(menulist))
      key = menulist{i};
      switch key
         case 'file'
            FileMenu(obj,'<file>');    % setup FILE menu
         case 'xfile'
            XfileMenu(obj,'<file>');   % setup extended FILE menu
         case 'tools'
            ToolsMenu(obj,'<tools>');  % setup TOOLS menu
         case 'info'
            InfoMenu(obj,'<info>');    % setup SIMULATION menu
         case 'play'
            PlayMenu(obj,'<main>');    % setup PLAY menu
      end
   end

   AddonMenus(obj);                    % launch addon menus
   
   if isempty(parent)                  % reinvoke only on top level
      drawnow;
      cbinvoke(obj);                   % by default display object's info
   end

   profiler('setup',-1);               % end profiling menu setup
   return                     

%==========================================================================      
   
function inifig(obj)
%
% INIFIG    Initialize figure to comply with CHAMEO menu support
%
   
   if (~isempty(get(gcf,'children')))
      position = option(obj,'position');
      menubar = option(obj,'menubar');
      hdl = figure;                               % open new figure
      
      if ~menubar
         set(gcf,'menubar','none'); % no standard menubar
      end

      if ~isempty(position)
         set(hdl,'position',position);      
      end
   end

      % first we retrieve options from object and add these as settings.
      % Don't forget to push object itself into settings later on!.
   
   settings = option(obj);       % retrieve settings if provided by object
   
      % if no special callback provided by object's options
      % then we rewrite the callback settings by a call to CbDataInfo
      
   if (isempty(option(obj,'callback')))
       settings.callback = {'menu(gcfo,''CbDataInfo'',cbo);',[]};
   end

   setting(settings);            % use these settings from now globally
   if setting('ohdl')
      fprintf('*** warning: expected empty OHDL during menu:inifig()\n');
      setting('ohdl',[]);
   end
   gcfo(obj);                    % don't forget to push object into figure
   
   clrscr off;                   % clear screen, axes off
   bright;                       % switch to bright mode
   
   set(gcf,'name',info(obj));    % display objects title in title bar
   set(gcf,'numbertitle','off');

      % we need to setup some defaults
      
   default('menubar',0);   % standard menus off
   
   if (~setting('menubar'))
      set(gcf,'menubar','none'); % no standard menubar
   end
   return

   
%==========================================================================      
% Addon Menus
%==========================================================================      

function AddonMenus(obj)
%
      % first of all we see if there are object specific addon's
      % defined. If yes we have to launch these addon's
      
   list = get(obj,'addon');            % get object specific addon list
   aolaunch(list);
   
      % next we have to launch the CHAMEO toolbox specific addon's.
         
   %list = toolbox(obj,'addon');       % get current addon list
   list = toolbox(smart,'addon');      % get current addon list
   aolaunch(list);
   return
   
%==========================================================================      
% File Menu
%==========================================================================      

function FileMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('cbinvoke(gcfo)')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('cbinvoke(gcfo)')];

   default('filename','');      % common file name for FILE operations
   default('directory','');     % common directory name for FILE operations
   
   %men = uimenu(gcf,LB,'File',UD,2);
   men = mount(obj,mountpt,LB,'File');
   itm = uimenu(men,LB,'Open ...',CB,call('CbOpen'));
   itm = uimenu(men,LB,'Save As ...',CB,call('CbSaveas'));
   itm = uimenu(men,LB,'Clone',CB,call('CbClone'));
   launch = toolbox(smart,'launch');   % get launch base
   if (~isempty(launch))
      itm = uimenu(men,LB,'Launch Base',CB,call('CbClose'),UD,-2);
   end

   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Close Other',CB,call('CbClose'),UD,0);
   itm = uimenu(men,LB,'Close All',CB,call('CbClose'),UD,1);
   itm = uimenu(men,LB,'Close',CB,call('CbClose'),UD,-1);
   
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Exit',CB,call('CbClose'),UD,2);
   return

%==========================================================================      
   
function XfileMenu(obj)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('cbinvoke(gcfo)')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('cbinvoke(gcfo)')];

   default('filename','');      % common file name for FILE operations
   default('directory','');     % common directory name for FILE operations

   default('make.verbose',1);       % verbose mode for make & compile
   default('make.nanmode',1);       % NaN mode for make & compile
   default('make.tslice',5);        % time slice [s]
   default('make.lmax',2000);       % max. parser list length to save
   default('make.format','#CHM1');  % default format for MAKE utility
   default('make.cycles',inf);      % number of production cycles to parse
   default('make.terminate',1);     % terminate after last ProdCycleEnd 
   default('make.profile','off');   % profiler off for make

   default('profile',1);            % reset profiling before each menu call
   
   men = uimenu(gcf,LB,'File',UD,2);
%  if property(obj,'series')
      %for i=1:length(count(obj))
      %   lab = info(series(obj,i));
      %   itm = uimenu(men,LB,lab,CB,sprintf('menu(gfo,''choose%g'')',i));
      %end
%     itm = uimenu(men,LB,'-------------');
%  end
   itm = uimenu(men,LB,'Open ...',CB,call('CbOpen'));
   itm = uimenu(men,LB,'Save As ...',CB,call('CbSaveas'));
   itm = uimenu(men,LB,'Clone',CB,call('CbClone'));
   %launch = toolbox(obj,'launch');   % get launch base
   launch = toolbox(smart,'launch');   % get launch base
   if (~isempty(launch))
      itm = uimenu(men,LB,'Launch Base',CB,call('CbClose'),UD,-2);
   end
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Edit');
         uimenu(itm,LB,'Edit Title ...',CB,call('CbEditTitle'));
         uimenu(itm,LB,'Add Comment ...',CB,call('CbAddComment'));
         uimenu(itm,LB,'Clear Comments ...',CB,call('CbClearComments'));
         
   itm = uimenu(men,LB,'Profiler');
         uimenu(itm,LB,'Profiling Info',CB,call('CbProfile'));
         uimenu(itm,LB,'------------------');
         uimenu(itm,LB,'Reset Profiler',CB,'profiler([]);');
   sub = uimenu(itm,LB,'Auto Reset',CB,CHK,UD,'profile');
         check(sub,setting('profile'));

   itm = uimenu(men,LB,'Make');
         uimenu(itm,LB,'Snif ...',CB,call('CbSnif'));
         uimenu(itm,LB,'Make ...',CB,call('CbMake'));
         uimenu(itm,LB,'------------------');
   sub = uimenu(itm,LB,'Verbose',UD,'make.verbose');
         uimenu(sub,LB,'off',CB,CHC,UD,0);
         uimenu(sub,LB,'1',CB,CHC,UD,1);
         uimenu(sub,LB,'2',CB,CHC,UD,2);
         uimenu(sub,LB,'3',CB,CHC,UD,3);
         choice(sub,setting('make.verbose'));
   sub = uimenu(itm,LB,'Format',UD,'make.format');
         uimenu(sub,LB,'#CHM1',CB,CHC,UD,'#CHM1');
         uimenu(sub,LB,'------------------');
         uimenu(sub,LB,'#GMA1',CB,CHC,UD,'#GMA1');
         uimenu(sub,LB,'#GMA2',CB,CHC,UD,'#GMA2');
         choice(sub,setting('make.format'));
   sub = uimenu(itm,LB,'Max. Product Cycles',UD,'make.cycles');
         uimenu(sub,LB,'Infinite',CB,CHC,UD,inf);
         uimenu(sub,LB,'2',CB,CHC,UD,2);
         uimenu(sub,LB,'5',CB,CHC,UD,5);
         uimenu(sub,LB,'10',CB,CHC,UD,10);
         uimenu(sub,LB,'20',CB,CHC,UD,20);
         uimenu(sub,LB,'50',CB,CHC,UD,50);
         uimenu(sub,LB,'100',CB,CHC,UD,100);
         uimenu(sub,LB,'200',CB,CHC,UD,200);
         uimenu(sub,LB,'500',CB,CHC,UD,500);
         uimenu(sub,LB,'1000',CB,CHC,UD,1000);
         choice(sub,setting('make.cycles'));
   sub = uimenu(itm,LB,'Terminate after last ProdCycle',UD,'make.terminate');
         uimenu(sub,LB,'Off',CB,CHC,UD,0);
         uimenu(sub,LB,'On',CB,CHC,UD,1);
         choice(sub,setting('make.terminate'));
   sub = uimenu(itm,LB,'Max. Length Parser List',UD,'make.lmax');
         uimenu(sub,LB,'off',CB,CHC,UD,0);
         uimenu(sub,LB,'1000',CB,CHC,UD,1000);
         uimenu(sub,LB,'2000',CB,CHC,UD,2000);
         uimenu(sub,LB,'5000',CB,CHC,UD,5000);
         uimenu(sub,LB,'Inf',CB,CHC,UD,Inf);
         choice(sub,setting('make.lmax'));
   sub = uimenu(itm,LB,'Profiling',UD,'make.profile');
         uimenu(sub,LB,'off',CB,CHC,UD,'off');
         uimenu(sub,LB,'on',CB,CHC,UD,'on');
         choice(sub,setting('make.profile'));

   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Demos');
         uimenu(itm,LB,'Playing Around',CB,'demo(chameo(''PLAYDEMO''));');
         uimenu(itm,LB,'Filter Demo',CB,'demo(chameo(''FILTDEMO''));');
         uimenu(itm,LB,'Chameo Devices',CB,'demo(chameo(''#CHM''));');
         uimenu(itm,LB,'Evo Devices',CB,'demo(chameo(''#EVO''));',EN,'off');
         uimenu(itm,LB,'Dragon Devices',CB,'demo(chameo(''#DRG''));',EN,'off');
         
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Close Other',CB,call('CbClose'),UD,0);
   itm = uimenu(men,LB,'Close All',CB,call('CbClose'),UD,1);
   itm = uimenu(men,LB,'Close',CB,call('CbClose'),UD,-1);
   
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Exit',CB,call('CbClose'),UD,2);
   return
   
%==========================================================================      
   
function ToolsMenu(obj)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('cbinvoke(gcfo)')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('cbinvoke(gcfo)')];

   default('filename','');      % common file name for FILE operations
   default('directory','');     % common directory name for FILE operations

   default('make.verbose',1);       % verbose mode for make & compile
   default('make.nanmode',1);       % NaN mode for make & compile
   default('make.tslice',5);        % time slice [s]
   default('make.lmax',2000);       % max. parser list length to save
   default('make.format','#CHM1');  % default format for MAKE utility
   default('make.cycles',inf);      % number of production cycles to parse
   default('make.terminate',1);     % terminate after last ProdCycleEnd 
   default('make.profile','off');   % profiler off for make

   default('profile',1);            % reset profiling before each menu call
   
   men = uimenu(gcf,LB,'Tools',UD,2);
   itm = uimenu(men,LB,'Edit');
         uimenu(itm,LB,'Edit Title ...',CB,call('CbEditTitle'));
         uimenu(itm,LB,'Add Comment ...',CB,call('CbAddComment'));
         uimenu(itm,LB,'Clear Comments ...',CB,call('CbClearComments'));
         
   itm = uimenu(men,LB,'Profiler');
         uimenu(itm,LB,'Profiling Info',CB,call('CbProfile'));
         uimenu(itm,LB,'------------------');
         uimenu(itm,LB,'Reset Profiler',CB,'profiler([]);');
   sub = uimenu(itm,LB,'Auto Reset',CB,CHK,UD,'profile');
         check(sub,setting('profile'));

   itm = uimenu(men,LB,'Make');
         uimenu(itm,LB,'Snif ...',CB,call('CbSnif'));
         uimenu(itm,LB,'Make ...',CB,call('CbMake'));
         uimenu(itm,LB,'------------------');
   sub = uimenu(itm,LB,'Verbose',UD,'make.verbose');
         uimenu(sub,LB,'off',CB,CHC,UD,0);
         uimenu(sub,LB,'1',CB,CHC,UD,1);
         uimenu(sub,LB,'2',CB,CHC,UD,2);
         uimenu(sub,LB,'3',CB,CHC,UD,3);
         choice(sub,setting('make.verbose'));
   sub = uimenu(itm,LB,'Format',UD,'make.format');
         uimenu(sub,LB,'#CHM1',CB,CHC,UD,'#CHM1');
         uimenu(sub,LB,'------------------');
         uimenu(sub,LB,'#GMA1',CB,CHC,UD,'#GMA1');
         uimenu(sub,LB,'#GMA2',CB,CHC,UD,'#GMA2');
         choice(sub,setting('make.format'));
   sub = uimenu(itm,LB,'Max. Product Cycles',UD,'make.cycles');
         uimenu(sub,LB,'Infinite',CB,CHC,UD,inf);
         uimenu(sub,LB,'2',CB,CHC,UD,2);
         uimenu(sub,LB,'5',CB,CHC,UD,5);
         uimenu(sub,LB,'10',CB,CHC,UD,10);
         uimenu(sub,LB,'20',CB,CHC,UD,20);
         uimenu(sub,LB,'50',CB,CHC,UD,50);
         uimenu(sub,LB,'100',CB,CHC,UD,100);
         uimenu(sub,LB,'200',CB,CHC,UD,200);
         uimenu(sub,LB,'500',CB,CHC,UD,500);
         uimenu(sub,LB,'1000',CB,CHC,UD,1000);
         choice(sub,setting('make.cycles'));
   sub = uimenu(itm,LB,'Terminate after last ProdCycle',UD,'make.terminate');
         uimenu(sub,LB,'Off',CB,CHC,UD,0);
         uimenu(sub,LB,'On',CB,CHC,UD,1);
         choice(sub,setting('make.terminate'));
   sub = uimenu(itm,LB,'Max. Length Parser List',UD,'make.lmax');
         uimenu(sub,LB,'off',CB,CHC,UD,0);
         uimenu(sub,LB,'1000',CB,CHC,UD,1000);
         uimenu(sub,LB,'2000',CB,CHC,UD,2000);
         uimenu(sub,LB,'5000',CB,CHC,UD,5000);
         uimenu(sub,LB,'Inf',CB,CHC,UD,Inf);
         choice(sub,setting('make.lmax'));
   sub = uimenu(itm,LB,'Profiling',UD,'make.profile');
         uimenu(sub,LB,'off',CB,CHC,UD,'off');
         uimenu(sub,LB,'on',CB,CHC,UD,'on');
         choice(sub,setting('make.profile'));
   return
   
%==========================================================================      
   
function CbOpen(obj,cbo)
%    
% CBOPEN
%
   profiler([]);             % init profiler
   
   launch(obj);
   return

%==========================================================================      

function CbSaveas(obj,cbo)
%    
% CBSAVEAS
%
   busy;
   %saveas(obj);
   saveas(obj,obj);    % new syntax needs the object twice !!!
   ready;
   return

%==========================================================================      
   
function CbClone(obj,cbo)
%    
% CBCLONE
%
   if (setting('profile')) profiler([]); end    % auto reset
   profiler('clone',1);
   
   pos = get(gcf,'position');
   clone = get(obj,'clone');
   if (isempty(clone))
      clone = 'menu';    % use default if no clone function provided
   end
   cmd = [clone,'(obj);'];
   obj = option(obj,'position',[pos(1)+20,pos(2)-20,pos(3:4)]);
   eval(cmd);
   %set(gcf,'position',[pos(1)+20,pos(2)-20,pos(3:4)]);
   
   profiler('clone',0);
   return
      
%==========================================================================      

function CbClose(obj,cbo)
%
% CBCLOSE    Close current or all figures & then open GMA base
%
   %cbsetup;                    % reset to no-action
   settings = setting;          % retrieve current settings

   mode = get(cbo,'userdata');
   if (mode >= 1)               %  close all figs or exit
      siblings = get(0,'children');
      delete(siblings);         % close figs
   elseif (mode == -1)          % close current figure
      delete(gcf);              
   elseif (mode == 0)           % close other figures
      siblings = get(0,'children');
      idx = find(siblings ~= gcf);
      delete(siblings(idx));    % close all other figs
   end

   if (mode == 1 || mode == -1 || mode == -2)
      %launch = toolbox(obj,'launch');   % get launch base
      launch = toolbox(smart,'launch');  % get launch base
      if (~isempty(launch))
         eval(launch);
         settings.obj = chameo; % set generic object
         setting(settings);
      end
   end
   return

%==========================================================================      

function CbMake(obj,cbo)
%    
% CBMAKE
%
   profiler([]);             % init profiler
   onoff = option(obj,'make.profile');
   profiler(onoff);          % enable/disable profiler for make

   curdir = cd;              % save current directory
   
   directory = option(obj,'directory');
   if ~isempty(directory)
      cd(directory);
   end

   filename = setting('make.file');
   newfile = '';
   while isempty(newfile)
      [newfile, newpath, typevalue] = uigetfile('*.log', 'Open',filename);
   end

   if newfile % user not pressed cancel
      try
         cd(newpath);
         setting('directory',newpath);
         [path,file,ext] = fileparts(newfile);
         %verbose = option(obj,'make.verbose');
         %make(obj,'#GMA2',file,'',verbose);
         format = option(obj,'make.format');
         make(obj,format,file);
         setting('make.file',newfile);
      catch
      end
   end
   cd(curdir);
   return

%==========================================================================      

function CbSnif(obj,cbo)
%    
% CBSNIF   Snif into file and show snif results
%
   profiler([]);             % init profiler
   %onoff = option(obj,'make.profile');
   %profiler(onoff);          % enable/disable profiler for make

   curdir = cd;              % save current directory
   
   directory = option(obj,'directory');
   if ~isempty(directory)
      cd(directory);
   end

   filename = setting('make.file');
   newfile = '';
   while isempty(newfile)
      [newfile, newpath, typevalue] = uigetfile('*.log', 'Open',filename);
   end

   if newfile % user not pressed cancel
      try
         cd(newpath);
         setting('directory',newpath);
         [path,file,ext] = fileparts(newfile);
         %verbose = option(obj,'make.verbose');
         %make(obj,'#GMA2',file,'',verbose);
         busy
         [lines,format,cycles] = snif(obj,newfile);
         ready
         setting('make.file',newfile);
         if isempty(format)
            format = 'not specified';
         end
         info = {'',['File: ',newfile],'',...
            sprintf('       Lines: %g',lines),...
            sprintf('       Format: %s',format),...
            sprintf('       Production cycles: %g                ',cycles)};
         msgbox(info,'Sniffing');
      catch
      end
   end
   cd(curdir);
   return

%==========================================================================      

function CbEditTitle(obj,cbo)
%
% CBEDITTITLE    Edit Title
%
   title = get(obj,'title');
   sout = inputdlg({'Edit Title:'},'',1,{title});
   if ~isempty(sout)
      obj = set(obj,'title',sout{1});
      gcfo(obj);    % push object to figure
      set(gcf,'name',info(obj));    % display objects title in title bar
      CbDataInfo(obj,[]);
   end
   return
   
%==========================================================================      

function CbAddComment(obj,cbo)
%
% CBADDCOMMENT    Add Comment
%
   comment = get(obj,'comment');
   sout = inputdlg({'Add Comment:'},'',1,{''});
   if ~isempty(sout)
      comment{end+1} = sout{1};
      obj = set(obj,'comment',comment);
      gcfo(obj);    % push object to figure
      CbDataInfo(obj,[]);
   end
   return

%==========================================================================      

function CbClearComments(obj,cbo)
%
% CBCLEARCOMMENTs    Clear all comments
%
   button = questdlg('Do you want to clear all comments?',...
                     'Clear Comments', 'Yes','No','No');  
   if strcmp(button,'Yes')
      obj = set(obj,'comment',{});
      gcfo(obj);    % push object to figure
      CbDataInfo(obj,[]);
   end
   return

%==========================================================================
% Info Menu
%==========================================================================

function InfoMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('cbinvoke(gcfo)')];
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('cbinvoke(gcfo)')];

   men = mount(obj,mountpt,LB,'Info');
   itm = uimenu(men,LB,'Plot Info',CB,'plotinfo(gcfo)');
   itm = uimenu(men,LB,'Data Info',CB,call('CbDataInfo'));
   itm = uimenu(men,LB,'Parsing Info',CB,call('CbParsingInfo'));
      
   %itm = uimenu(men,LB,'General',CB,call('CbGeneral'));
   itm = uimenu(men,LB,'Comment',CB,call('CbComment'));
   itm = uimenu(men,LB,'Simulation List',CB,call('CbInfoSimuList'));
   %itm = uimenu(men,LB,'M-File',CB,call('CbMfile'),EN,iif(property(obj,'generic'),'off','on'));
   itm = uimenu(men,LB,'How To ...',CB,call('CbHowto'));
   return

%==========================================================================      
   
function CbDataInfo(obj,cbo)
%
% CBDATAINFO   Display object's info
%
   cbsetup(obj,cbo);             % reset to no-action
   clrscr off;                   % clear screen, axes off
   plotinfo(obj,[]);             % reset plot info
   
   %htxt = text(0.5,0.9,['<',subst(info(obj,1)),'>']);
   htxt = text(0.5,0.9,['<',subst(info(obj)),'>']);
   set(htxt,'fontsize',14,'horizontalalignment','center')
   comment = property(obj,'comment');
   cnt = 0;
   for (i=1:length(comment))
      cnt = cnt+1;
      txt = comment{i};
      htxt = text(0.5,0.85-cnt*0.05,subst(txt));
      set(htxt,'fontsize',8,'horizontalalignment','center')
   end

   cycles = get(obj,'cycles');
   if ~isempty(cycles)
      cnt = cnt+2;
      txt = sprintf('%g production cycle%s',cycles,iif(cycles>1,'s',''));
      htxt = text(0.5,0.85-cnt*0.05,subst(txt));
      set(htxt,'fontsize',8,'horizontalalignment','center')
   end
   return
   
%==========================================================================      

function CbParsingInfo(obj,cbo)
%
% CBPARSINGINFO   Display parsing info
%
   cbsetup(obj,cbo);                 % reset to no-action
   clrscr off;                   % clear screen, axes off
   plotinfo(obj,[]);             % reset plot info
   
   try
      htxt = text(0.5,0.9,'Parsing Information');
      set(htxt,'fontsize',14,'horizontalalignment','center')
      parsed = get(obj,'parsed');
      cycles = get(obj,'cycles');
      cver = eval('parsed.version.chameo','''???''');
      vver = eval('parsed.version.smart','''???''');
      list = {sprintf('Parsed at: %s / %s',parsed.date,parsed.time),...
              sprintf('Toolbox version: CHAMEO %s, SMART %s',cver,vver),...
              sprintf('Production cycles: %g',cycles)};

      records = get(obj,'parsed.records');
      if (records)
         list{end+1} = sprintf('Records: %g',records);
      end

      cnt = 0;
      for (i=1:length(list))
         cnt = cnt+1;
         txt = list{i};
         htxt = text(0.5,0.85-cnt*0.05,subst(txt));
         set(htxt,'fontsize',8,'horizontalalignment','center')
      end
   catch
   end
   
   return
   
%==========================================================================      
   
function CbProfile(obj,cbo)
%
% CBPROFILE   Display profiling info
%
   profiler;                     % print profiling info
   % msgbox(sprintf('View MATLAB shell to see profiling info!'));
   return
   
%==========================================================================      
   
function CbComment(obj,cbo)
%
% CBCOMMENT   Popup message box about object's comments
%
   comment = property(obj,'comment');
   if isempty(comment)
      msgbox('No extra comment supported!');
   else
      msgbox(comment);
   end
   return

%==========================================================================      
   
function CbInfoSimuList(obj,cbo)
%
% CBINFOSIMULIST   Popup message box about object's simulation list
%
   list = get(obj,'list');
   if isempty(list)
      msgbox('Empty simulation list!');
   else
      n = length(list);
      msgbox(sprintf('Simulation list: %g entries',n));
   end
   return

%==========================================================================      
   
function CbHowto(obj,cbo)
%
% CBHOWTO   Print message how to get a figure's object into MATLAB work space
%
   msgbox(['To get the data object into MATLAB work space put the',...
           'desired figure on top of all windows and invoke',...
           '"obj=gcfo" in the MATLAB command line!'],...
           'How to get object','help')
   return

   
%==========================================================================
% Submenu Demos
%==========================================================================

function PlayMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';
   CHK = 'check(gcbo);';  CHKR = [CHK,call('cbinvoke(gcfo)')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('cbinvoke(gcfo)')];

   colorlist = {'b','g','r','c','m','y','k'};
   
   default;                       % set common default settings
   default('bullets',0);
   default('color',colorlist);
   default('frequency',1);
   default('grid',0);

   men = mount(obj,mountpt,LB,'Play');

   itm = uimenu(men,LB,'Settings');
   sub = uimenu(itm,LB,'Bullets',CB,CHKR,UD,'bullets');
         check(sub,setting('bullets'));            % init bullets item
   sub = uimenu(itm,LB,'Plot Color',UD,'color');
         uimenu(sub,LB,'Red',CB,CHCR,UD,'r');
         uimenu(sub,LB,'Green',CB,CHCR,UD,'g');
         uimenu(sub,LB,'Blue',CB,CHCR,UD,'b');
         uimenu(sub,LB,'Auto',CB,CHCR,UD,colorlist);
            choice(sub,setting('color'));          % init 'color' item
   sub = uimenu(itm,LB,'Frequency',UD,'frequency');
         uimenu(sub,LB,'x 1.0',CB,CHCR,UD,1);
         uimenu(sub,LB,'x 1.1',CB,CHCR,UD,1.1);
         uimenu(sub,LB,'x 1.2',CB,CHCR,UD,1.2);
            choice(sub,setting('frequency'));      % init 'frequency' item
   sub = uimenu(itm,LB,'Grid',CB,CHKR,UD,'grid');
            check(sub,setting('grid'));            % init grid item
         uimenu(itm,LB,'Show Settings',CB,'setting');
   
   uimenu(men,LB,'---------------------------------------------');
   uimenu(men,LB,'SIN/COS Plot Demo => 1 axes',CB,call('CbSinCos'),UD,1);
   uimenu(men,LB,'SIN/COS Plot Demo => 2 axes',CB,call('CbSinCos'),UD,2);
   uimenu(men,LB,'---------------------------------------------');
   uimenu(men,LB,'Multi Plots => 1 axes',CB,call('CbMultiPlot'),UD,1);
   uimenu(men,LB,'Multi Plots => 2 axes',CB,call('CbMultiPlot'),UD,2);

   return

%==========================================================================
   
function CbSinCos(obj,cbo)
%
   kf = setting('frequency'); 
   t = 0:0.1:10; 
   xy = [sin(kf*2*pi/10*t); cos(kf*2*pi/10*t)];
   smo = smart({t,xy},obj);          % construct a data object from  t & x

   smo = option(smo,'xscale',1);     % overwrite x-scaling 
   smo = option(smo,'suffix',{});    % overwrite suffix settings 
   clrscr on;                        % clear screen (axes visible)
   switch get(cbo,'userdata');       % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         smo = set(smo,'title','Sinus/Cosinus Function'); 
         plot(smo);          
      case 2                         % plot to dual axes
         smo = set(smo,'title',{'Sinus Function','Cosinus Function'}); 
         smo = set(smo,'symbol',{'sin','cos'}); 
         plot(smo,[subplot(211),subplot(212)]);
   end
   cbsetup(obj,cbo); keypress('CbKeyPressPlay'); shg;
   return

%==========================================================================

function CbMultiPlot(obj,cbo)
%
   kf = setting('frequency'); 
   t = 0:0.1:10; 
   for (k=1:10)
       xy(:,k) = 1 + cos(kf*2*pi/10*k*t) / k;
   end
   tit = sprintf('f(t) = 1 + cos(kf*2*pi/10*k*t)/k  (kf = %3.1f)',kf);
   smo = smart({t,xy},obj);          % construct a data object from  t & x
   smo = set(smo,'title',tit);       % set title 

   smo = option(smo,'xscale',1);     % overwrite x-scaling 
   clrscr on;                        % clear screen (axes visible)
   switch get(cbo,'userdata');       % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         plot(smo);          
      case 2                         % plot to dual axes
         plot(smo,[subplot(211),subplot(212)]);
   end
   cbsetup(obj,cbo); keypress('CbKeyPressPlay'); shg;
   return

%==========================================================================      

function CbKeyPressPlay(obj,cbo)
%
   kf = setting('frequency') + 0.1;
   if (kf > 1.21) kf = 1; end
   setting('frequency',kf);          % refresh incremented frequency
   cbinvoke(obj);
   return
   
   
%==========================================================================      
% Auxillary Functions
%==========================================================================      
   
function aolaunch(list)  
%
% LAUNCH   Launch single addon or list of addon's
%
%             aolaunch('mytool');
%             aolaunch({'mytool','histool','hertool'});
%
   if (isempty(list))
      return                   % done!
   end
   
   if (~iscell(list))
      list = {list};           % for single addon make sure to have a list
   end
   
   for (i=1:length(list))
      func = list{i};
      if (~isstr(func))
         error('non-string found in Add-On list!');
      end
      try
         eval(func);
      catch
         lerr = lasterror;    
         error(['menu(): error occured on calling ''',func,...
           ''' during launchiing of Add-On list:\n',lerr.message,'\n']);
      end
   end
   return
   
%==========================================================================      

function idx = lookup(sym,symlist)
%
% LOOKUP   Lookup symbol in object's symbol list. Return index if found
%          and empty if not found.
%
%             idx = lookup(sym,symlist)
%
   for (i=1:length(symlist))
      if (strcmp(sym,symlist{i}))
         idx = i;                     % symbol found, return index
         return 
      end
   end
   
   idx = [];
   return                             % symbol not found
   
%==========================================================================      
   
function s = subst(s)  % substitute under score
   if ~isempty(s)
      idx = find(s=='_');
      if ~isempty(idx)
         s(idx) = (0*idx)+' ';
      end
   end
   return
   
%==========================================================================      

function keypressing(obj,cbo)
%
% KEYPRESSING  This function is for external calls in order to redirect
%              keypress callback to standard handler
%
%                 menu(gcfo,'keypressing')  % setup standard kpr. callback
%
   keypress;
   return
  
% eof