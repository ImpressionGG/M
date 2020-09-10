function varargout = config(o,tag,list)  % Plot Configuration          
%
% CONFIG   Configure the configuration menu for plotting
%
%    1) Show or get actual configuration for plotting
%
%       config(o)                        % show all configurations
%       config(o,NaN)                    % show specific configuration
%       cfg = config(o)                  % get actual configuration
%
%       o = config(o,'+');               % let shell define configuration
%       o = config(o,'-');               % let trace define configuration
%
%       o = config(o,':');               % return THE TIME symbol
%       o = config(o,'#');               % return THE SYSTEM symbol
%
%       o = config(o,bag);               % set a bag of configurations
%
%    2) Get configuration parameters for a data stream by symbol
%
%       [sub,col] = config(o,'x')        % get config parameters for 'x'
%       list = config(o,'y')             % get config parameters for 'y'
%   
%    3) Get configuration parameters for a data stream by index
%
%       sym = config(o,0)                % get time symbol (always 'time')
%       [sym,sub,col,cat] = config(o,1)  % get 1st symbol (x) & parameters
%       [sym,sub,col,cat] = config(o,2)  % get 2nd symbol (y) & parameters
%
%       [nsym,nsub] = config(o,inf)      % get number of symbols (nsym)
%                                        % and number of subplots (nsub)
%
%    4) Set configuration parameters for a particular data stream
%
%       o = config(o,'x',{1,'r',cat1,L}) % set config parameters for 'x'
%       o = config(o,'y',{2,'g',cat2,L}) % set config parameters for 'y'
%
%       o = config(o,'x',2)              % set subplot = 2 for 'x'
%
%    5) Configuring data streams to be considered for plotting
%
%       o = config(o,{'x','y'});         % consider only 'x' and 'y'
%
%    6) Reset configuration
%
%       o = config(o,[]);                % set all subplots to zero
%
%    7) Provide a default configuration, if not defined
%
%       o = config(o,'');                % provide a default config
%
%    8) Actualize config settings, menu refresh & screen refresh
%
%       o = config(o,o);                 % update settings/menu & refresh
%       o = config(o,{o});               % conditional update settings/menu
%
%    9) Fast attribute retrieve for given subplot number sub
%
%       tokens = config(o,{sub})         % all tokens for subplot 'sub'
%       for (i=1:length(tokens))
%          [sym,sub,col,cat] = config(o,token{i})   % get attributes
%       end
%
%    Remark: if any of the subplots is activated then 'mode.config.opts'
%    setting will be set (value 1), meaning that the container options are
%    are copied to the individual traces. Otherwise the setting will be 
%    cleared, meaning individual trace options are used.
%
%    Example 1: setting up a configuration
%
%       t = 0:0.1:10;  x = 4*sin(t);  y = 5*cos(t); % create data
%       o = trace(caramel,t,'x',x,'y',y,'z',0*t)    % create trace object
%       o = config(o,{'x','y'})                     % setup configuration
%
%    Example 2: changing/retrieving configuration parameters
%
%       o = config(o,'y',{2,'b'});                  % change config y-par
%       list = config(o,'x')                        % retrieve x-par
%       [sym,sub,col,cat] = config(o,'y')           % retrieve y-par
%
%   Example 3: get data of time and data stream y
%
%       t = data(o,config(o,0));                   % get time data
%       x = data(o,config(o,1));                   % get x data
%       y = data(o,config(o,2));                   % get y data
%
%    To see all object type specific config, category and subplot options
%    or settings use
%    
%           type(sho)    % list type specific settings
%           type(o)      % list all type specific options
%
%  See also: CARAMEL, CATEGORY
%
   tags = Tags(o,o.type);              % tags for options & settings
   
   if (nargin >= 2) && isequal(tag,'config')
      'might stop for debug!';
   end
%
% Two input args with 2nd arg being a structure; start with fast mode
% a) [sym,sub,col,cat,lab] = config(o,token{i})   % get attributes
% This is a very fast mode, means that there are no checks!!!
%
   while (nargin == 2 && isstruct(tag) && nargout > 1)
      att = tag;                       % tag is an attribute struct
      varargout{1} = att.symbol;
      if (nargout >= 2)
         varargout{2} = att.index;
      end
      if (nargout >= 3)
         varargout{3} = o.either(att.color,'k');
      end
      if (nargout >= 4)
         varargout{4} = att.category;
      end
      if (nargout >= 5)
         varargout{5} = att.label;
      end
      return
   end
