function menu(obj,func)
% 
% MENU   Menu for transfer function objects (TFF)
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             menu(tff)           % open menu and add demo menus
%             menu(tff,'setup')   % add demo menus to existing menu
%             menu(tff,func)      % handle callbacks
%             menu(tff,'')        % empty action - existency check
%
%        Mount a rolldown menu
%
%             menu(arg(tff,mountpt),'rolldown');
%
%             obj = gfo;          % retrieve obj from menu's user data
%
%        See also   TFF SHELL MENU GFO
%
   if (nargin <= 1)                    % dispatch: setup or callback?
      setup(obj);                      % open figure & setup menu items 
   elseif ~propagate(obj,func,which(func)) 
      eval([func,'(obj);']);           % invoke callback
   end

   return
      

%==========================================================================
% User Defined Menu Setup
%==========================================================================

function obj = addinfo(obj)              % only called for stand-alone menu
%
% ADDINFO   Add object info before creating menu
%
   if (isempty(get(obj,'title')))
      obj = set(obj,'title','Transfer Function Shell');
      obj = set(obj,'comment',{'Investigate a transfer function'});
   end
   return

function inifig(obj)
%
% INIFIG    Initialize figure to comply with STREAMS menu support
%
   parent = obj.shell;           % get parent class object
   if isempty(arg(parent))
      parent = arg(parent,obj);  % pass derived object as arg!
   end
   menu(parent,'setup');         % call menu setup of parent class object 
   gfo(obj);                     % don't forget to push object into figure
   set(gcf,'name',info(obj));    % display objects title in title bar
   return

   
%==========================================================================

function setup(obj)  % hook in user defined menu items
%
% SETUP    Create a TCON object, add object's info and setup menu
%
   obj = addinfo(obj);
   inifig(obj);                 % open menu

   MenuSetupView(obj);
   MenuSetupBode(obj);
   MenuSetupRloc(obj);

   cls;
   refresh(obj);
   return

%==========================================================================
   
function rolldown(obj)
%
% ROLLDOWN      Mount a rolldown menu to a mount point 
%
%                  menu(arg(tff,mountpt),'rolldown');
%
   mountpt = arg(obj);
   if (isempty(mountpt))
      mountpt = '<main>';
   end
   
   MenuSetupBode(obj,mountpt);
   return
   
%==========================================================================
% View Menu
%==========================================================================

