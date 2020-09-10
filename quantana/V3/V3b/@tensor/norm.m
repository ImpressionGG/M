function n = norm(obj)
% 
% NORM    Calculate norm of a tensor object
%
%             H = space(tensor,[1:3;4:6]);  % Hilbert space H
%             V = 5*S('1');                 % a vector on H
%             n = norm(V);                  % calculate the norm of V
%
%         See also: TENSOR, SPACE, VECTOR
%
   switch format(obj)
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
         error(['bad format: ',format(obj)]);
   end
   return

end
