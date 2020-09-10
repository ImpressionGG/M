function oo = pbi(o,varargin)          % PBI Plugin                    
%
% PBI   PBI plugin - post bond inspection analysis
%
%              pbi(caramel)            % register PBI plugin
%
%              oo = pbi(o,func)        % call local pbi function
%
%         See also: CARAMEL, PLUGIN, SAMPLE, BASIS
%
   if (nargin == 0)
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@New,@Import,@Export,...
                       @Collect,@Read,@Write,@Signal,...
                       @ReadPbiTxt,@ReadPbiPbi,@ReadMbcTxt,@ReadMbcPbi);
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
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % New Simple Trace              
   % intentionally empty!
end
function o = Import(o)                 % Import from File              
   oo = mitem(o,'PBI');
   ooo = mitem(oo,'PBI Data File (.dat)',{@ImportCb,@ReadPbiDat,'.dat',@caramel});
   ooo = mitem(oo,'PBI Data File (.txt)',{@ImportCb,@ReadPbiTxt,'.txt',@caramel});
   ooo = mitem(oo,'PBI Data File (.pbi)',{@ImportCb,@ReadPbiPbi,'.pbi',@caramel});
   %ooo = mitem(oo,'New PBI Log File (.pbi)',{@ImportCb,@NewPbiPbiDrv,'.pbi'});
   ooo = mitem(oo,'-');
   ooo = Defaults(oo);
   return
   
   function oo = Defaults(o)           % Import Defaults for PBI       
      setting(o,{'pbi.rows'},1);
      setting(o,{'pbi.columns'},1);
      setting(o,{'pbi.path'},'cs');
      setting(o,{'pbi.start'},'bl');
      setting(o,{'pbi.gantry'},'');
      
      oo = mitem(o,'Defaults');
      ooo = mitem(oo,'Rows','','pbi.rows');
      charm(ooo,{});
      ooo = mitem(oo,'Columns',{},'pbi.columns');
      charm(ooo,{});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Path Method',{},'pbi.path');
      choice(ooo,{{'Undefined',''},...
                  {'Columns/Sawtooth','cs'},{'Columns/Meander','cm'},...
                  {'Rows/Sawtooth','rs'},{'Rows/Meander','rm'}});
      ooo = mitem(oo,'Path Start',{},'pbi.start');
      choice(ooo,{{'Bottom Left','bl'},{'Bottom Right','br'},...
                  {'Top Left','tl'},{'Top Right','tr'}});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'Gantry',{},'pbi.gantry');
      choice(ooo,{{'Undefined',''},{'Right','R'},...
                  {'Left','L'},{'Dual','D'}});
   end
   function o = ImpfortCb(o)           % Import Log Data Callback      
      driver = arg(o,1);               % export driver
      ext = arg(o,2);                  % file extension
      %o = caramel(o);                 % finally want create a CARAMEL obj
      
      caption = sprintf('Import PBI object from %s file',ext);
      [files, dir] = fselect(o,'i',ext,caption);

      list = {};                          % init: empty object list
      for (i=1:length(files))
         path = o.upath([dir,files{i}]);  % construct path
         oo = Read(o,driver,path);        % call read driver function
         oo = launch(oo,launch(o));       % inherit launch function

            % returned object can either be container (kids list appends to
            % list) or non-container (which goes directly into list)

         if container(oo)
            list = [list,data(oo)];       % append container's kids to list
         else
            list{end+1} = oo;             % add imported object to list
         end
      end
      paste(o,list);
   end
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
function o = Export(o)                 % Export to File                
end
function o = Collect(o)                % Configure Collection          
   table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
            {@read,'caramel','ReadGenDat', '.dat'},...
            {@pbi,'caramel','ReadPbiTxt', '.txt'},...
            {@pbi,'caramel','ReadPbiPbi', '.pbi'}};
   collect(o,{'pbi'},table); 

   table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
            {@read,'caramel','ReadGenDat', '.dat'},...
            {@pbi,'caramel','ReadMbcTxt', '.txt'},...
            {@pbi,'caramel','ReadMbcPbi', '.pbi'}};
   collect(o,{'mbc'},table); 
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   if isequal(type(current(o)),'pbi')
      oo = mitem(o,'X and Y',{@SignalXY});
      oo = mitem(o,'Theta',{@SignalTh});
      oo = mitem(o,'X/Y and Theta',{@SignalXYTh});
   end
   return
   
   function o = SignalXY(o)            % Configure for XY Signals      
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r'});
      o = config(o,'y',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = SignalTh(o)            % Configure for Th Signal       
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'th',{1,'g'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = SignalXYTh(o)          % Configure for XY & Th Signal  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r'});
      o = config(o,'y',{1,'b'});
      o = config(o,'th',{2,'g'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
end

%==========================================================================
% Read Driver
%==========================================================================

function oo = Read(o,varargin)         % Read Object                   
%
% READ   Read a CARAMEL object (type BMC/VIB) from file.
%
%           oo = Read(o,'PbiTxtDrv',path)
%           oo = Read(o,'PbiPbiDrv',path)
%           oo = Read(o,'NewPbiPbiDrv',path)
%
%        See also: CARAMEL, IMPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@ReadPbiTxt,@ReadPbiPbi,@ReadPbiDat);
   oo = gamma(oo);
end
function o = Config(o)                 % Provide Defaults              
%
   o = opt(o,'category.specs',[-2 2; -20 20]);
   o = opt(o,'category.limits',[0 0;   0  0]);
   o = opt(o,'category.units',{'µ','m°'});

   o = category(o,1,[-2 2],[0 0],'µ');        % category 1 for x,y
   o = category(o,2,[-20 20],[0 0],'m°');     % category 2 for th
   
   o = config(o,'x',{1,'r',1});
   o = config(o,'y',{1,'b',1});
   o = config(o,'th',{2,'g',2});
   o = config(o,'sys',{0,'y',0});
   o = config(o,'i',{0,'a',0});
   o = config(o,'j',{0,'k',0});
end

%==========================================================================
% New PbiPbi Driver for .txt File
%==========================================================================

function o = NewPbiPbiDrv(o)           % New PBI Read Driver           
%
% NEWPBIPBIDRV   Import a Postbond .PBI log file in order to return PBI data. 
%
%    PBI log file import for log files with .PBI extension. The result is
%    a list of trace object returned in the data part of the object.
%
%       o = NewPbiPbiDrv(arg(o,{filepath}));
%       o = NewPbiPbiDrv(arg(o,{'right_bk_2.pbi'}));
%
%    Data values are returned from IMP_PBI in the following data members:
%
%      type                            % data type 'stream'
%      
%      par.path                        % cluster path
%      par.sizes                       % number of matrix rows & columns
%      par.pitch                       % matrix pich x/y
%      par.method                      % meander/sawtooth, by row/column
%      
%      dat.time                        % t vector (time)
%      dat.x                           % x vector
%      dat.y                           % y vector
%      dat.th                          % theta vector
%      dat.sys                         % system number
%      dat.i                           % row index vector
%      dat.j                           % col index vector
%      dat.bp                          % bond position index
%
%   Note for system number: left=1, right = 2, other = 0
%   See also: PBI, IMPORT
%
   path = arg(o,1);
   o = read(o,'PbiPbiDrv',path);
end

%==========================================================================
% Read Driver for .txt File
%==========================================================================

function o = ReadMbcTxt(o)             % Read .TXT file into MBC object
   o = ReadPbiTxt(o);
   if ~o.is(o.type,{'pbi','mbc'})
      message(o,'Error: bad log file type!','PBI or MBC type expected!');  
   end
   o.type = 'mbc';
end
function o = ReadPbiTxt(o)             % Read PBI .TXT file            
%
% READPBITXT   Import a Postbond .TXT log file in order to return PBI data. 
%
%    PBI log file import for log files with .TXT extension. The result is
%    a list of trace object returned in the data part of the object.
%
%       o = ReadPbiTxt(arg(o,{filepath}));
%       o = ReadPbiTxt(arg(o,{'right_bk_2.pbi'}));
%
%    Data values are returned from ReadPbiTxt in the following data members:
%
%      type                  % data type 'pbi'
%      
%      par.path              % cluster path
%      par.sizes             % number of matrix rows & columns
%      par.pitch             % matrix pich x/y
%      par.method            % meander/sawtooth, by row/column
%      
%      dat.time              % t vector (time)
%      dat.x                 % x vector
%      dat.y                 % y vector
%      dat.th                % theta vector
%      dat.sys               % system number (left=1, right = 2, other = 0)
%      dat.i                 % row index vector
%      dat.j                 % col index vector
%      dat.bp                % bond position index
%
%   See also: CARAMEL
%
   filepath = arg(o,1);                % get file path from arg1
   o.data = {};                        % clear current data list
   o.work.filepath = filepath;         % store file information for later

   fid = fopen(filepath,'r');          % open input file
   if (fid < 0)
      error(['cannot import file: ',filepath]);
   end

   fseek(fid,0,+1);                    % go to end of file
   fsize = ftell(fid);                 % file eof position
   fseek(fid,0,-1);                    % go to begin of file
   
   o = var(o,'fid',fid);               % store file ID
   o = var(o,'fsize',fsize);           % store file size
   
% Call parser after anouncing parser start in a verbose message

   if (control(o,'verbose') >= 1)
      [~,fname,ext] = fileparts(work(o,'filepath'));
      fprintf('Reading file: %s\n',[fname,ext]);
      tstart = clock;
   end
   
   o = Parse1(o,fid);
   fclose(fid);

   if (control(o,'verbose') >= 1)
      count = var(o,'count');
      fprintf('Done - %g lines, elapsed time: %g s\n',...
         count,etime(clock,tstart));
   end
   %profiler('readtxt',0);
end
function o = Parse1(o,fid)             % Parse a .TXT Log File         
%
% PARSE   Parsing a .TXT post bond log file.
%
%    All Lexical units for the PBI import (tokens) are retrieved by
%    function Scan(). The parsing syntax of the PBI file is as follows
%
%    
%       Traces :={  {  "Parameter" <name> <value>
%                   }
%                   "Header"
%                   {  "Data" <line>
%                   }
%                   "Separator
%                   {  "Statistic"
%                   }
%                }
%                "Eof"
%
%    Return values are in the object variable var(o,'list') and
%    var(o,'count');
%
%       list      % list of parsed traces
%       count     % line count of parsed file
%
%    See also: READ, TOKEN
%
   %profiler('Parse',1);
   
   o = Scan1(o,fid);                         % init Scan1
   o = var(o,'list',{});                    % init trace list

% init parser variables

   o = var(o,'parse.par',[]);               % init trace parameters
   o = var(o,'parse.dat',[]);               % init trace data

% get first token from Scan1 and start actual parsing

   [o,symbol] = Scan1(o);                     % get next token
   while ~isequal(symbol,'Eof')
      while isequal(symbol,'Parameter')
         o = ParameterAction1(o);            % process parameters
         [o,symbol] = Scan1(o);               % get next token
      end
   
      Expect(o,symbol,'Header');            % expect symbol 'Header'
      [o,symbol] = Scan1(o);                  % eat - next token

      while isequal(symbol,'Data')
         o = DataAction1(o);                 % process data
         [o,symbol] = Scan1(o);               % get next token
      end

      Expect(o,symbol,'Separator');         % expect symbol 'Header'
      [o,symbol] = Scan1(o);                  % eat - next token

      while isequal(symbol,'Statistic')
         %o = StatisticAction1(o);           % process statistics
         [o,symbol] = Scan1(o);               % get next token
      end
      o = TraceAction1(o);                   % complete another Trace
   end
   
   Expect(o,symbol,'Eof');                  % expect symbol 'Eof'
   o = Scan1(o,0);                            % cleanup Scan1
   
   %profiler('Parse',0);
end
function o = DataAction1(o)            % Process Data Action           
%
% DATA-ACTION   Build up data arrays
%
%    Build up data arrays by appending data values of the token
%    at the end of the data arrays. Time must be treated specially,
%    since the starting time has to be subtracted of every time stamp
%    of an incoming token.
%
   %profiler('DataAction1',1);

   token = var(o,'token');
   parse = var(o,'parse');
   dat = parse.dat;
   
   if isempty(dat)
      parse.t0 = token.t;                    % init parse.t0 
      dat.time = 0;                          % timed always starts with 0
      dat.x = token.x;
      dat.y = token.y;
      dat.th = token.th;
      dat.i = token.ij(1);
      dat.j = token.ij(2);
      dat.sys = token.sys;
      dat.bp = 1; 
      parse.start = token.time;
   else
      t = token.t - parse.t0;
      while (t < 0) 
         t = t + 24*3600;                    % correct mid night jump
      end
      dat.time(end+1) = t;                   % time relative to start
      dat.x(end+1) = token.x;
      dat.y(end+1) = token.y;
      dat.th(end+1) = token.th;
      dat.i(end+1) = token.ij(1);
      dat.j(end+1) = token.ij(2);
      dat.sys(end+1) = token.sys;
      dat.bp(end+1) = 1;
   end
   
   parse.dat = dat;                          % pack dat into parse
   o = var(o,'parse',parse);                 % fast access

   %profiler('DataAction1',0);
end
function o = ParameterAction1(o)       % Process Parameter Action      
%
% PARAMETER-ACTION   Process new parameter
%
   [name,value] = Token(o,'name','value');
   for (i=1:length(name))
      if (name(i)==' ')
         name(i) = '_';
      end
   end
   o = var(o,['parse.par.',name],value);
   return
end
function o = StatisticAction1(o)       % Collect Statistic Results     
%
% STATISTIC-ACTION   Collect statistic results
%
   [name,value] = Token(o,'name','value');
   for (i=1:length(name))
      if (name(i)==' ')
         name(i) = '_';
      else
         name = name(i);
      end
   end
   o = var(o,['par.statistic.',name],value);
   return
end
function o = TraceAction1(o)           % Add New Trace Object          
%
% TRACE-ACTION   Add a new trace object to the return container object
%
   parse = var(o,'parse');            % unpack parse
   read = var(o,'read');              % unpack read

   oo = type(o,'pbi');                % start a type 'pbi' trace object
   oo = set(oo,'import',parse.par);   % set parameters   
   oo = data(oo,parse.dat);           % set data
   oo = var(oo,[]);                   % cleanup variables

      % provide file information

   [dir,fname] = fileparts(work(o,'filepath'));
   oo = set(oo,'import.file.filename',fname);
   oo = set(oo,'import.file.directory',dir);
      
      % provide sizes information
      
   msz = parse.par.Matrix_size;
   sz = [msz{1},msz{2}];
   sz(3) = length(parse.dat.time)/prod(sz);
   oo = set(oo,'sizes',sz);
   
      % provide method information
      
   proc = parse.par.Processing;
   
   method = [proc{1},'|',proc{2}];
   switch method
      case 'Sawtooth|By column'
         method = 'blcs';              % BotLeftColSawtooth
      case 'Sawtooth|By row'
         method = 'blrs';              % BotLeftRowSawtooth
      case 'Meander|By column'
         method = 'blcm';              % BotLeftColMeander
      case 'Meander|By row'
         method = 'blrm';              % BotLeftRowMeander';
   end
   oo = set(oo,'method',method);
   
      % provide gantry information
      
   sys = data(oo,'sys');
   if ~isempty(sys) && all(sys==1)
      oo = set(oo,'gantry','L');  gantry = 'left';
   elseif ~isempty(sys) && all(sys==2)
      oo = set(oo,'gantry','R');  gantry = 'right';
   else
      oo = set(oo,'gantry','D');  gantry = 'dual';
   end
   
      % set start date
      
   oo = set(oo,'time',parse.start);
   
   [date,time] = o.filedate(work(o,'filepath'));
   
   oo = set(oo,{'date'},date);
   oo = set(oo,{'time'},time);
   
      % set title
      
   path = work(o,'filepath');
   [~,title,~] = fileparts(path);
   title(1) = upper(title(1));
   oo = set(oo,'title',[get(oo,'time'),' ',title]);
   
      % provide machine information
      
   path = parse.par.FileVersion{3};  % cluster path
   directory = get(oo,'import.file.directory');
   filename = get(oo,'import.file.filename');
   idx = findstr('/950',directory);
   
   machine = '';
   if ~isempty(idx)
      idx = max(idx);
      machine = directory(idx+1:idx+11);
   end
   oo = set(oo,'machine',machine);

      % provide comments

   proc = parse.par.Processing;
   if all(parse.dat.sys == 1)
      system = 'left';
   elseif all(parse.dat.sys == 2)
      system = 'right';
   else
      system = 'dual';
   end
   comment{1} = ['Post Bond Inspection (',system,')'];
   comment{2} = sprintf('%g x %g matrix, %g repeats',sz(1),sz(2),sz(3));
   comment{3} = ['processing: ',lower(proc{1}),' / ',lower(proc{2})];
   comment{4} = ['machine: ',get(oo,'machine')];
   comment{5} = ['gantry: ',gantry];
   comment{6} = '';
   comment{7} = path;
   comment{8} = '';
   comment{9} = 'imported from';
   comment{10} = ['directory: ',directory];
   comment{11} = ['file name: ',filename];

   oo = set(oo,'comment',comment);
   
      % provide plot configuration
      
   oo = Config(oo);
   
      % append trace object to list of traces 
      
   o = add(o,oo);                      % add new trace object to end of list
   o = var(o,'count',read.count);      % pack count (number of lines in file)

   return
end
function [o,symbol] = Scan1(o,fid)     % User Defined Scan Function    
%
% SCAN1   User defined Scan callback
%
%    Syntax
%
%       o = Scan1(o,fid)           % init Scan1
%       [o,symbol] = Scan1(o)      % get next lexical unit (a line)
%
%    Tokens are line wise. The following token symbols will be used
%
%       "Data"           % a line starting with '['
%       "Header"         % a line starting with string 'Measurement
%       "Parameter"      % a sequence containing ':' and terminated with ';'
%       "Separator"      % a line starting with '-'
%       "Statistic"      % a line starting with 'statistic'
%
%    We make use of the following attributes:
%
%       token.symbol     % the token symbol
%       token.t          % log time in 'hh:mm:ss'
%       token.x          % post bond x-error
%       token.y          % post bond y-error
%       token.th         % post bond theta-error
%       token.ij         % [row col] index of bond position matrix
%       token.sys        % system (gantry) number
%
   
   if (nargin >= 2)
     o = Get(o,fid);            % init or cleanup READ variables
     return
   end

   %profiler('Scan1',1);
   
   token = [];                      % init token
   
      % continue to get a further line

   while(1)                         % loop until token processed
      [o,line,eof] = Get(o);           % get new line
      
      if (eof)
         symbol = 'Eof';
      elseif (find(o,'Measurement',line) == 1)
         symbol = 'Header';
      elseif (find(o,'[',line) == 1)
         symbol = 'Data';
         token = DataToken1(o,line);
      elseif (find(o,':',line) > 0)
         symbol = 'Parameter';
         token = ParameterToken1(o,line);
      elseif (find(o,'-',line) == 1)
         symbol = 'Separator';
      elseif (find(o,'statistic',line) == 1)
         symbol = 'Statistic';
         token = StatisticToken1(o,line);
      else
         if (control(o,'verbose') >= var(o,'read.verbose.echo'))
            fprintf(['*** line %g ignored!\n'],var(o,'read.count'));
         end
         continue;                  % continue with getting next line
      end
      break
   end
   
   token.symbol = symbol;          % pack symbol also into token
   o = var(o,'token',token);       % pack token into object variables

   %profiler('Scan1',0);
   return
end
function token = DataToken1(o,line)    % Build Data Token              
%
% DATA-TOKEN   Build Data token
%
   %profiler('DataToken1',1);

   isc = find(line==';');           % index of semicolons

   if (length(isc) ~= 6)
      error('6 occurences of '';'' expected for a data line!');
   end

   token.time = line(2:9);  
   sec = sscanf(['0.',line(11:13)],'%f');

      % now it follows a fast arithmetic to get time in seconds
      
   d = token.time - '00:00:00';        % difference
   token.t = [10*d(1)+d(2)]*3600 + [10*d(4)+d(5)]*60 + [10*d(7)+d(8)] + sec;

   token.ij = sscanf(line(isc(1):isc(3)),';%f;%f;')';
   
   gantry = line(isc(3)+1:isc(4)-1);
   
   switch lower(gantry)
      case 'left'
         token.sys = 1;
      case 'right'
         token.sys = 2;
      otherwise
         token.sys = 0;
   end         

   token.x = sscanf(line(isc(4)+1:isc(5)-1),'%f');
   token.y = sscanf(line(isc(5)+1:isc(6)-1),'%f');
   token.th = sscanf(line(isc(6)+1:end),'%f');
   
   %profiler('DataToken1',0);
   return
end
function token = ParameterToken1(o,line)% Build Parameter Token        
%
% PARAMETER-TOKEN   Build Parameter token
%
%    Parameter lines look like that:
%
%       FileVersion:;1;Cluster path:;/sd0/config/emc/advanced/MBMC_8k8.dcl
%       Startpoint:;G0;mm;-15.493832;42.176590;-0.054578
%       Processing:;Sawtooth;By column
%       Matrix size:;11;13
%       Pitch:;G0;mm;24.000000;24.000000
%       Repeats:;2
%
   line = o.trim(line);
   
   i = find(o,':',line);
   token.name = line(1:i-1);
   values = [line(i+1:end),';'];      % add stopper ';'
   
   isc = find(values==';');           % index of semicolons
   value = {};
   for (i=1:length(isc)-1)
      vali = values(isc(i)+1:isc(i+1)-1);
      value{i} = o.either(sscanf(vali,'%f'),vali); 
   end
   token.value = value;
   return
end
function token = StatisticToken1(o,line)% Build Statistic Token        
%
% STATISTIC-TOKEN   Build Statistic token
%
%    Statistic lines look as follows:
%
%       statistic;min;0.16; -1.77; -8.81; 
%       statistic;max;4.21; 2.35; 6.37; 
%       statistic;average;2.21; -0.20; -2.74; 
%       statistic;stddev;0.64; 0.79; 2.33; 
%       statistic;cm;1.55; 1.27; 4.30; 
%       statistic;cmk;0.41; 1.18; 3.91; 
%
   line = o.trim(line);
   
   isc = find(line==';');                    % index of semicolons
   token.name = line(isc(1)+1:isc(2)-1);
   for (i=2:length(isc)-1)
      vali = line(isc(i)+1:isc(i+1)-1);
      value{i-1} = o.either(sscanf(vali,'%f'),vali); 
   end
   token.value = value;
   return
end

%==========================================================================
% Read Driver for .pbi File
%==========================================================================

function o = ReadMbcPbi(o)             % Read .PBI file into MBC object
   o = ReadPbiPbi(o);
   for (i=1:data(o,inf))
      oo = o.data{i};
      if ~o.is(oo.type,{'pbi','mbc'})
         message(o,'Error: bad log file type!','PBI or MBC type expected!');  
      end
      oo.type = 'mbc';
      oo = config(oo);
      o.data{i} = oo;
   end
end
function o = ReadPbiPbi(o)             % Read Postbond .PBI file       
%
% READPBIPBI   Read a Postbond .PBI log file in order to return PBI data. 
%
%    PBI log file import for log files with .PBI extension. The result is
%    a list of trace object returned in the data part of the object.
%
%       o = ReadPbiPbi(arg(o,{filepath}));
%       o = ReadPbiPbi(arg(o,{'right_bk_2.pbi'}));
%
%    Data values are returned from ReadPbiPbi in the following data members:
%
%      type                            % data type 'stream'
%      
%      par.path                        % cluster path
%      par.sizes                       % number of matrix rows & columns
%      par.pitch                       % matrix pich x/y
%      par.method                      % meander/sawtooth, by row/column
%      
%      dat.time                        % t vector (time)
%      dat.x                           % x vector
%      dat.y                           % y vector
%      dat.th                          % theta vector
%      dat.sys               % system number (left=1, right = 2, other = 0)
%      dat.i                           % row index vector
%      dat.j                           % col index vector
%      dat.bp                          % bond position index
%
%   See also: PBI, IMPORT
%
   %profiler('readpbi',1);
   filepath = arg(o,1);          % get file path from arg1
   o.data = {};                  % clear current data list
   o.work.filepath = filepath;   % store file information for later

% Open the file to be imported

   fid = fopen(filepath,'r');    % open input file
   if (fid < 0)
      error(['cannot import file: ',filepath]);
   end

% Call parser after anouncing parser start in a verbose message

   if (control(o,'verbose') >= 1)
      [~,fname,ext] = fileparts(work(o,'filepath'));
      fprintf('Reading file: %s\n',[fname,ext]);
      tstart = clock;
   end
   
   o = Parse2(o,fid);
   fclose(fid);

   if (opt(o,'verbose') >= 1)
      count = var(o,'count');
      fprintf('Done - %g lines, elapsed time: %g s\n',...
         count,etime(clock,tstart));
   end
   
   %profiler('readpbi',0);
end
function o = Parse2(o,fid)             % Parse a .PBI Log File         
%
% PARSE   Parsing a .TXT post bond log file.
%
%    See also: READ, TOKEN
%
   %profiler('Parse2',1);
   o = verbose(with(o,'shell'),'bit',1,'some',2);
   
   o = Scan2(o,fid);                    % init Scan2
   o = var(o,'list',{});               % init trace list

% init parser variables

   o = var(o,'parse.par',[]);          % init trace parameters
   o = var(o,'parse.dat',[]);          % init trace data

% get first token from Scan2 and start actual parsing

   if var(o,'verbose.bit')
      fprintf('   reading PBI file ...\n');
      ticstart = tic;
   end

   bulk = textscan(fid,'%s %s %s %s %s %s %s','Delimiter','|');
   
   T = bulk{2}; 
   S = bulk{3};
   X = bulk{4};
   Y = bulk{5};
   Th = bulk{6};

   while ~isempty(T)
      idx = find(o,'Production start',T(3:end)) + 2;
      if (idx == 2)
         idx = 1:length(T);                         % we are done
      else
         idx = 1:idx-1;
      end
      
      token = DataToken2(o,T(idx),S(idx),X(idx),Y(idx),Th(idx));
      o = var(o,'token',token);
      
      T(idx)  = [];
      S(idx)  = [];
      X(idx)  = [];
      Y(idx)  = [];
      Th(idx) = [];
      
      
      o = DataAction2(o);
      o = TraceAction2(o);
   end
   
   
   if var(o,'verbose.bit')
      fprintf('   importing data complete (%g s)\n',toc(ticstart));
   end
   
   %profiler('Parse2',0);
   return                              % return values in var(o,'list')
end
function o = DataAction2(o)            % Process Data Action           
%
% DATA-ACTION   Build up data arrays
%
%    Build up data arrays by appending data values of the token
%    at the end of the data arrays. Time must be treated specially,
%    since the starting time has to be subtracted of every time stamp
%    of an incoming token.
%
   %profiler('DataAction2',1);

   token = var(o,'token');
   parse = var(o,'parse');
   dat = parse.dat;
   
   t = token.t;
   for (i=1:length(t))
      while (t(i) < 0) 
         t(i) = t(i) + 24*3600;        % correct mid night jump
      end
   end
   dat.time = t;                       % time relative to start
   dat.x = token.x;
   dat.y = token.y;
   dat.th = token.th;
   dat.sys = token.sys;
   dat.bp = 1 + 0*t;
   
   parse.start = token.time;           % put start time
   parse.dat = dat;                    % pack dat into parse
   o = var(o,'parse',parse);           % fast access

   %profiler('DataAction2',0);
   return
end
function o = ParameterAction2(o)       % Process Parameter Action      
%
% PARAMETER-ACTION   Process new parameter
%
   [name,value] = Token(o,'name','value');
   for (i=1:length(name))
      if (name(i)==' ')
         name(i) = '_';
      else
         name = name(i);
      end
   end
   o = var(o,['parse.par.',name],value);
   return
end
function o = TraceAction2(o)           % Add New Trace Object          
%
% TRACE-ACTION   Add a new trace object to the return container object
%
   either = @o.either;                 % need some utility
   
   parse = var(o,'parse');             % unpack parse
   read = var(o,'read');               % unpack read

   oo = type(o,'pbi');                 % start a type 'stream' trace object
   oo = set(oo,'import',parse.par);    % set parameters   
   oo = data(oo,parse.dat);            % set data
   oo = var(oo,[]);                    % cleanup variables

      % provide file information

   filepath = o.work.filepath;         % recall file information for later
   [directory,filename] = fileparts(filepath);
   oo = set(oo,'import.file.filename',filename);
   oo = set(oo,'import.file.directory',directory);
   
      % extract title from container name
      
   name = directory;
   if length(name) > 0 && (name(end) == '\' || name(end) == '/')
      name(end) = '';
   end
   [~,fpart,xpart] = fileparts(name);
   name = [fpart,xpart];
   
      % provide sizes information
      
   %msz = parse.par.Matrix_size;
   %sz = [msz{1},msz{2}];
   %sz(3) = length(parse.dat.time)/prod(sz);
   
   rows = either(opt(o,'pbi.rows'),1);
   cols = either(opt(o,'pbi.columns'),1);
   %sz = [1 1 length(parse.dat.time)];
   sz = [rows cols length(parse.dat.time)/rows/cols];
   
   oo = set(oo,'sizes',sz);
   
      % provide method information
      
   %proc = parse.par.Processing;
   
   %method = [proc{1},'|',proc{2}];
   start = either(opt(o,'pbi.start'),'bl');
   path = either(opt(o,'pbi.path'),'');
   if isempty(path)
      method = '';
   else
      method = [start,path];
   end
         
   switch method
      case 'Sawtooth|By column','blcs'
         method = 'blcs';
      case 'Sawtooth|By row'
         method = 'blrs';
      case 'Meander|By column'
         method = 'blcm';
      case 'Meander|By row'
         method = 'blrm';
   end
   oo = set(oo,'method',method);
   
      % provide gantry information
      
   sys = data(oo,'sys');
   if ~isempty(sys) && all(sys==1)
      oo = set(oo,'gantry','L');  gantry = 'left';
   elseif ~isempty(sys) && all(sys==2)
      oo = set(oo,'gantry','R');  gantry = 'right';
   else
      oo = set(oo,'gantry','D');  gantry = 'dual';
   end
   
      % set start date
      
   oo = set(oo,'time',parse.start);
   %[~,~,~,date,time] = file(o);       % get file date/time
   [date,time] = o.filedate(work(o,'filepath'));
   
   oo = set(oo,{'date'},date);
   oo = set(oo,{'time'},time);
   
      % set title
      
   if isempty(name)
      path = work(o,'filepath');
      [~,title,~] = fileparts(path);
      title(1) = upper(title(1));
      title = [get(oo,'time'),' ',title];
   else
      title = [name,' (',get(oo,'time'),')'];
   end
   oo = set(oo,'title',title);
   
      % provide empty machine information
      
   machine = '';
   oo = set(oo,'machine',machine);

      % provide comments

   proc = {'???','???'};
   if all(parse.dat.sys == 1)
      system = 'left';
   elseif all(parse.dat.sys == 2)
      system = 'right';
   else
      system = 'dual';
   end
   comment{1} = ['Post Bond Inspection (',system,')'];
   comment{2} = sprintf('%g x %g matrix, %g repeats',sz(1),sz(2),sz(3));
   comment{3} = ['processing: ',lower(proc{1}),' / ',lower(proc{2})];
   comment{4} = ['machine: ',get(oo,'machine')];
   comment{5} = ['gantry: ',gantry];
   comment{6} = '';
   comment{7} = 'imported from';
   comment{8} = ['directory: ',directory];
   comment{9} = ['file name: ',filename];

   oo = set(oo,'comment',comment);
   
      % provide plot configuration
      
   oo = Config(oo);
   
      % append trace object to list of traces 
      
   o = add(o,oo);                      % add new trace object to end of list
   o = var(o,'count',read.count);      % pack count (number of lines in file)
end
function [o,symbol] = Scan2(o,fid)     % User Defined Scan Function    
%
% SCAN2   User defined Scan callback
%
%    Syntax
%
%       o = Scan2(o,fid)           % init Scan2
%       [o,symbol] = Scan2(o)      % get next lexical unit (a line)
%
%    Tokens are line wise. The following token symbols will be used
%
%       "Data"           % a line starting with '['
%       "Header"         % a line starting with string 'Measurement
%       "Parameter"      % a sequence containing ':' and terminated with ';'
%       "Separator"      % a line starting with '-'
%       "Statistic"      % a line starting with 'statistic'
%
%    We make use of the following attributes:
%
%       token.symbol     % the token symbol
%       token.t          % log time in 'hh:mm:ss'
%       token.x          % post bond x-error
%       token.y          % post bond y-error
%       token.th         % post bond theta-error
%       token.ij         % [row col] index of bond position matrix
%       token.sys        % system (gantry) number
%
   
   if (nargin >= 2)
     o = Get(o,fid);               % init or cleanup READ variables
     return
   end

   %profiler('Scan2',1);
   
   token = [];                      % init token
   
      % continue to get a further line

   while(1)                         % loop until token processed
      [o,line,eof] = Get(o);       % get new line
      
      if (eof)
         symbol = 'Eof';
      elseif (find(o,'|',line) == 1)
         symbol = 'Data';
         fid = var(o,'read.fid');
         tic
         bulk = textscan(fid,'%s %s %f %f %f %s %s','Delimiter','|');
         toc
         
         token = DataToken2(o,line,bulk);
         count = var(o,'read.count') + length(bulk{1});
         o = var(o,'read.count',count);
      elseif (find(o,':',line) > 0)
         symbol = 'Parameter';
         token = ParameterToken2(o,line);
      else
         if (opt(o,'verbose') >= var(o,'read.verbose.echo'))
            fprintf(['*** line %g ignored!\n'],var(o,'read.count'));
         end
         continue;                  % continue with getting next line
      end
      break
   end
   
   token.symbol = symbol;          % pack symbol also into token
   o = var(o,'token',token);       % pack token into object variables

   %profiler('Scan2',0);
   return
end
function token = DataToken2(o,T,S,X,Y,Th)    % Build Data Token        
%
% DATA-TOKEN   Build Data token
%
   Rd = @o.rd;
   
   %profiler('DataToken2',1);

   line = S{1};
   idx = find(o,'Time: ',line);
   if (idx > 0)
      token.time = line(idx+6:idx+13);  
   else
      token.time = 0;
   end
   sec = 0;

      % now it follows a fast arithmetic to get time in seconds
      
   token.ij = [];
   token.t = [];
   token.x = [];
   token.y = [];
   token.th = [];
   token.sys = [];

   startvec = datevec(token.time);

   if var(o,'verbose.bit')
      fprintf('   processing bulk data ...\n');
   end
   
   n = length(T);
   for (i=1:n-2)
      k = i+2;
      ti = T{k};
      t = etime(datevec(ti),startvec);
      token.t(i) = t;
      token.x(i) = sscanf(X{k},'%f');
      token.y(i) = sscanf(Y{k},'%f');
      token.th(i) = sscanf(Th{k},'%f');
      
      sys = S{k};
      if isequal(sys,'Left')
         token.sys(i) = 1;
      elseif isequal(sys,'Right')
         token.sys(i) = 2;
      else
         token.sys(i) = 0;
      end
      
      if (rem(i,100) == 0)
         set(figure(o),'name',sprintf('time = %s (%g %%)',ti,Rd(i/n*100,0)));
         shg
      end
   end
   
   set(figure(o),'name',get(o,'title'));
   %profiler('DataToken2',0);
   return
end
function token = ParameterToken2(o,line)% Build Parameter Token        
%
% PARAMETER-TOKEN   Build Parameter token
%
%    Parameter lines look like that:
%
%       FileVersion:;1;Cluster path:;/sd0/config/emc/advanced/MBMC_8k8.dcl
%       Startpoint:;G0;mm;-15.493832;42.176590;-0.054578
%       Processing:;Sawtooth;By column
%       Matrix size:;11;13
%       Pitch:;G0;mm;24.000000;24.000000
%       Repeats:;2
%
   line = trim(o,line);
   
   i = find(o,':',line);
   token.name = line(1:i-1);
   values = [line(i+1:end),';'];      % add stopper ';'
   
   isc = find(values==';');           % index of semicolons
   value = {};
   for (i=1:length(isc)-1)
      vali = values(isc(i)+1:isc(i+1)-1);
      value{i} = either(sscanf(vali,'%f'),vali); 
   end
   token.value = value;
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [o,line,eof] = Get(o,arg1,arg2)% Get Line or Bulk from File   
%
% Get   Universal line reader for file parsing
%
%    Syntax:
%
%       o = Get(o,fid);                % initialize GET function
%       [o,line,eof] = Get(o);         % read next line
%       [o,bulk,eof] = Get(o,m,n);     % read mxn bulk data
%       [o,bulk,eof] = Get(o,m,inf);   % read mxn bulk data until eof
%
%       o = Get(o,'error',msg);        % record a parsing error message
%       o = Get(o,'warning',msg);      % record a parsing error warning
%
%    Function Get is controlled by a set of state variables.
%
%       state = var(o,'read');         % unpack state variables from object
%       o = var(o,'read',state);       % pack state variables into object
%       
%    During initialization READ sets up an object variable 'read' with the
%    following structure members: 
%
%       read.fid                       % file ID
%       read.line                      % current line
%       read.count                     % current line count
%       read.index                     % current line index
%       read.verbose.echo              % verbose level for line echo
%       read.verbose.periode           % periode for progress messages
%       read.verbose.actual            % actual verbose level setting
%       read.message                   % actual progress message
%       read.errors                    % list of error messages
%
%   Get uses option 'verbose' to control verbose talking like line echo
%   of the input file and periodic progress messages in the figure head line.
%   
%   Example: typical sequence for a user defined scan function
%
%      function o = Lex(o,fid)
%      if (nargin == 2)
%         o = Get(o,fid);
%         return
%      end
%
%      while(1)                        % loop until token processed
%         [o,line,eof] = Get(o);
%         if (eof)
%            token.symbol = 'Eof';
%         elseif (find(o,'Measurement',line) > 0)
%            token.symbol = 'Header';
%         elseif (find(o,'[',line) == 1)
%            token.symbol = 'Data';
%         else
%            continue
%         end
%         break
%      end
%      o = var(o,'token',token);
%      return
%         
%   See also: CORE, TOKEN, EXPECT, PROGRESS
%
   eof = 0;                               % by default
   if (nargin == 1)
      [o,line,eof] = GetLine(o);          % get next input line
   elseif (nargin == 2)
      if ~isa(arg1,'double')
         error('integer file ID expected for arg2!');
      end
      if (arg1 > 0)
         o = InitRead(o,arg1);                % init read state
      else
         o = Cleanup(o);                  % cleanup read
      end
   elseif (nargin == 3)
      if (isa(arg1,'double'))
         m = arg1;  n = arg2;             % bulk of mxn matrix data
         [o,bulk,eof] = GetBulk(o,m,n);   % get bulk data
         line = bulk;                     % return as output arg2
      else
         o = Record(o,arg1,arg2);         % message recording
      end
   else
      error('bad calling syntax!');
   end
end
function o = InitRead(o,fid)           % Initialize Read System        
%
% INITREAD   Init read state
%
   path = o.work.filepath;             % recall file information
   [dir,fname,~] = fileparts(path);    % split into directory & filename
   
   verbose = o.either(opt(o,'verbose'),0);

   read.fid = fid;                     % file id
   read.line = '';                     % current line
   read.count = 0;                     % current line count
   read.index = 0;                     % current line index
   read.verbose.echo = 2;              % verbose level for line echo
   read.verbose.periode = 50;          % modulus for progress messages
   read.verbose.actual = verbose;      % actual verbose level setting
   read.message = '';                  % progress message
   read.directory = dir;               % input directory
   read.filename = fname;              % input file name
   read.record = [];                   % message recording

   msg = ['Importing file: ',fname];   % initial progress message
   o = Progress(o,msg,20);             % init progress, periode = 20

   o = var(o,'read',read);             % pack state variable 'read'
end
function o = Cleanup(o)                % Cleanup Read System           
%
% EXIT   Exit read - cleanup
%
   o = Progress(o);                    % done, restore saved headline
   o = var(o,'read',[]);               % cleanup
   o = var(o,'progress',[]);           % cleanup
   return
end
function [o,line,eof] = GetLine(o)     % Get Next Line From Input File 
%
% GETLINE   Get next line from input file
%
   variables = var(o);                 % unpack variables
   read = variables.read;              % unpack state from variable 'read'
   
   read.line = fgetl(read.fid);        % get line from input file
   read.eof = ~ischar(read.line);
   read.count = read.count + 1;        % count number of input lines
   read.index = 1;                     % line index @ begin of line

% In case of eof we have to undo our line counting

   if (read.eof)   
      line = ''; 
      read.count = read.count - 1;     % undo counting
   end
   
% trace input file in verbose mode

   if (~read.eof && read.verbose.actual >= read.verbose.echo)
      fprintf(['%05.0f: ',read.line,'\n'],read.count);
   end

% update progress information

   if (rem(read.count,read.verbose.periode) == 0)
      message = sprintf('Reading %s: line %g',read.filename,read.count);
      o = Progress(o,message);         % display progress        
   end
   
% pack state into object variable 'read', set out arg2 and return

   variables.read = read;              % pack read into variables
   o = var(o,variables);               % pack variables
   
   line = read.line;                   % unpack line for out arg
   eof = read.eof;                     % unpack eof for out arg
   return
end
function [o,bulk,eof] = GetBulk(o,m,n) % Get Bulk Data from File       
%
% GETBULK   Get bulk from input file
%
   read = var(o,'read');               % unpack state from variable 'read'
   
   %[bulk,count] = fscanf(read.fid,'%f',[n,inf]); 
   [bulk,count] = fscanf(read.fid,'%f',[m,n]);
   bulk = bulk';
   read.count = read.count + size(bulk,1);    % update line count 
   
   read.eof = 0;
   read.index = 1;                     % line index @ begin of line

% pack state into object variable 'read', set out arg2 and return

   o = var(o,'read',read);             % pack state variable 'read'
   eof = read.eof;                     % unpack eof for out arg
end
function o = Record(o,tag,msg)         % Record Error Message          
%
% ERROR   Print and record error message
%
   read = var(o,'read');               % unpack state
   
   if ~isempty(tag)
      tag = lower(tag);  tag(1) = upper(tag(1));
   end
   
   txt = sprintf(['*** %s in line %03.0f: %s'],tag,read.count,msg);
   fprintf([txt,'\n']);

   switch(tag)
      case 'Error'
         list = either(var(o,'read.record.errors'),{});
         list{end+1} = txt;            % record error text
         read.record.errors = list;
      case 'Warning'
         list = either(var(o,'read.record.warnings'),{});
         list{end+1} = txt;            % record error text
         read.record.warnings = list;
      otherwise
         error('bad tag (arg2)');
   end
   
   o = var(o,'read',read);             % pack state variable 'read'
   return
end
function varargout = Token(o,varargin) % Access Token                  
%
% TOKEN   Convenient function to access parts of a token which has been
%         returned by LEX in the object variables var(o,'token')
%
%   1) Access parts of a token: Let's assume our token has attributes a1,
%   a2, a3, ... which are packed by LEX into an object
%
%      o = var(o,'token.a1',a1,'token.a2',a2,...)
%
%   Then the following easy syntax allows access to the attributes:
%
%      a1 = Token(o,'a1')
%      a2 = Token(o,'a2')
%      a3 = Token(o,'a3')
%   
%      [a1,a2,a3] = Token(o,'a1','a2','a3')
%
%   2) Access token symbol efficiently
%
%      symbol = Token(o)                % get token symbol
%      symbol = var(o,'token.symbol')   % same as above
%
%   3) relational comperison of token symbol with literal: Since checking
%   a token symbol against a literal is a very frequent operation in a
%   parser an efficient syntax supports such kinds of expressions
%
%      equal = Token(o,'==','Data')     % token symbol equals 'Data'?
%      noteq = Token(o,'~=','Data')     % token symbol not equals 'Data'?
%
%   4) Expect a token.
%
%      Token(o,'!','Header')            % error message if not matching
%      Token(o,'!',{'Header','Data'})   % error message if not matching
%
%      o = Token(o,'!','Header')     % return match status (no error)
%      o = Token(o,'!',{'Header','Data'})  
%
%   Above two statements are equivalent with the following two ones:
%
%      equal = strcmp(var(o,'token.symbol'),'Header')
%      noteq = ~strcmp(var(o,'token.symbol'),'Header')
%
%   See also: LEX, EAT
%
   
      % all input args arg2, arg3, arg4, ... are expected to be strings
      % in order to save computing time we intentionally do not explicitely
      % check consistency with string type
      
   token = var(o,'token');                % fast access to token
   
   if (nargin <= 1)
      varargout{1} = tok.symbol;
   elseif strcmp(varargin{1},'==') && (nargin == 3)
      varargout{1} = strcmp(tok.symbol,varargin{2});
   elseif strcmp(varargin{1},'~=') && (nargin == 3)
      varargout{1} = ~strcmp(var(o,'token.symbol'),varargin{2});
   elseif strcmp(varargin{1},'!') && (nargin == 3)
      good = (match(varargin{1},varargin{3}) ~= 0);
      if (~good)
         list = varargin{3};
         if iscell(list)
            fprintf('*** error: symbol expected to be %s',list{1});
            for (i=2:length(list))
               fprintf(', %s',list{i});
            end
            fprintf('\n');
         else
            fprintf('*** error: symbol expected to be %s',list{1});
         end
         errcnt = var(o,'parse.errcnt');
         o = var(o,'parse.errcnt',errcnt+1);
      end
      varargout{1} = o;
   else
      if (nargout+1 ~= nargin) && ~(nargout <= 1 && nargin == 2)
         error('number of input args must equal 1 + number of output args');
      end
      
      for (i=1:length(varargin))
         tag = varargin{i};
         varargout{i} = eval(['token.',tag],'[]');
      end
   end
   return