%
% Retrieve current type and make a general check
%
   typ = type(o,o);                    % get actual type
   if ~container(o)
      if ~trace(o)
         error('need a trace type object to config!');
      end
   end
%
% One input arg: 
% a) config(o) % show configuration setup
% b) cfg = config(o) % get configuration option 
%
   while (nargin == 1)                 % 1 input arg ('If-While')      
      if (nargout == 0)
         Show(o);
      else
%        varargout{1} = opt(o,['config.',typ]);
         varargout{1} = opt(o,tags.stream);
      end
      return
   end
%
% Two input args, second arg is an empty double
% o = config(o,[]): clear all subplot references to zero
%
   while ((nargin == 2) || nargin==3) && isa(tag,'double') && isempty(tag)            
      oo = Reset(o);                   % reset all subplots
      oo = Default(oo);                % return output arg
      if (nargin == 3) && ~isempty(list)
         typ = list;
         if ~ischar(typ)
            error('string expected for arg3!');
         end
         oo = type(oo,typ);            % change type to active type
      end
      varargout{1} = oo;
      return
   end
%
% Two input args, second arg is NaN
% o = config(o,NaN) % show type specific list of categories
%
   while (nargin == 2) && isa(tag,'double') && isnan(tag)              
      Show(o,o.type);                  % show type specific configurations
      return
   end
%   
% Two input args, second arg is an empty string
% a) o = config(o,'')                  % provide a default configuration
%
   while (nargin == 2 && ischar(tag) && isempty(tag))                  
      varargout{1} = Default(o);       % return output arg
      return
   end
%
% Two input args, second arg is a struct
% a) o = config(o,bag);                % set a bag of configurations
%
   while (nargin == 2 &&  isstruct(tag))                               
      bag = tag;                       % tag is a struct (bag)
%     varargout{1} = opt(o,['config.',typ],bag); 
      varargout{1} = opt(o,tags.stream,bag); 
      return
   end   
%
% Two input args, second arg is an object
% a) o = config(o,o) % update shell provided configuration
%
   while (nargin == 2 && isobject(tag))                                
      oo = tag;                        % copy object
      pkg = o.iif(subplot(oo,inf),1,0);% use individual options from traces

      if (~pkg)                        % ~pkg means individual trace opts
         oo = current(o);
      end
      
      o = Merge(o,oo,1);               % uncond. merge config, subplot options
      
      mode = subplot(o,'Signal');      % signal mode
      setting(o,'mode.signal',mode);   % set actual signal mode
      
      event(o,'config');               % invoke config event
      varargout{1} = o;
      return
   end
%
% Two input args, second arg is a list embedded object
% a) o = config(o,{o}) % provide a default configuration
%
   while (nargin==2 && iscell(tag) && length(tag)==1 && isobject(tag{1}))                                
      oo = tag{1};                        % copy object
      pkg = o.iif(subplot(oo,inf),1,0);% use individual options from traces

      if (~pkg)                        % ~pkg means individual trace opts
         oo = current(o);
      end
      
      o = Merge(o,oo,0);               % cond. merge config, subplot options
      %event(o,'config');               % invoke config event
      varargout{1} = o;
      return
   end
%
% Two input args, second arg is a list (containg subplot selection number)
% a) tokens = config(o,{sub})          % get token list
%
   while (nargin == 2) && iscell(tag)
      if isempty(tag) || ~isa(tag{1},'double')
         break                         % arg syntax not to be managed here
      end
      idx = round(tag{1});
      if (idx ~= tag{1})
         error('index (arg2) must be an integer!')
      end

%     cfg = opt(o,['config.',typ]);    % get config parameters
      cfg = opt(o,tags.stream);        % get config parameters
      if ~isempty(cfg)
         tags = fields(cfg);           % list of symbols
      else
         tags = {};
      end
      
        % build-up the token list, containing all attribute 
        % structures which are configured for specified subplot
        
      tokens = {};                     % init an empty token list
      for (i=1:length(tags))
         sym = tags{i};
         att = cfg.(sym);
         if (att.index == idx)           % configured for specified subplot?  
            att.symbol = sym;
            tokens{end+1} = att;
         end
      end
      varargout{1} = tokens;
      return
   end
