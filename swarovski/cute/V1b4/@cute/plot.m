function oo = plot(o,varargin)         % CUTE Plot Method              
%
% PLOT   CUTE plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: CUTE, DIAGRAM, METRICS
%
   [gamma,oo] = manage(o,varargin,@Plot,@About,@Menu,...
                       @WithCuo,@WithSho,@WithBasket,...
                       @OvwMagnitude,@Process,...
                       @Metrics,@CuttingEvolution,@KapplEvolution,...
                       @Cockpit,@Kappl,@Magnitude,@Orbit,@Evolution,...
                       @Zoom,@Shift);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   oo = current(o);
   switch oo.type                      % dispatch menu buildup on type
      case 'shell'
         oo = MenuShell(o);
      case 'article'
         oo = MenuArt(o);
      case {'pkg'}
         oo = MenuPkg(o);
      case {'mpl'}
         oo = MenuMpl(o);
      case 'cut'
         oo = MenuCut(o);
      otherwise
         oo = o;
         return
   end
end
function oo = MenuShell(o)             % Setup Plot Menu for SHELL Type
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'-');
   oo = mitem(o,'Metrics',{@WithSho,'Metrics'});
end
function oo = MenuArt(o)               % Setup Plot Menu for ART Type  
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'-');
   oo = mitem(o,'Metrics');
   enable(oo,false);
end
function oo = MenuPkg(o)               % Setup Plot Menu for PKG Type  
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'-');
   oo = mitem(o,'Metrics',{@WithCuo,'Metrics'});
end
function oo = MenuMpl(o)               % Setup Plot Menu for MPL Type  
   oo = mitem(o,'About',{@WithCuo,'About'});
   oo = mitem(o,'-');
   oo = mitem(o,'Metrics');
   enable(oo,false);
end
function oo = MenuCut(o)               % Setup Plot Menu for CUL Type  
%
% MENU  Setup plot menu. Note that plot functions are best invoked via
%       Callback or Basket functions, which do some common tasks
%
   oo = mitem(o,'About',{@WithCuo,'About'});
   %oo = mitem(o,'Overview',{@WithCuo,'Process'},'AO');
   oo = mitem(o,'Metrics',{@WithCuo,'Metrics'});

   oo = mitem(o,'-');

   oo = mitem(o,'Cockpit',{@WithCuo,'Cockpit'});
   
   oo = mitem(o,'-');

   oo = mitem(o,'Process');
   ooo = mitem(oo,'Acceleration Overview',{@WithCuo,'Process','AO'});
   ooo = mitem(oo,'Acceleration Magnitude',{@WithCuo,'Process'},'AM');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Acceleration 1 (Cut)',{@WithCuo,'Process'},'A1');
   ooo = mitem(oo,'Acceleration 2 (Cross)',{@WithCuo,'Process'},'A2');
   ooo = mitem(oo,'Acceleration 3 (Normal)',{@WithCuo,'Process'},'A3');
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Velocity Overview',{@WithCuo,'Process','VO'});
   ooo = mitem(oo,'Velocity Magnitude',{@WithCuo,'Process'},'VM');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Velocity 1 (Cut)',{@WithCuo,'Process'},'V1');
   ooo = mitem(oo,'Velocity 2 (Cross)',{@WithCuo,'Process'},'V2');
   ooo = mitem(oo,'Velocity 3 (Normal)',{@WithCuo,'Process'},'V3');

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Elongation Overview',{@WithCuo,'Process','SO'});
   ooo = mitem(oo,'Elongation Magnitude',{@WithCuo,'Process'},'SM');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Elongation 1 (Cut)',{@WithCuo,'Process'},'S1');
   ooo = mitem(oo,'Elongation 2 (Cross)',{@WithCuo,'Process'},'S2');
   ooo = mitem(oo,'Elongation 3 (Normal)',{@WithCuo,'Process'},'S3');
   
   oo = mitem(o,'Kappl');
   ooo = mitem(oo,'Acceleration Overview',{@WithCuo,'Kappl'},'AO');
   ooo = mitem(oo,'Acceleration Magnitude',{@WithCuo,'Kappl'},'AM');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Acceleration X',{@WithCuo,'Kappl'},'Ax');
   ooo = mitem(oo,'Acceleration Y',{@WithCuo,'Kappl'},'Ay');
   ooo = mitem(oo,'Acceleration Z',{@WithCuo,'Kappl'},'Az');
   
   oo = mitem(o,'Kolben');
   ooo = mitem(oo,'Acceleration Overview',{@WithCuo,'Kappl'},'BO');
   ooo = mitem(oo,'Acceleration Magnitude',{@WithCuo,'Kappl'},'BM');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'X-Acceleration',{@WithCuo,'Kappl'},'Bx');
   ooo = mitem(oo,'Y-Acceleration',{@WithCuo,'Kappl'},'By');
   ooo = mitem(oo,'Z-Acceleration',{@WithCuo,'Kappl'},'Bz');
   
      % Magnitude
      
   oo = mitem(o,'Magnitude');
   ooo = mitem(oo,'Acceleration',{@WithCuo,'Magnitude'},'A');
   ooo = mitem(oo,'Velocity',{@WithCuo,'Magnitude'},'V');
   ooo = mitem(oo,'Elongation',{@WithCuo,'Magnitude'},'S');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Kappl/Kolben',{@WithCuo,'Magnitude'},'C');

      % Separator
      
   ooo = mitem(oo,'-');

      % Orbit
   
   oo = mitem(o,'Orbit');
   ooo = mitem(oo,'Orbit Overview',{@WithCuo,'Orbit'},'O');
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Acceleration',{@WithCuo,'Orbit'},'A');
   ooo = mitem(oo,'Velocity',{@WithCuo,'Orbit'},'V');
   %enable(ooo,0);
   ooo = mitem(oo,'Elongation',{@WithCuo,'Orbit'},'S');
   %enable(ooo,0);

      % Evolution
      
   oo = mitem(o,'Evolution');
   ooo = mitem(oo,'Acceleration 1-2',{@WithCuo,'Evolution'},'A12');
   ooo = mitem(oo,'Acceleration 1-3',{@WithCuo,'Evolution'},'A13');
   ooo = mitem(oo,'Acceleration 2-3',{@WithCuo,'Evolution'},'A23');
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Velocity 1-2',{@WithCuo,'Evolution'},'V12');
   ooo = mitem(oo,'Velocity 1-3',{@WithCuo,'Evolution'},'V13');
   ooo = mitem(oo,'Velocity 2-3',{@WithCuo,'Evolution'},'V23');

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Elongation 1-2',{@WithCuo,'Evolution'},'S12');
   ooo = mitem(oo,'Elongation 1-3',{@WithCuo,'Evolution'},'S13');
   ooo = mitem(oo,'Elongation 2-3',{@WithCuo,'Evolution'},'S23');
