function oo = sample(o,varargin)       % Sample Plugin                 
%
% SAMPLE   Sample plugin
%
%             sample(cordoba)          % register plugin
%
%             oo = sample(o,func)      % call local sample function
%
%          Read Driver for Simple & Plain Objects
%
%             oo = sample(o,'PlnDatDrv',path);
%             oo = sample(o,'SmpDatDrv',path);
%
%          Note: all objects created by SAMPLE and imported by SAMPLE are
%          CORDOBA objects. Note that in dynamic shells the Analyse menu
%          is therfore built up by cordoba/shell/Analyse.
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORDOBA, PLUGIN, PLUG, BASIS, KEFALON
%
   if (nargin == 0)
      o = pull(corazon);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Config,...
                       @New,@Import,@Export,@Collect,@Signal,@ReadPkgPkg,...
                       @ReadPlnDat,@ReadSmpDat,@WritePlnDat,@WriteSmpDat);
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
   o = Config(type(o,'pln'));          % register 'pln' configuration
   o = Config(type(o,'smp'));          % register 'smp' configuration

   name = class(o);
   plugin(o,[name,'/shell/New'],{mfilename,'New'});
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],{mfilename,'Export'});
   plugin(o,[name,'/shell/Collect'],{mfilename,'Collect'});
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % New Sample Trace              
   oo = mitem(o,'Sample');
   ooo = mitem(oo,'Plain Sample',{@NewPlain});
   ooo = mitem(oo,'Simple Sample',{@NewSimple});
   return
   
   function oo = NewPlain(o)           % Create New Plain Object       
      co = cordoba(o);                 % convert to cordoba object
      oo = new(co,'Plain');            % create new plain object
      paste(o,{oo});                   % paste new object into shell
   end
   function oo = NewSimple(o)          % Create New Simple Object      
      co = cordoba(o);                 % convert to cordoba object
      oo = new(co,'Simple');           % create new Simple object
      paste(o,{oo});                   % paste new object into shell
   end

   function o = ConfigPlain(o)         % Configure Plain Object        
      o = category(o,1,[-5 5],[0 0],'�');      % category 1 for x,y
      o = category(o,2,[-50 50],[0 0],'m�');   % category 2 for p

      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'p',{2,'g',2});
   end
   function o = ConfigSimple(o)        % Configure Simple Object       
      o = category(o,1,[-5 5],[0 0],'�');      % category 1 for x,y
      o = category(o,2,[-50 50],[0 0],'m�');   % category 2 for p
      o = category(o,3,[-0.5 0.5],[0 0],'�');  % category 3 for ux,uy

      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'p',{2,'g',2});
      o = config(o,'ux',{3,'m',3});
      o = config(o,'uy',{3,'c',3});
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mitem(o,'Sample');
   ooo = mitem(oo,'Plain Sample (.dat)',{@ImportCb,'ReadPlnDat','.dat',@cordoba});
   ooo = mitem(oo,'Simple Sample (.dat)',{@ImportCb,'ReadSmpDat','.dat',@cordoba});
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
   setting(o,{'sample.separator'},'');
   oo = mitem(o,'Sample');
   set(mitem(oo,inf),'enable',onoff(o,{'pln','smp'}));
   ooo = mitem(oo,'Plain Sample (.dat)',{@ExportCb,'WritePlnDat','.dat',@cordoba});
   set(mitem(ooo,inf),'enable',onoff(o,'pln'));
   ooo = mitem(oo,'Simple Sample (.dat)',{@ExportCb,'WriteSmpDat','.dat',@cordoba});
   set(mitem(ooo,inf),'enable',onoff(o,'smp'));
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Separator',{},'sample.separator');
   choice(ooo,{{'None',''},{'"|"','|'},{'";"',';'}});
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
   table = {{@read,'cordoba','ReadPkgPkg','.pkg'},...
            {@read,'cordoba','ReadGenDat', '.dat'}};
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
      case {'pln'}
         oo = mitem(o,'X/Y and P',{@Config},'PlainXYP');
         oo = mitem(o,'X and Y',{@Config},'PlainXY');
      case {'smp'}
         oo = mitem(o,'All',{@Config},'SimpleAll');
         oo = mitem(o,'X/Y and P',{@Config},'SimpleXYP');
         oo = mitem(o,'UX and UY',{@Config},'SimpleU');
   end
end
function o = Config(o)                 % Change Configuration          
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   

   switch o.type
      case 'pln'                       % plain type
         o = subplot(o,'Color',[1 1 0.9]);
         o = category(o,1,[-10 10],[],'�');
         o = category(o,2,[-50 50],[],'m�');
      case 'smp'                       % simple type
         o = subplot(o,'Color',[0.97 0.98 1]);
         o = category(o,1,[-5 5],[0 0],'�');
         o = category(o,2,[-50 50],[0 0],'m�');
         o = category(o,3,[-0.5 0.5],[0 0],'�');
   end
         
      % get mode and provide a proper default if empty
      % (empty mode is provided during registration phase)
      
   mode = o.either(arg(o,1),o.type);  
   switch mode                         % dispatch on configuration mode
      case {'PlainXYP','pln'}
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
         mode = 'PlainXYP';
      case 'PlainXY'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'b',1});
      case {'SimpleAll','smp'}
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
         o = config(o,'ux',{3,'m',3});
         o = config(o,'uy',{3,'c',3});
         mode = 'SimpleAll';
      case 'SimpleXYP'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
      case 'SimpleU'
         o = config(o,'ux',{1,'m',1});
         o = config(o,'uy',{2,'c',1});
      otherwise
         error('bad mode!');
   end
   o = subplot(o,'Signal',mode);       % set signal mode   

   change(o,'Bias','drift');           % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for package info  
   path = arg(o,1);
   oo = read(o,'ReadPkgPkg',path);
end
function oo = ReadPlnDat(o)            % Read Driver for plain .dat    
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'pln')
      message(o,'Error: no plain sample data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end
function oo = ReadSmpDat(o)            % Read Driver for simple .dat   
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'smp')
      message(o,'Error: no simple sample data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end

function oo = WritePlnDat(o)           % Write Driver for plain .dat   
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
function oo = WriteSmpDat(o)           % Write Driver for simple .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
