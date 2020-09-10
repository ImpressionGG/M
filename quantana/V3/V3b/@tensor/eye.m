function I = eye(obj)
%
% EYE        Identity operator
%
%               S = space(tensor,1:5);
%
%               I = operator(S,'eye');    % identity operator
%               I = eye(S);               % same as above
%
%            See also: TENSOR, OPERATOR
%
   switch format(obj)
      case '#SPACE'
         I = operator(obj,'eye');
      case {'#OPERATOR','#PROJECTOR','#VECTOR','#SPLIT'}
         S = space(obj);
         I = operator(S,'eye');
      otherwise
         error(['format ',format(obj),' not supported for eye!']);
   end
   return
end
