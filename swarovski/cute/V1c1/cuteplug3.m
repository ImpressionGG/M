function oo = cuteplug3(o,varargin)    % Cuteplug3 Plugin              
%
% CUTEPLUG3 Cuteplug3 plugin: demonstration of hooking into cache brewing
%
%              cuteplug3(sho)          % plugin registration
%
%              oo = cuteplug3(o,func)  % call local cuteplug3 function
%
%           The plugin demonstrates the following topics:
%
%              1) Adding a Select/Internal/My_Cpk menu to change settings
%                 for 'MyCpk' calculation
%              2) Adding a Plot/My-Metrics menu entry to plot a customized
%                 metrics diagram
%              3) Providing and registering a BrewBrew callback which is 
%                 called for 'brew' cache segment refresh
%              4) Providing and registering a BrewPackage callback which is
%                 called for 'package' cache segment refresh
%              5) Modifying cute/metrics  method to incorporate new MyCpk
%                 in metrics diagram as 4-bar plot (look for string '@@@')
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CUTE, PLUGIN, SAMPLE, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Menu,...
                       @WithCuo,@WithSho,@WithBsk,...
                       @BrewBrew,@BrewPackage,@MyMetrics);
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
   plugin(o,[tag,'/brew/Brew'],{mfilename,'BrewBrew'});
   plugin(o,[tag,'/brew/Package'],{mfilename,'BrewPackage'});
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
% Menu Plugin Definitions
%==========================================================================

function o = Menu(o)                   % Setup General Plugin Menus    
%
% MENU   Setup general plugin menus. General Plugins can be used to plug-
%        in menus at any menu location. All it needs to be done is to
%        locate a menu item by path and to insert a new menu item at this
%        location.
%
   oo = Select(o);                     % add Select menu items
   oo = Plot(o);                       % add Plot menu items
end

%==========================================================================
% Select Menu Plugins
%==========================================================================

function oo = Select(o)                % Select Menu Plugins           
%
% SELECT   Add some Select menu items
%
   oo = mseek(o,{'#','Select' 'Internal'});   % find Select/Internal menu
   if isempty(oo)
      return
   end
   
   setting(o,{'spec.mycpk.factor'},0.2);
   
   ooo = mitem(oo,'-');
   ooo = mhead(oo,'My Cpk');
         enable(ooo,type(current(o),{'shell','pkg','cut'}));
   oooo = mitem(ooo,'Factor',{},'spec.mycpk.factor');
   choice(oooo,[-0.02 -0.01 0.01 0.1 0.2 0.5],{});
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
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'My Metrics',{@WithCuo,'MyMetrics'});
         enable(ooo,type(current(o),{'shell','pkg','cut'}));
end
function oo = MyMetrics(o)             % Plot MyMetrics Diagram        
   oo = Metrics(o);                    % forward to Metrics
end

%==========================================================================
% Cache Brewing
%==========================================================================

function oo = BrewBrew(o)              % Brew 'brew' Cache Segment     
%
% BREWBREW  This Callback is initiated when somewhere the 'brew' cache
%           segment is accessed and it is not up-to-date. This will cause
%           the brew/Breww local function being invoked, which has a plug
%           point to allow calling the current function (upon registered)
%
%           Typical action of this function is to refresh all plugin spe-
%           cific data in the 'brew' cache segment.
%
   fprintf('%s: brewing ''brew'' segment (%s) ...\n',...
           mfilename,get(o,{'oid','?'}));
   
      % calculate all data to be refreshed in the 'brew' cache segment
      
   mycpk = MyCpk(o);
   
      % store mycpks in 'package' cache segment
      % you may enter 'cache(oo)' to investigate updated cache
 
   oo = cache(o,'brew.mycpk',mycpk);
