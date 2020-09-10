function oo = read(o,varargin)         % Read CARAMEL Object From File 
%
% READ   Read a CARAMEL object from file.
%
%             oo = read(o,'ReadPkgPkg',path) % Package Info .pkg driver
%             oo = read(o,'ReadGenDat',path) % General Log Data .dat driver
%             oo = read(o,'ReadSmpDat',path) % Simple or Plain .dat driver
%             oo = read(o,'ReadVibTxt',path) % Vibration test .txt driver
%             oo = read(o,'ReadBmcTxt',path) % BMC test .txt driver
%             oo = read(o,'ReadPbiPbi',path) % PBI .pbi data driver
%
%          Besides of READ drivers there are also auxillary functions
%          for partial read tasks:
%
%             oo = read(o,'Open',path) % open file & create object
%             oo = read(oo,'Init')     % init object
%             oo = read(oo,'Type')     % extract object type
%             oo = read(oo,'Param')    % read parameters
%             oo = read(oo,'Head')     % read header
%             oo = read(oo,'Data')     % read data
%             oo = read(oo,'Config')   % configure plotting
%             oo = read(oo,'Close')    % close file & cleanup object
%             oo = read(o,'Snif',path) % Snif Parameters
%
%          Also possible to get next line from file, updating line number
%          and verbose talking
%
%             oo = read(oo,'Line')
%             line = var(o,'line')     % EOF for ~ischar(line)
%
%          See also: CARAMEL, IMPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@Line,...
                @Open,@Init,@Type,@Param,@Head,@Data,@Config,@Close,...
                @Snif,@ReadPkgPkg,@ReadSmpDat,@ReadGenDat,@ReadPbiPbi,...
                @ReadBmcPbi,@ReadVibTxt);
   oo = gamma(oo);
end

function o = Error(o)                  % Default Error Method          
   error('two input args expected!');
end

%==========================================================================
% Package Info File Driver
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for .pkg File     
   oo = Snif(o);                       % read parameters   
   oo = subplot(oo,'color',[0.95 0.8 0.5]);
end

%==========================================================================
% Simple Read Driver
%==========================================================================

function oo = ReadSmpDat(o)            % Read Driver for .log File     
   path = arg(o,1);                    % get path arg
   
   oo = read(o,'Open',path);           % open file & create object
   oo = read(oo,'Type');               % read type
   oo = read(oo,'Param');              % read parameters
   oo = read(oo,'Head');               % read data header
   oo = read(oo,'Data');               % read data
   oo = read(oo,'Config');             % configure plotting
   oo = read(oo,'Close');              % close file & cleanup object
end

%==========================================================================
% Universal Logfile Read Driver
%==========================================================================

function oo = ReadGenDat(o)            % General Read Driver (.dat)    
   path = arg(o,1);                    % get path arg
   
   oo = read(o,'Open',path);           % open file & create object
   oo = read(oo,'Type');               % read type
   oo = read(oo,'Param');              % read parameters
   oo = read(oo,'Head');               % read data header
   oo = read(oo,'Data');               % read data
   oo = read(oo,'Config');             % configure plotting
   oo = read(oo,'Close');              % close file & cleanup object
end

%==========================================================================
% Vibration Test Data File Read Driver
%==========================================================================

