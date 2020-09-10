function menu(obj,varargin)
% 
% MENU   Open new figure and setup menu for a CORE object
%
%    1) Open a new figure with proper menu.
%
%       obj = core(typ)         % create a CORE object
%       menu(obj)               % open figure, setup a proper menu
%
%    The type of menu will depend on the type of the core object.
%
%       menu(core)              % open figure with File menu
%       menu(core('generic'))   % same as above
%       menu(core('tutorial'))  % open figure with TUTORIAL menu
%       menu(core('simple'))    % open figure with SIMPLE demo menu
%       menu(core('tools'))     % open figure with TOOLS menu
%
%    Remarks: if obj has an empty arg setting then a call menu(obj) will
%    translate to a call menu(obj,'Setup'), while the 'Setup' function
%    will take responsibility to handle the different object types and 
%    set up a menu bar properly according to the object type.
%
%       menu(obj,'Setup')       % same as menu(obj)
%
%
%    2) Functions for creating a figure with an empty roll down menu bar
%    and for adding standard roll down menus.
%
%       menu(obj,'Empty');      % setup an empty menu
%       menu(obj,'File');       % add a FILE rolldown menu
%       menu(obj,'XFile');      % add an extended FILE rolldown
%       menu(obj,'Plugin');     % add all plugin roll down menus
%       menu(obj,'Info');       % add an INFO roll down menu
%
%
%    3) Callback functions
%
%       menu(obj,'Open')        % Open menu of an object from file
%       menu(obj,'Save')        % Save object to file
%       menu(obj,'SaveAs')      % Save object to file (file dialog)
%       menu(obj,'Clone')       % clone figure with current display
%       menu(obj,'Rebuild')     % rebuild current menu structure
%       menu(obj,'Close')       % close current figure
%
%       menu(obj,'Home')        % show home screen
%       menu(obj,'Tutorial')    % launch tutorial
%
%    See also: CORE, CLS, GFO, GCBO, CHECK, CHOICE, TINY, SIMPLE, ADVANCED
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'Setup');

   if ~propagate(obj,func,which(func)) 
      eval(cmd);               % invoke callback
   end
   return
end

%==========================================================================
% User Defined Menu Setup
%==========================================================================
   
function Setup(obj)                    % Setup all standard menus
%
% SETUP    Setup menu
%
   profiler('setup',1);                % begin profiling menu setup

   typ = type(obj);
   switch typ
      case 'simple'
         simple(obj,'Setup');
      case {'generic','tutorial'}
         tutorial(obj,'Setup');
      otherwise
         Empty(obj);                   % open figure & setup an empty menu
         menu(obj,'File');
   end
   
%    AddonMenus(obj);                  % launch addon menus
   
   %if strcmp(get(obj,'class'),'core') % reinvoke only on top level
   if strcmp(class(obj),'core')        % reinvoke only on top level
      drawnow;
      refresh(obj);                    % by default display object's info
   end

   setting('shell.debug',1);           % enable debug mode per default
   profiler('setup',-1);               % end profiling menu setup
   return                     
end

%==========================================================================      
   
function Empty(obj)
%
% Empty    Open figure and setup an empty menu
%
   if (~isempty(get(gcf,'children')))
      position = option(obj,'shell.position');
      menubar = option(obj,'shell.menubar');
      hdl = figure('visible','off');               % open new figure     
      if ~menubar
         set(hdl,'menubar','none');                % no standard menubar
      end

      if ~isempty(position)
         set(hdl,'position',position);      
      end
      %set(hdl,'visible','on');
   end

   
      % first we retrieve options from object and add these as settings.
      % Don't forget to push object itself into settings later on!.
   
   settings = option(obj);       % retrieve settings if provided by object
   
      % if no special callback provided by object's options
      % then we rewrite the callback settings by a call to DataInfo
      
   if (isempty(option(obj,'shell.callback')))
       %settings.shell.callback = 'menu(gfo,''DataInfo'');';
       settings.shell.callback = 'menu(gfo,''Home'');';
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
   
   txt = either(get(obj,'title'),info(obj));
   set(gcf,'name',txt);          % display objects title in title bar
   set(gcf,'numbertitle','off');

      % we need to setup some defaults
      
   default('shell.debug',0);         % no debug mode
   default('shell.launch','menu');   % default menu callback handling fct.
   default('shell.menubar',0);       % standard menus off
   default('shell.callback','');     % by default empty click action
   default('shell.callargs','');     % by default empty click action
   default('shell.click','');        % by default empty click action
   
   if (~setting('shell.menubar'))
      set(gcf,'menubar','none');     % no standard menubar
   end
   set(gcf,'visible','on');          % now show everything
   return
end

%==========================================================================      
% Addon Menus
%==========================================================================      