end
function oo = Filter(o)                % Add Filter Menu Items         
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mseek(o,{'#','Select'});
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Filter');
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

%==========================================================================
% Launch Functions for Local Callback Functions
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% Sho    General callback for operation on shell object
%        with refresh function redefinition, screen
%        clearing, current object pulling and forwarding to executing
%        local function, reporting of irregularities, dark mode support
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
% CALLBACK   A general callback with refresh function redefinition, screen
%            clearing, current object pulling and forwarding to executing
%            local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   oo = current(o);                    % get current object
   
   if type(oo,{'article','cut','shell','pkg','mpl'})
      oo = opt(oo,'verbose',1);        % set verbose option
      gamma = eval(['@',mfilename]);
      oo = gamma(oo);                  % forward to executing method
   else
      oo = [];
   end

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
   end
   dark(o);                            % do dark mode actions
end
function oo = WithBasket(o)            % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket, screen clearing, 
%         current object pulling and forwarding to executing local func-
%         tion, reporting of irregularities and dark mode support
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
function oo = Current(o)                                               
   oo = current(o);
   switch type(oo)
      case 'cut'
         'OK';
      case 'pkg'
         menu(oo,'About');
         oo = [];
         return
      otherwise
         oo = [];
         return
   end
   
      % look for non-empty cache! If empty then brew and refresh
      % current object
      
   [oo,bag,rfr] = cache(oo,oo,'brew'); % hard refresh of brew cache segment
end

%==========================================================================
% Default Plot Functions
%==========================================================================

function oo = Plot(o)                  % Default Plot                  
%
% PLOT The default Plot function shows how to deal with different object
%      types. Depending on type a different local plot function is invoked
%
   oo = plot(corazon,o);               % if arg list is for corazon/plot
   if ~isempty(oo)                     % is oo an array of graph handles?
      oo = []; return                  % in such case we are done - bye!
   end
   
      % continue dispatching on type

   cls(o);                             % clear screen
   switch o.type
      case 'cut'
         oo = Cockpit(o);
      case 'pkg'
         oo = About(o);
      otherwise
         oo = [];  return              % no idea how to plot
   end
end

%==========================================================================
% Plot About Object
%==========================================================================

function oo = About(o)                 % About Object                  
   if type(o,{'shell'})
      oo = menu(corazon(o),'About');
      refresh(oo,oo);                  % here to refresh!
      return
   end
   
   comment = get(o,{'comment',{}});    % get actual comment
   comment = PropertyList(o);
   oo = set(o,'comment',comment);
   message(oo);
   
   function list = PropertyList(o)     % Construct Property List       
      switch o.type
         case {'pkg','mpl'}
            list = PkgProperties(o);
         case 'cut'
            list = CutProperties(o);            
         case 'article'
            list = ArtProperties(o);            
         otherwise
            list = {};
      end
      
      list{end+1} = '  ';
      
      list = Add(o,list,'file','');
      list = Add(o,list,'dir','');
   end
   function list = PkgProperties(o)    % Get Package Property List     
      list = get(o,{'comment',{}});

      list{end+1} = '  ';
      
      list{end+1} = ['Type: package info object (',o.type,')'];
      list = Add(o,list,'oid','');
      list = Add(o,list,'package','');
      list = Add(o,list,'project','');
      list = Add(o,list,'machine','');
      list = AddStringRow(o,list,'article');

      list{end+1} = '  ';

      list = AddStringRow(o,list,'station');
      list = AddStringRow(o,list,'apparatus');
      list = AddStringRow(o,list,'damping');
      
      damping = list{end};
      list(end) = [];
      
      list = AddStringRow(o,list,'kappl');
      
      kappl = list{end};
      list{end} = [damping,',  ',kappl];
      
      
      list = AddNumberRow(o,list,'vcut');
      list = AddNumberRow(o,list,'vseek');
      list = AddNumberRow(o,list,'lage');
   end
   function list = CutProperties(o)    % Get Cut Property List         
      list = {['Type: cutting process data object (',o.type,')']};
      list = Add(o,list,'oid','');
      list = Add(o,list,'package','');
      list = Add(o,list,'project','');
      list = Add(o,list,'machine','');

      list{end+1} = '  ';

      list = Add(o,list,'station','');
      list = Add(o,list,'apparatus','');
      list = Add(o,list,'damping','');
      damping = list{end};
      list(end) = [];
      list = Add(o,list,'kappl','');
      list{end} = [damping,',  ',list{end}];
      
      list = Add(o,list,'vcut',nan);
      list = Add(o,list,'vseek',nan);
      list = Add(o,list,'lage',0);
      lage = list{end};
      list(end) = [];
      list = Add(o,list,'theta',0);
      list{end} = [lage,',  ',list{end}];
      
      list{end+1} = sprintf('facettes: %g',cluster(o,inf)); 
   end
   function list = ArtProperties(o)    % Get Article Property List     
      list = {'Type: article object (article)'};
      list = Add(o,list,'glass','');
      list = AddRow(o,list,'par.facette5');
      list = AddRow(o,list,'par.facette6');
      list = AddRow(o,list,'par.facette7');
      list = AddRow(o,list,'data.lage');
      list = AddRow(o,list,'data.angle');
   end
   function list = Add(o,list,tag,def) % Add Property List Item        
      value = get(o,{tag,def});
      
      if isa(value,'double')
         txt = sprintf('%s: %g',tag,value);
      elseif ischar(value)
         txt = sprintf('%s: %s',tag,value);
      else
         txt = '';
      end
      
      if ~isempty(txt)
         list{end+1} = txt;
      end
   end
   function list = AddRow(o,list,tag)  % Add a Row                     
      name = tag;
      idx = find(name=='.');
      name(1:idx(1)) = '';
      
      txt = [name,': ['];
      value = prop(o,tag);
      sep = '';
      for (i=1:length(value))
         txt = [txt,sep,sprintf('%g',value(i))];  sep = ' ';
      end
      txt = [txt,']'];
      list{end+1} = txt;
   end
   function list = AddNumberRow(o,list,tag)  % Add Row With Numbers    
      name = tag;
      idx = find(name=='.');
      if o.is(idx)
         name(1:idx(1)) = '';
      end
      
      values = UniqueNumbers(o,get(o,tag));
      
      if (length(values) == 1)
         txt = sprintf('%s: %g',name,values);
      else
         txt = [name,': '];
         sep = '';  mind = {};
         for (i=1:length(values))
            txt = [txt,sep,sprintf('%g',values(i))];  sep = ', ';
         end
      end
      
      list{end+1} = txt;
   end
   function list = AddStringRow(o,list,tag)  % Add Row With Strings    
      name = tag;
      idx = find(name=='.');
      if o.is(idx)
         name(1:idx(1)) = '';
      end
      
      values = get(o,tag);
      values = UniqueStrings(o,values);
      
      if (length(values) == 1 && ischar(values))
         txt = sprintf('%s: %s',name,values);
      elseif (length(values) == 1 && iscell(values))
         txt = sprintf('%s: %s',name,values{1});
      else
         txt = [name,': '];
         sep = '';  mind = {};
         for (i=1:length(values))
            txt = [txt,sep,sprintf('%s',values{i})];  sep = ', ';
         end
         txt = [txt,''];
      end
      
      list{end+1} = txt;
   end
   function out = UniqueNumbers(o,values)                              
      assert(isa(values,'double'));
      
      if (length(values) <= 1)
         out = values;
         return
      end
      
      values = values(:);  out = [];  mind = {};
      
      for (i=1:length(values))
         val = values(i);
         sval = sprintf('%g',val);
         if ~o.is(sval,mind)
            out(1,end+1) = val;
            mind{end+1} = sval;
         end
      end
      
      out = sort(out);
   end
   function out = UniqueStrings(o,values)                              
      if (length(values) <= 1)
         out = values;
         return
      end
      
      assert(isa(values,'char')||iscell(values));

      values = values(:);  out = [];  mind = {};
      
      for (i=1:length(values))
         val = values{i};
         if ~o.is(val,mind)
            out{1,end+1} = val;
            mind{end+1} = val;
         end
      end
      
      out = sort(out);
   end
