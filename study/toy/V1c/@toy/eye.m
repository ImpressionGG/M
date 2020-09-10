function I = eye(obj)
%
% EYE   Identity operator
%
%    Syntax
%       H = space(toy,1:5);
%
%       I = operator(H,'eye');          % identity operator
%       I = eye(H);                     % same as above
%
%       iseye = property(I,'eye?');
%
%    See also: TOY, OPERATOR
%
   switch type(obj)
      case '#SPACE'
         I = operator(obj,'eye');
      case {'#OPERATOR','#PROJECTOR','#VECTOR','#SPLIT'}
         S = space(obj);
         I = operator(S,'eye');
      otherwise
         error(['type ',type(obj),' not supported for eye!']);
   end
   return
end