function oo = ReadVibTxt(o)            % Read Driver for VIB Object    
%
% VIBTXTDRV   Read diver for VIB log file (vibration test)
%
   path = arg(o,1);                    % get path argument

   oo = caramel('list');               % create a container object
   ooo = read(o,'Open',path);          % open log file & create object
   ooo = Type(ooo);                    % read type
   while ischar(var(ooo,'line'))
      ooo = read(ooo,'Init');          % init object
      ooo = Param(ooo);                % read parameters
      ooo = Head(ooo);                 % read head
      ooo = Data(ooo);                 % read data
      ooo = Config(ooo);               % configure for plotting
      oo = add(oo,ooo);                % add object to container
   end
   ooo = read(ooo,'Close');            % close file & cleanup object
   return

   function o = Type(o)                % Read Object Type              
      typ = 'vib';                     % type we are dealing with
      o.type = typ;                    % set type

      o = read(o,'Type');              % read type
      if ~isequal(o.type,typ)
         error('unexpected log file type!');
      end
   end
   function o = Param(o)               % Read Object Parameters        
   %
   % PARAM   Extract parameters from VSC log file by (dummy read)
   %         A VSC log file does not contain a lot of information
   %
   %            X Y
   %            1130.000000 1405.000000
   %            1182.000000 1465.000000
   %                 :     :     :    :
   %
      o = read(o,'Param');             % extract parameters, if provided
      
      path = var(o,{'path',''});
      if ~isempty(path)
         inst = var(o,{'instance',0});
         title = sprintf('Vibration Test (%g)',inst);
         
         [date,time] = o.filedate(path);
         o = set(o,{'date'},date);
         o = set(o,{'time'},time);
         o = set(o,{'title'},[o.par.date,' @ ',o.par.time,' ',title]);
         
         [dir,file] = fileparts(path);
         o = set(o,{'comment'},{title});
         o.par.comment{end+1} ='';
         o.par.comment{end+1} = ['File: ',file];
         o.par.comment{end+1} = ['Directory: ',dir];
      end
      
         % if no title or comment provided
         
      o = set(o,{'title'},'Vibration Test');
      o = set(o,{'comment'},{'Vibration test'});
   end
   function o = Head(o)                % Read Data Header              
      fid = var(o,'fid');              % get file ID
      o = read(o,'Line');              % read header (and ignore)
      o = var(o,'symbols',{'x','y'});  % setup symbols
      o = var(o,'units',{'µ','µ'});    % setup units
      o = var(o,'format','%f %f');     % setup format
   end
   function o = Data(o)                % Read Data                     
      o = read(o,'Data');              % read data
      o.data.x = o.data.x/1000;        % convert to µm
      o.data.y = o.data.y/1000;        % convert to µm
   end
   function o = Config(o)              % Configure Object              
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = category(o,1,[-0.5 0.5],[0 0],'µ');
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{2,'b',1});
   end
end

%==========================================================================
% BMC Test Data File Read Driver
%==========================================================================

function oo = ReadBmcTxt(o)            % Read Driver for BMC .txt File 
   path = arg(o,1);                    % get path argument
   oo = read(o,'Open',path);           % open log file & create object
   oo = Type(oo);                      % read type
   oo = Param(oo);                     % read parameters
   oo = Data(oo);                      % read data
   oo = Config(oo);                    % configure for plotting
   oo = read(oo,'Close');              % close file & cleanup object
   return

   function o = Type(o)                % Read Type of BMC Object       
      typ = 'bmc';                     % type we are dealing with
      o.type = typ;                    % set type

      o = read(o,'Type');              % read type
      if ~isequal(o.type,typ)
         error('unexpected log file type!');
      end
   end
   function o = Param(o)               % Read Parameters of BMC Object 
   %
   % BMCPARAM   Extract parameters from BMC log file by reading first line
   %            which looks like: "BMC-Test 24.10.2015 - 01:36 - system 2"
   %
      fid = var(o,'fid');              % get file ID
      line = fgetl(fid);               % read first line of file
      if ~o.is(line(1:8),'BMC-Test')
         error('String ''BMC-Test'' expected in first line!');
      end

      o.par.comment = {line};
      date = line(10:19);
      o.par.date = datestr(datenum(date,'dd.mm.yyyy'));
      time = line(23:27);
      o.par.time = [time,':00'];

      o.par.gantry = o.assoc(line(end),{{'1','L'},{'2','R'},''}); 
      title = [o.par.date,' @ ',o.par.time,' BMC Test'];
      gantry = o.assoc(o.par.gantry,{{'L','Left'},{'R','Right'},'?'});
      o.par.title = sprintf('%s %s',title,gantry);
   end
   function o = Data(o)                % Read Data of BMC Object       
      fid = var(o,'fid');              % get file ID
      log = [];
      while(1)
         line = fgetl(fid);
         if isequal(line,-1)
            break;
         end
         idx = find(line==',');
         if ~isempty(idx)
            line(idx) = '.' + zeros(size(idx));   % replace ',' by '.'
         end
         vec = sscanf(line,'%f');
         log(end+1,1:4) = vec(:)';
      end
      o.data.t = log(:,1)';
      o.data.x = log(:,2)';
      o.data.y = log(:,3)';
      o.data.th = log(:,4)';

      o.par.sizes = [1,1,size(log,1)];
      o.par.method = 'blcs';
   end
   function o = Config(o)              % Configure Plotting            
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = category(o,1,[-2 2],[0 0],'µ');      % category 1 for x,y
      o = category(o,2,[-50 50],[0 0],'m°');   % category 2 for p
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'th',{2,'g',2});
   end
