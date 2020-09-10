function sinedemo(obj,func,cbo)
% 
% SINEDEMO  Open new figure for Sine Demo / handle callbacks
%      
%              sinedemo  % open figure with demo menu for Sine Demo
%              sinedemo(obj,func,cbo)   % handle callback
%
%           See also: SHELL

   if (nargin == 0)                        % dispatch: setup or callback?
      setup(create,[]);                    % create SHELL object & setup
   elseif (nargin == 1)                    % dispatch: setup or callback?
      setup(eval('obj','shell'),[]);       % open figure & setup menu items 
   elseif ~propagate(obj,func,cbo,which(func)) 
      eval([func,'(obj,cbo);']);           % invoke callback
   end
   return
      
%==========================================================================

function obj = create
%
% CREATE  Create a SHELL object and provide some settings
%
   obj = shell('play','title','Sine Demo - Mfile based');
   obj = set(obj,'menu',{'file','play'});
   return
   
%==========================================================================
   
function setup(obj,cbo)
%
% SETUP   Open figure & setup menu items for Sine Demo 
%
   obj = set(obj,'clone',mfilename);       % necessary for clone function
   menu(obj);
   
   LB = 'label'; CB = 'callback'; UD = 'userdata'; CBI = 'refresh(gcfo);';
   CHCI = ['choice(gcbo);',CBI];  CHKI = ['check(gcbo);',CBI];

      % Let's define and initialize two settings: 'color' and 'bullets' 

   default('color','r');       % red color as our default setting
   default('bullets',1);       % draw bullets as our default setting

      % Now we add a menu item as a child of 'Play' menu to plot the sine

   men = mount(gcfo,'Play');   % get handle for mounting at menu 'Play'
   itm = uimenu(men,'label','Plot Sine Wave',CB,call('CbPlot'));
         uimenu(men,LB,'--------------');

      % We'd like to have choice for 'color' selection

   itm = uimenu(men,LB,'Color',UD,'color');
         uimenu(itm,LB,'Red',CB,CHCI,UD,'r');
         uimenu(itm,LB,'Blue',CB,CHCI,UD,'b');
         choice(itm,setting('color'));

      % And we'd like to toggle the 'bullets' setting

   itm = uimenu(men,LB,'Bullets',CB,CHKI,UD,'bullets');
         check(itm,setting('bullets'));

      % Finally we want to see actual parameter setting based on menu click

   uimenu(men,LB,'--------------');
   uimenu(men,LB,'Display Settings',CB,'setting');
   return                     

%==========================================================================

function CbPlot(obj,cbo)   % plot callback
%
% CBPLOT   Plot callback: plots a sine curve regarding 'color' setting
%          and 'bullets' setting.
%
   cls; 
   t = 0:25;  y = sin(t*2*pi/max(t));   % time vector & sine wave data
   c = setting('color');                % get current 'color' setting
   b = setting('bullets');              % get current 'bullets' setting
   plot(t,y,c);                         % plot sine wave
   if (b)                               
      hold on; plot(t,y,'k.');          % plot bullets if demanded
   end
   
   cbsetup(obj,cbo); % setup current function (CbPlot) as refresh callback
   return
   
% eof