function oo = cuteplug2(o,varargin)    % Cuteplug2 Plugin              
%
% CUTEPLUG2 Cuteplug2 plugin: list object titles under different
%           basket (filter) settings
%
%              cuteplug2(sho)          % plugin registration
%
%              oo = cuteplug2(o,func)  % call local cuteplug2 function
%
%           See also: CUTE, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho,@WithBsk,...
                       @Objects);
   oo = gamma(oo);
end              

%==========================================================================
% Plugin Setup & Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   tag = class(o);
   plugin(o,[tag,'/menu/End'],{mfilename,'Menu'});
   plugin(o,[tag,'/current/Select'],{mfilename,'Menu'});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
  end
  dark(o);                            % do dark mode actions
end
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
 
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Plugin Definitions
%==========================================================================

function o = Menu(o)                   % Setup General Plugin Menus    
%
% MENU   Setup general plugin menus. General Plugins can be used to plug-
%        in menus at any menu location. All it needs to be done is to
%        locate a menu item by path and to insert a new menu item at this
%        location.
%
   oo = Analyse(o);                    % add Analyse menu items
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Analyse(o)               % Plot Menu Setup               
%
% ANALYSE   Add some Analyse menu items
%
   oo = mseek(o,{'#','Analyse'});      % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Basket');
         enable(ooo,type(o,{'shell','pkg'}));
   oooo = mitem(ooo,'Selected Objects',{@WithCuo,'Objects'});
end
function oo = Objects(o)               % Plot Object Overview          
   switch o.type
      case {'shell'}
         oo = ShellObjects(o);
      case {'pkg'}
         oo = PkgObjects(o);
      otherwise
         oo = plot(o,'About');
   end
   
   function o = PkgObjects(o)          % Plot List of Basket Objects   
      assert(type(o,{'pkg'}));
      uscore = o.util('uscore');
      
      oo = var(o,cook(o,'package'));   % access package data
      objects = var(oo,'objects');
      number = var(oo,'number');
      
         % get basket indices according to basket (filter) settings
         
      index = basket(oo,'Index');      % get basket indices      
      n = length(index);
      
         % plot dummy stuff
         
      plot([-1 10],[0.5 n+1.5],'.');   % must plot some junk initially!!!
      dark(o,'Axes');                  % dark mode dependent axes
      set(gca,'Ylim',[0 n+1.5]);
      hold on;
         
      x = 0;
      Package(o,x,n+1,'bc');
      for (i=1:n)
         y = n+1-i;
         col = o.iif(dark(o),'w','k'); % dark mode depending color

         k = index(i);           % actual index
         Object(oo,x,y,col,objects{k},number(k));
      end
      Heading(o);                      % add heading        
      axis('off');
   end
   function o = ShellObjects(o)        % Plot List of Basket Objects   
      assert(type(o,{'shell'}));
      
         % first get N as total line count needed
         
      o = pull(o);                     % get shell object
      N = 0;
      for (i=1:length(o.data))
         oo = o.data{i};
         if type(oo,{'pkg'})
            index = basket(oo,'Index');% get basket indices      
            N = N+1+length(index);
         end
      end
      
         % plot dummy stuff
         
      plot([-1 10],[0.5 N+1.5],'.');   % must plot some junk initially!!!
      dark(o,'Axes');                  % dark mode dependent axes
      set(gca,'Ylim',[0 N+1.5]);
      hold on;
         
         % now loop through all packages
         
      x = 0;  y = N+1;  
      for (i=1:length(o.data))                                         
         oo = o.data{i};
         if ~type(oo,{'pkg'})
            continue
         end
         
         bag = cook(oo,'package');  % access package data
         N = N+1+length(bag.objects);

         y = y-1;
         Package(oo,x,y,'bc');

         index = basket(oo,'Index');% get basket indices      
         n = length(index);

         for (i=1:n)
            y = y-1;
            col = o.iif(dark(o),'w','k'); % dark mode depending color
            k = index(i);           % actual index
            Object(oo,x,y,col,bag.objects{k},bag.number(k));
         end
      end
      Heading(o);
      axis('off');
   end
end

%==========================================================================
% Helpers
%==========================================================================

function Object(o,x,y,col,object,numb) % Plot Object Text              
   uscore = o.util('uscore');          % short hand
   ID = sprintf('%s.%d',id(o),numb);
   title = [ID,': ',object];
   hdl = text(x,y,uscore(title));
   set(hdl,'Color',o.color(col));
   set(hdl,'Horizontal','left','Vertical','mid');
end
function Package(o,x,y,col)            % Plot Package Text             
   uscore = o.util('uscore');          % short hand
   package = get(o,{'package',''});
   title = get(o,{'title',['Package ',package]});
   hdl = text(x,y,uscore(title));
   set(hdl,'Color',o.color('bc'));
   set(hdl,'Horizontal','left','Vertical','mid');
end
function Heading(o)                    % Add Diagram Heading           
   if type(o,{'pkg'})
      msg = [get(o,{'title',''}),' (',id(o),')'];
   else
      msg = get(o,{'title',''});
   end
   
   extra = opt(o,{'view.heading',''});
   if ~all(extra==' ')
      msg = [msg,' - ',extra];
   end

   heading(o,msg);
end
