function n = norm(obj)
% 
% NORM    Calculate norm of a toy object
%
%             H = space(toy,[1:3;4:6]);        % Hilbert space H
%             V = 5*H('1');                    % a vector on H
%             n = norm(V);                     % calculate the norm of V
%
%         See also: TOY, SPACE, VECTOR
%
   switch type(obj)
      case '#VECTOR'
         M = matrix(obj)+0;
         n = norm(M(:));

      case '#OPERATOR'
         M = matrix(obj)+0;
         n1 = sqrt(trace(M'*M));
         
         n = norm(M);
         
         if ~(abs(n-n1) < 30*eps)
            fprintf('*** norm mismatch %g <-> %g\n',n,n1);
            %beep
         end
         
      otherwise
         error(['bad type: ',type(obj)]);
   end
   return

end
