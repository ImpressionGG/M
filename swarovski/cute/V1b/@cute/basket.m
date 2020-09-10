function [oo,idx] = basket(o,arg2)     % Basket of Selected Objects    
%
% BASKET   Get list of objects in basket, or display basket settings.
%
%    The objects in the basket list inherit work properties from the 
%    container object in a proper way (see INHERIT method).
%
%       [list,idx] = basket(o)         % list & indices of basket objects
%       basket(o)                      % print selecting options
%
%    Are some objects in basket with type from given type list?
%
%       ok = basket(o,{'shell','weird','cube'})
%
%    Perform operation gamma on all objects of the basket list
%
%       oo = basket(o,gamma)           % perform gamma on basket list
%
%    Note that the basket can contain only objects of a class which matches
%    exactly the class of the current selected object. This is nessessay
%    to provide proper dynamic menus.
%
%       oo = basket(o,'Menu')          % setup basket menu
%       oo = basket(o,'Index')         % get basket indices
%
%    Example 1: plot all objects of a basket
%
%       list = basket(o);
%       for (i=1:length(list))
%          oo = list{i};
%          plot(oo);
%       end
%
%    Example 2: a typical Basket() function to perform a basket operation 
%
%       function o = Basket(o)         % perform basket operation                   
%          refresh(o,o);               % use this callback for refresh
%          cls(o);                     % clear screen
%          gamma = eval(['@',mfilename]);
%          oo = basket(o,gamma);       % perform operation gamma on basket   
%          if ~isempty(oo)             % irregulars happened?
%             message(oo);             % report irregular
%          end
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CUTE, INHERIT
%
   o.profiler('Basket',1);             % begin profiling
   [either,iif] = util(o,'either','iif');   % need some utility
   
   collect = opt(o,{'basket.collect','selected'});
   groups = opt(o,{'basket.groups','*'});
%
% No out args and 1 input arg: show info about option settings
% a) basket(o)                         % print selecting options
%
   while nargin == 1 && nargout == 0   % print selecting options       
      Info(o);
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% One out arg and 1 input arg: return list of selected objects
% b) [list,idx] = basket(o) % list & indices of basket objects
%
   while nargin == 1 && nargout >= 1   % list of selected objects      
      [list,idx] = Basket(o);
      oo = list;                       % out arg
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% Two input args: type found in basket?
% c) ok = basket(o,{'cube','ball'})    % type found in basket?
%
   while nargin == 2 && iscell(arg2)   % type supporting?              
      types = arg2;                    % arg2 is a list of types
      for (i=1:length(types))
         if ~ischar(types{i})
            error('type list (arg2) must contain character strings!');
         end
      end
      
      list = basket(o);      
      for (i=1:length(list))
         if o.is(type(list{i}),types)
            oo = true;                 % found a type from type list
            o.profiler('Basket',0);    % end profiling
            return
         end
      end
      
      oo = false;                      % no type from type list found
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% Two input args: perform operation gamma on basket
% d) ok = basket(o,gamma)              % type found in basket?
%
   while nargin == 2 && isa(arg2,'function_handle') % perform operation
      oo = Perform(o,arg2);            % perform operation on basket
      o.profiler('Basket',0);          % end profiling
      return
   end
%   
% Two input args and 2nd arg is a character string 
% a) oo = basket(o,'Menu')
%
   while nargin == 2 && ischar(arg2)
      switch arg2
         case 'Menu'
            oo = Menu(o);
         case 'Index'
            oo = Index(o);
         otherwise
            error('bad mode (arg2)');
      end
      o.profiler('Basket',0);             % end profiling
      return
   end
%
% if we reach here something with the calling syntax is wrong
%
   error('bad calling syntax (1 in arg an 0 or 1 out args expected)!');
end

%==========================================================================
% Basket Tag Definition
%==========================================================================

function tags = BasketTags(o)          % Get List of Basket Tags       
   tags = {'station','apparatus','damping','kappl','lage','vcut','vseek'};
end

%==========================================================================
% Basket Menu
%==========================================================================

function oo = Menu(o)                  % Setup Basket Menu             
   oo = current(o);
   switch oo.type
      case 'pkg'
         oo = PkgMenu(o);
      case 'shell'
         oo = ShellMenu(o);
      otherwise
         oo = o;
   end
end
function oo = PkgMenu(o)               % Setup Basket Menu @ Package   
   bag = opt(o,{'basket',struct});
   oo = current(o);
   oo = var(oo,bag);
   
      % copy basic elements from bag of settings
      
   basket.collect = var(oo,'collect');
   basket.type = var(oo,'type');
   
      % add object specifics
    
   tags = BasketTags(o);
   for (i=1:length(tags))
      tag = tags{i};
      values = get(oo,tag);
      choices = Unique(oo,values);
      basket = AddSpecifics(oo,basket,tag,choices);
   end
   
      % refresh basket setting and setup Basket menu
      
   setting(o,'basket',basket);
   o = opt(o,'basket',basket);
   oo = BasketMenu(o);                 % setup Basket menu @ basket setting