end

%==========================================================================
% PBI File Read Driver
%==========================================================================

function oo = ReadPbiPbi(o)            % Read Driver for .log File     
   path = arg(o,1);                    % get path argument

   oo = caramel('list');               % create a container object
   oo.tag = o.tag;                     % copy tag from input arg object
   oo = balance(oo);                   % convert to input arg class
   
   ooo = read(o,'Open',path);          % open log file & create object
   ooo = Type(ooo);                    % read type
   while ischar(var(ooo,'line'))
      ooo = read(ooo,'Init');          % init object
      ooo = Param(ooo);                % read parameters
      ooo = Head(ooo);                 % read head
      ooo = Data(ooo);                 % read data
      ooo = Config(ooo);               % configure for plotting
      oo = add(oo,ooo);                % add object to container
   end
   ooo = read(ooo,'Close');            % close file & cleanup object
   return

   function o = Type(o)                % Read Object Type              
      typ = 'pbi';                     % type we are dealing with
      o.type = typ;                    % set type

      o = read(o,'Type');              % read type
      if ~isequal(o.type,typ)
         error('unexpected log file type!');
      end
   end
   function o = Param(o)               % Read Object Parameters        
   %
   % PARAM   Extract parameters from VSC log file by (dummy read)
   %         A VSC log file does not contain a lot of information
   %
   %            X Y
   %            1130.000000 1405.000000
   %            1182.000000 1465.000000
   %                 :     :     :    :
   %
      o = read(o,'Param');             % extract parameters, if provided
      
      path = var(o,{'path',''});
      if ~isempty(path)
         [date,time] = o.filedate(path);

         [dir,file] = fileparts(path);
         [s1,s2,s3] = fileparts(dir);
         o = set(o,{'title'},[s2,s3]);
         o = set(o,{'comment'},{});
         o = set(o,{'date'},date);
      end
      
         % if no title or comment provided
         
      o = set(o,{'title'},'PBI Data');

   end
   function o = Head(o)                % Read Data Header              
      fid = var(o,'fid');              % get file ID
      
      o = read(o,'Line');              % read 1st header line
      line = var(o,'line');
      txt = line(findstr('Time:',line):end);
      time = txt(7:14);
      o = set(o,'time',time);
      
      o = read(o,'Line');              % read 2nd header line
      line = var(o,'line');
      txt = sscanf(var(o,'line'),'|%s|%s|%s|%s|%s|%s|');
      
      o = var(o,'symbols',{'t','x','y','th','sys','i','j','bp'});
      o = var(o,'units',{'s','µ','µ','m°','1','1','1','1'});
      o = var(o,'format','%f %f %f %f %f %f %f %f');
      
      o = set(o,'title',[get(o,{'title',''}),' (',time,')']);
   end
   function o = Data(o)                % Read Data                     
      trim = @o.trim;                  % shorthand for utility
      if var(o,{'verbose.read',3})     % verbose talking enabled?
         fprintf('Data: read data\n')
      end

      oo = o;                          % we will modify object
      fid = var(oo,'fid');             % get file ID
      lnmb = var(oo,'lnmb');           % get current line number
      format = var(oo,'format');       % get format
      talking = var(oo,'verbose.read');% verbose talking during read?

         % in the following while loop we collect the log data rows
         % column by column in the matrix variable 'signals'. Each
         % row of signals represents one signal (row) vector.

      signals = [];                    % signals
      t0 = datenum(get(o,'time'),'HH:MM:SS');
      tbase = 0;
      
      while (1)
         filepos = ftell(fid);         % mind current file position
         line = fgetl(fid);            % read next line from file

         if isequal(line,-1)           % eof?
            if talking                 % verbose talking enabled?
               fprintf('%5.0f: EOF\n',lnmb)
            end
            break
         else
            lnmb = lnmb + 1;           % increment line number
            if talking                 % verbose talking enabled?
               fprintf('%5.0f: %s\n',lnmb,line)
            end
            if (rem(lnmb,50) == 0)
               o = Progress(o,'Data'); % display progress in figure bar
            end
         end

            % scan data vector, if empty restore last file position,
            % otherwise add to data buffer

         idx = find(line=='|');
         if isempty(idx)
            fseek(fid,filepos,-1);     % adjust to previous fileposition
            lnmb = lnmb - 1;           % decrement line number
            break                      % stop so far reading data
         else            
            chunks = {};
            for (i=1:length(idx)-1)
               chunks{i} = trim(line(idx(i)+1:idx(i+1)-1));
            end

               % process time
               
            time = chunks{1};
            if (length(time) ~= 8)
               fseek(fid,filepos,-1);  % adjust to previous fileposition
               lnmb = lnmb - 1;        % decrement line number
               break                   % stop so far reading data
            end            
            t = tbase + datenum(time,'HH:MM:SS') - t0;
            vec = datevec(t);
            t = vec * [0 0 24*3600 3600 60 1]';
            
               % process system (gantry number)
               
            gantry = chunks{2};
            if isequal(gantry,'Left')
               sys = 1;
            elseif isequal(gantry,'Right')
               sys = 2;
            else
               sys = 0;
            end

               % process x,y & theta
               
            x = sscanf(chunks{3},'%f');
            y = sscanf(chunks{4},'%f');
            th = sscanf(chunks{5},'%f');

               % store all in vec, add two more for 'i' amd 'j'
               
            vec = [t,x,y,th,sys,0,0,0];
            signals(:,end+1) = vec(:); % add column to signals
         end
      end
      
         % transfer signal data to object's data

      symbols = var(o,'symbols');      % get symbols
      if ~isempty(signals) && (size(signals,1) ~= length(symbols))
         error('number of data columns must match number of symbols!');
      end

      for (i=1:length(symbols))
         sym = symbols{i};
         if isempty(signals)
            o.data.(sym) = [];         % empty, if no data provided
         else
            o.data.(sym) = signals(i,:);  % set data signal vector
         end
      end

         %correct midnight jump      
         
      t = o.data.t;
      for (i=1:length(t))
         while (t(i) < 0) 
            t = t + 24*3600;           % correct mid night jump
         end
      end
      o.data.t = t;
      
         % provide defaults for 'sizes' and 'method'

      sz = get(o,'sizes');             % sizes already provided?
      if ~isempty(sz)
         rows = sz(1);  cols = sz(2);
      else
         rows = opt(o,{'pbi.import.rows',1});
         cols = opt(o,{'pbi.import.columns',1});
      end
      
      if (length(sz) < 3)
         sz = [rows cols length(t)/rows/cols];
      end
      oo = set(oo,'sizes',sz);         % actualize sizes      
      
         
         
      o = set(o,{'sizes'},[1,1,length(o.data.(sym))]);
      o = set(o,{'method'},'blcs');

         % update line and line number

      o = var(o,'lnmb',lnmb);          % update line number
      o = var(o,'line',line);          % update line
   end
   function o = Config(o)              % Configure Object              
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = category(o,1,[-2 2],[0 0],'µ');
      o = category(o,2,[-20 20],[0 0],'m°');
      o = category(o,3,[0 0],[0 0],'1');
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'th',{2,'g',2});
      o = config(o,'sys',{0,'k',0});
      o = config(o,'i',{0,'k',0});
      o = config(o,'j',{0,'k',0});
      o = config(o,'bp',{0,'k',0});
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Open(o)                  % Open File & Create Object     
%
% OPEN   Auxillary function to open an import sequence. The following
%        operations are performed:
%
%           1) create CARAMEL object with default type 'trace'
%           2) open a file for read
%           3) store file ID in var(oo,'fid')
%           4) store file path in var(oo,'path')
%           5) set var(oo,'line') empty (not EOF)
%
   oo = type(o,'trace');               % create trace typed CARAMEL object
   oo = balance(o);                    % make tag and class matching
   
   oo = work(oo,work(o));              % copy work properties
   oo = verbose(oo,'read',3);          % set verbose level >= 3 for read
   
   path = arg(o,1);                    % get path argument
   path = o.upath(path);               % convert to Unix style
   
   oo = var(oo,'path',path);           % store file path
   oo = var(oo,'lnmb',0);              % init line number
   oo = var(oo,'line','');             % init empty line

   oo = Init(oo);                      % clear parameter & data part
   oo = var(oo,'instance',0);          % init instance counter
   
   if var(oo,{'verbose.read',3})       % verbose talking enabled?
      fprintf('Open: open file %s\n',path)
   end
   
   fid = fopen(path,'r');              % open log file for read
   if (fid < 0)
      error('cannot open import file');
   end
   
      % determine length of file
      
   fseek(fid,0,+1);                    % go to end of file
   fsize = ftell(fid);                 % file eof position
   fseek(fid,0,-1);                    % go to begin of file
   
   oo = var(oo,'fid',fid);             % store file ID
   oo = var(oo,'fsize',fsize);         % store file size
