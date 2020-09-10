function oo = context(o,varargin)
%
% CONTEXT   Get context from path
%
%    Syntax
%       oo = context(o,'Total',path)        % total available context
%
%       machine = context(o,'Machine',path) % total available context
%       project = context(o,'Project',path) % extract project from path
%       folder = context(o,'Path',path)     % extract project path
%
%           See also: CARAMEL, KEFALON
%
   [gamma,oo] = manage(o,varargin,@Error,@Total,@Machine,@Project,@Path);
   oo = gamma(oo);
end

%==========================================================================
% Published Local Functions
%==========================================================================

function o = Error(o)
   error('3 input args required!');
end

function machine = Machine(o)                                          
   path = arg(o,1);                    % get path arg
   n = length(path);                   % n must decrement each time
   while ~isempty(path)
      [path,fnam,ext] = fileparts(path);
      name = [fnam,ext];               % re-combine
      
      if length(path) >= n
         break                         % no machine context found
      end
      n = length(path);                % update n with current path length
      
      if length(name) > 0 && name(1) == '#'
         name(1) = '';                 % delete 1st character
         machine = '';
         for (i=1:length(name))
            c = name(i);
            if ('0' <= c & c <= '9')
               machine(end+1) = c;
               continue
            end
            return                     % machine context found!
         end
         return
      end
   end
   machine = '';                       % no machine context found
end
function project = Project(o)                                          
   path = arg(o,1);                    % get path arg
   list = Scope(o,path);               % get list of directories
   
   if isempty(list)
      project = '';                    % no project found
   else
      project = list{end};
      if  length(project) > 0 && project(1) == '[' && project(end) == ']'
         project = project(2:end-1);
      end
   end
end
function folder = Path(o)                                          
   path = arg(o,1);                    % get path arg
   list = Scope(o,path);               % get list of directories
   
   if isempty(list)
      folder = '';                     % no project found
   else
      folder = '';  sep = '';
      for (i=length(list):-1:1)
         folder = [folder,sep,list{i}];   sep = '/';
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

%==========================================================================
% Context Sub Function
%==========================================================================

function [info,list] = doContext(o,path,query)  % Construct Context Info        
%
% CONTEXT   Construct a database node's context info
%
%    All context information can be purely reconstructed from the path
%    of the database object. The return value is a structure comparable to 
%    the info structure returned by corona/query
%
%       info = Context(o,path)         % context info from path
%       info = Context(o,path,query)   % context info from path & query
%
%    CONTEXT makes use of option opt(o,'serials') to convert machine nick
%    names into serial numbers. The value of option 'serials' should be as
%    shown by example:
%
%       serials = {{'Nepes Demo#1','95088403908'},...
%                   {'IMEC TC#1','95088603842'}};
%
%       info = Context(opt(o,'serials',serials),path);
%
%    Rules:
%
%    1) All context info starts with the so called 'scope root' which is 
%    the rightmost mountable directory the path. Note that names of mount-
%    able directories are enclosed by brackets ('[...]').
%
%    2) The scope root name without the brackets is automatically the
%    project name
%
%    3) The right most directory name with trailing '#' character followed
%    by digits and terminated by space determines  the serial context
%
%    4) Object kind is also found in the right most directory name which
%    starts with a mandatory '@' character followed by a valid identifier
%    sequence and terminated by space (e.g. '@ANY ','@PAK ') or an optional
%    '@' character, followed by a valid identifier syntax terminated by a
%    periode ('.')  (e.g., 'PAK.2.34', '@PAK.2.417','MBC.95088411704',
%    'RnD2.') or an optional '@' character followed by a valid identifier
%    syntax leaded by repeated number & '.' sequence (e.g. '@2.345.PAK',
%    '@2.MBC','2.345.PAK','2.MBC')
%
%    5) The right most directory name which can be converted by DATEVEC
%    function to a date vector without an error gives a date context.
%
   if (nargin == 3)
      [info,list] = Context(o,path,query);
      return
   end
   
   serials = opt(o,{'caramba.serials'},{}); % no predefined serial numbers
   
   list = Scope(o,path);               % list of directories in scope
   if isempty(list)                    % note that list order is reversed
      info = [];
      return
   end
