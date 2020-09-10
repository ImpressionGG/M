function varargout = config(o,tag,list)% Plot Configuration            
%
% CONFIG   Configure the configuration menu for plotting
%
%    1) Show or get actual configuration for plotting
%
%       config(o)                        % show actual configuration
%       cfg = config(o)                  % get actual configuration
%
%       o = config(o,'+');               % let shell define configuration
%       o = config(o,'-');               % let trace define configuration
%
%       o = config(o,':');               % return THE TIME symbol
%       o = config(o,'#');               % return THE SYSTEM symbol
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
%       n = config(o,inf)                % get number of symbols in ylist
%
%    4) Set configuration parameters for a particular data stream
%
%       o = config(o,'x',{1,'r',cat1})   % set config parameters for 'x'
%       o = config(o,'y',{2,'g',cat2})   % set config parameters for 'y'
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
%
%    Remark: if any of the subplots is activated then 'mode.config.opts'
%    setting will be set (value 1), meaning that the container options are
%    are copied to the individual traces. Otherwise the setting will be 
%    cleared, meaning individual trace options are used.
%
%    Example 1: setting up a configuration
%
%       t = 0:0.1:10;  x = 4*sin(t);  y = 5*cos(t); % create data
%       o = trace(caracook,t,'x',x,'y',y,'z',0*t)   % create trace object
%       o = config(o,{'x','y'})                     % setup configuration
%
%    Above statement causes to build the following internal parameter
%    structure:
%
%       o = set(o,'config.xlist','time')            % always 'time'
%       o = set(o,'config.ylist.x',{1,'r',cat1})    % stream x
%       o = set(o,'config.ylist.y',{1,'g',cat1})    % stream y
%
%    Example 2: changing/retrieving configuration parameters
%
%       o = config(o,'y',{2,'b'});                  % change config y-par
%       list = config(o,'x')                        % retrieve x-par
%       [sym,sub,col,cat] = config(o,'y')           % retrieve y-par
%
%    Above statement builds the following internal parameter structure
%
%       o = set(o,'config.xlist','time')            % always 'time'
%       o = set(o,'config.ylist.x',{1,'r',cat1)     % stream x
%       o = set(o,'config.ylist.y',{1,'g',cat1)     % stream y
%
%   Example 3: get data of time and data stream y
%
%       t = data(o,config(o,0));                   % get time data
%       x = data(o,config(o,1));                   % get x data
%       y = data(o,config(o,2));                   % get y data
%
%  See also: CARALOG, CATEGORY
%
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
         varargout{1} = opt(o,'config');
      end
      return
   end
%
% Two input args, second arg is an empty double
% o = config(o,[]): clear all subplot references to zero
%
   while (nargin == 2) && isa(tag,'double') && isempty(tag)            
      varargout{1} = Reset(o);
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
% Two input args, second arg is an object
% a) o = config(o,o)                   % provide a default configuration
%
   while (nargin == 2 && isobject(tag))                                
      oo = category(o);                % actualize category option
      [Iif] = util('iif');             % need some utils
      pkg = Iif(subplot(oo,inf),1,0);  % use individual options from traces

      if (~pkg)                        % ~pkg means individual trace opts
         oo = current(o);
      end
      
      setting('config',opt(oo,'config'));     % update config settings
      setting('subplot',opt(oo,'subplot'));   % update subplot setting
      setting('category',opt(oo,'category')); % update category setting
      setting('mode.config.opts',pkg);        % activate container options
      
      o = pull(core);                         % refresh object by GFO
      menu(o,'Config');                       % update configuration
      refresh(pull(core));                    % refresh screen
      
      varargout{1} = o;
      return
   end
%
% Two input args, second arg is a non-empty double
% a) sym = config(o,0)                 % get time symbol (always 'time')
% b) [sym,sub,col,cat] = config(o,1)   % get 1st symbol (x) & parameters
% c) [sym,sub,col,cat] = config(o,2)   % get 2nd symbol (y) & parameters
%
   while (nargin == 2) && isa(tag,'double') && o.is(tag)                 
      varargout{2} = [];  varargout{3} = [];  varargout{4} = [];
      
      if isempty(tag)
         varargout{1} = opt(o,'config',[]);   % reset configuration
         return
      end
      
      idx = round(tag);
      if (idx ~= tag)
         error('index (arg2) must be an integer!')
      end

      cfg = opt(o,'config');                  % get config parameters
      if o.is(cfg)
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
         [sub,col,cat] = config(o,sym);
         varargout{2} = sub;  varargout{3} = col;  varargout{4} = cat;
      end
      return
   end