end
function oo = Init(o)                  % Init Object Parameters & Data 
   oo = set(o,[]);                     % init empty parameter part
   oo = data(oo,[]);                   % init empty data part
   oo = launch(oo,launch(o));          % inherit launch function
   
   n = var(oo,'instance');
   oo = var(oo,'instance',n+1);        % increment instance counter
end
function oo = Type(o)                  % Extract Object Type           
%
% TYPE   Extract object type. The function saves the actual file position 
%        and searches for a valid type clause, like
%
%           $type='simple'
%           $type=simple
%
%        Apostrophs enclosing the type value are optional. If a valid type
%        clause is found it is stored in the returned object's type, other
%        wise no change is made.
%
%        The search is limited to the first lines of a file which is either
%        comprised of parameter clauses (line starting with a '$' char) or
%        comment lines (starting with '%') or empty lines. Once the first
%        line appears which is neither a parameter clause nor an empty line
%        or comment line the search for the type clause will be stopped.
%
%        At the end of the function the saved file position will be
%        restored.
%
%        Example for valid file header:
%
%           $title='18-Jun-2016 @ 08:21:07 Simple Trace Data'
%           $comment='sin/cos data (random frequency & magnitude)'
%
%           % comment line
%           $method='blrm'
%           $type='simple'
%           $date='18-Jun-2016'
%           $time='08:21:07'
%
%        See also: CARAMEL, READ
%
   if var(o,{'verbose.read',3})        % verbose talking enabled?
      fprintf('Type: extract type\n')
   end
   o = Progress(o,'Type');             % display progress in figure bar

   fid = var(o,'fid');                 % get file ID
   filepos = ftell(fid);               % mind current file position
   
   if fseek(fid,0,-1)
      error('cannot reset file position!');
   end
   
   oo = o;
   lnmb = 0;
   while(1)
      [oo,line] = Line(oo);            % get next line from file

      if isequal(line,-1)              % eof?
         break                         % no type info found
      elseif isempty(line) 
         continue                      % ignore empty lines
      elseif line(1) == '%'
         continue                      % ignore comment lines
      end
      
      if o.find('$type=',line) == 1;
         n = length('$type=');
         typ = line(n+1:end);
         if length(typ) >= 2 && typ(1) == '''' && typ(end) == ''''
            typ(1) = '';  typ(end) = '';
         end
         oo.type = typ;
         break
      end

         % see if it is some parameter
         
      if o.find('$',line) == 1;
         continue
      end
      break                            % otherwise we stop searching
   end
   
   if fseek(fid,filepos,-1)            % adjust to initial fileposition
      error('cannot restore file position!');
   end
   oo = var(oo,'lnmb',0);              % reset also line number
