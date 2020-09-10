function [cmd,out,olist] = args(obj,idx)
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
%       func = args(1);             % func = 'run';
%       arg1 = args(2);             % arg1 = 'a';
%       arg2 = args(3);             % arg2 = 'b';
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
