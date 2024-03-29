function [R,K,S] = rks(M)
%
% RKS       RKS factorizaton of a matrix.
%
%              [R,K,S] = rks(M)     % RKS factorization: M = R*K*S
%
%           To a given matrix M calculate the decomposed matrices R,K,S,
%           where
%                M = R*K*S
%           and
%                R ... rotation matrix (orthonormal: R'*R = R*R' = E)
%                K ... scale matrix (K = diag(ki))
%                S ... shear matrix (upper triangular with all diagonal elements =1)
%
%           Theory:
%                Let D := K*S, so M = R*D
%                Further M'*M = D'*R'*R*D = D'*E*D = D'*D
%                D can be solved by Cholesky factorization D'*D = U, where U = M'*M
%                Finally: K = diag(D(i,i)), S = K\D and R = M/D
%
%           See also: ROBO, ROT, SCALE, SHEAR
%

% Change history
%    2009-12-02 avoid numerical crash for singular matrix (Robo/V1k)

   [m,n] = size(M);
   if ( m ~= n ) error('arg1 must be a quadratic matrix!'); end
   if ( m < 2 | m > 3 ) error('arg1 must be 2D or 3D matrix!'); end
   
   if ( nargout == 0 )
      if m == 2
         hrks(h2m(M,0));
      elseif m == 3
         hrks(hom(M,0));
      else
         error('bug!');
      end
   elseif nargout == 1
      if m == 2
         R = hrks(h2m(M,0));
      elseif m == 3
         R = hrks(hom(M,0));
      else
         error('bug!');
      end
   else
      if ( norm(M) <= 100*eps )  % null matrix
         K = 0*M;  S = eye(size(M));  R = S;
      else
         if (det(M) == 0)%    2009-12-02 avoid numerical crash for singular matrix (Robo/V1k)
             M = M + diag([1e-15 1e-15]);
         end
         D = chol(M'*M);        % Cholesky factorization D'*D = U, where U = M'*M
         K = diag(diag(D));
         S = K\D;
         R = M/D;
      end
   end
   
% eof   