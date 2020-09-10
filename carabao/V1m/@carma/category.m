function varargout = category(o,cat,spec,limit,unit)
%
% CATEGORY   Setup or display categories
%
%    Syntax:
%
%       [spec,limit,unit] = category(o,cat);   % get category attributes
%
%       o = category(o,cat,spec,limit,unit);   % setup category
%       o = category(o,1,[0 0],[0 0],'µ');     % setup category 1
%       o = category(o,1,[],[],'µ');           % same as above
%       o = category(o,2,[-3 3],[-4 4],'µ');   % setup category 2
%
%       n = category(o,inf)                    % number of categories
%       category(o)                            % list categories
%
%       [o,m] = category(o)                    % actualize category opts
%                                              % return number m of cat's
%
%    Remark: categories are stored in opt(o,'category');
%
%    See also: CARALOG, CONFIG, SUBPLOT
%

%
% One input arg and no output arg
% a) category(o) % list categories
%
   while (nargin == 1 && nargout == 0) % list categories               
      Show(o);                         % show categories
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
% For 2 and more input args arg2 must be a scalar integer > 0
%
   if ~(isa(cat,'double') && length(cat) == 1)
      error('arg2 must be a scalar number!');
   end
   if (round(cat) ~= cat || cat < 1)
      error('arg2 must be an integer > 0!');
   end
%
% For 2 input args we have to retrieve category attributes
% a)  n = category(o,inf) % number of categories
% b) [spec,limit,unit] = category(o,cat);   % get category attributes
%
   while (nargin == 2)
      if isinf(cat)
         varargout{1} = Number(o);  % return number of categories
         return
      end

         % get spec
         
      specs = opt(o,'category.specs');
      varargout{1} = [0 0];
      if (size(specs,1) >= cat)
         varargout{1} = specs(cat,:);
      end
      
         % get limit
         
      limits = opt(o,'category.limits');
      varargout{2} = [0 0];
      if (size(limits,1) >= cat)
         varargout{2} = limits(cat,:);
      end
      
         % get unit
         
      units = opt(o,'category.units');
      varargout{3} = '';
      if (length(units) >= cat)
         varargout{3} = units{cat};
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
      if (any([m n]~=[1 2]) || ~isa(limit,'double'))
         error('spec dimension (arg3) must be 1x2!');
      end
      
      specs = opt(o,'category.specs');
      [m,n] = size(specs);

      for (i=m+1:cat-1)
         specs(i,1:2) = [0 0];
      end
      specs(cat,1:2) = spec;
      o = opt(o,'category.specs',specs);
      
         % update limits
         
      [m,n] = size(limit);
      if (any([m n]~=[1 2]) || ~isa(limit,'double'))
         error('limit dimension (arg4) must be 1x2!');
      end
      
      limits = opt(o,'category.limits');
      [m,n] = size(limits);
      
      for (i=m+1:cat-1)
         limits(i,1:2) = [0 0];
      end
      limits(cat,1:2) = limit;
      o = opt(o,'category.limits',limits);
      
         % update units
         
      if ~ischar(unit) 
         error('unit (arg5) must be string!');
      end
      
      units = opt(o,'category.units');
      m = length(units);
      for (i=m+1:cat-1)
         units{i} = '';
      end
      units{cat} = unit;
      o = opt(o,'category.units',units);
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
   m = 0;
   for (i=1:config(o,inf))
      [~,~,~,cat] = config(o,i);
      m = max(m,cat);               % determine max category
   end
%
% now we know the max category number m
%
   limits = opt(o,'category.limits');
   limits = [limits; zeros(m,2)];   % provide big enough dimension
   limits = limits(1:m,:);          % truncate to proper size

   specs = opt(o,'category.specs');
   specs = [specs; zeros(m,2)];     % provide big enough dimension
   specs = specs(1:m,:);            % truncate to proper size

   units = opt(o,{'category.units',{}});
   for (i=1:m)
      if i > length(units)
         units{i} = '';             % init units
      end
   end
   units = units(1:m);              % truncate to proper size

   category.limits = limits;
   category.specs = specs;
   category.units = units;
   
   oo = opt(o,'category',category);
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function n = Number(o)                 % Number of Categories
%
   specs = opt(o,'category.specs');
   limits = opt(o,'category.limits');
   units = opt(o,'category.units');
   
   n = max([size(specs,1),size(limits,1),length(units)]);
   return
end

function Show(o)
%
   n = category(o,inf);
   if (n == 0)
      fprintf('   no categories defined yet!\n');
      return
   end
   
   for (i = 1:n)
      [spec,limit,unit] = category(o,i);
      txt = sprintf('   #%g: spec = [%g %g],  ',i,spec(1),spec(2));
      txt1 = txt;   % txt(1:24);
      
      txt = sprintf('limit = [%g %g],  ',limit(1),limit(2));
      txt2 = txt;                 % txt(1:20);
      
      fprintf([txt1,txt2,'unit = ''%s''\n'],unit);
   end
   return
end
