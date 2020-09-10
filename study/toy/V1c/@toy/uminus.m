function out = uminus(obj)
% 
% UMINUS  Unary minus operator for tensors
%
%             H = space(toy,1:3);
%             A = eye(H);                % operator on H
%             V = A(1);
%
%         Usage of unary minus operator
%
%            B = -A;
%            V = -V;
%
%
   switch type(obj)
      case {'#OPERATOR','#VECTOR'}
         out = obj*(-1);
         
      case '#PROJECTOR'
         out = obj;
   end
   return
end

