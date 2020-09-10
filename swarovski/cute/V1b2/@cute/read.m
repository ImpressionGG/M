function oo = read(o,varargin)         % Read CUT Object From File     
%
% READ   Read a CUT object from file.
%
%           oo = read(o,'ReadPkgPkg',path) % package info file (.pkg)
%           oo = read(o,'ReadCutCsv',path) % CUT log data file (.csv)
%
%        Read whole relevant part of measurement plan which matches 
%        referred object files and convert to package
%
%        Read whole measurement plan and convert to package
%
%           oo = read(o,'ReadMplXlsx',path) % measurement plan (.xlsx)
%
%        See also: CUT, IMPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@ReadPkgPkg,@ReadCutCsv,...
                       @ReadArtArt,@ReadSpmSpm,@ReadPkgXlsx,@ReadMplXlsx);
   oo = gamma(oo);
end

function o = Error(o)                  % Default Error Method          
   error('two input args expected!');
end

%==========================================================================
% Package Info File Read Driver
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for .pkg File     
   co = corazon(o);                    % cast to acess corazon method
   path = arg(o,1);
   
   oo = opt(o,'progress',0);           % disable progress bar
   
   oo = read(oo,'Open',path);          % open file & create object
   oo = read(oo,'Type');               % read type
   oo = read(oo,'Param');              % read parameters
   oo = read(oo,'Header');             % read data header
   oo = read(oo,'Data');               % read data
   oo = read(oo,'Close');              % close file & cleanup object
   oo = cute(oo);                      % cast back to cute object
      
      % pimp title
      
   title = get(oo,{'title',''});
   idx = strfind(title,'.CUL');
   if ~isempty(idx)
      title(idx(1):idx(1)+3) = '';
      oo.par.title = title;
   end
end
function oo = ReadMplXlsx(o)           % Read Full Measurement Plan    
   o = opt(o,'full',true);
   oo = ReadPkgXlsx(o);                % delegate to ReadPkgXlsx