end
function oo = BrewPackage(o)           % Brew 'package' cache segment  
   fprintf('%s: brewing ''package'' segment (%s) ...\n',...
           mfilename,get(o,{'oid','?'}));
   
      % calculate all data to be refreshed in the 
      % 'package' cache segment ...

   assert(type(o,{'pkg'}));
   objids = cache(o,'package.objids');
   
   if isempty(objids)
      fprintf('*** warning: could not brew package (cuteplug3)\n');
      oo = o;
      return
   end

      % objids has valid data, so we can do our actual job to calculate
      % all data to be refreshed in the package cache segment
      
   mycpks = [];                     % we need to refresh 'mycpks'
   for (i=1:length(objids))
      oo = select(o,objids{i});
      oid = get(oo,'oid');          % just for debug
      if isempty(oo)                % then object is not loaded
         mycpks(i) = NaN;
      else
         mycpks(i) = MyCpk(oo);
      end
   end
   
      % if mycpks contains all valid values then we can store
      % mycpks as data, otherwise we retrieve mycpks from data
      
   if any(isnan(mycpks))
      mycpks = data(o,{'mycpks',zeros(1,length(objids))});
   else
      o = data(o,'mycpks',mycpks);
      assert(length(mycpks) == length(data(o,'numbers'))); 
   end

      % store mycpks in 'package' cache segment
      % you may enter 'cache(oo)' to investigate updated cache

   oo = cache(o,'package.mycpks',mycpks);
end
function mycpk = MyCpk(o)              % Calculate My (Special) Cpk    
   factor = opt(o,{'spec.mycpk.factor',100});
   mycpk = 1.0 + get(o,{'number',0})*factor;
end

%==========================================================================
% Plot Metrics Diagram (All Stuff Copied from metrics.m)
%==========================================================================

function oo = Metrics(o,sub)           % Plot Metrics Diagram          
%
% METRICS   Plot metrics diagram
%
%              oo = metrics(o,[1 1 1]) % metrics diagram in subplot(1,1,1)
%              oo = metrics(o)         % same as above
%
%           Remarks:
%              - occasional hard refresh of 'spec' and 'package', but soft
%                refresh of 'brew' cache segment. This is to avoid spoiling
%                cache memory for a huge number of data objects
%
%           Options:
%
%              heading:       plot heading (default: true)
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CUTE, DIAGRAM, PLOT
%
   if (nargin < 2)
      sub = [1 1 1];
   end
   
   oo = opt(o,'subplot',sub);          % store for helpers
   
   [ok,duplicate] = integrity(o);
   if ~ok
      message(o,'Metrics plot denied',...
               [{'reason: duplicate packages or objects (fix first):'},...
               duplicate]);
      oo = o;
      return
   end
   
      % dispatch on type
      
   cls(o);
   switch oo.type
      case 'shell'
         ShellMetrics(o,sub);
      case 'pkg'
         PkgMetrics(oo,sub);
      case 'cut'
         CutMetrics(oo,sub);
      otherwise
         plot(oo,'About');
   end
   dark(o);
end

%==========================================================================
% Shell Metrics, Package Metrics, Data Object Metrics
%==========================================================================

