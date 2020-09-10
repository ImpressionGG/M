function out = subplot(o,idx,value)
%
% SUBPLOT   Subplot management
%
%    The subplot management accesses and manipulates options 'config'
%    and 'subplot
%
%       subplot(o)                     % show all subplot configs
%       subplot(o,NaN)                 % show specific subplot configs
%       bag = subplot(o)               % get bag of subplot configs
%       o = subplot(o,bag)             % set bag of subplot configs
%
%       sub = subplot(o,inf)           % get number of subplots
%       key = subplot(o,k)             % get access key for k-th subplot
%
%       subplot(o,k)                   % select k-th subplot
%       k = subplot(o,'x')             % select subplot according to 'x'
%
%       o = subplot(o,'Layout',1)      % 1 column layout
%       o = subplot(o,'Layout',3)      % 3 column layout (max columns!)
%       o = subplot(o,{3})             % same as above (short form)
%
%       o = subplot(o,'Color',[0.8 0.9 0.9])  % set background color
%       color = subplot(o,'Color');    % get background color
%       mode = subplot(o,'Signal');    % get signal mode
%
%       subplot(o,oo);                 % unconditional upload
%       subplot(o,{oo});               % unconditional upload
%
%    Example:
%       o = trace(t,'x','y');
%       o = config(o,'x',{1,'r'},'y',{2,'b'});
%       o = subplot(o,'layout',1)      % layout with 1 subplot column
%
%       n = subplot(o,inf)             % n = 2 (2 subplots congigured)
%       key = subplot(o,1)             % key = [2 1 1] 
%       key = subplot(o,2)             % key = [2 1 2] 
%
%       o = subplot(o,'layout',2)      % layout with 2 subplot column
%       key = subplot(o,1)             % key = [1 2 1] 
%       key = subplot(o,2)             % key = [1 2 2] 
%
%    To see all object type specific config, category and subplot options
%    or settings use
%    
%           type(sho)    % list type specific settings
%           type(o)      % list all type specific options
%
%    See also: CARAMEL, CONFIG, CATEGORY, SIGNAL
%
   [tags,~,cfgtag] = Tags(o,o.type);   % tags fot config options & settings
   typ = type(o,o);                    % actual type
%
% One input arg
% a) subplot(o) % show subplot configs
% b) bag = subplot(o) % get bag of subplot configs
%
   while (nargin == 1)
      if (nargout == 0)
         Show(o);                      % show all subplot options
      else
         typ = type(o,o);              % get actual type
%        out = opt(o,['subplot.',typ]);
         out = opt(o,tags.subplot);
      end
      return
   end
%
% Two input args and arg2 is a struct
% a) o = subplot(o,bag) % set bag of subplot configs
%
   while (nargin == 2) && (isstruct(idx) || isempty(idx))
      bag = idx;                       % idx is a struct (bag)
      typ = type(o,o);                 % get actual type
%     out = opt(o,['subplot.',typ],bag);
      out = opt(o,tags.subplot,bag);
      return
   end
%
% Two input args and arg2 is an object
% a) o = subplot(o,o) % unconditional type specific upload%
   while (nargin == 2) && isobject(idx)
      oo = idx;                        % idx is an object
      upload(oo,cfgtag,'*','subplot');
      return
   end
%
% Two input args and arg2 is an embedded object
% a) o = subplot(o,o) % conditional type specific upload
%
   while (nargin == 2) && iscell(idx) && length(idx) == 1 && isobject(idx{1})
      oo = idx{1};                         % idx is an object
      upload(oo,{cfgtag,'*','subplot'});   % conditional upload
      return
   end
%
% Two input args and arg2 is NaN
% a) o = subplot(o,NaN) % show specific subplot config
%
   while (nargin == 2) && isa(idx,'double') && isnan(idx)
      Show(o,o.type);
      return
   end
%   
% Two input args and arg2 is a char
% a) color = subplot(o,'Color'); % get background color
% b) mode = subplot(o,'Signal'); % get signal mode
%
   while (nargin == 2) && ischar(idx)
      mode = idx;                      % idx is a mode
      typ = type(o,o);                 % get actual type
      switch mode
         case {'color'}
            error('error: use subplot(o,''Color'') instead!');
         case {'Color'}
%           tag = ['subplot.',typ,'.','color'];
            tag = [tags.subplot,'.color'];
            out = opt(o,{tag,[]});
         case {'Signal'}
