function out = uminus(obj)
% 
% UMINUS  Unary minus operator for tensors
%
%             S = space(tensor,1:3);
%             A = eye(S);                % operator on S
%             V = A(1);
%
%         Operator sum
%
%            B = -A;
%            V = -V;
%
%
   switch format(obj)
      case {'#OPERATOR','#VECTOR'}
         out = obj*(-1);
         
      case '#PROJECTOR'
         out = obj;
   end
   return
end