function o = ShellMetrics(o,sub)       % Plot Shell Metricss           
   oo = current(o);
   if ~container(oo) || ~type(oo,{'shell'}) || isempty(oo.data)                 
      plot(o,'About');
      return                           % bye!
   end
   subplot(o,sub);
   
   uscore = util(o,'uscore');          % short hand
   strong = (spec(o) <= 1);            % strong spec mode
 
      % begin graphics, return boundary values

   [o,m,xlim] = Begin(o,[1 1 1]);      % begin graphics 
   PlotMetrics(o);                     % plot bars row by row ...
   End(o);                             % end graphics

   if opt(o,{'heading',true})
      txt = Project(o);
      heading(o,txt);
   end
   
   function PlotMetrics(o)             % Plot Bars Row by Row          
      ru = 0.05;                       % graphical raster unit
      p = 0;                           % package index
      y = m;                           % y-position
      for (i=1:length(o.data))
         oo = o.data{i};
         oo = inherit(oo,o);           % inherit options from container
         
         if type(oo,{'pkg'})
            index = var(oo,'index');   % already pre-calculated in Begin
            if isempty(index)
               continue                % ignore this package
            end
            
            p = p+1;                   % inc package index
            y0 = y;                    % mid this y coordinate

            name = get(oo,{'title',''});
            txt = o.iif(name,name,sprintf('Package #%g',p));
            hdl = text(0,y,txt);
            set(hdl,'Color',o.color('bc'));
            FontSize(o,m,hdl,+4);
            y = y-1;                   % decrement y position

               % fetch bag of package cache segment

            [oo,bag,rfr] = cache(oo,'package');
            
            cpk = o.iif(strong,bag.cpks(index),bag.cpkw(index));
            mgr = o.iif(strong,bag.mgrs(index),bag.mgrw(index));
            chk = bag.chk(index);
            facettes = bag.facettes(index);

            if (index)
               objects = bag.objects(index);
            else
               objects = {};
            end
            
               % @@@ retrieve our special metrics values. Those are
               % found in the 'package' cache segment. alternatively 
               % we could just take from bag (bag.mycpks)
         
            mycpks = cache(oo,'package.mycpks');                       %@@@
            mycpk = mycpks(index);                                     %@@@
 
               % plot metrics bars

            for (j=1:length(objects))
               % PlotBar(o,mgr(j),[y+3*ru,y+7*ru],'r');                %@@@
               % PlotBar(o,cpk(j),[y-2*ru,y+2*ru],'ryyy');             %@@@
               % PlotBar(o,chk(j),[y-3*ru,y-7*ru],'ggk');              %@@@

                  % @@@ instead of 3 bars we will plot 4 bars
            
               PlotBar(o,mgr(j),[y+5*ru,y+7*ru],'r');
               PlotBar(o,cpk(j),[y+1*ru,y+3*ru],'ryyy');
               PlotBar(o,mycpk(j),[y-1*ru,y-3*ru],'mmc');
               PlotBar(o,chk(j),[y-5*ru,y-7*ru],'ggk');
               
                  % @@@ for facette plotting we must pass the minimum of 
                  % cpk(i) and mycpk(i) in order to get proper coloring of
                  % facette bars

               % PlotFacettes(o,facettes(j),[y-7*ru,y+7*ru],cpk(j),mgr(j));

               mini = min(cpk(j),mycpk(j));                            %@@@
               PlotFacettes(o,facettes(j),[y-7*ru,y+7*ru],mini,mgr(j));%@@@

                  % @@@ for Text plotting we must pass additional mycpk(j)

               % x0 = max([cpk(j),mgr(j),chk(j)]);                     %@@@
               % Text(oo,m,j,x0,y,ru, objects{j},mgr(j),cpk(j),chk(j));%@@@

               x0 = max([cpk(j),mgr(j),chk(j),mycpk(j)]);              %@@@
               Text(oo,m,j,x0,y,ru, objects{j},mgr(j),cpk(j),chk(j),mycpk(j));
               
               y = y-1;                   % decrement y position
            end
            
            scol = opt(o,{'spec.color','c'});
            hdl = plot(o,[1 1],[y0-0.5 y+0.5],[scol,'-.']);
            set(hdl,'Linewidth',opt(o,{'spec.linewidth',1}));
         end
      end
   end
   function [o,m,xlim] = Begin(o,sub)  % Begin Graphics                
      assert(container(o));            % make sure we deal with shell obj
   
         % for each package we need rows for objects plus package heading

      m = 0;
      xlim = [0 0];
     
         % loop through object list and take action for package objects
         
      for (i=1:length(o.data))
         oo = inherit(o.data{i},o);
         if type(oo,{'pkg'})
            [oo,bag,rfr] = cache(oo,oo,'spec');
            [oo,bag,rfr] = cache(oo,oo,'package');
            
               % get basket indices, store as var in object
               % and refresh container list
               
            index = basket(oo,'Index');
            oo = var(oo,'index',index);
            o.data{i} = oo;
            
               % if index is not empty then add update line count (m)
               % by adding required line numbers
               
            if ~isempty(index)
               m = m + length(index) + 1;
            end

               % calculate xmin and xmax
               
            xmin = -1;  xmax = 1;
            
            if (index)
               cpk = o.iif(strong,bag.cpks(index),bag.cpkw(index));
               mgr = o.iif(strong,bag.mgrs(index),bag.mgrw(index));
               chk = bag.chk(index);
               
                  % @@@ retrieve our special metrics values. Those are
                  % found in the 'package' cache segment. alternatively 
                  % we could just take from bag (bag.mycpks)
         
               mycpks = cache(oo,'package.mycpks');                    %@@@
               mycpk = mycpks(index);                                  %@@@
              
               % xmax = 3*max([max(cpk),max(mgr),max(chk),1]);         %@@@
         
                  % @@@ Above commented statement is as it is found in 
                  % metrics.m, but it is not the right way to do: we also 
                  % need to consider the values of mycpk for xmax calcula-
                  % tion, so let's get xmax by proper calculation!
         
               xmax = 3*max([max(cpk),max(mgr),max(chk),1,max(mycpk)]);%@@@
            end
            
            xlim = [min(xlim(1),xmin), max(xlim(2),xmax)];
         end
      end
      
         % begin graphics
         
      subplot(o,sub);
      plot(o,xlim,[0 m+1],'w.');

      set(gca,'Ytick',[]);             % no yticks
      set(gca,'Xlim',xlim, 'Ylim',[0.5 max(m,1)+0.5]);
   end
   function End(o)                     % End Graphics                  
      package = get(o,{'package',''});
      title(['Magnitude Reserve (Mgr), Process Capability (Cpk)',...
             ' & Harmonic Capability (Chk)']);
      ylabel('Chk (green),  Cpk (gold),  Mgr (red)');
   end
