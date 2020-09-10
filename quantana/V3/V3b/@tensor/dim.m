function [m,n] = dim(obj)
%
% DIM        Get dimension of a space, vector or operator
%
%               S = space(tensor,{'u','d'});
%               n = dim(obj);
%
%               op = operator(S,M);
%               n = dim(op);         % same as n = dim(space(op))                
%
%            Two output arguments return sizes of the operator
%
%               [m,n] = dim(op)
%
%            See also: TENSOR, VECTOR, PROJECTOR
%
   fmt = format(obj);
   
   switch fmt
      case {'#SPACE','#VECTOR','#OPERATOR','#PROJECTOR','#SPLIT','#UNIVERSE'}
         if (nargout <= 1)
            m = property(obj,'dimension');
         else
            [m,n] = size(labels(obj));
         end
      otherwise
         error('bad format!');
   end
   
   return
end
