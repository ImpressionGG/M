function oo = menu(o,varargin)         % CUTE Menu Construction        
% 
% MENU   Build functions for CUTE menu.
%
%           oo = menu(o,'Select');
%           oo = menu(o,'Organized');
%           oo = menu(o,'Filter');
%           oo = menu(o,'Rotate');
%           oo = menu(o,'Bias');
%
%        See also: CARALOG, SHELL, ADVANCED
%
   [gamma,oo] = manage(o,varargin,@Error,@Select,@Basket,...
                       @Facette,@Ffilter,@Vfilter,@Filter,@Bias,...
                       @Rotate,@Heading,@Internal,@Refresh,@About);
   oo = gamma(oo);                     % invoke callback
end

%==========================================================================
% Menu Setup
%==========================================================================

function o = Error(o)                  % Error                         
   error('menu method must be called with a local function arg!');
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Add Select Menu               
%
% SELECT   Add Select menu
%
   oo = mhead(o,'Select');             % menu header
   ooo = wrap(oo,'Objects');           % add Objects menu (wrapped)

   ooo = mitem(oo,'-');
   ooo = menu(oo,'Organize');          % add Organize menu
   ooo = wrap(oo,'Basket');            % add Basket menu (wrapped)
   %enable(ooo,0);
   %set(mitem(ooo,inf),'visible','off');

   ooo = mitem(oo,'-');
   ooo = wrap(oo,'Bias');              % add Bias menu (wrapped)
   ooo = menu(oo,'Filter');            % add Filter menu
   %ooo = menu(oo,'Scope');            % add Scope menu   
   %ooo = menu(oo,'Ignore');           % add Ignore menu
   ooo = mitem(oo,'-');
   ooo = Spec(oo);                     % add Spec menu
   ooo = wrap(oo,'Facette');           % add Facette menu
   ooo = Scaling(oo);                  % add Scaling menu item   
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Internal');          % add Internal menu
   
   Title(o);                           % refresh title in figure bar
end

function oo = NewActivate(o)           % Object Activation             
%
   o.profiler('Activate',1);           % begin profiling
   
   idx = arg(o,1);
   oo = current(o,idx);
  
   o.profiler('Activate',0);           % end profiling
   if control(o,'profiling') > 1
      o.profiler
   end
   
   refresh(o);
   
   if (idx == 0)
      title = 'Package';
   else
      title = sprintf('Object #%g',idx);
   end
   
   title = get(oo,{'title',title});
   set(figure(o),'name',title);        % update figure title
end
function oo = Basket(o)                % Basket Menu                   
   oo = basket(o,'Menu');              % add Basket menu
end
function oo = OldBasket(o)             % Basket Menu                   
   setting(o,{'basket.collect'},'selected');  % collection of objects
   %setting(o,{'basket.groups'},'*');  % choice of groups

   oo = mhead(o,'Basket');             % add Basket header
   
   ooo = mhead(oo,'Collect','','basket.collect'); % add Objects menu header
   choices = {{'All Objects','*'},{},{'Selected Object','selected'},...
              {'Marked Objects','marked'},{'Unmarked Objects','unmarked'}};
   choices = {{'All Objects','*'},{},{'Selected Object','selected'}};
   choice(ooo,choices,'');
   
%  ooo = mitem(oo,'-');                % add separator
%  ooo = mhead(oo,'Groups','','basket.groups');   % add Groups menu header
%  choices = {{'All Groups','*'},{},...
%             {'Marked Groups','marked'},{'Unmarked Groups','unmarked'}};
%  choice(ooo,choices,'');
%  set(mitem(ooo,inf),'visible','off');% make invisible
   
   ooo = menu(oo,'Type');              % add Type menu
   ooo = menu(oo,'Kind');              % add Kind menu
