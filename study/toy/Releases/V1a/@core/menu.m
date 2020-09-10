function menu(obj,varargin)
% 
% MENU   Open new figure and setup menu for a CORE object
%      
%           obj = core(typ)                % create a CORE object
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
%        Called with 1 argument menu setup depends on the type of the
%        CORE object:
%
%           menu(core)                    % setup basic menu
%           menu(core('generic'));        % setup basic menu
%        
%        Internally the menu method is also used to dispatch callback
%        functions:
%
%           menu(obj,'Open')              % call 'Open' callback
%
%        See also: CORE CLS GFO GCBO CHECK CHOICE MOUNT
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'Setup');

   if ~propagate(obj,func,which(func)) 
      eval(cmd);               % invoke callback
   end
   return

%==========================================================================
% User Defined Menu Setup
%==========================================================================
   
function Setup(obj)             % Setup all standard menus
%
% SETUP    Setup menu
%
   profiler('setup',1);                % begin profiling menu setup
   inifig(obj);                        % initialize figure & set defaults
   
   rolldowns(obj);                     % setup roll down menus
   AddonMenus(obj);                    % launch addon menus
   
   if strcmp(get(obj,'class'),'shell') % reinvoke only on top level
      drawnow;
      refresh(obj);                    % by default display object's info
   end

   setting('shell.debug',1);           % enable debug mode per default
   profiler('setup',-1);               % end profiling menu setup
   return                     


%==========================================================================      

function rolldowns(obj)   % setup roll down menus
%
% ROLLDOWNS
%
      % Setup menu structure by providing mount points
   
   mountpoints = {'<file>','<xfile>',...
      '<tools>','<tools>','<tools>','<tools>','<tools>',...
      '<tools>','<tools>','<tools>','<tools>','<tools>',...
      '<view>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<main>','<main>','<main>','<main>','<main>',...
      '<window>','<play>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<addon>','<addon>','<addon>','<addon>','<addon>',...
      '<test>','<info>','<help>'};      

   for (i=1:length(mountpoints))
      uimenu(gcf,'label',mountpoints{i},'visible','off');
   end
   
      % Now create shell menus as being advised
      
   menulist = get(obj,'menu');
   
   for (i=1:length(menulist))
      key = menulist{i};
      key = iif(iscell(key),'*',key);
      switch key
         case 'file'
            FileMenu(obj,'<file>');    % setup FILE menu
         case 'xfile'
            XFileMenu(obj,'<file>');  % setup extended FILE menu
         case 'tools'
            ToolsMenu(obj,'<tools>');  % setup TOOLS menu
         case 'test'
            TestMenu(obj,'<test>');    % setup PLAY menu
         case 'play'
            PlayMenu(obj,'<main>');    % setup PLAY menu
         case 'info'
            InfoMenu(obj,'<info>');    % setup SIMULATION menu
      end
   end
   return

%==========================================================================      
   
function inifig(obj)
%
% INIFIG    Initialize figure to comply with CHAMEO menu support
%
   if (~isempty(get(gcf,'children')))
      position = option(obj,'shell.position');
      menubar = option(obj,'shell.menubar');
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
      
   if (isempty(option(obj,'shell.callback')))
       %settings.shell.callback = 'menu(gfo,''CbDataInfo'');';
       settings.shell.callback = 'menu(arg(gfo,''CbDataInfo''));';
       settings.shell.callargs = {};
   end

   setting(settings);            % use these settings from now globally
   if setting('shell.ohdl')
      fprintf('*** warning: expected empty OHDL during menu:inifig()\n');
      setting('ohdl',[]);
   end
   gfo(obj);                     % don't forget to push object into figure
   
   cls off;                      % clear screen, axes off
   bright;                       % switch to bright mode
   
   set(gcf,'name',info(obj));    % display objects title in title bar
   set(gcf,'numbertitle','off');

      % we need to setup some defaults
      
   default('shell.debug',0);         % no debug mode
   default('shell.handle','menu');   % default menu callback handling fct.
   default('shell.menubar',0);       % standard menus off
   default('shell.keypress','');     % by default empty keypress action
   
   if (~setting('shell.menubar'))
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
   %return % so far      
   %obj = either(arg(obj,1),obj);      % refer to parent object, if provided
   %list = get(obj,'addon');         % get object specific addon list
   %aolaunch(obj,list);
   
      % next we have to launch the CHAMEO toolbox specific addon's.
         
   %list = toolbox(obj,'addon');    % get current addon list
   list = toolbox(core,'addon');    % get current addon list
   aolaunch(obj,list);
   return
   
