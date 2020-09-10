function tiny(obj,varargin)
% 
% TINY   A tiny demo
%      
%             tiny(core,'Setup');       % setup SIMPLE menu structure
%             tiny(core);               % same as above (for empty args)
%
%          See also: CORE, MENU, SIMPLE
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'Setup');
   eval(cmd);                             % invoke callback
   return
end

%==========================================================================
% Menu Setup
%==========================================================================

function Setup(obj)           
%
% SETUP    Setup menu
%
   obj = set(obj,'title','A Tiny Demo Shell');
   obj = set(obj,'comment',{'Playing around with simple graphics'});
   
      % setup the launch function
      
   obj = launch(obj,mfilename);

      % setup a menu shell and provide File roll down menu
      
   menu(obj,'Empty');         % setup an new empty menu shell
   menu(obj,'File');          % add standard File roll down menu
   tiny(obj,'Tiny');          % add Tiny roll down menu
   menu(obj,'XInfo');         % add standard Info roll down menu
   
   if isempty(refresh(obj))   % refresh and check whether refresh worked
      menu(obj,'Home');       % call Home function which sets up refresh
   end
   return                     
end

%==========================================================================
% Setup Tiny Rolldown Menu
%==========================================================================

function Tiny(obj)
%
% TINY   Setup Tiny roll down menu
%
   default('bullets',0);
   default('color','r');
   
      % setup the tiny menu
      
   ob1 = mitem(obj,'Tiny');                 % add rolldown header item
   ob2 = mitem(ob1,'Bullets','','bullets');
         check(ob2,call('refresh'));        % add check/refresh mechanism
   ob2 = mitem(ob1,'Color','','color');
         list = {{'Red','r'},{'Green','g'},{'Blue','b'}};
         choice(ob2,list,call('refresh'));  % add choice/refresh mechanism
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Plot',call('Sine'));
   return
end


%==========================================================================
% Plot Sine and Cosine Function
%==========================================================================
   
function Sine(obj)
%
% SINE   Plot sine and cosine function
%
   bullets = option(obj,'bullets');
   col = iif(bullets,'k.',option(obj,'color'));
   
   cls                               % clear screen
   t = 0:0.1:10; 
   plot(t,sin(2*pi/10*t),col);
   
   refresh(obj,inf);                 % use this function for refresh
   shg;                              % shoe graphics
   return
end