end
function o = PkgMetrics(o,sub)         % Plot Package Metricss         
   if ~type(o,{'pkg'})                 
      plot(o,'About');
      return                           % bye!
   end
   
      % hard refresh spec cache segment and package cache segment 
      
   package = get(o,{'package',''});
   [o,bag,rfr] = cache(o,o,'spec');
   [o,bag,rfr] = cache(o,o,'package');
      
      % plot Cpk and Mgr (magnitude reserve)
         
   PlotMetrics(o,sub);                 % plot magnitude reserve & Cpk
   
   if opt(o,{'heading',true})
      txt = Project(o);
      heading(o,txt);
   end

   function PlotMetrics(o,sub)         % Plot Magnitude Reserve & Cpk  
      uscore = util(o,'uscore');       % short hand
      subplot(o,sub);

      [o,bag,rfr] = cache(o,'package');
      index = basket(o,'Index');
      o = var(o,'index',index);        % need in Text()
      
      cpk = o.iif(spec(o)<=1,bag.cpks(index),bag.cpkw(index));
      mgr = o.iif(spec(o)<=1,bag.mgrs(index),bag.mgrw(index));
      chk = bag.chk(index);
      facettes = bag.facettes(index);
      
      if (index)
         objects = bag.objects(index);
      else
         objects = {};
      end

         % @@@ retrieve our special metrics values. Those are found
         % in the 'package' cache segment. alternatively we could just 
         % take from bag (bag.mycpks)
         
      mycpks = cache(o,'package.mycpks');                             % @@@
      mycpk = mycpks(index);                                          % @@@
      
         % start plotting
         
      % xmax = 3*max([max(cpk),max(mgr),max(chk),1]);
      
         % @@@ Above commented statement is as it is found in metrics.m,
         % but it is not the right way to do: we also need to consider the 
         % values of mycpk for xmax calculation, so let's get xmax by pro-
         % per calculation!
         
      xmax = 3*max([max(cpk),max(mgr),max(chk),1,max(mycpk)]);         %@@@
      
      xmin = -1;
      plot([xmin xmax],[0 length(cpk)+1],'w.');
      dark(o,'Axes');
      
      m = length(index);  
      ru = 0.05;                          % graphical raster unit

      if (m > 0)
         set(gca,'Ytick',[]);             % no yticks
         set(gca,'Xlim',[xmin xmax], 'Ylim',[0.5 length(cpk)+0.5]);
      end
      
      for (i=1:m)
         y = m+1-i;

         % PlotBar(o,mgr(i),[y+3*ru,y+7*ru],'r');                      %@@@
         % PlotBar(o,cpk(i),[y-2*ru,y+2*ru],'ryyy');                   %@@@
         % PlotBar(o,chk(i),[y-3*ru,y-7*ru],'ggk');                    %@@@
         
            % @@@ instead of 3 bars we will plot 4 bars
            
         PlotBar(o,mgr(i),[y+5*ru,y+7*ru],'r');
         PlotBar(o,cpk(i),[y+1*ru,y+3*ru],'ryyy');
         PlotBar(o,mycpk(i),[y-1*ru,y-3*ru],'mmc');
         PlotBar(o,chk(i),[y-5*ru,y-7*ru],'ggk');

            % @@@ for facette plotting we must pass the minimum of cpk(i)
            % and mycpk(i) in order to get proper coloring of facette bars
         
         mincpk = min(cpk(i),mycpk(i));
         
         % PlotFacettes(o,facettes(i),[y-7*ru,y+7*ru],cpk(i),mgr(i));  %@@@
         PlotFacettes(o,facettes(i),[y-7*ru,y+7*ru],mincpk,mgr(i));

         % x0 = max([cpk(i),mgr(i),chk(i)]);                           %@@@
         x0 = max([cpk(i),mgr(i),chk(i),mycpk(i)]);                    %@@@

            % @@@ for Text plotting we must pass additional mycpk(i)
            
         % Text(o,m,i,x0,y,ru, objects{i},mgr(i),cpk(i),chk(i));       %@@@
         Text(o,m,i,x0,y,ru, objects{i},mgr(i),cpk(i),chk(i),mycpk(i));%@@@
      end

      scol = opt(o,{'spec.color','c'});
      hdl = plot(o,[1 1],get(gca,'Ylim'),[scol,'-.']);
      set(hdl,'Linewidth',opt(o,{'spec.linewidth',1}));

      package = get(o,{'package',''});
      title(['Magnitude Reserve (Mgr), Process Capability (Cpk)',...
             ' & Harmonic Capability (Chk)']);
      ylabel('Chk (green),  Cpk (gold),  Mgr (red)');
   end