end
function good = Expect(o,symbol,arg)   % Expect Certain Token          
%
% EXPECT   Expect a symbol or list of symbols during parsing
%          
%    Function EXPECT looks into the current token and checks whether the
%    symbol matches an expected symbol or a list of expected symbols.
%    
%       good = Expect(o,symbol,'Header');
%       good = Expect(o,symbol,{'Header','Data'});
%
%    The matching result is returned as boolean value. If no match then an
%    error message is printed, but no error is raised. 
%
%    The calling function is responsible for raing of errors based on the
%    return value of EXPECT (if this is required).
%
%    See also: CARAPBI, READ, TOKEN
%
   good = isequal(symbol,arg);
   
   if (~good)
      if iscell(arg)
         list = arg;
         msg = sprintf('symbol expected to be ''%s''',list{1});
         for (i=2:length(list))
            msg = [msg,sprintf(', ''%s''',list{i})];
         end
      else
         msg = sprintf('symbol expected to be ''%s''',arg);
      end
      o = read(o,'error',msg);       % print & record parser error message
   end
end
function o = Progress(o,msg,periode)   % Show a Progress Message       
%
% PROGRESS   Display a progress message in the figure head line
%        
%    Repeated calls to PROGRESS will increment an internal counter. Once
%    counter reaches the value of period a progress message is updated in
%    the header line of current figure.
%
%    Syntax
%
%       Progress(o,msg);                   % update progress message
%
%       o = Progress(o,msg,periode)        % init progress
%       o = Progress(o,msg,20)             % init, periode = 20
%       o = Progress(o,mesg)               % init, periode = inf
%       o = Progress(o);                   % done, restore saved headline
%
%    PROGRESS works with the internal state
%
%       var(o,'progress.fig')              % figure to display message 
%       var(o,'progress.savename')         % save figure name
%       var(o,'progress.count')            % periode for refreshing
%       var(o,'progress.periode')          % periode for refreshing
%
%    See also: CARMA, GETLINE, EAT
%
   if (nargin == 1)                        % done, restore saved headline
      savename = o.either(var(o,'progress.savename'),'');
      set(gcf,'name',savename);
      o = ProgressBar(o,inf);
   elseif (nargin == 2) && (nargout > 0)   % initialize progress message
      o = Progress(o,msg,inf);
      o = ProgressBar(o,msg);
      return
   elseif (nargin == 2) && (nargout == 0)  % refresh progress message
      count = var(o,'progress.count') + 1;
      o = var(o,'progress.count',count);

      periode = var(o,'progress.periode');
      periode = count;                     % overwrite
      
      if (rem(count,periode) == 0)
         if ~ischar(msg)
            error('string expected for arg2');
         end
         fig = var(o,'progress.fig');   
         set(fig,'name',msg);
         shg;
         o = ProgressBar(o);               % update
      end
   elseif (nargin == 3)                    % init, save actual head line
      fig = figure(o);
      o = var(o,'progress.fig',fig);   
      o = var(o,'progress.savename',get(fig,'name'));   
      o = var(o,'progress.count',0);
      o = var(o,'progress.periode',periode);
      if ischar(msg)
         set(fig,'name',msg);
      end
      shg
   else
      error('1,2 or 3 input args expected!');
   end
   return
   
   function o = ProgressBar(o,msg)
   %
   % PROGRESSBAR   Open, update, close progress bar
   %
   %                  o = ProgressBar(o,msg)     % open progressbar
   %                  o = ProgressBar(o)         % update progressbar
   %                  o = ProgressBar(o,inf)     % close progressbar
   %
      return % ignore so far
      if (nargin == 2) && ischar(msg)            % open progress bar
         hbar = var(o,'hbar');                   % handle to wait bar
         if isempty(hbar)
            hbar = waitbar(0,msg);
            o = var(o,'hbar',hbar);              % store waitbar handle
         else
            o = ProgressBar(o);                  % update
         end
      elseif (nargin == 1)                       % update progress bar
         fid = var(o,'fid');
         fsize = var(o,{'fsize',NaN});
         
         if ~isnan(fsize) && ~isempty(fid)
            percent = round(100*ftell(fid)/fsize); 
            hbar = var(o,'hbar');      % handle to wait bar
            if ~isempty(hbar)
               waitbar(percent/100,hbar);
            end
         end
      elseif (nargin == 2) && isequal(msg,inf)
         hbar = var(o,'hbar');         % handle to wait bar
         close(hbar);
      else
         error('bad calling syntax!');
      end
   end
end