end
function oo = Param(o)                 % Extract Object Parameters     
%
% PARAM   Extract object parameters. Leave file position without
%         look-ahead
%
   if var(o,{'verbose.read',3})        % verbose talking enabled?
      fprintf('Param: extract parameter\n')
   end
   o = Progress(o,'Parameter');        % display progress in figure bar
   
   fid = var(o,'fid');                 % get file ID

   oo = o;                             % modify object
   while(1)
      filepos = ftell(fid);            % mind current file position
      lnmb = var(oo,'lnmb');           % get line number
      [oo,line] = Line(oo);            % get next line from file
      if ~ischar(line)                 % eof?
         break                         % no type info found
      elseif isempty(line) 
         continue                      % ignore empty lines
      elseif line(1) == '%'
         continue                      % ignore comment lines
      elseif o.find('$type=',line) == 1;
         continue                      % type has been processed already
      end
      
         % see if we have some parameter clause
         
      if o.find('$',line) == 1;
         idx = min(findstr('=',line));
         if isempty(idx)
            fprintf('*** bad parameter clause: %s\n',line);
            continue
         end
         
            % now we can extract tag & value
            
         tag = line(2:idx-1);
         value = line(idx+1:end);
         
         if ~isempty(value)
            switch value(1)
               case ''''
                  if length(value) >= 2 && value(end) == ''''
                     value(1) = '';   value(end) = '';
                  end
               case {'[','{','('}
                  if ~isequal(tag,'comment')   
                     value = eval(value,'[]');
                  end
               otherwise
                  % by default we interprete value as char
            end
         end
         
            % comments are treated in a special way
            
         if isequal(tag,'comment')
            comment = get(oo,{'comment',{}});
            if ~iscell(comment)
               comment = {comment};
            end
            comment{end+1} = value;
            oo.par.comment = comment;
         elseif isempty(find(tag == '.'))   % simple tag?
            oo.par.(tag) = value;      % unnested struct field (quick!)
         else                          % nested tag!
            cmd = ['oo.par.',tag,' = value;'];
            eval(cmd,'');              % set nested struct field
         end
         continue
      end
      
         % adjust file position to previous one (before last fgetl)
         % in order to avoid look-ahead on leave
         
      fseek(fid,filepos,-1);           % adjust to previous fileposition
      oo = var(oo,'lnmb',lnmb);        % store line number
      break                            % otherwise we stop searching
   end
