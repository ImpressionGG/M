function oo = arg(o,index)
%
% ARG   Object argument handling
%
%          o = arg(o,{arg1,arg2,...})  % set list of object args
%
%          list = arg(o,0)             % get list of object args
%          list = arg(o,0)             % same as above
%          argn = arg(o,n)             % get n-th object arg
%          n = arg(o,inf)              % get number of args
%
%       Code lines: 25
%
%       See also: CARACOW, MANAGE
%
   if (nargin == 1)
      oo = work(o,'arg');              % same as arg(o,0)
   elseif iscell(index)
      o.work.arg = index;
      oo = o;
   elseif isa(index,'double')
      list = work(o,'arg');
      if isempty(list)
         if (index == 0)
            oo = {};                   % return empty list
         elseif isinf(index)
            oo = 0;
         else
            oo = [];                   % return empty matrix
         end
         return
      end
         
      if (index == 0)
         oo = list;
      elseif (index > 0) && (index <= length(list))
         oo = list{index};
      elseif isinf(index)
         oo = length(list);            % return number of args
      else
         oo = [];
      end
   end
end