end

%==========================================================================
% Cockpit, Raw & Orbit
%==========================================================================

function oo = Cockpit(o)               % plot velocity and elongation  
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   uscore = util(o,'uscore');
   mode = arg(o,1);
   
   oo = Current(o);
   oo = opt(oo,'metrics',false);       % don't show metrics in diagrams
   
   t  = cook(oo,'t');
   a1 = cook(oo,'a1');
   a2 = cook(oo,'a2');
   a3 = cook(oo,'a3');
   v1 = cook(oo,'v1');
   v2 = cook(oo,'v2');
   v3 = cook(oo,'v3');
   s1 = cook(oo,'s1');
   s2 = cook(oo,'s2');
   s3 = cook(oo,'s3');

      % index 1 plots

   diagram(oo,'A1',t,a1,[3 4 1]);
   diagram(oo,'V1',t,v1,[3 4 5]);
   diagram(oo,'S1',t,s1,[3 4 9]);
   xlabel('time [s]');
   
      % index 2 plots

   diagram(oo,'A2',t,a2,[3 4 2]);
   diagram(oo,'V2',t,v2,[3 4 6]);
   diagram(oo,'S2',t,s2,[3 4 10]);
   xlabel('time [s]');
   
      % index 3 plots

   diagram(oo,'A3',t,a3,[3 4 3]);
   diagram(oo,'V3',t,v3,[3 4 7]);
   diagram(oo,'S3',t,s3,[3 4 11]);
   xlabel('time [s]');
   
      % x/y plots

   diagram(oo,'A12',a1,a2,[3 4 4]);
   if isequal(opt(o,'analyse.select.scaling'),'same');
      maxi = max(max(abs(ax)),max(abs(ay)));
      %set(gca,'xlim',[-maxi maxi],'ylim',[-maxi maxi]);
   end
   
   diagram(oo,'V12',v1,v2,[3 4 8]);
   if isequal(opt(o,'analyse.select.scaling'),'same');
      %maxi = max(max(abs(vx)),max(abs(vy)));
      %set(gca,'xlim',[-maxi maxi],'ylim',[-maxi maxi]);
   end
   
   diagram(oo,'S12',s1,s2,[3 4 12]);
   if isequal(opt(o,'analyse.select.scaling'),'same');
      %maxi = max(max(abs(sx)),max(abs(sy)));
      %set(gca,'xlim',[-maxi maxi],'ylim',[-maxi maxi]);
   end
   
   closeup(oo,{mfilename,'Zoom'},{mfilename,'Shift'});
   menu(oo,'Heading');