end
function oo = Head(o)                  % Read Data Header              
%
% HEAD   Read data header while extracting symbols and units. Also sepa-
%        rator is extracted if provided. On return the following object
%        variables are provided.
%
%           var(oo,'symbols')          % list of signal symbols
%           var(oo,'units')            % list of signal units
%           var(oo,'separator')        % separator character
%           var(oo,'format')           % format string for data read
%
%        Example for header
%               t [s]    x [µ]    y [y]   th [m°]
%           |   t [s]|   x [µ]|   y [y]|  th [m°]|
%           ;   t [s];   x [µ];   y [y];  th [m°];
%
%        See also: CARAMEL, READ
%
   if var(o,{'verbose.read',3})        % verbose talking enabled?
      fprintf('Head: process header\n')
   end
   o = Progress(o,'Header');           % display progress in figure bar
   
   oo = o;                             % copy object to change object vars
   while(1)
      [oo,line] = Line(oo);            % get a line from file
      if ~ischar(line)                 % eof?
         break
      elseif isempty(line) || line(1) == '%'
         continue;                     % ignore empty lines & comments
      end
      break                            % orherwise break & process line
   end
      
      % classify header: we assume a header with integrated units
      % in brackets, possibly embedded between separators.

   symbols = {};  units = {};  format = '';  sep = '';
   if ischar(line)
      idx = find(line=='[');           % check if units are provided
      if isempty(idx)
         error('header must provide units enclosed in brackets [...]!');
      end
      
         % determine whether there is a separator character and make
         % consistency checks
         
      sep = line(1);
      if ('a' <= lower(sep) && lower(sep) <= 'z')
         sep = ' ';
      else                             % separator character found
         sdx = find(line==sep);
         if (length(sdx) ~= length(idx)+1)
            error('bad number of seperator characters in headewr!')
         end
      end
      
         % scan the header symbols and extract units
         
      n = length(idx);
      line = [line,' '];               % add space at the end of line
      format = sep;
      for (i=1:n)
         if line(1) == sep
            line(1) = '';              % remove separator
         end
         idx = min(find(line==']'));
         str = line(1:idx);  line(1:idx) = '';
         
         jdx = min(find(str=='['));
         sym = str(1:jdx-1);           % extract symbol        
         unit = str(jdx+1:end-1);      % extract unit
         
         symbols{end+1} = o.trim(sym); % store symbol in symbol list
         units{end+1} = o.trim(unit);  % store unit in unit list
         
         format = [format,'%f',sep]; 
      end
      
         % set object variables for returned object
      
      if (sep == ' ')                  % space separator?
         sep = '';                     % replace by empty separator
         format = o.trim(format);      % remove leading & trailing spaces
      end
   end
   
   oo = var(oo,'symbols',symbols);     % store symbol list
   oo = var(oo,'units',units);         % store unit list
   oo = var(oo,'format',format);       % store format string
   oo = var(oo,'separator',sep);       % store separator character