%           tag = ['subplot.',typ,'.','signal'];
            tag = [tags.subplot,'.signal'];
            out = o.either(opt(o,{tag,[]}),'');
         case {'Layout'}
            tag = [tags.subplot,'.layout'];
            out = o.either(opt(o,{tag,[]}),'');
         otherwise
            error('''Color'',''Signal'' or ''Layout'' expected for arg2!');
      end
      return
   end
%
% Three input args
% a) o = subplot(o,'layout',3) % 3 column layout (max columns!)
% b) o = subplot(o,'color',[0.8 0.9 0.9]) % set background color
%
   while (nargin == 3)
      switch idx
         case {'Layout','layout'}
            layout = value;  l = layout;
            if ~(isa(l,'double') && length(l) == 1 && round(l) == l)
               error('index (arg3) must be a scalar integer!');
            end
            if (layout < 1 || layout > 3)
               error('layout (arg3) must be 1,2 or 3');
            end

%           o = opt(o,['subplot.',typ,'.layout'],layout);
            o = opt(o,[tags.subplot,'.layout'],layout);
            out = o;
            return
         case {'Color','color'}
            color = value;
            if ~isa(color,'double') || any(size(color)~=[1 3])
               error('color must be 1x3 RGB color value');
            end
%           o = opt(o,['subplot.',typ,'.color'],color);
            o = opt(o,[tags.subplot,'.color'],color);
            out = o;
            return
         case {'Signal'}
            mode = value;
            if ~ischar(mode)
               error('signal mode must be a string');
            end
%           o = opt(o,['subplot.',typ,'.signal'],mode);
            o = opt(o,[tags.subplot,'.signal'],mode);
            out = o;
            return
         otherwise
            error('string ''Layout'', ''Color'' or ''Signal'' expected for arg2!');
      end
   end
%
% argument checks
%
   while (nargin < 2)                  % error for nargin < 2          
      error('2 input args expected!')
   end
%
% if arg2 is a cell array we define the layout (number of columns)
% a) o = subplot(o,{3}) % 3 column layout (max columns!)
%
   while isa(idx,'cell')               % define layout                 
      list = idx;                      % idx refers to a list
      if length(list) ~= 1
         error('1 list element expected for arg2!');
      end
      number = list{1};
      if ~isa(number,'double') || length(number) ~= 1
         error('layout number (arg2{1}) must be a scalar!');
      end
      if number ~= round(number)
         error('layout number (arg2{1}) must be an integer scalar!');
      end
      out = subplot(o,'layout',number);
      return
   end
%
% if index is a string we try to select according to index   
% a) k = subplot(o,'x') % select subplot according to 'x'
%   
   while isa(idx,'char')               % select symbol related subplot 
      sym = idx;                       % idx refers to a symbol
      [sub,~] = config(o,sym);
      if ~isempty(sub)
         subplot(o,sub);
      end
      out = sub;
      return
   end
%
% Two input args and 2nd arg is INF 
% a) n = subplot(o,inf) % get number of subplots
%
   while (nargin == 2) && isinf(idx)
      [~,out] = config(o,inf);         % number of subplots
      return
   end
%
% check for proper index
%
   while ~(isa(idx,'double') && length(idx) == 1 && round(idx) == idx) 
      error('index (arg2) must be a scalar integer or string!');
   end
%  
% calculate the maximum number of configured subplots
%
%  layout = opt(o,{['subplot.',typ,'.layout'],1});
   layout = opt(o,{[tags.subplot,'.layout'],1});
   
%    sub = [];
%    for (i=1:config(o,inf))
%       [sym,sub(i)] = config(o,i);
%    end

   [~,sub] = config(o,inf);            % max number of subplots
   if isempty(sub)
      out = 0;
      return                           % no need to continue
   end
   
   nmax = max(sub);                    % max number of subplots
   if isempty(nmax)
      nmax = 0;
   end
   
   ncols = floor(layout);              % number of subplot columns
   nrows = ceil(max(sub)/ncols);       % number of subplot rows
%
% Now we can dispatch on the calling syntax
%
   if (1 <= idx && idx <= nmax)
      key = [nrows,ncols,idx];
   elseif isinf(idx)
      out = nmax;
      return
   else
      key = [];
   end
%   
% Finalize: either select subplot (nargout==0) or return selection key
%
   if (nargout == 0)
      if ~isempty(key)
         subplot(key(1),key(2),key(3));   % select k-th subplot
      end
   else
      out = key;                          % otherwise return key
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Show(o,typ)                   % Show Subplot Options          
%
% SHOW   Show subplot options
%

%  subplot = opt(o,'subplot');
%  if ~isempty(subplot)
   if (1)
 %   list = fields(subplot);
      if Tags(o)                       % if new style category options
         bag = opt(o,{'config',struct('')});
         list = fields(bag);
      else                             % else old style category options
         subplot = opt(o,{'subplot',struct('')});
         list = fields(subplot);
      end
      for (i=1:length(list))           % with all types
         typi = list{i};
         if (nargin >= 2)
            if ~isequal(typi,typ)
               continue
            end
         end
%        tag = ['subplot.',list{i}];
         tags = Tags(o,typi);
         tag = tags.subplot;
         
         if (nargin >= 2)
            fprintf('      subplots:\n');
         else
            fprintf('      subplots for type ''%s''\n',list{i});
         end
         layout = opt(o,[tag,'.layout']);
         color = opt(o,{[tag,'.color'],[]});
         signal = opt(o,{[tag,'.signal'],''});

         if ~isempty(layout)
            fprintf('         layout: %g\n',layout);
         else
            fprintf('         layout: []\n');
         end
         
         if ~isempty(color)
            fprintf('         color: [%g,%g,%g]\n',color(1),color(2),color(3));
         else
            fprintf('         color: []\n');
         end

         if ~isempty(signal)
            fprintf('         signal: %s\n',signal);
         else
            fprintf('         signal: ''''\n');
         end
      end
   end
end
function [tags,tag,cfg] = Tags(o,typ)  % Get tags for options and settings
   new = true;                         % flag indicating new world
   if (nargin == 1)
      tags = new;                      % return new (or old)
   elseif new
      cfg = 'config';
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