function MenuSetupView(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%
   a = 5;
   
   default('profiler',0);
   default('view.pzonly',0);

   men = mount(obj,'<main>',LB,'View');
         uimenu(men,LB,'Standard Menues',CB,call('CbStdMenu'));
         uimenu(men,LB,'Tool Bar',CB,call('CbToolBar'));
         uimenu(men,LB,'Grid on/off',CB,'grid;');
         uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');
         
   return         

%==========================================================================
   
function CbStdMenu(obj)  % switch standard menus on/off
%
   itm = gcbo;                          % get menu item handle
   toolbar = get(gcf,'toolbar');        % get current toolbar status
   if strcmp(get(itm,'checked'),'on')
      set(gcf,'menubar','none');
      set(itm,'checked','off');
   else
      set(gcf,'menubar','figure');
      set(itm,'checked','on');
   end
   set(gcf,'toolbar',toolbar);          % restore toolbar status
   return
       
function CbToolBar(obj)  % switch on icon tool bar
%
   itm = gcbo;   % get menu item handle
   if strcmp(get(itm,'checked'),'on')
      set(gcf,'toolbar','none');
      set(itm,'checked','off');
   else
      set(gcf,'toolbar','figure');
      set(itm,'checked','on');
   end
   return
   
%==========================================================================
% Bode Menu
%==========================================================================

function MenuSetupBode(obj,mountpt)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
   
   if (nargin < 2) mountpt = '<main>'; end
%            
   default('bode.omin',1e-2);         % minimum frequency
   default('bode.omax',1e+3);         % maximum frequency
   default('bode.mmin',-80);          % minimum magnitude
   default('bode.mmax',+80);          % maximum magnitude
   default('bode.pmin',-270);         % minimum phase
   default('bode.pmax',+90);          % maximum phase

   men = mount(obj,mountpt,LB,'Bode');
         uimenu(men,LB,'Bode Plot',CB,call('CbRun'),UD,'CbBode');

   sub = uimenu(men,LB,'---------------------');
   
   sub = uimenu(men,LB,'Frequency Range');
   itm = uimenu(sub,LB,'Min Omega',UD,'bode.omin');
         uimenu(itm,LB,'1e-2',CB,CHCR,UD,1e-2);
         choice(itm,setting('bode.omin'));   
   itm = uimenu(sub,LB,'Max Omega',UD,'bode.omax');
         uimenu(itm,LB,'1e+3',CB,CHCR,UD,1e+3);
         choice(itm,setting('bode.omax'));   

   sub = uimenu(men,LB,'Magnitude Range');
   itm = uimenu(sub,LB,'Min Magnitude',UD,'bode.mmin');
         uimenu(itm,LB,'-80',CB,CHCR,UD,-80);
         choice(itm,setting('bode.mmin'));   
   itm = uimenu(sub,LB,'Max Magnitude',UD,'bode.mmax');
         uimenu(itm,LB,'+80',CB,CHCR,UD,+80);
         choice(itm,setting('bode.mmax'));   

   sub = uimenu(men,LB,'Phase Range');
   itm = uimenu(sub,LB,'Min Phase',UD,'bode.pmin');
         uimenu(itm,LB,'-270',CB,CHCR,UD,-270);
         choice(itm,setting('bode.pmin'));   
   itm = uimenu(sub,LB,'Max Phase',UD,'bode.pmax');
         uimenu(itm,LB,'+90',CB,CHCR,UD,+90);
         choice(itm,setting('bode.pmax'));   
   return

function CbBode(obj)   
%
   bode(obj);
   return

   
%==========================================================================
% Root Locus Menu
%==========================================================================

function MenuSetupRloc(obj,mountpt)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
   
   if (nargin < 2) mountpt = '<main>'; end
%            
   default('rloc.scope',1.2);     % scope factor for plot area
   default('rloc.asymptotes',1);  % draw asymptotes
   default('rloc.pzonly',0);      % plot only poles & zeros
   default('rloc.zoom',1);        % zoom factor for root locus
   default('rloc.ncolor','b');    % negative color (K < 0)
   default('rloc.icolor','m');    % intermediate color (0 <= K < 1)
   default('rloc.pcolor','r');    % positive color (K >= 1)
   default('rloc.mcolor','k');    % marker color (poles & zeros)
   default('rloc.width',1);       % line width
   default('rloc.mwidth',3);      % marker width (poles & zeros)
   default('rloc.bullets',1);     % draw bullets
   
   men = mount(obj,mountpt,LB,'Root Locus');
         uimenu(men,LB,'Root Locus PLot',CB,call('CbRun'),UD,'CbRloc');

   sub = uimenu(men,LB,'---------------------');
   
   itm = uimenu(men,LB,'Scope',UD,'rloc.scope');
         uimenu(itm,LB,'1.2',CB,CHCR,UD,1.2);
         choice(itm,setting('rloc.scope'));   

   itm = uimenu(men,LB,'Asymptotes',UD,'rloc.asymptotes');
         check(itm,setting('rloc.asymptotes'));   

   itm = uimenu(men,LB,'Only poles & zeros',UD,'rloc.pzonly');
         check(itm,setting('rloc.pzonly'));   

   itm = uimenu(men,LB,'Zoom factor',UD,'rloc.zoom');
         uimenu(itm,LB,'x 1/8',CB,CHCR,UD,1/8);
         uimenu(itm,LB,'x 1/6',CB,CHCR,UD,1/6);
         uimenu(itm,LB,'x 1/4',CB,CHCR,UD,1/4);
         uimenu(itm,LB,'x 1/2',CB,CHCR,UD,1/2);
         uimenu(itm,LB,'x 3/4',CB,CHCR,UD,3/4);
         uimenu(itm,LB,'x 1',CB,CHCR,UD,1);
         uimenu(itm,LB,'x 1.5',CB,CHCR,UD,1.5);
         uimenu(itm,LB,'x 2',CB,CHCR,UD,2);
         uimenu(itm,LB,'x 3',CB,CHCR,UD,3);
         uimenu(itm,LB,'x 4',CB,CHCR,UD,4);
         choice(itm,setting('rloc.zoom'));   

   itm = uimenu(men,LB,'Line width',UD,'rloc.width');
         uimenu(itm,LB,'1',CB,CHCR,UD,1);
         uimenu(itm,LB,'2',CB,CHCR,UD,2);
         uimenu(itm,LB,'3',CB,CHCR,UD,3);
         choice(itm,setting('rloc.width'));   

   return

function CbRloc(obj)   
%
   rloc(obj);
   return

   
%==========================================================================
% Model Control
%==========================================================================

function MenuSetupControl(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
%            
   default('control.Kp',1);           % controller gain
   default('control.Ti',5);           % Integration time constant
   default('control.Td',1);           % Differential time constant
   default('control.N',10);           % lead ratio
   default('control.omega',2);        % omega
   default('control.zeta',1);         % zeta

   men = mount(obj,'<main>',LB,'Control');
         uimenu(men,LB,'Root Locus 1',CB,call('CbControl'),UD,'CbRloc1');
         uimenu(men,LB,'Root Locus 2',CB,call('CbControl'),UD,'CbRloc2');
         uimenu(men,LB,'Step Response 2',CB,call('CbControl'),UD,'CbStep2');

   sub = uimenu(men,LB,'---------------------');
   itm = uimenu(men,LB,'Kp: Controller Gain',UD,'control.Kp');
         uimenu(itm,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(itm,LB,'0.2',CB,CHCR,UD,0.2);
         uimenu(itm,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(itm,LB,'0.7',CB,CHCR,UD,0.7);
         uimenu(itm,LB,'1.0',CB,CHCR,UD,1.0);
         uimenu(itm,LB,'1.2',CB,CHCR,UD,1.2);
         uimenu(itm,LB,'1.5',CB,CHCR,UD,1.5);
         uimenu(itm,LB,'2.0',CB,CHCR,UD,2.0);
         uimenu(itm,LB,'3.0',CB,CHCR,UD,3.0);
         uimenu(itm,LB,'5.0',CB,CHCR,UD,5.0);
         uimenu(itm,LB,'10',CB,CHCR,UD,10);
         choice(itm,setting('control.Kp'));   

   itm = uimenu(men,LB,'Ti: Integration Time',UD,'control.Ti');
         uimenu(itm,LB,'5',CB,CHCR,UD,5);
         choice(itm,setting('control.Ti'));   

   itm = uimenu(men,LB,'Td: Differential Time',UD,'control.Td');
         uimenu(itm,LB,'1',CB,CHCR,UD,1);
         choice(itm,setting('control.Td'));   

   itm = uimenu(men,LB,'omega: controller frequency',UD,'control.omega');
         uimenu(itm,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(itm,LB,'1.0',CB,CHCR,UD,1.0);
         uimenu(itm,LB,'2.0',CB,CHCR,UD,2.0);
         uimenu(itm,LB,'3.0',CB,CHCR,UD,3.0);
         uimenu(itm,LB,'4.0',CB,CHCR,UD,4.0);
         choice(itm,setting('control.omega'));   

   itm = uimenu(men,LB,'zeta: controller damping',UD,'control.zeta');
         uimenu(itm,LB,'0.1',CB,CHCR,UD,0.1);
         uimenu(itm,LB,'0.2',CB,CHCR,UD,0.2);
         uimenu(itm,LB,'0.3',CB,CHCR,UD,0.3);
         uimenu(itm,LB,'0.4',CB,CHCR,UD,0.4);
         uimenu(itm,LB,'0.5',CB,CHCR,UD,0.5);
         uimenu(itm,LB,'0.6',CB,CHCR,UD,0.6);
         uimenu(itm,LB,'0.7',CB,CHCR,UD,0.7);
         uimenu(itm,LB,'0.8',CB,CHCR,UD,0.8);
         uimenu(itm,LB,'0.9',CB,CHCR,UD,0.9);
         uimenu(itm,LB,'1.0',CB,CHCR,UD,1.0);
         uimenu(itm,LB,'1.1',CB,CHCR,UD,1.1);
         uimenu(itm,LB,'1.2',CB,CHCR,UD,1.2);
         uimenu(itm,LB,'1.3',CB,CHCR,UD,1.3);
         uimenu(itm,LB,'1.4',CB,CHCR,UD,1.4);
         uimenu(itm,LB,'1.5',CB,CHCR,UD,1.5);
         uimenu(itm,LB,'2.0',CB,CHCR,UD,2.0);
         uimenu(itm,LB,'5.0',CB,CHCR,UD,5.0);
         uimenu(itm,LB,'8.0',CB,CHCR,UD,8.0);
         choice(itm,setting('control.zeta'));   

   itm = uimenu(men,LB,'N: Lead ratio',UD,'control.N');
         uimenu(itm,LB,'1',CB,CHCR,UD,1);
         uimenu(itm,LB,'2',CB,CHCR,UD,2);
         uimenu(itm,LB,'5',CB,CHCR,UD,5);
         uimenu(itm,LB,'10',CB,CHCR,UD,10);
         choice(itm,setting('control.N'));   

   return

function CbControl(obj)   
%
   CbExecute(obj,'studymodel');
   return

   
%==========================================================================
% 4) Auxillary Functions
%==========================================================================

function [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];  VI = 'visible';
   CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')]; 
   MF = mfilename; 
   return

%==========================================================================
   
function CbExecute(obj,handler)        % execute callback
%
% Cbexecute    Execute an external handler function which dispatches
%              to the particular handler given by user data
%
   cbsetup(obj);                       % setup current function for refresh
   keypress(obj,'CbTerminate');
  
   if (nargin <2)
      handler = setting('shell.execute');
      if (isempty(handler))
         return;                      % cannot continue
      end
   end
   setting('shell.execute',handler);  % for next time keypress
   
   busy;
   cmd = [handler,'(obj);'];
   eval(cmd);
   ready;

   keypress(obj,'CbRefresh')
   return

function CbRun(obj)   
%
   cbsetup(obj);                       % setup current function for refresh
   keypress(obj,'CbTerminate');
  
   busy;
   handler = 'menu';
   func = arg(obj);
   cmd = [handler,'(obj,''',func,''');'];
   eval(cmd);
   ready;

   keypress(obj,'CbRefresh')
   return
   
%==========================================================================
% Key Press Handlers
%==========================================================================
   
function CbRefresh(obj)
%
% CBREFRESH   Ignore keypress event
%
   fprintf('CbRefresh: key pressed!\n');
   profiler([]);                 % initialize profiler
   refresh(obj);
   if (option(obj,'profiler'))
      profiler;                  % display profiling information
   end
   return

function CbIgnore(obj)
%
% CBIGNORE   Ignore keypress event
%
   %fprintf('CbIgnore: key pressed!\n');
   return

function CbTerminate(obj)
%
% CBTERMINATE   Set termination flag on keypress event
%
   %fprintf('CbTerminate: key pressed!\n');
   terminate(smart);
   keypress(obj,'CbRefresh');    % continue next keypress with refresh
   return
   
   
%==========================================================================
   
% eof