%==========================================================================      
% File Menu
%==========================================================================      

function XFileMenu(obj,mountpt,extended)   % Extended File Menu
   FileMenu(obj,mountpt,1)
   return

function FileMenu(obj,mountpt,extended)
%
%    LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
%    CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')]; 
%    CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF,AC] = shortcuts(core);
 
   if (nargin < 3) extended = 0; end
   
   default('shell.filename','');      % common file name for FILE operations
   default('shell.directory','');     % common directory name for FILE operations
   
   men = mount(obj,mountpt,LB,'File');
 
   itm = uimenu(men,LB,'Open ...',CB,call('CbOpen'));
   cl = get(obj,'class');
   if (~strcmp(cl,'shell'))
      itm = uimenu(men,LB,'Import ...',CB,call('CbImport'));
   end
   itm = uimenu(men,LB,'Save As ...',CB,call('CbSaveas'));
   itm = uimenu(men,LB,'Clone',CB,call('CbClone'));
   itm = uimenu(men,LB,'Rebuild',CB,call('CbReload'));
   launch = toolbox(core,'launch');   % get launch base
   if (~isempty(launch))
      itm = uimenu(men,LB,'Launch Base',CB,call('CbClose'),UD,-2);
   end

   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Properties');
         uimenu(itm,LB,'Edit Title ...',CB,call('CbEditTitle'));
         uimenu(itm,LB,'Add Comment ...',CB,call('CbAddComment'));
         uimenu(itm,LB,'Clear Comments ...',CB,call('CbClearComments'));
         
   if (extended)         
      itm = uimenu(men,LB,'Make');
      ToolsMenu(obj,itm);
   end
   
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Close Other',CB,call('Close'),UD,0);
   itm = uimenu(men,LB,'Close All',CB,call('Close'),UD,1);
   itm = uimenu(men,LB,'Close',CB,call('Close'),UD,-1);
   
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Exit',CB,call('Close'),UD,2);
   return

%==========================================================================      
   
function ToolsMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   default('shell.filename','');      % common file name for FILE operations
   default('shell.directory','');     % common directory name for FILE operations

   default('make.verbose',1);       % verbose mode for make & compile
   default('make.nanmode',1);       % NaN mode for make & compile
   default('make.tslice',5);        % time slice [s]
   default('make.lmax',2000);       % max. parser list length to save
   default('make.format','#CHM1');  % default format for MAKE utility
   default('make.cycles',inf);      % number of production cycles to parse
   default('make.terminate',1);     % terminate after last ProdCycleEnd 
   default('make.profile','off');   % profiler off for make

   default('profile',1);            % reset profiling before each menu call
   
   %men = uimenu(gcf,LB,'Tools',UD,2);
   men = mount(obj,mountpt,LB,'Tools');
   
   itm = uimenu(men,LB,'Snif ...',CB,call('CbSnif'));
         uimenu(men,LB,'Make ...',CB,call('CbMake'));
         uimenu(men,LB,'------------------');
   itm = uimenu(men,LB,'Verbose',UD,'make.verbose');
         uimenu(itm,LB,'off',CB,CHC,UD,0);
         uimenu(itm,LB,'1',CB,CHC,UD,1);
         uimenu(itm,LB,'2',CB,CHC,UD,2);
         uimenu(itm,LB,'3',CB,CHC,UD,3);
         choice(itm,setting('make.verbose'));
   itm = uimenu(men,LB,'Format',UD,'make.format');
         uimenu(itm,LB,'#CHM1',CB,CHC,UD,'#CHM1');
         uimenu(itm,LB,'------------------');
         uimenu(itm,LB,'#GMA1',CB,CHC,UD,'#GMA1');
         uimenu(itm,LB,'#GMA2',CB,CHC,UD,'#GMA2');
         choice(itm,setting('make.format'));
   itm = uimenu(men,LB,'Max. Product Cycles',UD,'make.cycles');
         uimenu(itm,LB,'Infinite',CB,CHC,UD,inf);
         uimenu(itm,LB,'2',CB,CHC,UD,2);
         uimenu(itm,LB,'5',CB,CHC,UD,5);
         uimenu(itm,LB,'10',CB,CHC,UD,10);
         uimenu(itm,LB,'20',CB,CHC,UD,20);
         uimenu(itm,LB,'50',CB,CHC,UD,50);
         uimenu(itm,LB,'100',CB,CHC,UD,100);
         uimenu(itm,LB,'200',CB,CHC,UD,200);
         uimenu(itm,LB,'500',CB,CHC,UD,500);
         uimenu(itm,LB,'1000',CB,CHC,UD,1000);
         choice(itm,setting('make.cycles'));
   itm = uimenu(men,LB,'Terminate after last ProdCycle',UD,'make.terminate');
         uimenu(itm,LB,'Off',CB,CHC,UD,0);
         uimenu(itm,LB,'On',CB,CHC,UD,1);
         choice(itm,setting('make.terminate'));
   itm = uimenu(men,LB,'Max. Length Parser List',UD,'make.lmax');
         uimenu(itm,LB,'off',CB,CHC,UD,0);
         uimenu(itm,LB,'1000',CB,CHC,UD,1000);
         uimenu(itm,LB,'2000',CB,CHC,UD,2000);
         uimenu(itm,LB,'5000',CB,CHC,UD,5000);
         uimenu(itm,LB,'Inf',CB,CHC,UD,Inf);
         choice(itm,setting('make.lmax'));

      % profiler
      
   itm = uimenu(men,LB,'------------------');
   itm = uimenu(men,LB,'Profiler');
         uimenu(itm,LB,'Profiling Info',CB,call('CbProfile'));
         uimenu(itm,LB,'------------------');
         uimenu(itm,LB,'Reset Profiler',CB,'profiler([]);');
   sub = uimenu(itm,LB,'Auto Reset',CB,CHK,UD,'profile');
         check(sub,setting('profile'));
         uimenu(itm,LB,'------------------');
   sub = uimenu(itm,LB,'Profiling for Make',UD,'make.profile');
         uimenu(sub,LB,'off',CB,CHC,UD,'off');
         uimenu(sub,LB,'on',CB,CHC,UD,'on');
         choice(sub,setting('make.profile'));

   itm = uimenu(men,LB,'Debug',UD,'shell.debug');
         uimenu(itm,LB,'off',CB,CHC,UD,0);
         uimenu(itm,LB,'on',CB,CHC,UD,1);
         choice(itm,setting('shell.debug'));
   
   itm = uimenu(men,LB,'Release Notes');
         uimenu(itm,LB,'Read',CB,'version(chameleon)');
         uimenu(itm,LB,'Edit',CB,'edit chameleon/version');
            
   return
   
