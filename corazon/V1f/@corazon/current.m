function [oo,index] = current(o,varargin)  % Get/Set Current Object    
%
% CURRENT   Get current trace object & data stream/vector
%
%    Based on contents of list of traces, object type and selection index
%    return current selected trace object.
%
%       oo = current(o)                % get current trace object
%       [oo,index] = current(o)        % get also current index
%
%       o = current(o,oo);             % update current object
%       current(o,oo);                 % push updated object into shell
%
%       oo = current(o,{oo})           % provide proper options for 'oo'
%
%    Accessing shell object:
%
%       oo = current(corazon)          % get current trace object
%       [oo,index] = current(corazon)  % get also current index
%       o = current(corazon,oo);       % update current object
%
%    Remark: depending on option 'mode.options' the options are either
%    inherited from the container object or are taken from the trace object.
%    For a fast access the call oo = current(o,oo) provides always the right
%    options. Also object args are transfered properly.
%
%    Consider the following cases:
%
%       A) Object's figure method (figure(o)) returns non-empty. In this
%       case proceed directly with 1) or 2)
%
%       B) Object's figure method (figure(o)) returns empty. In this case
%       object is replaced by shell object (o=pull(corazon)) and proceed
%       with 1) or 2).
%
%       1) Object (o) is not a container object (check with container method).
%       in this case CURRENT returns the current object.
%
%       2) Object is a container object (check with container method).
%          a) empty [] is returned if control(o,'current') is outside the
%             index range.
%          b) indexed object data(o,control(o,'current')) will be returned
%
%    Change selection (changes settings)
%
%    All these functions check if new selection differs from current
%    selection. If yes (differing) then the virtual menu function 
%    menu(o,'Current') will be invoked which usually will change set-
%    tings  and update the Trace menu. If the default functionality of 
%    menu(o,'Current') is not appropriate an overloaded function can be
%    provided to adopt for required functionality.
%
%       current(o,3)                   % set 3rd trace in list as current
%       oo = current(o,3)              % set 3rd trace current and get oo
%
%       oo = current(o,'First');       % select first object in list
%       oo = current(o,'Last');        % select last object in list
%       oo = current(o,'Next');        % select next object in list
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON
%
   if isempty(figure(o))
      o = pull(o);                     % replace o by current shell object
      if nargin == 2 && isobject(varargin{1})
         oo = Update(o,varargin{1});
         push(oo);
         return
      end
   end
   
   while (nargin == 1)                                                 
      [oo,index] = Current(o);
      return
   end
%
% Two input args and second argument is a cell array
% 1) oo = current(o,{oo})              % provide proper options for 'oo'
%
   while nargin == 2 && iscell(varargin{1})    % provide proper options
      list = varargin{1};
      oo = list{1};
      if (length(list) ~= 1)
         error('1x1 cell array expected for arg2!');
      end
      oo = Options(oo,o);                      % transfer options properly
      oo = work(oo,'object',work(o,'object')); % transfer object handle
      oo = arg(oo,arg(o,0));                   % transfer args properly
      return
   end
%
% Two input args and second argument is an object
% 1) o = current(o,oo) % update current object
%
   while nargin == 2 && isobject(varargin{1})  % provide proper options
      if (nargout == 0)
         o = pull(o);
         o = Update(o,varargin{1});
         push(o);
         refresh(o);                   % refresh screen
      else
         o = Update(o,varargin{1});
         oo = o;                       % otherwise return object to caller
      end
      return
   end
%
% Otherwise: two input args, second arg is a double
%
   while nargin == 2 && isa(varargin{1},'double')                      
      index = varargin{1};
      if isempty(index)
         index = 0;
      end
      o = pull(o);                     % refresh object
      oo = Select(o,index);
      return
   end
%
% Otherwise: two input args, second arg is a string
%
   while nargin == 2 && isa(varargin{1},'char')                        
      gamma = eval(['@',varargin{1}]);
      oo = gamma(o);
      return
   end
%
% we should never come here!
%
   error('bad calling syntax:1 or 2 input args expected!');
end

%==========================================================================
% Local Functions
%==========================================================================

function [oo,index] = Current(o)       % Select Current Object         
%
% CURRENT   Get current object
%

      % we need to pull object again to refresh figure and options
      
   args = arg(o,0);                    % save arguments