end
function oo = Process(o)               % Plot 1-2-3 Data               
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   uscore = util(o,'uscore');
   mode = arg(o,1);
   
   oo = Current(o);
   
   switch mode
      case 'A'         
         t = cook(oo,':','stream');
         a1 = cook(oo,'a1','stream');  % fetch cutting acceleration 1
         a2 = cook(oo,'a2','stream');  % fetch cutting acceleration 2
         a3 = cook(oo,'a3','stream');  % fetch cutting acceleration 3
         
         diagram(oo,'A1',t,a1,[3 3 1]);
         diagram(oo,'A2',t,a2,[3 3 4]);
         diagram(oo,'A3',t,a3,[3 3 7]);

         diagram(oo,'A13',a1,a3,[3 6 3]);  Orbit(o,'','','a3 (a1)');
         diagram(oo,'A12',a1,a2,[3 6 9]);  Orbit(o,'','','a2 (a1)');
         diagram(oo,'A23',a2,a3,[3 6 15]); Orbit(o,'','','a3 (a2)');
         
         oo = opt(oo,'spec.mode',0);
         
         diagram(oo,'A13',a1,a3,[3 6 4]);  Orbit(o,'','','a3 (a1)');
         diagram(oo,'A12',a1,a2,[3 6 10]); Orbit(o,'','','a2 (a1)');
         diagram(oo,'A23',a2,a3,[3 6 16]); Orbit(o,'','','a3 (a2)');
         
         diagram(oo,'A1',t,a1,[3 3 3]);
         diagram(oo,'A2',t,a2,[3 3 6]);
         diagram(oo,'A3',t,a3,[3 3 9]);
         
      case 'AO'         
         t = cook(oo,':','stream');
         a1 = cook(oo,'a1','stream');  % fetch cutting acceleration 1
         a2 = cook(oo,'a2','stream');  % fetch cutting acceleration 2
         a3 = cook(oo,'a3','stream');  % fetch cutting acceleration 3
         a = cook(oo,'a');
         
         diagram(oo,'A1',t,a1,[4 2 1]);
         diagram(oo,'A2',t,a2,[4 2 3]);
         diagram(oo,'A3',t,a3,[4 2 5]);
         diagram(oo,'A', t,a, [4 2 7]);   

         diagram(oo,'A13',a1,a3,[2 2 2]);  Stretch(o);
         %shelf(oo,gca,'t',t);         % for closeup debug
         
         diagram(oo,'A12',a1,a2,[2 2 4]);  Stretch(o);
         %shelf(oo,gca,'t',t);         % for closeup debug

      case 'AM'
         t = cook(oo,':','stream');
         a = cook(oo,'a');
         %diagram(oo,'Ar',t,ar,[2 1 1]);   
         diagram(oo,'A',t,a,[2 1 1]);   
         oo = opt(oo,'spec.mode',0);
         %diagram(oo,'Ar',t,ar,[2 1 2]);   
         diagram(oo,'A',t,a,[2 1 2]);   

      case 'A1'         
         t = cook(oo,':','stream');
         a1 = cook(oo,'a1','stream'); % fetch cutting acceleration 1         
         diagram(oo,'A1',t,a1,[1 1 1]);
      case 'A2'         
         t = cook(oo,':','stream');
         a2 = cook(oo,'a2','stream'); % fetch cutting acceleration 2         
         diagram(oo,'A2',t,a2,[1 1 1]);
      case 'A3'         
         t = cook(oo,':','stream');
         a3 = cook(oo,'a3','stream'); % fetch cutting acceleration 3         
         diagram(oo,'A3',t,a3,[1 1 1]);

            % Kappl acceleration
            
      case 'B'
         assert(0);
         t = cook(oo,':','stream');
         bx = cook(oo,'bx#','stream'); % fetch raw kappl acceleration x
         by = cook(oo,'by#','stream'); % fetch raw kappl acceleration y
         bz = cook(oo,'bz#','stream'); % fetch raw kappl acceleration z
         
         diagram(oo,'Bx',t,bx,[3 1 1]);
         diagram(oo,'By',t,by,[3 1 2]);
         diagram(oo,'Bz',t,bz,[3 1 3]);
      case 'B1'         
         assert(0);
         t = cook(oo,':','stream');
         bx = cook(oo,'bx#','stream'); % fetch raw kolben acceleration x         
         diagram(oo,'Bx',t,bx,[1 1 1]);
      case 'B2'         
         assert(0);
         t = cook(oo,':','stream');
         by = cook(oo,'by#','stream'); % fetch raw kolben acceleration y         
         diagram(oo,'By',t,by,[1 1 1]);
      case 'B3'         
         assert(0);
         t = cook(oo,':','stream');
         bz = cook(oo,'bz#','stream'); % fetch raw kolben acceleration z         
         diagram(oo,'Bz',t,bz,[1 1 1]);

            % cutting velocity
            
      case 'VO'         
         t = cook(oo,':','stream');
         v1 = cook(oo,'v1','stream');  % fetch cutting velocity 1
         v2 = cook(oo,'v2','stream');  % fetch cutting velocity 2
         v3 = cook(oo,'v3','stream');  % fetch cutting velocity 3
         v = cook(oo,'v');
         
         diagram(oo,'V1',t,v1,[4 2 1]);
         diagram(oo,'V2',t,v2,[4 2 3]);
         diagram(oo,'V3',t,v3,[4 2 5]);
         diagram(oo,'V', t,v, [4 2 7]);   

         diagram(oo,'V13',v1,v3,[2 2 2]);  Stretch(o);
         diagram(oo,'V12',v1,v2,[2 2 4]);  Stretch(o);

      case 'VM'
         t = cook(oo,':','stream');
         v = cook(oo,'v');
         diagram(oo,'V',t,v,[2 1 1]);   
         oo = opt(oo,'spec.mode',0);
         diagram(oo,'V',t,v,[2 1 2]);   

      case 'V1'         
         t = cook(oo,':','stream');
         v1 = cook(oo,'v1','stream'); % fetch cutting velocity 1         
         diagram(oo,'V1',t,v1,[1 1 1]);
      case 'V2'         
         t = cook(oo,':','stream');
         v2 = cook(oo,'v2','stream'); % fetch cutting velocity 2         
         diagram(oo,'V2',t,v2,[1 1 1]);
      case 'V3'         
         t = cook(oo,':','stream');
         v3 = cook(oo,'v3','stream'); % fetch cutting velocity 3         
         diagram(oo,'V3',t,v3,[1 1 1]);

            % cutting elongation
            
      case 'SO'         
         t = cook(oo,':','stream');
         s1 = cook(oo,'s1','stream');  % fetch cutting elongation 1
         s2 = cook(oo,'s2','stream');  % fetch cutting elongation 2
         s3 = cook(oo,'s3','stream');  % fetch cutting elongation 3
         s = cook(oo,'s');
         
         diagram(oo,'S1',t,s1,[4 2 1]);
         diagram(oo,'S2',t,s2,[4 2 3]);
         diagram(oo,'S3',t,s3,[4 2 5]);
         diagram(oo,'S', t,s, [4 2 7]);   

         diagram(oo,'S13',s1,s3,[2 2 2]);  Stretch(o);
         diagram(oo,'S12',s1,s2,[2 2 4]);  Stretch(o);

      case 'SM'
         t = cook(oo,':','stream');
         s = cook(oo,'s');
         diagram(oo,'S',t,s,[2 1 1]);   
         oo = opt(oo,'spec.mode',0);
         diagram(oo,'S',t,s,[2 1 2]);   

      case 'S1'         
         t = cook(oo,':','stream');
         s1 = cook(oo,'s1','stream'); % fetch cutting elongation 1         
         diagram(oo,'S1',t,s1,[1 1 1]);
      case 'S2'         
         t = cook(oo,':','stream');
         s2 = cook(oo,'s2','stream'); % fetch cutting elongation 2         
         diagram(oo,'S2',t,s2,[1 1 1]);
      case 'S3'         
         t = cook(oo,':','stream');
         s3 = cook(oo,'s3','stream'); % fetch cutting elongation 3         
         diagram(oo,'S3',t,s3,[1 1 1]);
      
      otherwise
         message(o);
   end
   
   closeup(oo,{mfilename,'Zoom'},{mfilename,'Shift'});
   menu(oo,'Heading');
   
   function Orbit(o,xlab,ylab,tit)     % Re-label Orbit Plots          
      xlabel(xlab);
      ylabel(ylab);
      title(tit);
      shelf(o,gca,'closeup',0);        % prevent from closeup control
   end