%==========================================================================      
   
function CbOpen(obj)
%    
% CBOPEN
%
   profiler([]);             % init profiler
   
   launch(obj);
   return

%==========================================================================      
   
function CbImport(obj)
%    
% CBIMPORT
%
   msgbox('Import is not implemented for SHELL objects!');
   return

%==========================================================================      

function CbSaveas(obj)
%    
% CBSAVEAS
%
   busy;
   %saveas(obj);
   saveas(gfo,gfo);    % new syntax needs derived object as arg2 !!!
   ready;
   return

%==========================================================================      
   
function CbClone(obj)
%    
% CBCLONE
%
   if (setting('profile')) profiler([]); end    % auto reset
   profiler('clone',1);
   
   obj = gfo;          % refetch object, since obj can be derived from shell

   pos = get(gcf,'position');
   obj = option(obj,'shell.position',[pos(1)+20,pos(2)-20,pos(3:4)]);

   handle(obj);
   
   profiler('clone',0);
   return
      
%==========================================================================      
   
function CbReload(obj)
%    
% CBRELOAD   Same function as 'Clone' but new window has the same position
%            as existing, and existing window to be closed
%
   if (setting('profile')) profiler([]); end    % auto reset
   profiler('reload',1);
   
   fig = gcf;           % get existing (current) figure
   obj = gfo;          % refetch object, since obj can be derived from shell

   pos = get(gcf,'position');
   obj = option(obj,'shell.position',[pos(1),pos(2),pos(3:4)]);

   handle(obj);
   delete(fig);         % close existing figure
   
   profiler('reload',0);
   return
      
%==========================================================================      

function Close(obj)
%
% CLOSE   Close current or all figures & then open GMA base
%
   %cbsetup;                    % reset to no-action
   settings = setting;          % retrieve current settings

   mode = arg(obj,1);
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
      launch = toolbox(core,'launch');  % get launch base
      if (~isempty(launch))
         eval(launch);
         %settings.obj = chameo; % set generic object
         %setting(settings);
      end
   end
   return

%==========================================================================      