%
% Two input args, second arg is a non-empty double
% a) sym = config(o,0)                 % get time symbol (always 'time')
% b) [sym,sub,col,cat] = config(o,1)   % get 1st symbol (x) & parameters
% c) [sym,sub,col,cat] = config(o,2)   % get 2nd symbol (y) & parameters
%
   while (nargin == 2) && isa(tag,'double') && ~isempty(tag)                 
      varargout{2} = [];  varargout{3} = [];  varargout{4} = [];
      
      idx = round(tag);
      if (idx ~= tag)
         error('index (arg2) must be an integer!')
      end

%     cfg = opt(o,['config.',typ]);           % get config parameters
      cfg = opt(o,tags.stream);               % get config parameters
      if ~isempty(cfg)
         flds = fields(cfg);                  % list of symbols
      else
         flds = {};
      end
      
      i = find(o,'time',flds);                % find string in list
      if (i > 0)
         flds(i) = [];                        % remove 'time' symbol
      end
         
      if (idx == 0)                           % special meaning
         varargout{1} = 'time';               % return time symbol
         return
      elseif isinf(idx)                       % special meaning
         varargout{1} = length(flds);         % return number of symbols
         if (nargout >= 2)
            nsub = 0;                         % return max number of
            for (i=1:length(flds))            % configured subplots
               att = cfg.(flds{i});
               nsub = max(nsub,att.index);
            end
            varargout{2} = nsub;              % return subplot number
         end
         return
      end

      if (idx < 1 || idx > length(flds))
         sym = '';                            % cannot locate symbol
      else
         sym = flds{idx};
      end
      
         % set output args
         
      varargout{1} = sym;
      if (nargout > 1)
         if ischar(sym)
            att = cfg.(sym);                     % get attribute
            varargout{2} = att.index;
            varargout{3} = att.color;
            varargout{4} = att.category;
            varargout{5} = att.label;
         else
            [sub,col,cat,lab] = config(o,sym);
            varargout{2} = sub;
            varargout{3} = col;
            varargout{4} = cat;
            varargout{5} = lab;
         end
      end
      return
   end
%
% Two input args, second arg is a non-empty string
% a) [sub,col] = config(o,'x') % get config parameters for 'x'
% b) list = config(o,'y') % get config parameters for 'y'
% c) o = config(o,'+') % let shell define configuration
% d) o = config(o,'-') % let trace define configuration
% e) o = config(o,'t, x[µ]:r, y[µ]:b')
%
   while (nargin == 2) && ischar(tag) && o.is(tag)
      if o.find(',',tag) || o.find(' ',tag)
         varargout{1} = Smart(o,tag);         % smart configuration
         return
      end
      switch tag
         case '+'
            o = control(o,'options',1);       % shell defines configuration
            varargout{1} = o;
            return
         case '-'
            o = control(o,'options',0);       % object defines configuration
            varargout{1} = o;
            return
         case ':'                             % time symbol
            varargout{1} = 'time';
            return
         case '#'                             % system symbol
            varargout{1} = 'sys';
            return
      end

      varargout{1} = [];  varargout{2} = [];  varargout{3} = [];
%     cfg = opt(o,['config.',typ]);
      cfg = opt(o,tags.stream);
      %cmd = ['cfg.',tag,';'];
      %att = eval(cmd,'[]');                  % get attribute
      if isfield(cfg,tag)
         att = cfg.(tag);                     % get attribute
      else
         att = [];
      end
      
      list = {[],[],[]};                      % default
      if o.is(att)
         list = {att.index, att.color, att.category,att.label};
      end
      
      if o.is(list) && nargout > 1
         varargout = list;
      else
         varargout{1} = list;
      end
      return
   end
%
% Two input args, with a list as second argument
% a) o = config(o,{'x','y'});          % consider only 'x' and 'y'
%
   while (nargin == 2) && iscell(tag)  % setup config based on symbols 
      assert(nargin==2);
      list = tag;                      % interprete arg2 as list

      for (i=1:length(list))
         if ~ischar(list{i})
            error('arg3: all list elements must be of type string!');
         end
      end

   % All arguments have been checked so far! Start now with the real work
   % to setup the configuration

