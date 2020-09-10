function U = gramschmidt(obj,X)
%
% GRAMSCHMIDT   Gram-Schmidt procedure to calculate an orthonormal 
%               basis according to a give set X of linear independent
%               basis vectors
%
%                  U = gramschmidt(quantana,X);
%
%               See also: QUANTANA
%
   n = size(X,2);
   
   if (rank(X) ~= min(size(X)))
      warning('rank deficite!');
   end
   
   for (j=1:n)
      xj = X(:,j);
      vj = xj;
      for (k=1:j-1)
         vj = vj - U(:,k) * U(:,k)'*xj;
      end
      uj = vj / sqrt((vj'*vj));    % normalize
      U(:,j) = uj;           % store in a matrix U = [u1,u2,...,uj]
   end
   return
   
% eof   