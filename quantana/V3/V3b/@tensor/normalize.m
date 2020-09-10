function obj = normalize(obj)
% 
% NORMALIZE   Normalize a vector
%
%                S = space(tensor,{'a','b','c'})
%
%                V0 = normalize(V);
%                V1 = normalize(S('a')+S('b'));
%
   switch format(obj)
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
