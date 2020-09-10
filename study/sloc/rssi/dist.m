function D = dist(p)
%
% DIST  Calculate distance matrix
%
%          p = [0 4 4; 0 0 3];
%          D = dist(p);
%
   [m,n] = size(p);
   D = zeros(n,n);
    
   for (i = 1:n)
      for (j=1:n)
         D(i,j) = norm(p(:,i)-p(:,j));
      end
   end
end