end
function oo = Data(o)                  % Read Data                     
%
% DATA   Read data and store data into data variables according to
%        the symbol list var(o,'symbols'). File ID and current line
%        number must be provided with object variables var(o,'fid')
%        and var(o,'lnmb').
%
%           oo = Data(o)               % read data columns
%
%        Verbose talking is controlled by flag var(o,'verbose.read')
%
   if var(o,{'verbose.read',3})        % verbose talking enabled?
      fprintf('Data: read data\n')
   end

   oo = o;                             % we will modify object
   fid = var(oo,'fid');                % get file ID
   lnmb = var(oo,'lnmb');              % get current line number
   format = var(oo,'format');          % get format
   talking = var(oo,'verbose.read');   % verbose talking during read?
   
      % in the following while loop we collect the log data rows
      % column by column in the matrix variable 'signals'. Each
      % row of signals represents one signal (row) vector.
      
   signals = [];                       % signals
   while (1)
      filepos = ftell(fid);            % mind current file position
      line = fgetl(fid);               % read next line from file

      if isequal(line,-1)                 % eof?
         if talking                    % verbose talking enabled?
            fprintf('%5.0f: EOF\n',lnmb)
         end
         break
      else
         lnmb = lnmb + 1;              % increment line number
         if talking                    % verbose talking enabled?
            fprintf('%5.0f: %s\n',lnmb,line)
         end
         if (rem(lnmb,50) == 0)
            o = Progress(o,'Data');    % display progress in figure bar
         end
      end
      
         % skip comments or empty lines
         
      if isempty(line)                 % skip empty line
         continue
      elseif line(1) == '%'            % skip comment line
         continue
      end

         % scan data vector, if empty restore last file position,
         % otherwise add to data buffer
         
      vec = sscanf(line,format);
      if isempty(vec)
         fseek(fid,filepos,-1);        % adjust to previous fileposition
         lnmb = lnmb - 1;              % decrement line number
         break                         % stop so far reading data
      else
         signals(:,end+1) = vec(:);    % add column to signals
      end
   end

      % transfer signal data to object's data
      
   symbols = var(o,'symbols');         % get symbols
   if ~isempty(signals) && (size(signals,1) ~= length(symbols))
      error('number of data columns must match number of symbols!');
   end
   
   for (i=1:length(symbols))
      sym = symbols{i};
      if isempty(signals)
         oo.data.(sym) = [];           % empty, if no data provided
      else
         oo.data.(sym) = signals(i,:); % set data signal vector
      end
   end
   
      % provide defaults for 'sizes' and 'method'
      
   if ~isempty(oo.data)
      oo = set(oo,{'sizes'},[1,1,length(oo.data.(sym))]);
      oo = set(oo,{'method'},'blcs');
   end
   
      % update line and line number
      
   oo = var(oo,'lnmb',lnmb);           % update line number
   oo = var(oo,'line',line);           % update line
end
function oo = Config(o)                % Configure for Plotting        
   switch o.type
      case {'pln','plain'}
         oo = ConfigPlain(o);
      case {'smp','simple'}
         oo = ConfigSimple(o);
      otherwise
         oo = ConfigDefault(o);
   end
   return
   
   function o = ConfigPlain(o)         % Configure for Plain XY and P  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = subplot(o,'color',[1 1 0.9]);
      o = category(o,1,[-10 10],[0 0],'µ');
      o = category(o,2,[-50 50],[0 0],'m°');
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'p',{2,'g',2});
   end
   function o = ConfigSimple(o)        % Configure All Signals         
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = subplot(o,'color',[0.97 0.98 1]);
      o = category(o,1,[-5 5],[0 0],'µ');
      o = category(o,2,[-50 50],[0 0],'m°');
      o = category(o,3,[-0.5 0.5],[0 0],'µ');
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{1,'b',1});
      o = config(o,'p',{2,'g',2});
      o = config(o,'ux',{3,'m',3});
      o = config(o,'uy',{3,'c',3});
   end
   function o = ConfigDefault(o)       % Configure Default Object Type 
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = subplot(o,'color',[1 1 1]);
      symbols = var(o,{'symbols',{}}); % get symbol list
      units = var(o,{'units',{}});     % get unit list

      if (length(symbols) ~= length(units))
         error('length of symbol & unit list must match!');
      end

      o = config(o,[]);                % set all subplots to zero
      o = subplot(o,'layout',1);       % layout with 1 subplot column   

      list = {};
      for (i=1:length(symbols))
         sym = symbols{i};
         unit = units{i};
         cat = o.find(unit,list);
         if (cat == 0)
            cat = length(list) + 1;    % new category number
            list{cat} = unit;
            o = category(o,cat,[0 0],[0 0],unit);
         end
         o = config(o,sym,{1,'k',cat});
      end
   end