end
function oo = ReadPkgXlsx(o)           % Read Measurement Plan into Pkg
   full = opt(o,{'full',false});       % full measurement plan or relevant?
   
   path = arg(o,1);                    % get path arg
   [dir,file,ext] = fileparts(path);
   
   set(figure(o),'Name',['Importing ',file,ext,' (1%)']);
   idle(o);
   
      % read .CSV file into table, extract names and table matrix (M)
      % and store as object (working) variables
      
   T = readtable(path,'PreserveVariableNames',true);
   M = table2array(T);
   names = T.Properties.VariableNames;
   
      % create new object
      
   oo = cute('pkg');                   % package from measurement plan
   oo.par.title = '';                  % set title later
   oo.par.comment = {names{1}};        % set comment now
   oo.par.project = context(o,'Project',path);
   
      % extract package info
      
   oo = PackageInfo(oo,path);
   oo.par.symbols = {};                % init empty symbols
   oo.par.units = {};                  % init empty units
   
      % store raw data in object variables for further processing
      
   oo = var(oo,'T,M',T,M);             % store in object variables
   
         % extend files with extension and check existence
         % in 'ful' mode prepare a full index, while in relevant mode
         % prepare an index vector indicating only entries relating to
         % existing files
      
   files = Pick(oo,'Datei');  
   index = [];
   
   for (i=1:length(files))
      filename = [files{i},'.csv'];
      files{i} = filename;
      
      dir = oo.par.dir;
      if (exist([dir,'/',filename]) ~= 2)
         if (full)                     % warn only in full mode
            fprintf('*** warning: directory %s:\n',dir);
            fprintf('    file ''%s'' not existing!\n',filename);
         end
      else
         index(end+1) = i;             % relevant indices
      end
   end
   
   if (full)
      oo = var(oo,'index',1:length(files));
   else
      oo = var(oo,'index',index);
   end
   
      % extract data (from M)
      
   oo = Number(oo,'number','Nr.');  
   oo = String(oo,'process','Bearbeitung');  
   oo = String(oo,'station','Station');  
   oo = String(oo,'disktype','Scheibentyp');  
   oo = String(oo,'diskmount','Scheibenbefestigung');  
   oo = String(oo,'direction','Scheibendrehrichtung');  
   oo = Number(oo,'vcut','Schnittgeschwindigkeit');  
   oo = Number(oo,'chang','Changierung');  
   oo = String(oo,'article','Artikel');  
   oo = String(oo,'glass','Glassorte');  
   oo = String(oo,'setup','Bestückung');  
   oo = String(oo,'apparatus','Apparat');  
   oo = String(oo,'damping','Dämpfung');  
   oo = String(oo,'kappl','Kappl');  
   oo = String(oo,'cement','Kitt');  
   oo = String(oo,'previous','VorherigeStation');  
   oo = Number(oo,'lage','Lagenbezug');  
   oo = Number(oo,'theta','lagenwinkel');  
   oo = String(oo,'facette','Facettenbezug');  
   oo = String(oo,'angles','Facettenwinkel');  
   oo = String(oo,'strategy','Schleifstrategie');  
   oo = Number(oo,'preasure','Stiftklemmdruck');  
   oo = Number(oo,'vseek','Suchgeschwindigkeit');  
   oo = Number(oo,'threshforce','Schwellkraft');  
   oo = Number(oo,'force','Kraft');  
   oo = Number(oo,'toff','Ausschleifzeit');  
   oo = Number(oo,'mmseek','Suchabstand');  
   oo = Number(oo,'mmlift','Abhebeabstand');  
   oo = Number(oo,'stroke','MaxTiefenachse');  
   oo = String(oo,'remark','Anmerkung');  
   oo = String(oo,'files','Datei');  

      % add extension to files
      
   for (i=1:length(oo.par.files))
      filename = [oo.par.files{i},'.csv'];
      oo.par.files{i} = filename;
   end
   
      % that's it - we are almost done ...
   
   oo.data = [];                       % empty data
   oo = var(oo,[]);                    % cleanup object variables
   return
   
   function o = PackageInfo(o,path)    % Extract Package Info          
      [dir,file,ext] = fileparts(path);
      
         % next extract folder name
         
      [~,folder,fext] = fileparts(dir);
      folder = [folder,fext];          % reconstruct folder name

         % extract run number digits and machine name from file name

      idx = find(file =='_');
      if (length(idx) < 2)
         error('cannot extract file name');
      end
      digs = file(idx(end)+1:end);
      machine = file(idx(end-1)+1:idx(end)-1);
         
         % construct package name depending on folder naming convention
         % folder naming convention 1: '@LPC03.20060900.CUT'
         % folder naming convention 2: 'LPC03_200609'
         
      digits = [digs,'00'];            % default digits
      
      if (length(folder) > 1 && folder(1) == '@') % '@LPC03.20060900.CUT'
         idx = find(folder=='.');
         if length(idx) >= 2
            pkgdigs = folder(idx(1)+1:idx(2)-1);
            if (strfind(pkgdigs,digs) == 1)
               digits = pkgdigs;       % take over
            end
         end
      end

         % extract run number and construct package indentifier
         
      run = sscanf(digits,'%f');
      
         % final syntax check
         
      if ~isequal(digits,sprintf('%d',run))
         error('inconsistent data folder naming');
      end
      
         % finally construct package indentifier
         
      package = ['@',machine,'.',digits,'.CUT'];
      
         % store parameters
         
      o.par.package = package;
      o.par.date = [digits(5:6),'-',digits(3:4),'-20',digits(1:2)];
      o.par.dir = dir;
      o.par.file = [package,'.pkg'];
      o.par.title = ['Package ',package];
      o.par.machine = machine;
   end
   function o = String(o,tag,sym)      % Pick String Data Column       
      [list,unit] = Pick(o,sym);
      
      index = var(o,'index');
      if (index)
         list = list(index);
      else
         list = {};
      end
      
      o.par.(tag) = list;
      o.par.symbols{end+1} = sym;
      o.par.units{end+1} = unit;
   end
   function o = Number(o,tag,sym)      % Pick Number Data Column       
      [~,unit,row] = Pick(o,sym);
      
      index = var(o,'index');
      if (~isempty(index) && ~isempty(row))
         row = row(index);
      else
         row = [];
      end

      o.par.(tag) = row;
      o.par.symbols{end+1} = sym;
      o.par.units{end+1} = unit;
   end
   function [list,unit,row] = Pick(o,sym) % Pick Column Given by Symbol
      M = var(o,'M');
      [m,n] = size(M);
      
         % init stuff
         
      idx = [];
      list = {};
      unit = '';
      row = [];
      
         % seek column
         
      for (j=1:n)
         if isequal(sym,M{2,j})
            idx = j;
            break;
         end
      end
      
         % pick list
      
      if ~isempty(idx)
         unit = M{1,idx};
         list = M(3:end,idx)';
         if (nargout >= 3)
            for (i=1:length(list))
               row(1,i) = sscanf(list{i},'%f'); 
            end
         end
      end
   end   
