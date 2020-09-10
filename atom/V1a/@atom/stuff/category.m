function varargout = category(o,cat,spec,limit,unit)
%
% CATEGORY   Setup or display categories
%
%    Syntax:
%
%       [spec,limit,unit] = category(o,cat);   % get category attributes
%       [specs,limits,units] = category(o);    % get category attributes
%       bag = category(o)                      % get bag of category opts
%
%       o = category(o,bag);                   % set category settings' bag
%       o = category(o,o);                     % update shell settings
%
%       o = category(o,cat,spec,limit,unit);   % setup category
%       o = category(o,1,[0 0],[0 0],'µ');     % setup category 1
%       o = category(o,1,[],[],'µ');           % same as above
%       o = category(o,2,[-3 3],[-4 4],'µ');   % setup category 2
%
%       n = category(o,inf)                    % number of categories
%       category(o)                            % list all categories
%       category(o,NaN)                        % list specific categories
%
%                                              % return number m of cat's
%
%    To see all object type specific config, category and subplot options
%    or settings use
%    
%           type(sho)    % list type specific settings
%           type(o)      % list all type specific options
%
%    Remark: categories are stored in opt(o,['category.',type(current(o))])
%
%    See also: CARAMEL, CONFIG, SUBPLOT, TYPE
%
   tags = Tags(o,o.type);              % tags for config options & settings
%
% One input arg
% a) category(o) % list all categories
% b) bag = category(o); % get bag of category opts
% c) [specs,limits,units] = category(o); % get category attributes
%
   while (nargin == 1)                                                 
      if (nargout == 0)                % list categories               
         Show(o);                      % show all categories
      elseif (nargout == 1)
         typ = type(o,o);              % get actual type
%        varargout{1} = opt(o,['category.',typ]);      
         varargout{1} = opt(o,tags.category);      
      else
         typ = type(o,o);              % get actual type
%        varargout{1} = opt(o,['category.',typ,'.specs']);         
         varargout{1} = opt(o,[tags.category,'.specs']);         
%        varargout{2} = opt(o,['category.',typ,'.limits']);         
         varargout{2} = opt(o,[tags.category,'.limits']);         
%        varargout{3} = opt(o,['category.',typ,'.units']);         
         varargout{3} = opt(o,[tags.category,'.units']);         
      end
      return
   end
%
% one input arg and 1 output arg means that the category 
% options have to be actualized
% a) [o,m] = category(o) % actualize category opts
%
   while (nargin == 1 && nargout >= 1) % actualize category options    
      [oo,m] = Actualize(o);           % actualize category options
      varargout{1} = oo;
      varargout{2} = m;
      return
   end
%
% Two input args and arg2 is a struct
% a) o = category(o,bag); % set category settings' bag
%   
   while (nargin == 2 && isstruct(cat)) % set bag of category settings 
      bag = cat;                    % cat is a struct (bag)
      typ = type(o,o);              % get actual type
%     varargout{1} = opt(o,['category.',typ],bag);
      varargout{1} = opt(o,tags.category,bag);
      return
   end
%
% Two input args and arg2 is NaN
% a) category(o,NaN) % list specific category settings
%   
   while (nargin == 2 && isa(cat,'double') && ~isempty(cat) && isnan(cat))              
      Show(o,o.type);               % show specific categories
      return
   end
%
% Two input args and arg2 is an object
% a) o = category(o,o); % update shell settings
%   
   while (nargin == 2 && isobject(cat)) % update category settings     
      if Tags(o)                       % if new style of config options
         o = Upload(o,'config','*','category');
         varargout{1} = o;
      else
         bag = opt(o,'category');
         setting(o,'category',bag);
         varargout{1} = o;
      end
      return
   end
%
% For 2 and more input args arg2 must be a scalar integer > 0
%
   while nargin == 2 && isempty(cat)                                   
      typ = type(o,o);                 % get actual type
