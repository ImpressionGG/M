function oo = tcb(o,varargin)          % TCB Plugin                 
%
% TCB   TCB plugin - to analyse TCB trace files.
%       Supported types: 'tcb'
%
%             tcb(cordoba)             % register plugin
%
%             oo = tcb(o,func)         % call local tcb function
%
%         Local functions:
%            oo = tcb(o,'New')         % add New/TCB menu
%            oo = tcb(o,'Import')      % add Import/TCB menu
%            oo = tcb(o,'Export')      % add Export/TCB menu
%
%            oo = Config(oo)           % configure plotting of TCB objects
%
%         Import Driver
%            oo = tcb(o,'ReadTcbTrace','.trace')
%
%         Copyright(c): Bluenetics 2020 
%
%         See also: CORDOBA, SAMPLE, BASIS, PBI, DANA, KEFALON
%
   if (nargin == 0)
      o = pull(corazon);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@New,@Import,@Export,...
                       @Collect,@Signal,@Analysis,@TcbTraceCb,@Config,...
                       @ReadTcbTrace,@ReadTcbDat,@WriteTcbDat);
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
   name = class(o);
   plugin(o,[name,'/shell/New'],{mfilename,'New'});
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],{mfilename,'Export'});
   plugin(o,[name,'/shell/Collect'],{mfilename,'Collect'});
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
   plugin(o,[name,'/shell/Analysis'],{mfilename,'Analysis'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % Add New Menu                  
   % no menu items for New menu!
end
function o = Import(o)                 % Add Import Menu               
   oo = mitem(o,'TCB');
   ooo = mitem(oo,'TCB Trace (.trace)',{@ImportCb,@ReadTcbTrace,'.trace',@cordoba});
   ooo = mitem(oo,'TCB Trace (.dat)',{@ImportCb,@ReadTcbDat,'.dat',@cordoba});
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
function o = Export(o)                 % Add Export Menu               
   oo = mitem(o,'TCB');                % add menu header
   set(mitem(oo,inf),'enable',onoff(o,'tcb'));
   ooo = mitem(oo,'TCB Trace (.dat)',{@ExportCb,'WriteTcbDat','.dat',@cordoba});
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
function o = Collect(o)                % Setup Collection Control      
   table = {{@read,'cordoba','ReadPkgPkg','.pkg'},...
            {@tcb,'tcb','ReadTcbTrace','.trace'},...
            {@tcb,'tcb','ReadTcbDat','.dat'}};
   collect(o,{'tcb'},table); 
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   if isequal(type(current(o)),'tcb')
      oo = mitem(o,'T,F,w,z',{@SignalCb,'TFwz'});
      oo = mitem(o,'-');
      oo = mitem(o,'T',{@SignalCb,'T'});
      oo = mitem(o,'F',{@SignalCb,'F'});
      oo = mitem(o,'w',{@SignalCb,'w'});
      oo = mitem(o,'z',{@SignalCb,'z'});
   end
   return
   
   function o = SignalCb(o)            % Signal Callback               
      mode = arg(o,1);                 % get callback mode
      o = Config(current(o));          % default configuration
      switch mode
         case 'T'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = category(o,2,[0 0],[0 0],'�C');
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'T',1);
         case 'F'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = category(o,3,[0 0],[0 0],'N');
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'F',1);
         case 'w'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = category(o,1,[0 0],[0 0],'�');
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'w',1);
         case 'z'
            o = subplot(o,'layout',1); % layout with 1 subplot column   
            o = category(o,1,[0 0],[0 0],'�');
            o = config(o,[]);          % set all sublots to zero
            o = config(o,'z',1);
         otherwise
            'go with default!';
      end

      change(o,'bias','absolute');     % change bias mode, update menu
      change(o,'config',o);            % change config, rebuild & refresh
   end
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = [];  
   if isequal(onoff(o,'tcb'),'on')
      oo = mhead(o,'TCB Analysis');
      ooo = mitem(oo,'TCB Trace Analysis',{@TcbTraceCb});
   end
