function Y = map(o,C,X,kind)
%
% MAP   Deal with fitting maps
%       
%    General mapping. Does both mapping and calculation of the map
%
%       C = map(o,X,Y,0)   % calculate linear map
%       C = map(o,X,Y,1)   % calculate affine map
%       C = map(o,X,Y,2)   % calculate order 2 map
%
%       C = map(o,X,Y,-2)  % calculate map by 2 corners
%       C = map(o,X,Y,-3)  % calculate map by 3 corners
%       C = map(o,X,Y,-4)  % calculate map by 4 corners
%       C = map(o,X,Y,-5)  % calculate map by 5 corners
%
%       Y = map(o,C,X)     % map X to Y
%
%    Meaning of the arguments
%
%       C: map coefficients
%       X: input vector set
%       Y: output vector set
%
%    Example:
%
%       C = camera([0 2 0],[80 40],[30 30 30]*deg);
%       V = vchip; F = photo(C,V);
%
%       C1 = map(o,V,F,1);  F1 = map(o,C1,V);
%       C2 = map(o,V,F,2);  F2 = map(o,C2,V);
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, PLOT
%
   while (nargin == 3)   % actual mapping                              
      
      [m,n] = size(X);
      if ( m == 1 )              % 1D input vector

         if all(size(C) == [1 1])
            Y = C*X;
         elseif all(size(C) == [1 2]) || all(size(C) == [2 1])
            Y = C(1)*X + C(2);
         else
            error('unsupported size of C!');
         end
         
      elseif ( m == 2 )              % 2D input vector set
         
         if all(size(C)==[2 2])  % simple linear map
            Y = C*X;                  
         elseif all(size(C)==[3 3])       % affine map (H3-matrix)
            Y = Ihom(C*[X; 0*sum(X)+1]);
         elseif all(size(C,1)==2 & size(C,2)>=6)       % order n map
            %Y = bili(X,C);
            Y = NlMap(C,X);
         else
            error('bad sized input args!')
         end
         
      elseif ( m == 3 ) % 3D input vector set
         
         if all(size(C)==[3 3])  % simple linear map
            Y = C*X;                  
         elseif all(size(C)==[4 4])       % affine map (H4-matrix)
            Y = Ihom(C*[X; 0*sum(X)+1]);
         else
            error('bad sized input args!')
         end
         
      else
         error('2D or 3D input vector set expected!')
      end
      return
   end
