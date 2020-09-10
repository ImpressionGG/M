function l = last(v)
%
% LAST	 l = last(v) returns the last element of a vector v. Thus it
%      	 is exactly the same as [m,n]=size(v); l = v(m*n); The function
%         works also for cell arrays.
%
   [m,n] = size(v);
   if numel(v), % if ( m*n )
      if iscell(v)
         l = v{m*n};
      else
         l = v(m*n);
      end
   else
      l = [];
   end
%
