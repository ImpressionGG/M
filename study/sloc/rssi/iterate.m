function q = iterate(p,D,M,noise,alfa)
%
% ITERATE   iterate position
%
%              p = iterate(p,D)
%              p = iterate(p,D,M,alfa)
%
   if (nargin < 3)
      M = ones(size(D));
   end
   if (nargin < 4)
      alfa = 0.1;
   end
      
   D = (D+D')/2;                       % symmetrize
   
   [m,n] = size(p);
   q = p .* (1+noise*randn(size(p)));                              % updated positions
   
   for (i=1:n)
      for (j=1:i-1)
         if ( M(i,j) )
            pi = p(:,i);  pj = p(:,j);

            v = pi - pj;                  % distance vector
            d  = norm(v);
            if (d == 0)
               e = 0*v;
            else
               e = v/d;
            end
            delta = d - D(i,j);
            dq = e*delta;
           
            q(:,i) = q(:,i) - alfa*dq;
            q(:,j) = q(:,j) + alfa*dq;
         end
      end
   end
   
end