function CbMake(obj)
%    
% CBMAKE
%
   profiler([]);             % init profiler
   obj = gfo;               % fetch derived object from figure
   
   onoff = option(obj,'make.profile');
   profiler(onoff);          % enable/disable profiler for make

   curdir = cd;              % save current directory
   
   directory = option(obj,'shell.directory');
   if ~isempty(directory)
      cd(directory);
   end

   filename = setting('make.file');
   newfile = '';
   while isempty(newfile)
      [newfile, newpath, typevalue] = uigetfile('*.log', 'Open',filename);
   end

   if newfile % user not pressed cancel
      if option(obj,'shell.debug')
         domake(obj,newpath,newfile);   % without exception handler
      else
         try
            domake(obj,newpath,newfile) % inside exception handler
         catch
            msgbox('Exception catched during make!');
         end
      end
   end
   cd(curdir);
   return

function domake(obj,newpath,newfile)
%
% DOMAKE   Do actual makeing
%
   cd(newpath);
   setting('shell.directory',newpath);
   [path,file,ext] = fileparts(newfile);
   format = option(obj,'make.format');
   make(obj,format,file);
   setting('make.file',newfile);
   return
   
%==========================================================================      

function CbSnif(obj)
%    
% CBSNIF   Snif into file and show snif results
%
   profiler([]);             % init profiler
   %onoff = option(obj,'make.profile');
   %profiler(onoff);          % enable/disable profiler for make

   obj = gfo;               % fetch derived object
   
   curdir = cd;              % save current directory
   
   directory = option(obj,'shell.directory');
   if ~isempty(directory)
      cd(directory);
   end

   filename = setting('make.file');
   newfile = '';
   while isempty(newfile)
      [newfile, newpath, typevalue] = uigetfile('*.log', 'Open',filename);
   end

   if newfile % user not pressed cancel
      if option(obj,'shell.debug')
         dosnif(obj,newpath,newfile);    % snif without exception handler
      else
         try
            dosnif(obj,newpath,newfile); % snif without exception handler
         catch
         end
      end
   end
   cd(curdir);
   return

function dosnif(obj,newpath,newfile)
%
% DOSNIF   Do actual sniffing
%
   cd(newpath);
   setting('shell.directory',newpath);
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
      iif(cycles == 0,'',...
         sprintf('       Production cycles: %g                ',cycles))};
   msgbox(info,'Sniffing');
return

%==========================================================================      

function CbEditTitle(obj)
%
% CBEDITTITLE    Edit Title
%
   title = get(obj,'title');
   sout = inputdlg({'Edit Title:'},'',1,{title});
   if ~isempty(sout)
      obj = gfo;                   % pull (inherited) object from figure
      obj = set(obj,'title',sout{1});
      gfo(obj);    % push object to figure
      set(gcf,'name',info(obj));    % display objects title in title bar
      CbDataInfo(obj);
   end
   return
   
%==========================================================================      

function CbAddComment(obj)
%
% CBADDCOMMENT    Add Comment
%
   comment = get(obj,'comment');
   sout = inputdlg({'Add Comment:'},'',1,{''});
   if ~isempty(sout)
      obj = gfo;                   % pull (inherited) object from figure
      comment{end+1} = sout{1};
      obj = set(obj,'comment',comment);
      gfo(obj);    % push object to figure
      CbDataInfo(obj);
   end
   return

%==========================================================================      

function CbClearComments(obj)
%
% CBCLEARCOMMENTs    Clear all comments
%
   button = questdlg('Do you want to clear all comments?',...
                     'Clear Comments', 'Yes','No','No');  
   if strcmp(button,'Yes')
      obj = gfo;                   % pull (inherited) object from figure
      obj = set(obj,'comment',{});
      gfo(obj);    % push object to figure
      CbDataInfo(obj);
   end
   return

%==========================================================================
% Submenu Test
%==========================================================================

function TestMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   colorlist = {'b','g','r','c','m','y','k'};
   
   default;                       % set common default settings
   default('bullets',0);
   default('color',colorlist);
   default('frequency',1);
   default('grid',0);

   men = mount(obj,mountpt,LB,'Test');

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
   
function CbSinCos(obj)
%
   kf = setting('frequency'); 
   t = 0:0.1:10; 
   xy = [sin(kf*2*pi/10*t); cos(kf*2*pi/10*t)];
   smo = smart({t,xy},obj);          % construct a data object from  t & x

   smo = option(smo,'xscale',1);     % overwrite x-scaling 
   smo = option(smo,'suffix',{});    % overwrite suffix settings 
   cls on;                           % clear screen (axes visible)
   switch arg(obj,1);               % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         smo = set(smo,'title','Sinus/Cosinus Function'); 
         plot(smo);          
      case 2                         % plot to dual axes
         smo = set(smo,'title',{'Sinus Function','Cosinus Function'}); 
         smo = set(smo,'symbol',{'sin','cos'}); 
         plot(smo,[subplot(211),subplot(212)]);
   end
   cbsetup(obj);  keypress(obj,'CbKeyPressPlay'); shg;
   return

