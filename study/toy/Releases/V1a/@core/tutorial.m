function tutorial(obj)
% 
% TUTORIAL   CORE Tutorial
%
%    Open new figure and setup a tutorial menu for a CORE object
%      
%       tutorial(obj)  % open a menu shell with tutorial menu
%
%    See also: CORE DEMO
%
   [cmd,obj,list] = dispatch(obj);
   if cmd
      eval(cmd);
   else
      setup(obj);
   end
   return
   
%==========================================================================

function dummy
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj);                          % open figure & setup menu items 
   elseif ~propagate(obj,func,which(func)) 
      eval([func,'(obj);']);               % invoke callback
   end
   return
    
%==========================================================================
% 1) Some auxillary functions we need in the context of this file
%==========================================================================

function hdl = shmenu(parent,label,userdata)
%
% SHMENU  Syntactic sugar for uimenu call
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   if (nargin > 2)
      hdl = uimenu(parent,LB,label,CB,call('exec'),UD,userdata);
   else
      hdl = uimenu(parent,LB,label);
   end
   return

%==========================================================================
% 2) User Defined Menu Setup
%==========================================================================

function setup(obj)   % Setup all standard menus
%
% SETUP    Setup menu
%
   obj = set(obj,'menu',{{mfilename},'file'},'title','Shell Tutorial');
   obj = set(obj,'comment',{'How to utilize the power of SHELL objects',...
          'Introduction into SHELL class','Have fun!'});

   menu(obj);                          % open menu
   
   IntroDemoMenu(obj,'<main>')
   
   return                     

   
%==========================================================================      
% Intro Demo Menu
%==========================================================================      

function IntroDemoMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   men = mount(obj,mountpt,LB,'Intro');
   sub = uimenu(men,LB,'Chameleon Introduction');
         shmenu(sub,'Chameleon Toolbox Introduction','intro_toolbox');
         shmenu(sub,'Introduction to SHELL Objects','intro_shell');
   sub = uimenu(men,LB,'The Sine Demo');
         shmenu(sub,'Sine Demo - At a Glance','intro_sinedemo');
         uimenu(sub,LB,'------------------');
         shmenu(sub,'Playing with Sine Demo','intro_playing');
         shmenu(sub,'Dealing with an Object','intro_dealing');
   sub = uimenu(men,LB,'Details About Sine Demo');
         shmenu(sub,'Understanding Sine Demo','intro_understanding');
         shmenu(sub,'Open a Shell to Play','intro_openshell');
         shmenu(sub,'Add Color Setting Menu Items','intro_colorsetting');
         shmenu(sub,'Add Menu Stuff','intro_addmenus');
         shmenu(sub,'Shell Settings','intro_setting');
   
   men = mount(obj,mountpt,LB,'Shell');
         shmenu(men,'About SHELL objects','cons_shell');
         shmenu(men,'Simple SHELL Construction','cons_simple');

   %men = mount(obj,mountpt,LB,'Chameo');
   %      shmenu(men,'Study ASE#16 Logging','menu(ase16)');
   %      uimenu(men,LB,'------------------');
   %      shmenu(men,'Launching Chameo Toolbox Shell','chameo_toolbox');
         
   return
   
%==========================================================================      

function Construct(obj)
   switch args(obj,1);
      case 'shell',     cons_shell
      case 'setting',   cons_simple
   end
   return

function exec(obj)  % execute M-file
    cmd = args(obj,1);
    evalin('base',cmd);    %evalin('base',get(gcbo,'userdata'));
    return
    
% eof