end

%==========================================================================
% Read Cut Log Data File 
%==========================================================================

function oo = ReadCutCsv(o)            % Read Driver for .log File     
   path = arg(o,1);                    % get path arg
   [dir,file,ext] = fileparts(path);
   
   try
      [~,package,pxt] = fileparts(dir);
      [package,typ,name,run,machine] = split(o,[package,pxt]);
   catch
      machine = '';
   end
   
   set(figure(o),'Name',['Importing ',file,ext,' (1%)']);
   idle(o);

      % read .csv file into table (preserve original variable names)

   T = readtable(path,'PreserveVariableNames',true);

   set(figure(o),'Name',['Importing ',file,ext,' (90%)']);

   M = table2array(T);
   names = T.Properties.VariableNames;
   
   oo = cute('cut');                   % create CUTE object of type 'CUT'
   oo = figure(oo,figure(o));          % copy figure
   oo.par.title = file;
   
   oo.par.package = package;
   oo.par.machine = machine;
   oo.par.dir = dir;
   oo.par.file = [file,ext];
   
   oo.par.comment = {['package: ',package],['machine: ',machine],...
                     ['file: ',file,'/',ext],['directory: ',dir]};
   oo = Extract(oo,oo.par.title);
                  
   zero = zeros(1,size(M,1));
   oo = data(oo,'t',zero);
   oo = data(oo,'ax',zero);
   oo = data(oo,'ay',zero);
   oo = data(oo,'az',zero);
   oo = data(oo,'bx',zero);
   oo = data(oo,'by',zero);
   oo = data(oo,'bz',zero);

   for (i=1:length(names))
      name = names{i};
      switch name
         case 'Time (s)'
            oo = data(oo,'t',M(:,i)');
         case 'Acc_X_Kappl (g)'
            oo = data(oo,'ax',M(:,i)');
         case 'Acc_Y_Kappl (g)'
            oo = data(oo,'ay',M(:,i)');
         case 'Acc_Z_Kappl (g)'
            oo = data(oo,'az',M(:,i)');
         case 'Acc_X_Kolben (g)'
            oo = data(oo,'bx',M(:,i)');
         case {'Acc_Y_Kolben (g)','Acc_YKolben (g)'}
            oo = data(oo,'by',M(:,i)');
         case 'Acc_Z_Kolben (g)'
            oo = data(oo,'bz',M(:,i)');
      end
   end
end

%==========================================================================
% Read Article Data File 
%==========================================================================

function oo = ReadArtArt(o)            % Read Article Data File        
   oo = read(o,'ReadGenDat',arg(o,1)); % forward to corazon/read
end

%==========================================================================
% extract parameters from file title
%==========================================================================

function o = Extract(o,title)                                          
   text = ['_',title,'_'];
   idx = find(text=='_');
 
      % split up text into chunks
      
   chunks = {};
   for (i=2:length(idx))
      chunk = text(idx(i-1)+1:idx(i)-1);
      chunks{end+1} = chunk;
   end
   
      % extract number
      
   while (1)
      number = chunks{end};
      o.par.number = sscanf(number,'%f');
      
      if ~isempty(o.par.number)
         break;
      end
      nick = get(o,{'nick',''});
      o = set(o,'nick',[nick,' ',chunks{end}]);
      chunks(end) =[];  % otherwise repeat
   end

      % extract lage
      
   lage = chunks{end-1};
   o.par.lage = sscanf(lage,'Lage%f');
   if ~isa(o.par.lage,'double')
      o.par.lage = NaN;
   end
   
      % extract date
      
   date = chunks{1};
   o.par.date = ['20',date(1:2),'-',date(3:4),'-',date(5:6)];
      
      % extract machine and station
   
   o.par.machine = chunks{2};
   o.par.station = chunks{3};
   
      % extract article and kappl

   o.par.article = chunks{4};
   o.par.kappl = chunks{5};
   
      % extract facette angle
      
   art = get(o,'article');
   if ~isempty(art)
      ao = article(o,art);
      tags = fields(o.either(get(ao),struct));
      for (i=1:length(tags))
         tag = tags{i};
         if isequal(strfind(tag,'facette'),1)
            o = set(o,tag,get(ao,tag));
         end
      end
   end
   
      % set angle
      
   oo = article(o,o.par.article);
   if ~isempty(oo)
      o.par.angle = angle(oo,get(o,{'lage',0}));
   end
   
      % copy info from package object
      
   %o = Package(o);
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