function AddonMenus(obj)
%
      % first of all we see if there are object specific addon's
      % defined. If yes we have to launch these addon's
   %return % so far      
   %obj = either(arg(obj,1),obj);   % refer to parent object, if provided
   %list = get(obj,'addon');        % get object specific addon list
   %aolaunch(obj,list);
   
      % next we have to launch the CHAMEO toolbox specific addon's.
         
   %list = toolbox(obj,'addon');    % get current addon list
   list = toolbox(core,'addon');    % get current addon list
   aolaunch(obj,list);
   return
end

%==========================================================================      
%##########################################################################
% Setup File Rolldown Menu
%##########################################################################
%==========================================================================      

function File(obj)
%
% FILE   Add FILE rolldown menu
%
   SetupFileMenu(obj,0);
   return
end

function XFile(obj)
%
% X-FILE   Add extended FILE rolldown menu
%
   SetupFileMenu(obj,1);
   return
end

function SetupFileMenu(obj,extended)
%
% SETUP-FILE-MENU
%
   default('shell.filename','');      % common file name for FILE operations
   default('shell.directory','');     % common directory name for FILE operations
   
   ob1 = mitem(obj,'File');           % rolldown menu header
   ob2 = mitem(ob1,'Open ...',call,'Open');
   
   cl = class(obj);
   if (~strcmp(cl,'core'))
      ob2 = mitem(ob1,'Import ...',call,'Import');
   end
   ob2 = mitem(ob1,'Save',call,'Save');
   ob2 = mitem(ob1,'Save As ...',call,'SaveAs');
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Clone',call,'Clone');
   ob2 = mitem(ob1,'Rebuild',call,'Rebuild');

%    launch = toolbox(core,'launch');   % get launch base
%    if (~isempty(launch))
%       ob2 = mitem(ob1,'Launch Base',call,{'CbClose',-2});
%    end

   if (extended)         
      ob2 = mitem(ob1,LB,'Make');
      ToolsMenu(ob2,itm);
   end
   
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Close Other',call,{'Close',0});
   %ob2 = mitem(ob1,'Close All',call,{'Close',1});
   ob2 = mitem(ob1,'Close',call,{'Close',-1});
   
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Exit',call,{'Close',2});
   return
end

%==========================================================================      
   
function ToolsMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')]; 
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')];

   default('shell.filename','');    % common file name for FILE operations
   default('shell.directory','');   % common directory name for FILE operations

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
end

%==========================================================================      
% Open Object from .MAT File
%==========================================================================      
   
function Open(obj)
%    
% OPEN   Open object from .MAT file (load & launch)
%
   profiler([]);             % init profiler
   
   obj = translate(obj,'shell');
   obj = open(obj,'');
   
      % now update settings for shell.directory and shell.filename

   if ~isempty(obj)
      setting('shell.directory',option(obj,'directory'));
      setting('shell.filename',option(obj,'filename'));
   end
   return
end

%==========================================================================      
% Save Object
%==========================================================================      

function Save(obj)
%    
% SAVE   Save object - filepath based on shell settings
%
   obj = translate(obj,'shell');
   obj = save(obj);                   % file path based on shell settings

      % now update settings for shell.directory and shell.filename
      
   if ~isempty(obj)
      setting('shell.directory',option(obj,'directory'));
      setting('shell.filename',option(obj,'filename'));
   end
   return
end

%==========================================================================      
% Save Object As
%==========================================================================      

function SaveAs(obj)
%    
% SAVE-AS   Save object as user defined file name (open file dialog)
%
   obj = translate(obj,'shell');
   obj = save(obj,'');    % force to open file dialog

      % now update settings for shell.directory and shell.filename
      
   if ~isempty(obj)
      setting('shell.directory',option(obj,'directory'));
      setting('shell.filename',option(obj,'filename'));
   end
   return
end

%==========================================================================      
% Clone
%==========================================================================      
   
function Clone(obj)
%    
% CLONE
%
   %if (setting('profile')) profiler([]); end    % auto reset
   %profiler('clone',1);
   
   obj = gfo;          % refetch object, since obj can be derived from shell

   pos = get(gcf,'position');
   obj = option(obj,'shell.position',[pos(1)+20,pos(2)-20,pos(3:4)]);

   obj = arg(obj,{});  % clear arg list
   launch(obj);
   
   %profiler('clone',0);
   return
end

%==========================================================================      
% Rebuild
%==========================================================================      
   
function Rebuild(obj)
%    
% REBUILD    Same function as 'Clone' but new window has the same position
%            as existing, and existing window to be closed
%
   if (setting('profile')) profiler([]); end    % auto reset
   profiler('Rebuild',1);
   
   fig = gcf;           % get existing (current) figure
   obj = gfo;           % refetch object, since obj can be derived from shell

   pos = get(gcf,'position');
   obj = option(obj,'shell.position',[pos(1),pos(2),pos(3:4)]);

   launch(arg(obj,{}));
   delete(fig);         % close existing figure
   
   profiler('Rebuild',0);
   return
end

%==========================================================================      
% Close
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
end

%==========================================================================      
%##########################################################################
% Setup Info Rolldown Menu
%##########################################################################
%==========================================================================      

