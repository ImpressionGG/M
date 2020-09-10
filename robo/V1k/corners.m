function idx = corners(K)
%
% CORNERS   Corner indizes
%
%              corners(K)      % initialize by a vector set
%              idx = corners
%
%           Order of corners are:
%              1) lower left
%              2) upper right
%              3) lower right
%              4) upper left
%              5) center
%
%           See also: ROBO, CMAP

   global CornerIndices
   
   if (nargin >= 1)
      if ( size(K,1) ~= 2 ) error('arg1 must be a 2D-vector set!'); end
      
      x = K(1,:);
      y = K(2,:);
      
      ll = find(x==min(x) & y==min(y));  ll = ll(1);
      ur = find(x==max(x) & y==max(y));  ur = ur(1);
      lr = find(x==max(x) & y==min(y));  lr = lr(1);
      ul = find(x==min(x) & y==max(y));  ul = ul(1);
      
      cx = (min(x)+max(x))/2;  cy = (min(y)+max(y))/2;
      e = sqrt((x-cx).^2 + (y-cy).^2);
      ct = find(e == min(e));  ct = ct(1);
      
      CornerIndices = [ll, ur, lr(1), ul ct];
   end
      
   if isempty(CornerIndices)
      error('corners not initialized: enter: corners(K)!');
   end
   
   idx = CornerIndices;
   
% eof
   