%
% 3 input args
%
   while ( nargin == 4 )  % calculate map                              
      
      Y = Velim(X);  X = Velim(C);  % interprete input args - eliminate NANs
      
      [m,n] = size(X);
      if any(size(X)~=size(Y))
         error('sizes of input args must match!')
      end
      
      if (m == 1)
         C = OneDMap(X,Y,kind);     % calculate 1D-mao
      elseif ( m == 2 )             % 2D input vector set
         
         if ( kind == 0 )           % calculate linear map: Y = C*X
            C = Y/X;                % linear regression
         elseif ( kind == 1 )       % affine map - calculate 3H matrix
            Xh = [X; 0*sum(X)+1];   % 3H vector set - preserve NANs!
            Yh = [Y; 0*sum(Y)+1];   % 3H vector set - preserve NANs!
            C = Yh/Xh;              % 3H matrix
         elseif ( kind >= 2 )
            % C = bili(X,Y');       % order 2 map
            C = NlMap(X,Y,kind);    % order n map
         elseif (kind == -2)
            Corners(C);  % initialize corners
            idx = Corners; idx = idx(3:4);
            X0 = X(:,idx);  Y0 = Y(:,idx);
            x = diff(X0(1,:)+sqrt(-1)*X0(2,:));
            y = diff(Y0(1,:)+sqrt(-1)*Y0(2,:));
            phi = angle(y)-angle(x);
            k = abs(y)/abs(x);
            K = scale(k,k);
            R = rot(phi);
            T = R*K;
            x0 = Y0(:,1) - T*X0(:,1);
            C = H2m(T,x0);
         elseif (kind == -3)
            Corners(C);  % initialize corners
            idx = Corners; idx = idx(2:4);
            C = map(X(:,idx),Y(:,idx),1);
         elseif (kind == -4)
            Corners(C);  % initialize corners
            idx = Corners; idx = idx(1:4);
            C = map(X(:,idx),Y(:,idx),1);
         elseif (kind == -5)
            Corners(C);  % initialize corners
            idx = Corners; idx = idx(1:5);
            C = map(X(:,idx),Y(:,idx),1);
         else
            error('bad value for arg3!')
         end
         
      elseif ( m == 3 ) % 3D input vector set
         if ( kind == 0 )           % calculate linear map: Y = C*X
            C = Y/X;                % linear regression
         elseif ( kind == 1 )       % affine map - calculate 3H matrix
            Xh = [X; 0*sum(X)+1];   % 4H vector set - preserve NANs!
            Yh = [Y; 0*sum(Y)+1];   % 4H vector set - preserve NANs!
            C = Yh/Xh;              % 4H matrix
         else
            error('bad value for arg3!')
         end
      else
         error('2D or 3D input vector set expected!')
      end
      
      Y = C;  % output argument is map coefficient matrix
      return
   end
%
% anything beyond that point is a syntax error
%   
   error('2 or 3 input args expected!');
   return
end

%==========================================================================
% Nonlinear Mapping
%==========================================================================

function [ret,G] = NlMap(arg1,arg2,order)   % Nonlinear Map            
%
% NLMAP  Nonlinear map
%
%           C = NlMap(X,Y,order)   % calculate map
%           Y = NlMap(C,X)         % actual mapping of a vector set
%           G = NlMap(X)
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
%           y = NlMap(C,x) = C * g(x)
%
%        or
%
%           Y = NlMap(C,[x1,...xN]) = C*G 
%
%        where
%                 G = [g(x1),...,g(xN)]
%                 g(x) = [1  x  y  x*x  2*x*y  y*y x*x*x 3*x*x*y 3*x*y*y y*y*y]'
%
%        See also: CORE, MAP, HOM, IHOM, 
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
         CC = NlMap(X,Y,order-1);
         C(:,1:size(CC,2)) = CC;
      end
      C=Y/G;
      ret = C;
   else
      error('bug!');
   end
   return
end

%==========================================================================
% 1D Map Calculation
%==========================================================================

function C = OneDMap(x,y,kind)
%
% ONEDMAP   Calculate 1D-map
%
%              y = k*x + d
%
%              => Sum_i{[k*xi+d - yi]^2} -> min
%
%              d/dk = 0:  Sum(i){2*(k*xi+d - yi)*xi = 0
%                         k*Sum(xi*xi) + d*Sum(xi) = Sum(yi*xi)
%
%              d/dd = 0:  Sum(i){2*(k*xi+d - yi)*1 = 0
%                         k*Sum(xi) + d*Sum(1) = Sum(yi)
%
%              [x'*x   x'*1]   [  k  ]     [ x'*y ]
%              [           ] * [     ]  =  [      ]
%              [x'*one 1'*1]   [  d  ]     [ y'*1 ]
%
   if (kind ~= 1)
      error('only affine map (linear regression) supported!');
   end
   x = x(:);  y = y(:);  one = 0*x + 1;
   A = [x'*x, x'*one;  x'*one, one'*one];
   B = [x'*y; y'*one];
   C = A\B;
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function rv = Hom(arg1,arg2)           % Homogenious Coordinate Transf.
%
% HOM       Homogeneous coordinate vector or homogeneous
%           transformation matrix
%
%              vh = Hom(v)       % homogeneous coordinate vector
%              Th = Hom(M,v)     % homogeneous coordinate transformation
%              Th = Hom(M,[])    % homogeneous coordinate transformation
%              Th = Hom([],v)    % homogeneous coordinate transformation
%
%          Works with 2D, 3D, or 4H vectors or matrices. If a 2D-vector or
%          2D-matrix is provided, a 3H result is returned. A 4H vector set
%          is directly returned. Providing both a 4H matrix and a 4H vector
%          is an error!
%
%          The result is either a 3H or 4H vector or matrix.
%
%          Theory:
%
%             Hom(v) = [v;1]
%             Hom(V) = [V;ones(1,n)]   % n = size(V,2)
%
%             Hom(M,v) = [M,v; zeros(n,1), 1]  % n = size(M,2)
%
%           See also: CORE, IHOM
%
   if (nargin == 1)
      V = arg1;
      
      [m,n] = size(V);
      if (m < 2 | m > 4) error('arg1 must be 2D, 3D or 4H vector or vector set!'); end
      
      %if (m == 2) V = extz(V); end
      
      if (m == 4)
         rv = V;
      else
         rv = [V;0*sum(V)+1];   % 0*sum(V)+1 preserves NANs!
      end
      
   elseif (nargin == 2)
      M = arg1; v = arg2;
      
      if (isempty(v)) v = 0*M(:,1); end
      if (isempty(M)) M = eye(length(v)); end
      if (min(size(v))==1) v = v(:); end  % both row and column vector work!
      
      [m,n] = size(M);
      if any(size(M) ~= size(M'))
         error('arg1 must be quadratic!') 
      end
      if (m < 2 | m > 3) error('arg1 must be 2x2 or 3x3 matrix!'); end
      
      if (length(v) < 1) v = zeros(size(M(:,1))); end
      
      if any(size(M(1,:)')~= size(v))
         error('arg2 must be a proper dimensioned column vector!') 
      end
      
      %if (m == 2)
      %   M = [M [0;0]; 0 0 1];  v = extz(v);
      %end
      
      if (m == 4)
         error('2 4H arguments not allowed!')
      else
         rv = [M v; 0*sum(M) 1];  % 0*sum(M) is a proper dimensioned zero-row
      end
   end
   return
end

function [V,v] = Ihom(Vh)              % Inverse Homogenious Transf.   
%
% IHOM      Inverse homogeneous coordinate transformation
%
%              v = Ihom(vh)      % coordinate vector
%              V = Ihom(Vh)      % set of coordinate vectors
%
%              [T,v] = Ihom(Th)  % decomposition of Th = hom(T,v) 
%
%           Works with 2- or 3-vectors or matrices
%
%           Theory:
%
%              Ihom(v) = v(1:m-1) / v(m)  % m = length(v)
%
%           Note: Ihom(Vh) = Ihom(k*Vh) for all k~=0 !!!
%
%           See also: CORE, MAP
%
   [m,n] = size(Vh);
   
   if ( nargout == 1 )
      V = Vh(1:m-1,:) ./ (ones(m-1,1)*Vh(m,:)); 
   elseif (nargout == 2)
      if (m ~= n | m < 3 | m > 4) error('arg1 must be a quadratic 3H or 4H matrix!'); end
      if ( m == 3 )
         V = Vh(1:2,1:2);  v = Vh(1:2,3);
      elseif (m == 4)
         V = Vh(1:3,1:3);  v = Vh(1:3,4);
      else
         error('bug!')
      end
   else
      error('only one or two output args expected!');
   end
   return
end

function idx = Corners(K)              % Corner Indices                
%
% CORNERS   Corner indices
%
%              Corners(K)      % initialize by a vector set
%              idx = Corners
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
   return
end

function rv = H2m(arg1,arg2)           % Homogenious Coordinate Transf.
%
% H2M       Homogeneous coordinate vector or homogeneous
%           transformation matrix to 3H homogeneous representation
%
%              vh = H2m(v)       % homogeneous coordinate vector
%              Th = H2m(T,v)     % homogeneous coordinate transformation
%              Th = H2m(T,0)     % homogeneous coordinate transformation
%
%          Works with 2D vectors or matrices.
%
%          The result is always a 3H vector or matrix.
%
%          Theory:
%
%             H2m(v) = [v;1]
%             H2m(V) = [V;ones(1,n)]   % n = size(V,2)
%
%             H2m(T,v) = [T,v; zeros(n,1), 1]  % n = size(T,2)
%
%           See also: CORE, MAP
%
   if (nargin == 1)
      V = arg1;
      
      [m,n] = size(V);
      if (m < 2 | m > 2) error('arg1 must be 2D vector or vector set!'); end
      
      rv = [V;0*sum(V)+1];   % 0*sum(V)+1 preserves NANs!
      
   elseif (nargin == 2)
      T = arg1; v = arg2;
      
      if (arg1==0) arg1 = zeros(2); end
      if (arg2==0) arg2 = [0;0]; end
      if (all(size(arg2)==[1 2])) arg2 = arg2'; end
      
      [m,n] = size(T);
      if any(size(T) ~= size(T'))
         error('arg1 must be quadratic!') 
      end
      if (m < 2 | m > 2) error('arg1 must be 2x2 matrix!'); end
      
      if (length(v) <= 1) v = zeros(size(T(:,1))); end
      
      if any(size(T(1,:)')~= size(v))
         error('arg2 must be a proper dimensioned column vector!') 
      end
      
      if (m == 2)
         rv = [T v; 0 0 1];  v = extz(v);
      elseif (m == 3 | m == 4)
         error('2 4H arguments not allowed!')
      else
         rv = [T v; 0*sum(T) 1];  % 0*sum(T) is a proper dimensioned zero-row
      end
   end
   return
end

function V = Velim(Vnan)
%
% VELIM     Eliminate all columns with NANs of a vector set.
%
%              V = Velim(Vnan)
%
%           See also: CORE, MAP
%
   idx = find(isnan(sum(Vnan)));   % dirty trick: sum(.) preserves NANs
   V = Vnan;
   V(:,idx) = [];
   return
end

