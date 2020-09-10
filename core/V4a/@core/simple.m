function simple(obj,varargin)
% 
% SIMPLE   Manage SIMPLE roll down menu
%      
%             simple(core,'Setup');       % setup SIMPLE menu structure
%             simple(core);               % same as above
%
%          See also: CORE, MENU, TUTORIAL, TINY
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
   vers = ['CORE toolbox version: ',version(core)];

   obj = set(obj,'title','A Simple Demo Shell');
   obj = set(obj,'comment',{'Playing around with simple graphics',vers});
   obj = launch(obj,mfilename);

      % setup a menu shell and provide File roll down menu
      
   menu(obj,'Empty');         % setup an new empty menu shell
   menu(obj,'File');          % add standard File roll down menu
   simple(obj,'Parameter');   % add Parameter roll down menu
   simple(obj,'Plot');        % setup Plot roll down menu
   menu(obj,'XInfo');         % add extended Info menu
   
   if isempty(refresh(obj))   % refresh and check whether refresh worked
      SinCos(arg(gfo,{1}));   % call SinCos which sets up refresh callback
   end
   return                     
end

%==========================================================================
% Setup Simple Rolldown Menu
%==========================================================================

function Parameter(obj)
%
% PARAMETER   Setup PARAMETER roll down menu
%
   clist = {'b','g','r','c','m','y','k'};
   
   default('bullets',0);
   default('color',clist);
   default('frequency',1);
   default('linewidth',1);
   default('grid',0);
   
      % setup the simple menu
      
   ob1 = mitem(obj,'Parameter');            % add rolldown header item
   ob2 = mitem(ob1,'Bullets','','bullets');
         check(ob2,call('refresh'));        % add check/refresh mechanism
   ob2 = mitem(ob1,'Plot Color','','color');
         list = {{'Red','r'},{'Green','g'},{'Blue','b'},{'Auto',clist}};
         choice(ob2,list,call('refresh'));  % add choice/refresh mechanism
   ob2 = mitem(ob1,'Frequency','','frequency');
         list = {{'x 1.0',1.0},{'x 1.5',1.5},{'x 2.0',2.0}};
         choice(ob2,list,'');               % add choice/refresh mechanism
   ob2 = mitem(ob1,'Line Width','','linewidth');
         choice(ob2,1:3,'');
         choice(ob2,'4',4,'');
         choice(ob2,'5',5,call('refresh'));
   ob2 = mitem(ob1,'Grid','','grid');
         check(ob2,'');                     % add check/refresh mechanism
   ob2 = mitem(ob1,'Show Settings','setting',0);
   
   return
end

%==========================================================================
% Setup Plot Rolldown Menu
%==========================================================================

function Plot(obj)
%
% Plot   Setup PLOT roll down menu
%
   ob1 = mitem(obj,'Plot');               % add rolldown header item
   ob2 = mitem(ob1,'SIN/COS Demo');       % add rolldown item
         mitem(ob2,'1 Axis',call,{'SinCos',1});
         mitem(ob2,'2 Axes',call,{'SinCos',2});
         
   ob2 = mitem(ob1,'-----------------------');
   
   ob2 = mitem(ob1,'Multi Plot Demo');
         mitem(ob2,'1 Axis',call,{'MultiPlot',1});
         mitem(ob2,'2 Axes',call,{'MultiPlot',2});
   
   return
end

%==========================================================================
   
function SinCos(obj)
%
% SIN-COS   Plot sine and cosine function
%
   kf = setting('frequency'); 
   t = 0:0.1:10; 
   xy = [sin(kf*2*pi/10*t); cos(kf*2*pi/10*t)];
   cob = core({t,xy},obj);           % construct a data object from  t & x

   cob = option(cob,'xscale',1);     % overwrite x-scaling 
   cob = option(cob,'suffix',{});    % overwrite suffix settings 
   cls on;                           % clear screen (axes visible)
   
   switch arg(obj,1);                % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         cob = set(cob,'title','Sine/Cosine Function'); 
         cob = set(cob,'xlabel',sprintf('frequency = %g',kf));
         plot(cob);          
      case 2                         % plot to dual axes
         cob = set(cob,'title',{'Sine Function','Cosine Function'}); 
         cob = set(cob,'symbol',{'sin','cos'}); 
         plot(cob,[subplot(211),subplot(212)]);
   end
   
   refresh(obj,inf);                 % use this function for refresh
   click(obj,'Click');               % setup mouse button click callback
   shg;                              % shoe graphics
   return
end

%==========================================================================

function MultiPlot(obj)
%
% MULTI-PLOT
%
   kf = setting('frequency'); 
   t = 0:0.1:10; 
   for (k=1:10)
       xy(:,k) = 1 + cos(kf*2*pi/10*k*t) / k;
   end
   tit = sprintf('f(t) = 1 + cos(kf*2*pi/10*k*t)/k  (kf = %3.1f)',kf);
   cob = core({t,xy},obj);           % construct a data object from  t & x
   cob = set(cob,'title',tit);       % set title 

   cob = option(cob,'xscale',1);     % overwrite x-scaling 
   cls on;                           % clear screen (axes visible)
   switch arg(obj,1)                 % number of axes objects to be plotted
      case 1                         % single axis; same as plot(obj,gca)
         plot(cob);          
      case 2                         % plot to dual axes
         plot(cob,[subplot(211),subplot(212)]);
   end
   
   refresh(obj,inf);                 % use this function for refresh
   click(obj,'Click');               % setup mouse button click callback
   shg;                              % shoe graphics
   return
end

%==========================================================================      
% Mouse Button Click Handler
%==========================================================================      

function Click(obj)
%
   kf = setting('frequency') + 0.5;
   if (kf > 2) kf = 1; end
   choice('frequency',kf);          % refresh menu setting
   refresh(obj);
   return
end