end
function o = CutMetrics(o,sub)         % Plot Cut Object Metrics       
   if ~type(o,{'cut'})                 
      plot(o,'About');
      return                           % bye!
   end

      % after fetching current object we will hard refresh the 'brew' cache
      % segment (if it is not up-to-date). This means that there is no
      % further subsequent data brewing, as oo has an up-to-date brew cache
      % segment (otherwise we have endless data brewwing)
      
   oo = current(o);
   [oo,bag,rfr] = cache(oo,oo,'brew'); % hard refresh of brew cache segment

   
   oo = opt(oo,'select.facette',0);
   PlotAcceleration(oo);
   
   if opt(o,{'heading',true})
      txt = Project(o);
      heading(o,txt);
   end
 
   function PlotAcceleration(o)        % Plot Acceleration Diagrams    
      o = opt(o,'metrics',false);
      
      t = cook(o,':');
      a1 = cook(o,'a1');               % fetch cutting acceleration 1
      a2 = cook(o,'a2');               % fetch cutting acceleration 2
      a3 = cook(o,'a3');               % fetch cutting acceleration 3
      a = cook(o,'a');                 % fetch cutting acceleration 3

      PlotMetrics(oo,[4 1 1]);

      diagram(o,'A1',t,a1,[4 4 5]);
      diagram(o,'A2',t,a2,[4 4 6]);
      diagram(o,'A3',t,a3,[4 4 7]);
      diagram(o,'A',t,a,[4 4 8]);
      
      diagram(o,'A12',a1,a2,[2 3 4]);
      diagram(o,'A13',a1,a3,[2 3 5]);
      diagram(o,'A23',a2,a3,[2 3 6]);
   end
   function PlotMetrics(o,sub)         % Plot Magnitude Reserve & Cpk  
      uscore = util(o,'uscore');       % short hand
      subplot(sub(1),sub(2),sub(3));

      %[o,bag,rfr] = cache(o,'package');
      [cpks,cpkw,mgrs,mgrw,mgn,sig,avg] = cpk(o,'a');
      %index = basket(o,'Index');
      o = var(o,'index',[1]);          % needed for Text()
      [~,chk] = thdr(oo);
      
      Cpk = o.iif(spec(o)<=1,cpks,cpkw);
      mgr = o.iif(spec(o)<=1,mgrs,mgrw);
      facettes = cluster(o,inf);
      
      objects = {get(o,{'title',''})};

         % @@@ retrieve our special metrics values. Those are found
         % in the 'package' cache segment. alternatively we could just 
         % take from bag (bag.mycpks)
         
      mycpk = cache(o,'brew.mycpk');                                   %@@@
      
         % start plotting
         
      %xmax = 3*max([max(Cpk),max(mgr),max(chk),1]);
      
         % @@@ Above commented statement is as it is found in metrics.m,
         % but it is not the right way to do: we also need to consider the 
         % values of mycpk for xmax calculation, so let's get xmax by pro-
         % per calculation!
         
      xmax = 3*max([max(Cpk),max(mgr),max(chk),1,max(mycpk)]);         %@@@
      
      xmin = -1;
      plot([xmin xmax],[0 length(Cpk)+1],'w.');
      dark(o,'Axes');
      
      m = 1;  
      ru = 0.05;                       % graphical raster unit

      if (m > 0)
         set(gca,'Ytick',[]);          % no yticks
         set(gca,'Xlim',[xmin xmax], 'Ylim',[0.5 length(Cpk)+0.5]);
      end
      
      for (i=1:m)
         y = m+1-i;
         % PlotBar(o,mgr(i),[y+3*ru,y+7*ru],'r');                      %@@@
         % PlotBar(o,Cpk(i),[y-2*ru,y+2*ru],'ryyy');                   %@@@
         % PlotBar(o,chk(i),[y-3*ru,y-7*ru],'ggk');                    %@@@

            % @@@ instead of 3 bars we will plot 4 bars
            
         PlotBar(o,mgr(i),[y+5*ru,y+7*ru],'r');
         PlotBar(o,Cpk(i),[y+1*ru,y+3*ru],'ryyy');
         PlotBar(o,mycpk(i),[y-1*ru,y-3*ru],'mmc');
         PlotBar(o,chk(i),[y-5*ru,y-7*ru],'ggk');
         
            % @@@ for facette plotting we must pass the minimum of cpk(i)
            % and mycpk(i) in order to get proper coloring of facette bars
         
         mincpk = min(Cpk(i),mycpk(i));
         
         % PlotFacettes(o,facettes(i),[y-7*ru,y+7*ru],Cpk(i),mgr(i));  %@@@
         PlotFacettes(o,facettes(i),[y-7*ru,y+7*ru],mincpk,mgr(i));    %@@@

         %x0 = max([Cpk(i),mgr(i),chk(i)]);                            %@@@

            % @@@ Above commented statement is as it is found in metrics.m,
            % but it is not the right way to do: we also need to consider 
            % the values of mycpk for xmax calculation, so let's get xmax 
            % by proper calculation!
            
         x0 = max([Cpk(i),mgr(i),chk(i),mycpk(i)]);

            % @@@ for Text plotting we must pass additional mycpk(i)
            
         % Text(o,m,i,x0,y,ru, objects{i},mgr(i),Cpk(i),chk(i));       %@@@
         Text(o,m,i,x0,y,ru, objects{i},mgr(i),Cpk(i),chk(i),mycpk(i));%@@@
     end

      scol = opt(o,{'spec.color','c'});
      hdl = plot(o,[1 1],get(gca,'Ylim'),[scol,'-.']);
      set(hdl,'Linewidth',opt(o,{'spec.linewidth',1}));

      package = get(o,{'package',''});
      title(['Magnitude Reserve (Mgr), Process Capability (Cpk)',...
             ' & Harmonic Capability (Chk)']);
      ylabel('Chk (g), Cpk (y), Mgr (r)');
   end
