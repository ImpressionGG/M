function idx = index(v)
%
% INDEX   Return index range of a vector or matrix:
%
%	      idx = index([3 5 7])	     => [1 2 3]
%
%	      idx = index([4 6 7; 8 9 2])    => [1 3 5; 2 4 6]
%

   idx = v;		  % preserve dimensions
   [m,n] = size(v);
   idx(:) = 1:m*n;

% eof
