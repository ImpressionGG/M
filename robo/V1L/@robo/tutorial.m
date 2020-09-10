function tutorial(obj,func)
% 
% TUTORIAL  ROBO Tutorial; open new figure and setup a tutorial menu for
%           a ROBO object. The tutorial shell allows to check the tutorials
%      
%              robo              % use this short syntax to open tutorial
%
%           There are (unimportant) alternatives which also work:
%
%              tutorial(robo)    % open a ROBO shell with tutorial menu
%              robo tutorial     % syntactic sugar for the same
%
%           See also: ROBO
%
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj);                          % open figure & setup menu items 
   elseif ~propagate(obj,func,which(func)) 
      eval([func,'(obj);']);               % invoke callback
   end
   return
    
%==========================================================================
% User Defined Menu Setup
%==========================================================================

function setup(obj)
%
% SETUP  Setup all standard menus
%
   obj = set(obj,'menu',{{mfilename},'file'},'title','ROBO Tutorial');
   obj = set(obj,'comment',{'Getting started with ROBO Toolbox'});

   menu(obj);                          % open menu
   
   TutorialIntroMenu(obj,'<main>')
   
   return                     

   
%==========================================================================      
% Intro Menu
%==========================================================================      

function TutorialIntroMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   men = mount(obj,mountpt,LB,'Intro');
   sub = mymenu(men,'ROBO Introduction','intro_robo');
         uimenu(men,LB,'-----------------');
   sub = mymenu(men,'Consider a Chip','intro_chip');
   sub = mymenu(men,'Make a Foto','intro_camera');
   sub = mymenu(men,'Linear Map','intro_order1_map');
         uimenu(men,LB,'-----------------');
   sub = mymenu(men,'Make a Foto','intro_camera');
   sub = mymenu(men,'Second Order Map','intro_order2_map');
         uimenu(men,LB,'-----------------');
   sub = mymenu(men,'Make a Foto','intro_camera');
   sub = mymenu(men,'Third Order Map','intro_order3_map');

   return

%==========================================================================      
% Auxillary Functions
%==========================================================================      

function hdl = mymenu(parent,label,userdata)
%
% MYMENU  Syntactic sugar for uimenu call
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   if (nargin > 2)
      hdl = uimenu(parent,LB,label,CB,call('exec'),UD,userdata);
   else
      hdl = uimenu(parent,LB,label);
   end
   return

%==========================================================================      

function exec(obj)  % execute M-file from an uimenu callback.
   evalin('base',get(gcbo,'userdata'));
   return
   
% eof