function list = collect(o,types,table)
%
% COLLECT   Collect log files of a package directory
%
%    Before applying a collect operation a collection configuration must be
%    setup in prior (1,2). After that the collection can be applied (3).
%
%    1) Setup a collection configuration: this happens by repeated
%    assignment of an object type list with an import table
%
%       collect(o,{})                  % init (reset) collection config
%       collect(o,types,table)         % setup collection config
%       collect(o,{'pln','smp'},table) % setup collection config
%       collect(o,{},table0)           % provide default import table
%
%    2) Display collect configuration
%
%       collect(o)                     % display collection config
%
%    3) Apply collection: collect files according to previously defined
%    configuration
%
%       list = collect(o)              % collect files of a package
%
%    Remark: the collection configuration is an assoc table where each 
%    configured type is assigned with an import driver table, while each
%    import driver table tells the collect method how to import a log file.
%    A default table
%
%       setting(o,'collect',{{type1,table1},{type2,table2},...,table0})
%
%    Example 1: provide only default table
%
%       collect(o,{})                  % reset collection config
%       table0 = {{@read,'cutes','PackageDrv','.pkg'},...
%                 {@read,'cute','UniLogDrv', '.log'}};
%       collect(o,{},table0);          % only default table
%
%    Example 2: provide general collection configuration
%
%       collect(o,{})                  % reset collection config
%
%       table1 = {{@read,'cute','PackageDrv','.pkg'},...
%                 {@read,'cute','UniLogDrv', '.log'}};
%       collect(o,{'pln','smp'},table1); 
%
%       table2 = {{@read,'cute','PackageDrv','.pkg'},...
%                 {@read,'cute','UniLogDrv', '.log'}};
%                 {@basis,'cute','VibTxtDrv','.txt'}},...
%       collect(o,{'vib'},table2); 
%
%       table3 = {{@read,'cute','PackageDrv','.pkg'},...
%                 {@read,'cute','UniLogDrv', '.log'}};
%                 {@basis,'cute','BmcTxtDrv','.txt'}},...
%                 {@basis,'cute','BmcPbiDrv','.pbi'}},...
%       collect(o,{'bmc'},table3); 
%
%    See also: CUTE, IMPORT
%
   if (nargin == 1) && (nargout == 0)
      Show(o);                         % show collection configuration
   elseif (nargin == 1) && (nargout > 0)
      list = Collect(o);               % actually collect files of package
   elseif (nargin == 2)
      Init(o,types);                   % init/reset collection config
   elseif (nargin == 3)
      Configure(o,types,table);        % configure collection
   else
      error('1,2 or 3 input args expected!');
   end
end

%==========================================================================
% Configuration
%==========================================================================

function Init(o,types)                 % Init/Reset Configuration      
   if ~isempty(types) || ~iscell(types)
      error('{} expected for arg2!');
   end
   setting(o,'collect',{});            % reset assoc list
end
function Show(o)                       % Show Configuration            
   tables = setting(o,{'collect',{}});
   fprintf('Collection Setup:\n');
   for (i=1:length(tables))
      pair = tables{i};
      if isstruct(pair)               % default table
         fprintf('   Default:\n');
         ShowTable(pair.default);
      else
         fprintf('   Type %s:\n',pair{1});
         ShowTable(pair{2});
      end         
   end
   return
   
   function ShowTable(table)
      for (j=1:length(table))
         entry = table{j};
         method = char(entry{1});
         class = entry{2};
         driver = entry{3};
         ext = entry{4};
         fprintf('      %s(%s,''%s'',''%s'')\n',method,class,driver,ext);
      end
   end
end
function Configure(o,types,table)      % Add Configuration             
   if ~iscell(types)
      error('type list (arg2) must be cell array!');
   end
   for (i=1:length(types))
      if ~ischar(types{i})
         error('all types in list (arg2) must be char!');
      end
   end
   
   
   if ~iscell(table)
      error('configuration table must be a list!');
   end
   for (i=1:length(table))
      entry = table{i};
      if ~iscell(entry) || any(size(entry) ~= [1 4])
         error('all configuration table entries must be 4-list!');
      end
      method = entry{1};
      class = entry{2};
      driver = entry{3};
      ext = entry{4};
   
      if ~isa(method,'function_handle')
         error('table entry{1} must be function handle');
      end
      if ~ischar(class) || ~ischar(driver) || ~ischar(ext)
         error('table entry(2:4) must be char');
      end
   end
   
      % everything ok so far - start configuring
   
   tables = setting(o,{'collect',{}});
   default = [];
   if length(tables) > 0 && length(tables{end}) ~= 2
      default = tables{end};
      tables(end) = [];
   end
   
      % we got rid of the default entry, and default holds the
      % default table, if it has been provided before
      
   if isempty(types)
      tail.default = table;
      default = tail;  % overwrite default
   else
      for (k=1:length(types))
         typ = types{k};
         [value,idx] = o.assoc(typ,tables);
         if (idx > 0)
            tables{idx} = {typ,table}; % replace by updated assoc pair
         else
            tables{end+1} = {typ,table};
         end
      end
   end
   
      % finally we have to append default table, if there is one
      
   if ~isempty(default)
      tables{end+1} = default;
   end
   
      % update collect setting
      
   setting(o,'collect',tables);
end

%==========================================================================
% Actual Collection
%==========================================================================

