function o = log(o,varargin)           % Create Log Object or Log To   
% 
% LOG   Data logging
%
%    Passing strings to the LOG method initializes a data logging object.
%    Subsequent passing of multiple scalar arguments adds values to the
%    data logging object.
%
%       oo = log(caramel,'t','x','y','z',...)    % init a data log object
%       oo = log(oo,t,x,y,z,...)                 % add values to trace log
%       oo = log(oo)                             % new repeat
%
%    Syntactic Sugar: consider that all strings are horizontally concate-
%    nated with comma separation, and all double args are vertically con-
%    catenated (must thus have same number of rows)
%
%       oo = log(caramel,'t,x,y,z');
%       oo = log(caramel,'t',0:100,'x,y,z',rand(3,101));
%       oo = log(caramel,'t',0:100,'x,y,z',rand(m*3,101));
%       oo = log(caramel,'t,x,y,z',0:100,rand(m*3,101));
%       oo = log(caramel,'t,x,y,z',0:100,rand(m*3,101));
%
%       oo = log(caramel,'t[s],x[µ]:r#1,y[µ]#2,th[m°]@g',rand(1+m*3,n));
%
%    Type setting and unpacking plot relevant options is performed
%    if the log object is derived from a shell object:
%
%       o = pull(caramel);
%       oo = log(type(o,'mytype'),'t,x:r,y:b',1:100,sin(1:100),cos(1:100))
%
%    Example 1:
%
%       oo = log(o,'t','u','y');       % create empty data log object
%       T = 0.1;  a = 0.9;  y = 0;
%       for k = 0:100
%          t = k*T;                    % time stamp
%          u = randn;                  % some signal
%          y = a*y + (1-a)*u;          % filtered signal
%          oo = log(oo,t,u,y);         % add values to data log object
%       end
%
%    Example 2:
%
%       oo = log(o,'t','u','y');       % create empty data log object
%       T = 0.1;  a = 0.9;  y = 0;  t = 0;
%
%       for i = 1:repeats
%          oo = log(oo);               % new repeat       
%          for k = 0:100
%             u = randn;               % some signal
%             y = a*y + (1-a)*u;       % filtered signal
%             oo = log(oo,t,u,y);      % add values to data log object
%             t = t + T;               % time transition
%          end
%       end
%
%    See also: CARAMEL, TRACE, PLOT, LABEL, CONFIG, CATEGORY, SUBPLOT
%
   while (nargin > 1 && isa(varargin{1},'double'))
      if iscell(o.data)
         error('object must be a trace object for data logging!');
      end
      tags = fields(o.data);
      if length(tags) ~= length(varargin)
         error('bad number of input args - does not match number of data members!');
      end

         % check if all args have same number of data elements
     
      nmax = prod(size(varargin{1}));
      for (i=2:length(tags))
         if prod(size(varargin{i})) ~= nmax
            error('all data added to log object must have same number of data elements!');
         end
      end
      
         % add data to log object
      
      for (i=1:length(tags))
         tag = tags{i};
         array = o.data.(tag);
         argi = varargin{i};           % get i-th arg
         rowi = argi(:)';              % make a row vector
         
         %array(:,end+1) = varargin{i};
         array = [array,rowi];
         o.data.(tag) = array;
      end
           
         % update sizes only in first repeat !!!
         
      if (o.par.sizes(3) == 0)         % missing o = log(o) call?
         o.par.sizes(3) = 1;           % auto init of repeat
      end
      if (o.par.sizes(3) == 1)         % during first repeat
         o.par.sizes(2) = o.par.sizes(2) + nmax;
      end
      return
   end
%
% otherwise setup an empty log object
%
   while (nargin > 1 && ischar(varargin{1}))
      if container(o)                  % this is an allowed possibility
         o.par = [];  o.data = [];
         o = with(o,'style');          % unpack 'style' options
         o = with(o,'view');           % unpack 'view' options
         o = with(o,'select');         % unpack 'select' options
         o = arg(o,{});                % clear args
      end
      
      if ~isequal(o.data,{}) && ~isempty(o.data)
         error('empty data property expected!');
      end
      
      [o,symbols,values,descriptors] = Parse(o,varargin);  
      
      if (~isempty(o.data))
          o.par.sizes(3) = o.par.sizes(3) + 1;
          return
      end
      
      o.data = [];                       % initialize data property
      for (i=1:length(symbols))
         tag = symbols{i};
         if ~ischar(tag)
            error('all args expected to be char!');
         end
         if length(values) == length(symbols)
            value = values{i};           % get i-th value
            o.data.(tag) = value;        % set data member with i-th value
         else
            o.data.(tag) = [];           % initialize data member
         end
      end

      if length(values) == length(symbols)
         r = 1;
         n = length(values{1});        % columns
      else
         n = 0; r = 0;
      end
      
      o = launch(o,'shell');             % provide launch function
      o = config(o,symbols);             % default configuration
      
      for (i=1:length(descriptors))
         bag = descriptors{i};
         o = config(o,bag.sym,{bag.sub,bag.col,bag.cat,bag.label});
      end
      
      o = set(o,'method','tlrs');        % make it being defined
      o = set(o,'sizes',[1 n r]);        % define one row, init repeats = r
      
      o = set(o,{'title'},['Log Object @ ',o.now]);
      o = arg(o,{});                     % clear args
      return
   end
%
% Start new Repeat
% o = log(o);
%
   if (nargin == 1)
      o.par.sizes(3) = o.par.sizes(3) + 1;
      return
   end
