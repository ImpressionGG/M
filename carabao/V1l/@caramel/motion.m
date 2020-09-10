function oo = motion(o,varargin)       % Motion Plugin                 
%
% MOTION   Motion plugin
%
%             motion(caramel)          % register plugin
%
%             oo = motion(o,func)      % call local sample function
%
%          Read Driver for Motion Objects
%
%             oo = motion(o,'MotionDatDrv',path);
%
%          Note: all objects created by MOTION and imported by MOTION are
%          CARAMEL objects. Note that in dynamic shells the Analyse menu
%          is therfore built up by caramel/shell/Analyse.
%
%          See also: CARAMEL, PLUGIN, PLUG, BASIS, KEFALON, MOTION
%
   if (nargin == 0)
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Config,...
                       @New,@Import,@Export,@Collect,@Signal,@Analysis,...
                       @MotionProfile,@DutyProfile,@MotionMap,@DutyMap,...
                       @ReadPkgPkg,@ReadMotionDat,@WriteMotionDat,@Create);
   oo = gamma(oo);
end

%==========================================================================
% Plugin Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   o = Config(type(o,'motion'));       % register 'pln' configuration

   name = class(o);
   plugin(o,[name,'/shell/Register'],{mfilename,'Register'});
   plugin(o,[name,'/shell/New'],     {mfilename,'New'});
   plugin(o,[name,'/shell/Import'],  {mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],  {mfilename,'Export'});
   plugin(o,[name,'/shell/Collect'], {mfilename,'Collect'});
   plugin(o,[name,'/shell/Signal'],  {mfilename,'Signal'});
   plugin(o,['caramel/shell/Analysis'],{mfilename,'Analysis'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % New Sample Trace              
   oo = mitem(o,'Motion');
   ooo = mitem(oo,'Motion Trace',{@Create});
end
function oo = Parameter(o,label,tag,smax,vmax,amax,tj)                 
%
% MOTIONMENU   Add charm menu items for parameter settings
%
%                 oo = MotionMenu(o,'','motion',50,3000,25000,0.01);
%                 oo = MotionMenu(o,'Long','long',200,3000,25000,0.01);
%
   context = Tag([tag,'.']);           
   setting(o,{[context,'tmax']},500);  % park motion parameter smax
   setting(o,{[context,'Ts']},1);  % park motion parameter smax
   setting(o,{[context,'smax']},smax); % park motion parameter smax
   setting(o,{[context,'vmax']},vmax); % park motion parameter vmax
   setting(o,{[context,'amax']},amax); % park motion parameter amax
   setting(o,{[context,'tj']},tj);     % park motion parameter tj
   setting(o,{[context,'algo']},1);    % Etel motion algorithm

   context = [tag,'.']; 
   if ~isempty(label)
      oo = mitem(o,label);
   else
      oo = o;                          % no sub menu item if empty label
   end
%  ooo = mitem(oo,'Motion Profile',{@invoke,mfilename,@MotionPlot,tag});
%  ooo = mitem(oo,'Duty Profile',{@invoke,mfilename,@DutyPlot,tag});
%  ooo = mitem(oo,'Plot & Clip',{@invoke,mfilename,@ClipPlot,tag});
%  if isequal(tag,'motion')
%     ooo = mitem(oo,'-');
%     ooo = mitem(oo,'Motion Map',{@invoke,mfilename,@MotionMap,tag});
%     ooo = mitem(oo,'Duty Map',{@invoke,mfilename,@DutyMap,tag});
%  end
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Max Time [ms]',[context,'tmax']);
   ooo = Charm(oo,'Sample Time [ms]',[context,'Ts']);
   ooo = mitem(oo,'-');
   ooo = Charm(oo,'Stroke [mm]',[context,'smax']);
   ooo = Charm(oo,'Velocity [mm/s]',[context,'vmax']);
   ooo = Charm(oo,'Acceleration [mm/s2]',[context,'amax']);
   ooo = Charm(oo,'Jerk Time [s]',[context,'tj']);
   ooo = mitem(oo,'-');
   ooo = mitem(o,'Algorithm',{},Tag([context,'algo']));
         choice(ooo,{{'Datacon',0},{'Etel',1},{'Hux',2},{'Alt',3}},{});
   return
   
   function o1 = Charm(o,label,tag)    % Add Charm Menu Item           
   %
   % CHARM   Setup a menu item with CHARM functionality
   %
      o1 = mitem(o,label,{},Tag(tag));
      charm(o1,{});
   end
   function tag = Tag(suffix)          % Create Full Tag               
   %
   % TAG   Create a full tag, given pos fix tag
   %
   %          tag = Tag('z')           % tag = 'ultra.z'
   %          tag = Tag('slow.stroke') % tag = 'ultra.slow.stroke'
   %
      tag = ['new.',suffix];
   end
end

function oo = Import(o)                % Import Menu Items             
   oo = mitem(o,'Motion');
   ooo = mitem(oo,'Motion Trace (.dat)',{@ImportCb,'ReadMotionDat','.dat',@caramel});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      read = eval(['@',mfilename]);    % reader method

      co = cast(o);                    % casted object
      list = import(co,drv,ext,read);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mitem(o,'Motion');
   set(mitem(oo,inf),'enable',onoff(o,{'motion'}));
   ooo = mitem(oo,'Motion Trace (.dat)',{@ExportCb,'WriteMotionDat','.dat',@caramel});
   return
   
   function oo = ExportCb(o)           % Export Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         write = eval(['@',mfilename]);% writer method

         co = cast(oo);                % casted object
         export(co,drv,ext,write);     % export object to file
      end
   end
end
function o = Collect(o)                % Configure Collection          
   table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
            {@read,'caramel','ReadGenDat', '.dat'}};
   collect(o,{'pln','smp'},table); 
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   switch active(o)                    % depending on active type
      case {'motion'}
         oo = mitem(o,'V and S',{@Config},'ConfigVS');
         oo = mitem(o,'A and J',{@Config},'ConfigAJ');
         oo = mitem(o,'-');
         oo = mitem(o,'S',{@Config},'ConfigS');
         oo = mitem(o,'V',{@Config},'ConfigV');
         oo = mitem(o,'A',{@Config},'ConfigA');
         oo = mitem(o,'J',{@Config},'ConfigJ');
         oo = mitem(o,'-');
         oo = mitem(o,'All',{@Config},'ConfigAll');
   end
end
function o = Config(o)                 % Change Configuration          
   o = config(o,[],active(o));         % init with active type
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = category(o,1,[],[],'mm');
   o = category(o,2,[],[],'mm/s');
   o = category(o,3,[],[],'mm/s2');
   o = category(o,4,[],[],'mm/s3');
         
      % get mode and provide a proper default if empty
      % (empty mode is provided during registration phase)
      
   mode = o.either(arg(o,1),'ConfigVS');  
   switch mode                         % dispatch on configuration mode
      case 'ConfigS'
         o = config(o,'s',{1,'g',1});
      case 'ConfigV'
         o = config(o,'v',{1,'b',2});
      case 'ConfigA'
         o = config(o,'a',{3,'g',3});
      case 'ConfigJ'
         o = config(o,'j',{4,'yo',4});
      case 'ConfigVS'
         o = config(o,'v',{1,'b',2});
         o = config(o,'s',{2,'g',1});
      case 'ConfigAJ'
         o = config(o,'a',{1,'r',3});
         o = config(o,'j',{2,'yo',4});
      case 'ConfigAll'
         o = subplot(o,'Layout',2);
         o = config(o,'v',{1,'b',2});
         o = config(o,'s',{2,'g',1});
         o = config(o,'a',{3,'r',3});
         o = config(o,'j',{4,'yo',4});
   end
   o = subplot(o,'Signal',mode);       % set signal mode
   
   change(o,'Bias','absolute');        % change bias mode, update menu
   change(o,'Labels','plain');         % change labels mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Analysis Menu
%==========================================================================

function o = Analysis(o)               % Analysis Menu                 
   oo = MotionObject(o);               % classify current object
   if ~isempty(oo)                     % if 'motion' typed CARAMEL object
      oo = mhead(o,'Motion');
      ooo = mitem(oo,'Motion Profile',{@invoke,mfilename,@MotionProfile});
      ooo = mitem(oo,'Duty Profile',{@invoke,mfilename,@DutyProfile});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Motion Map',{@invoke,mfilename,@MotionMap});
      ooo = mitem(oo,'Duty Map',{@invoke,mfilename,@DutyMap});
   end
   plugin(o,'caramel/motion/Analysis');% plug point
end
function o = MotionProfile(o)          % Motion Profile Callback       
   oo = MotionObject(o);
   if isempty(oo)
      menu(o,'About');
      return
   end
   
   [smax,vmax,amax] = get(oo,'smax','vmax','amax');
   [tj,algo,unit] = get(oo,'tj','algo','unit');
   motion(carasim,smax,vmax,amax,[tj/1000,algo],unit);
end
function o = DutyProfile(o)            % Duty Profile Callback         
   oo = MotionObject(o);
   if isempty(oo)
      menu(o,'About');
      return
   end
   
   [smax,vmax,amax] = get(oo,'smax','vmax','amax');
   [tj,algo,unit] = get(oo,'tj','algo','unit');
   duty(carasim,smax,vmax,amax,[tj/1000,algo],unit);
end
function o = MotionMap(o)              % Motion Map Callback           
   oo = MotionObject(o);
   if isempty(oo)
      menu(o,'About');
      return
   end
   
   [smax,vmax,amax] = get(oo,'smax','vmax','amax');
   [tj,algo,unit] = get(oo,'tj','algo','unit');
   motion(carasim,NaN,vmax,amax,[tj/1000,algo],unit);
end
function o = DutyMap(o)                % Duty Map Callback             
   oo = MotionObject(o);
   if isempty(oo)
      menu(o,'About');
      return
   end
   
   [smax,vmax,amax] = get(oo,'smax','vmax','amax');
   [tj,algo,unit] = get(oo,'tj','algo','unit');
   duty(carasim,NaN,vmax,amax,[tj/1000,algo],unit);
end
function oo = MotionObject(o)          % Get Motion Object             
   oo = current(o);
   ctype = type(oo);
   if ~(isequal(ctype,'motion') && isa(oo,'caramel'))
      oo = [];                         % no 'motion' typed CARAMEL object
   end
end

%==========================================================================
% Read/Write Driver
%==========================================================================

function oo = ReadMotionDat(o)         % Read Driver for motion .dat   
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'smp')
      message(o,'Error: no motion data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end
function oo = WriteMotionDat(o)        % Write Driver for motion .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Create(o)                % New Motion Object             
%
% CREATE   Create a motion object with parameters
%
%             smax:  motion distance
%             vmax:  maximum velocity
%             amax:  maximum acceleration
%             tj:    jerk time
%             unit:  reference unit (mm or deg)
%             algo:  algorithm
%
%             tmax:  maximum time of motion profile
%             Ts:    sampling time
%
   [smax,vmax,amax,tj,unit,algo,tmax,Ts,kind,title] = ...
       get(o,{'smax',50},{'vmax',500},{'amax',10000},{'tj',20},...
             {'unit','mm'},{'algo',1},{'tmax',500},{'Ts',1},...
             {'kind',[]},'title');

      % dynamically generated title only at the very first time
      
   if container(o)                     % at the very first time
      title = sprintf('Motion Profile %g %s @ %g ms',max(smax),unit,tmax);
   end
   
      % dynamical comment generation each time!
      
   comment = {};                       % dynamical comment generation
   comment{1} = sprintf('vmax = %g %s/s, amax = %g %s/s2, tj = %g ms',...
                vmax,unit,amax,unit,tj);
   comment{2} = sprintf('tmax = %g ms, Ts = %g ms',tmax,Ts);   
      
      % create motion object and convert to 'motion' typed CARAMEL
      
   t = [0:Ts:tmax+eps] / 1000;         % convert from ms to sec
   o = motion(carasim,{smax,t},vmax,amax,[tj/1000 algo],unit);       
   
   oo = caramel('motion');
   oo = set(oo,'kind',kind);           % need to check for virgin
   
   oo = log(oo,'t','s','v','a','j');   % create CARAMEL based log object
   oo = log(oo,var(o,'t'),var(o,'s'),var(o,'v'),var(o,'a'),var(o,'j'));

      % write parameters back to object and provide edit list
      
   oo = set(oo,'smax',smax,'vmax',vmax,'amax',amax','tj',tj,'unit',unit,...
               'algo',algo,'tmax',tmax','Ts',Ts,'title',title,...
               'comment',comment);
   oo = set(oo,'edit',{{'Motion Distance','smax'},...
               {'Max. Velocity','vmax'},{'Max Acceleration','amax'},...
               {'Jerk Time [ms]','tj'},{'Reference Unit','unit'},...
               {'Algorithm (0,1,2,3)','algo'},{'Max. Time [ms]','tmax'},...
               {'Sample Time [ms]','Ts'}});

      % apply some generic finishing procedure
      
   oo = Finish(oo,oo);
end
function oo = Finish(o,oo)             % Finish Object Creation        
%
%  FINISH   Finish the creation process of a motion object
%    
%              title = '100 mm Motion';
%              comment = {'move from flipper to upward camera'};
%              oo = motion(caramel,{smax,0:Ts:tmax},vmax,amax,tj,unit,algo);    
%              oo = finish(o,oo,title,comment)
%    
   [func,mfile] = caller(o,1);
   kind = get(oo,'kind');
   
   oo = set(oo,'kind',func);
   gamma = eval(['@',mfile]);
   oo = set(oo,'update',{gamma,func});

      % in case of a virgin object paste transfer function, otherwise
      % merge data and new parameters into old object
      
   virgin = ~isequal(kind,func);       % do we have a virgin object?
   if (virgin)
      oo = edit(oo);
      if ~isempty(oo)
         paste(o,{oo});                % paste transfer function
      end
   else
      oo = Merge(o,oo);                % merge data and parameters
   end
   return
   
   function o  = Merge(o,oo)           % Merge Data and Parameters     
   %
   % MERGE   Merge new data and parameters of new object oo into old
   %         object o.
   %
   %            oo = Merge(o,oo)
   %
      tags = fields(oo.par);
      for (i=1:length(tags))
         tag = tags{i};
         o = set(o,tag,get(oo,tag));
      end
      o.data = oo.data;
   end
end