end
function oo = ShellMenu(o)             % Setup Basket Menu @ Shell Obj 
   assert(container(o));

   bag = opt(o,{'basket',struct});
   o = var(o,bag);
   
      % copy basic elements from bag of settings to new basket struct
      
   basket.collect = var(o,'collect');
   basket.type = var(o,'type');
 
      % next generate a list of package objects
      
   packages = {};                      % list of packages
   oo = o;
   for (i=1:length(o.data))
      oo = o.data{i};
      if type(oo,{'pkg'})
         packages{end+1} = oo;
      end
   end
   
      % build basket option
      
   tags = BasketTags(o);
   for (i=1:length(tags))
      tag = tags{i};
      values = Values(packages,tag);
      choices = Unique(o,values);
      basket = AddSpecifics(oo,basket,tag,choices);
   end
   
      % refresh basket setting and setup Basket menu
      
   setting(o,'basket',basket);
   o = opt(o,'basket',basket);
   oo = BasketMenu(o);                 % setup Basket menu @ basket setting

   function values = Values(packages,tag)
      if isempty(packages)
         values = [];
         return
      end

         % start with initial values
         
      assert(length(packages) >= 1);
      values = get(packages{1},tag);
      
         % now merge values of package objects
         
      for (i=2:length(packages))
         oo = packages{i};
         vali = get(oo,tag);
         
            % trivial cases - one of them (values,vali) is empty
            
         if isempty(values) && isempty(vali)
            values = [];
            continue
         elseif isempty(values) && ~isempty(vali)
            values = vali;
            continue
         elseif ~isempty(values) && isempty(vali)
            continue
         end

            % both values and vali are non-empty
            
         if iscell(values) && iscell(vali)
            values = [values,vali];
         elseif isa(values,'double') && isa(vali,'double')
            values = [values(:)',vali(:)'];
         elseif isequal(values,vali)
            continue
         else
            fprintf('*** warning: incompatible baskets - cannot merge!\n');
         end            
      end
   end
end
function oo = BasketMenu(o)            % Setup Basket Menu @ Basket    
   oo = mhead(o,'Basket');
   basket = opt(o,'basket');
   tags = fields(basket);

   for (i=1:length(tags))
      tag = tags{i};
      if o.is(tag,{'collect','type'})
         continue
      end

         % otherwise tag stands for a menu item

      entry = basket.(tag);
      ooo = mitem(oo,entry.label);
      for (j=1:length(entry.choices))
         tagj = sprintf('basket.%s.enable%g',tag,j);
         oooo = mitem(ooo,entry.choices{j},{},tagj);
         check(oooo,{});
      end
   end
end

%==========================================================================
% Basket List
%==========================================================================

function [list,index] = Basket(o)      % Get Basket of Objects         
   o = pull(o);                        % shell object
   [oo,idx] = current(o);
   if container(oo)
      list = oo.data;  
      index = 1:length(oo.data);
      if isempty(list)
         list = {oo};  index = idx;
      end
   else
      list = {oo};  index = idx;
   end
end
function index = Index(o)              % Get Basket Indices            
   switch o.type
      case 'pkg'
         o = cache(o,'package');       % soft refresh package
         objects = cache(o,'package.objects');
         index = 1:length(objects);
         
            % reduce index by filtering
            
         ftags = FilterTags(o);        % get list of filter tags
         for (k=1:length(ftags))
            ftag = ftags{k};
            index = Filter(o,index,ftag);
         end
      case 'shell'
         %basket = opt(o,'basket');     % save basket settings
         %o = pull(o);                  % refresh shell object
         %o = opt(o,'basket',basket);   % restore basket settings
         
         %for (i=1:length(o.data))
         %   oo = o.data{i};
         %end
         error('implementation');
   end
   
   function list = FilterTags(o)                                       
      basket = opt(o,{'basket',struct});
      list = {};
      
      tags = fields(basket);
      for (j=1:length(tags))
         tagj = tags{j};
         entry = basket.(tagj);
         if isfield(entry,'choices')   % then we found a filter entry
            list{end+1} = tagj;
         end
      end
   end
   function index = Filter(o,index,tag)% Filtering                     
      tags = Enabled(o,tag);
      
      key = ['package.',tag];
      items = cache(o,key);
      number = cache(o,'package.number');
      
         % extend items to respect multiple numbers
         
      while(0)
         numbers = cache(o,'package.numbers');
         xitems = o.iif(iscell(items),{},[]);

         for (i=1:length(numbers))
            ndx = find(number==numbers(i));
            if iscell(xitems)
               xitems{i} = items(ndx);
            else
               xitems(i) = items(ndx);
            end
         end
      end
         
         % loop ...
      
      for (i=1:length(index))
         if isa(items,'double')        % double arrays
