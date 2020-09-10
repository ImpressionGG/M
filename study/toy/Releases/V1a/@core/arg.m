function [value,out,olist] = arg(obj,idx,value)
%
% ARG   Get object's argument during callback
%
%    Set arguments: Two possibilies are possible. Either the argument is a
%    list. Then one can use a two argument call. If no list then 3
%    arguments have to be provided for setting the argument directly.
%
%       obj = arg(obj,{})         % set empty argument list
%       obj = arg(obj,{'abc',pi}) % set argument list with two arguments
%       obj = arg(obj,[],value)   % synonym for: obj = set(obj,'arg',value)
%
%    Get arguments
%
%       value = arg(obj)          % synonym for: value = get(obj,'arg')
%       value = arg(obj,0)        % get argument list
%       value = arg(obj,1)        % get first argument in list
%       value = arg(obj,i)        % get i-th argument in list
%
%    Assume now that an object is prepared with an argument list, e.g.
%
%       obj = arg(obj,{'run','a','b',...});   % set argument list
%
%    Then the following calling syntax is an easy way to retrieve the
%    complete arg list:
%
%       arglist = arg(obj);
%
%    A more powerful use of ARG is the calling syntax
%
%       [func,obj,list] = arg(obj);
%
%          % func = 'run', list = {'a','b',...}
%          % obj = arg(obj,list)
%
%    It will end-up in a split of function and pure argument list,
%    while the returned object will have an adopted argument setup
%    with only 'list' and the first arg (func) removed.
%
%    Individual access of arguments:
%
%       func = args(obj,1,[]);             % func = 'run';
%       arg1 = args(obj,2,[]);             % arg1 = 'a';
%       arg2 = args(obj,3,[]);             % arg2 = 'b';
%
%    See also: CORE, GFO, DISPATCH
%
   if (nargout <= 1 && nargin == 1)
      
      value = get(obj,'arg');
      
   elseif (nargout > 1 && nargin == 1)

      list = arg(obj);
      if ~isempty(list)
         if ~iscell(list)
            list = {list};
         end
      end
      
      if isempty(list)
         cmd = [];
         olist = {};
      else
         cmd = list{1};
         list(1) = [];
         olist = list;
      end
      value = cmd;
      out = arg(obj,[],olist);
      
      %[value,out,olist] = Args(obj,idx)
   
   elseif (nargout <= 1 && nargin == 2)

      if isa(idx,'cell')
         value = set(obj,'arg',idx);
         return
      elseif ~isa(idx,'double')
         error('double expected for argument index (arg2)!');
      end
      
      list = get(obj,'arg');
      if ~isempty(list) && ~iscell(list)
         list = {list};
      end
      if (idx == 0)
         if isempty(list)
            list = {};
         end
         value = list;                         % return arg list
      elseif (idx < 1 || idx > length(list))
         value = [];
      else
         value = list{idx};
      end
      
   elseif (nargout <= 1 && nargin == 3)
      
      value = set(obj,'arg',value);
      
   else
      error('cannot process calling syntax!');
   end
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [cmd,out,olist] = DummyArgs(obj,idx)
%
% ARGS   Convenient way to get object's arguments
%
%    If an object is prepared with an argument list, e.g.
%
%       obj = arg(obj,{'run','a','b',...});   % set argument list
%
%    then the following calling syntax is an easy way to retrieve the
%    complete arg list:
%
%       arglist = args(obj);       % arglist = {'run','a','b',...}
%
%    A more powerful use of args is the calling syntax
%
%       [func,obj,list] = args(obj);
%
%          % func = 'run', list = {'a','b',...}
%          % obj = arg(obj,list)
%
%    It will end-up in a split of function and pure argument list,
%    while the returned object will have an adopted argument setup
%    with only 'list' and the first arg (func) removed.
%
%    Individual access of arguments:
%
%       func = args(obj,1);             % func = 'run';
%       arg1 = args(obj,2);             % arg1 = 'a';
%       arg2 = args(obj,3);             % arg2 = 'b';
%
%    See also: SHELL, GFO, ARG
%
   list = arg(obj);
   if ~isempty(list)
      if ~iscell(list)
         list = {list};
      end
   end
      
      
   if (nargin == 1)
      if (nargout <= 1)
         cmd = either(list,{});    % if empty then return an empty list
      else
         if isempty(list)
            cmd = [];
            olist = {};
         else
            cmd = list{1};
            list(1) = [];
            olist = list;
         end
         out = arg(obj,olist);
      end
   elseif (nargin == 2)
      if (idx < 1 || idx > length(list))
         cmd = [];
      else
         cmd = list{idx};
      end
   end
   return
end   