%     varargout{1} = opt(o,['category.',typ],[]);
      varargout{1} = opt(o,tags.category,[]);
      return
   end
   if ~(isa(cat,'double') && length(cat) == 1)
      error('arg2 must be a scalar number!');
   end
   if (round(cat) ~= cat || cat < 0)
      error('arg2 must be an integer >= 0!');
   end
%
% For 2 input args we have to retrieve category attributes
% a) n = category(o,inf) % number of categories
% b) [spec,limit,unit] = category(o,cat);   % get category attributes
%
   while (nargin == 2)                                                 
      if isinf(cat)
         varargout{1} = Number(o);     % return number of categories
         return
      end

         % get spec

      typ = type(o,o);                 % get actual type
%     specs = opt(o,['category.',typ,'.specs']);
      specs = opt(o,[tags.category,'.specs']);
      varargout{1} = [0 0];
      if (size(specs,1) >= cat)
         if (cat > 0)
            varargout{1} = specs(cat,:);
         else                          % for time signal
            varargout{1} = [0 0];
         end
      end
      
         % get limit
         
%     limits = opt(o,['category.',typ,'.limits']);
      limits = opt(o,[tags.category,'.limits']);
      
      varargout{2} = [0 0];
      if (size(limits,1) >= cat)
         if (cat > 0)
            varargout{2} = limits(cat,:);
         else                          % for time signal
            varargout{1} = [0 0];
         end
      end
      
         % get unit
         
%     units = opt(o,['category.',typ,'.units']);
      units = opt(o,[tags.category,'.units']);
      
      varargout{3} = '';
      if (length(units) >= cat)
         if (cat > 0)
            varargout{3} = units{cat};
         else
            varargout{3} = 's';
         end
      end
      return
   end
%
% 3 or more input args means to set category attributes
% a) o = category(o,cat,spec,limit,unit);   % setup category
% b) o = category(o,1,[0 0],[0 0],'µ');     % setup category 1
% c) o = category(o,1,[],[],'µ');           % same as above
% d) o = category(o,2,[-3 3],[-4 4],'µ');   % setup category 2
%
   while (nargin > 2)                                                  
      if isempty(spec)
         spec = [0 0];
      end
      if (nargin < 4)
         limit = [0 0];
      end
      if isempty(limit)
         limit = [0 0];
      end
      if (nargin < 5)
         unit = '';
      end
      
         % update specs
         
      [m,n] = size(spec);
      if (m*n == 1)                    % for scalars symmetrize spec
         spec = [-1 1]*abs(spec);
         [m,n] = size(spec);
      end      
      if (any([m n]~=[1 2]) || ~isa(limit,'double'))
         error('spec dimension (arg3) must be 1x2!');
      end
      
      typ = type(o,o);                 % get actual type
%     specs = opt(o,['category.',typ,'.specs']);
      specs = opt(o,[tags.category,'.specs']);
      
      [m,n] = size(specs);

      for (i=m+1:cat-1)
         specs(i,1:2) = [0 0];
      end
      specs(cat,1:2) = spec;
%     o = opt(o,['category.',typ,'.specs'],specs);
      o = opt(o,[tags.category,'.specs'],specs);
      
         % update limits
         
      [m,n] = size(limit);
      if (m*n == 1)                    % for scalars symmetrize limit
         limit = [-1 1]*abs(limit);
         [m,n] = size(limit);
      end      
      if (any([m n]~=[1 2]) || ~isa(limit,'double'))
         error('limit dimension (arg4) must be 1x2!');
      end
      
%     limits = opt(o,['category.',typ,'.limits']);
      limits = opt(o,[tags.category,'.limits']);
      [m,n] = size(limits);
      
      for (i=m+1:cat-1)
         limits(i,1:2) = [0 0];
      end
      limits(cat,1:2) = limit;
