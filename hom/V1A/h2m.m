function rv = h2m(arg1,arg2)
%
% H2M       Homogeneous coordinate vector or homogeneous
%           transformation matrix to 3H homogeneous representation
%
%              vh = h2m(v)       % homogeneous coordinate vector
%              Th = h2m(T,v)     % homogeneous coordinate transformation
%              Th = h2m(T,0)     % homogeneous coordinate transformation
%
%          Works with 2D vectors or matrices.
%
%          The result is always a 3H vector or matrix.
%
%          Theory:
%
%             h2m(v) = [v;1]
%             h2m(V) = [V;ones(1,n)]   % n = size(V,2)
%
%             h2m(T,v) = [T,v; zeros(n,1), 1]  % n = size(T,2)
%
%           See also: ROBO, IHOM
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
   
% eof   