end
function oo = Kappl(o)                 % plot raw data                 
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   uscore = util(o,'uscore');
   mode = arg(o,1);
   
   oo = Current(o);
   
   switch mode
      case 'A'         
         t = cook(oo,':','stream');
         ax = cook(oo,'ax#','stream'); % fetch raw kappl acceleration x
         ay = cook(oo,'ay#','stream'); % fetch raw kappl acceleration y
         az = cook(oo,'az#','stream'); % fetch raw kappl acceleration z
         
         diagram(oo,'Ax',t,ax,[3 1 1]);
         diagram(oo,'Ay',t,ay,[3 1 2]);
         diagram(oo,'Az',t,az,[3 1 3]);
      case 'AM'
         t = cook(oo,':','stream');
         ar = cook(oo,'ar');
         diagram(oo,'Ar',t,ar,[2 1 1]);   
         oo = opt(oo,'spec.mode',0);
         diagram(oo,'Ar',t,ar,[2 1 2]);   
      case 'AO'         
         t = cook(oo,':','stream');
         ax = cook(oo,'ax','stream'); % fetch cutting acceleration 1
         ay = cook(oo,'ay','stream'); % fetch cutting acceleration 2
         az = cook(oo,'az','stream'); % fetch cutting acceleration 3
         ar = cook(oo,'ar');
         
         diagram(oo,'Ay',t,ax,[4 2 1]);
         diagram(oo,'Ay',t,ay,[4 2 3]);
         diagram(oo,'Az',t,az,[4 2 5]);
         diagram(oo,'Ar',t,ar,[4 2 7]);   

         diagram(oo,'Axz',ax,az,[2 2 2]);  Stretch(o);
         diagram(oo,'Axy',ax,ay,[2 2 4]);  Stretch(o);
      case 'Ax'         
         t = cook(oo,':','stream');
         ax = cook(oo,'ax','stream'); % fetch raw kappl acceleration x         
         diagram(oo,'Ax',t,ax,[1 1 1]);
      case 'Ay'         
         t = cook(oo,':','stream');
         ay = cook(oo,'ay','stream'); % fetch raw kappl acceleration y         
         diagram(oo,'Ay',t,ay,[1 1 1]);
      case 'Az'         
         t = cook(oo,':','stream');
         az = cook(oo,'az','stream'); % fetch raw kappl acceleration z         
         diagram(oo,'Az',t,az,[1 1 1]);

      case 'B'         
         t = cook(oo,':','stream');
         bx = cook(oo,'bx#','stream'); % fetch raw kappl acceleration x
         by = cook(oo,'by#','stream'); % fetch raw kappl acceleration y
         bz = cook(oo,'bz#','stream'); % fetch raw kappl acceleration z
         
         diagram(oo,'Bx',t,bx,[3 1 1]);
         diagram(oo,'By',t,by,[3 1 2]);
         diagram(oo,'Bz',t,bz,[3 1 3]);
      case 'BM'
         t = cook(oo,':','stream');
         br = cook(oo,'br#');
         diagram(oo,'Br',t,br,[2 1 1]);   
         oo = opt(oo,'spec.mode',0);
         diagram(oo,'Br',t,br,[2 1 2]);   
      case 'BO'         
         t = cook(oo,':','stream');
         bx = cook(oo,'bx#','stream'); % fetch kolben acceleration x
         by = cook(oo,'by#','stream'); % fetch kolben acceleration y
         bz = cook(oo,'bz#','stream'); % fetch kolben acceleration z
         br = cook(oo,'br#');
         
         diagram(oo,'By',t,bx,[4 2 1]);
         diagram(oo,'By',t,by,[4 2 3]);
         diagram(oo,'Bz',t,bz,[4 2 5]);
         diagram(oo,'Br',t,br,[4 2 7]);   

         diagram(oo,'Bxz',bx,bz,[2 2 2]);  Stretch(o);
         diagram(oo,'Bxy',bx,by,[2 2 4]);  Stretch(o);
      case 'Bx'         
         t = cook(oo,':','stream');
         bx = cook(oo,'bx#','stream'); % fetch raw kolben acceleration x         
         diagram(oo,'Bx',t,bx,[1 1 1]);
      case 'By'         
         t = cook(oo,':','stream');
         by = cook(oo,'by#','stream'); % fetch raw kolben acceleration y         
         diagram(oo,'By',t,by,[1 1 1]);
      case 'Bz'         
         t = cook(oo,':','stream');
         bz = cook(oo,'bz#','stream'); % fetch raw kolben acceleration z         
         diagram(oo,'Bz',t,bz,[1 1 1]);

      otherwise
         message(o);
   end
   
   closeup(oo,'Setup');
   menu(oo,'Heading');
   
   function Orbit(o,xlab,ylab,tit)     % Re-label Orbit Plots          
      xlabel(xlab);
      ylabel(ylab);
      title(tit);
      shelf(o,gca,'closeup',0);        % prevent from closeup control
   end
   function Stretch(o)                 % Stretch Orbit Plot            
      ylim = get(gca,'Ylim');
      set(gca,'Xlim',ylim*1.5);
      shelf(o,gca,'closeup',0);        % prevent from closeup control
   end
end
function oo = Magnitude(o)             % X/Y Stream Plot of Magnitude  
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   mode = arg(o,1);
   oo = Current(o);

   t = cook(oo,':','stream');
%  cls(o);
      
      % x/y plots

   switch mode
      case 'A'
         ar = cook(oo,'ar');
         diagram(oo,'Ar',t,ar,[1 1 1]);   
         
      case 'V'
         vr = cook(oo,'vr');
         diagram(oo,'Vr',t,vr,[1 1 1]);
         
      case 'S'
         sr = cook(oo,'sr');
         diagram(oo,'Sr',t,sr,[1 1 1]);
         
      case 'C'
         ar = cook(oo,'ar');
         diagram(oo,'Ar',t,ar,[3 1 1]);

         br = cook(oo,'br');
         diagram(oo,'Br',t,br,[3 1 2]);

         cr = ar.*br;
         diagram(oo,'Cr',t,cr,[3 1 3]);
         c = cov(ar/std(ar),br/std(br));
         xlabel(sprintf('Cross Correlation: %g%%',round(1000*c(1,2))/10));
         plot(get(gca,'xlim'),+500*[1 1],'k-.');
         plot(get(gca,'xlim'),-500*[1 1],'k-.');
   end
