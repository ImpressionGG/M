function [ret,G] = nlmap(arg1,arg2,order)
%
% NLMAP  Nonlinear map
%
%           C = nlmap(X,Y,order)   % calculate map
%           Y = nlmap(C,X)         % actual mapping of a vector set
%           G = nlmap(X)
%
%        Meaning of arguments:
%
%           C     ... map coefficients
%           X     ... input vector set
%           Y     ... output vector set
%           order ... mapping order            
%
%        Theory of operation:
%
%           y = nlmap(C,x) = C * g(x)
%
%        or
%
%           Y = nlmap(C,[x1,...xN]) = C*G 
%
%        where
%                 G = [g(x1),...,g(xN)]
%                 g(x) = [1  x  y  x*x  2*x*y  y*y x*x*x 3*x*x*y 3*x*y*y y*y*y]'
%
%        See also: ROBO, MAP
%
   if (nargin == 1)
      X = arg1;
   elseif (nargin == 2)
      C = arg1; X = arg2; 
   elseif (nargin == 3)
      X = arg1; Y = arg2;
   else
      error('1,2 or 3 input args expected!')
   end
   
   [m,n] = size(X);
   one = ones(n,1);
   
   if (m == 1)   % input vector dimension = 1
      x = X(1,:)';  xx = x.*x;        
      G = one;          dim(1) = size(G,2);
      G = [one, x];     dim(2) = size(G,2);
      G = [G, xx];      dim(3) = size(G,2);
      G = [G, xx.*x];   dim(4) = size(G,2);
      G = [G, xx.*xx];  dim(5) = size(G,2);
   elseif (m == 2)   % input vector dimension = 2
      x = X(1,:)';  y = X(2,:)'; xx = x.*x;  xy = x.*y;  yy = y.*y;
      G = one;                        dim(1) = size(G,2);
      G = [one, x, y];                dim(2) = size(G,2);
      G = [G, xx yy xy];              dim(3) = size(G,2);
      G = [G, xx.*x yy.*y xx.*y x.*yy ];     dim(4) = size(G,2);
      G = [G, xx.*xx yy.*yy xx.*xy xx.*yy xy.*yy];  dim(5) = size(G,2);
   elseif (m == 3)   % input vector dimension = 3
      x = X(1,:)';  y = X(2,:)';  z = X(3,:)';
      xx = x.*x; yy = y.*y;  zz = z.*z;  
      xy = x.*y; xz = x.*z;  yz = y.*z;
      xxx = xx.*x; yyy = yy.*y; zzz = zz.*z;
      G = one;              dim(1) = size(G,2);
      G = [one, x y z];         dim(2) = size(G,2);
      G = [G, xx yy zz xy xz yz];        dim(3) = size(G,2);
      G = [G, xxx yyy zzz xx.*y xx.*z yy.*x yy.*z zz.*x zz.*y x.*y.*z];     dim(4) = size(G,2);
      G = [G, xx.*xx yy.*yy zz.*zz xxx.*y xxx.*z yyy.*x yyy.*z zzz.*x zzz.*y xx.*yy xx.*zz yy.*zz];  dim(5) = size(G,2);
   elseif (m == 4)   % input vector dimension = 4
      error('vector dimension 4 not supported!')
   else
      error('bad input vector dimension (only 1,2,3,4 supported!)')
   end
   G = G';
          
   if (nargin == 1)
      ret = G;
   elseif (nargin == 2)  % actual mapping
      G = G(1:size(C,2),:);      
      Y = C*G;
      ret = Y;
   elseif (nargin == 3)    % calculate map
      G = G(1:dim(order+1),:);      
      GG = G*G';
      if (rank(GG) == length(GG))
         C = Y*G'*inv(GG);
      else
         C = 0*(Y*G'*GG);       % proper sized zero matrix
         CC = nlmap(X,Y,order-1);
         C(:,1:size(CC,2)) = CC;
      end
      C=Y/G;
      ret = C;
   else
      error('bug!');
   end

% eof