end
function oo = Kind(o)                  % Add Kind Menu                 
%
% KIND   Setup kind selection menu
%
   setting(o,{'basket.kind'},'*');     % all kinds selected by default
   
      % for each different kind add a menu item
      
   choices = {{'All Kinds','*'}};
   list = Kinds(o);
   if ~isempty(list)
      choices{end+1} = {};
      for (i=1:length(list))
         name = list{i};
         choices{end+1} = {name,name};
      end
   end
   oo = mhead(o,'Kind','','basket.kind');
   choice(oo,choices,{@KindCb});
   return
   
   function o = KindCb(o)
      oo = current(o);                 % get current object
      dynamic(o,oo);                   % update all dynamic menu items
      refresh(o);
   end
   function list = Kinds(o)            % Get List of Kinds             
      list = {};
      if container(o)
         for (i=1:length(o.data))
            oo = o.data{i};
            kind = get(oo,'kind');
            if ~isempty(kind) && ~corazon.is(kind,list)
               list{end+1} = kind;
            end
         end
      end
   end
end
function oo = Title(o)                 % Set Title in Figure Bar       
   oo = current(o);                    % get current object
   title = get(o,{'title','Shell'});   % get container object's title
   title = get(oo,{'title',title});    % get current object's title
   set(figure(o),'name',title);        % update figure bar
end

function oo = Bias(o)                  % Bias Mode Menu                
%
   setting(o,{'mode.bias'},'absolute');% default bias mode is 'drift'

   oo = mhead(o,'Bias','','mode.bias');
   choice(oo,{{'Absolute','absolute'},{'Absolute * 1000','abs1000'},...
              {'Drift','drift'},{'Deviation','deviation'}},{});

   ooo = mseek(oo,{'Absolute * 1000'});
   set(mitem(ooo,inf),'visible','off');        