%     cfg.t.index = nan;               % dummy init for t (=> NaN)
%     cfg.t.color = '*';               % dummy init for t (=> '*')
%     cfg.t.category = 0;              % dummy init for t (=> 0  )
%     cfg.t.label = 't';               % dummy init for label
      cfg = [];
      if length(list) > 0
         sym = list{1};
         cfg.(sym).index = nan;           % dummy init for t (=> NaN)
         cfg.(sym).color = '*';           % dummy init for t (=> '*')
         cfg.(sym).category = 0;          % dummy init for t (=> 0  )
         cfg.(sym).label = 't';           % dummy init for label
      end
      
      for (i=2:length(list))
         sym = list{i};                % actual data stream symbol
%        if isequal(sym,'t') || isequal(sym,'time')
%           cfg.t.label = sym;         % dummy init for label
%           continue;                  % already provided
%        end

            % initialize configuration attributes

         att.index = 1;
         att.color = o.color(i);
         att.category = 1;
         att.label = sym;

         cmd = ['cfg.',sym,' = att;']; % store attribute in config
         eval(cmd);
      end

%     varargout{1} = opt(o,['config.',typ],cfg);
      varargout{1} = opt(o,tags.stream,cfg);
      return
   end
%
% Three input args, arg3 being a list: set configuration parameters
% a) o = set(o,'x',{1,'r',cat1})       % stream x
% b) o = set(o,'y',{1,'g',cat1})       % stream y
%
   while (nargin == 3) && iscell(list) % set config parameters         
      if ~ischar(tag)
         error('string expected for arg2!');
      end
      if ~(iscell(list))
         error('list of length 3 expected for arg3!');
      end

         % check parameter type
         
      if length(list) >= 1 && ~isa(list{1},'double')
         error('double expected for 1st parameter (enable)');
      end
      if length(list) >= 2 && ~isa(list{2},'char')
         error('char expected for 2nd parameter (color)');
      end
      if length(list) >= 3 && ~isa(list{3},'double')
         error('double expected for 3rd parameter (category)');
      end
      if length(list) >= 4 && ~isa(list{4},'char')
         error('char expected for 4th parameter (label)');
      end
      
         % actualize
         
%     cfg = opt(o,['config.',typ]);
      cfg = opt(o,tags.stream);
      if isfield(cfg,tag)
         att = cfg.(tag);                 % fetch attributes
      else
         att.index = 0;  att.color = 'k';
         att.category = 1;  att.label = '';
      end
      
      if length(list) >= 1
         att.index = list{1};
      end
      if length(list) >= 2
         att.color = list{2};
      end
      if length(list) >= 3
         att.category = list{3};
      end
      if length(list) >= 4
         att.label = list{4};
      else
         att.label = tag;              % default label
      end
      cfg.(tag) = att;                 % update attributes
%     varargout{1} = opt(o,['config.',typ],cfg);
      varargout{1} = opt(o,tags.stream,cfg);
      return
   end
%   
% Three input args: arg3 being a double: set subplot
% a) o = config(o,'x',2)               % set subplot = 2 for 'x'
%
   while (nargin == 3) && isa(list,'double')  % set subplot index      
      sub = list;                      % list is a subplot index
      if ~ischar(tag)
         error('string expected for arg2!');
      end
      if (length(sub) > 1) || (sub ~= round(sub))
         error('scalar integer expected for subplot index (arg3)!');
      end

         % actualize
         
%     cfg = opt(o,['config.',typ]);
      cfg = opt(o,tags.stream);
      if isfield(cfg,tag)
         att = cfg.(tag);              % fetch attributes
      else
         att.index = 0;  att.color = 'k';
         att.category = 1;  att.label = '';
      end
      
      att.index = sub;
      cfg.(tag) = att;                 % update attributes
%     varargout{1} = opt(o,['config.',typ],cfg);
      varargout{1} = opt(o,tags.stream,cfg);
      return
   end
%
% We are done, and we should never come beyond that point!
%
   error('bad calling syntax!');       % we should never come here
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Default(o)               % Provide default cobfiguration 
%
   if config(o,inf) == 0               % if no config then
      o = config(o,symbol(o));         % provide default config
   end
   %oo = category(o);                  % actualize categories
   oo = o;                             % pass over to output
end
function o = Reset(o)                  % Reset all subplot references  
%
% RESET   Reset all subplot numbers of the configuration to zero
%
%  tag = ['config.',o.type];
   tags = Tags(o,o.type);              % tags for config options & settings
   
   if Tags(o)                          % if new
      o = opt(o,'config',[]);          % clear config options
   else                                % else old style
      o = opt(o,'config',[]);          % clear config options
      o = opt(o,'category',[]);        % clear category optioms
      o = opt(o,'subplot',[]);         % clear subplot options
   end
      