function list = Collect(o)             % Collect Files                 
   list = {};                          % by default empty list
   
   caption = 'Import all objects from folder';
   directory = fselect(o,'d','*.*',caption);
   if isempty(directory)
      return
   end
   
   [dir,file,ext] = fileparts(directory);
   name = [file,ext];                  % recombine file&extension to name
   
      % extract package type
      
   try
      [package,typ] = split(o,name);
   catch
      idx = find(name == '_');
      if length(idx) == 1
         machine = name(1:idx-1);
         digits = [name(idx+1:end),'00'];
         package = ['@',machine,'.',digits];
         typ = 'cut';
      else
         typ = '';                        % initiate an error
      end
   end

   if isempty(typ)
      message(o,'Error: something wrong with package folder syntax!',...
                '(cannot import files)');
      return
   end

      % from here everything is ok - we extracted the package type
      
   tables = setting(o,{'collect',{}});
   if isempty(tables)
      tables = opt(o,{'collect',{}});
   end
   table = o.assoc(typ,tables); 
   
   if isempty(table)
      message(o,'Error: package type not supported!',...
                ['Package: ',package,', Type: ',typ],'',...
                'Consider to install a proper plugin!');
      list = {};
      return
   elseif isstruct(table)
      table = table.default;           % resolve struct indirection
   end
   
      % otherwise collect package by importing files in package 
      
   list = Import(o,directory,table);   
end
function list = Import(o,folder,table)
   list = {};                          % init: empty object list   
   packages = {};                      % init (to avoid crash)
   
      % setup tag list for parameters to be inherited
      
   tags = {'project','machine','package','date','time',...
           'station','apparatus','damping','kappl','lage','vcut','vseek',...
           'creator','version'};

      % loop throughall table entries ...
   
   for (k=1:length(table))
      entry = table{k};
      gamma = entry{1};                % read routine
      class = entry{2};                % object class
      driver = entry{3};               % read driver
      suffix = entry{4};               % supported file suffix

         % first read all package info objects of this folder into
         % a list named 'packages'
         
      switch suffix
         case '.pkg'
            obj = cast(o,class); 
            packages = Packages(obj,folder,gamma); % read all package info files

               % check if we found any package info file

            if isempty(packages)
               message(o,'Error: missing package info file!',...
                       'First provide a package info file (.pkg)!');
               return
            end
            
         otherwise    
            for (k=1:length(packages))    % loop through all packages
               list = Files(packages{k},list,folder,driver);
            end
      end
   end
   return
   
   function list = Files(o,list,folder,driver) % Read Files Related to Pkg
      list{end+1} = o;                % add package object to object list
      blo = var(o,[]);                % init variables of 'blue object
      
      blo = Provide(blo,o,tags);      % update blueprint (of 'blue object')

      filenames = dir(folder);
      for (i=1:length(filenames))
         [~,file,ext] = fileparts(filenames(i).name);
         if ~isequal(ext,suffix) || isequal(ext,'.pkg')
            continue
         end

            % now read data file (by consulting read driver)

         path = o.upath([folder,'/',file,ext]);
         oo = gamma(o,driver,path);    % call read driver function

            % if files list of package object is nonempty then filename
            % of object has to be listed in files list
            
         files = get(o,{'files',{}});
         idx = 0;                      % default init
         if ~isempty(files)
            idx = o.is(get(oo,{'file','?'}),files);
            if (idx == 0)
               continue
            end
         end
         
            % returned object can either be container (kids list appends to
            % list) or non-container (which goes directly into list)

         if container(oo)
            error('did not expect imported container object');
         end

            % inherit launch function and key parameters
            % finally add objects to list

         func = launch(o);             % get shell's launch function
         oo = launch(oo,func);         % inherit launch function
         oo = Inherit(blo,oo,tags,idx);% inherit parameters from blueprint
         
            % add to object list
            
         list{end+1} = oo;              % append object to end of list
      end
   end
   function list = Packages(o,folder,gamma) % Read Pckages             
      filenames = dir(folder);
      
      list = {};     
      for (i=1:length(filenames))
         [~,file,ext] = fileparts(filenames(i).name);
            
         if isequal(ext,'.pkg')
            path = o.upath([folder,'/',file,ext]);
            
               % call read driver function
               
            oo = gamma(o,driver,path);  
            list{end+1} = oo;         % add to list
         end
      end
   end
   function o = Provide(o,oo,tags)          % provide blueprint value  
   %
   % PROVIDE  Provide blueprint value if not already provided
   %
   %             o = Provide(o,oo)
   %
   %          var(o) contain the blueprint values, while oo is the
   %          package object which sponsors the data to be inherited
   %
      for (i=1:length(tags))
         tag = tags{i};
         
            % first get actual blueprint value; blue print values are
            % stored as work variables of o
            
         blue = var(o,tag);                 % get actual blueprint value
         
            % now fetch value from package. if package value is empty
            % then use blueprint value as result
            
         val = get(oo,{tag,blue});          % get value from package
         o = var(o,{tag},val);              % updated blueprint   
      end
   end
   function oo = Inherit(o,oo,tags,idx)     % inherit from package obj 
   %
   % INHERIT  Inherit blueprint values
   %
   %             oo = Inherit(o,oo)
   %
   %          var(o) contain the blueprint values, while oo is an object
   %          which receives blueprint data from o
   %     
      for (i=1:length(tags))
         tag = tags{i};
         blue = var(o,tag);            % get blueprint value
         if length(blue) > 0 && ~ischar(blue)
            if (idx > 0 && idx <= length(blue))
               if isa(blue,'double')
                  oo = set(oo,tag,blue(idx));
               elseif iscell(blue)
                  oo = set(oo,tag,blue{idx});
               else  
                  fprintf('*** warning: cannot inherit from package!\n');
               end
            end
         else
            oo = set(oo,tag,blue);     % inherit object parameter
         end
      end
   end
end