end

function oo = OrbitRaw(o)              % X/Y Orbit Plot                
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   mode = arg(o,1);
   oo = Current(o);
      
      % x/y plots

   switch mode
      case 'A'
         OrbitA(o);
   
      case 'V'
         vx = cook(oo,'vx','stream');
         vy = cook(oo,'vy','stream');
         diagram(oo,'Vxy',vx,vy,[1 1 1]);
   
      case 'S'
         sx = cook(oo,'sx','stream');
         sy = cook(oo,'sy','stream');
         diagram(oo,'Sxy',sx,sy,[1 1 1]);

      case 'AV'
         OrbitAV(o)
   end
   
   menu(oo,'Heading');
   
   function OrbitA(o)                  % Acceleration
      ax = cook(oo,'ax','stream');
      ay = cook(oo,'ay','stream');
      az = cook(oo,'az','stream');
 
      O{1} = diagram(oo,'Axy',ax,ay,[1 3 1]);
      O{2} = diagram(oo,'Axz',ax,az,[1 3 3]);
      O{3} = diagram(oo,'Azy',az,ay,[1 3 2]);

      Equalize(O);
   end
   function OrbitAV(o)                 % Acceleration/Velocity Orbits  
      ax = cook(oo,'ax','stream');
      ay = cook(oo,'ay','stream');
      az = cook(oo,'az','stream');

      O{1} = diagram(oo,'Axy',ax,ay,[2 3 1]);
      O{2} = diagram(oo,'Axz',ax,az,[2 3 4]);
      O{3} = diagram(oo,'Azy',az,ay,[2 3 2]);
      
      Equalize(O);

      vx = cook(oo,'vx','stream');
      vy = cook(oo,'vy','stream');
      vz = cook(oo,'vz','stream');

      O{1} = diagram(oo,'Vxy',vx,vy,[2 3 6]);
      O{2} = diagram(oo,'Vxz',vx,vz,[2 3 3]);
      O{3} = diagram(oo,'Vzy',vz,vy,[2 3 5]);
      
      Equalize(O);
   end
   function Equalize(O)                % Equalize Axes Limits          
      lim = 0;
      for (i=1:length(O))
         hax = var(O{i},'hax');
         maxi = max(max(abs(get(hax,'xlim'))),max(abs(get(hax,'ylim'))));
         lim = max(lim,maxi);
      end
      for (i=1:length(O))
         hax = var(O{i},'hax');
         set(hax,'xlim',lim*[-1 1],'ylim',lim*[-1 1]);
      end
   end
end
function oo = Orbit(o)                 % 1-2-3 Orbit Plot              
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   mode = arg(o,1);
   oo = Current(o);
      
      % x/y plots

   switch mode
      case 'A'
         OrbitA(o);
   
      case 'V'
         OrbitV(o);
  
      case 'S'
         OrbitS(o);

      case 'AV'
         OrbitAV(o)

      case 'O'                         % orbit overview
         OrbitO(o)
   end
   
   menu(oo,'Heading');
   
   function OrbitA(o)                  % Acceleration
      a1 = cook(oo,'a1');
      a2 = cook(oo,'a2');
      a3 = cook(oo,'a3');
 
      O{1} = diagram(oo,'A12',a1,a2,[1 3 1]);
      O{3} = diagram(oo,'A32',a3,a2,[1 3 2]);
      O{2} = diagram(oo,'A13',a1,a3,[1 3 3]);

      Equalize(O);
   end
   function OrbitV(o)                  % Velocity
      v1 = cook(oo,'v1');
      v2 = cook(oo,'v2');
      v3 = cook(oo,'v3');
 
      O{1} = diagram(oo,'V12',v1,v2,[1 3 1]);
      O{3} = diagram(oo,'V32',v3,v2,[1 3 2]);
      O{2} = diagram(oo,'V13',v1,v3,[1 3 3]);

      Equalize(O);
   end
   function OrbitS(o)                  % Elongation
      s1 = cook(oo,'s1');
      s2 = cook(oo,'s2');
      s3 = cook(oo,'s3');
 
      O{1} = diagram(oo,'S12',s1,s2,[1 3 1]);
      O{3} = diagram(oo,'S32',s3,s2,[1 3 2]);
      O{2} = diagram(oo,'S13',s1,s3,[1 3 3]);

      Equalize(O);
   end
   function OrbitAV(o)                 % Acceleration/Velocity Orbits  
      ax = cook(oo,'ax','stream');
      ay = cook(oo,'ay','stream');
      az = cook(oo,'az','stream');

      O{1} = diagram(oo,'Axy',ax,ay,[2 3 1]);
      O{2} = diagram(oo,'Axz',ax,az,[2 3 4]);
      O{3} = diagram(oo,'Azy',az,ay,[2 3 2]);
      
      Equalize(O);

      vx = cook(oo,'vx','stream');
      vy = cook(oo,'vy','stream');
      vz = cook(oo,'vz','stream');

      O{1} = diagram(oo,'Vxy',vx,vy,[2 3 6]);
      O{2} = diagram(oo,'Vxz',vx,vz,[2 3 3]);
      O{3} = diagram(oo,'Vzy',vz,vy,[2 3 5]);
      
      Equalize(O);
   end
   function OrbitO(o)                  % Orbit Overview                
      a1 = cook(oo,'a1');
      a2 = cook(oo,'a2');
      a3 = cook(oo,'a3');

      O{1} = diagram(oo,'A12',a1,a2,[3 3 1]);
      O{2} = diagram(oo,'A13',a1,a3,[3 3 2]);
      O{3} = diagram(oo,'A32',a3,a2,[3 3 3]);
      
      Equalize(O);

      v1 = cook(oo,'v1');
      v2 = cook(oo,'v2');
      v3 = cook(oo,'v3');

      O{1} = diagram(oo,'V12',v1,v2,[3 3 4]);
      O{2} = diagram(oo,'V13',v1,v3,[3 3 5]);
      O{3} = diagram(oo,'V32',v3,v2,[3 3 6]);
      
      Equalize(O);

      s1 = cook(oo,'s1');
      s2 = cook(oo,'s2');
      s3 = cook(oo,'s3');

      O{1} = diagram(oo,'S12',s1,s2,[3 3 7]);
      O{2} = diagram(oo,'S13',s1,s3,[3 3 8]);
      O{3} = diagram(oo,'S32',s3,s2,[3 3 9]);
      
      Equalize(O);
   end
   function Equalize(O)                % Equalize Axes Limits          
      lim = 0;
      for (i=1:length(O))
         hax = var(O{i},'hax');
         maxi = max(max(abs(get(hax,'xlim'))),max(abs(get(hax,'ylim'))));
         lim = max(lim,maxi);
      end
      for (i=1:length(O))
         hax = var(O{i},'hax');
         set(hax,'xlim',lim*[-1 1],'ylim',lim*[-1 1]);
      end
   end