%
% Two input args, second arg is a non-empty string
% a) [sub,col] = config(o,'x') % get config parameters for 'x'
% b) list = config(o,'y') % get config parameters for 'y'
% c) o = config(o,'+') % let shell define configuration
% d) o = config(o,'-') % let trace define configuration
%
   while (nargin == 2) && ischar(tag) && o.is(tag)                       
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
      cfg = opt(o,'config');
      cmd = ['cfg.',tag,';'];
      att = eval(cmd,'[]');                   % get attribute

      list = {[],[],[]};                         % default
      if o.is(att)
         list = {att.index, att.color, att.category};
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

      cfg.time.index = nan;            % dummy init for time (=> NaN)
      cfg.time.color = '*';            % dummy init for time (=> '*')
      cfg.time.category = 0;           % dummy init for time (=> 0  )

      for (i=1:length(list))
         sym = list{i};                % actual data stream symbol
         if o.is(sym,'time')
            error('stream symbol cannot be ''time''!');
         end

            % initialize configuration attributes

         att.index = 1;
         att.color = o.color(i);
         att.category = 1;

         cmd = ['cfg.',sym,' = att;']; % store attribute in config
         eval(cmd);
      end

      varargout{1} = opt(o,'config',cfg);
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
         
      if ~isa(list{1},'double')
         error('double expected for 1st parameter (enable)');
      end
      if ~isa(list{2},'char')
         error('char expected for 2nd parameter (color)');
      end
      
         % actualize
         
      cfg = opt(o,'config');
      if isfield(cfg,tag)
         att = cfg.(tag);                 % fetch attributes
      else
         att.index = 0;  att.color = 'k';  att.category = 1;
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
      cfg.(tag) = att;                 % update attributes
      varargout{1} = opt(o,'config',cfg);
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
         
      att = opt(o,['config.',tag]);
      if is(att)                       % initialized signal?
         o = opt(o,['config.',tag,'.index'],sub);
      end
      varargout{1} = o;
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
   if config(o,inf) == 0            % if no config then
      o = config(o,symbol(o));      % provide default config
   end
   oo = category(o);                % actualize categories
end

function oo = Reset(o)                 % Reset all subplot references  
%
% RESET   Reset all subplot numbers of the configuration to zero
%
   n = config(o,inf);                  % number of configurations
   for (i=1:n)
      [sym,sub,col,cat] = config(o,i); % get 1st symbol (x) & parameters
       o = config(o,sym,{0,col,cat});  % set config parameters for sym
   end
   oo = o;
   return
end

function Show(o)                       % Show Configuration            
%
% SHOW   Show configuration
%
   Iif = @o.iif;                       % need some utils

   cfg = config(o);
   if isempty(cfg)
      return
   end
   
   flds = fields(cfg);
   n = 8;
   for (i=1:length(flds))
      sym = flds{i};
      tag = ['                        ',sym];
      tag = Iif(length(sym)<n,tag(end-(n-1):end),['   ',sym]);
      att = eval(['cfg.',sym,';']);
      fprintf('%s: index = %g, color = ''%s'', category = %g\n',...
         tag,att.index,att.color,att.category);
   end
   return
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

