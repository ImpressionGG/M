function oo = cuteplug1(o,varargin)    % Cuteplug1 Plugin              
%
% CUTEPLUG1 Cuteplug1 plugin: customize metrics view (support a special
%           metrics plot menu)
%
%              cuteplug1(sho)          % plugin registration
%
%              oo = cuteplug1(o,func)  % call local cuteplug1 function
%
%           See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho,@WithBsk,...
                       @Metrics);
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
   oo = Plot(o);                       % add Plot menu items
end

%==========================================================================
% Plot Menu Plugins
%==========================================================================

function oo = Plot(o)                  % Plot Menu Setup               
%
% PLOT   Add some Plot menu items
%
   oo = mseek(o,{'#','Plot'});         % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   types = {'shell','cuteplug1'};          % supported types

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Special');
         enable(ooo,type(o,{'shell','pkg','cut'}));
   oooo = mitem(ooo,'Special Metrics',{@WithCuo,'Metrics'});
end
function oo = Metrics(o)               % Plot Metrics Overview         
   switch o.type
      case {'cut'}
         oo = CutMetrics(o);
      case {'pkg'}
         oo = PkgMetrics(o);
      otherwise
         oo = ShellMetrics(o);
   end
   
   function oo = CutMetrics(o)         % Plot Metrics for Cut Object   
      oo = metrics(o,[1 1 1]);
   end
   function oo = PkgMetrics(o)         % Plot Metrics for Pkg Object   
      bag = cook(o,'package');         % access package data
      o = var(o,bag);
      [cpk,mgr,chk] = var(o,'cpks,mgrs,chk');
      
      if isempty(cpk)
         oo = plot(o,'About');
         return
      end
      
         % plot standard metrics plot
         
      o = opt(o,'heading',false);      % no heading for metrics plot
      oo = metrics(o,[2 1 1]);

         % plot overall metrics as the minimum of all
         % partial metrics
         
      subplot(o,[2 1 2]);
      index = basket(o,'Index');       % get basket indices
      
      n = length(index);
      for (k=1:n)
         i = index(k);
         met(k) = min([cpk(i),mgr(i),chk(i)]); 
      end
      plot(o,1:n,met,'bcw3');  
      hold on
      plot(o,1:n,met,'go');
      
      o = var(o,cook(o,'spec'));
      plot(o,get(gca,'Xlim'),[1 1],[var(o,'color'),'-.']);
      
      title('Overall Metrics');
      set(gca,'Ylim',get(gca,'Ylim').*[0 1]);
      set(gca,'Xtick',1:n);
      
         % add heading
         
      msg = [get(o,{'title',''}),' (',id(o),')'];
      extra = opt(o,{'view.heading',''});
      if (extra)
         msg = [msg,' - ',extra];
      end
      
      heading(o,msg);
   end
   function oo = ShellMetrics(o)       % Plot Metrics for Shell Object 
      oo = metrics(o);
   end
end