end

%==========================================================================
% Evolution
%==========================================================================

function oo = Evolution(o)             % Evolution of Orbits           
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   oo = CuttingEvolution(o);
end
function oo = CuttingEvolution(o)      % Evolution of Orbits           
   mode = arg(o,1);
   scaling = opt(o,{'select.scaling','same'});
   
   oo = Current(o);
   
   index = cache(oo,'cluster.index');
   
   cls(o);
   
   t = cook(oo,'t');
   
   a1 = cook(oo,'a1');
   a2 = cook(oo,'a2');
   a3 = cook(oo,'a3');
   
   v1 = cook(oo,'v1');
   v2 = cook(oo,'v2');
   v3 = cook(oo,'v3');

   s1 = cook(oo,'s1');
   s2 = cook(oo,'s2');
   s3 = cook(oo,'s3');
   
      % define layout parameters
      
   m = 3;  n = 6;  extra = 1;
   M = 0;  N = m*n + 2*M;

      % plot top 3 diagrams
   
   switch mode
      case 'A12'
         type1 = mode;  type2 = 'A';  xx = a1;  yy = a2;
         spec = opt(o,'spec.a');
      case 'A13'
         type1 = mode;  type2 = 'A';  xx = a1;  yy = a3;
         spec = opt(o,'spec.a');
      case 'A23'
         type1 = mode;  type2 = 'A';  xx = a2;  yy = a3;
         spec = opt(o,'spec.a');
         
      case 'V12'
         type1 = mode;  type2 = 'V';  xx = v1;  yy = v2;
         spec = opt(o,'spec.v');
      case 'V13'
         type1 = mode;  type2 = 'V';  xx = v1;  yy = v3;
         spec = opt(o,'spec.v');
      case 'V23'
         type1 = mode;  type2 = 'V';  xx = v2;  yy = v3;
         spec = opt(o,'spec.v');
        
      case 'S12'
         type1 = mode;  type2 = 'S';  xx = s1;  yy = s2;
         spec = opt(o,'spec.s');
      case 'S13'
         type1 = mode;  type2 = 'S';  xx = s1;  yy = s3;
         spec = opt(o,'spec.s');
      case 'S23'
         type1 = mode;  type2 = 'S';  xx = s2;  yy = s3;
         spec = opt(o,'spec.s');
   end
   switch opt(o,'spec.mode')
      case 0
         spec = 0;
      case 1
         spec = spec(1);
      case 2
         spec = spec(2);
   end
   
   %oo = opt(o,'metrics',false);        % don't add metrics on title
   Info(oo,[m+extra,3,1]);
   
   diagram(oo,mode([1 2]),t,xx,[m+extra,3,2]);
   diagram(oo,mode([1 3]),t,yy,[m+extra,3,3]);

      % get index
      
   [index,t] = cluster(oo);
   
      % plot evolution of orbits
      
   maxi = 0;
   for (i=1:m*n)
      bdx = Chunk(o,index,N,i+M);
      x = xx(bdx);  y = yy(bdx);      
      x = x-mean(x);  y = y-mean(y);  
      
      t1 = o.rd(t(bdx(1)),2);
      t2 = o.rd(t(bdx(end)),2);
      
      if isequal(scaling,'same')
         ooo = diagram(oo,type1,x,y,[m+extra n i+n]);
         set(gca,'DataAspectRatio',[1 1 1]);
      else
         oo = opt(oo,'spec',[]);   % no spec drawing
         ooo = diagram(oo,type1,x,y,[m+extra n i+n]);
      end
      
      phi = var(ooo,{'phi',NaN});
      if (isnan(phi) || ~opt(o,{'view.ellipse',0}))
         title(sprintf('%g ... %g',t1,t2));
      else
         title(sprintf('%g ... %g (%g°)',t1,t2,o.rd(phi,0)));
      end
      
      shg;  pause(0.01);
      
      maxi = max(maxi,max(max(abs(x)),max(abs(y))));
   end
   
   if isequal(scaling,'same')
      for (i=1:m*n)
         subplot(m+extra,n,i+n);
         maxi = max(maxi,spec*5.5/5);
         set(gca,'xlim',[-maxi maxi],'ylim',[-maxi maxi]);
      end
   end
end
function oo = KapplEvolution(o)        % Evolution of Orbits           
   mode = arg(o,1);
   scaling = opt(o,{'analyse.select.scaling','same'});
   
   refresh(o,o);
   oo = Current(o);
   
   index = cache(oo,'cluster.index');
   
   cls(o);
   
   t = cook(oo,'t');
   %[vx,sx,ax] = velocity(oo,oo.data.ax,t);
   %[vy,sy,ay] = velocity(oo,oo.data.ay,t);
   
   ax = cook(oo,'ax');
   ay = cook(oo,'ay');
   az = cook(oo,'az');

      % define layout parameters
      
   m = 3;  n = 6;  extra = 1;
   %M = 20;  N = m*n + 3*M;
   M = 0;  N = m*n + 2*M;

      % plot top 3 diagrams
   
   switch mode
      case 'A'
         type1 = 'AXY';  type2 = 'A';  xx = ax;  yy = ay;
         spec = opt(o,'spec.a');
      case 'V'
         type1 = 'VXY';  type2 = 'V';  xx = vx;  yy = vy;
         spec = opt(o,'spec.v');
      case 'S'
         type1 = 'SXY';  type2 = 'S';  xx = sx;  yy = sy;
         spec = opt(o,'spec.s');
   end
   switch opt(o,'spec.mode')
      case 0
         spec = 0;
      case 1
         spec = spec(1);
      case 2
         spec = spec(2);
   end
   
   subplot(m+extra,3,1);
   Info(oo);
   
   diagram(oo,[type2,'x'],t,xx,[m+extra,3,2]);
   diagram(oo,[type2,'y'],t,yy,[m+extra,3,3]);
   shg;  pause(0.01);

      % plot evolution of orbits
      
   maxi = 0;
   for (i=1:m*n)
      bdx = Chunk(o,index,N,i+M);
      x = xx(bdx);  y = yy(bdx);      
      x = x-mean(x);  y = y-mean(y);  
      
      if isequal(scaling,'same')
         diagram(oo,type1,x,y,[m+extra n i+n]);
         set(gca,'DataAspectRatio',[1 1 1]);
      else
         oo = opt(oo,'spec',0);   % no spec drawing
         diagram(oo,type1,x,y,[m+extra n i+n]);
      end
      shg;  pause(0.01);
      
      maxi = max(maxi,max(max(abs(x)),max(abs(y))));
   end
   
   if isequal(scaling,'same')
      for (i=1:m*n)
         subplot(m+extra,n,i+n);
         maxi = max(maxi,spec*5.5/5);
         set(gca,'xlim',[-maxi maxi],'ylim',[-maxi maxi]);
      end
   end
