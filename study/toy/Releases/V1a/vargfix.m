function varargs = vargfix(varargs)
%
% VARGFIX  Fix vararg list
%
%    Fix varargs list if nest level of vararg list is to deep
%    caused by subsequent class inheritance in class constructors.
%
%       vargs = vargfix(vargs);
%
%    See also: CORE
%
   if (length(varargs) == 1)     % check calling convenience
      if (iscell(varargs{1}))    % for handing over varargin list
         varargs = varargs{1};   % remove one level!
      end
   end
   return
end
   
