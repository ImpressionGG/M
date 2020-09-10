function obj = normalize(obj)
% 
% NORMALIZE   Normalize a vector
%
%                S = space(toy,{'a','b','c'})
%
%                V0 = normalize(V);
%                V1 = normalize(S('a')+S('b'));
%
%             See also: TOY, NORM, VECTOR, OPERATOR
%
   switch type(obj)
      case '#VECTOR'
         M = matrix(obj);
         N = norm(obj);
         
         if (N ~= 0)
            M = M/N;
         end
         obj = matrix(obj,M);    % update object with normalized matrix
         
      otherwise
         error('#VECTOR expected');
   end
   
   return
end