%==========================================================================

function CbMultiPlot(obj)
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
   cls on;                           % clear screen (axes visible)
   switch arg(obj,1)                % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         plot(smo);          
      case 2                         % plot to dual axes
         plot(smo,[subplot(211),subplot(212)]);
   end
   cbsetup(obj);  keypress(obj,'CbKeyPressPlay'); shg;
   return

%==========================================================================      

function CbKeyPressPlay(obj)
%
   kf = setting('frequency') + 0.1;
   if (kf > 1.21) kf = 1; end
   setting('frequency',kf);          % refresh incremented frequency
   refresh(obj);
   return

%==========================================================================
% Submenu Play
%==========================================================================

function PlayMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   men = mount(obj,mountpt,LB,'Play');
   return
   
   men = mount(obj,mountpt,LB,'File');
   
   itm = uimenu(men,LB,'Open ...',CB,call('CbOpen'));
   itm = uimenu(men,LB,'Save As ...',CB,call('CbSaveas'));
   itm = uimenu(men,LB,'Clone',CB,call('CbClone'));
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Close Other',CB,call('CbClose'),UD,0);
   itm = uimenu(men,LB,'Close All',CB,call('CbClose'),UD,1);
   itm = uimenu(men,LB,'Close',CB,call('CbClose'),UD,-1);
   itm = uimenu(men,LB,'-------------');
   itm = uimenu(men,LB,'Exit',CB,call('CbClose'),UD,2);
   
   return

%==========================================================================
% Info Menu
%==========================================================================

function InfoMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   men = mount(obj,mountpt,LB,'Info');
   itm = uimenu(men,LB,'Plot Info',CB,'plotinfo(gfo)');
   itm = uimenu(men,LB,'Data Info',CB,call('CbDataInfo'));
   itm = uimenu(men,LB,'Parsing Info',CB,call('CbParsingInfo'));
      
   %itm = uimenu(men,LB,'General',CB,call('CbGeneral'));
   itm = uimenu(men,LB,'Comment',CB,call('CbComment'));
   itm = uimenu(men,LB,'Simulation List',CB,call('CbInfoSimuList'));
   %itm = uimenu(men,LB,'M-File',CB,call('CbMfile'),EN,iif(property(obj,'generic'),'off','on'));
   itm = uimenu(men,LB,'How To ...',CB,call('CbHowto'));
   return

%==========================================================================      
   
function CbDataInfo(obj)
%
% CBDATAINFO   Display object's info
%
   %obj = gfo;                    % fetch derived object from figure
   
   cbsetup(obj);                 % reset to no-action
   cls off;                      % clear screen, axes off
   plotinfo(obj,[]);             % reset plot info
   
   %htxt = text(0.5,0.9,['<',subst(info(obj,1)),'>']);
   %htxt = text(0.5,0.9,['<',subst(info(obj)),'>']);
   

   %iob = kid(obj,10);   
   htxt = text(0.5,0.9,[subst(info(obj))]);
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

function CbParsingInfo(obj)
%
% CBPARSINGINFO   Display parsing info
%
   cbsetup(obj);                 % reset to no-action
   cls off;                      % clear screen, axes off
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
   
function CbProfile(obj)
%
% CBPROFILE   Display profiling info
%
   profiler;                     % print profiling info
   % msgbox(sprintf('View MATLAB shell to see profiling info!'));
   return
   
%==========================================================================      
   
function CbComment(obj)
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
   
function CbInfoSimuList(obj)
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
   
function CbHowto(obj)
%
% CBHOWTO   Print message how to get a figure's object into MATLAB work space
%
   msgbox(['To get the data object into MATLAB work space put the',...
           'desired figure on top of all windows and invoke',...
           '"obj=gfo" in the MATLAB command line!'],...
           'How to get object','help')
   return

   
%==========================================================================      
% Auxillary Functions
%==========================================================================      
   
function aolaunch(obj,list)  
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
      
      cmd = [func,'(obj);'];
      
      if option(obj,'shell.debug');
         eval(cmd);
      else         
         try
            eval(cmd);
         catch
            lerr = lasterror;    
            error(['menu(): error occured on calling ''',func,...
              ''' during launching of Add-On list:\n',lerr.message,'\n']);
         end
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
  
% eof