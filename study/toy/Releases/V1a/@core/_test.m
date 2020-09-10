function test(obj,func)
% 
% TEST      SHELL Tutorial; open new figure and setup a tutorial menu for a
%           SHELL object
%      
%              tutorial(shell)  % open a shell with tutorial menu
%
%           See also: SHELL DEMO
%
   if (nargin <= 1)                        % dispatch: setup or callback?
      setup(obj,[]);                       % open figure & setup menu items 
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

function hdl = mymenu(parent,label,func,userdata)
%
% MYMENU  Syntactic sugar for uimenu call
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   if (nargin >= 4)
      hdl = uimenu(parent,LB,label,CB,call(func),UD,userdata);
   elseif (nargin >= 3)
      hdl = uimenu(parent,LB,label,CB,call(func));
   end
   return

%==========================================================================
% 2) User Defined Menu Setup
%==========================================================================

function setup(obj,parent)   % Setup all standard menus
%
% SETUP    Setup menu
%
   obj = set(obj,'menu',{{mfilename},'file','test','info'});
   obj = set(obj,'title','Shell Test');
   obj = set(obj,'comment',{'This test shell provides functions',...
          'for regression test of shell functionality.',...
          'It can be also used for studies!'});

   menu(obj);                          % open menu
   
   IntroDemoMenu(obj,'<main>')
   
   return                     

   
%==========================================================================      
% Intro Demo Menu
%==========================================================================      

function IntroDemoMenu(obj,mountpt)
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 

   men = mount(obj,mountpt,LB,'Shell');
   sub = uimenu(men,LB,'Shell Creation');
         shmenu(sub,'Create & open a test shell','test_shellcreate');
         
   return
   
%==========================================================================      
   
% eof