end

%==========================================================================
% Helpers
%==========================================================================

function PlotBar(o,len,pos,col)        % Plot a Bar                    
   x = [0 len len 0 0];
   y = [pos(1) pos(1) pos(2) pos(2) pos(1)];
   hdl = patch(x,y,o.color(col));
   hold on;
end
function PlotFacettes(o,nf,pos,cpk,mgr)% Plot a Bar                    
   if (cpk >= 1 && mgr >= 1)           % fully acceptable
      col = 'g1';                      % green!
   elseif (cpk > 1 && mgr < 1)         % marginally acceptable
      col = 'wk1';                     % gray!
   else                                % unacceptable
      col = 'r1';                      % red!
   end
   
      % plot number of facettes as number of colored bars
   
   y = [pos(1) pos(2)];
   for (i=1:nf)
      plot(o,-i*0.1*[1 1],[pos(1) pos(2)],col);
      hold on;
   end
end
function FontSize(o,m,hdl,delta)       % Set Font Size                 
   if (nargin < 4)
      delta = 0;
   end
   if (m <= 10)
      set(hdl,'FontSize',12+delta);
   elseif (m <= 20)
      set(hdl,'Fontsize',10+delta);
   elseif (m <= 40)
      set(hdl,'Fontsize',8+delta);
   elseif (m <= 60)
      set(hdl,'Fontsize',7+delta);
   else
      set(hdl,'Fontsize',6+delta);
   end