function Info(obj)
%
% INFO   Setup INFO menu
%
   default('profiler',0);
   default('shell.debug',0);
   
   ob1 = mitem(obj,'Info');
   ob2 = mitem(ob1,'Home Screen',call('Home'));

   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Properties');
         mitem(ob2,'Edit Title ...',call,'EditTitle');
         mitem(ob2,'Add Comment ...',call,'AddComment');
         mitem(ob2,'Clear Comments ...',call,'ClearComments');
   
   ob2 = mitem(ob1,'Profiler');
   ob3 = mitem(ob2,'Profiling','','profiler');
         choice(ob3,{{'Off',0},{'On',1}});
   ob3 = mitem(ob2,'Results',call('Profiling'));

   ob2 = mitem(ob1,'Debug','','shell.debug');
         choice(ob2,{{'Off',0},{'On',1}});
   
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Tutorial',call('Tutorial'));
   return
end

%==========================================================================      
% Home Callback (Show Data Info)
%==========================================================================      
   
function Home(obj)
%
% HOME   Home function - display object info
%
   ObjectInfo(obj);
   refresh(obj,inf);             % use this function for refresh
   return
end

function ObjectInfo(obj)
%
% OBJECT-INFO   Display object's info
%
   refresh(obj,inf);             % use this function for refresh
   cls off;                      % clear screen, axes off
   plotinfo(obj,[]);             % reset plot info
   
   txt = either(get(obj,'title'),info(obj));
   htxt = text(0.5,0.9,underscore(obj,txt));
   set(htxt,'fontsize',14,'horizontalalignment','center')
   comment = get(obj,'comment');
   
   if ~isa(comment,'cell')
      comment = {comment};
   end
   
   cnt = 0;
   for (i=1:length(comment))
      cnt = cnt+1;
      txt = either(comment{i},'');
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
end


function EditTitle(obj)
%
% EDIT-TITLE    Edit Title
%
   title = get(obj,'title');
   sout = inputdlg({'Edit Title:'},'',1,{title});
   if ~isempty(sout)
      obj = gfo;                   % pull (inherited) object from figure
      obj = set(obj,'title',sout{1});
      gfo(obj);    % push object to figure
      set(gcf,'name',info(obj));    % display objects title in title bar
      ObjectInfo(obj);
   end
   return
end

function Tutorial(obj)
%
% TUTORIAL   Launch CORE tutorial
%
   tutorial(core);
   return
end

%==========================================================================      

function AddComment(obj)
%
% ADD-COMMENT    Add Comment
%
   comment = get(obj,'comment');
   sout = inputdlg({'Add Comment:'},'',1,{''});
   if ~isempty(sout)
      obj = gfo;                   % pull (inherited) object from figure
      comment{end+1} = sout{1};
      obj = set(obj,'comment',comment);
      gfo(obj);    % push object to figure
      ObjectInfo(obj);
   end
   return
end

%==========================================================================      

function ClearComments(obj)
%
% CLEAR-COMMENTS    Clear all comments
%
   button = questdlg('Do you want to clear all comments?',...
                     'Clear Comments', 'Yes','No','No');  
   if strcmp(button,'Yes')
      obj = gfo;                   % pull (inherited) object from figure
      obj = set(obj,'comment',{});
      gfo(obj);    % push object to figure
      ObjectInfo(obj);
   end
   return
end

%==========================================================================      
   
function Profiling(obj)
%
% PROFILING   Display profiling info
%
   profiler;                     % print profiling info
   % msgbox(sprintf('View MATLAB shell to see profiling info!'));
   return
end

%==========================================================================      
   
function Comment(obj)
%
% COMMENT   Popup message box about object's comments
%
   comment = property(obj,'comment');
   if isempty(comment)
      msgbox('No extra comment supported!');
   else
      msgbox(comment);
   end
   return
end

%==========================================================================      
%##########################################################################
% OTHER STUFF
%##########################################################################
%==========================================================================      


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
   itm = uimenu(men,LB,'Data Info',CB,call('DataInfo'));
   itm = uimenu(men,LB,'Parsing Info',CB,call('CbParsingInfo'));
      
   %itm = uimenu(men,LB,'General',CB,call('CbGeneral'));
   itm = uimenu(men,LB,'Comment',CB,call('CbComment'));
   itm = uimenu(men,LB,'Simulation List',CB,call('CbInfoSimuList'));
   %itm = uimenu(men,LB,'M-File',CB,call('CbMfile'),EN,iif(property(obj,'generic'),'off','on'));
   itm = uimenu(men,LB,'How To ...',CB,call('CbHowto'));
   return
end


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
end

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
end
   
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
end

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
end

%==========================================================================      
   
function s = subst(s)  % substitute under score
   if ~isempty(s)
      idx = find(s=='_');
      if ~isempty(idx)
         s(idx) = (0*idx)+' ';
      end
   end
   return
end  