%     o = opt(o,['category.',typ,'.limits'],limits);
      o = opt(o,[tags.category,'.limits'],limits);
      
         % update units
         
      if ~ischar(unit) 
         error('unit (arg5) must be string!');
      end
      
%     units = opt(o,['category.',typ,'.units']);
      units = opt(o,[tags.category,'.units']);
      
      m = length(units);
      for (i=m+1:cat-1)
         units{i} = '';
      end
      units{cat} = unit;
%     o = opt(o,['category.',typ,'.units'],units);
      o = opt(o,[tags.category,'.units'],units);
      varargout{1} = o;
      return
   end
%
% Never walk beyond this point
%
   assert(0);
   return
end

%==========================================================================
% Actualize Category Options
%==========================================================================

function [oo,m] = Actualize(o)
%
   tags = Tags(o,o.type);              % tag for config options & settings
   m = 0;
   for (i=1:config(o,inf))
      [~,~,~,cat] = config(o,i);
      m = max(m,cat);               % determine max category
   end
%
% now we know the max category number m
%
   typ = type(o,o);                    % get actual type
%  limits = opt(o,['category.',typ,'.limits']);
   limits = opt(o,[tags.category,'.limits']);
   
   limits = [limits; zeros(m,2)];      % provide big enough dimension
   limits = limits(1:m,:);             % truncate to proper size

%  specs = opt(o,['category.',typ,'.specs']);
   specs = opt(o,[tags.category,'.specs']);
   
   specs = [specs; zeros(m,2)];        % provide big enough dimension
   specs = specs(1:m,:);               % truncate to proper size

%  units = opt(o,{['category.',typ,'.units'],{}});
   units = opt(o,{[tags.category,'.units'],{}});
   
   for (i=1:m)
      if i > length(units)
         units{i} = '';             % init units
      end
   end
   units = units(1:m);                 % truncate to proper size

   category.limits = limits;
   category.specs = specs;
   category.units = units;
   
%  oo = opt(o,['category.',typ],category);
   oo = opt(o,tags.category,category);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function n = Number(o)                 % Number of Categories          
%
   tags = Tags(o,o.type);
   
   typ = type(o,o);                    % get actual type
%  specs = opt(o,['category.', typ,'.specs']);
   specs = opt(o,[tags.category,'.specs']);
%  limits = opt(o,['category.',typ,'.limits']);
   limits = opt(o,[tags.category,'.limits']);
%  units = opt(o,['category.', typ,'.units']);
   units = opt(o,[tags.category,'.units']);
   
   n = max([size(specs,1),size(limits,1),length(units)]);
end
function Show(o,otype)                 % Show Category Parameters      
%
   tags = Tags(o,o.type);
   
   if Tags(o)                          % new style of config options
      bag = o.either(opt(o,'config'),struct(''));
      list = fields(bag);
   else
      cats = opt(o,'category');
      if isempty(cats)
         return
      end
      list = fields(cats);
   end
   
   oo = o;                             % copy to a working object
   for (k=1:length(list))
      typ = list{k};
      if (nargin >= 2)
         if ~isequal(otype,typ)
            continue
         end
      end

      if (nargin >= 2)
         fprintf('      categories:\n');
      else
         fprintf('      categories for type ''%s''\n',typ);
      end
      
      oo.type = typ;
      n = category(oo,inf);
      if (n == 0)
         fprintf('      no categories defined yet!\n');
         continue
      end
   
      for (i = 1:n)
         [spec,limit,unit] = category(oo,i);
         txt = sprintf('         #%g: spec = [%g %g],  ',i,spec(1),spec(2));
         txt1 = txt;   % txt(1:24);

         txt = sprintf('limit = [%g %g],  ',limit(1),limit(2));
         txt2 = txt;                 % txt(1:20);

         fprintf([txt1,txt2,'unit = ''%s''\n'],unit);
      end
   end
end
function [tags,tag] = Tags(o,typ)      % Get tags for options and settings
   new = true;                         % flag indicating new world
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
