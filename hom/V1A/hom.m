function rv = hom(arg1,arg2)
%
% HOM       Homogeneous coordinate vector or homogeneous
%           transformation matrix
%
%              vh = hom(v)       % homogeneous coordinate vector
%              Th = hom(M,v)     % homogeneous coordinate transformation
%              Th = hom(M,[])    % homogeneous coordinate transformation
%              Th = hom([],v)    % homogeneous coordinate transformation
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
%             hom(v) = [v;1]
%             hom(V) = [V;ones(1,n)]   % n = size(V,2)
%
%             hom(M,v) = [M,v; zeros(n,1), 1]  % n = size(M,2)
%
%           See also: ROBO, IHOM
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
   
% eof   