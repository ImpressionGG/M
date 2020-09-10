function demo(obj,func,cbo)
% 
% DEMO   Open new figure and setup demo menu for a SHELL object
%      
%           demo(shell)  % open figure with demo menu for shell object
%
%        See also: SHELL
%
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj,[]);                       % open figure & setup menu items 
   elseif ~propagate(obj,func,cbo,which(func)) 
      eval([func,'(obj,cbo);']);           % invoke callback
   end
   return
    
%==========================================================================
% 1) Some auxillary functions we need in the context of this file
%==========================================================================

function keypress(func)                  % setup keypress function
   set(gcf,'WindowButtonDownFcn',call(eval('func','''CbKeyPress''')));
   return

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

function exec(obj,cbo)
%
% EXEC   Execute M-file
%
   cmd = get(cbo,'userdata');
   eval(cmd);
   return
   
%==========================================================================
% 2) User Defined Menu Setup
%==========================================================================

function setup(obj,parent)   % Setup all standard menus
%
% SETUP    Setup menu
%
   obj = set(obj,'menu',{'file'},'title','Shell Demo');
   obj = set(obj,'comment',{'Play arround and investigate',...
          'the power of SHELL objects.','Have fun!'});

   menu(obj);                    % open menu
   
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
         shmenu(sub,'Open a Shell to Play','intro_openshell');
         shmenu(sub,'Add Color Setting Menu Items','intro_colorsetting');
         shmenu(sub,'Add Menu Stuff','intro_addmenus');
         shmenu(sub,'Shell Settings','intro_setting');
   
   men = mount(obj,mountpt,LB,'Shell');
   shmenu(men,'About SHELL objects','construct_shell');
   shmenu(men,'Simple SHELL Construction','construct_simple');
   
   return
   
%==========================================================================      


%==========================================================================      

function Construct(obj,cbo)
   switch get(cbo,'userdata');
      case 'shell',     cons_shell
      case 'setting',   cons_simple
   end
   return

   
% eof