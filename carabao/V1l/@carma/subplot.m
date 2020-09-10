function out = subplot(o,idx,layout)
%
% SUBPLOT   Subplot management
%
%    The subplot management accesses and manipulates options 'config'
%    and 'subplot
%
%       n = subplot(o,inf)             % get number of subplots
%       key = subplot(o,k)             % get access key for k-th subplot
%
%       subplot(o,k)                   % select k-th subplot
%       k = subplot(o,'x')             % select subplot according to 'x'
%
%       o = subplot(o,'layout',1)      % 1 column layout
%       o = subplot(o,'layout',3)      % 3 column layout (max columns!)
%       o = subplot(o,{3})             % same as above (short form)
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
%    See also: CARALOG, CONFIG, CATEGORY
%
   [either,is] = util(o,'either','is');% need some utils
   
   if (nargin == 1)
      Show(o);                         % show subplot options
      return
   end
%
% first handle the layout setting syntax
%
   while (nargin == 3)
      if ~is(idx,'layout')
         error('string ''layout'' expected for arg2!');
      end
      l = layout;
      if ~(isa(l,'double') && length(l) == 1 && round(l) == l)
         error('index (arg3) must be a scalar integer!');
      end
      if (layout < 1 || layout > 3)
         error('layout (arg3) must be 1,2 or 3');
      end
      
      o = opt(o,'subplot.layout',layout);
      out = o;
      return
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
      if is(sub)
         subplot(o,sub);
      end
      out = sub;
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
   layout = either(opt(o,'subplot.layout'),1);
   
   sub = [];
   for (i=1:config(o,inf))
      [sym,sub(i)] = config(o,i);
   end
   
   if isempty(sub)
      out = 0;
      return                           % no need to continue
   end
   
   nmax = either(max(sub),0);          % max number of subplots
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
% Finalize: either select subplot (narout==0) or return selection key
%
   if (nargout == 0)
      if is(key)
         subplot(key(1),key(2),key(3));   % select k-th subplot
      end
   else
      out = key;                          % otherwise return key
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Show(o)                       % Show Subplot Options          
%
% SHOW   Show subplot options
%
   layout = opt(o,'subplot.layout');
   if is(layout)
      fprintf('  layout: %g\n',layout);
   else
      fprintf('  layout: []\n');
   end
   return
end