%
% Reaching the c ode beyond this point indicates an error
%
   error('bad calling syntax!');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [o,symbols,values,descriptors] = Parse(o,list)                
%
% PARSE Parse the following syntax which is given by example
%
%          oo = log(caramel,'t,x,y,z');
%          oo = log(caramel,'t',0:100,'x,y,z',rand(3,101));
%          oo = log(caramel,'t',0:100,'x,y,z',rand(m*3,101));
%          oo = log(caramel,'t,x,y,z',0:100,rand(m*3,101));
%          oo = log(caramel,'t,x,y,z',0:100,rand(m*3,101));
%
%          oo = log(caramel,'t[s],x[µ]:r#1,y[µ]#2,th[m°]@g',rand(1+m*3,n));
%   
   line = '';
   symbols = {};
   values = [];
   descriptors = {};
   
   for (i = 1:length(list))
      item = list{i};
      if ischar(item)
         line = [line,',',item];
      elseif isa(item,'double')
         if ~isempty(values) && size(values,2) ~= size(item,2)
            error('all double data must have same column sizes!');
         end
         values = [values; item];
      else
         error('only character args or double args expected!');
      end
   end
   
      % now parse string
      
   if length(line) > 0 && line(1) == ','
      line(1) = [];
   end
   line(end+1) = ',';
   
   sym = '';  col = '';  cat = 0;  sub = 0;  unit = '';  label = '';
   n = length(line);  i = 1;
   
   c = Get('impossible error!');
   while (1)
      if (c == ' ')
         c = Get('bad character after white space!');
         continue
      elseif (c == ',')
         if ~isempty(sym)
            bag.sym = sym;
            bag.col = col;
            bag.cat = cat;
            bag.sub = sub;
            bag.unit = unit;
            bag.label = o.either(label,sym);
            symbols{end+1} = sym;
            descriptors{end+1} = bag;
         end
         sym = '';  col = '';  cat = 0;  sub = 0;  unit = '';  label = '';
         if (i >= n)
            break;
         end
         c = Get('impossible error!');
         continue;               % separator
      elseif IsLetter(c) || IsDigit(c) && ~isempty(sym)
         sym(end+1) = c;
         c = Get('separator expected!');
         continue
      elseif (c == '[')
         c = Get('character expected for unit!');
         while (c ~= ']')
            unit(end+1) = c;
            c = Get('character expected for unit!');
         end
         c = Get('separator expected!');
         continue
      elseif (c == ':')
         c = Get('character expected for color string!');
         while ~IsSpecial(c)
            col(end+1) = c;
            c = Get('character expected for color string!');
         end
         continue
      elseif (c == '@')
         c = Get('digit expected for category number!');
         while IsDigit(c)
            cat = cat*10 + (c - '0');
            c = Get('digit expected for category number!');
         end
         continue
      elseif (c == '#')
         c = Get('digit expected for subplot number!');
         while IsDigit(c)
            sub = sub*10 + (c - '0');
            c = Get('digit expected for subplot number!');
         end
         continue
      else
         error('syntax error: unexpected character!');
      end
   end % while
   
      % check if data is compatible with symbols
      
   if ~isempty(values)
      n = length(symbols) - 1;            % not counting time symbol
      [M,~] = size(values);
      m = (M-1) / n;

      if (m ~= round(m))
         error('incompatible number of data rows with number of symbols!');
      end

         % ok - now we can split up the values

      bulk = values;
      values = {bulk(1,:)};
      for (i = 1:n)
         i1 = 2 + (i-1)*m;  i2 = i1 + m-1;
         values{i+1} = bulk(i1:i2,:);
      end
   end
   
      % finally we tweak the desctrtiptors in a smart way
      
   [o,descriptors] = Smart(o,descriptors);
   return
      
   function c = Get(errmsg)            % Get Character                 
      if (i > n)
         error(['syntax error: ',errmsg]);
      end
      c = line(i);  i = i+1;
   end
   function ok = IsLetter(c)           % Is Character a Letter         
      ok = ('a' <= c && c <= 'z' || 'A' <= c && c <= 'Z');
   end
   function ok = IsDigit(c)            % Is Character a Digit          
      ok = ('0' <= c && c <= '9');
   end
   function ok = IsSpecial(c)          % Is it a Special Character     
      ok = (c == ' ' || c == ',' || c == '#' || c == '@');
      ok = ok || (c == ':' || c == '[' || c == ']');
   end
end
function [o,descriptors] = Smart(o,descriptors)                        
   o = subplot(o,'layout',1);          % set subplot layout
   
   if (length(descriptors) >= 1)
      bag = descriptors{1};            % representing time dimension
      bag.sub = NaN;                   % default for time symbol
      bag.col = '*';                   % default for time symbol
      bag.cat = 0;                     % default for time symbol
      descriptors{1} = bag;            % store back
   end

   units = {};
   for (i=2:length(descriptors))
      bag = descriptors{i};
      cat = find(o,bag.unit,units);
      if (cat == 0) && ~isempty(bag.unit)
         units{end+1} = bag.unit;
         cat = length(units);
         o = category(o,cat,[],[],bag.unit); 
      end
      
      if isempty(bag.cat) || (length(units) > 0 && isequal(bag.cat,0))
         bag.cat = cat;
      end
      if isempty(bag.sub) || isequal(bag.sub,0)
         bag.sub = max(1,cat);
      end
      descriptors{i} = bag;
   end
end
