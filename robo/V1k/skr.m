function [S,K,R] = skr(M)
%
% SKR       SKR factorizaton of a matrix.
%
%              [S,K,R] = rks(M)     % SKR factorization: M = S*K*R
%
%           To a given matrix M calculate the decomposed matrices S,K,R,
%           where
%                M = S*K*R
%           and
%                S ... shear matrix (upper triangular with all diagonal elements =1)
%                K ... scale matrix (K = diag(ki))
%                R ... rotation matrix (orthonormal: R'*R = R*R' = E)
%
%           Theory:
%                Let M = S*K*R, so inv(M) = inv(R)*inv(K)*inv(S)
%                RKS-Factorize inv(M) = Ri*Ki*Si
%                and R = inv(Ri), K = inv(Ki), S = inv(Si)
%
%           See also: ROBO, ROT, SCALE, SHEAR
%
   [m,n] = size(M);
   if ( m ~= n ) error('arg1 must be a quadratic matrix!'); end
   if ( m < 2 | m > 3 ) error('arg1 must be 2D or 3D matrix!'); end
   
   if ( nargout == 0 )
      if m == 2
         hskr(h2m(M,0));
      elseif m == 3
         hskr(hom(M,0));
      else
         error('bug!');
      end
   elseif nargout == 1
      if m == 2
         S = hskr(h2m(M,0));
      elseif m == 3
         S = hskr(hom(M,0));
      else
         error('bug!');
      end
   else
      if ( norm(M) <= 100*eps )  % null matrix
         K = 0*M;  S = eye(size(M));  R = S;
      else
         [Ri,Ki,Si] = rks(inv(M));
         R = inv(Ri);  K = inv(Ki);  S = inv(Si);
      end
   end
   
% eof   