end
function oo = Filter(o)                % Add General Filter Menu       
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mseek(o,{'#','Select'});

   ooo = mitem(oo,'General Filter');
   oooo = mitem(ooo,'Mode','','filter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'filter.type');
   choice(oooo,{{'Order 2 Low Pass','LowPass2'},...
                {'Order 2 High Pass','HighPass2'},...
                {'Order 4 Low Pass','LowPass4'},...
                {'Order 4 High Pass','HighPass4'}},{});
   oooo = mitem(ooo,'Bandwidth',{},'filter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'filter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'filter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end
function oo = Scope(o)                 % Scope Menu                    
   setting(o,{'select.scope'},[]);     % no scope restriction
   setting(o,{'select.from'},1);       % scope from
   setting(o,{'select.to'},inf);       % scope to
   
   oo = mitem(o,'Scope');
   ooo = mitem(oo,'From',{},'select.from');
   charm(ooo,{@ScopeCb,'from'});
   ooo = mitem(oo,'To',{},'select.to');
   charm(ooo,{@ScopeCb,'to'});
   return
   
   function o = ScopeCb(o)
      mode = arg(o,1);
      oo = current(o);
      sz = sizes(oo);
      switch mode
         case 'from'
         case 'to'
      end
      from = setting(o,'select.from');
      to = setting(o,'select.to');
      from = max(min(from,sz(3)),1);
      
      if isinf(to) && sz(3) == 1
         scope = [];
      else
         to = max(min(to,sz(3)),1);
         scope = from:to;              % default scope range
      end
      setting(o,'select.scope',scope);    
      refresh(o);
   end
end
function oo = Ignore(o)                % Ignore Menu                   
%
   setting(o,{'select.ignore'},0);     % no data to ignore by default
   oo = mitem(o,'Ignore','','select.ignore');
   choice(oo,[0:10,15:5:25,50,100],{});
end
function oo = Spec(o)                  % Specs Menu                    
   setting(o,{'spec.mode'},1);         % by default display specs
   setting(o,{'spec.linewidth'},1);    % default spec line width
   
      % kappl specs
      
   setting(o,{'spec.a'},[25 100]);     % default acceleration specs
   setting(o,{'spec.v'},[40 160]);     % default acceleration specs
   setting(o,{'spec.s'},[6.25 25]);    % default acceleration specs
   
      % kolben specs
      
   setting(o,{'spec.b'},[2.5 10.0]);   % default Kolben acceleration specs
 
      % THDR specs
      
   setting(o,{'spec.thdr'},0.2);       % harmonic distortion specs
   
      % build menu
      
   oo = mitem(o,'Spec');
   ooo = mitem(oo,'Mode',{},'spec.mode');
   choice(ooo,{{'Off',0},{'Strong',1},{'Weak',2}},{});
   
   ooo = mitem(oo,'Acceleration',{},'spec.a');
   choice(ooo,{{'25g (100g)',[25 100]}},{});
   choice(ooo,{{'50g (200g)',[50 200]}},{});
   choice(ooo,{{'100g (400g)',[100 400]}},{});
   
   ooo = mitem(oo,'Velocity',{},'spec.v');
   choice(ooo,{{'40mm/s (160mm/s)',[40 160]}},{});
   choice(ooo,{{'80mm/s (320mm/s)',[80 320]}},{});
   choice(ooo,{{'160mm/s (640mm/s)',[160 640]}},{});

   ooo = mitem(oo,'Elongation',{},'spec.s');
   choice(ooo,{{'6.25um (25um)',[6.25 25]}},{});
   choice(ooo,{{'12.5um (50um)',[12.5 50]}},{});
   choice(ooo,{{'25um (100um)',[25 100]}},{});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'THDR',{},'spec.thdr');
   choice(ooo,{{'1%',0.01},{'2%',0.02},{'5%',0.05},{'10%',0.1},...
               {'15%',0.15},{'20%',0.20},{'25%',0.25},{'30%',0.30}},{});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Line Width',{},'spec.linewidth');
   choice(ooo,[0.5 1 2],{});
end
function oo = Facette(o)               % Facette Selection Menu        
   setting(o,{'select.facette'},0);
   
   
   oo = current(o);
   if ~(isa(oo,'cute') && type(oo,{'cut'}))
      oo = mhead(o,'Facette');         % provide a dummy menu
      enable(oo,0);                    % disable Facette header menu item
      ooo = mhead(oo,'Dummy');
      return                           % Facette menu is only for CUTEs
   end
   
   if container(oo)
      itab = [];
   else
      %idx = cluster(oo);
      itab = cache(oo,'cluster.itab');
   end
   n = size(itab,1);

      % provide Facette menu header item
      
   oo = mhead(o,'Facette',{},'select.facette');
   enable(oo,true);

      % add Facette menu sub-items
      
   list = {{'Total',0},{'Compact',-1},{}};
   for (i=1:n)
      label = sprintf('Facette #%d',i);
      list{end+1} = {label,i};
   end
   choice(oo,list,{});
end
function oo = Scaling(o)               % Scaling Menu Item             
   setting(o,{'select.scaling'},'same');
   
   oo = mitem(o,'Scaling',{},'select.scaling');
   choice(oo,{{'Same','same'},{'Individual','individual'}},{});
end

%==========================================================================
% Internal Submenu
%==========================================================================

function oo = Internal(o)              % Internal Menu                 
   oo = mseek(o,{'#','Select'});

   ooo = mhead(oo,'Internal');
   oooo = menu(ooo,'Rotate');          % add Rotate menu
   oooo = Cluster(ooo);                % add cluster parameter menu
   oooo = Cpk(ooo);                    % Cpk Parameters                
   oooo = Thdr(ooo);                   % Thdr Parameters                
   oooo = Cfilter(ooo);                % add cluster filter menu
   oooo = Vfilter(ooo);                % add velocity filter menu
end
function oo = Rotate(o)                % Rotate Menu                   
   setting(o,{'brew.rotate'},2);       % rotation on by default
   
   oo = mitem(o,'Rotate',{},'brew.rotate');
   ooo = choice(oo,{{'Off',0},{'Compensate Facette Rotation',1},...
                    {'Transform to 1-2-3',2}},{@DirtyCache});
   
   function o = DirtyCache(o)
      dirty = setting(o,'brew.dirty');
      setting(o,'brew.dirty',dirty+1); % make brew options dirty
   end
end
function oo = Cluster(o)               % Cluster Menu                  
   setting(o,'cluster.method','sigma');
   setting(o,'cluster.segments',100);
   setting(o,'cluster.threshold',6);   % sigma threshold
   
   oo = mhead(o,'Clustering');
   ooo = mitem(oo,'Cluster Method',{},'cluster.method');
   choice(ooo,{{'Level','level'},{'Sigma','sigma'}},{});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Number of Segments',{},'cluster.segments');
   choice(ooo,[10,20,50,100,200,500,1000],{});
   ooo = mitem(oo,'Sigma Threshold',{},'cluster.threshold');
   choice(ooo,{{'3 Sigma',3},{'4 Sigma',4},{'5 Sigma',5},{'6 Sigma',6},...
               {'10 Sigma',10},{'20 Sigma',20},{'50 Sigma',50}},{});
end
function oo = Cpk(o)                   % Cpk Parameters                
   setting(o,{'cpk.pareto'},0.99);     % Cpk pareto
   setting(o,{'cpk.relevance'},2);     % relevance algorithm
   
   oo = mhead(o,'Process Capability (Cpk)');
   ooo = mitem(oo,'Relevance',{},'cpk.relevance');
   choice(ooo,{{'All Signals in Interval',1},{'Large Signals Only',2}},{});
   ooo = mitem(oo,'Cpk Pareto',{},'cpk.pareto');
   choice(ooo,{{'90%',0.90},{'92%',0.92},{'95%',0.95},{'99%',0.99},...
               {'99.2%',0.992},{'99.5%',0.995},{'99.9%',0.999}},{});

end
function oo = Thdr(o)                  % Total Harmonic Distortion     
   setting(o,{'thdr.bandwidth'},1500); % 1500 Hz
   
   oo = mhead(o,'Total Harmonic Distortion (THDR)');
   ooo = mitem(oo,'Bandwidth [Hz]',{},'thdr.bandwidth');
   charm(ooo,{});
end
function oo = Cfilter(o)               % Add Cluster Filter Menu       
   setting(o,{'cfilter.mode'},'raw');   % filter mode off
   setting(o,{'cfilter.type'},'LowPass2');
   setting(o,{'cfilter.bandwidth'},0.2);
   setting(o,{'cfilter.zeta'},0.6);
   setting(o,{'cfilter.method'},1);

   oo = o;
   ooo = mitem(oo,'Cluster Filter');
   oooo = mitem(ooo,'Mode','','cfilter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'cfilter.type');
   choice(oooo,{{'Order 2 Low Pass','LowPass2'},...
   %            {'Order 2 High Pass','HighPass2'},...
   %            {'Order 4 High Pass','HighPass4'},...
                {'Order 4 Low Pass','LowPass4'}},{});...
              
   oooo = mitem(ooo,'Bandwidth',{},'cfilter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'cfilter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'cfilter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end
function oo = Vfilter(o)               % Add Velocity Filter Menu      
   setting(o,{'vfilter.mode'},'raw');   % filter mode off
   setting(o,{'vfilter.type'},'Order2');
   setting(o,{'vfilter.bandwidth'},100);
   setting(o,{'vfilter.zeta'},0.6);
   setting(o,{'vfilter.method'},1);

   oo = o;
   ooo = mitem(oo,'Velocity Filter');
   oooo = mitem(ooo,'Mode','','vfilter.mode');
   choice(oooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'Type',{},'vfilter.type');
   choice(oooo,{{'Order 2','Order2'},{'Order 4','Order4'}},{});
   oooo = mitem(ooo,'Bandwidth',{},'vfilter.bandwidth');
   charm(oooo,{});
   oooo = mitem(ooo,'Zeta',{},'vfilter.zeta');
   charm(oooo,{});
   oooo = mitem(ooo,'Method',{},'vfilter.method');
   choice(oooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = About(o)                 % About Object                  
   oo = plot(o,'About');               % delegate to plot function
end
function oo = Refresh(o)               % Refresh Figure & Cache        
   refresh(o);                         % invoke refresh callback
   dirty = setting(o,'brew.dirty');    % get current value of dirty
   setting(o,'brew.dirty',dirty+1);
   oo = o;
end

%==========================================================================
% Helper
%==========================================================================

function o = Heading(o)                % Provide Heading               
   [~,facette] = cluster(o,inf);       % get facette index
   if (facette == 0)
      suffix = '(Total)';
   elseif (facette < 0)
      suffix = '(Compact)';
   else
      suffix = sprintf('(Facette #%g)',facette);
   end
   
   title = [get(o,{'title',''}),' ',suffix];
   heading(o,title);
end
