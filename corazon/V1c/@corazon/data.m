function varargout = data(o,tag,value,varargin)  
%
% DATA   Get or set object data settings
%  
%    Object data is stored in object's data properties.
%  
%       bag = data(o)                  % get data settings
%       data(o,bag)                    % refresh all data settings
%
%    Get/set specific data setting
%
%       x = data(o,'x')                % get value of specific data 
%       o = data(o,'x',x)              % set value of specific data
%
%       x = data(o,{'x',3})            % get with default value (if empty)
%       o = data(o,{'x'},3)            % set with default value (if empty)
%
%    Multiple data get/set
%
%       [x,y,z] = data(o,'x','y','z')  % multiple data get
%       o = data(o,'x',1,'y',2,...)    % multiple data set
%
%    Package management
%
%       oo = data(o,{o1,o2,o3});       % set list of traces
%       list = data(o);                % return list of traces
%       oo = data(o,0);                % return container object            
%       oo = data(o,3);                % return 3rd object in list            
%       o = data(o,3,oo);              % replace 3rd object in list            
%
%    Indexing can only happen if the data is actually a list. With the 
%    syntax we can investigate the length of the list (or NaN is returned
%    if data is no list).
%
%       len = data(o,inf)              % length of list or NaN
%
%       dat = {o1,o2,o3}               % define as list of objects
%       len = data(data(o,dat),0)      % return 3
%         
%       dat = struct('x',x,'y',y)      % define data as structure
%       len = data(data(o,dat),0)      % return NaN
%
%    Note: it is assumed that in case of object lists all elements of the
%    list are (non-container) objects. For future expansion, however, this
%    list must not contain objects, and DATA will also not take care of the
%    type of the actual list elements.
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, PROP
%
   section = 'data';    % here we store settings
   switch nargin
      case 1
         dat = prop(o,section);
         if (nargout == 0)
            disp(dat);
         else
            varargout{1} = dat;
         end
         
      case 2
         if isempty(tag)
            varargout{1} = prop(o,section,tag);  % clear all data
         elseif ischar(tag)
            varargout{1} = prop(o,[section,'.',tag]);
         elseif iscell(tag)
            if  length(tag) == 2 && ischar(tag{1})
               varargout{1} = prop(o,[section,'.',tag{1}]);
               if isempty(varargout{1})
                  varargout{1} = tag{2};
               end
            else
               varargout{1} = prop(o,section,tag);
            end
         elseif isstruct(tag)
            varargout{1} = prop(o,section,tag);
         elseif (isa(tag,'double'))
            idx = tag;
            if (length(idx) ~= 1)
               error('index (arg2) must be scalar!');
            end
            if (round(idx) ~= idx)
               error('index (arg2) must be an integer!');
            end

            if (idx == 0)
               varargout{1} = o;               % return container object
               return
            elseif isinf(idx)
               if iscell(o.data) || isempty(o.data)
                  o = length(o.data);   % return length of list
               else
                  o = NaN;              % return NaN (since no list)
               end
               varargout{1} = o;
               return                   % done for length of list request
            end      

               % go ahead with indexing

            if ~iscell(o.data)
               error('actual data is not for indexing!');
            end
            if (idx >= 1 && idx <= length(o.data))
               varargout{1} = o.data{idx};
            else
               varargout{1} = [];
            end
         else
            error('arg2 must be either string, structure, list or integer!');
         end
         
      case 3
         if (nargout <= 1) && ischar(tag)
            varargout{1} = prop(o,[section,'.',tag],value);
         elseif (nargout <= 1) && iscell(tag)
            curval = prop(o,[section,'.',tag{1}]);
            if isempty(curval)
               o = prop(o,[section,'.',tag{1}],value);
            end
            varargout{1} = o;
         elseif (nargout <= 1) && isa(tag,'double')
            idx = tag;                 % tag is the index
            if ~(isscalar(idx) && round(idx) == idx)
               error('index (arg2) must be a scalar integer!');
            end
            o.data{idx} = value;
            varargout{1} = o;
         elseif (nargout == 2)
            varargout{1} = data(o,tag);
            varargout{2} = data(o,value);
         else
            error('max 2 output args expected!');
         end
      otherwise
         if (nargout == 1)   % e.g. o = data(o,'x',1,'y',2,'z',3)
            if (rem(nargin,2) ~= 1)
               error('odd number of input args expected!');
            end
            o = data(o,tag,value);
            for (i=1:2:length(varargin))
               tag = varargin{i};  value = varargin{i+1};
               if ~ischar(tag)
                  error(sprintf('char expected for arg %d!',i+3));
               end
               o = data(o,tag,value);
            end
            varargout{1} = o;
         else
            if (nargin-1 ~= nargout)
               error('nargout must be nargin-1!');
            end
            varargout{1} = data(o,tag);
            varargout{2} = data(o,value);
            for (i=3:nargout)
               varargout{i} = data(o,varargin{i-2});
            end
         end
   end
end