end   
function o = TcbTraceCb(o)             % TCB Trace Analysis Callback   
   message(current(o),'TCB Trace Analysis','under construction ...');
end

%==========================================================================
% Read/Write Driver for TCB Trace and Dat Files
%==========================================================================

function oo = ReadTcbTrace(o)          % Read Driver for TCB .trace    
%
% VIBTXTDRV   Read diver for VIB log file (vibration test)
%
   path = arg(o,1);

   oo = read(o,'Open',path);           % open file & create object
   oo = Type(oo,'tcb');                % read type
   oo = read(oo,'Param');              % read parameters
   oo = Head(oo);                      % read data header
   oo = Data(oo);                      % read data
   oo = read(oo,'Param');              % read parameters (again)
   oo = Post(oo);                      % post processing of object
   oo = read(oo,'Close');              % close file & cleanup object
   
   oo = Config(oo);                    % overwrite configuration
   return
   
   function o = Type(o,typ)            % Extract Type Information      
      o.type = typ;                    % set default type
      o = read(o,'Type');              % read type
   end
   function o = Head(o)                % Read Header Information       
      o = read(o,'Head');              % read data header
      symbols = var(o,'symbols');
      units = var(o,'units');
      factors = [];  labels = [];
      for (k=1:length(symbols))
         ident = [symbols{k},' [',units{k},']'];
         [sym,unit,runit,label,rlabel,fac] = Classify(ident,k);
         symbols{k} = sym;
         units{k} = unit;
         factors(k) = fac;
         labels{k} = label;
      end
      o = var(o,'symbols',symbols);
      o = var(o,'units',units);
      o = var(o,'factors',factors);
      o = var(o,'labels',labels);
   end
   function o = Data(o)                % Read Data and Convert         
      o = read(o,'Data');              % delegate to read driver
      symbols = var(o,'symbols');
      factors = var(o,'factors');
      for (k=1:length(symbols))
         sym = symbols{k};  fac = factors(k);
         o.data.(sym) = o.data.(sym)/fac;
      end
   end
   function o = Post(o)                % post processing of object
      co = o;                          % copy object
      o.par = [];                      % now clear all parameters

      [dir,title,ext] = fileparts(var(o,'path'));

      if isequal(o.type,'pkg')
         kind = 'tcb';
      elseif o.find('Bondtrace',title) == 1
         kind = 'tcb';
      elseif o.find('.',title) == 4
         kind = lower(title(1:3));
      else
         kind = 'any';
      end
      
      idx = min(find(title=='_'));
      if ~isempty(idx)
         title = title(1:idx-1);
      end
      
      o = set(o,'title',get(co,{'TITLE',title}));
      o = set(o,'date',get(co,'DATE'));
      if ~isempty(o.par.date)
         o.par.date = datestr(datevec(o.par.date,'dd-mm-yyyy'));
      end
      o = set(o,'time',get(co,'TIME'));
      o = set(o,'machine',get(co,'MACHINE_ID'));
      o = set(o,'kind',kind);
      
      o.par.import = co.par;           % copy original parameters
   end