end
function oo = Close(o)                 % Close File & Cleanup Object   
   fid = var(o,'fid');                 % get file handle
   fclose(fid);                        % close file

   path = var(o,'path');
   o = Progress(o,'');                 % End of progress message
   %message(o,'Import from log data file completed!',...
   %          ['File: ',path]);

   oo = var(o,[]);                     % cleanup object variables
end
function oo = Snif(o)                  % Snif Parameters for Any File  
   path = arg(o,1);                    % get path arg
   
   oo = read(o,'Open',path);           % open file & create object
   oo = read(oo,'Type');               % read type
   oo = read(oo,'Param');              % read parameters
   oo = read(oo,'Close');              % close file & cleanup object
end

   % line read and progress message
   
function [oo,line] = Line(o)           % Get Next Line from File       
%
% FGETL   Get next line from file, update line number, and print a
%         verbose message controlled by tag 'read'
%
%            [oo,line] = Fgetl(o)
%
%         Alternative with 1 output arg
%
%            oo = Fgetl(o)             % return line as var(oo,'line')
%            oo = read(o,'Fgetl')      % same as above
%
%         Example
%            o = verbose(o,'bit',3)    % talk for verbose level >= 3
%            oo = read(o,'Open',path)
%            line = '';
%            while ischar(line)
%               [oo,line] = Fgetl(o)
%               if ischar(line)
%                  :    :    :
%               end
%            end
%
%         See also: CARAMEL, READ
%
   fid = o.work.var.fid;               % get file ID
   lnmb = o.work.var.lnmb;             % get file ID
   line = fgetl(fid);                  % get a line from file
   
   if isequal(line,-1)                 % eof?
      if var(o,{'verbose.read',3})     % verbose talking enabled?
         fprintf('%5.0f: EOF\n',lnmb)
      end
   else
      lnmb = lnmb + 1;                 % increment line number
      if var(o,{'verbose.read',3})     % verbose talking enabled?
         fprintf('%5.0f: %s\n',lnmb,line)
      end
      line = o.trim(line);
   end
   
   oo = var(o,'lnmb',lnmb);            % update line number
   if (nargout < 2)
      oo.work.var.line = line;
   end
end
function o = Progress(o,msg)           % Show Progress Message         
%
% PROGRESS   Display progress message in menu bar
%
%               Progress(o,'')         % restore object title
%               Progress(o,'')         % restore object title
%
%            Example
%
%               o = Progress(o,
%
   if (nargin < 2)
      msg = arg(o,1);
   end
   
   msg = o.underscore(msg);            % substitute underscores
   if isempty(msg)
      %menu(pull(o),'Title');          % restore figure title
      hbar = var(o,'hbar');            % handle to wait bar
      close(hbar);
   else
      [~,file,ext] = fileparts(var(o,{'path','?'}));
      fid = var(o,'fid');
      fsize = var(o,{'fsize',NaN});
      
      if ~isnan(fsize) && ~isempty(fid)
         percent = round(100*ftell(fid)/fsize); 
         %str = sprintf('%3.0f%% imported from file: %s',percent,[file,ext]);
         %str = o.underscore(str);      % substitute underscores
         %set(figure(o),'name',str);
         %shg
         
         hbar = var(o,'hbar');         % handle to wait bar
         if isempty(hbar)
            txt = o.underscore(['Importing file: ',file,ext]);
            hbar = waitbar(0,txt);
            o = var(o,'hbar',hbar);
         end
         waitbar(percent/100,hbar);
      end
   end
end
