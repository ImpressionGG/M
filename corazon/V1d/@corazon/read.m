function oo = read(o,varargin)         % Read CORAZON Object From File 
%
% READ     Read a CORAZON object from file.
%
%             oo = read(o,'ReadLogLog',path)  % Log data .log read driver
%             oo = read(o,'ReadStuffTxt',path) % Stuff .txt read driver
%
%          Read some generic stuff
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
%             oo = read(oo,'Close')    % close file & cleanup object
%             oo = read(o,'Snif',path) % Snif Parameters
%
%          Also possible to get next line from file, updating line number
%          and verbose talking
%
%             oo = read(oo,'Line')
%             line = var(o,'line')     % EOF for ~ischar(line)
%
%          Copyright (c): Bluenetics 2020 
%
%          See also: CORAZON, IMPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@Line,...
                @Open,@Init,@Type,@Param,@Header,@Data,@Close,...
                @Snif,@ReadPkgPkg,@ReadSmpDat,@ReadGenDat,@ReadPbiPbi,...
                @ReadBmcPbi,@ReadVibTxt,@ReadLogLog,@ReadStuffTxt);
   oo = gamma(oo);
end

%==========================================================================
% Error
%==========================================================================

function o = Error(o)                  % Default Error Method          
   error('two input args expected!');
end

%==========================================================================
% Read Driver for Log Data
%==========================================================================

function oo = ReadLogLog(o)            % Read Driver for Log Data .log 
   path = arg(o,1);
   [x,y,par] = Read(path);             % read data into variables x,y,par
   
   oo = corazon('log');                % create 'log' typed CORAZON object
   oo.par = par;                       % store parameters in object
   oo.data.x = x';                     % store x-data in object
   oo.data.y = y';                     % store y-data in object
   return
   
   function [x,y,par] = Read(path)     % read log data (v1a/read.m)
      fid = fopen(path,'r');
      if (fid < 0)
         error('cannot open log file!');
      end
      par.title = fscanf(fid,'$title=%[^\n]');
      log = fscanf(fid,'%f',[2 inf])'; % transpose after fscanf!
      x = log(:,1); y = log(:,2);
   end
end

%==========================================================================
% Read Driver for Corazon Stuff
%==========================================================================

function oo = ReadStuffTxt(o)          % Read Driver for .txt File     
   path = arg(o,1);                    % get path
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   tit = fscanf(fid,'$title=%[^\n]');
   newline = fgets(fid);
   type = fscanf(fid,'$type=%[^\n]');
   newline = fgets(fid);
   colorexp = fscanf(fid,'$color=%[^\n]');
   c = eval(colorexp);

   oo = corazon(type);                 % create a CORAZON object
   oo = set(oo,'title',tit,'color',c); % set parameters
   oo.data = [];                       % make a non-container object
   
   switch oo.type
      case 'weird'
         bulk = fscanf(fid,'%f',[5 inf])';% transpose after fscanf!

         oo.data.t = bulk(:,1);        % set t data
         oo.data.w = bulk(:,2);        % set w data
         oo.data.x = bulk(:,3);        % set x data
         oo.data.y = bulk(:,4);        % set y data
         oo.data.z = bulk(:,5);        % set z data
      case {'ball','cube'}
         bulk = fscanf(fid,'%f',[4 inf])';  % transpose after fscanf!
         oo.data.radius = bulk(1,1);
         oo.data.offset = bulk(1,2:4);
   end
   fclose(fid);
end

%==========================================================================
% Package Info File Read Driver
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for .pkg File     
   oo = Snif(o);                       % read parameters   
   
      % store file & directory in parameters
      
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);
   oo.par.file = [file,ext];
   oo.par.dir = dir;
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
   oo = read(oo,'Close');              % close file & cleanup object

      % store file & directory in parameters
      
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);
   oo.par.file = [file,ext];
   oo.par.dir = dir;
end

%==========================================================================
% Universal Logfile Read Driver
%==========================================================================

function oo = ReadGenDat(o)            % General Read Driver (.dat)    
   path = arg(o,1);                    % get path arg
   
   oo = read(o,'Open',path);           % open file & create object
   oo = read(oo,'Type');               % read type
   oo = read(oo,'Param');              % read parameters
   oo = read(oo,'Header');             % read data header
   oo = read(oo,'Data');               % read data
   oo = read(oo,'Close');              % close file & cleanup object

      % store file & directory in parameters
      
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);
   oo.par.file = [file,ext];
   oo.par.dir = dir;
end

%==========================================================================
% Helpers
%==========================================================================

function oo = Open(o)                  % Open File & Create Object     
%
% OPEN   Auxillary function to open an import sequence. The following
%        operations are performed:
%
%           1) create CORAZON object with default type 'trace'
%           2) open a file for read
%           3) store file ID in var(oo,'fid')
%           4) store file path in var(oo,'path')
%           5) set var(oo,'line') empty (not EOF)
%
   oo = type(o,'trace');               % create trace typed CORAZON object
   oo = balance(o);                    % make tag and class matching
   
   oo = work(oo,work(o));              % copy work properties
   oo = verbose(oo,'read',3);          % set verbose level >= 3 for read
      
   path = arg(o,1);                    % get path argument
   path = o.upath(path);               % convert to Unix style   
   [dir,file,ext] = fileparts(path);

   oo = var(oo,'path',path);           % store file path
   oo = var(oo,'lnmb',0);              % init line number
   oo = var(oo,'line','');             % init empty line

   oo = Init(oo);                      % clear parameter & data part
   oo = var(oo,'instance',0);          % init instance counter

   oo = set(oo,'file',[file,ext]);     % store file name as parameter
   oo = set(oo,'dir',dir);             % store directory as parameter
   
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
%        See also: CORAZON, READ
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
function oo = Header(o)                % Read Data Header              
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
%               t [s]    x [um]    y [um]   th [m°]
%           |   t [s]|   x [um] |  y [um] | th [m°]|
%           ;   t [s];   x [um] ;  y [um] ; th [m°];
%
%        See also: CORAZON, READ
%
   if var(o,{'verbose.read',3})        % verbose talking enabled?
      fprintf('Header: process header\n')
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
      %oo = set(oo,{'method'},'blcs');
   end
   
      % update line and line number
      
   oo = var(oo,'lnmb',lnmb);           % update line number
   oo = var(oo,'line',line);           % update line
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
%         See also: CORAZON, READ
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
   if (nargin < 2)
      msg = arg(o,1);
   end
   
   uscore=util(o,'uscore');
   msg = uscore(msg);                  % substitute underscores
   if isempty(msg)
      %menu(pull(o),'Title');          % restore figure title
      hbar = var(o,'hbar');            % handle to wait bar
      close(hbar);
   else
      [~,file,ext] = fileparts(var(o,{'path','?'}));
      fid = var(o,'fid');
      fsize = var(o,{'fsize',NaN});
      
      if ~isnan(fsize) && ~isempty(fid)
         txt = uscore(['Importing file: ',file,ext]);
         percent = round(100*ftell(fid)/fsize); 
         
         hbar = var(o,'hbar');         % handle to wait bar
         if isempty(hbar)
            hbar = waitbar(0,txt);
            o = var(o,'hbar',hbar);
         end
         txt = [txt,sprintf(' (%g%%)',percent)];
         set(figure(o),'Name',txt);
         %shg; pause(0.1);
      end
   end
end
