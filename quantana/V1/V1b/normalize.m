function psi = normalize(psi,z)
%
% NORMALIZE   Normalize a wave function or quantum mechanical state
%             in order to get 
%
%                1) psi'*psi = 1                     % psi is an n-vector
%                2) integral psi(z)'*psi(z) dz = 1   % psi(z) is a function
%
%             Calling syntax:
%
%                psi = normalize(psi)            % vector case
%                psi = normalize(psi,z)          % wave function case
%
%             To check correct normalization call the functions without 
%             assigning to output arguments
%
%                normalize(psi)    % must return 1
%                normalize(psi,z)  % must return 1
%
%             See also: QUANTANA, PROB
%
   [m,n] = size(psi);

   if (nargout == 0)   % check
      if (nargin == 1)
         check = diag(psi'*psi)';  % must equal 1
      else
         for (j=1:size(psi,2))
            psij = sqrt(sdiff(z(:))).*psi(:,j);
            check(1,j) = psij' * psij;
         end
      end
      psi = check;  % return result of check
      return
   end


   if (nargin == 1)
      if (min(m,n) == 1)
         AA = psi(:)'*psi(:);
         psi = psi / sqrt(AA);
      else
         for(j=1:n)
            AA = psi(:,j)'*psi(:,j);
            psi(:,j) = psi(:,j) / sqrt(AA);
         end
      end
   else
      sqrtdz = sqrt(sdiff(z));
      if (min(m,n) == 1)
         AA = (sqrtdz.*psi(:))' * (sqrtdz.*psi(:));
         psi = psi / sqrt(AA);
      else
         for(j=1:n)
            AA = (sqrtdz.*psi(:,j))' * (sqrtdz.*psi(:,j));
            psi(:,j) = psi(:,j) /sqrt(AA);
         end
      end
   end

   return

% eof