end
function Text(o,m,j,x,y,ru,objs,mgr,cpk,chk,mycpk)                     
%
% TEXT   @@@ Text has been modified with an additional metrics value,
%        (i.e. mycpk)
%
   uscore = util(o,'uscore');          % short hand
   name = uscore(objs);

      % @@@ extend txt0 by additional metrics value (mycpk)
      
   %txt0 = sprintf('Mgr: %g, Cpk: %g, Chk: %g',...                % @@@
   %              o.rd(mgr,2), o.rd(cpk,2), o.rd(chk,2));         % @@@
   txt0 = sprintf('Mgr: %g, Cpk: %g, MyCpk: %g, Chk: %g',...
                  o.rd(mgr,2), o.rd(cpk,2), o.rd(mycpk,2), o.rd(chk,2));
   txt1 = [' ',name];

      % get other data

   try
      index = var(o,'index');

      number = cache(o,'package.numbers');   number = number(index);
      number = number(j);

      station = cache(o,'package.station');  station = station(index);
      station = uscore(station{j});

      damping = cache(o,'package.damping');  damping = damping(index);
      damping = uscore(damping{j});

      kappl = cache(o,'package.kappl');    kappl = kappl(index);
      kappl = uscore(kappl{j});

      lage = cache(o,'package.lage');    lage = lage(index);
      lage = lage(j);

      vcut = cache(o,'package.vcut');    vcut = vcut(index);
      vcut = vcut(j);

      vseek = cache(o,'package.vseek');    vseek = vseek(index);
      vseek = vseek(j);
   catch
      number = NaN;  station = '';  damping = '';  kappl = '';
      lage = NaN;  vcut = NaN;  vseek = NaN;
      
      if type(o,{'cut'})
         station = uscore(get(o,{'station',''}));
         damping = uscore(get(o,{'damping',''}));
         kappl = uscore(get(o,{'kappl',''}));
         
         number = get(o,{'number',NaN});
         lage = get(o,{'lage',NaN});
         vcut = get(o,{'vcut',NaN});
         vseek = get(o,{'vseek',NaN});
      end
   end

   objid = sprintf(' %s.%g',get(o,{'package',''}),number);
   txt3 = sprintf([' station:%s, damping:%s, kappl:%s, lage:%g, ',...
                   'vcut:%g, vseek:%g'],...
                    station,damping,kappl,lage,vcut,vseek);
   txt2 = [' ',txt3,' (',txt0,')'];

   col = o.iif(dark(o),'w','k');
   
   sub = opt(o,{'subplot',[1 1 1]});
   M = m*sub(1);                       % artificial scaling
   
   if (M < 10)
      txt1 = [objid,':  ',txt1];
      
      hdl1 = text(x,y+5*ru,[' ',txt0]);
      hdl2 = text(x,y+0*ru,['',txt1]);
      hdl3 = text(x,y-5*ru,[' ',txt3]);

      set(hdl1,'Horizontal','left','Vertical','mid','Color',col);
      set(hdl2,'Horizontal','left','Vertical','mid','Color',o.color('yyk'));   
      set(hdl3,'Horizontal','left','Vertical','mid','Color',col);

      hdl = [hdl1(:); hdl2(:); hdl3(:)];
      FontSize(o,M,hdl);               % set proper font size
   elseif (M < 20)
      txt1 = [objid,':  ',txt1];
      
      hdl1 = text(x,y+3*ru,txt1);
      hdl2 = text(x,y-3*ru,txt2); 

      set(hdl1,'Horizontal','left','Vertical','mid','Color',o.color('yyk'));   
      set(hdl2,'Horizontal','left','Vertical','mid','Color',col);

      hdl = [hdl1(:); hdl2(:)];
      FontSize(o,M,hdl);         % set proper font size
   else
      txt = [objid,txt2];
      hdl = text(x,y,txt);

      set(hdl,'Horizontal','left','Vertical','mid','Color',col);
      FontSize(o,M,hdl);         % set proper font size
   end
end
function txt = Project(o)              % Get Project(s) Text           
   if ~container(o)
      txt = 'Metrics - Project Overview';
      return
   end
   uscore = util(o,'uscore');          % short hand
   
   projects = {};
   sep = '';  txt = '';
   for (i=1:length(o.data))
      oo = o.data{i};
      project = get(oo,{'project',''});
      
      if ~isempty(project) && ~o.is(project,projects)
         projects{end+1} = project;
         txt = [txt,sep,project]; sep = ', ';
      end
   end
   
   if isempty(txt)
      txt = 'Metrics - Project Overview';
   elseif (length(projects) == 1)
      txt = ['Metrics Overview - Project: ',txt];
   else
      txt = ['Metrics Overview - Projects: ',txt];
   end
   
      % add some heading tail
      
   tail = opt(o,'view.heading');
   if (~isempty(tail) && ~all(tail==' '))
      txt = [txt,'  (',tail,')'];
   end
end