%  o = opt(o,tag,setting(o,tag));      % copy from shell setting
   tag = tags.stream; 
   o = opt(o,tag,setting(o,tag));      % copy from shell setting

   %oo = o.either(pull(o),caramel);    % refresh config options
   %o = opt(o,'config',opt(oo,'config'));
   
   n = config(o,inf);                  % number of configurations
   for (i=1:n)
      [sym,sub,col,cat] = config(o,i); % get 1st symbol (x) & parameters
       o = config(o,sym,{0,col,cat});  % set config parameters for sym
   end
end
function Show(o,otype)                 % Show Configuration            
%
% SHOW   Show configuration
%
   Iif = @o.iif;                       % need some utils
   
   cfgs = opt(o,'config');
   if isempty(cfgs)
      return
   end
   
   list = fields(cfgs);
   for (k=1:length(list))
      typ = list{k};
      if (nargin >= 2)
         if ~isequal(typ,otype)
            continue
         end
      end
%     cfg = cfgs.(typ);
      tags = Tags(o,typ);
      cfg = opt(o,{tags.stream,struct('')});
      
      flds = fields(cfg);
      n = 8;
      if (nargin >= 2)
         fprintf('      config:\n');
      else
         fprintf('      config for type ''%s''\n',typ);
      end
      for (i=1:length(flds))
         sym = flds{i};
         tag = ['                        ',sym];
         tag = Iif(length(sym)<n,tag(end-(n-1):end),['   ',sym]);
         att = eval(['cfg.',sym,';']);
         fprintf(['   %s: index = %g, color = ''%s'',',...
                  ' category = %g, label = ''%s''\n'],...
                  tag,att.index,att.color,att.category,att.label);
      end
   end
end
function list = Split(line)            % Split a line into list of args
%
% SPLIT   Split string into list of args
%
   list = {};  sym = '';  line = [line,' '];  % add stopper
   for (i = 1:length(line))
      c = line(i);
      if isempty(sym) && isletter(c)
         sym(end+1) = c;                  % start with symbol head
         continue
      elseif is(sym) && (isletter(c) || c == '_' || c == '.')
         sym(end+1) = c;                  % build-up inner part of symbol
         continue
      elseif isspace(c) || c == ',' || c == ';'
         if is(sym)
            list{end+1} = sym;  sym = '';
         end
      end
   end
   return
end
function oo = Merge(o,oo,uncond)% Merge Options into Settings          
%
% MERGE   Merge config, category and subplot options of object oo (arg2)
%         into shell settings.
%
%            o = Merge(o,oo);          % merge config, subplot options
%
   either = @o.either;                 % short hand
   
   if Tags(o)                          % if new style
      bag = either(opt(oo,'config'),struct(''));
      types = fields(bag);
      for (i=1:length(types))
         typ = types{i};
         [tags,tag] = Tags(o,typ);
         opts = opt(oo,tag); 
         if uncond
            setting(o,tag,opts);       % unconditional setting update
         else
            setting(o,{tag},opts);     % conditional setting update
         end
      end
   else                                % elseold style
      list = {'config','category','subplot'};
      for (k=1:length(list))
         item = list{k};
         bag = either(opt(oo,item),struct(''));
         types = fields(bag);
         for (i=1:length(types))
            type = types{i};
            tag = [item,'.',type];
            opts = bag.(type);
            if uncond
               setting(o,tag,opts);    % unconditional update of config settings
            else
               setting(o,{tag},opts);  % conditional update of config settings
            end
         end
      end
   end   
   oo = pull(o);                       % refresh object
end
function [tags,tag] = Tags(o,typ)      % Get tags for opts & settings  
   new = true;
   if (nargin == 1)
      tags = new;                      % return new (or old)
   elseif new
      tag = ['config.',typ];
      tags.stream =   [tag,'.stream'];
      tags.category = [tag,'.category'];
      tags.subplot =  [tag,'.subplot'];
   else                                % else old
      tag = NaN;                       % not supported
      tags.stream =   ['config.',typ];
      tags.category = ['category.',typ];
      tags.subplot =  ['subplot.',typ];
   end
end
function oo = Smart(o,line)            % Smart Configuration
   oo = smart(o,line);
   tag = ['config.',o.type];
   oo = opt(o,tag,opt(oo,tag));
end