end
function oo = Info(o,sub)              % Plot Info Diagram             
   subplot(o,sub);
   oo = opt(o,'subplot',1);
   uscore = util(o,'uscore');
   
   title(uscore(get(oo,'title')));
   set(gca,'xtick',[],'ytick',[]);
   
   %nick = sprintf('%s',get(oo,{'nick',''}));
   ID = sprintf('ID: %s',id(o)); 
   
   station = sprintf('Station: %s',get(oo,{'station',''}));
   apparatus = sprintf('Apparatus: %s',get(oo,{'apparatus',''}));
   damping = sprintf('Damping: %s',get(oo,{'damping',''}));
   kappl = sprintf('Kappl: %s',get(oo,{'kappl',''}));

   lage = sprintf('Lage: %g',get(oo,{'lage',NaN}));
   angle = sprintf('Theta: %g',o.rd(get(oo,{'theta',NaN}),1));
   vcut = sprintf('Vcut: %g',get(oo,{'vcut',NaN}));
   vseek = sprintf('Vseek: %g',get(oo,{'vseek',NaN}));

   comment = {ID,' ',station,' ',apparatus,' ',damping,' ',kappl,' ',...
              [lage,' ',angle],' ',[vcut,' ',vseek]};
   message(oo,'',comment);
   dark(o,'Axes');
end

%==========================================================================
% Metrics (Cpk,Chk,Mgr)
%==========================================================================

function oo = Metrics(o)               % Plot Metrics                  
   oo = metrics(o,[1 1 1]);
end

%==========================================================================
% Zoom and Shift Callbacks for Closeup and Refresh Helper
%==========================================================================

function o = Zoom(o)                   % Zoom Slider Callback          
   oo = closeup(o,'Zoom');
   Refresh(oo);
end
function o = Shift(o)                  % Shift Slider Callback         
   oo = closeup(o,'Shift');
   Refresh(oo);
end
function o = Refresh(o)                % Refresh Helper for Zoom/Shift 
   kids = get(figure(o),'Children');
   for i=1:length(kids)
      kid = kids(i);
      if isequal(get(kid,'type'),'axes')
         xyz = shelf(o,kid,'xyz');       % fetch axes shelf          
         if (xyz)
            bag = shelf(o,kid);
            oo = closeup(o,'Range',[1 length(bag.x)]);
            subplot(oo,bag.sub);
            
            delete(get(gca,'Children'));
            
               % set range option
               
            oo = opt(oo,'range',var(oo,'range'));
            diagram(oo,bag.mode,bag.x,bag.y,bag.sub,bag.heading);
         end
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function bdx = Chunk(o,idx,n,i)                                        
   i1 = 0;
   L = length(idx);
   delta = L/n;
   
   for (j=1:i)
      i0 = i1+1;
      i1 = ceil(i0+delta);
   end
   i1 = min(i1,L);
   bdx = i0:i1;
   
   assert(all(bdx<=L));
end
function SpecLimits(o,positive)                                        
   
   mode = opt(o,{'specs.display',1});  % display mode
   if (~mode)
      return     % don't show spec limits
   end
   
   kind = opt(o,{'kind',''});
   switch kind
      case {'A','a'}
         spec = opt(o,{'specs.a',[25 100]});
      case {'V','v'}
         spec = opt(o,{'specs.a',[25 100]});
      case {'S','s'}
         spec = opt(o,{'specs.a',[25 100]});
      otherwise
         return
   end
   strong = spec(1);
   weak  = spec(2);
   limit = [];                         % so far limit is deactivated
   
   oo = corazon(o);
   if (kind == upper(kind))            % circular
      phi = 0:pi/100:2*pi;
      hold on;
      plot(strong*cos(phi),strong*sin(phi),'k');
      plot(weak *cos(phi), weak*sin(phi),'k');
      
      if (mode == 2)
         plot([0 0],bad*[-1.2 1.2],'k');
         plot(bad*[-1.2 1.2],[0 0],'k');
      end

      if (length(limit) > 0 && prod(limit) ~= 0)
         set(gca,'xlim',limit, 'ylim',limit);
      end
      set(gca,'DataaspectRatio',[1 1 1])
   else
      xlim = get(gca,'xlim');
      plot(oo,xlim,+strong*[1 1],'c-.');
      plot(oo,xlim,-strong*[1 1],'c-.');
      set(gca,'ylim',strong*6/5*[-1 1]);
      
      if (mode == 2)
         plot(oo,xlim, +weak*[1 1],'c-.');
         plot(oo,xlim, -weak*[1 1],'c-.');
      end
      
      if (nargin >=2 && positive)
         limit(1) = -0.0001;
      end
      if (length(limit) > 0 && prod(limit) ~= 0)
         set(gca,'ylim',limit);
      end
   end
end
function list = Basket(o,tag,value)    % Get Basket List               
   list = {};
   for (i=1:length(o.data))
      oo = o.data{i};      
      if type(oo,{'cut'}) 
         if isequal(get(oo,{tag,''}),value)
            list{end+1} = oo;
         end
      end
   end   
end
function Stretch(o)                    % Stretch Orbit Plot            
   ylim = get(gca,'Ylim');
   set(gca,'Xlim',ylim*1.5);
   shelf(o,gca,'closeup',0);           % prevent from closeup control
end