%           item = xitems(index(i));
            item = items(index(i));
            item = sprintf('%g',item); % convert to char
         elseif iscell(items)          % cell array
            %item = xitems{index(i)};
            item = items{index(i)};
         else                          % otherwise be tolerant
            continue
         end
         
         if ~o.is(item,tags)
            index(i) = NaN;         % mark index to be deleted
         end
      end
      
      idx = find(isnan(index));
      if (idx)
         index(idx) = [];
      end
   end
   function list = Enabled(o,tag)      % list of Enabled Items         
      basket = opt(o,{'basket',struct});
      tags = fields(basket);
      list = {};
      
      if isfield(basket,tag)
         entry = basket.(tag);
         choices = entry.choices;
         for (i=1:length(choices))
            tagi = sprintf('enable%g',i);
            if isfield(entry,tagi)
               if entry.(tagi)
                  list{end+1} = choices{i};
               end
            else
               list{end+1} = choices{i};
            end
         end
      end
   end
end

%==========================================================================
% Helper Functions
%==========================================================================

function [list,idx] = Classes(o,ilist,index)  % Filter Proper Class    
   name = class(o);
   list = {};  idx = [];
   for (i=1:length(ilist))
      oo = ilist{i};
      if isequal(class(oo),name)
         list{end+1} = oo;  idx(end+1) = index(i);
      end
   end
end
function [list,idx] = Types(o,ilist,index)    % Filter Selected Types  
   type = opt(o,{'basket.type','*'});
   list = ilist;  idx = index;
   if ~isequal(type,'*')
      list = {};  idx = [];
      for (i=1:length(ilist))
         oo = ilist{i};
         if o.is(oo.type,type)
            list{end+1} = oo;  idx(end+1) = index(i);
         end
      end
   end
end
function Info(o)                       % Show selecting option settings
%
% INFO   Display selection info
%
   o = pull(o);                        % refresh options
   either = util(o,'either');          % need some utility
   
   [oo,idx] = current(o);              % get index of current object
   
   collect = opt(o,{'basket.collect',''''''});
   groups = opt(o,{'basket.groups',''''''});
   classname = class(oo);
   type = opt(o,{'basket.type','*'});

   fprintf('  Current Selection\n');
   if (idx == 0)
      fprintf('    all objects of shell\n');
   else
      title = get(oo,{'title',''});
      fprintf('    object #%g: %s\n',idx,title);
   end
   influence = corazon.iif(idx==0,'(no influence)','');
   fprintf('  Basket class\n');
   fprintf('    class:  %s\n',classname);
   fprintf('  Basket options %s\n',influence);
   fprintf('    collect: %s\n',collect);
   %fprintf('   groups:  %s\n',groups);
   fprintf('    type:   %s\n',type);
   fprintf('  Objects in basket\n');
   
   [list,idx] = basket(o);
   for (i = 1:length(list))
      title = get(list{i},{'title',''''''});
      fprintf('    object #%g: %s\n',idx(i),title);
   end
   return
end
function oo = Perform(o,gamma)         % Perform Operation on Basket   
%
% PERFORM   Perform operation on the basket. If regulars happen then
%           return non-empty object with a short description of irregular
%           in title and comment. Calling routine may decide to report
%           irregular situation by calling message()
%
   list = basket(o);

   if isempty(list)
      oo = set(o,'title','No objects!');
      oo = set(oo,'comment',{'(import object or create a new one)'});
      return                        % irregular happened
   else
      dirty = 0;
      for (i=1:length(list))
         oo = list{i};
         if container(oo)
            return;                 % irregular happened
         else
            oo = opt(oo,'hold',1,'index',i);
            ooo = gamma(oo);           % forward to sample/Plot method
            hold on;                   % saves work for plot helpers

            dirty = dirty + ~isempty(ooo);
         end
      end

      if ~dirty
         oo = current(o);           % irregular happened
         return
      end
   end

   oo = [];                         % no irregulars happened
end
function list = Unique(o,tags)         % Get Unique Parameter List     
   list = {};
   numbers = [];
   for (i=1:length(tags))
      if iscell(tags)
         tag = tags{i};
      else
         tag = sprintf('%g',tags(i));
      end
      if ~o.is(tag,list)
         list{end+1} = tag;
         if isa(tags,'double')
            numbers(end+1) = tags(i);
         end
      end
   end
   
      % return sorted list of choices
      
   if ~isempty(list) && length(list) == length(numbers)
      [~,idx] = sort(numbers);
      list = list(idx);
   else
      list = sort(list);   
   end
end
function basket = AddSpecifics(o,basket,tag,choices)                   
   label = [upper(tag(1)),tag(2:end)];

   entry.label = label;
   %entry.choices = Unique(o,get(o,tag));
   entry.choices = choices;
   for (j=1:length(entry.choices))
      tagj = sprintf('enable%g',j);
      entry.(tagj) = 1;
   end
   basket.(tag) = entry;
end