%
% We have a nonempty scope, which means that we have also a mountpoint
% directory (= 'scope root). We will use this as the project name
%
   scoperoot = list{end};              % note reversed list order    
   list(end) = [];                     % remove scope root from list
   info.project = scoperoot(2:end-1);  % scopre root => project name
%
% Determine the serial context: the right most directory name with leading
% '#' character followed by digits and terminated by space determines the
% serial context. Otherwise if directory name contains a '#' character we
% can try to assoc the nick name
%
   info.serial = {};
   for (k=1:length(list))                                              
      dir = list{k};
      idx = min(find(dir=='#'));
      if ~isempty(idx)
         if (idx == 1)                      % leading '#' character
            chunk = dir(idx+1:end);
            vec = ('0' <= [chunk,' 0'] & [chunk,' 0'] <= '9');
            len = min(find(vec==0)) - 1;
            chunk = chunk(1:len);
            
            number = sscanf(chunk,'%f');
            id = sprintf('%-20.0f',number);
            len = min(find(id==' ')) - 1;   % index of last digit
            if (length(chunk) == len)
               list(k) = [];                % remove directory from list
               info.serial = {chunk};
               break;
            end
         end
         
            % otherwise we might have chance to find a serial nick         
         
         for (i=1:length(serials))
            entry = serials{i};
            serial = entry{1};
            items = entry{2};
            for (j=1:length(items))
               item = items{j};
               nick = item.text;
               idx = findstr(nick,dir);
               if ~isempty(idx)           % nick name found!
                  list(k) = [];           % remove directory from list
                  info.serial = {serial};
                  break;
               end
            end
            if ~isempty(info.serial)
               break
            end
         end
         
         if ~isempty(info.serial)
            break;
         end
      end
   end
%
% Determine the kind-context: 
%
%    The right most directory name fullfilling one of the following
%    conditions:
%    1) Leaded by a mandatory '@' character followed by a valid identifier
%    syntax and terminated with a periode ('.')
%    2) Leaded by an optional '@' character followed by a valid identifier
%    syntax terminated by a % periode ('.')
%    3) or a leading number & periode sequence followed by a valid
%    identifier.
%
   info.kind = '';
   for (k=1:length(list))
      dir = list{k};
      
         % investigate the leading '@' character case
         
      if ~isempty(dir) && (dir(1) == '@')
         dir(1) = '';                  % strip-off leading '@'
         idx = min(find(dir==' '));
         if ~isempty(idx)
            chunk = dir(1:idx-1);
            ident = Ident(chunk);
            if isequal(ident,chunk)       % if we have an identifier
               list(k) = [];              % remove list item
               info.kind = ident;
               break
            end
         end
      end
      
         % first trial: leading identifier terminated with a periode
         
      idx = min(find(dir=='.'));
      if ~isempty(idx)
         chunk = dir(1:idx-1);
         ident = Ident(chunk);
         if isequal(ident,chunk)       % if we have an identifier
            list(k) = [];              % remove list item
            info.kind = ident;
            break
         end
      end
      
         % second trial: identifier leaded by number & periode sequences

      i = 1;
      valid = (length(dir) > 0) && ('0' <= dir(1) && dir(1) <= '9');

      chunk = '';
      for (i=1:length(dir))
         c = dir(i);
         if ~(valid && (('0' <= c && c <= '9') || c == '.'))
            chunk = dir(i:end);
            break
         end
      end
      
      if (valid)         % was that a valid digit & periode sequence?
         ident = Ident(chunk); 
         if ~isempty(ident)
            list(k) = [];              % remove item from list
            info.kind = ident;         % kind context found
            break                      % proceed to the next info
         end
      end
   end
%
% Determine the date context: the right most directory name which can be
% converted by DATEVEC function to a date vector without errors determines
% the date context
%
   info.datenum = 0;
   for (k = 1:length(list))                                            
      try
         dir = list{k};                % interprete directory as date
         vec = datevec(dir);           % check if this statement crashes?

            % without crash we have found a valid date
            
         list(k) = [];                 % remove item from list
         info.datenum = datenum(vec);  % date context found!
         break;
      catch
         'crashes!';
      end
   end
   
end

%==========================================================================
% Auxillary functions
%==========================================================================

function list = Scope(o,path)          % List of Dir's in Scope        
%
% SCOPE   Return list of directories in the directory scope. Note that
%         list order is reversed.
%
   co = carabase;                      % for access of CARABASE methods
   list = {};
%
% first we have to strip-off the file extension
%
   [path,fnam,ext] = fileparts(path);
   path = [path,'/',fnam];
   
      % begin very dirty code % @@@@@@@@@@@@@@@@@@@@@@@@@@@q
      
   if (length(ext) > 6)
      path = [path,ext];    % eg '.trace' assumed the longest extension
   end

      % end very dirty code % @@@@@@@@@@@@@@@@@@@@@@@@@@@q
   
   while ~isempty(path) && ~isempty(find(path=='['))
      [path,fnam,ext] = fileparts(path);
      dir = [fnam,ext];                % re-combine
      
      if mountable(co,dir)
         list{end+1} = dir;
         return           % reached at a mount point directory we are done
      end
      
      if ~isempty(dir)
         list{end+1} = dir;
      end
   end
%
% coming to this point means that directory '[Corona]' has not been found
% Clear list to indicate that no directories have to be modified
%
   list = {};  

end

function ident = Ident(line)           % Extract Leading Identifier    
%
% IDENT   Extract leading identifier from a text line
%
   if (isempty(line) || ~isletter(line(1)))
      ident = '';                      % oops!
      return                           % no leading identifier
   end
   
   ident = line(1);
   for (i=2:length(line))
      c = line(i);
      if isletter(c) || ('0' <= c && c <= '9') || (c == '_')
         ident(end+1) = c;
         continue;
      end
      break
   end
end

%==========================================================================
% Context Info Incorporating Query Info
%==========================================================================

function [info,list] = Context(o,path,query)
%
   is = @bazaar.is;                    % need some utility
   list = {};
%
% first of all get context info and query info
%
   ctxt = context(o,path);             % get context info
   info = either(query,[]);
%
% now we have context info (ctxt) and query info (info)
% get the info tags list
%
   if is(info)
      qtags = fields(info);
   else
      info = ctxt;                     % copy whole context info
      list = fields(info);             % all fields
      return
   end
   
   if is(ctxt)
      ctags = fields(ctxt);
   else
      ctags = {};
   end
%
% now merge all tags from context info. Any tag which is not available or
% is assigned with empty value will be also added to list of tags (list).
%
   for (k=1:length(ctags))             % setup data matrix
      ctag = ctags{k};
      cvalue = getfield(ctxt,ctag);    % get context value

         % patch in context info?

      if ~isempty(cvalue)
         if find(o,ctag,qtags) == 0       % if context tag missing in query
            info = setfield(info,ctag,cvalue);
            list{end+1} = ctag;
         else
            qvalue = getfield(info,ctag);
            if isempty(qvalue)
               info = setfield(info,ctag,cvalue);
               list{end+1} = ctag;
            end
         end
      end
   end
end