end
function oo = ReadTcbDat(o)            % Read Driver for TCB .dat File 
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'tcb')
      message(o,'Error: no TCB data!',...
              'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteTcbDat(o)           % Write Driver for TCB .dat File
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% Configure Plotting
%==========================================================================

function o = Config(o)                 % Configure for Plotting        
   o = subplot(o,'layout',2);          % layout with 1 subplot column   
   o = subplot(o,'color',[1 0.8 0.8]);

   o = category(o,1,[0 0],[0 0],'�');
   o = category(o,2,[0 0],[0 0],'*C');
   o = category(o,3,[0 0],[0 0],'N');

   o = config(o,[]);                   % set all sublots    to zero
   o = config(o,'T',{1,'r',2});
   o = config(o,'F',{2,'b',3});
   o = config(o,'w',{3,'g',1});
   o = config(o,'z',{4,'a',1});
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [sym,unit,runit, label,rlabel,fac] = Classify(ident,k)        
%
% CLASSIFY     Classify a variable description and return a variable
%              symbol. Return some default if variable description 
%              cannot be identified.
%
   switch ident
      case 'Time [ms]'
         sym = 't';  runit = 'ms';  unit = 's';  
         label = 'Time';  fac = 1000;
      case 'Digital inputs [none]'
         sym = 's';  runit = '[none]';  unit = '1';  
         label = 'Sync Trigger';  fac = 1/500;
      case 'Tool heater current [A]'
         sym = 'I';  runit = '[A]';  unit = 'A';  
         label = 'Tool Heater Current';  fac = 1;
      case 'Z-Position [mm]'   
         sym = 'z';  unit = '�';  runit = 'mm';
         label = 'Z-Position';  fac = -1/1000;
      case 'Z-TrackingError [mm]'   
         sym = 'ez';  unit = '�';  runit = 'mm';
         label = 'Z-Error';  fac = -1/1000;
      case 'Z-Current [A]'   
         sym = 'iz';  unit = 'A';  runit = 'A';
         label = 'Z-Current';  fac = 1;
      case {'Tool-Temperature [�C]','Tool-Temperature [°C]'}   
         sym = 'T';  unit = '�C';  runit = '�C';
         label = 'Temperature';  fac = 1;
      case {'Interface-Temperature [�C]','Interface-Temperature [°C]'}   
         sym = 'A';  unit = '�C';  runit = '�C';
         label = 'Auxillary Temperature';  fac = 1;
      case 'W-Position [mm]'
         sym = 'w';  unit = '�';  runit = 'mm';
         label = 'W-Position';  fac = -1/1000;  % weird!!!! assumed: fac = 1000;
      case 'W-TrackingError [mm]'   
         sym = 'ew';  unit = '�';  runit = 'mm';
         label = 'W-Error';  fac = -1/1000;     % weird!!!! assumed: fac = 1000;
      case 'W-Current [A]'   
         sym = 'iw';  unit = 'A';  runit = 'A';
         label = 'W-Current';  fac = 1;
      case 'Bond-Force [g]'   
         sym = 'F';  unit = 'g';  runit = 'N';
         label = 'Force';  fac = 100;
      case 'Tool vacuum [flow]'   
         sym = 'f';  unit = 'flow';  runit = 'flow';
         label = 'Tool Vacuum';  fac = 1;
      case 'Tool vacuum valve [on/off]'   
         sym = 'V';  unit = 'on/off';  runit = 'on/off';
         label = 'Tool Vacuum Valve';  fac = 1;
      case 'Tool nitrogene valve [on/off]'   
         sym = 'N';  unit = 'on/off';  runit = 'on/off';
         label = 'Tool Nitrogen Valve';  fac = 1;
      case {'Theta-Position [°]','Theta-Position [�]'}   
         sym = 'Th';  unit = '1';  runit = '[1]';
         label = 'Theta-Position [�]';  fac = 1;
      case 'Tilt-A-Position [mm]'   
         sym = 'A';  unit = '�';  runit = 'mm';
         label = 'Tilt-A-Position';  fac = 1000;
      case 'Tilt-B-Position [mm]'   
         sym = 'B';  unit = '�';  runit = 'mm';
         label = 'Tilt-B-Position';  fac = 1000;
      case 'Tool Cooling [on/off]'   
         sym = 'C';  unit = 'on/off';  runit = 'on/off';
         label = 'Tool Cooling';  fac = 1;
      case {'Bond heating [�C]','Bond heating [°C]'}   
         sym = 'Ts';  unit = '�C';  runit = '�C';
         label = 'Stage Temperature';  fac = 1;
      otherwise
         sym = sprintf('v_%g',k);  unit = '1';  runit = 1;
         label = ident;  fac = 1;
   end
   rlabel = ident;
end