% the next line was commented, but this is completely wrong semantics !!!!
% thus we need to pull !!! Don't know which side effects this fix has ???
   o = pull(o);                        % refresh options
   o = arg(o,args);                    % restore arguments
   
   if ~container(o)
      oo = o;  index = 0;              % return object
   elseif container(o)
      n = data(o,inf);                 % get number of traces in container
      index = control(o,{'current',0});
      if (1 <= index && index <= n)
         oo = data(o,index);           % get object with given index
         oo = inherit(oo,o);           % transfer options properly
      else
         oo = o;                       % bad index, return object
      end
   end
end
function oo = Select(o,index)          % Select Object by Index        
%
% SELECT   Select trace object by numeric index
%          Ignore if not a container object
%
   assert(isa(index,'double') && ~isempty(index));
   
   oo = o;                             % same object by default
   if container(o)
      n = data(o,inf);   idx = index(1);
      if (n >= 0) && (idx <= n)
         assert(isequal(class(o),o.tag));  % o is balanced!

            % if class has changed we have to refresh the callback
         
         if Changes(o,idx);            % has class changed?
            refresh(o,{'menu','About'});
         end
         
            % update current index and get current object
            % although I think we do not need the old index any more
            
         control(o,'current',idx);     % update current index
         o = pull(o);                  % mandatory to refresh object!
         oo = Current(o);              % return current object

            % rebuild menu and update all dynamic menu items
            
 %       active(o,oo.type);            % change active object
         active(o,oo);                 % make sure object is active
         event(o,'select');            % Invoke SELECT event
         title(oo);
         dynamic(o,oo);                % update all dynamic menu items
         
         plugin(oo,[o.tag,'/current/Select']);  % plug point
      end
   end
end
function oo = First(o)                 % Select First Object           
%
% FIRST   Select first trace object
%         Ignore if not a container object
%
   oo = current(o,1);                  % select first object
   return
end
function oo = Last(o)                  % Select Last Object of List    
%
% LAST   Select last trace object
%        Ignore if not a container object
%
   n = data(o,inf);
   oo = current(o,n);
   return
end
function oo = Next(o)                  % Select Next Object in List    
%
% NEXT   Select next trace object in trace list
%        Ignore if not a container object
%
   oo = o;                                % same object by default
   if container(o)
      n = data(o,inf);                    % get length of list
      if (n > 0)
         [~,k] = current(o);              % get current index
         if (k < n)
            oo = balance(o);              % balance object
            oo = menu(oo,'Current',k+1);  % set index n current
   %        setting('shell.current',n);
   %        o = pull(corazon);            % refresh object
            oo = Current(oo);             % return current object
         end
      end
   end
   return
end
function o = Update(o,oo)              % Update Current Object in List 
%
% UPDATE   Update current object
%
%             o = Update(arg(o,2,oo))
%
%          Ignore if o (arg1) is not a container object.
%          Pass through if oo (arg2) is a container object.
%
%fprintf('*** warning: current>Update is going to be obsoleted\n!')
   %o = pull(o);                       % pull object from figure
   if (nargin < 2)
      oo = arg(o,1);
   end
   
   if container(o)
      n = data(o,inf);                 % get length of list
      if (n == 0)
         if ~container(oo)
            error('object (arg2) must be a container object!');
         end
         o = oo;
         % push(oo);                   % push oo back to figure
      elseif (n > 0)
         [~,k] = current(o);           % get current index
         if (k == 0)
            if ~container(oo)
               error('object (arg2) must be a container object!');
            end
            oo = balance(oo);          % balance object
            o = oo;                    % pass through
         elseif (k <= n)
            if container(oo)
               error('object (arg2) must not be a container object!');
            end
            oo = balance(oo);          % balance object
            list = data(o);            % get object list
            list{k} = oo;              % replace current trace
            o = data(o,list);          % update list
            % push(o);                 % refresh shell object
         end
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function changed = Changes(o,idx)      % Has Class Changed             
%
% CHANGES   Has the class changed?
%
   cold = 'old?';  cnew = 'new?';      % init with stupid stuff
   n = length(o.data);
   
   old = control(o,'current');         % old index
   cnull = class(o);                   % class for index = 0

   cold = cnull;
   if (old > 0) && (old <= n)
      cold = class(o.data{old});
   end
   
   cnew = cnull;
   if (idx > 0) && (idx <= n)
      cnew = class(o.data{idx});
   end
   changed = ~isequal(cold,cnew);
end
