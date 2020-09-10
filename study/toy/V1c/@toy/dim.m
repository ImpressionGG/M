function [m,n] = dim(obj)
%
% DIM        Get dimension of a space, vector or operator
%
%               H = space(toy,{'u';'d'});
%               n = dim(obj);
%
%               op = operator(H,M);
%               n = dim(op);         % same as n = dim(space(op))                
%
%            Two output arguments return sizes of the operator
%
%               [m,n] = dim(op)
%
%            See also: TOY, VECTOR, PROJECTOR
%
   typ = type(obj);
   
   switch typ
      case {'#SPACE','#CSPACE','#VECTOR','#OPERATOR','#PROJECTOR','#SPLIT','#UNIVERSE'}
         if (nargout <= 1)
            m = property(obj,'dimension');
         else
            [m,n] = size(labels(obj));
         end
      otherwise
         error('bad type!');
   end
   
   return
end
